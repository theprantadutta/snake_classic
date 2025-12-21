/// Base failure class for all failures in the app
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure: $message${code != null ? ' (code: $code)' : ''}';
}

/// Server-related failures (API errors, 500s, etc.)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);

  factory ServerFailure.fromStatusCode(int statusCode, [String? customMessage]) {
    final message = customMessage ?? switch (statusCode) {
      400 => 'Bad request',
      401 => 'Unauthorized',
      403 => 'Forbidden',
      404 => 'Not found',
      422 => 'Validation error',
      429 => 'Too many requests',
      500 => 'Internal server error',
      502 => 'Bad gateway',
      503 => 'Service unavailable',
      _ => 'Server error (status: $statusCode)',
    };
    return ServerFailure(message);
  }
}

/// Cache-related failures
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

/// Network-related failures (no internet, timeout, etc.)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'No network connection']) : super(message);
}

/// Authentication-related failures
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication failed']) : super(message);
}

/// Validation failures (invalid input, etc.)
class ValidationFailure extends Failure {
  final Map<String, List<String>>? fieldErrors;

  const ValidationFailure(
    String message, {
    this.fieldErrors,
  }) : super(message);
}

/// Feature-specific failures
class GameFailure extends Failure {
  const GameFailure(String message) : super(message);
}

class PremiumFailure extends Failure {
  const PremiumFailure(String message) : super(message);
}

class LeaderboardFailure extends Failure {
  const LeaderboardFailure(String message) : super(message);
}

class SocialFailure extends Failure {
  const SocialFailure(String message) : super(message);
}

class MultiplayerFailure extends Failure {
  const MultiplayerFailure(String message) : super(message);
}
