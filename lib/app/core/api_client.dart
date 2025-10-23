// lib/core/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'dio_interceptor.dart';
import 'constants.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio dio;
  VoidCallback? _onUnauthorized;

  ApiClient._internal() {
    dio = Dio(BaseOptions(
      baseUrl: API_BASE_URL,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {'Accept': 'application/json'},
    ));
    _setupInterceptors();
  }

  void _setupInterceptors() {
    dio.interceptors.clear();
    dio.interceptors.add(AppInterceptor(onUnauthorized: _onUnauthorized));
  }

  void setUnauthorizedCallback(VoidCallback callback) {
    _onUnauthorized = callback;
    _setupInterceptors();
  }
}
