import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

/// What happened to an interactive API call.
///
/// Interactive calls used to collapse every failure into `null`: offline, a
/// timeout, an expired session, a validation conflict, rate limiting and a
/// backend 5xx were indistinguishable at the call site. That is why a player
/// could be shown a vague "failed" for a problem that was really their
/// connection, their account, or the server — and why support could not tell
/// those apart afterwards either.
///
/// The durable outbox keeps its own [SyncOutcome]: it needs "retry later"
/// versus "never retry", which is a different question from what to tell
/// someone standing in front of the screen.
enum ApiFailure {
  /// Never reached the server — DNS, TLS, refused, no route.
  offlineOrTransport,

  /// Reached the network but nothing answered in time.
  timeout,

  /// 401. The session is gone; re-authenticate.
  unauthorized,

  /// 403. Authenticated, and not allowed.
  forbidden,

  /// 400/409/422. The request itself was refused on its merits. Retrying it
  /// unchanged will fail the same way.
  validation,

  /// 429. Back off; [ApiResult.retryAfter] carries the server's hint when it
  /// sent one.
  rateLimited,

  /// 5xx. The backend is having a bad time. Worth retrying later.
  serverUnavailable,

  /// 2xx that could not be parsed. As broken as an error, but distinctly so —
  /// it means the contract drifted, not that anything is down.
  badResponse,
}

/// The result of an interactive API call: a value, or a reason.
class ApiResult<T> {
  const ApiResult._({
    this.value,
    this.failure,
    this.statusCode,
    this.retryAfter,
    this.requestId,
  });

  factory ApiResult.success(T value, {int? statusCode, String? requestId}) =>
      ApiResult._(value: value, statusCode: statusCode, requestId: requestId);

  factory ApiResult.failed(
    ApiFailure failure, {
    int? statusCode,
    Duration? retryAfter,
    String? requestId,
  }) => ApiResult._(
    failure: failure,
    statusCode: statusCode,
    retryAfter: retryAfter,
    requestId: requestId,
  );

  final T? value;
  final ApiFailure? failure;

  /// The HTTP status, where there was one. Never a body — bodies carry player
  /// data and belong nowhere near logs or telemetry.
  final int? statusCode;

  /// From `Retry-After`, when the server sent it.
  final Duration? retryAfter;

  /// Correlation id from the response, for matching a client report to a
  /// server log.
  final String? requestId;

  bool get isSuccess => failure == null;

  /// Whether this outcome says anything about the backend being reachable.
  ///
  /// A 4xx does NOT: the server answered, in detail, which is proof it is
  /// there. Counting an expired token as "backend unreachable" is precisely
  /// the false negative that used to freeze the outbox.
  bool get indicatesBackendUnreachable =>
      failure == ApiFailure.offlineOrTransport ||
      failure == ApiFailure.timeout ||
      failure == ApiFailure.serverUnavailable;

  /// Whether the backend demonstrably answered — any HTTP response at all,
  /// including a refusal.
  bool get indicatesBackendReachable => isSuccess || statusCode != null;

  R when<R>({
    required R Function(T value) success,
    required R Function(ApiResult<T> result) failed,
  }) => isSuccess ? success(value as T) : failed(this);

  @override
  String toString() => isSuccess
      ? 'ApiResult.success(status: $statusCode)'
      : 'ApiResult.failed(${failure!.name}, status: $statusCode)';
}

/// Turns an HTTP response or a thrown exception into an [ApiFailure].
///
/// Kept separate from ApiService so the mapping can be tested directly rather
/// than through a socket.
abstract final class ApiFailureClassifier {
  /// Classify a completed response. Returns null when it is a success.
  static ApiFailure? forStatus(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) return null;
    return switch (statusCode) {
      401 => ApiFailure.unauthorized,
      403 => ApiFailure.forbidden,
      400 || 409 || 422 => ApiFailure.validation,
      429 => ApiFailure.rateLimited,
      >= 500 => ApiFailure.serverUnavailable,
      // Any other 4xx is the request being refused on its merits.
      >= 400 => ApiFailure.validation,
      _ => ApiFailure.badResponse,
    };
  }

  /// Classify a thrown exception from an HTTP attempt.
  static ApiFailure forError(Object error) {
    if (error is TimeoutException) return ApiFailure.timeout;
    if (error is SocketException) return ApiFailure.offlineOrTransport;
    if (error is http.ClientException) return ApiFailure.offlineOrTransport;
    if (error is HandshakeException) return ApiFailure.offlineOrTransport;
    if (error is FormatException) return ApiFailure.badResponse;
    return ApiFailure.offlineOrTransport;
  }

  /// `Retry-After`, as seconds or as an HTTP date.
  static Duration? retryAfterFrom(Map<String, String> headers, {DateTime? now}) {
    final raw = headers['retry-after'] ?? headers['Retry-After'];
    if (raw == null || raw.isEmpty) return null;

    final seconds = int.tryParse(raw.trim());
    if (seconds != null) return Duration(seconds: seconds.clamp(0, 86400));

    try {
      final when = HttpDate.parse(raw);
      final from = now ?? DateTime.now();
      final delta = when.difference(from);
      return delta.isNegative ? Duration.zero : delta;
    } catch (_) {
      return null;
    }
  }

  static String? requestIdFrom(Map<String, String> headers) =>
      headers['x-request-id'] ??
      headers['X-Request-Id'] ??
      headers['x-correlation-id'];

  /// Decode a successful body, or report [ApiFailure.badResponse].
  static ApiResult<Map<String, dynamic>> decodeObject(http.Response response) {
    final requestId = requestIdFrom(response.headers);
    final failure = forStatus(response.statusCode);
    if (failure != null) {
      return ApiResult.failed(
        failure,
        statusCode: response.statusCode,
        retryAfter: retryAfterFrom(response.headers),
        requestId: requestId,
      );
    }

    if (response.body.isEmpty) {
      return ApiResult.success(
        const <String, dynamic>{},
        statusCode: response.statusCode,
        requestId: requestId,
      );
    }

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return ApiResult.success(
          Map<String, dynamic>.from(decoded),
          statusCode: response.statusCode,
          requestId: requestId,
        );
      }
      return ApiResult.success(
        <String, dynamic>{'data': decoded},
        statusCode: response.statusCode,
        requestId: requestId,
      );
    } catch (_) {
      return ApiResult.failed(
        ApiFailure.badResponse,
        statusCode: response.statusCode,
        requestId: requestId,
      );
    }
  }
}
