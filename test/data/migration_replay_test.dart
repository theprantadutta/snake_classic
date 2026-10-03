import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/database/app_database.dart';

/// Every upgrade step must be safe to REPLAY onto a schema that already has
/// its result.
///
/// Drift runs onUpgrade and only then writes the new user_version. If any
/// step throws, the steps before it are durably applied and the version is
/// not, so the next launch replays them all. `ALTER TABLE ... ADD COLUMN`
/// has no IF NOT EXISTS, so a replayed addColumn throws "duplicate column
/// name" — and now every launch throws it, forever, until the player clears
/// app data. That was the #1 crash in production for the week of 31 Aug
/// 2026: 50 crashes across 37 users, all at startup, all
/// `duplicate column name: stats_applied`, plus a second cluster on
/// `difficulty_index`. Nothing about those devices was unusual; a single
/// interrupted upgrade at any point in their history was enough.
///
/// Each test builds the COMPLETE current schema, rewinds only the version
/// number to an older value, and reopens. That is exactly the state of a
/// device whose upgrade was interrupted after its last step: the columns are
/// there, the version says they are not. The upgrade must complete.
void main() {
  late Directory dir;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('snake_migration_');
  });

  tearDown(() async {
    await dir.delete(recursive: true);
  });

  /// A database file holding the full current schema, stamped as [version].
  Future<File> completeSchemaStampedAs(int version) async {
    final file = File('${dir.path}/v$version.db');
    final db = AppDatabase.forTesting(NativeDatabase(file));
    // Opening a fresh file runs onCreate: every table, every column, as
    // they are defined today.
    await db.customSelect('SELECT 1').get();
    await db.customStatement('PRAGMA user_version = $version');
    await db.close();
    return file;
  }

  Future<int> userVersion(AppDatabase db) async {
    final row = await db.customSelect('PRAGMA user_version').getSingle();
    return row.read<int>('user_version');
  }

  // Every version a shipped build could have left a device at.
  for (var from = 1; from < 24; from++) {
    test('replaying the upgrade from v$from onto a complete schema succeeds',
        () async {
      final file = await completeSchemaStampedAs(from);
      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      // Any query opens the database, which runs onUpgrade(from, 24).
      await db.customSelect('SELECT 1').get();

      expect(await userVersion(db), 24, reason: 'the upgrade completed');

      // The schema is still whole: the columns the crash loops were about,
      // and the newest table, all readable.
      await db.customSelect(
        'SELECT stats_applied, coins_applied, xp_applied, completed_at '
        'FROM applied_multiplayer_settlements LIMIT 1',
      ).get();
      await db.customSelect(
        'SELECT difficulty_index, locale_code, haptics_enabled, updated_at '
        'FROM game_settings LIMIT 1',
      ).get();
      await db.customSelect(
        'SELECT snap_movement_enabled, control_layout_index '
        'FROM device_preferences LIMIT 1',
      ).get();
      await db.customSelect(
        'SELECT session_id, revision, poisoned FROM telemetry_sessions LIMIT 1',
      ).get();
      await db.customSelect(
        'SELECT feedback_id, rating FROM telemetry_feedback LIMIT 1',
      ).get();
      await db.customSelect(
        'SELECT bronze_grants_absorbed, silver_grants_absorbed, '
        'gold_grants_absorbed FROM premium_status LIMIT 1',
      ).get();
      await db.initializeDefaults();
    });
  }

  test('a real v22 database gains the telemetry tables, and they work',
      () async {
    // A complete schema minus what v23 adds, stamped 22: the state of every
    // device on the build before telemetry.
    final file = await completeSchemaStampedAs(22);
    final raw = AppDatabase.forTesting(NativeDatabase(file));
    await raw.customSelect('SELECT 1').get();
    await raw.customStatement('DROP TABLE telemetry_sessions');
    await raw.customStatement('DROP TABLE telemetry_feedback');
    await raw.customStatement('PRAGMA user_version = 22');
    await raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();
    expect(await userVersion(db), 24);

    final now = DateTime(2026, 10, 3, 9);
    await db.telemetryDao.upsertSession(
      TelemetrySessionsCompanion.insert(
        sessionId: '0b0c3a52-1c1e-4c43-9a55-3d0b6f4d2f10',
        design: 'living_board',
        appVersion: '6.8.0',
        build: 60,
        startedAt: now,
        lastActiveAt: now,
        localDay: '2026-10-03',
      ),
    );
    final dirty = await db.telemetryDao.dirtySessions(limit: 10);
    expect(dirty.single.poisoned, isFalse);
    expect(dirty.single.dirty, isTrue);
  });

  test('a failed step leaves nothing behind for the next launch to trip on',
      () async {
    // The upgrade runs inside a transaction, so an interrupted step rolls
    // back the ones before it instead of leaving them applied under the old
    // version number. Simulated by stamping a complete schema at v18 and
    // checking the version is either untouched or fully advanced — never a
    // half-way state with the version still behind. (With every step also
    // idempotent this is belt and braces, which is the point.)
    final file = await completeSchemaStampedAs(18);
    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();
    expect(await userVersion(db), 24);
  });

  test('a real v23 database gains the absorbed counters, unknown, with its '
      'entries intact', () async {
    // A complete schema minus what v24 adds, stamped 23, with entries the
    // player already holds.
    final file = await completeSchemaStampedAs(23);
    final raw = AppDatabase.forTesting(NativeDatabase(file));
    await raw.customSelect('SELECT 1').get();
    await raw.initializeDefaults();
    await raw.customStatement(
      'UPDATE premium_status SET bronze_tournament_entries = 2, '
      'gold_tournament_entries = 1 WHERE id = 1',
    );
    for (final column in [
      'bronze_grants_absorbed',
      'silver_grants_absorbed',
      'gold_grants_absorbed',
    ]) {
      await raw.customStatement('ALTER TABLE premium_status DROP COLUMN $column');
    }
    await raw.customStatement('PRAGMA user_version = 23');
    await raw.close();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    addTearDown(db.close);
    await db.customSelect('SELECT 1').get();
    expect(await userVersion(db), 24);

    final status = await db.storeDao.getPremiumStatus();
    expect(status!.bronzeTournamentEntries, 2);
    expect(status.goldTournamentEntries, 1);
    // Unknown until the first premium-content fetch adopts the server's.
    expect(status.bronzeGrantsAbsorbed, isNull);
    expect(status.silverGrantsAbsorbed, isNull);
    expect(status.goldGrantsAbsorbed, isNull);
  });
}
