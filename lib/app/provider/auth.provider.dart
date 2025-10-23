// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:mytodo/app/repository/auth.repository.dart';
import '../core/errors.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repo;
  bool _loading = false;
  bool get loading => _loading;

  bool _initializing = true;
  bool get isInitializing => _initializing;

  bool _authenticated = false;
  bool get isAuthenticated => _authenticated;

  String? _nameError;
  String? get nameError => _nameError;

  String? _emailError;
  String? get emailError => _emailError;

  String? _passwordError;
  String? get passwordError => _passwordError;

  String? _error;
  String? get error => _error;

  AuthProvider(this._repo) {
    _init();
  }

  Future<void> _init() async {
    _initializing = true;
    notifyListeners();

    try {
      _authenticated = await _repo.hasToken();
    } catch (e) {
      _authenticated = false;
    } finally {
      _initializing = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password) async {
    _loading = true;
    _error = null;
    _emailError = null;
    _passwordError = null;
    notifyListeners();
    try {
      await _repo.login(email, password);
      _authenticated = true;
    } catch (e) {
      if (e is ValidationException) {
        _emailError = e.details['email'][0];
        _passwordError = e.details['password'][0];
      } else if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'Unknown error';
      }
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> register(String name, String email, String password,
      String passwordConfirmation) async {
    // _loading = true;
    // _error = null;
    // notifyListeners();
    try {
      await _repo.register(name, email, password, passwordConfirmation);
    } catch (e) {
      if (e is ValidationException) {
        _nameError = e.details['name'][0];
        _emailError = e.details['email'][0];
        _passwordError = e.details['password'][0];
      } else if (e is ApiException) {
        _error = e.message;
      } else {
        _error = 'Unknown error';
      }
    } finally {
      // _loading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _loading = true;
    notifyListeners();
    final status = await _repo.logout();
    if (status) {
      _authenticated = false;
    }
    _loading = false;
    notifyListeners();
  }

  void handleUnauthorized() {
    _authenticated = false;
    notifyListeners();
  }
}
