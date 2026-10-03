import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/services/telemetry/design_feedback.dart';
import 'package:snake_classic/services/telemetry/install_identity.dart';

/// "How's the game feeling?" — shown once, after the 5th finished run AND
/// at least 2 days after install, never to someone who dismissed it twice.
void main() {
  final installedAt = DateTime(2026, 10, 1, 9);
  final dueAt = installedAt.add(DesignFeedbackPolicy.minInstallAge);

  DesignFeedbackState state({
    int runs = 5,
    bool submitted = false,
    int dismissals = 0,
    DateTime? lastDismissedAt,
  }) =>
      DesignFeedbackState(
        finishedRuns: runs,
        submitted: submitted,
        dismissals: dismissals,
        lastDismissedAt: lastDismissedAt,
      );

  group('DesignFeedbackPolicy', () {
    bool eligible(DesignFeedbackState s, DateTime now, {DateTime? installed}) =>
        DesignFeedbackPolicy.isEligible(
          s,
          installedAt: installed ?? installedAt,
          now: now,
        );

    test('needs five finished runs', () {
      expect(eligible(state(runs: 4), dueAt), isFalse);
      expect(eligible(state(runs: 5), dueAt), isTrue);
    });

    test('needs two days since install', () {
      final early = dueAt.subtract(const Duration(minutes: 1));
      expect(eligible(state(), early), isFalse);
      expect(eligible(state(), dueAt), isTrue);
    });

    test('an unknown install time waits', () {
      expect(
        DesignFeedbackPolicy.isEligible(state(), installedAt: null, now: dueAt),
        isFalse,
      );
    });

    test('never again once answered', () {
      expect(eligible(state(submitted: true), dueAt), isFalse);
    });

    test('one dismissal waits, two dismissals end it for good', () {
      final dismissed = dueAt;
      final s1 = state(dismissals: 1, lastDismissedAt: dismissed);
      expect(eligible(s1, dismissed.add(const Duration(days: 1))), isFalse);
      expect(
        eligible(s1, dismissed.add(DesignFeedbackPolicy.redisplayAfter)),
        isTrue,
      );
      final s2 = state(dismissals: 2, lastDismissedAt: dismissed);
      expect(eligible(s2, dismissed.add(const Duration(days: 365))), isFalse);
    });
  });

  group('DesignFeedbackService', () {
    late AppDatabase db;
    late DateTime now;
    late DesignFeedbackStore store;
    var flushed = 0;

    DesignFeedbackService service() => DesignFeedbackService(
          store: store,
          dao: db.telemetryDao,
          identity: () => InstallIdentity(
            installId: '8f3c1a52-1c1e-4c43-9a55-3d0b6f4d2f10',
            appVersion: '6.8.0',
            build: 60,
            platform: 'android',
            design: 'living_board',
          ),
          installedAt: () => installedAt,
          onAnswered: () async => flushed++,
          clock: () => now,
        );

    Future<void> finishRuns(int n) async {
      for (var i = 0; i < n; i++) {
        await store.recordFinishedRun();
      }
    }

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      db = AppDatabase.forTesting(NativeDatabase.memory());
      store = DesignFeedbackStore();
      now = dueAt;
      flushed = 0;
    });

    tearDown(() => db.close());

    test('offers once per process at most', () async {
      await finishRuns(5);
      final s = service();
      expect(await s.claimOffer(), isTrue);
      expect(await s.claimOffer(), isFalse);
    });

    test('is not offered before the fifth finished run', () async {
      await finishRuns(4);
      expect(await service().claimOffer(), isFalse);
      await finishRuns(1);
      expect(await service().claimOffer(), isTrue);
    });

    test('an answer is stored for upload and closes the question', () async {
      await finishRuns(5);
      final s = service();
      await s.submit(rating: 4, comment: '  smoother than before  ');

      final row = (await db.telemetryDao.dirtyFeedback(limit: 5)).single;
      expect(row.rating, 4);
      expect(row.comment, 'smoother than before');
      expect(row.trigger, 'after_runs');
      expect(row.design, 'living_board');
      expect(row.appVersion, '6.8.0');
      expect(flushed, 1, reason: 'the uploader is asked to send it now');
      expect(await service().claimOffer(), isFalse);
    });

    test('two dismissals and it never comes back', () async {
      await finishRuns(5);
      await service().dismiss();
      now = now.add(DesignFeedbackPolicy.redisplayAfter);
      final again = service();
      expect(await again.claimOffer(), isTrue);
      await again.dismiss();
      now = now.add(const Duration(days: 400));
      expect(await service().claimOffer(), isFalse);
    });

    test('comments are trimmed, emptied to null and cut to 500 code units',
        () {
      expect(DesignFeedbackService.clampComment('   '), isNull);
      expect(DesignFeedbackService.clampComment(null), isNull);
      final long = 'a' * 499 + '😀' * 3;
      final clamped = DesignFeedbackService.clampComment(long)!;
      expect(clamped.length, lessThanOrEqualTo(500));
      // The emoji straddling the limit is dropped whole, not halved.
      expect(clamped, 'a' * 499);
    });
  });
}
