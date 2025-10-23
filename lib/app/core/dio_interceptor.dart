// lib/core/dio_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'errors.dart';
import 'constants.dart';

class AppInterceptor extends Interceptor {
  final VoidCallback? onUnauthorized;

  AppInterceptor({this.onUnauthorized});

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    // Attach bearer token if present
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(PREFS_AUTH_TOKEN);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    options.headers['Accept'] = 'application/json';
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // map Dio errors to our ApiException types
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      handler.reject(DioException(
          requestOptions: err.requestOptions,
          error: NetworkException('Request timed out')));
      return;
    }

    final response = err.response;
    if (response != null) {
      final status = response.statusCode ?? 0;

      if (status == 401) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(PREFS_AUTH_TOKEN);

        // Trigger unauthorized callback to update auth state
        onUnauthorized?.call();
      }

      if (status == 422) {
        final data = response.data;
        final errorsMap = <String, List<String>>{};
        if (data is Map && data['errors'] is Map) {
          (data['errors'] as Map).forEach((k, v) {
            errorsMap[k.toString()] = List<String>.from(v as List);
          });
        }
        handler.reject(DioException(
            requestOptions: err.requestOptions,
            error: ValidationException(errorsMap, statusCode: 422),
            response: response));
        return;
      } else {
        final message = (response.data is Map && response.data['error'] != null)
            ? response.data['error']
            : response.statusMessage ?? 'Unknown error';

        handler.reject(DioException(
            requestOptions: err.requestOptions,
            error: ApiException(message, statusCode: status),
            response: response));
        return;
      }
    }

    // Fallback
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: NetworkException(err.message ?? 'Network error'),
      ),
    );
  }
}
