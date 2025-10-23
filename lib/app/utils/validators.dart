// lib/utils/validators.dart
class Validators {
  static String? required(String? v) {
    if (v == null || v.trim().isEmpty) return 'This field is required';
    return null;
  }

  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final regex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!regex.hasMatch(v.trim())) return 'Invalid email';
    return null;
  }

  static String? password(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Password must be at least 6 chars';
    return null;
  }
}
