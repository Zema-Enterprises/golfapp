/// API exception types for handling network errors

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  const ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({String message = 'Unauthorized'})
      : super(message: message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException({String message = 'Forbidden'})
      : super(message: message, statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException({String message = 'Not found'})
      : super(message: message, statusCode: 404);
}

class ValidationException extends ApiException {
  final Map<String, List<String>>? errors;

  const ValidationException({
    String message = 'Validation failed',
    this.errors,
  }) : super(message: message, statusCode: 422);
}

class ServerException extends ApiException {
  const ServerException({String message = 'Internal server error'})
      : super(message: message, statusCode: 500);
}

class NetworkException extends ApiException {
  const NetworkException({String message = 'Network error'})
      : super(message: message, statusCode: null);
}
