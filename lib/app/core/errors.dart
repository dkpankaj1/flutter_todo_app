class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException(this.message, {this.statusCode, this.details});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class NetworkException extends ApiException {
  NetworkException(super.message);
}

class ValidationException extends ApiException {
  final Map<String, List<String>> errors;
  ValidationException(this.errors, {int? statusCode})
      : super('Validation failed', statusCode: statusCode, details: errors);
}
