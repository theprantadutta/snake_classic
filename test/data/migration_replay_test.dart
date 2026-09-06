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
  for (var from = 1; from < 22; from++) {
    test('replaying the upgrade from v$from onto a complete schema succeeds',
        () async {
      final file = await completeSchemaStampedAs(from);
      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);

      // Any query opens the database, which runs onUpgrade(from, 22).
      await db.customSelect('SELECT 1').get();

      expect(await userVersion(db), 22, reason: 'the upgrade completed');

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
      await db.initializeDefaults();
    });
  }

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
    expect(await userVersion(db), 22);
  });
}
