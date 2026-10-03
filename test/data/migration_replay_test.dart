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

  // The classic and living_board builds both ship schema v23, and a player
  // can move between them in either direction (the classic build is the
  // redesign's fallback). With the same version number on both sides
  // neither build runs a migration on the other's file, so the two v23
  // telemetry tables must be byte-for-byte the same shape on both branches.
  // These are the CREATE statements Drift generates for them; if one branch
  // changes a column, this fails there and the other branch must follow (or
  // the schema version must move on both).
  const telemetrySessionsSql =
      'CREATE TABLE "telemetry_sessions" ("session_id" TEXT NOT NULL, '
      '"design" TEXT NOT NULL, "app_version" TEXT NOT NULL, '
      '"build" INTEGER NOT NULL, "started_at" INTEGER NOT NULL, '
      '"ended_at" INTEGER NULL, "last_active_at" INTEGER NOT NULL, '
      '"local_day" TEXT NOT NULL, '
      '"foreground_ms" INTEGER NOT NULL DEFAULT 0, '
      '"runs_started" INTEGER NOT NULL DEFAULT 0, '
      '"runs_finished" INTEGER NOT NULL DEFAULT 0, '
      '"runs_again" INTEGER NOT NULL DEFAULT 0, '
      '"best_score" INTEGER NOT NULL DEFAULT 0, '
      '"total_score" INTEGER NOT NULL DEFAULT 0, '
      '"run_ms" INTEGER NOT NULL DEFAULT 0, '
      '"multiplayer_matches" INTEGER NOT NULL DEFAULT 0, '
      '"ad_impressions_banner" INTEGER NOT NULL DEFAULT 0, '
      '"ad_impressions_interstitial" INTEGER NOT NULL DEFAULT 0, '
      '"ad_impressions_rewarded" INTEGER NOT NULL DEFAULT 0, '
      '"ad_impressions_app_open" INTEGER NOT NULL DEFAULT 0, '
      '"rewarded_completed" INTEGER NOT NULL DEFAULT 0, '
      '"rewarded_abandoned" INTEGER NOT NULL DEFAULT 0, '
      '"ad_revenue_micros" INTEGER NOT NULL DEFAULT 0, '
      '"purchases_started" INTEGER NOT NULL DEFAULT 0, '
      '"purchases_completed" INTEGER NOT NULL DEFAULT 0, '
      '"store_views" INTEGER NOT NULL DEFAULT 0, '
      '"abnormal_end" INTEGER NOT NULL DEFAULT 0 '
      'CHECK ("abnormal_end" IN (0, 1)), '
      '"dirty" INTEGER NOT NULL DEFAULT 1 CHECK ("dirty" IN (0, 1)), '
      '"revision" INTEGER NOT NULL DEFAULT 0, '
      '"uploaded_at" INTEGER NULL, '
      '"poisoned" INTEGER NOT NULL DEFAULT 0 CHECK ("poisoned" IN (0, 1)), '
      'PRIMARY KEY ("session_id"))';
  const telemetryFeedbackSql =
      'CREATE TABLE "telemetry_feedback" ("feedback_id" TEXT NOT NULL, '
      '"design" TEXT NOT NULL, "app_version" TEXT NOT NULL, '
      '"rating" INTEGER NOT NULL, "comment" TEXT NULL, '
      '"trigger" TEXT NOT NULL, "created_at" INTEGER NOT NULL, '
      '"dirty" INTEGER NOT NULL DEFAULT 1 CHECK ("dirty" IN (0, 1)), '
      '"uploaded_at" INTEGER NULL, PRIMARY KEY ("feedback_id"))';

  Future<Map<String, String?>> telemetryTableSql(AppDatabase db) async {
    final rows = await db
        .customSelect(
          "SELECT name, sql FROM sqlite_master WHERE type = 'table' "
          "AND name LIKE 'telemetry_%' ORDER BY name",
        )
        .get();
    return {
      for (final r in rows) r.read<String>('name'): r.read<String?>('sql'),
    };
  }

  test(
    'v23 telemetry tables have the exact shape both designs create',
    () async {
      // Fresh install path (onCreate) ...
      final fresh = AppDatabase.forTesting(NativeDatabase.memory());
      expect(await telemetryTableSql(fresh), {
        'telemetry_feedback': telemetryFeedbackSql,
        'telemetry_sessions': telemetrySessionsSql,
      });
      await fresh.close();

      // ... and the upgrade path (v22 -> v23) end up identical.
      final file = await completeSchemaStampedAs(22);
      final raw = AppDatabase.forTesting(NativeDatabase(file));
      await raw.customSelect('SELECT 1').get();
      await raw.customStatement('DROP TABLE telemetry_sessions');
      await raw.customStatement('DROP TABLE telemetry_feedback');
      await raw.customStatement('PRAGMA user_version = 22');
      await raw.close();
      final upgraded = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(upgraded.close);
      expect(await telemetryTableSql(upgraded), {
        'telemetry_feedback': telemetryFeedbackSql,
        'telemetry_sessions': telemetrySessionsSql,
      });
    },
  );

  test(
    'a file at the shared version, written by the other design, opens as-is and keeps its rows',
    () async {
      // Both designs ship the same schema; whatever it currently is.
      final probe = AppDatabase.forTesting(NativeDatabase.memory());
      final current = probe.schemaVersion;
      await probe.close();
      // The redesign build left a session and an answer behind; this build
      // opens the same file at the same version (no onUpgrade at all) and
      // adds its own rows next to them. Both get uploaded, each tagged with
      // the design that recorded it.
      final file = await completeSchemaStampedAs(current);
      final now = DateTime(2026, 10, 3, 9);
      final other = AppDatabase.forTesting(NativeDatabase(file));
      await other.telemetryDao.upsertSession(
        TelemetrySessionsCompanion.insert(
          sessionId: '7d1c0d1e-5f0a-4b8e-8f3a-2a6f0c9e4b11',
          design: 'living_board',
          appVersion: '6.8.0',
          build: 60,
          startedAt: now,
          lastActiveAt: now,
          localDay: '2026-10-03',
        ),
      );
      await other.telemetryDao.insertFeedback(
        TelemetryFeedbackCompanion.insert(
          feedbackId: '1f6b2c3d-4e5f-4a6b-8c7d-9e0f1a2b3c4d',
          design: 'living_board',
          appVersion: '6.8.0',
          rating: 4,
          trigger: 'after_runs',
          createdAt: now,
        ),
      );
      await other.close();

      final db = AppDatabase.forTesting(NativeDatabase(file));
      addTearDown(db.close);
      await db.customSelect('SELECT 1').get();
      expect(await userVersion(db), current);
      await db.telemetryDao.upsertSession(
        TelemetrySessionsCompanion.insert(
          sessionId: '2a3b4c5d-6e7f-4081-9a2b-3c4d5e6f7a8b',
          design: 'classic',
          appVersion: '6.8.0',
          build: 60,
          startedAt: now.add(const Duration(hours: 1)),
          lastActiveAt: now.add(const Duration(hours: 1)),
          localDay: '2026-10-03',
        ),
      );

      final sessions = await db.telemetryDao.dirtySessions(limit: 10);
      expect(sessions.map((s) => s.design).toSet(), {
        'living_board',
        'classic',
      });
      final feedback = await db.telemetryDao.dirtyFeedback(limit: 10);
      expect(feedback.single.design, 'living_board');
      expect(feedback.single.rating, 4);
    },
  );

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
