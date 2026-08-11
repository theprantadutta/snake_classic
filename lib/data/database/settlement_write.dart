import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/models/game_statistics.dart';
import 'package:snake_classic/models/player_level.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_state.dart'
    show BattlePassTiers;
import 'package:snake_classic/models/snake_coins.dart';

/// What one settlement actually changed, reported back after the transaction
/// committed so the in-memory layer can be refreshed from durable truth.
class SettlementWriteResult {
  /// False when the settlement was already applied — nothing was written.
  final bool applied;

  final int coinsCredited;
  final int battlePassXpCredited;
  final int lifetimeXpCredited;

  /// Lifetime levels crossed by this settlement's XP, and the coins those
  /// level-ups paid. Both are part of the same transaction as everything else.
  final int levelBefore;
  final int levelAfter;
  final int levelUpCoins;

  const SettlementWriteResult({
    required this.applied,
    this.coinsCredited = 0,
    this.battlePassXpCredited = 0,
    this.lifetimeXpCredited = 0,
    this.levelBefore = 0,
    this.levelAfter = 0,
    this.levelUpCoins = 0,
  });

  static const alreadyApplied = SettlementWriteResult(applied: false);

  bool get leveledUp => levelAfter > levelBefore;

  /// Every coin this settlement minted — the match reward plus any level-up
  /// bonuses it triggered.
  int get totalCoins => coinsCredited + levelUpCoins;
}

/// What one daily-challenge settlement changed.
class DailyChallengeWriteResult {
  final bool applied;
  final int coinsCredited;
  final int xpCredited;

  const DailyChallengeWriteResult({
    required this.applied,
    this.coinsCredited = 0,
    this.xpCredited = 0,
  });

  static const alreadyApplied = DailyChallengeWriteResult(applied: false);
}

/// The whole durable effect of applying one multiplayer settlement, as a
/// single atomic database operation.
///
/// This exists because routing settlement rewards through the cubits and
/// services could not be made safe. Three separate problems, all of which
/// this sidesteps rather than patches:
///
///   * **Failures were swallowed.** StatisticsService._persistToDrift,
///     BattlePassCubit.flushXP and ProgressionService.flushXp each catch their
///     own persistence errors and return normally. A caller could not tell a
///     successful write from a failed one, so a settlement marked itself
///     applied over rewards that never landed.
///
///   * **Level-up coins escaped.** ProgressionService.flushXp fires
///     `_creditLevelUpRewards` with `unawaited`, outside any transaction and
///     with no idempotency of its own. Settlement XP that crossed a level
///     minted coins that no rollback could take back and no record could
///     dedupe — so a replayed settlement paid them twice.
///
///   * **In-memory state cannot roll back.** Those services compute from
///     their own in-memory state and mutate it as they go, so a rolled-back
///     transaction left memory ahead of the database.
///
/// Here every write is a DAO write inside ONE transaction, together with the
/// settlement marker. Either the player's statistics, coins, battle-pass XP,
/// lifetime XP and level-up rewards all move, or none of them do. Nothing
/// in-memory is touched at all; the caller refreshes from the database after
/// the commit returns.
extension SettlementWrite on AppDatabase {
  /// Apply [settlementId]'s rewards exactly once.
  ///
  /// Returns [SettlementWriteResult.alreadyApplied] without writing anything if
  /// the marker says it is done. Throws if any write fails — and because the
  /// whole thing is one transaction, a throw means nothing was applied.
  Future<SettlementWriteResult> applyMultiplayerSettlementOnce({
    required String settlementId,
    required int coinsAwarded,
    required int battlePassXpAwarded,
    required int score,
    required int foodsEaten,
    required int durationSeconds,
    required bool survivedToEnd,
    required String? deathReason,
    required bool won,
  }) {
    return transaction(() async {
      // Read the marker inside the transaction: a concurrent pass must not see
      // a stale "not applied" and pay the same settlement alongside this one.
      final existing = await (select(appliedMultiplayerSettlements)
            ..where((t) => t.settlementId.equals(settlementId)))
          .getSingleOrNull();
      if (existing?.completedAt != null) {
        return SettlementWriteResult.alreadyApplied;
      }

      await _writeStatistics(
        score: score,
        foodsEaten: foodsEaten,
        durationSeconds: durationSeconds,
        survivedToEnd: survivedToEnd,
        deathReason: deathReason,
      );

      if (coinsAwarded > 0) {
        await storeDao.addCoins(
          coinsAwarded,
          CoinEarningSource.multiplayer.name,
          description: won ? 'Multiplayer Victory' : 'Multiplayer Match',
        );
      }

      await _addBattlePassXp(battlePassXpAwarded);

      // Lifetime XP, the levels it crosses, and the coins those levels pay —
      // all inside this transaction. This is the piece that used to escape as
      // an unawaited call with no record of its own.
      final progressBefore = await gameDao.getPlayerProgress();
      final levelBefore = progressBefore?.level ?? PlayerLevel.levelForXp(0);
      var levelAfter = levelBefore;
      var levelUpCoins = 0;

      if (battlePassXpAwarded > 0) {
        final progressAfter = await gameDao.addPlayerXp(battlePassXpAwarded);
        levelAfter = progressAfter.level;

        for (var level = levelBefore + 1; level <= levelAfter; level++) {
          levelUpCoins += PlayerLevel.coinRewardForLevel(level);
        }
        if (levelUpCoins > 0) {
          await storeDao.addCoins(
            levelUpCoins,
            CoinEarningSource.levelUp.name,
            description: 'Player Level $levelAfter',
          );
        }
      }

      await into(appliedMultiplayerSettlements).insertOnConflictUpdate(
        AppliedMultiplayerSettlementsCompanion.insert(
          settlementId: settlementId,
          statsApplied: const Value(true),
          coinsApplied: const Value(true),
          xpApplied: const Value(true),
          completedAt: Value(DateTime.now()),
        ),
      );

      return SettlementWriteResult(
        applied: true,
        coinsCredited: coinsAwarded,
        battlePassXpCredited: battlePassXpAwarded,
        lifetimeXpCredited: battlePassXpAwarded,
        levelBefore: levelBefore,
        levelAfter: levelAfter,
        levelUpCoins: levelUpCoins,
      );
    });
  }

  /// Apply one daily-challenge settlement's coins and XP, exactly once.
  ///
  /// Same shape and the same reasoning as
  /// [applyMultiplayerSettlementOnce]: one transaction covering the coins,
  /// the battle-pass XP and the marker, at the DAO layer, so a failure
  /// anywhere rolls back everything and a replay pays nothing. Nothing
  /// in-memory is touched — the caller refreshes from Drift after the commit
  /// returns, so a rollback cannot leave the UI ahead of the database.
  ///
  /// This replaces "set a local claimed flag, then call CoinsCubit". That was
  /// two independent writes with a crash window between them, and it was the
  /// device deciding it had earned something rather than the server.
  Future<DailyChallengeWriteResult> applyDailyChallengeSettlementOnce({
    required String settlementId,
    required String settlementKey,
    required int coinsAwarded,
    required int xpAwarded,
    required String description,
  }) {
    return transaction(() async {
      // Read BOTH markers inside the transaction.
      //
      // By id, so a re-delivered settlement is a no-op. And by key, so a
      // reward this device already paid itself under the old local-claim flow
      // — recorded during the v20 migration — is never paid again, even if
      // the server offers a settlement for it.
      final byId = await (select(appliedDailyChallengeSettlements)
            ..where((t) => t.settlementId.equals(settlementId)))
          .getSingleOrNull();
      if (byId?.completedAt != null) {
        return DailyChallengeWriteResult.alreadyApplied;
      }

      final byKey = await (select(appliedDailyChallengeSettlements)
            ..where((t) =>
                t.settlementKey.equals(settlementKey) &
                t.completedAt.isNotNull()))
          .get();
      if (byKey.isNotEmpty) {
        // Record the id as seen so it stops being offered, but pay nothing.
        await into(appliedDailyChallengeSettlements).insertOnConflictUpdate(
          AppliedDailyChallengeSettlementsCompanion.insert(
            settlementId: settlementId,
            settlementKey: settlementKey,
            coinsApplied: const Value(0),
            xpApplied: const Value(0),
            completedAt: Value(DateTime.now()),
          ),
        );
        return DailyChallengeWriteResult.alreadyApplied;
      }

      if (coinsAwarded > 0) {
        await storeDao.addCoins(
          coinsAwarded,
          CoinEarningSource.dailyChallenge.name,
          description: description,
        );
      }

      await _addBattlePassXp(xpAwarded);

      await into(appliedDailyChallengeSettlements).insertOnConflictUpdate(
        AppliedDailyChallengeSettlementsCompanion.insert(
          settlementId: settlementId,
          settlementKey: settlementKey,
          coinsApplied: Value(coinsAwarded),
          xpApplied: Value(xpAwarded),
          completedAt: Value(DateTime.now()),
        ),
      );

      return DailyChallengeWriteResult(
        applied: true,
        coinsCredited: coinsAwarded,
        xpCredited: xpAwarded,
      );
    });
  }

  /// Whether this device has already banked the reward for [settlementKey] —
  /// a catalog challenge id, or `bonus:<date>`.
  ///
  /// What separates a claim that has SETTLED from one still pending, which is
  /// what the UI shows the player while they are offline.
  Future<bool> isDailyChallengeSettled(String settlementKey) async {
    final rows = await (select(appliedDailyChallengeSettlements)
          ..where((t) =>
              t.settlementKey.equals(settlementKey) &
              t.completedAt.isNotNull()))
        .get();
    return rows.isNotEmpty;
  }

  /// Every settled key, for hydrating the UI in one read.
  Future<Set<String>> settledDailyChallengeKeys() async {
    final rows = await (select(appliedDailyChallengeSettlements)
          ..where((t) => t.completedAt.isNotNull()))
        .get();
    return rows.map((r) => r.settlementKey).toSet();
  }

  /// Mark a settlement done without granting anything — a match the server
  /// never settled. Still a transaction so it cannot half-happen.
  Future<void> markSettlementApplied(String settlementId) {
    return transaction(() async {
      await into(appliedMultiplayerSettlements).insertOnConflictUpdate(
        AppliedMultiplayerSettlementsCompanion.insert(
          settlementId: settlementId,
          statsApplied: const Value(true),
          coinsApplied: const Value(true),
          xpApplied: const Value(true),
          completedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<bool> isSettlementApplied(String settlementId) async {
    final row = await (select(appliedMultiplayerSettlements)
          ..where((t) => t.settlementId.equals(settlementId)))
        .getSingleOrNull();
    return row?.completedAt != null;
  }

  /// Fold the match into the statistics blob using the same model math the
  /// normal game-end path uses, and write it back. No swallowing: a failure
  /// here rolls the whole settlement back.
  Future<void> _writeStatistics({
    required int score,
    required int foodsEaten,
    required int durationSeconds,
    required bool survivedToEnd,
    required String? deathReason,
  }) async {
    final row = await gameDao.getStatistics();
    final current = row?.modelJson == null
        ? const GameStatistics()
        : GameStatistics.fromJson(
            jsonDecode(row!.modelJson) as Map<String, dynamic>);

    final wallHits = deathReason == 'wall' ? 1 : 0;
    // self / opponent / head_on all bucket into selfHits — statistics has no
    // "other snake" column and multiplayer walls are always on.
    final selfHits = (!survivedToEnd && wallHits == 0) ? 1 : 0;

    final updated = current.updateWithGameResult(
      score: score,
      gameTime: durationSeconds,
      level: 1,
      foodConsumed: foodsEaten,
      foodTypes: {'apple': foodsEaten},
      foodPoints: score,
      powerUpsCollected: 0,
      powerUpTypes: const <String, int>{},
      powerUpTime: 0,
      wallHits: wallHits,
      selfHits: selfHits,
      isPerfectGame: survivedToEnd && durationSeconds >= 30,
      unlockedAchievements: const [],
      // Multiplayer records under the non-GameMode key on purpose — it must
      // not count toward per-mode / mode-exploration achievements.
      gameMode: 'multiplayer',
    );

    await gameDao.updateStatisticsFromJson(jsonEncode(updated.toJson()));
  }

  /// Add battle-pass XP, rolling tiers exactly as BattlePassCubit.addXP does,
  /// but writing straight to the row instead of deriving from cubit memory.
  Future<void> _addBattlePassXp(int xp) async {
    if (xp <= 0) return;

    final pass = await storeDao.getCurrentBattlePass();
    if (pass == null) return; // no active season — nothing to credit

    var newXp = pass.currentXp + xp;
    var newTier = pass.currentTier;
    var xpForNext = pass.xpForNextTier;

    while (newXp >= xpForNext && newTier < BattlePassTiers.max) {
      newXp -= xpForNext;
      newTier++;
      xpForNext = BattlePassTiers.xpRequiredForTier(newTier);
    }

    await storeDao.saveBattlePass(
      BattlePassesCompanion(
        id: Value(pass.id),
        seasonId: Value(pass.seasonId),
        currentTier: Value(newTier),
        currentXp: Value(newXp),
        xpForNextTier: Value(xpForNext),
      ),
    );
  }
}
