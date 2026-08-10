import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/data/database/settlement_write.dart';
import 'package:snake_classic/models/game_statistics.dart';
import 'package:snake_classic/models/player_level.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_state.dart'
    show BattlePassTiers;
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/services/multiplayer/settlement_ledger.dart';

/// The settlement write against a REAL database.
///
/// Every earlier version of these tests ran on hand-written fakes, which meant
/// they could only prove that the code did what the fake was written to allow.
/// Two bugs got through that way: a reward landing before its record committed
/// (the fake had no transaction), and an unawaited level-up coin grant that no
/// fake modelled at all. This runs the actual schema, the actual DAO writes and
/// the actual transaction, and forces each of them to fail.
///
/// The assertion throughout is the same one: across a failure and a restart,
/// every reward is credited exactly once — statistics, coins, battle-pass XP,
/// lifetime XP, and the coins a level-up pays.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    // The coins row is a singleton the DAO expects to exist.
    await db.into(db.coins).insert(
          CoinsCompanion.insert(
            balance: const Value(0),
            totalEarned: const Value(0),
          ),
          mode: InsertMode.insertOrIgnore,
        );
    await db.into(db.battlePasses).insert(
          BattlePassesCompanion.insert(
            seasonId: 'season-1',
            currentTier: const Value(0),
            currentXp: const Value(0),
            xpForNextTier: Value(BattlePassTiers.xpRequiredForTier(0)),
          ),
        );
  });

  tearDown(() async => db.close());

  // ---- helpers ------------------------------------------------------------

  Future<SettlementWriteResult> apply({
    String id = 's1',
    int coins = 25,
    int xp = 20,
  }) {
    return db.applyMultiplayerSettlementOnce(
      settlementId: id,
      coinsAwarded: coins,
      battlePassXpAwarded: xp,
      score: 120,
      foodsEaten: 12,
      durationSeconds: 95,
      survivedToEnd: true,
      deathReason: null,
      won: true,
    );
  }

  Future<int> coinBalance() async =>
      (await (db.select(db.coins)..where((t) => t.id.equals(1))).getSingle())
          .balance;

  Future<int> coinTransactionCount([String? source]) async {
    final rows = await db.select(db.coinTransactions).get();
    return source == null
        ? rows.length
        : rows.where((r) => r.source == source).length;
  }

  Future<GameStatistics> stats() async {
    final row = await db.gameDao.getStatistics();
    if (row?.modelJson == null) return const GameStatistics();
    return GameStatistics.fromJson(
        jsonDecode(row!.modelJson) as Map<String, dynamic>);
  }

  Future<int> battlePassXp() async =>
      (await db.storeDao.getCurrentBattlePass())!.currentXp;

  Future<int> lifetimeXp() async =>
      (await db.gameDao.getPlayerProgress())?.totalXp ?? 0;

  Future<int> lifetimeLevel() async =>
      (await db.gameDao.getPlayerProgress())?.level ??
      PlayerLevel.levelForXp(0);

  /// Make every INSERT and UPDATE on [table] abort, leaving SELECT working.
  Future<void> breakWrites(String table) async {
    for (final op in ['INSERT', 'UPDATE']) {
      await db.customStatement(
        "CREATE TRIGGER break_${table}_$op BEFORE $op ON $table "
        "BEGIN SELECT RAISE(ABORT, 'forced write failure'); END",
      );
    }
  }

  Future<void> unbreakWrites(String table) async {
    for (final op in ['INSERT', 'UPDATE']) {
      await db.customStatement('DROP TRIGGER IF EXISTS break_${table}_$op');
    }
  }

  // ---- the happy path -----------------------------------------------------

  group('applying a settlement', () {
    test('credits every reward exactly once', () async {
      final result = await apply();

      expect(result.applied, isTrue);
      expect(await coinBalance(), 25);
      expect(await battlePassXp(), 20);
      expect(await lifetimeXp(), 20);
      expect((await stats()).totalGamesPlayed, 1);
      expect(await db.isSettlementApplied('s1'), isTrue);
    });

    test('a second attempt writes nothing at all', () async {
      await apply();
      final second = await apply();

      expect(second.applied, isFalse);
      expect(await coinBalance(), 25);
      expect(await battlePassXp(), 20);
      expect(await lifetimeXp(), 20);
      expect((await stats()).totalGamesPlayed, 1);
      expect(await coinTransactionCount(), 1);
    });

    test('ten attempts still credit once', () async {
      for (var i = 0; i < 10; i++) {
        await apply();
      }

      expect(await coinBalance(), 25);
      expect(await lifetimeXp(), 20);
      expect((await stats()).totalGamesPlayed, 1);
    });
  });

  // ---- level-up rewards ---------------------------------------------------

  group('level-up coins', () {
    test('are paid inside the same transaction as the XP', () async {
      // Enough XP to cross at least one lifetime level.
      final xpForLevel2 = PlayerLevel.costForLevel(1) + 1;

      final result = await apply(id: 'lvl', xp: xpForLevel2, coins: 0);

      expect(result.leveledUp, isTrue);
      expect(result.levelUpCoins, greaterThan(0));
      expect(await lifetimeLevel(), greaterThan(1));
      expect(await coinBalance(), result.levelUpCoins);
      expect(await coinTransactionCount('levelUp'), 1);
    });

    test('are NOT paid a second time when the settlement is replayed',
        () async {
      // The bug this closes: ProgressionService fired the level-up grant with
      // `unawaited`, outside any transaction and with no record, so replaying
      // the settlement minted the coins again.
      final xpForLevel2 = PlayerLevel.costForLevel(1) + 1;

      final first = await apply(id: 'lvl', xp: xpForLevel2, coins: 0);
      final balanceAfterFirst = await coinBalance();

      await apply(id: 'lvl', xp: xpForLevel2, coins: 0);
      await apply(id: 'lvl', xp: xpForLevel2, coins: 0);

      expect(await coinBalance(), balanceAfterFirst);
      expect(await coinTransactionCount('levelUp'), 1);
      expect(await lifetimeLevel(), first.levelAfter);
    });
  });

  // ---- forced failures ----------------------------------------------------

  group('a write fails part-way through', () {
    /// Break one table's WRITES and prove the whole transaction rolled back.
    ///
    /// Triggers rather than renaming the table: a rename breaks reads too, and
    /// a failing read masks the thing actually under test. Every one of these
    /// paths reads before it writes, so with a rename the transaction aborts on
    /// the SELECT and a swallowed write error would never be reached. This
    /// fails exactly the write, which is what the real bug looked like —
    /// StatisticsService, BattlePassCubit and ProgressionService each caught
    /// their own persistence failure and returned as if it had worked.
    Future<void> expectRollbackWhenBroken(String table) async {
      final coinsBefore = await coinBalance();
      final xpBefore = await lifetimeXp();
      final bpBefore = await battlePassXp();
      final gamesBefore = (await stats()).totalGamesPlayed;

      await breakWrites(table);
      await expectLater(apply(), throwsA(isA<Object>()));
      await unbreakWrites(table);

      expect(await coinBalance(), coinsBefore, reason: '$table: coins moved');
      expect(await lifetimeXp(), xpBefore, reason: '$table: lifetime XP moved');
      expect(await battlePassXp(), bpBefore, reason: '$table: bp XP moved');
      expect((await stats()).totalGamesPlayed, gamesBefore,
          reason: '$table: stats moved');
      expect(await db.isSettlementApplied('s1'), isFalse,
          reason: '$table: marked applied despite rolling back');
    }

    for (final table in [
      'statistics',
      'coins',
      'coin_transactions',
      'battle_passes',
      'player_progress_table',
      'applied_multiplayer_settlements',
    ]) {
      test('$table failing rolls the whole settlement back', () async {
        await expectRollbackWhenBroken(table);
      });
    }

    test('after a rollback, the retry credits everything exactly once',
        () async {
      await breakWrites('coins');
      await expectLater(apply(), throwsA(isA<Object>()));
      await unbreakWrites('coins');

      // "Restart": a fresh writer over the same database.
      final writer = DriftSettlementWriter(db);
      final done = await writer.applyOnce(_settlement());

      expect(done, isTrue);
      expect(await coinBalance(), 25);
      expect(await battlePassXp(), 20);
      expect(await lifetimeXp(), 20);
      expect((await stats()).totalGamesPlayed, 1);
      expect(await coinTransactionCount(), 1);
    });

    test(
      'a failure during a level-up settlement leaves no level-up coins behind',
      () async {
        final xpForLevel2 = PlayerLevel.costForLevel(1) + 1;

        await breakWrites('applied_multiplayer_settlements');
        await expectLater(
          apply(id: 'lvl', xp: xpForLevel2, coins: 0),
          throwsA(isA<Object>()),
        );
        await unbreakWrites('applied_multiplayer_settlements');

        expect(await coinBalance(), 0,
            reason: 'the level-up grant must have rolled back with the rest');
        expect(await coinTransactionCount('levelUp'), 0);
        expect(await lifetimeLevel(), 1);

        // Retry: paid once, not twice.
        final result = await apply(id: 'lvl', xp: xpForLevel2, coins: 0);
        expect(result.levelUpCoins, greaterThan(0));
        expect(await coinBalance(), result.levelUpCoins);
        expect(await coinTransactionCount('levelUp'), 1);
      },
    );
  });

  // ---- restart across many failures ---------------------------------------

  test('failing at every table in turn still credits exactly once', () async {
    for (final table in [
      'statistics',
      'coins',
      'battle_passes',
      'player_progress_table',
    ]) {
      await breakWrites(table);
      try {
        await apply();
      } catch (_) {
        // expected
      }
      await unbreakWrites(table);
    }

    final done = await DriftSettlementWriter(db).applyOnce(_settlement());

    expect(done, isTrue);
    expect(await coinBalance(), 25);
    expect(await battlePassXp(), 20);
    expect(await lifetimeXp(), 20);
    expect((await stats()).totalGamesPlayed, 1);
    expect(await coinTransactionCount(), 1);
  });

  test('an interrupted match is marked applied without crediting anything',
      () async {
    final writer = DriftSettlementWriter(db);
    await writer.applyOnce(_settlement(endReason: 'ServerInterrupted'));

    expect(await coinBalance(), 0);
    expect(await lifetimeXp(), 0);
    expect((await stats()).totalGamesPlayed, 0);
    expect(await db.isSettlementApplied('s1'), isTrue);
  });

  test('the in-memory refresh runs only after a commit', () async {
    var refreshes = 0;
    final writer = DriftSettlementWriter(
      db,
      onApplied: (_) async => refreshes++,
    );

    await breakWrites('coins');
    await expectLater(
        writer.applyOnce(_settlement()), throwsA(isA<Object>()));
    expect(refreshes, 0, reason: 'a rolled-back attempt must not refresh');
    await unbreakWrites('coins');

    await writer.applyOnce(_settlement());
    expect(refreshes, 1);

    // A no-op second apply changed nothing, so there is nothing to refresh.
    await writer.applyOnce(_settlement());
    expect(refreshes, 1);
  });
}

MultiplayerSettlement _settlement({
  String id = 's1',
  String endReason = 'LastAlive',
  int coins = 25,
  int xp = 20,
}) {
  return MultiplayerSettlement(
    id: id,
    gameId: 'g1',
    result: 'Win',
    coinsAwarded: coins,
    battlePassXpAwarded: xp,
    score: 120,
    foodsEaten: 12,
    durationSeconds: 95,
    survivedToEnd: true,
    deathReason: null,
    endReason: endReason,
    ratingDelta: 16,
    ratingAfter: 1016,
    versusBot: false,
  );
}
