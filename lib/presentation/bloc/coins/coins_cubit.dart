import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/logger.dart';

import 'coins_state.dart';

export 'coins_state.dart';

/// Cubit for managing in-game coin economy
class CoinsCubit extends Cubit<CoinsState> {
  final Uuid _uuid = const Uuid();
  SharedPreferences? _prefs;

  CoinsCubit() : super(CoinsState.initial());

  /// Initialize the coins cubit
  Future<void> initialize() async {
    if (state.status == CoinsStatus.ready) return;

    emit(state.copyWith(status: CoinsStatus.loading));

    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadData();

      // Historical-state backfill — earnCoins USED to only write to
      // SharedPreferences, so any coin gain prior to the StoreDao routing
      // fix lives only in CoinsCubit's local state and was never seen
      // by Drift, SyncEngine, or the backend. The result: dashboard
      // shows a smaller balance than the Flutter user sees.
      //
      // On first init after the fix, if SharedPreferences holds more
      // coins than the Drift coins row, push the delta through
      // StoreDao.addCoins so it (a) lands in Drift, (b) writes a
      // 'historical_backfill' CoinTransactions audit row, and (c) gets
      // enqueued for sync. The next SyncEngine tick reconciles the
      // backend. Idempotent — once Drift catches up, the delta is 0
      // and the backfill no-ops.
      await _backfillDriftFromSharedPreferences();

      emit(state.copyWith(status: CoinsStatus.ready));
      AppLogger.info('CoinsCubit initialized. Balance: ${state.balance.total}');

      // Backend reconcile is no longer fired here — AuthCubit triggers
      // syncWithBackend after the user is authenticated and the JWT is
      // valid (see AuthCubit._firePostAuthSyncs). Firing here would race
      // with auth and consistently 401 on first launch.
    } catch (e) {
      AppLogger.error('Error initializing CoinsCubit', e);
      emit(
        state.copyWith(status: CoinsStatus.error, errorMessage: e.toString()),
      );
    }
  }

  /// Pull `User.Coins` from the backend and reconcile with local balance.
  ///
  /// Strategy: take max(local, server). The backend coin field gets incremented
  /// on every successful purchase verify (VerifyPurchaseCommandHandler), so on
  /// fresh installs the server will be the source of truth. For existing users
  /// whose verify calls failed before the contract fix, local will still be
  /// higher and we don't want to overwrite it with 0.
  Future<void> syncWithBackend() async {
    try {
      final apiService = ApiService();
      if (!apiService.isAuthenticated) return;

      final data = await apiService.getCurrentUser();
      if (data == null) return;

      final serverCoins = (data['coins'] as int?) ?? 0;
      final localTotal = state.balance.total;
      if (serverCoins <= localTotal) {
        // Local is already at or above server — nothing to do.
        AppLogger.info(
          'Coin sync: local=$localTotal, server=$serverCoins (no change)',
        );
        return;
      }

      // Server is ahead — credit the difference as a "purchased" delta so the
      // CoinBalance.purchased subtotal reflects server-side IAP grants.
      final delta = serverCoins - localTotal;
      final newBalance = state.balance.copyWith(
        total: serverCoins,
        purchased: state.balance.purchased + delta,
        lastUpdated: DateTime.now(),
      );
      emit(state.copyWith(balance: newBalance));
      await _saveData();

      AppLogger.info(
        'Coin sync: local=$localTotal, server=$serverCoins (synced +$delta)',
      );
    } catch (e) {
      AppLogger.error('Error syncing coins with backend', e);
    }
  }

  /// One-shot reconcile of historical SharedPreferences-only coin gains
  /// into Drift. See the call site in [initialize] for context. Safe to
  /// call repeatedly — once Drift catches up to SharedPreferences the
  /// delta is 0 and this no-ops.
  Future<void> _backfillDriftFromSharedPreferences() async {
    try {
      final storageService = StorageService();
      if (!storageService.isInitialized) return;
      final driftRow = await storageService.storeDao.getCoinBalanceRow();
      if (driftRow == null) return; // Drift not seeded yet — initializeDefaults
      // will have created the row before this code path runs, but bail
      // safely on the off chance.

      final driftBalance = driftRow.balance;
      final cubitBalance = state.balance.total;
      if (cubitBalance <= driftBalance) {
        return; // Drift already at or ahead — nothing to backfill.
      }

      final delta = cubitBalance - driftBalance;
      AppLogger.info(
        'CoinsCubit: backfilling +$delta to Drift '
        '(SharedPreferences=$cubitBalance, Drift=$driftBalance) — '
        'historical gains made before earnCoins started routing through '
        'StoreDao. Enqueued for sync via the regular coin_balance / '
        'coin_transaction outbox path.',
      );
      await storageService.storeDao.addCoins(
        delta,
        'historical_backfill',
        description: 'Reconcile of pre-sync SharedPreferences gains',
      );
    } catch (e) {
      AppLogger.warning('CoinsCubit: Drift backfill failed: $e');
    }
  }

  Future<void> _loadData() async {
    if (_prefs == null) return;

    try {
      // Load balance
      final balanceJson = _prefs!.getString('coin_balance');
      CoinBalance balance = CoinBalance.initial;
      if (balanceJson != null) {
        balance = CoinBalance.fromJson(json.decode(balanceJson));
      }

      // Load transactions
      final transactionsJson = _prefs!.getStringList('coin_transactions') ?? [];
      final transactions =
          transactionsJson
              .map((jsonStr) => CoinTransaction.fromJson(json.decode(jsonStr)))
              .toList()
            ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

      // Load daily bonuses
      final bonusesJson = _prefs!.getStringList('daily_bonuses') ?? [];
      List<DailyLoginBonus> dailyBonuses = DailyLoginBonus.getWeeklyBonuses();
      if (bonusesJson.isNotEmpty) {
        dailyBonuses = bonusesJson
            .map((jsonStr) => DailyLoginBonus.fromJson(json.decode(jsonStr)))
            .toList();
      }

      // Load daily earning cap data
      final dailyEarnings = _prefs!.getInt('daily_earnings') ?? 0;
      final lastResetStr = _prefs!.getString('last_earning_reset');
      DateTime lastEarningReset = DateTime.now().toUtc();
      if (lastResetStr != null) {
        lastEarningReset = DateTime.parse(lastResetStr);
      }

      // Check if we need to reset daily earnings (new UTC day)
      final now = DateTime.now().toUtc();
      final resetDate = DateTime.utc(
        lastEarningReset.year,
        lastEarningReset.month,
        lastEarningReset.day,
      );
      final today = DateTime.utc(now.year, now.month, now.day);
      final shouldReset = today.isAfter(resetDate);

      emit(
        state.copyWith(
          balance: balance,
          transactions: transactions,
          dailyBonuses: dailyBonuses,
          dailyEarnings: shouldReset ? 0 : dailyEarnings,
          lastEarningReset: shouldReset ? now : lastEarningReset,
        ),
      );

      // Save reset if needed
      if (shouldReset) {
        await _saveDailyCapData();
      }

      AppLogger.info('Coin data loaded successfully');
    } catch (e) {
      AppLogger.error('Error loading coin data', e);
    }
  }

  Future<void> _saveData() async {
    if (_prefs == null) return;

    try {
      // Save balance
      await _prefs!.setString(
        'coin_balance',
        json.encode(state.balance.toJson()),
      );

      // Save recent transactions (limit to last 200)
      final recentTransactions = state.transactions.take(200).toList();
      final transactionsJson = recentTransactions
          .map((t) => json.encode(t.toJson()))
          .toList();
      await _prefs!.setStringList('coin_transactions', transactionsJson);

      // Save daily bonuses
      final bonusesJson = state.dailyBonuses
          .map((b) => json.encode(b.toJson()))
          .toList();
      await _prefs!.setStringList('daily_bonuses', bonusesJson);

      // Save daily cap data
      await _saveDailyCapData();
    } catch (e) {
      AppLogger.error('Error saving coin data', e);
    }
  }

  Future<void> _saveDailyCapData() async {
    if (_prefs == null) return;
    await _prefs!.setInt('daily_earnings', state.dailyEarnings);
    await _prefs!.setString(
      'last_earning_reset',
      state.lastEarningReset.toIso8601String(),
    );
  }

  /// Check if earning would exceed daily cap
  bool _wouldExceedDailyCap(int amount) {
    return state.dailyEarnings + amount > state.dailyEarningCap;
  }

  /// Reset daily earnings if needed (called at midnight UTC)
  void _checkAndResetDailyEarnings() {
    final now = DateTime.now().toUtc();
    final lastReset = state.lastEarningReset;
    final resetDate = DateTime.utc(lastReset.year, lastReset.month, lastReset.day);
    final today = DateTime.utc(now.year, now.month, now.day);

    if (today.isAfter(resetDate)) {
      emit(state.copyWith(
        dailyEarnings: 0,
        lastEarningReset: now,
      ));
      AppLogger.info('Daily earnings reset at midnight UTC');
    }
  }

  /// Update premium multiplier based on subscription status
  void updatePremiumMultiplier(bool hasPremium, bool hasBattlePass) {
    double multiplier;
    bool premiumBonus = hasPremium || hasBattlePass;

    if (hasPremium && hasBattlePass) {
      multiplier = 1.75; // Pro + Battle Pass
    } else if (hasPremium) {
      multiplier = 1.5; // Pro only
    } else if (hasBattlePass) {
      multiplier = 1.25; // Battle Pass only
    } else {
      multiplier = 1.0; // Free tier
    }

    emit(
      state.copyWith(
        earningMultiplier: multiplier,
        hasPremiumBonus: premiumBonus,
      ),
    );

    AppLogger.info('Updated coin earning multiplier to ${multiplier}x');
  }

  /// Earn coins from a specific source
  Future<bool> earnCoins(
    CoinEarningSource source, {
    int? customAmount,
    String? itemName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Check for daily reset
      _checkAndResetDailyEarnings();

      final baseAmount = customAmount ?? source.getBaseAmount();
      if (baseAmount <= 0) return true; // Skip if no coins to earn

      final multipliedAmount = (baseAmount * state.earningMultiplier).round();

      // Check daily earning cap (purchases bypass the cap)
      if (source != CoinEarningSource.purchase && _wouldExceedDailyCap(multipliedAmount)) {
        // Cap the amount to remaining daily allowance
        final cappedAmount = state.remainingDailyEarnings;
        if (cappedAmount <= 0) {
          AppLogger.info('Daily earning cap reached, no coins awarded');
          return false;
        }

        // Award capped amount
        return _processEarning(source, cappedAmount, itemName, metadata, wasCapped: true);
      }

      return _processEarning(source, multipliedAmount, itemName, metadata);
    } catch (e) {
      AppLogger.error('Error earning coins', e);
      return false;
    }
  }

  Future<bool> _processEarning(
    CoinEarningSource source,
    int amount,
    String? itemName,
    Map<String, dynamic>? metadata, {
    bool wasCapped = false,
  }) async {
    final transaction = CoinTransaction(
      id: _uuid.v4(),
      amount: amount,
      isEarned: true,
      earningSource: source,
      itemName: itemName,
      timestamp: DateTime.now(),
      metadata: {
        ...?metadata,
        if (wasCapped) 'capped': true,
      },
    );

    final newTransactions = [transaction, ...state.transactions];
    // Keep only recent transactions in memory (limit to 500)
    final limitedTransactions = newTransactions.take(500).toList();

    final newBalance = state.balance.copyWith(
      total: state.balance.total + amount,
      earned: state.balance.earned + amount,
      lastUpdated: DateTime.now(),
    );

    // Update daily earnings (purchases don't count toward cap)
    final newDailyEarnings = source != CoinEarningSource.purchase
        ? state.dailyEarnings + amount
        : state.dailyEarnings;

    emit(
      state.copyWith(
        balance: newBalance,
        transactions: limitedTransactions,
        dailyEarnings: newDailyEarnings,
      ),
    );

    await _saveData();

    // Route through StoreDao so the gain lands in Drift AND the sync
    // engine outbox — without this, every CoinsCubit.earnCoins call
    // stayed local-only (in-memory + SharedPreferences) and never
    // propagated to the backend. The dashboard's UserCoinBalance.Balance
    // therefore drifted behind whatever the Flutter user actually saw
    // (e.g. 800-coin gap when claim handlers credited server-side
    // User.Coins but the client-side optimistic credit never reached
    // the ledger). StoreDao.addCoins writes Drift + enqueues both
    // `coin_balance` snapshot and `coin_transaction` event syncs with
    // an idempotency key — the next SyncEngine tick PUSHes them.
    try {
      await StorageService().storeDao.addCoins(
        amount,
        source.name,
        description: itemName,
      );
    } catch (e) {
      // Local in-memory + SharedPreferences state was already updated
      // above; a Drift write failure shouldn't roll that back. Worst
      // case: this single gain doesn't reach the server until the
      // next opportunity (e.g. /auth/me pull bumps User.Coins, max
      // policy keeps the local value).
      AppLogger.warning(
        'CoinsCubit: Drift propagation failed for +$amount from ${source.name}: $e',
      );
    }

    AppLogger.info(
      'Earned $amount coins from ${source.displayName}${wasCapped ? ' (capped)' : ''}',
    );
    return true;
  }

  /// Set the coin balance to a server-authoritative value. Used after a
  /// backend mutation (e.g. coin-purchased power-up) returns the new
  /// total — keeps local state aligned with the server without a full
  /// sync round-trip. The delta is recorded as a `spent` adjustment when
  /// the server total is lower than local.
  Future<void> setServerBalance(int serverTotal) async {
    if (state.balance.total == serverTotal) return;
    final delta = state.balance.total - serverTotal;
    final newBalance = state.balance.copyWith(
      total: serverTotal,
      spent: delta > 0 ? state.balance.spent + delta : state.balance.spent,
      lastUpdated: DateTime.now(),
    );
    emit(state.copyWith(balance: newBalance));
    await _saveData();
  }

  /// Spend coins on an item
  Future<bool> spendCoins(
    int amount,
    CoinSpendingCategory category, {
    String? itemName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (state.balance.total < amount) {
        AppLogger.warning(
          'Insufficient coins: need $amount, have ${state.balance.total}',
        );
        return false;
      }

      final transaction = CoinTransaction(
        id: _uuid.v4(),
        amount: amount,
        isEarned: false,
        spendingCategory: category,
        itemName: itemName,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );

      final newTransactions = [transaction, ...state.transactions];
      final limitedTransactions = newTransactions.take(500).toList();

      final newBalance = state.balance.copyWith(
        total: state.balance.total - amount,
        spent: state.balance.spent + amount,
        lastUpdated: DateTime.now(),
      );

      emit(
        state.copyWith(balance: newBalance, transactions: limitedTransactions),
      );

      await _saveData();

      AppLogger.info(
        'Spent $amount coins on ${category.displayName}${itemName != null ? ': $itemName' : ''}',
      );
      return true;
    } catch (e) {
      AppLogger.error('Error spending coins', e);
      return false;
    }
  }

  /// Purchase coins with real money
  Future<bool> purchaseCoins(
    CoinPurchaseOption option,
    String transactionId,
  ) async {
    try {
      final totalCoins = option.totalCoins;

      final transaction = CoinTransaction(
        id: _uuid.v4(),
        amount: totalCoins,
        isEarned: true,
        earningSource: CoinEarningSource.purchase,
        itemName: option.name,
        timestamp: DateTime.now(),
        metadata: {
          'purchase_option_id': option.id,
          'transaction_id': transactionId,
          'base_coins': option.coins,
          'bonus_coins': option.bonusCoins,
          'price_usd': option.price,
        },
      );

      final newTransactions = [transaction, ...state.transactions];
      final limitedTransactions = newTransactions.take(500).toList();

      final newBalance = state.balance.copyWith(
        total: state.balance.total + totalCoins,
        purchased: state.balance.purchased + totalCoins,
        lastUpdated: DateTime.now(),
      );

      emit(
        state.copyWith(balance: newBalance, transactions: limitedTransactions),
      );

      await _saveData();

      AppLogger.info('Purchased $totalCoins coins via ${option.name}');
      return true;
    } catch (e) {
      AppLogger.error('Error purchasing coins', e);
      return false;
    }
  }

  /// Collect daily login bonus
  Future<bool> collectDailyBonus() async {
    try {
      final bonus = state.availableDailyBonus;
      if (bonus == null) {
        AppLogger.warning('No daily bonus available to collect');
        return false;
      }

      // Earn the coins
      final success = await earnCoins(
        CoinEarningSource.dailyLogin,
        customAmount: bonus.coins,
        itemName: 'Day ${bonus.day} Bonus',
        metadata: {'day': bonus.day, 'bonus_item': bonus.bonusItem},
      );

      if (success) {
        // Mark bonus as collected
        final updatedBonus = bonus.copyWith(
          isCollected: true,
          collectedAt: DateTime.now(),
        );

        final updatedBonuses = state.dailyBonuses.map((b) {
          return b.day == bonus.day ? updatedBonus : b;
        }).toList();

        emit(state.copyWith(dailyBonuses: updatedBonuses));
        await _saveData();

        // Persist claim date for frontend gate
        await _prefs?.setString(
          'last_daily_bonus_claim_date',
          DateTime.now().toIso8601String().substring(0, 10),
        );

        AppLogger.info(
          'Collected daily bonus: Day ${bonus.day} - ${bonus.coins} coins',
        );
        return true;
      }

      return false;
    } catch (e) {
      AppLogger.error('Error collecting daily bonus', e);
      return false;
    }
  }

  /// Get coins earned from a specific source today
  int getCoinsEarnedToday(CoinEarningSource source) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return state.transactions
        .where(
          (t) =>
              t.isEarned &&
              t.earningSource == source &&
              t.timestamp.isAfter(startOfDay),
        )
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Get spending by category this week
  Map<CoinSpendingCategory, int> getWeeklySpending() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));

    final weeklyTransactions = state.transactions.where(
      (t) => !t.isEarned && t.timestamp.isAfter(weekAgo),
    );

    final spending = <CoinSpendingCategory, int>{};

    for (final transaction in weeklyTransactions) {
      if (transaction.spendingCategory != null) {
        spending[transaction.spendingCategory!] =
            (spending[transaction.spendingCategory!] ?? 0) + transaction.amount;
      }
    }

    return spending;
  }

  /// Reset daily bonuses for a new week
  Future<void> resetDailyBonuses() async {
    try {
      emit(state.copyWith(dailyBonuses: DailyLoginBonus.getWeeklyBonuses()));
      await _saveData();

      AppLogger.info('Daily bonuses reset for new week');
    } catch (e) {
      AppLogger.error('Error resetting daily bonuses', e);
    }
  }

  /// Debug: Add coins (for testing)
  Future<void> debugAddCoins(int amount) async {
    if (amount <= 0) return;

    await earnCoins(
      CoinEarningSource.gameCompleted,
      customAmount: amount,
      itemName: 'Debug Addition',
      metadata: {'debug': true},
    );
  }

  /// Debug: Reset balance (for testing)
  Future<void> debugResetBalance() async {
    try {
      emit(CoinsState.initial().copyWith(status: CoinsStatus.ready));
      await _saveData();

      AppLogger.info('Coin balance reset to initial state');
    } catch (e) {
      AppLogger.error('Error resetting coin balance', e);
    }
  }

  /// Whether the daily bonus was already claimed today (calendar day)
  bool get wasDailyBonusClaimedToday {
    final lastClaim = _prefs?.getString('last_daily_bonus_claim_date');
    if (lastClaim == null) return false;
    final today = DateTime.now().toIso8601String().substring(0, 10);
    return lastClaim == today;
  }

  /// Check if user can afford a purchase
  bool canAfford(int amount) => state.balance.total >= amount;

  /// Get current balance
  int get balance => state.balance.total;

  /// Clear error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
