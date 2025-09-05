import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/snake_coins.dart';
import '../utils/logger.dart';

class CoinsProvider extends ChangeNotifier {
  static final CoinsProvider _instance = CoinsProvider._internal();
  factory CoinsProvider() => _instance;
  CoinsProvider._internal();

  CoinBalance _balance = CoinBalance.initial;
  List<CoinTransaction> _transactions = [];
  List<DailyLoginBonus> _dailyBonuses = DailyLoginBonus.getWeeklyBonuses();
  bool _isInitialized = false;
  final Uuid _uuid = const Uuid();

  // Premium multipliers
  double _earningMultiplier = 1.0;
  bool _hasPremiumBonus = false;

  // Getters
  CoinBalance get balance => _balance;
  List<CoinTransaction> get transactions => List.unmodifiable(_transactions);
  List<DailyLoginBonus> get dailyBonuses => List.unmodifiable(_dailyBonuses);
  bool get isInitialized => _isInitialized;
  double get earningMultiplier => _earningMultiplier;
  bool get hasPremiumBonus => _hasPremiumBonus;
  
  // Recent transactions (last 50)
  List<CoinTransaction> get recentTransactions => _transactions.take(50).toList();
  
  // Today's earnings
  int get todaysEarnings {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return _transactions
        .where((t) => t.isEarned && t.timestamp.isAfter(startOfDay))
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Check if user can collect daily login bonus
  bool get canCollectDailyBonus {
    return _dailyBonuses.any((bonus) => bonus.isAvailable && !bonus.isCollected);
  }

  // Get available daily bonus
  DailyLoginBonus? get availableDailyBonus {
    return _dailyBonuses.where((bonus) => bonus.isAvailable && !bonus.isCollected).firstOrNull;
  }

  Future<void> initialize() async {
    try {
      AppLogger.info('Initializing Coins Provider...');
      
      await _loadData();
      _isInitialized = true;
      notifyListeners();
      
      AppLogger.info('Coins Provider initialized successfully');
      AppLogger.info('Current balance: ${_balance.total} coins');
    } catch (e) {
      AppLogger.error('Error initializing Coins Provider', e);
    }
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load balance
      final balanceJson = prefs.getString('coin_balance');
      if (balanceJson != null) {
        _balance = CoinBalance.fromJson(json.decode(balanceJson));
      }
      
      // Load transactions
      final transactionsJson = prefs.getStringList('coin_transactions') ?? [];
      _transactions = transactionsJson
          .map((jsonStr) => CoinTransaction.fromJson(json.decode(jsonStr)))
          .toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp)); // Most recent first
      
      // Load daily bonuses
      final bonusesJson = prefs.getStringList('daily_bonuses') ?? [];
      if (bonusesJson.isNotEmpty) {
        _dailyBonuses = bonusesJson
            .map((jsonStr) => DailyLoginBonus.fromJson(json.decode(jsonStr)))
            .toList();
      }
      
      AppLogger.info('Coin data loaded successfully');
    } catch (e) {
      AppLogger.error('Error loading coin data', e);
    }
  }

  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save balance
      await prefs.setString('coin_balance', json.encode(_balance.toJson()));
      
      // Save recent transactions (limit to last 200 for storage efficiency)
      final recentTransactions = _transactions.take(200).toList();
      final transactionsJson = recentTransactions
          .map((t) => json.encode(t.toJson()))
          .toList();
      await prefs.setStringList('coin_transactions', transactionsJson);
      
      // Save daily bonuses
      final bonusesJson = _dailyBonuses
          .map((b) => json.encode(b.toJson()))
          .toList();
      await prefs.setStringList('daily_bonuses', bonusesJson);
      
    } catch (e) {
      AppLogger.error('Error saving coin data', e);
    }
  }

  void updatePremiumMultiplier(bool hasPremium, bool hasBattlePass) {
    _hasPremiumBonus = hasPremium || hasBattlePass;
    
    if (hasPremium && hasBattlePass) {
      _earningMultiplier = 2.5; // Pro + Battle Pass
    } else if (hasPremium) {
      _earningMultiplier = 2.0; // Pro only
    } else if (hasBattlePass) {
      _earningMultiplier = 1.5; // Battle Pass only
    } else {
      _earningMultiplier = 1.0; // Free tier
    }
    
    AppLogger.info('Updated coin earning multiplier to ${_earningMultiplier}x');
    notifyListeners();
  }

  Future<bool> earnCoins(
    CoinEarningSource source, {
    int? customAmount,
    String? itemName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final baseAmount = customAmount ?? source.getBaseAmount();
      final multipliedAmount = (baseAmount * _earningMultiplier).round();
      
      final transaction = CoinTransaction(
        id: _uuid.v4(),
        amount: multipliedAmount,
        isEarned: true,
        earningSource: source,
        itemName: itemName,
        timestamp: DateTime.now(),
        metadata: metadata ?? {},
      );
      
      _addTransaction(transaction);
      
      final newBalance = _balance.copyWith(
        total: _balance.total + multipliedAmount,
        earned: _balance.earned + multipliedAmount,
        lastUpdated: DateTime.now(),
      );
      
      _balance = newBalance;
      await _saveData();
      notifyListeners();
      
      AppLogger.info('Earned $multipliedAmount coins from ${source.displayName}');
      return true;
    } catch (e) {
      AppLogger.error('Error earning coins', e);
      return false;
    }
  }

  Future<bool> spendCoins(
    int amount,
    CoinSpendingCategory category, {
    String? itemName,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_balance.total < amount) {
        AppLogger.warning('Insufficient coins: need $amount, have ${_balance.total}');
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
      
      _addTransaction(transaction);
      
      final newBalance = _balance.copyWith(
        total: _balance.total - amount,
        spent: _balance.spent + amount,
        lastUpdated: DateTime.now(),
      );
      
      _balance = newBalance;
      await _saveData();
      notifyListeners();
      
      AppLogger.info('Spent $amount coins on ${category.displayName}${itemName != null ? ': $itemName' : ''}');
      return true;
    } catch (e) {
      AppLogger.error('Error spending coins', e);
      return false;
    }
  }

  Future<bool> purchaseCoins(CoinPurchaseOption option, String transactionId) async {
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
      
      _addTransaction(transaction);
      
      final newBalance = _balance.copyWith(
        total: _balance.total + totalCoins,
        purchased: _balance.purchased + totalCoins,
        lastUpdated: DateTime.now(),
      );
      
      _balance = newBalance;
      await _saveData();
      notifyListeners();
      
      AppLogger.info('Purchased $totalCoins coins via ${option.name}');
      return true;
    } catch (e) {
      AppLogger.error('Error purchasing coins', e);
      return false;
    }
  }

  Future<bool> collectDailyBonus() async {
    try {
      final bonus = availableDailyBonus;
      if (bonus == null) {
        AppLogger.warning('No daily bonus available to collect');
        return false;
      }
      
      // Earn the coins
      final success = await earnCoins(
        CoinEarningSource.dailyLogin,
        customAmount: bonus.coins,
        itemName: 'Day ${bonus.day} Bonus',
        metadata: {
          'day': bonus.day,
          'bonus_item': bonus.bonusItem,
        },
      );
      
      if (success) {
        // Mark bonus as collected
        final updatedBonus = bonus.copyWith(
          isCollected: true,
          collectedAt: DateTime.now(),
        );
        
        final bonusIndex = _dailyBonuses.indexWhere((b) => b.day == bonus.day);
        if (bonusIndex >= 0) {
          _dailyBonuses[bonusIndex] = updatedBonus;
        }
        
        await _saveData();
        notifyListeners();
        
        AppLogger.info('Collected daily bonus: Day ${bonus.day} - ${bonus.coins} coins');
        return true;
      }
      
      return false;
    } catch (e) {
      AppLogger.error('Error collecting daily bonus', e);
      return false;
    }
  }

  void _addTransaction(CoinTransaction transaction) {
    _transactions.insert(0, transaction);
    
    // Keep only recent transactions in memory (limit to 500)
    if (_transactions.length > 500) {
      _transactions = _transactions.take(500).toList();
    }
  }

  bool canAfford(int amount) {
    return _balance.total >= amount;
  }

  // Get coins earned from specific source today
  int getCoinsEarnedToday(CoinEarningSource source) {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    
    return _transactions
        .where((t) => 
            t.isEarned && 
            t.earningSource == source && 
            t.timestamp.isAfter(startOfDay))
        .fold(0, (sum, t) => sum + t.amount);
  }

  // Get spending by category this week
  Map<CoinSpendingCategory, int> getWeeklySpending() {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    final weeklyTransactions = _transactions
        .where((t) => !t.isEarned && t.timestamp.isAfter(weekAgo));
    
    final spending = <CoinSpendingCategory, int>{};
    
    for (final transaction in weeklyTransactions) {
      if (transaction.spendingCategory != null) {
        spending[transaction.spendingCategory!] = 
            (spending[transaction.spendingCategory!] ?? 0) + transaction.amount;
      }
    }
    
    return spending;
  }

  // Reset daily bonuses (called when a new week starts)
  Future<void> resetDailyBonuses() async {
    try {
      _dailyBonuses = DailyLoginBonus.getWeeklyBonuses();
      await _saveData();
      notifyListeners();
      
      AppLogger.info('Daily bonuses reset for new week');
    } catch (e) {
      AppLogger.error('Error resetting daily bonuses', e);
    }
  }

  // Admin/debug methods
  Future<void> debugAddCoins(int amount) async {
    if (amount <= 0) return;
    
    await earnCoins(
      CoinEarningSource.gameCompleted,
      customAmount: amount,
      itemName: 'Debug Addition',
      metadata: {'debug': true},
    );
  }

  Future<void> debugResetBalance() async {
    try {
      _balance = CoinBalance.initial;
      _transactions.clear();
      _dailyBonuses = DailyLoginBonus.getWeeklyBonuses();
      
      await _saveData();
      notifyListeners();
      
      AppLogger.info('Coin balance reset to initial state');
    } catch (e) {
      AppLogger.error('Error resetting coin balance', e);
    }
  }

  @override
  void dispose() {
    // No subscriptions to cancel, but included for completeness
    super.dispose();
  }
}