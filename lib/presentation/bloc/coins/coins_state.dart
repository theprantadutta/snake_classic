import 'package:equatable/equatable.dart';
import 'package:snake_classic/models/snake_coins.dart';

/// Status of the coins cubit
enum CoinsStatus {
  initial,
  loading,
  ready,
  error,
}

/// State class for CoinsCubit
class CoinsState extends Equatable {
  final CoinsStatus status;
  final CoinBalance balance;
  final List<CoinTransaction> transactions;
  final List<DailyLoginBonus> dailyBonuses;
  final double earningMultiplier;
  final bool hasPremiumBonus;
  final String? errorMessage;

  const CoinsState({
    this.status = CoinsStatus.initial,
    required this.balance,
    this.transactions = const [],
    this.dailyBonuses = const [],
    this.earningMultiplier = 1.0,
    this.hasPremiumBonus = false,
    this.errorMessage,
  });

  /// Initial state
  factory CoinsState.initial() => CoinsState(
        balance: CoinBalance.initial,
        dailyBonuses: DailyLoginBonus.getWeeklyBonuses(),
      );

  /// Create a copy with updated values
  CoinsState copyWith({
    CoinsStatus? status,
    CoinBalance? balance,
    List<CoinTransaction>? transactions,
    List<DailyLoginBonus>? dailyBonuses,
    double? earningMultiplier,
    bool? hasPremiumBonus,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CoinsState(
      status: status ?? this.status,
      balance: balance ?? this.balance,
      transactions: transactions ?? this.transactions,
      dailyBonuses: dailyBonuses ?? this.dailyBonuses,
      earningMultiplier: earningMultiplier ?? this.earningMultiplier,
      hasPremiumBonus: hasPremiumBonus ?? this.hasPremiumBonus,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Whether the coins system is ready
  bool get isReady => status == CoinsStatus.ready;

  /// Total coin balance
  int get total => balance.total;

  /// Recent transactions (last 50)
  List<CoinTransaction> get recentTransactions =>
      transactions.take(50).toList();

  /// Today's earnings
  int get todaysEarnings {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    return transactions
        .where((t) => t.isEarned && t.timestamp.isAfter(startOfDay))
        .fold(0, (sum, t) => sum + t.amount);
  }

  /// Check if user can collect daily login bonus
  bool get canCollectDailyBonus {
    return dailyBonuses.any((bonus) => bonus.isAvailable && !bonus.isCollected);
  }

  /// Get available daily bonus
  DailyLoginBonus? get availableDailyBonus {
    return dailyBonuses
        .where((bonus) => bonus.isAvailable && !bonus.isCollected)
        .firstOrNull;
  }

  /// Check if user can afford a specific amount
  bool canAfford(int amount) => balance.total >= amount;

  @override
  List<Object?> get props => [
        status,
        balance,
        transactions,
        dailyBonuses,
        earningMultiplier,
        hasPremiumBonus,
        errorMessage,
      ];
}
