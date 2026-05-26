import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/data/database/app_database.dart' as db;
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/logger.dart';

import 'coins_state.dart';

export 'coins_state.dart';

/// Cubit for managing in-game coin economy.
///
/// **Storage model (offline-first, single source of truth per data point):**
/// the coin balance and transaction history live in Drift — the `Coins`
/// and `CoinTransactions` tables, owned by [StoreDao]. The SyncEngine
/// pushes both to the backend through the `coin_balance` and
/// `coin_transaction` outbox dataTypes. This cubit is a *read* layer
/// over Drift: every mutation routes through StoreDao, and the cubit
/// subscribes to Drift's watch streams to keep state in lock-step with
/// the database. The dashboard's `UserCoinBalance.Balance` and the
/// Flutter UI therefore can never disagree, because they're both
/// downstream of the same Drift row.
///
/// **SharedPreferences usage** is limited strictly to device-only state
/// that never leaves the install:
///   * `coin_daily_earnings` / `coin_last_earning_reset` — anti-grind
///     cap (resets at UTC midnight; a fresh device gets a fresh cap
///     by design).
///   * `coin_daily_bonuses` — which weekly login bonus has been
///     collected on this device. The COIN gain still lands in Drift
///     and syncs; only the "which day was claimed" picker is local.
///   * `last_daily_bonus_claim_date` — guards the home-screen claim
///     CTA on this device.
class CoinsCubit extends Cubit<CoinsState> {
  CoinsCubit() : super(CoinsState.initial());

  SharedPreferences? _prefs;

  StreamSubscription<db.Coin?>? _coinsRowWatch;
  StreamSubscription<List<db.CoinTransaction>>? _transactionsWatch;

  /// Tracks the in-flight initialize() call so concurrent callers
  /// (notably AuthCubit._firePostAuthSyncs → syncWithBackend) await
  /// the same completion instead of either short-circuiting on the
  /// status guard or starting a second parallel init. Without this,
  /// syncWithBackend ran against state.balance = CoinBalance.initial
  /// (50) before initialize had a chance to load Drift, and the sync
  /// log misreported "local=50, server=N (synced)" while overwriting
  /// Drift with the server value.
  Completer<void>? _initCompleter;

  // Device-only SharedPreferences keys. Any synced state moved to Drift.
  static const String _dailyEarningsKey = 'daily_earnings';
  static const String _lastEarningResetKey = 'last_earning_reset';
  static const String _dailyBonusesKey = 'daily_bonuses';
  static const String _lastBonusClaimDateKey = 'last_daily_bonus_claim_date';

  /// Retired SharedPreferences keys — the Drift-first refactor moves
  /// balance and transactions into Drift. Kept here so the one-shot
  /// migration in [initialize] can find any legacy data, fold it into
  /// Drift, and then remove the keys.
  static const String _legacyBalanceKey = 'coin_balance';
  static const String _legacyTransactionsKey = 'coin_transactions';

  /// Initialize the coins cubit
  Future<void> initialize() async {
    if (state.status == CoinsStatus.ready) return;
    // Coalesce a concurrent call onto the existing init future. Both
    // main.dart's BlocProvider.create and syncWithBackend's eager
    // await can land here in the same frame; without this guard the
    // second caller would also pass the status check (state is
    // "loading", not "ready") and run the full migration/seed/load
    // sequence in parallel.
    final inFlight = _initCompleter;
    if (inFlight != null) return inFlight.future;

    final completer = Completer<void>();
    _initCompleter = completer;

    emit(state.copyWith(status: CoinsStatus.loading));

    try {
      _prefs = await SharedPreferences.getInstance();

      // One-shot: any legacy SharedPreferences balance from the
      // dual-write era gets folded into Drift, then the retired keys
      // are cleared. After this runs once on a given install, Drift
      // is the sole owner of balance + transactions.
      await _migrateLegacySharedPreferencesToDrift();

      // Drift might be cold-empty (fresh install, no legacy SP either)
      // — seed the starting bonus through the canonical addCoins path
      // so the gain rides the outbox and the backend sees +50 on first
      // sync. Idempotent: skipped once Drift shows any activity.
      await _maybeSeedStartingBonus();

      await _loadFromDrift();
      _loadDeviceState();
      _wireDriftWatches();

      emit(state.copyWith(status: CoinsStatus.ready));
      AppLogger.info(
        'CoinsCubit initialized (Drift-first). Balance: ${state.balance.total}',
      );

      // Backend reconcile is no longer fired here — AuthCubit triggers
      // syncWithBackend after the user is authenticated and the JWT is
      // valid (see AuthCubit._firePostAuthSyncs). Firing here would race
      // with auth and consistently 401 on first launch.
      completer.complete();
    } catch (e) {
      AppLogger.error('Error initializing CoinsCubit', e);
      emit(
        state.copyWith(status: CoinsStatus.error, errorMessage: e.toString()),
      );
      completer.complete(); // Surface to awaiters; sync will skip via the
      // status guard if init failed.
    }
  }

  /// Pull `User.Coins` from the backend and reconcile with local balance.
  ///
  /// Strategy: take max(local, server). When server is ahead, write the
  /// new balance via [StoreDao.applyCoinBalanceSnapshot] — which skips
  /// the outbox so the server's number doesn't echo back as a push.
  /// The watch stream re-emits and the UI updates. Local-ahead is
  /// preserved; the next outbox drain will push the missing delta.
  Future<void> syncWithBackend() async {
    try {
      // Block on initialize() so state.balance reflects Drift, not the
      // CoinBalance.initial seed. AuthCubit._firePostAuthSyncs fires
      // this method as soon as auth resolves, which can land seconds
      // before the BlocProvider's init has loaded from Drift. Without
      // this await, local=50 races server=N and the wrong branch wins:
      // applyCoinBalanceSnapshot would overwrite Drift's real value
      // with the server's, AND the log would lie about the "before"
      // balance.
      await initialize();
      if (state.status != CoinsStatus.ready) return;

      final apiService = ApiService();
      if (!apiService.isAuthenticated) return;

      final data = await apiService.getCurrentUser();
      if (data == null) return;

      final serverCoins = (data['coins'] as int?) ?? 0;
      final localTotal = state.balance.total;

      if (serverCoins == localTotal) {
        AppLogger.info(
          'Coin sync: local=$localTotal, server=$serverCoins (in sync)',
        );
      } else if (serverCoins < localTotal) {
        // Local ahead — keep it; the next outbox drain will push the
        // missing delta to the server. Don't overwrite local with a
        // smaller server number.
        AppLogger.info(
          'Coin sync: local=$localTotal, server=$serverCoins '
          '(kept local; server is behind by ${localTotal - serverCoins} — '
          'next sync drain will push)',
        );
      } else {
        // Server is ahead → adopt it. Snapshot-apply skips the outbox
        // (the value came FROM the server, no need to push it back) but
        // still bumps Drift's updatedAt so subsequent local mutations
        // win on the next sync. The watchCoinBalanceRow stream picks up
        // the write and re-emits state — no manual emit here.
        final delta = serverCoins - localTotal;
        await StorageService().storeDao.applyCoinBalanceSnapshot(
              balance: serverCoins,
            );
        AppLogger.info(
          'Coin sync: local=$localTotal, server=$serverCoins (synced +$delta)',
        );
      }

      // Always force-reconcile the backend's UserCoinBalance mirror table
      // with the Drift balance we just settled on. The dashboard reads
      // UserCoinBalance (the client-mirror), but /auth/me returned
      // User.Coins (the canonical ledger) — and those two server-side
      // records can drift apart when a historical /sync push set
      // UserCoinBalance to a value the gameplay/claim handlers never
      // bumped User.Coins up to. Pushing once after every sync
      // guarantees the dashboard always reflects the value Flutter is
      // showing. The outbox is idempotent per drain cycle, so this
      // costs at most one HTTP push per auth cycle.
      await StorageService().storeDao.enqueueCoinBalanceSync();
    } catch (e) {
      AppLogger.error('Error syncing coins with backend', e);
    }
  }

  /// One-shot migration: fold any legacy SharedPreferences balance into
  /// Drift, then delete the retired keys. Safe to call on every launch
  /// — once the keys are gone the method is a no-op.
  Future<void> _migrateLegacySharedPreferencesToDrift() async {
    final prefs = _prefs;
    if (prefs == null) return;

    final legacyBalanceJson = prefs.getString(_legacyBalanceKey);
    if (legacyBalanceJson == null) {
      // Already migrated (or never had legacy data). Defensive cleanup
      // of the transactions key in case it was orphaned without the
      // balance key.
      if (prefs.containsKey(_legacyTransactionsKey)) {
        await prefs.remove(_legacyTransactionsKey);
      }
      return;
    }

    try {
      final storageService = StorageService();
      if (!storageService.isInitialized) return;

      final legacyBalance = CoinBalance.fromJson(
        json.decode(legacyBalanceJson),
      );
      final legacyTotal = legacyBalance.total;
      final driftRow = await storageService.storeDao.getCoinBalanceRow();
      final driftBalance = driftRow?.balance ?? 0;

      if (legacyTotal > driftBalance) {
        final delta = legacyTotal - driftBalance;
        AppLogger.info(
          'CoinsCubit: migrating legacy SharedPreferences balance to Drift '
          '(SP=$legacyTotal, Drift=$driftBalance, delta=+$delta). Outboxed '
          'as historical_backfill — next sync drain will reconcile backend.',
        );
        await storageService.storeDao.addCoins(
          delta,
          'historical_backfill',
          description: 'Reconcile of legacy SharedPreferences balance',
        );
      } else if (legacyTotal != driftBalance) {
        AppLogger.info(
          'CoinsCubit: legacy SharedPreferences balance ($legacyTotal) is '
          'behind Drift ($driftBalance) — no migration needed. Drift wins.',
        );
      }

      // Drop the retired keys regardless of delta direction — the
      // migration is complete and we don't want to read them again.
      await prefs.remove(_legacyBalanceKey);
      await prefs.remove(_legacyTransactionsKey);
    } catch (e) {
      AppLogger.warning(
        'CoinsCubit: legacy SharedPreferences migration failed (will retry '
        'on next launch since keys are still present): $e',
      );
    }
  }

  /// On a fresh install with no legacy SharedPreferences data and a
  /// virgin Drift coins row (balance=0, totalEarned=0), credit the
  /// starting bonus through the canonical [StoreDao.addCoins] path so
  /// the gain syncs to the backend like any other earn event.
  Future<void> _maybeSeedStartingBonus() async {
    final storageService = StorageService();
    if (!storageService.isInitialized) return;
    final row = await storageService.storeDao.getCoinBalanceRow();
    if (row == null) return;
    if (row.balance > 0 || row.totalEarned > 0) return;

    AppLogger.info('CoinsCubit: seeding +50 starting bonus to fresh Drift row');
    await storageService.storeDao.addCoins(
      50,
      'starting_bonus',
      description: 'Welcome bonus for new players',
    );
  }

  /// Hydrate state.balance + state.transactions from Drift.
  Future<void> _loadFromDrift() async {
    final storageService = StorageService();
    if (!storageService.isInitialized) return;

    final row = await storageService.storeDao.getCoinBalanceRow();
    final txns = await storageService.storeDao.getCoinTransactions(limit: 200);

    final balance = _balanceFromRow(row);
    final transactions = txns.map(_modelFromDriftTxn).toList();

    emit(state.copyWith(balance: balance, transactions: transactions));
  }

  /// Subscribe to Drift watches so any later write (snapshot apply,
  /// spend, debug reset, sync-engine restore) propagates into state
  /// without a manual refresh.
  void _wireDriftWatches() {
    final storageService = StorageService();
    if (!storageService.isInitialized) return;

    _coinsRowWatch?.cancel();
    _transactionsWatch?.cancel();

    _coinsRowWatch = storageService.storeDao.watchCoinBalanceRow().listen(
      (row) {
        final newBalance = _balanceFromRow(row);
        if (newBalance == state.balance) return;
        emit(state.copyWith(balance: newBalance));
      },
    );

    _transactionsWatch =
        storageService.storeDao.watchCoinTransactions(limit: 200).listen(
      (rows) {
        final modelTxns = rows.map(_modelFromDriftTxn).toList();
        emit(state.copyWith(transactions: modelTxns));
      },
    );
  }

  /// Build a [CoinBalance] from a Drift `Coins` row. Drift's `totalEarned`
  /// accumulates all credits (gameplay + purchases) so the model's
  /// separate `purchased` field is dropped to 0 — `earned` already
  /// represents lifetime gain. The `lifetime` derived getter and
  /// `spendingRatio` stay correct under this mapping.
  CoinBalance _balanceFromRow(db.Coin? row) {
    if (row == null) {
      return CoinBalance(
        total: 0,
        earned: 0,
        spent: 0,
        purchased: 0,
        lastUpdated: DateTime.now(),
      );
    }
    return CoinBalance(
      total: row.balance,
      earned: row.totalEarned,
      spent: row.totalSpent,
      purchased: 0,
      lastUpdated: row.lastUpdated,
    );
  }

  /// Convert a Drift `CoinTransactions` row into the in-memory display
  /// model. Sign convention: Drift stores spends as negative amounts
  /// (see [StoreDao.spendCoins]). The model's `isEarned` flag captures
  /// the direction explicitly, and `amount` is normalized to positive.
  CoinTransaction _modelFromDriftTxn(db.CoinTransaction txn) {
    final isEarned = txn.type == 'earned' || txn.amount > 0;
    final source = txn.source;

    CoinEarningSource? earningSource;
    CoinSpendingCategory? spendingCategory;
    if (isEarned) {
      earningSource = CoinEarningSource.values.firstWhere(
        (s) => s.name == source,
        orElse: () => CoinEarningSource.gameCompleted,
      );
    } else {
      spendingCategory = CoinSpendingCategory.values.firstWhere(
        (c) => c.name == source,
        orElse: () => CoinSpendingCategory.powerUps,
      );
    }

    return CoinTransaction(
      id: 'drift_${txn.id}',
      amount: txn.amount.abs(),
      isEarned: isEarned,
      earningSource: earningSource,
      spendingCategory: spendingCategory,
      itemName: txn.description,
      timestamp: txn.createdAt,
      metadata: const {},
    );
  }

  Future<void> _loadDeviceState() async {
    final prefs = _prefs;
    if (prefs == null) return;

    try {
      // Daily bonuses
      final bonusesJson = prefs.getStringList(_dailyBonusesKey) ?? [];
      List<DailyLoginBonus> dailyBonuses = DailyLoginBonus.getWeeklyBonuses();
      if (bonusesJson.isNotEmpty) {
        dailyBonuses = bonusesJson
            .map((jsonStr) => DailyLoginBonus.fromJson(json.decode(jsonStr)))
            .toList();
      }

      // Daily earning cap data
      final dailyEarnings = prefs.getInt(_dailyEarningsKey) ?? 0;
      final lastResetStr = prefs.getString(_lastEarningResetKey);
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
          dailyBonuses: dailyBonuses,
          dailyEarnings: shouldReset ? 0 : dailyEarnings,
          lastEarningReset: shouldReset ? now : lastEarningReset,
        ),
      );

      if (shouldReset) {
        await _saveDailyCapData();
      }
    } catch (e) {
      AppLogger.error('Error loading device-only coin state', e);
    }
  }

  Future<void> _saveDailyBonuses() async {
    final prefs = _prefs;
    if (prefs == null) return;
    final bonusesJson =
        state.dailyBonuses.map((b) => json.encode(b.toJson())).toList();
    await prefs.setStringList(_dailyBonusesKey, bonusesJson);
  }

  Future<void> _saveDailyCapData() async {
    final prefs = _prefs;
    if (prefs == null) return;
    await prefs.setInt(_dailyEarningsKey, state.dailyEarnings);
    await prefs.setString(
      _lastEarningResetKey,
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
    final resetDate =
        DateTime.utc(lastReset.year, lastReset.month, lastReset.day);
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
      _checkAndResetDailyEarnings();

      final baseAmount = customAmount ?? source.getBaseAmount();
      if (baseAmount <= 0) return true;

      final multipliedAmount = (baseAmount * state.earningMultiplier).round();

      // Cap-exempt sources: purchases (paid IAP, never grindable) and the
      // daily login bonus (a once-per-day engagement claim, not a grind
      // vector). If gameplay maxed out the cap earlier in the day, the
      // user should still get their daily bonus on first launch.
      final bypassesCap = source == CoinEarningSource.purchase ||
          source == CoinEarningSource.dailyLogin;
      if (!bypassesCap && _wouldExceedDailyCap(multipliedAmount)) {
        final cappedAmount = state.remainingDailyEarnings;
        if (cappedAmount <= 0) {
          AppLogger.info('Daily earning cap reached, no coins awarded');
          return false;
        }
        return _processEarning(source, cappedAmount, itemName, metadata,
            wasCapped: true);
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
    // Drift is the source of truth — writing here updates the balance
    // row + appends a CoinTransactions row + enqueues both for sync,
    // all inside a single transaction. The watch streams will re-emit
    // the new balance and the appended transaction, but we also pull a
    // fresh row synchronously below so any caller that snapshots
    // state.balance.earned before/after this call (see
    // GameCubit._earnAndTrack) observes the delta without waiting on
    // the async stream emission.
    try {
      await StorageService().storeDao.addCoins(
            amount,
            source.name,
            description: itemName,
          );
    } catch (e) {
      AppLogger.error(
        'CoinsCubit: addCoins failed for +$amount from ${source.name}',
        e,
      );
      return false;
    }

    // Synchronous state refresh from Drift — keeps the
    // "earnedBefore / earnedAfter" pattern in GameCubit working
    // regardless of when the watch stream fires.
    await _refreshBalanceFromDrift();

    // Daily cap counter is device-only. Cap-bypassing sources also don't
    // count toward the cap (consistent with the bypass check above).
    final countsTowardCap = source != CoinEarningSource.purchase &&
        source != CoinEarningSource.dailyLogin;
    if (countsTowardCap) {
      emit(state.copyWith(dailyEarnings: state.dailyEarnings + amount));
      await _saveDailyCapData();
    }

    AppLogger.info(
      'Earned $amount coins from ${source.displayName}'
      '${wasCapped ? ' (capped)' : ''}'
      '${metadata == null || metadata.isEmpty ? '' : ' meta=${metadata.keys.join(",")}'}',
    );
    return true;
  }

  /// Set the coin balance to a server-authoritative value. Used after a
  /// backend mutation (e.g. coin-purchased power-up) returns the new
  /// total. The snapshot-apply path skips the outbox because the value
  /// came from the server.
  Future<void> setServerBalance(int serverTotal) async {
    if (state.balance.total == serverTotal) return;
    await StorageService().storeDao.applyCoinBalanceSnapshot(
          balance: serverTotal,
        );
    // watchCoinBalanceRow fires and triggers the state refresh.
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

      final ok = await StorageService().storeDao.spendCoins(
            amount,
            category.name,
            description: itemName,
          );
      if (!ok) {
        AppLogger.warning('StoreDao.spendCoins refused — balance race');
        return false;
      }

      await _refreshBalanceFromDrift();

      AppLogger.info(
        'Spent $amount coins on ${category.displayName}'
        '${itemName != null ? ': $itemName' : ''}'
        '${metadata == null || metadata.isEmpty ? '' : ' meta=${metadata.keys.join(",")}'}',
      );
      return true;
    } catch (e) {
      AppLogger.error('Error spending coins', e);
      return false;
    }
  }

  /// Purchase coins with real money. Routes through the same Drift +
  /// outbox path as gameplay earnings, tagged with source='purchase'
  /// so the backend's coin ledger reflects the IAP credit.
  Future<bool> purchaseCoins(
    CoinPurchaseOption option,
    String transactionId,
  ) async {
    try {
      final totalCoins = option.totalCoins;
      final description =
          '${option.name} (txn: $transactionId, base: ${option.coins}, '
          'bonus: ${option.bonusCoins}, price: \$${option.price})';

      await StorageService().storeDao.addCoins(
            totalCoins,
            'purchase',
            description: description,
          );

      await _refreshBalanceFromDrift();

      AppLogger.info('Purchased $totalCoins coins via ${option.name}');
      return true;
    } catch (e) {
      AppLogger.error('Error purchasing coins', e);
      return false;
    }
  }

  Future<void> _refreshBalanceFromDrift() async {
    final storageService = StorageService();
    if (!storageService.isInitialized) return;
    final row = await storageService.storeDao.getCoinBalanceRow();
    final newBalance = _balanceFromRow(row);
    if (newBalance == state.balance) return;
    emit(state.copyWith(balance: newBalance));
  }

  /// Collect daily login bonus
  Future<bool> collectDailyBonus() async {
    try {
      final bonus = state.availableDailyBonus;
      if (bonus == null) {
        AppLogger.warning('No daily bonus available to collect');
        return false;
      }

      final success = await earnCoins(
        CoinEarningSource.dailyLogin,
        customAmount: bonus.coins,
        itemName: 'Day ${bonus.day} Bonus',
        metadata: {'day': bonus.day, 'bonus_item': bonus.bonusItem},
      );

      if (success) {
        final updatedBonus = bonus.copyWith(
          isCollected: true,
          collectedAt: DateTime.now(),
        );

        final updatedBonuses = state.dailyBonuses.map((b) {
          return b.day == bonus.day ? updatedBonus : b;
        }).toList();

        emit(state.copyWith(dailyBonuses: updatedBonuses));
        await _saveDailyBonuses();

        await _prefs?.setString(
          _lastBonusClaimDateKey,
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
      await _saveDailyBonuses();
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

  /// Debug: Reset balance (for testing). Wipes Drift balance + the
  /// device-only daily cap counter. Transactions are not retroactively
  /// erased because the backend still has them on the ledger.
  Future<void> debugResetBalance() async {
    try {
      await StorageService().storeDao.applyCoinBalanceSnapshot(balance: 0);
      await _refreshBalanceFromDrift();
      emit(state.copyWith(dailyEarnings: 0));
      await _saveDailyCapData();
      AppLogger.info('Coin balance reset to 0 (debug)');
    } catch (e) {
      AppLogger.error('Error resetting coin balance', e);
    }
  }

  /// Whether the daily bonus was already claimed today (calendar day)
  bool get wasDailyBonusClaimedToday {
    final lastClaim = _prefs?.getString(_lastBonusClaimDateKey);
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

  @override
  Future<void> close() async {
    await _coinsRowWatch?.cancel();
    await _transactionsWatch?.cancel();
    return super.close();
  }
}
