class ValidationException implements Exception {
  final Map errors;
  final String? message;

  ValidationException({
    required this.errors,
    this.message,
  });
}