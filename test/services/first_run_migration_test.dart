import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/first_run_service.dart';

/// Who counts as a new player.
///
/// `initialize()` stamps a new install whenever the install key is absent —
/// and absent is exactly what an existing player's device looks like on the
/// launch that first ships this service. They then read as gamesStarted == 0
/// and get everything meant for someone who has never seen the board: the
/// gentle opening speed, the deferred mode picker, the first-run prompt
/// queue, the later sign-in ask. The people most entitled to be left alone.
///
/// The migration asks one question the install stamp cannot: has THIS device
/// actually played? Local, durable evidence only — a restored cloud profile
/// proves someone played somewhere, not that this device ever rendered a
/// frame of gameplay.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FirstRunService service;

  Future<void> bootWith(Map<String, Object> stored) async {
    SharedPreferences.setMockInitialValues(stored);
    service = FirstRunService()..resetForTest();
    await service.initialize();
  }

  Future<bool> played() async => true;
  Future<bool> neverPlayed() async => false;
  Future<bool> databaseDown() async => throw StateError('db not ready');

  Future<int?> storedVersion() async =>
      (await SharedPreferences.getInstance()).getInt(
        'first_run_migration_version',
      );

  group('an existing player upgrading', () {
    test('is graduated out of onboarding', () async {
      // No first-run keys at all — the shape of every install that predates
      // this service — but the local database has games in it.
      await bootWith({});
      expect(service.isFirstGame, isTrue, reason: 'before the migration');

      await service.migrateExistingInstall(played);

      expect(service.gamesStarted, FirstRunService.onboardingGameCount);
      expect(service.isFirstGame, isFalse);
      expect(service.hasCompletedOnboarding, isTrue);
    });

    test('is not slowed by the first-game path afterwards', () async {
      await bootWith({});
      await service.migrateExistingInstall(played);

      expect(service.isInOnboarding, isFalse);
    });
  });

  group('a fresh install', () {
    test('still gets the new-player path', () async {
      await bootWith({});

      await service.migrateExistingInstall(neverPlayed);

      expect(service.gamesStarted, 0);
      expect(service.isFirstGame, isTrue);
      expect(service.hasCompletedOnboarding, isFalse);
    });

    test('and a reinstall does too', () async {
      // A reinstall is indistinguishable from a fresh install by design:
      // first-run state lives in device-local preferences precisely so that
      // it does not travel, and someone re-learning the controls on a new
      // device really is new to it.
      await bootWith({});

      await service.migrateExistingInstall(neverPlayed);

      expect(service.isFirstGame, isTrue);
    });
  });

  test('an old install that never played is treated as new', () async {
    // Installed months ago, opened once, never pressed Play. Nothing to
    // protect, and the gentle path is the right one for them.
    await bootWith({
      'first_run_installed_at_ms': DateTime(2025, 1, 1).millisecondsSinceEpoch,
    });

    await service.migrateExistingInstall(neverPlayed);

    expect(service.gamesStarted, 0);
    expect(service.isFirstGame, isTrue);
  });

  group('when the database cannot be read', () {
    test('nothing is decided', () async {
      await bootWith({});

      await service.migrateExistingInstall(databaseDown);

      expect(service.gamesStarted, 0);
      expect(
        await storedVersion(),
        isNull,
        reason: 'an unstamped migration can try again next launch',
      );
    });

    test('and the next launch can still classify them correctly', () async {
      // The failure mode this protects against: stamping "new player" while
      // the database was merely unavailable would bake in the exact wrong
      // answer permanently.
      await bootWith({});
      await service.migrateExistingInstall(databaseDown);

      await service.migrateExistingInstall(played);

      expect(service.gamesStarted, FirstRunService.onboardingGameCount);
    });

    test('unavailable preferences are a no-op, not a crash', () async {
      final uninitialized = FirstRunService()..resetForTest();

      await uninitialized.migrateExistingInstall(played);

      expect(uninitialized.gamesStarted, 0);
    });
  });

  group('idempotence', () {
    test('running it twice does not double-seed', () async {
      await bootWith({});

      await service.migrateExistingInstall(played);
      await service.migrateExistingInstall(played);

      expect(service.gamesStarted, FirstRunService.onboardingGameCount);
    });

    test('a second run does not consult the database at all', () async {
      await bootWith({});
      await service.migrateExistingInstall(played);

      var probed = false;
      await service.migrateExistingInstall(() async {
        probed = true;
        return true;
      });

      expect(probed, isFalse);
      expect(await storedVersion(), FirstRunService.currentMigrationVersion);
    });

    test('it never rewinds a player who is already counting games', () async {
      // Someone mid-onboarding under this service is exactly what the
      // counter says. Seeding them to three would skip the rest of their
      // first-run window; leaving them at one is correct.
      await bootWith({'first_run_games_started': 1});

      await service.migrateExistingInstall(played);

      expect(service.gamesStarted, 1);
      expect(service.isInOnboarding, isTrue);
      expect(await storedVersion(), FirstRunService.currentMigrationVersion);
    });

    test('an already-stamped install is left alone entirely', () async {
      await bootWith({
        'first_run_migration_version': FirstRunService.currentMigrationVersion,
      });

      await service.migrateExistingInstall(played);

      expect(service.gamesStarted, 0);
    });
  });

  test('recording games still works after a migration', () async {
    // The seeded value is a real count, not a sentinel, so the ordinary
    // counter keeps working on top of it.
    await bootWith({});
    await service.migrateExistingInstall(played);

    await service.recordGameStarted();

    expect(service.gamesStarted, FirstRunService.onboardingGameCount + 1);
  });
}
