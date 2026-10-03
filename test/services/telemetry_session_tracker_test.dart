import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/telemetry/design_feedback.dart';
import 'package:snake_classic/services/telemetry/install_identity.dart';
import 'package:snake_classic/services/telemetry/telemetry_analytics_client.dart';
import 'package:snake_classic/services/telemetry/telemetry_session_tracker.dart';

/// The session rules of docs/design-metrics/CONTRACT.md, driven through the
/// same analytics calls the app makes, against a real in-memory database.
void main() {
  late AppDatabase db;
  late DateTime now;
  final identity = InstallIdentity(
    installId: '8f3c1a52-1c1e-4c43-9a55-3d0b6f4d2f10',
    appVersion: '6.8.0',
    build: 60,
    platform: 'android',
    design: 'living_board',
  );

  DateTime clock() => now;
  void advance(Duration d) => now = now.add(d);

  TelemetrySessionTracker newTracker() => TelemetrySessionTracker(
        dao: db.telemetryDao,
        identity: identity,
        clock: clock,
      );

  Future<TelemetrySession> row(TelemetrySessionTracker t) async {
    await t.persistNow();
    return (await db.telemetryDao.sessionById(t.sessionId))!;
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // Mid-morning, so a local-day boundary cannot sneak into any test.
    now = DateTime(2026, 10, 3, 9, 12);
  });

  tearDown(() => db.close());

  group('session lifecycle', () {
    test('a cold start opens a session stamped with the build and local day',
        () async {
      final t = newTracker();
      await t.start();
      advance(const Duration(minutes: 3));
      final r = await row(t);

      expect(r.design, 'living_board');
      expect(r.appVersion, '6.8.0');
      expect(r.build, 60);
      expect(r.localDay, '2026-10-03');
      expect(r.endedAt, isNull);
      expect(r.foregroundMs, 3 * 60 * 1000);
      expect(r.dirty, isTrue);
      t.dispose();
    });

    test('a background trip under 30 minutes continues the same session, '
        'and foreground_ms leaves the time away out', () async {
      final t = newTracker();
      await t.start();
      final id = t.sessionId;

      advance(const Duration(minutes: 2));
      t.backgrounded();
      var r = await row(t);
      expect(r.endedAt, isNotNull, reason: 'the end is recorded on background');

      advance(const Duration(minutes: 29, seconds: 59));
      t.foregrounded();
      advance(const Duration(minutes: 1));
      r = await row(t);

      expect(t.sessionId, id);
      expect(r.endedAt, isNull, reason: 'the session is open again');
      expect(r.foregroundMs, 3 * 60 * 1000);
      t.dispose();
    });

    test('30 minutes or more in the background starts a new session',
        () async {
      final t = newTracker();
      await t.start();
      final first = t.sessionId;
      t.storeViewed();

      advance(const Duration(minutes: 1));
      t.backgrounded();
      advance(TelemetrySessionTracker.backgroundTimeout);
      t.foregrounded();
      final r = await row(t);

      expect(t.sessionId, isNot(first));
      expect(r.storeViews, 0, reason: 'counters start over');
      final old = (await db.telemetryDao.sessionById(first))!;
      expect(old.endedAt, isNotNull);
      expect(old.abnormalEnd, isFalse);
      expect(old.storeViews, 1);
      t.dispose();
    });

    test('a session the process never ended is closed as abnormal on the '
        'next launch, ending at its last write', () async {
      final crashed = newTracker();
      await crashed.start();
      advance(const Duration(minutes: 4));
      await crashed.persistNow();
      final lastWrite = now;
      final crashedId = crashed.sessionId;
      crashed.dispose(); // killed: no background, no end

      advance(const Duration(hours: 2));
      final next = newTracker();
      await next.start();

      final old = (await db.telemetryDao.sessionById(crashedId))!;
      expect(old.abnormalEnd, isTrue);
      expect(
        old.endedAt!.millisecondsSinceEpoch ~/ 1000,
        lastWrite.millisecondsSinceEpoch ~/ 1000,
      );
      expect(old.dirty, isTrue, reason: 'the server must hear about it');
      expect((await row(next)).abnormalEnd, isFalse);
      next.dispose();
    });

    test('a process killed in the background is a normal end', () async {
      final first = newTracker();
      await first.start();
      advance(const Duration(minutes: 1));
      first.backgrounded();
      await first.persistNow();
      final firstId = first.sessionId;
      first.dispose();

      advance(const Duration(minutes: 5));
      final next = newTracker();
      await next.start();

      final old = (await db.telemetryDao.sessionById(firstId))!;
      expect(old.abnormalEnd, isFalse);
      expect(next.sessionId, isNot(firstId), reason: 'a cold start is new');
      next.dispose();
    });
  });

  group('runs and the again rule', () {
    test('a run started within 60 s of a game over counts as again', () async {
      final t = newTracker();
      await t.start();

      t.runStarted();
      advance(const Duration(seconds: 40));
      t.runFinished(score: 120, durationSeconds: 40);
      advance(const Duration(seconds: 60));
      t.runStarted();
      advance(const Duration(seconds: 10));
      t.runFinished(score: 30, durationSeconds: 10);
      advance(const Duration(seconds: 61));
      t.runStarted();

      final r = await row(t);
      expect(r.runsStarted, 3);
      expect(r.runsFinished, 2);
      expect(r.runsAgain, 1, reason: '60 s counts, 61 s does not');
      expect(r.bestScore, 120);
      expect(r.totalScore, 150);
      expect(r.runMs, 50 * 1000);
      t.dispose();
    });

    test('a game over reported late (the continue window) is timed from the '
        'run clock, not from when the report arrived', () async {
      final t = newTracker();
      await t.start();

      t.runStarted();
      // The snake dies 20 s in; finalization reports it 8 s later, when the
      // continue offer closes.
      advance(const Duration(seconds: 28));
      t.runFinished(score: 50, durationSeconds: 20);
      // 65 s after the real game over, 57 s after the report.
      advance(const Duration(seconds: 57));
      t.runStarted();

      var r = await row(t);
      expect(r.runsAgain, 0);
      expect(r.runMs, 20 * 1000);

      // AGAIN pressed inside the window: the report arrives at that moment.
      advance(const Duration(seconds: 15));
      t.runFinished(score: 10, durationSeconds: 15);
      t.runStarted();
      r = await row(t);
      expect(r.runsAgain, 1);
      t.dispose();
    });

    test('paused time is neither play time nor part of the again gap',
        () async {
      final t = newTracker();
      await t.start();

      t.runStarted();
      advance(const Duration(seconds: 10));
      t.runPaused();
      advance(const Duration(minutes: 5));
      t.runResumed();
      advance(const Duration(seconds: 10));
      t.runFinished(score: 5, durationSeconds: 20);

      final r = await row(t);
      expect(r.runMs, 20 * 1000);
      t.dispose();
    });

    test('the again rule does not cross a session boundary', () async {
      final t = newTracker();
      await t.start();

      t.runStarted();
      advance(const Duration(seconds: 30));
      t.runFinished(score: 5, durationSeconds: 30);
      t.backgrounded();
      advance(const Duration(minutes: 31));
      t.foregrounded();
      t.runStarted();

      final r = await row(t);
      expect(r.runsStarted, 1);
      expect(r.runsAgain, 0);
      t.dispose();
    });
  });

  group('analytics client', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('the facade feeds every contract counter from the existing events',
        () async {
      final t = newTracker();
      await t.start();
      final store = DesignFeedbackStore();
      final analytics = AnalyticsFacade([
        TelemetryAnalyticsClient(tracker: t, feedbackStore: store),
      ]);

      await analytics.trackScreenView('store');
      await analytics.trackScreenView('home');
      await analytics.trackGameStarted(
        boardWidth: 20,
        boardHeight: 20,
        gameMode: 'classic',
        controlScheme: 'swipe',
      );
      advance(const Duration(seconds: 12));
      await analytics.trackGameOver(
        score: 42,
        level: 2,
        durationSeconds: 12,
        cause: 'wall',
        foodEaten: 4,
        powerUpsCollected: 0,
        maxCombo: 1,
        isNewHighScore: true,
        inputsAccepted: 10,
        inputsRejected: 0,
      );
      await analytics.trackMultiplayerGameEnded(score: 3, result: 'win');
      for (final f in [
        'banner',
        'banner',
        'interstitial',
        'rewarded',
        'rewarded_interstitial',
        'app_open',
      ]) {
        await analytics.trackAdImpression(format: f);
      }
      await analytics.trackRewardedCompleted('revive');
      await analytics.trackRewardedAbandoned('revive');
      await analytics.trackAdRevenue(
        format: 'banner',
        valueMicros: 1070.4,
        currencyCode: 'USD',
        precision: 'estimated',
      );
      await analytics.trackPurchaseInitiated(
        productId: 'coins_small',
        productType: 'consumable',
      );
      await analytics.trackItemPurchased(
        itemId: 'coins_small',
        itemType: 'consumable',
        price: r'$0.99',
      );

      final r = await row(t);
      expect(r.storeViews, 1);
      expect(r.runsStarted, 1);
      expect(r.runsFinished, 1);
      expect(r.bestScore, 42);
      expect(r.runMs, 12000);
      expect(r.multiplayerMatches, 1);
      expect(r.adImpressionsBanner, 2);
      expect(r.adImpressionsInterstitial, 1);
      expect(r.adImpressionsRewarded, 2);
      expect(r.adImpressionsAppOpen, 1);
      expect(r.rewardedCompleted, 1);
      expect(r.rewardedAbandoned, 1);
      expect(r.adRevenueMicros, 1070);
      expect(r.purchasesStarted, 1);
      expect(r.purchasesCompleted, 1);
      expect((await store.read()).finishedRuns, 1);
      t.dispose();
    });
  });
}
