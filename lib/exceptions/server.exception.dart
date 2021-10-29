class InternalServerErrorException implements Exception {
  String? message;
  InternalServerErrorException({
    message,
  }) {
    this.message = message ?? 'Something went wrong, please try later';
  }
}