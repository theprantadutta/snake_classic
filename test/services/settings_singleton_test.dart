import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/daos/settings_dao.dart';
import 'package:snake_classic/data/database/app_database.dart';

/// `game_settings` is a SINGLETON table, and the whole app depends on that:
/// [SettingsDao.watchSettings] uses `watchSingleOrNull`, which THROWS rather
/// than returning a row when the table holds more than one.
///
/// It stopped being a singleton in production. `id` is
/// `PRIMARY KEY AUTOINCREMENT`, so SQLite never reuses an id after a delete —
/// but two writers hardcode `id = 1` while three others insert with no id at
/// all. Once those disagree the table grows a second row, and the next launch
/// dies in ThemeCubit.initialize with
/// `Bad state: Expected exactly one element, but got 2` before any UI renders.
///
/// These run against a REAL in-memory database because the bug lives in the
/// interaction between AUTOINCREMENT, delete-then-insert, and an upsert keyed
/// on a literal 1 — none of which a fake reproduces.
void main() {
  late AppDatabase db;
  late SettingsDao dao;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = SettingsDao(db);
  });

  tearDown(() => db.close());

  Future<int> settingsRowCount() async =>
      (await db.select(db.gameSettings).get()).length;

  group('game_settings stays a singleton', () {
    test('a fresh install seeds exactly one row, at id 1', () async {
      await db.initializeDefaults();

      final rows = await db.select(db.gameSettings).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, 1);
    });

    test('logout then cloud restore does not leave two rows', () async {
      // The production crash path, in order.
      await db.initializeDefaults();
      await db.clearAllData(); // signs out — deletes the settings row
      await db.initializeDefaults(); // re-seeds on next launch
      // First sign-in restore applies the cloud snapshot, keyed on id 1.
      await dao.applySettingsSnapshot(
        const GameSettingsCompanion(themeIndex: Value(3)),
      );

      expect(await settingsRowCount(), 1);
      await expectLater(dao.watchSettings().first, completes);
    });

    test('resetting settings does not leave two rows', () async {
      await db.initializeDefaults();
      await dao.resetSettings();
      await dao.applySettingsSnapshot(
        const GameSettingsCompanion(themeIndex: Value(2)),
      );

      expect(await settingsRowCount(), 1);
      await expectLater(dao.watchSettings().first, completes);
    });

    test('writes still land after a reset', () async {
      // The silent half of the same bug: _writeSettings updates
      // `where id = 1`, so once the row is re-created at id 2 every settings
      // change writes zero rows and is lost without an error.
      await db.initializeDefaults();
      await dao.resetSettings();
      await dao.updateTheme(4);

      final settings = await dao.getSettings();
      expect(settings?.themeIndex, 4);
    });

    test('a database already holding duplicates is repaired, keeping the '
        'newest row', () async {
      // Installs that already crashed are in this state on disk. They have to
      // heal on launch — a fix that only prevents new duplicates leaves every
      // affected player stuck on a crash loop they cannot clear.
      await db.into(db.gameSettings).insert(
            GameSettingsCompanion.insert(
              themeIndex: const Value(1),
              lastUpdated: Value(DateTime(2026, 1, 1)),
            ),
          );
      await db.into(db.gameSettings).insert(
            GameSettingsCompanion.insert(
              themeIndex: const Value(7),
              lastUpdated: Value(DateTime(2026, 6, 1)),
            ),
          );
      expect(await settingsRowCount(), 2);

      await db.initializeDefaults();

      final rows = await db.select(db.gameSettings).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, 1);
      expect(rows.single.themeIndex, 7, reason: 'newest row wins');
      await expectLater(dao.watchSettings().first, completes);
    });
  });

  group('the other id-1 singletons survive a logout', () {
    // game_settings crashed first only because ThemeCubit initializes earliest.
    // coins, statistics, premium_status and player_progress share the same
    // `where id = 1` convention and the same clearAllData/re-seed cycle, so
    // they were landing on id 2 too — reading as empty and swallowing writes.
    test('every singleton is still at id 1 after clearAllData', () async {
      await db.initializeDefaults();
      await db.clearAllData();
      await db.initializeDefaults();

      Future<void> expectSingleAtId1(String label, List<int> ids) async {
        expect(ids, [1], reason: '$label should hold exactly one row, at id 1');
      }

      await expectSingleAtId1(
        'game_settings',
        (await db.select(db.gameSettings).get()).map((r) => r.id).toList(),
      );
      await expectSingleAtId1(
        'coins',
        (await db.select(db.coins).get()).map((r) => r.id).toList(),
      );
      await expectSingleAtId1(
        'statistics',
        (await db.select(db.statistics).get()).map((r) => r.id).toList(),
      );
      await expectSingleAtId1(
        'premium_status',
        (await db.select(db.premiumStatus).get()).map((r) => r.id).toList(),
      );
      await expectSingleAtId1(
        'player_progress_table',
        (await db.select(db.playerProgressTable).get())
            .map((r) => r.id)
            .toList(),
      );
      await expectSingleAtId1(
        'device_preferences',
        (await db.select(db.devicePreferences).get()).map((r) => r.id).toList(),
      );
    });
  });
}
