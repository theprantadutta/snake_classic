import 'package:equatable/equatable.dart';

/// Status of the battle pass cubit
enum BattlePassStatus { initial, loading, ready, error }

/// Battle pass reward tier
enum RewardTier { free, premium }

/// State class for BattlePassCubit
class BattlePassState extends Equatable {
  final BattlePassStatus status;
  final bool isActive;
  final int currentTier;
  final int currentXP;
  final int xpForNextTier;
  final DateTime? expiryDate;
  final Set<int> claimedFreeTiers;
  final Set<int> claimedPremiumTiers;
  final String? errorMessage;
  final String seasonName;

  const BattlePassState({
    this.status = BattlePassStatus.initial,
    this.isActive = false,
    this.currentTier = 0,
    this.currentXP = 0,
    this.xpForNextTier = 100,
    this.expiryDate,
    this.claimedFreeTiers = const {},
    this.claimedPremiumTiers = const {},
    this.errorMessage,
    this.seasonName = 'Season 1',
  });

  /// Initial state
  factory BattlePassState.initial() => const BattlePassState();

  /// Create a copy with updated values
  BattlePassState copyWith({
    BattlePassStatus? status,
    bool? isActive,
    int? currentTier,
    int? currentXP,
    int? xpForNextTier,
    DateTime? expiryDate,
    Set<int>? claimedFreeTiers,
    Set<int>? claimedPremiumTiers,
    String? errorMessage,
    bool clearError = false,
    String? seasonName,
  }) {
    return BattlePassState(
      status: status ?? this.status,
      isActive: isActive ?? this.isActive,
      currentTier: currentTier ?? this.currentTier,
      currentXP: currentXP ?? this.currentXP,
      xpForNextTier: xpForNextTier ?? this.xpForNextTier,
      expiryDate: expiryDate ?? this.expiryDate,
      claimedFreeTiers: claimedFreeTiers ?? this.claimedFreeTiers,
      claimedPremiumTiers: claimedPremiumTiers ?? this.claimedPremiumTiers,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      seasonName: seasonName ?? this.seasonName,
    );
  }

  /// Whether battle pass is expired
  bool get isExpired {
    if (expiryDate == null) return true;
    return DateTime.now().isAfter(expiryDate!);
  }

  /// Whether battle pass is valid (active and not expired)
  bool get isValid => isActive && !isExpired;

  /// Progress to next tier (0.0 to 1.0)
  double get tierProgress {
    if (xpForNextTier <= 0) return 1.0;
    return (currentXP / xpForNextTier).clamp(0.0, 1.0);
  }

  /// Check if a free tier reward is claimed
  bool isFreeTierClaimed(int tier) => claimedFreeTiers.contains(tier);

  /// Check if a premium tier reward is claimed
  bool isPremiumTierClaimed(int tier) => claimedPremiumTiers.contains(tier);

  /// Maximum tier level
  static const int maxTier = 100;

  /// XP required per tier (can be customized)
  int xpRequiredForTier(int tier) {
    // Base: 100 XP, increasing by 50 per tier
    return 100 + (tier * 50);
  }

  @override
  List<Object?> get props => [
    status,
    isActive,
    currentTier,
    currentXP,
    xpForNextTier,
    expiryDate,
    claimedFreeTiers,
    claimedPremiumTiers,
    errorMessage,
    seasonName,
  ];
}
