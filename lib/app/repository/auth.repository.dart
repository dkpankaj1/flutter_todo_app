// lib/repositories/auth_repository.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:mytodo/app/core/api_client.dart';
import 'package:mytodo/app/core/constants.dart';
import 'package:mytodo/app/core/errors.dart';
import 'package:mytodo/app/model/auth.model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final ApiClient _client = ApiClient();

  Future<User> login(String email, String password) async {
    try {
      final res = await _client.dio
          .post('login', data: {'email': email, 'password': password});
      final data = res.data;
      final token = data['data']['token'];
      // save token
      final prefs = await SharedPreferences.getInstance();
      if (token != null) await prefs.setString(PREFS_AUTH_TOKEN, token);
      // attempt to build user object
      final userJson = data['data']['user'];
      final user = User.fromJson({...userJson, 'token': token});
      return user;
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw ApiException('Failed to login');
    }
  }

  Future<void> register(String name, String email, String password,
      String passwordConfirmation) async {
    try {
      await _client.dio.post('register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
    } on DioException catch (e) {
      if (e.error is ApiException) throw e.error!;
      throw ApiException('Failed to register');
    }
  }

  Future<bool> logout() async {
    try {
      await _client.dio.post('logout');
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(PREFS_AUTH_TOKEN);
      return true;
    } on DioException catch (e) {
      debugPrint(e.toString());
      // even if logout fails on server, clear local token
    }
    return false;
  }

  Future<bool> hasToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(PREFS_AUTH_TOKEN);
  }
}
