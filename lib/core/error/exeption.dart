// ==================== EXCEPTIONS ====================
// These are thrown by data sources and repositories

/// Base exception class for all custom exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalException;

  const AppException(
      this.message, {
        this.code,
        this.originalException,
      });

  @override
  String toString() => 'AppException: $message';
}

/// Authentication related exceptions
class AuthenticationException extends AppException {
  const AuthenticationException(
      super.message, {
        super.code,
        super.originalException,
      });
}

/// Network connectivity exceptions
class NetworkException extends AppException {
  const NetworkException(
      super.message, {
        super.code,
        super.originalException,
      });
}

/// Server response exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(
      super.message, {
        this.statusCode,
        super.code,
        super.originalException,
      });
}

/// Request timeout exceptions
class TimeoutException extends AppException {
  final Duration? timeoutDuration;

  const TimeoutException(
      super.message, {
        this.timeoutDuration,
        super.code,
        super.originalException,
      });
}

/// Bad response format exceptions
class BadResponseException extends AppException {
  const BadResponseException(
      super.message, {
        super.code,
        super.originalException,
      });
}

/// Unauthorized access exceptions (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException(
      super.message, {
        super.code,
        super.originalException,
      });
}

/// Forbidden access exceptions (403)
class ForbiddenException extends AppException {
  const ForbiddenException(
      super.message, {
        super.code,
        super.originalException,
      });
}

/// Resource not found exceptions (404)
class NotFoundException extends AppException {
  const NotFoundException(
      super.message, {
        super.code,
        super.originalException,
      });
}

/// Validation exceptions (422)
class ValidationException extends AppException {
  final Map<String, dynamic>? validationErrors;

  const ValidationException(
      super.message, {
        this.validationErrors,
        super.code,
        super.originalException,
      });
}

/// Cache related exceptions
class CacheException extends AppException {
  const CacheException(
      super.message, {
        super.code,
        super.originalException,
      });
}

/// Unknown or unexpected exceptions
class UnknownException extends AppException {
  const UnknownException(
      super.message, {
        super.code,
        super.originalException,
      });
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(
      super.message, {
        super.code,
        super.originalException,
      });
}

/// File system exceptions
class FileSystemException extends AppException {
  const FileSystemException(
      super.message, {
        super.code,
        super.originalException,
      });
}

/// Business logic exceptions
class BusinessLogicException extends AppException {
  const BusinessLogicException(
      super.message, {
        super.code,
        super.originalException,
      });
}