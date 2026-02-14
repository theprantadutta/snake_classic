import 'package:equatable/equatable.dart';
import 'package:snake_classic/utils/constants.dart';

/// Premium subscription tier
enum PremiumTier { free, pro }

/// Status of the premium cubit
enum PremiumStatus { initial, loading, ready, error }

/// Premium content definition
class PremiumContent {
  /// Themes that require premium or purchase to unlock
  static const Set<GameTheme> premiumThemes = {
    GameTheme.space,
    GameTheme.ocean,
    GameTheme.cyberpunk,
    GameTheme.forest,
    GameTheme.desert,
    GameTheme.crystal,
  };

  /// Check if a theme requires premium
  static bool isPremiumTheme(GameTheme theme) => premiumThemes.contains(theme);
}

/// State class for PremiumCubit
class PremiumState extends Equatable {
  final PremiumStatus status;
  final PremiumTier tier;
  final DateTime? subscriptionExpiry;
  final bool isOnTrial;
  final DateTime? trialEndDate;
  final DateTime? trialStartDate;
  final Set<GameTheme> ownedThemes;
  final Set<String> ownedSkins;
  final Set<String> ownedTrails;
  final Set<String> ownedPowerUps;
  final Set<String> ownedBoardSizes;
  final Set<String> ownedBundles;
  final String selectedSkinId;
  final String selectedTrailId;
  final String? errorMessage;

  // Tournament entries
  final int bronzeTournamentEntries;
  final int silverTournamentEntries;
  final int goldTournamentEntries;

  // Battle pass
  final bool hasBattlePass;
  final int battlePassTier;

  const PremiumState({
    this.status = PremiumStatus.initial,
    this.tier = PremiumTier.free,
    this.subscriptionExpiry,
    this.isOnTrial = false,
    this.trialEndDate,
    this.trialStartDate,
    this.ownedThemes = const {},
    this.ownedSkins = const {},
    this.ownedTrails = const {},
    this.ownedPowerUps = const {},
    this.ownedBoardSizes = const {},
    this.ownedBundles = const {},
    this.selectedSkinId = 'classic',
    this.selectedTrailId = 'none',
    this.errorMessage,
    this.bronzeTournamentEntries = 0,
    this.silverTournamentEntries = 0,
    this.goldTournamentEntries = 0,
    this.hasBattlePass = false,
    this.battlePassTier = 0,
  });

  /// Initial state
  factory PremiumState.initial() => const PremiumState();

  /// Create a copy with updated values
  PremiumState copyWith({
    PremiumStatus? status,
    PremiumTier? tier,
    DateTime? subscriptionExpiry,
    bool? isOnTrial,
    DateTime? trialEndDate,
    DateTime? trialStartDate,
    Set<GameTheme>? ownedThemes,
    Set<String>? ownedSkins,
    Set<String>? ownedTrails,
    Set<String>? ownedPowerUps,
    Set<String>? ownedBoardSizes,
    Set<String>? ownedBundles,
    String? selectedSkinId,
    String? selectedTrailId,
    String? errorMessage,
    bool clearError = false,
    int? bronzeTournamentEntries,
    int? silverTournamentEntries,
    int? goldTournamentEntries,
    bool? hasBattlePass,
    int? battlePassTier,
  }) {
    return PremiumState(
      status: status ?? this.status,
      tier: tier ?? this.tier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      isOnTrial: isOnTrial ?? this.isOnTrial,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      ownedThemes: ownedThemes ?? this.ownedThemes,
      ownedSkins: ownedSkins ?? this.ownedSkins,
      ownedTrails: ownedTrails ?? this.ownedTrails,
      ownedPowerUps: ownedPowerUps ?? this.ownedPowerUps,
      ownedBoardSizes: ownedBoardSizes ?? this.ownedBoardSizes,
      ownedBundles: ownedBundles ?? this.ownedBundles,
      selectedSkinId: selectedSkinId ?? this.selectedSkinId,
      selectedTrailId: selectedTrailId ?? this.selectedTrailId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      bronzeTournamentEntries:
          bronzeTournamentEntries ?? this.bronzeTournamentEntries,
      silverTournamentEntries:
          silverTournamentEntries ?? this.silverTournamentEntries,
      goldTournamentEntries:
          goldTournamentEntries ?? this.goldTournamentEntries,
      hasBattlePass: hasBattlePass ?? this.hasBattlePass,
      battlePassTier: battlePassTier ?? this.battlePassTier,
    );
  }

  /// Whether the premium cubit is initialized
  bool get isInitialized => status == PremiumStatus.ready;

  /// Whether user has active premium
  bool get hasPremium {
    if (tier == PremiumTier.pro && !isSubscriptionExpired) return true;
    if (isOnTrial && !isTrialExpired) return true;
    return false;
  }

  /// Whether subscription is expired
  bool get isSubscriptionExpired {
    if (subscriptionExpiry == null) return true;
    return DateTime.now().isAfter(subscriptionExpiry!);
  }

  /// Whether trial is expired
  bool get isTrialExpired {
    if (trialEndDate == null) return true;
    return DateTime.now().isAfter(trialEndDate!);
  }

  /// Check if a theme is owned
  bool isThemeOwned(GameTheme theme) => ownedThemes.contains(theme);

  /// Check if a theme is unlocked (free themes always unlocked, premium needs purchase or subscription)
  bool isThemeUnlocked(GameTheme theme) =>
      !PremiumContent.isPremiumTheme(theme) || hasPremium || ownedThemes.contains(theme);

  /// Check if a skin is owned
  bool isSkinOwned(String skinId) => ownedSkins.contains(skinId);

  /// Check if a trail is owned
  bool isTrailOwned(String trailId) => ownedTrails.contains(trailId);

  /// Check if a power-up is unlocked
  bool isPowerUpUnlocked(String powerUpId) => ownedPowerUps.contains(powerUpId);

  /// Check if a board size is unlocked
  bool isBoardSizeUnlocked(String boardSizeId) {
    final boardSize = GameConstants.availableBoardSizes
        .where((b) => b.id == boardSizeId)
        .firstOrNull;
    if (boardSize == null) return false;
    return !boardSize.isPremium || hasPremium || ownedBoardSizes.contains(boardSizeId);
  }

  /// Check if a bundle is owned
  bool isBundleOwned(String bundleId) => ownedBundles.contains(bundleId);

  /// Whether user has used trial before
  bool get hasUsedTrial => trialStartDate != null;

  /// Time remaining on trial
  Duration? get trialTimeRemaining {
    if (!isOnTrial || trialEndDate == null) return null;
    final remaining = trialEndDate!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Check if user has tournament entry
  bool hasTournamentEntry(String tournamentType) {
    switch (tournamentType.toLowerCase()) {
      case 'bronze':
        return bronzeTournamentEntries > 0;
      case 'silver':
        return silverTournamentEntries > 0;
      case 'gold':
        return goldTournamentEntries > 0;
      default:
        return false;
    }
  }

  /// Get tournament entry count
  int getTournamentEntryCount(String tournamentType) {
    switch (tournamentType.toLowerCase()) {
      case 'bronze':
        return bronzeTournamentEntries;
      case 'silver':
        return silverTournamentEntries;
      case 'gold':
        return goldTournamentEntries;
      default:
        return 0;
    }
  }

  @override
  List<Object?> get props => [
    status,
    tier,
    subscriptionExpiry,
    isOnTrial,
    trialEndDate,
    trialStartDate,
    ownedThemes,
    ownedSkins,
    ownedTrails,
    ownedPowerUps,
    ownedBoardSizes,
    ownedBundles,
    selectedSkinId,
    selectedTrailId,
    errorMessage,
    bronzeTournamentEntries,
    silverTournamentEntries,
    goldTournamentEntries,
    hasBattlePass,
    battlePassTier,
  ];
}
