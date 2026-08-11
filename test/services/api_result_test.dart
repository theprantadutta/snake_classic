import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:snake_classic/services/api_result.dart';

/// Interactive API calls used to collapse every failure into `null`. Offline,
/// a timeout, an expired session, a validation conflict, rate limiting and a
/// backend 5xx were indistinguishable at the call site — which is why a player
/// could be shown a vague "failed" for a problem that was really their
/// connection, their account, or the server, and why support could not tell
/// those apart afterwards either.
void main() {
  http.Response respond(int status, {String body = '{}', Map<String, String>? headers}) =>
      http.Response(body, status, headers: headers ?? const {});

  group('status codes map to something a caller can act on', () {
    test('2xx is a success', () {
      expect(ApiFailureClassifier.forStatus(200), isNull);
      expect(ApiFailureClassifier.forStatus(201), isNull);
      expect(ApiFailureClassifier.forStatus(204), isNull);
    });

    test('each failing status has its own meaning', () {
      expect(ApiFailureClassifier.forStatus(401), ApiFailure.unauthorized);
      expect(ApiFailureClassifier.forStatus(403), ApiFailure.forbidden);
      expect(ApiFailureClassifier.forStatus(400), ApiFailure.validation);
      expect(ApiFailureClassifier.forStatus(409), ApiFailure.validation);
      expect(ApiFailureClassifier.forStatus(422), ApiFailure.validation);
      expect(ApiFailureClassifier.forStatus(429), ApiFailure.rateLimited);
      expect(ApiFailureClassifier.forStatus(500), ApiFailure.serverUnavailable);
      expect(ApiFailureClassifier.forStatus(503), ApiFailure.serverUnavailable);
    });

    test('an unlisted 4xx is a refusal, not an outage', () {
      expect(ApiFailureClassifier.forStatus(404), ApiFailure.validation);
      expect(ApiFailureClassifier.forStatus(418), ApiFailure.validation);
    });
  });

  group('thrown errors map to transport outcomes', () {
    test('a timeout is a timeout, not a generic failure', () {
      expect(
        ApiFailureClassifier.forError(TimeoutException('slow')),
        ApiFailure.timeout,
      );
    });

    test('socket and client failures are transport failures', () {
      expect(
        ApiFailureClassifier.forError(const SocketException('no route')),
        ApiFailure.offlineOrTransport,
      );
      expect(
        ApiFailureClassifier.forError(http.ClientException('closed')),
        ApiFailure.offlineOrTransport,
      );
    });

    test('a malformed body is distinct from an outage', () {
      // The contract drifted; nothing is down. Retrying will not help and
      // telling the player to check their connection would be a lie.
      expect(
        ApiFailureClassifier.forError(const FormatException('bad json')),
        ApiFailure.badResponse,
      );
    });
  });

  group('what an outcome says about the backend being reachable', () {
    test('any HTTP answer proves the backend is there — including a refusal', () {
      // This is the crux. Counting an expired token as "backend unreachable"
      // is exactly the false negative that used to freeze the outbox.
      for (final status in [401, 403, 409, 429]) {
        final result = ApiFailureClassifier.decodeObject(respond(status));
        expect(result.isSuccess, isFalse);
        expect(result.indicatesBackendReachable, isTrue,
            reason: '$status came FROM the backend');
        expect(result.indicatesBackendUnreachable, isFalse,
            reason: '$status must not mark the backend unreachable');
      }
    });

    test('5xx and transport failures do indicate trouble', () {
      final server = ApiFailureClassifier.decodeObject(respond(503));
      expect(server.indicatesBackendUnreachable, isTrue);

      final transport = ApiResult<void>.failed(ApiFailure.offlineOrTransport);
      expect(transport.indicatesBackendUnreachable, isTrue);
      expect(transport.indicatesBackendReachable, isFalse);

      final timeout = ApiResult<void>.failed(ApiFailure.timeout);
      expect(timeout.indicatesBackendUnreachable, isTrue);
    });

    test('a success is reachable', () {
      final ok = ApiFailureClassifier.decodeObject(respond(200));
      expect(ok.isSuccess, isTrue);
      expect(ok.indicatesBackendReachable, isTrue);
      expect(ok.indicatesBackendUnreachable, isFalse);
    });
  });

  group('decoding', () {
    test('an empty 2xx body is an empty map, not a failure', () {
      final result = ApiFailureClassifier.decodeObject(respond(204, body: ''));
      expect(result.isSuccess, isTrue);
      expect(result.value, isEmpty);
    });

    test('a 2xx that is not JSON is badResponse', () {
      final result =
          ApiFailureClassifier.decodeObject(respond(200, body: '<html>nope'));
      expect(result.failure, ApiFailure.badResponse);
    });

    test('a bare JSON array is wrapped rather than rejected', () {
      final result = ApiFailureClassifier.decodeObject(respond(200, body: '[1,2]'));
      expect(result.isSuccess, isTrue);
      expect(result.value!['data'], [1, 2]);
    });
  });

  group('retry-after and correlation', () {
    test('seconds form is honoured', () {
      final result = ApiFailureClassifier.decodeObject(
        respond(429, headers: {'retry-after': '30'}),
      );
      expect(result.failure, ApiFailure.rateLimited);
      expect(result.retryAfter, const Duration(seconds: 30));
    });

    test('an HTTP-date form is honoured', () {
      final now = DateTime.utc(2026, 8, 11, 12);
      final headers = {'retry-after': HttpDate.format(now.add(const Duration(seconds: 45)))};
      expect(
        ApiFailureClassifier.retryAfterFrom(headers, now: now),
        const Duration(seconds: 45),
      );
    });

    test('nonsense is ignored rather than guessed at', () {
      expect(ApiFailureClassifier.retryAfterFrom({'retry-after': 'soon'}), isNull);
      expect(ApiFailureClassifier.retryAfterFrom(const {}), isNull);
    });

    test('a correlation id survives so a report can be matched to a log', () {
      final result = ApiFailureClassifier.decodeObject(
        respond(500, headers: {'x-request-id': 'abc-123'}),
      );
      expect(result.requestId, 'abc-123');
      expect(result.statusCode, 500);
    });
  });
}
