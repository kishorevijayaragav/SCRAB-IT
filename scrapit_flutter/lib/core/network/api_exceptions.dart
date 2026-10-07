class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException([String message = 'Session expired. Please sign in again.'])
      : super(message, 401);
}

class NetworkException extends ApiException {
  NetworkException([String message = 'Unable to connect to ScrapIt server. Please check your connection.'])
      : super(message);
}
