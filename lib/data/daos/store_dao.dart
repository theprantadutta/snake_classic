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

  /// Add coins (from game, achievement, etc.)
  Future<void> addCoins(int amount, String source, {String? description}) async {
    final current = await (select(coins)..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    if (current == null) return;

    final newBalance = current.balance + amount;
    final newTotalEarned = current.totalEarned + amount;

    await (update(coins)..where((t) => t.id.equals(1))).write(CoinsCompanion(
      balance: Value(newBalance),
      totalEarned: Value(newTotalEarned),
      lastUpdated: Value(DateTime.now()),
    ));

    // Record transaction
    await into(coinTransactions).insert(CoinTransactionsCompanion.insert(
      amount: amount,
      type: 'earned',
      source: source,
      description: Value(description),
    ));
  }

  /// Spend coins
  Future<bool> spendCoins(int amount, String source, {String? description}) async {
    final current = await (select(coins)..where((t) => t.id.equals(1)))
        .getSingleOrNull();

    if (current == null || current.balance < amount) return false;

    final newBalance = current.balance - amount;
    final newTotalSpent = current.totalSpent + amount;

    await (update(coins)..where((t) => t.id.equals(1))).write(CoinsCompanion(
      balance: Value(newBalance),
      totalSpent: Value(newTotalSpent),
      lastUpdated: Value(DateTime.now()),
    ));

    // Record transaction
    await into(coinTransactions).insert(CoinTransactionsCompanion.insert(
      amount: -amount,
      type: 'spent',
      source: source,
      description: Value(description),
    ));

    return true;
  }

  /// Set coin balance directly (for sync)
  Future<void> setCoinBalance(int balance) async {
    await (update(coins)..where((t) => t.id.equals(1))).write(CoinsCompanion(
      balance: Value(balance),
      lastUpdated: Value(DateTime.now()),
    ));
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

    // Check expiration
    if (status.premiumExpirationDate != null &&
        DateTime.now().isAfter(status.premiumExpirationDate!)) {
      // Premium expired, update status
      await (update(premiumStatus)..where((t) => t.id.equals(1)))
          .write(const PremiumStatusCompanion(isPremiumActive: Value(false)));
      return false;
    }

    return true;
  }

  /// Set premium active
  Future<void> setPremiumActive(bool active, {DateTime? expirationDate}) async {
    await (update(premiumStatus)..where((t) => t.id.equals(1)))
        .write(PremiumStatusCompanion(
      isPremiumActive: Value(active),
      premiumExpirationDate: Value(expirationDate),
      lastUpdated: Value(DateTime.now()),
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
  }) async {
    await (update(premiumStatus)..where((t) => t.id.equals(1)))
        .write(PremiumStatusCompanion(
      isOnTrial: Value(isOnTrial),
      trialStartDate: Value(trialStartDate),
      trialEndDate: Value(trialEndDate),
      lastUpdated: Value(DateTime.now()),
    ));
  }

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
  }) async {
    await (update(premiumStatus)..where((t) => t.id.equals(1)))
        .write(PremiumStatusCompanion(
      bronzeTournamentEntries: Value(bronze),
      silverTournamentEntries: Value(silver),
      goldTournamentEntries: Value(gold),
      lastUpdated: Value(DateTime.now()),
    ));
  }

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

  /// Unlock an item
  Future<void> unlockItem(String itemId, String itemType, {String? unlockedBy}) async {
    await into(unlockedItems).insert(
      UnlockedItemsCompanion.insert(
        itemId: itemId,
        itemType: itemType,
        unlockedBy: Value(unlockedBy ?? 'purchase'),
      ),
      mode: InsertMode.insertOrIgnore,
    );
  }

  /// Set unlocked items for a type (replaces all)
  Future<void> setUnlockedItems(String itemType, List<String> itemIds) async {
    await transaction(() async {
      await (delete(unlockedItems)..where((t) => t.itemType.equals(itemType)))
          .go();
      for (final itemId in itemIds) {
        await into(unlockedItems).insert(
          UnlockedItemsCompanion.insert(
            itemId: itemId,
            itemType: itemType,
          ),
        );
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

  /// Save battle pass data
  Future<void> saveBattlePass(BattlePassesCompanion pass) async {
    await into(battlePasses).insertOnConflictUpdate(pass);
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

  /// Set battle pass from JSON
  Future<void> setBattlePassData(String? jsonData) async {
    if (jsonData == null) {
      await delete(battlePasses).go();
      return;
    }

    final data = json.decode(jsonData) as Map<String, dynamic>;
    await saveBattlePass(BattlePassesCompanion(
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
      lastUpdated: Value(DateTime.now()),
    ));
  }

  // ==================== Purchase History ====================

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
