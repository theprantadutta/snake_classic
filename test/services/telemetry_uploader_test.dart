import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/services/api_result.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/telemetry/install_identity.dart';
import 'package:snake_classic/services/telemetry/telemetry_uploader.dart';
import 'package:uuid/uuid.dart';

/// A scripted stand-in for the one ApiService call the uploader makes.
class _FakeApi implements ApiService {
  _FakeApi(this.statuses);

  /// Status to answer each request with, in order; 200 once exhausted.
  final List<int> statuses;
  final List<Map<String, dynamic>> bodies = [];

  /// Runs while a request is "in flight" — for writes that race an upload.
  Future<void> Function()? during;

  @override
  Future<ApiResult<Map<String, dynamic>>> postTelemetryBatch(
    Map<String, dynamic> body,
  ) async {
    bodies.add(body);
    await during?.call();
    final status = statuses.isEmpty ? 200 : statuses.removeAt(0);
    if (status == 200) {
      return ApiResult.success(const {}, statusCode: 200);
    }
    return ApiResult.failed(
      ApiFailureClassifier.forStatus(status) ?? ApiFailure.offlineOrTransport,
      statusCode: status == 0 ? null : status,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

void main() {
  late AppDatabase db;
  late DateTime now;
  const uuid = Uuid();
  final identity = InstallIdentity(
    installId: '8f3c1a52-1c1e-4c43-9a55-3d0b6f4d2f10',
    appVersion: '6.8.0',
    build: 60,
    platform: 'android',
    design: 'living_board',
  );
  final installedAt = DateTime.utc(2026, 9, 1, 12);

  TelemetryUploader uploader(_FakeApi api, {InstallIdentity? id}) =>
      TelemetryUploader(
        dao: db.telemetryDao,
        api: api,
        identity: () => id ?? identity,
        locale: () => 'en',
        installedAt: () => installedAt,
        clock: () => now,
      );

  Future<String> addSession({
    int revision = 1,
    DateTime? startedAt,
    int runsStarted = 1,
  }) async {
    final id = uuid.v4();
    final at = startedAt ?? now;
    await db.telemetryDao.upsertSession(
      TelemetrySessionsCompanion.insert(
        sessionId: id,
        design: 'living_board',
        appVersion: '6.8.0',
        build: 60,
        startedAt: at,
        lastActiveAt: at,
        localDay: '2026-10-03',
        runsStarted: Value(runsStarted),
        revision: Value(revision),
      ),
    );
    return id;
  }

  Future<String> addFeedback({int rating = 4, DateTime? createdAt}) async {
    final id = uuid.v4();
    await db.telemetryDao.insertFeedback(
      TelemetryFeedbackCompanion.insert(
        feedbackId: id,
        design: 'living_board',
        appVersion: '6.8.0',
        rating: rating,
        trigger: 'after_runs',
        createdAt: createdAt ?? now,
      ),
    );
    return id;
  }

  /// What the tracker does to an open session: a newer snapshot, dirty.
  Future<void> rewrite(
    String id, {
    required int revision,
    required int runsStarted,
  }) =>
      (db.update(db.telemetrySessions)..where((t) => t.sessionId.equals(id)))
          .write(
        TelemetrySessionsCompanion(
          runsStarted: Value(runsStarted),
          revision: Value(revision),
          dirty: const Value(true),
        ),
      );

  Future<TelemetrySession> session(String id) async =>
      (await db.telemetryDao.sessionById(id))!;

  List<String> sentSessionIds(Map<String, dynamic> body) => [
        for (final s in body['sessions'] as List) (s as Map)['session_id'],
      ];

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    now = DateTime.utc(2026, 10, 3, 9, 30);
  });

  tearDown(() => db.close());

  test('the body carries the install, installed_at and every row', () async {
    final s = await addSession();
    final f = await addFeedback();
    final api = _FakeApi([]);
    await uploader(api).flush();

    final body = api.bodies.single;
    expect(body['install_id'], identity.installId);
    expect(body['app_version'], '6.8.0');
    expect(body['build'], 60);
    expect(body['platform'], 'android');
    expect(body['design'], 'living_board');
    expect(body['locale'], 'en');
    expect(body['installed_at'], '2026-09-01T12:00:00.000Z');
    final sent = (body['sessions'] as List).single as Map;
    expect(sent['session_id'], s);
    expect(sent['local_day'], '2026-10-03');
    expect(sent['started_at'], isNotNull);
    expect(sent['ended_at'], isNull);
    expect(sent['runs_started'], 1);
    expect(sent['abnormal_end'], isFalse);
    final answer = (body['feedback'] as List).single as Map;
    expect(answer['feedback_id'], f);
    expect(answer['rating'], 4);
    expect(answer['trigger'], 'after_runs');
  });

  test('rows are marked uploaded on a 200 and not sent again', () async {
    final s = await addSession();
    final api = _FakeApi([]);
    final up = uploader(api);
    await up.flush();
    await up.flush();

    expect(api.bodies, hasLength(1));
    final r = await session(s);
    expect(r.dirty, isFalse);
    expect(r.uploadedAt, isNotNull);
  });

  test('a failed request leaves rows dirty for the next flush', () async {
    final s = await addSession();
    final api = _FakeApi([503, 0]);
    final up = uploader(api);
    await up.flush();
    expect((await session(s)).dirty, isTrue);
    await up.flush();
    expect((await session(s)).dirty, isTrue);
    await up.flush();
    expect((await session(s)).dirty, isFalse);
    expect(api.bodies, hasLength(3));
  });

  test('a session rewritten during the upload stays dirty', () async {
    final s = await addSession(revision: 1);
    final api = _FakeApi([]);
    api.during = () async {
      api.during = null;
      await rewrite(s, revision: 2, runsStarted: 2);
    };
    final up = uploader(api);
    await up.flush();

    final r = await session(s);
    expect(r.dirty, isTrue, reason: 'revision 2 was never sent');
    await up.flush();
    expect((await session(s)).dirty, isFalse);
    expect((api.bodies.last['sessions'] as List).single['runs_started'], 2);
  });

  test('batches respect the contract limits', () async {
    for (var i = 0; i < 120; i++) {
      await addSession(startedAt: now.add(Duration(seconds: i)));
    }
    for (var i = 0; i < 25; i++) {
      await addFeedback();
    }
    final api = _FakeApi([]);
    await uploader(api).flush();

    expect(
      [for (final b in api.bodies) (b['sessions'] as List).length],
      [50, 50, 20],
    );
    expect(
      [for (final b in api.bodies) (b['feedback'] as List).length],
      [20, 5, 0],
    );
    expect(await db.telemetryDao.dirtySessions(limit: 500), isEmpty);
  });

  test('a 400 sets the whole batch aside instead of retrying it forever',
      () async {
    final s = await addSession();
    final f = await addFeedback();
    final api = _FakeApi([400]);
    final up = uploader(api);
    await up.flush();
    await up.flush();

    expect(api.bodies, hasLength(1), reason: 'never resent');
    final r = await session(s);
    expect(r.poisoned, isTrue);
    expect(r.dirty, isFalse);
    expect(await db.telemetryDao.allFeedback(), isEmpty);
    expect(f, isNotEmpty);

    // Even a later write to the same session does not bring it back.
    await rewrite(s, revision: 9, runsStarted: 3);
    await up.flush();
    expect(api.bodies, hasLength(1));
  });

  test('a 413 splits the batch and sends the halves', () async {
    final ids = [for (var i = 0; i < 4; i++) await addSession()];
    final api = _FakeApi([413]);
    await uploader(api).flush();

    expect(api.bodies.map((b) => (b['sessions'] as List).length), [4, 2, 2]);
    expect(
      {for (final b in api.bodies.skip(1)) ...sentSessionIds(b)},
      ids.toSet(),
    );
    for (final id in ids) {
      expect((await session(id)).dirty, isFalse);
    }
  });

  test('a single row the server still finds too large is set aside',
      () async {
    final s = await addSession();
    final api = _FakeApi([413]);
    await uploader(api).flush();
    expect((await session(s)).poisoned, isTrue);
  });

  test('a 429 backs off until the next scheduled flush', () async {
    final s = await addSession();
    final api = _FakeApi([429]);
    final up = uploader(api);
    await up.flush();
    expect(api.bodies, hasLength(1));

    now = now.add(const Duration(minutes: 1));
    await up.flush();
    expect(api.bodies, hasLength(1), reason: 'still backing off');
    expect((await session(s)).dirty, isTrue);

    now = now.add(TelemetryUploader.flushInterval);
    await up.flush();
    expect(api.bodies, hasLength(2));
    expect((await session(s)).dirty, isFalse);
  });

  test('rows that would fail the server checks are set aside before sending',
      () async {
    final good = await addSession();
    final bad = await addSession(runsStarted: -1);
    final badAnswer = await addFeedback(rating: 9);
    final api = _FakeApi([]);
    await uploader(api).flush();

    expect(sentSessionIds(api.bodies.single), [good]);
    expect(api.bodies.single['feedback'], isEmpty);
    expect((await session(bad)).poisoned, isTrue);
    expect((await session(good)).dirty, isFalse);
    expect(badAnswer, isNotEmpty);
    expect(await db.telemetryDao.allFeedback(), isEmpty);
  });

  test('nothing is sent before the install identity exists', () async {
    await addSession();
    final api = _FakeApi([]);
    final up = TelemetryUploader(
      dao: db.telemetryDao,
      api: api,
      identity: () => null,
      locale: () => 'en',
      installedAt: () => null,
      clock: () => now,
    );
    await up.flush();
    expect(api.bodies, isEmpty);
  });

  test('uploaded rows older than 14 days are pruned; recent ones stay',
      () async {
    final old = await addSession();
    final oldAnswer = await addFeedback();
    final api = _FakeApi([]);
    final up = uploader(api);
    await up.flush();

    now = now.add(const Duration(days: 13));
    final recent = await addSession();
    await up.flush();
    expect(await db.telemetryDao.sessionById(old), isNotNull);

    now = now.add(const Duration(days: 2));
    await up.flush();
    expect(await db.telemetryDao.sessionById(old), isNull);
    expect(await db.telemetryDao.sessionById(recent), isNotNull);
    expect(
      [for (final f in await db.telemetryDao.allFeedback()) f.feedbackId],
      isNot(contains(oldAnswer)),
    );
  });

  test('rows that never got through are dropped after 30 days', () async {
    final stuck = await addSession();
    final api = _FakeApi([503]);
    final up = uploader(api);
    await up.flush();
    expect(await db.telemetryDao.sessionById(stuck), isNotNull);

    now = now.add(const Duration(days: 31));
    api.statuses.add(503);
    await up.flush();
    expect(await db.telemetryDao.sessionById(stuck), isNull);
  });
}
