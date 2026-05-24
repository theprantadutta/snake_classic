import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:snake_classic/data/database/app_database.dart';

part 'store_dao.g.dart';

@DriftAccessor(
    tables: [Coins, CoinTransactions, PremiumStatus, UnlockedItems, BattlePasses, PurchaseHistory])
class StoreDao extends DatabaseAccessor<AppDatabase> with _$StoreDaoMixin {
  StoreDao(super.db);

  // ==================== Coins ====================

  /// Watch coin balance for reactive UI
  Stream<int> watchCoinBalance() =>
      (select(coins)..where((t) => t.id.equals(1)))
          .watchSingleOrNull()
          .map((c) => c?.balance ?? 0);

  /// Get current coin balance
  Future<int> getCoinBalance() async {
    final coin = await (select(coins)..where((t) => t.id.equals(1)))
        .getSingleOrNull();
    return coin?.balance ?? 0;
  }

  /// Add coins (from game, achievement, etc.). Bumps balance, appends
  /// a transaction record, and enqueues both rows for sync inside a
  /// single Drift transaction.
  Future<void> addCoins(int amount, String source, {String? description}) async {
    final current = await (select(coins)..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    if (current == null) return;

    final newBalance = current.balance + amount;
    final newTotalEarned = current.totalEarned + amount;
    final now = DateTime.now();

    await transaction(() async {
      await (update(coins)..where((t) => t.id.equals(1))).write(CoinsCompanion(
        balance: Value(newBalance),
        totalEarned: Value(newTotalEarned),
        lastUpdated: Value(now),
        updatedAt: Value(now),
      ));

      await into(coinTransactions).insert(CoinTransactionsCompanion.insert(
        amount: amount,
        type: 'earned',
        source: source,
        description: Value(description),
        updatedAt: Value(now),
      ));

      final txnKey = 'coin_transaction:${now.microsecondsSinceEpoch}';
      await attachedDatabase.enqueueSyncOutbox(
        dataType: SyncDataType.coinBalance,
        entityKey: 'coin_balance:1',
      );
      await attachedDatabase.enqueueSyncOutbox(
        dataType: SyncDataType.coinTransaction,
        entityKey: txnKey,
        payload: {
          'amount': amount,
          'type': 'earned',
          'source': source,
          'description': description,
          'created_at': now.toUtc().toIso8601String(),
        },
      );
    });
  }

  /// Spend coins. Mirrors [addCoins] but with the opposite sign.
  Future<bool> spendCoins(int amount, String source, {String? description}) async {
    final current = await (select(coins)..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    if (current == null || current.balance < amount) return false;

    final newBalance = current.balance - amount;
    final newTotalSpent = current.totalSpent + amount;
    final now = DateTime.now();

    await transaction(() async {
      await (update(coins)..where((t) => t.id.equals(1))).write(CoinsCompanion(
        balance: Value(newBalance),
        totalSpent: Value(newTotalSpent),
        lastUpdated: Value(now),
        updatedAt: Value(now),
      ));

      await into(coinTransactions).insert(CoinTransactionsCompanion.insert(
        amount: -amount,
        type: 'spent',
        source: source,
        description: Value(description),
        updatedAt: Value(now),
      ));

      final txnKey = 'coin_transaction:${now.microsecondsSinceEpoch}';
      await attachedDatabase.enqueueSyncOutbox(
        dataType: SyncDataType.coinBalance,
        entityKey: 'coin_balance:1',
      );
      await attachedDatabase.enqueueSyncOutbox(
        dataType: SyncDataType.coinTransaction,
        entityKey: txnKey,
        payload: {
          'amount': -amount,
          'type': 'spent',
          'source': source,
          'description': description,
          'createdAt': now.toIso8601String(),
        },
      );
    });

    return true;
  }

  /// Set coin balance directly. Used by the first-sign-in pull when
  /// the cloud's authoritative balance comes down. [enqueueSync]
  /// defaults true; set false when hydrating from server data.
  Future<void> setCoinBalance(int balance, {bool enqueueSync = true}) async {
    final now = DateTime.now();
    await transaction(() async {
      await (update(coins)..where((t) => t.id.equals(1))).write(CoinsCompanion(
        balance: Value(balance),
        lastUpdated: Value(now),
        updatedAt: Value(now),
      ));
      if (enqueueSync) {
        await attachedDatabase.enqueueSyncOutbox(
          dataType: SyncDataType.coinBalance,
          entityKey: 'coin_balance:1',
        );
      }
    });
  }

  /// Get coin transaction history
  Future<List<CoinTransaction>> getCoinTransactions({int limit = 50}) async {
    return (select(coinTransactions)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)])
          ..limit(limit))
        .get();
  }

  // ==================== Premium Status ====================

  /// Watch premium status
  Stream<PremiumStatusData?> watchPremiumStatus() =>
      (select(premiumStatus)..where((t) => t.id.equals(1))).watchSingleOrNull();

  /// Get premium status
  Future<PremiumStatusData?> getPremiumStatus() =>
      (select(premiumStatus)..where((t) => t.id.equals(1))).getSingleOrNull();

  /// Check if premium is active
  Future<bool> isPremiumActive() async {
    final status = await getPremiumStatus();
    if (status == null) return false;

    if (!status.isPremiumActive) return false;

    if (status.premiumExpirationDate != null &&
        DateTime.now().isAfter(status.premiumExpirationDate!)) {
      // Premium expired — flip the flag through the canonical setter
      // so the outbox row gets queued.
      await setPremiumActive(false);
      return false;
    }

    return true;
  }

  /// Apply a partial update to the singleton premium-status row + bump
  /// timestamps + enqueue an outbox row.
  Future<void> _writePremiumStatus(
    PremiumStatusCompanion patch, {
    bool enqueueSync = true,
  }) async {
    final now = DateTime.now();
    await transaction(() async {
      await (update(premiumStatus)..where((t) => t.id.equals(1))).write(
        patch.copyWith(
          lastUpdated: Value(now),
          updatedAt: Value(now),
        ),
      );
      if (enqueueSync) {
        await attachedDatabase.enqueueSyncOutbox(
          dataType: SyncDataType.premiumStatus,
          entityKey: 'premium_status:1',
        );
      }
    });
  }

  /// Set premium active
  Future<void> setPremiumActive(bool active, {DateTime? expirationDate}) =>
      _writePremiumStatus(PremiumStatusCompanion(
        isPremiumActive: Value(active),
        premiumExpirationDate: Value(expirationDate),
      ));

  /// Cloud-snapshot apply path. Mirrors [_writePremiumStatus] but
  /// without the outbox enqueue, so a first-sign-in restore can write
  /// the row without immediately echoing it back as a push.
  Future<void> applyPremiumStatusSnapshot(PremiumStatusCompanion patch) =>
      _writePremiumStatus(patch, enqueueSync: false);

  /// Cloud-snapshot apply path for coin balance.
  Future<void> applyCoinBalanceSnapshot({
    required int balance,
    int? totalEarned,
    int? totalSpent,
    DateTime? updatedAt,
  }) async {
    final ts = updatedAt ?? DateTime.now();
    await (update(coins)..where((t) => t.id.equals(1))).write(CoinsCompanion(
      balance: Value(balance),
      totalEarned: totalEarned == null ? const Value.absent() : Value(totalEarned),
      totalSpent: totalSpent == null ? const Value.absent() : Value(totalSpent),
      lastUpdated: Value(ts),
      updatedAt: Value(ts),
    ));
  }

  /// Get premium expiration date as string
  Future<String?> getPremiumExpirationDate() async {
    final status = await getPremiumStatus();
    return status?.premiumExpirationDate?.toIso8601String();
  }

  /// Set trial data
  Future<void> setTrialData({
    required bool isOnTrial,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
  }) =>
      _writePremiumStatus(PremiumStatusCompanion(
        isOnTrial: Value(isOnTrial),
        trialStartDate: Value(trialStartDate),
        trialEndDate: Value(trialEndDate),
      ));

  /// Get trial data
  Future<Map<String, dynamic>> getTrialData() async {
    final status = await getPremiumStatus();
    return {
      'isOnTrial': status?.isOnTrial ?? false,
      'trialStartDate': status?.trialStartDate?.toIso8601String(),
      'trialEndDate': status?.trialEndDate?.toIso8601String(),
    };
  }

  /// Set tournament entries
  Future<void> setTournamentEntries({
    required int bronze,
    required int silver,
    required int gold,
  }) =>
      _writePremiumStatus(PremiumStatusCompanion(
        bronzeTournamentEntries: Value(bronze),
        silverTournamentEntries: Value(silver),
        goldTournamentEntries: Value(gold),
      ));

  /// Get tournament entries
  Future<Map<String, int>> getTournamentEntries() async {
    final status = await getPremiumStatus();
    return {
      'bronze': status?.bronzeTournamentEntries ?? 0,
      'silver': status?.silverTournamentEntries ?? 0,
      'gold': status?.goldTournamentEntries ?? 0,
    };
  }

  // ==================== Unlocked Items ====================

  /// Get unlocked items by type
  Future<List<String>> getUnlockedItemsByType(String itemType) async {
    final items = await (select(unlockedItems)
          ..where((t) => t.itemType.equals(itemType)))
        .get();
    return items.map((i) => i.itemId).toList();
  }

  /// Check if item is unlocked
  Future<bool> isItemUnlocked(String itemId, String itemType) async {
    final item = await (select(unlockedItems)
          ..where(
              (t) => t.itemId.equals(itemId) & t.itemType.equals(itemType)))
        .getSingleOrNull();
    return item != null;
  }

  /// Unlock an item. Idempotent — insertOrIgnore avoids creating
  /// duplicate rows for the same (itemId, itemType) pair. The outbox
  /// row is enqueued unconditionally; the sync engine handles
  /// dedup at the backend.
  Future<void> unlockItem(String itemId, String itemType,
      {String? unlockedBy, bool enqueueSync = true}) async {
    final now = DateTime.now();
    await transaction(() async {
      await into(unlockedItems).insert(
        UnlockedItemsCompanion.insert(
          itemId: itemId,
          itemType: itemType,
          unlockedBy: Value(unlockedBy ?? 'purchase'),
          updatedAt: Value(now),
        ),
        mode: InsertMode.insertOrIgnore,
      );
      if (enqueueSync) {
        await attachedDatabase.enqueueSyncOutbox(
          dataType: SyncDataType.unlockedItem,
          entityKey: 'unlocked_item:$itemType:$itemId',
          payload: {
            'item_id': itemId,
            'item_type': itemType,
            'unlocked_by': unlockedBy ?? 'purchase',
            'unlocked_at': now.toUtc().toIso8601String(),
          },
        );
      }
    });
  }

  /// Replace all items for a given type. Used by server-restore /
  /// admin-debug paths. [enqueueSync] defaults true; pass false when
  /// hydrating from a cloud pull.
  Future<void> setUnlockedItems(
    String itemType,
    List<String> itemIds, {
    bool enqueueSync = true,
  }) async {
    await transaction(() async {
      await (delete(unlockedItems)..where((t) => t.itemType.equals(itemType)))
          .go();
      for (final itemId in itemIds) {
        await unlockItem(itemId, itemType, enqueueSync: enqueueSync);
      }
    });
  }

  // Convenience methods for specific item types
  Future<List<String>> getUnlockedThemes() => getUnlockedItemsByType('theme');
  Future<List<String>> getUnlockedSkins() => getUnlockedItemsByType('skin');
  Future<List<String>> getUnlockedTrails() => getUnlockedItemsByType('trail');
  Future<List<String>> getUnlockedPowerUps() => getUnlockedItemsByType('powerup');
  Future<List<String>> getUnlockedBoardSizes() => getUnlockedItemsByType('board_size');
  Future<List<String>> getUnlockedGameModes() => getUnlockedItemsByType('game_mode');
  Future<List<String>> getUnlockedBundles() => getUnlockedItemsByType('bundle');

  Future<void> setUnlockedThemes(List<String> ids) => setUnlockedItems('theme', ids);
  Future<void> setUnlockedSkins(List<String> ids) => setUnlockedItems('skin', ids);
  Future<void> setUnlockedTrails(List<String> ids) => setUnlockedItems('trail', ids);
  Future<void> setUnlockedPowerUps(List<String> ids) => setUnlockedItems('powerup', ids);
  Future<void> setUnlockedBoardSizes(List<String> ids) => setUnlockedItems('board_size', ids);
  Future<void> setUnlockedGameModes(List<String> ids) => setUnlockedItems('game_mode', ids);
  Future<void> setUnlockedBundles(List<String> ids) => setUnlockedItems('bundle', ids);

  // ==================== Battle Pass ====================

  /// Watch battle pass
  Stream<BattlePassesData?> watchBattlePass(String seasonId) =>
      (select(battlePasses)..where((t) => t.seasonId.equals(seasonId)))
          .watchSingleOrNull();

  /// Get battle pass
  Future<BattlePassesData?> getBattlePass(String seasonId) =>
      (select(battlePasses)..where((t) => t.seasonId.equals(seasonId)))
          .getSingleOrNull();

  /// Get current battle pass (any season)
  Future<BattlePassesData?> getCurrentBattlePass() =>
      (select(battlePasses)..limit(1)).getSingleOrNull();

  /// Save battle pass data. [enqueueSync] defaults true.
  Future<void> saveBattlePass(
    BattlePassesCompanion pass, {
    bool enqueueSync = true,
  }) async {
    final now = DateTime.now();
    final stamped = pass.copyWith(
      lastUpdated: Value(now),
      updatedAt: Value(now),
    );
    final seasonId = stamped.seasonId.present ? stamped.seasonId.value : null;
    await transaction(() async {
      await into(battlePasses).insertOnConflictUpdate(stamped);
      if (enqueueSync && seasonId != null) {
        await attachedDatabase.enqueueSyncOutbox(
          dataType: SyncDataType.battlePass,
          entityKey: 'battle_pass:$seasonId',
        );
      }
    });
  }

  /// Get battle pass as JSON
  Future<String?> getBattlePassData() async {
    final pass = await getCurrentBattlePass();
    if (pass == null) return null;

    return json.encode({
      'seasonId': pass.seasonId,
      'currentTier': pass.currentTier,
      'currentXp': pass.currentXp,
      'xpForNextTier': pass.xpForNextTier,
      'isPremiumPass': pass.isPremiumPass,
      'claimedRewards': json.decode(pass.claimedRewards),
      'seasonStartDate': pass.seasonStartDate?.toIso8601String(),
      'seasonEndDate': pass.seasonEndDate?.toIso8601String(),
    });
  }

  /// Set battle pass from JSON. Used by the server pull on first
  /// sign-in; doesn't enqueue an outbox row.
  Future<void> setBattlePassData(String? jsonData) async {
    if (jsonData == null) {
      await delete(battlePasses).go();
      return;
    }

    final data = json.decode(jsonData) as Map<String, dynamic>;
    await saveBattlePass(
      BattlePassesCompanion(
        seasonId: Value(data['seasonId'] ?? 'default'),
        currentTier: Value(data['currentTier'] ?? 0),
        currentXp: Value(data['currentXp'] ?? 0),
        xpForNextTier: Value(data['xpForNextTier'] ?? 100),
        isPremiumPass: Value(data['isPremiumPass'] ?? false),
        claimedRewards: Value(json.encode(data['claimedRewards'] ?? [])),
        seasonStartDate: data['seasonStartDate'] != null
            ? Value(DateTime.parse(data['seasonStartDate']))
            : const Value.absent(),
        seasonEndDate: data['seasonEndDate'] != null
            ? Value(DateTime.parse(data['seasonEndDate']))
            : const Value.absent(),
      ),
      enqueueSync: false,
    );
  }

  // ==================== Purchase History ====================
  // PurchaseHistory is not synced — the server is already the source
  // of truth via the IAP receipt-verification path.

  /// Add purchase to history
  Future<void> addPurchase(PurchaseHistoryCompanion purchase) async {
    await into(purchaseHistory).insert(purchase);
  }

  /// Get purchase history
  Future<List<PurchaseHistoryData>> getPurchaseHistory() =>
      (select(purchaseHistory)
            ..orderBy([(t) => OrderingTerm.desc(t.purchasedAt)]))
          .get();

  /// Get purchase history as JSON list
  Future<List<String>> getPurchaseHistoryJson() async {
    final purchases = await getPurchaseHistory();
    return purchases
        .map((p) => json.encode({
              'purchaseId': p.purchaseId,
              'productId': p.productId,
              'transactionId': p.transactionId,
              'amount': p.amount,
              'currency': p.currency,
              'status': p.status,
              'purchasedAt': p.purchasedAt.toIso8601String(),
            }))
        .toList();
  }

  /// Add purchase from JSON
  Future<void> addPurchaseFromJson(String purchaseJson) async {
    final data = json.decode(purchaseJson) as Map<String, dynamic>;
    await addPurchase(PurchaseHistoryCompanion.insert(
      purchaseId: data['purchaseId'] ?? '',
      productId: data['productId'] ?? '',
      transactionId: Value(data['transactionId']),
      amount: data['amount'] ?? 0,
      currency: Value(data['currency'] ?? 'USD'),
      status: data['status'] ?? 'completed',
      receiptData: Value(data['receiptData']),
    ));
  }
}
