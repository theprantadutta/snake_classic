import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/daos/store_dao.dart';
import 'package:snake_classic/data/database/app_database.dart';

/// `daily_bonus_state` and `power_up_inventory_state` are singletons that are
/// created lazily, on their first write, rather than seeded at startup — and
/// they were missed when the seeded singletons were pinned to `id = 1`.
///
/// `id` is `PRIMARY KEY AUTOINCREMENT`, so after a sign-out ([clearAllData]
/// deletes the row) the next lazy insert got `id = 2`. Every read is
/// `where id = 1`, so from then on the claim gate read "never claimed": the
/// daily-coins popup came back on every launch, and every claim was granted
/// again and inserted yet another row. The sync push reads `id = 1` too, so
/// the server stopped hearing about claims at all.
///
/// Real in-memory database: the bug is the interaction of AUTOINCREMENT with
/// delete-then-insert, which a fake would not reproduce.
void main() {
  late AppDatabase db;
  late StoreDao store;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    store = StoreDao(db);
    await db.initializeDefaults();
  });

  tearDown(() => db.close());

  group('daily bonus', () {
    test('a second claim the same day is refused after a sign-out', () async {
      // Claim once, sign out (wipes the row), relaunch.
      expect(await store.claimDailyBonusToday(), isA<DailyBonusClaimed>());
      await db.clearAllData();
      await db.initializeDefaults();

      // First claim on the fresh account goes through...
      expect(await store.claimDailyBonusToday(), isA<DailyBonusClaimed>());
      // ...and is visible to the gate and the sync push...
      expect((await store.getDailyBonusRow())?.lastClaimUtcMs, isNotNull);
      // ...so a relaunch the same day cannot claim again.
      await db.initializeDefaults();
      expect(
        await store.claimDailyBonusToday(),
        isA<DailyBonusAlreadyClaimedToday>(),
      );
      expect(await db.select(db.dailyBonusState).get(), hasLength(1));
    });

    test('an install already in the broken state is repaired', () async {
      // What affected devices have on disk: no id-1 row, claims at id 2+.
      await db.customStatement(
        "INSERT INTO daily_bonus_state (id, last_claim_utc_ms, current_streak, total_claims, weekly_claims_json, updated_at) "
        "VALUES (2, 1000, 1, 1, '{}', 100), (3, ${DateTime.now().toUtc().millisecondsSinceEpoch}, 1, 9, '{}', 200)",
      );
      await db.initializeDefaults();

      final rows = await db.select(db.dailyBonusState).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, 1);
      // The latest claim (today) survives, so the gate holds.
      expect(rows.single.totalClaims, 9);
      expect(
        await store.claimDailyBonusToday(),
        isA<DailyBonusAlreadyClaimedToday>(),
      );
      // And the repaired row is queued for the server, which stopped
      // receiving claims while the row was unreachable.
      final queued = await db.select(db.syncQueue).get();
      expect(queued.any((q) => q.data.contains('daily_bonus_claim:1')), isTrue);
    });
  });

  group('power-up inventory', () {
    test('survives a sign-out as one row at id 1', () async {
      await store.applyPowerUpInventorySnapshot(
        inventoryJson: jsonEncode({'speed_boost': 1}),
      );
      await db.clearAllData();
      await db.initializeDefaults();
      await store.applyPowerUpInventorySnapshot(
        inventoryJson: jsonEncode({'invincibility': 3}),
      );

      final rows = await db.select(db.powerUpInventoryState).get();
      expect(rows, hasLength(1));
      expect(rows.single.id, 1);
      expect(jsonDecode(rows.single.inventoryJson), {'invincibility': 3});
    });
  });
}
