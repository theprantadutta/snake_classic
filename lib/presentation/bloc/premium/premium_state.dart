import 'package:equatable/equatable.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/services/purchase_service.dart' show ProductIds;
import 'package:snake_classic/utils/constants.dart';

/// Premium subscription tier
enum PremiumTier { free, pro }

/// Which Pro plan the account is actually on.
///
/// [PremiumTier] answers "is this user Pro"; this answers "on what". The two
/// are separate because a promo grant makes someone Pro with no plan at all,
/// and the premium screen has to tell those cases apart to know what to offer.
enum PremiumPlan {
  /// No paid subscription — a free user, or one on a server-side promo.
  none,
  monthly,
  yearly,
}

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

  /// Store product id of the active subscription, or null when there is no
  /// paid plan (free, or Pro via promo). Sourced from the Play/StoreKit
  /// purchase the store reports as owned — the client never guesses it.
  final String? activeSubscriptionId;
  final Set<GameTheme> ownedThemes;
  final Set<String> ownedSkins;
  final Set<String> ownedTrails;
  final Set<String> ownedPowerUps;
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

  // Server-side promo (welcome bonus / app-wide giveaway). When `isOnPromo`
  // is true the user has Pro for free until `promoExpiresAt`; revocation is
  // handled server-side by the ExpirePromosJob.
  final bool isOnPromo;
  final DateTime? promoExpiresAt;
  final String? promoSource;

  const PremiumState({
    this.status = PremiumStatus.initial,
    this.tier = PremiumTier.free,
    this.subscriptionExpiry,
    this.activeSubscriptionId,
    this.ownedThemes = const {},
    this.ownedSkins = const {},
    this.ownedTrails = const {},
    this.ownedPowerUps = const {},
    this.ownedBundles = const {},
    this.selectedSkinId = 'classic',
    this.selectedTrailId = 'none',
    this.errorMessage,
    this.bronzeTournamentEntries = 0,
    this.silverTournamentEntries = 0,
    this.goldTournamentEntries = 0,
    this.hasBattlePass = false,
    this.battlePassTier = 0,
    this.isOnPromo = false,
    this.promoExpiresAt,
    this.promoSource,
  });

  /// Initial state
  factory PremiumState.initial() => const PremiumState();

  /// Create a copy with updated values
  PremiumState copyWith({
    PremiumStatus? status,
    PremiumTier? tier,
    DateTime? subscriptionExpiry,
    String? activeSubscriptionId,
    bool clearActiveSubscriptionId = false,
    Set<GameTheme>? ownedThemes,
    Set<String>? ownedSkins,
    Set<String>? ownedTrails,
    Set<String>? ownedPowerUps,
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
    bool? isOnPromo,
    DateTime? promoExpiresAt,
    String? promoSource,
    bool clearPromo = false,
  }) {
    return PremiumState(
      status: status ?? this.status,
      tier: tier ?? this.tier,
      subscriptionExpiry: subscriptionExpiry ?? this.subscriptionExpiry,
      activeSubscriptionId: clearActiveSubscriptionId
          ? null
          : (activeSubscriptionId ?? this.activeSubscriptionId),
      ownedThemes: ownedThemes ?? this.ownedThemes,
      ownedSkins: ownedSkins ?? this.ownedSkins,
      ownedTrails: ownedTrails ?? this.ownedTrails,
      ownedPowerUps: ownedPowerUps ?? this.ownedPowerUps,
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
      isOnPromo: clearPromo ? false : (isOnPromo ?? this.isOnPromo),
      promoExpiresAt:
          clearPromo ? null : (promoExpiresAt ?? this.promoExpiresAt),
      promoSource: clearPromo ? null : (promoSource ?? this.promoSource),
    );
  }

  /// Whether the premium cubit is initialized
  bool get isInitialized => status == PremiumStatus.ready;

  /// Whether user has active premium
  bool get hasPremium {
    return tier == PremiumTier.pro && !isSubscriptionExpired;
  }

  /// Which paid plan is active. [PremiumPlan.none] for free users AND for Pro
  /// granted by promo — a promo has nothing to switch away from.
  PremiumPlan get plan {
    switch (activeSubscriptionId) {
      case ProductIds.snakeClassicProMonthly:
        return PremiumPlan.monthly;
      case ProductIds.snakeClassicProYearly:
        return PremiumPlan.yearly;
      default:
        return PremiumPlan.none;
    }
  }

  /// True when the user pays for Pro (as opposed to holding it on a promo).
  /// Only a paying subscriber can switch plans.
  bool get hasPaidSubscription => hasPremium && plan != PremiumPlan.none;

  /// The plan a switch would move to, or null when switching is not offered.
  PremiumPlan? get switchTarget {
    switch (plan) {
      case PremiumPlan.monthly:
        return PremiumPlan.yearly;
      case PremiumPlan.yearly:
        return PremiumPlan.monthly;
      case PremiumPlan.none:
        return null;
    }
  }

  /// Switching to yearly is an upgrade: it takes effect immediately and the
  /// unused month is credited. Switching to monthly is a downgrade and waits
  /// for the paid period to end. The premium screen says which, so the user
  /// knows before tapping whether money moves today.
  bool get switchTakesEffectImmediately => switchTarget == PremiumPlan.yearly;

  /// Whether subscription is expired
  bool get isSubscriptionExpired {
    if (subscriptionExpiry == null) return true;
    return DateTime.now().isAfter(subscriptionExpiry!);
  }

  /// Check if a theme is owned
  bool isThemeOwned(GameTheme theme) => ownedThemes.contains(theme);

  /// Check if a theme is unlocked (free themes always unlocked, premium needs purchase or subscription)
  bool isThemeUnlocked(GameTheme theme) =>
      !PremiumContent.isPremiumTheme(theme) || hasPremium || ownedThemes.contains(theme);

  /// Check if a skin is owned. Strict set-membership only — used by the
  /// purchase-pending reconciler (`_isProductOwned`) where we need to know
  /// whether the IAP grant has landed, independent of Pro status.
  bool isSkinOwned(String skinId) => ownedSkins.contains(skinId);

  /// Check if a trail is owned. Same strict-set semantics as [isSkinOwned].
  bool isTrailOwned(String trailId) => ownedTrails.contains(trailId);

  /// Check if a skin is usable by the player — free skins always are; premium
  /// skins unlock either through individual purchase OR an active Pro
  /// subscription (Pro bundles all premium cosmetics, mirroring the theme
  /// fast-path). Use this in UI gating (store equip buttons, paint logic).
  bool isSkinUnlocked(SnakeSkinType skin) =>
      !skin.isPremium || hasPremium || ownedSkins.contains(skin.id);

  /// Check if a trail is usable by the player. Same Pro-bundle fast-path
  /// as [isSkinUnlocked].
  bool isTrailUnlocked(TrailEffectType trail) =>
      !trail.isPremium || hasPremium || ownedTrails.contains(trail.id);

  /// Check if a power-up is unlocked
  bool isPowerUpUnlocked(String powerUpId) => ownedPowerUps.contains(powerUpId);

  /// Check if a bundle is owned
  bool isBundleOwned(String bundleId) => ownedBundles.contains(bundleId);

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
    activeSubscriptionId,
    ownedThemes,
    ownedSkins,
    ownedTrails,
    ownedPowerUps,
    ownedBundles,
    selectedSkinId,
    selectedTrailId,
    errorMessage,
    bronzeTournamentEntries,
    silverTournamentEntries,
    goldTournamentEntries,
    hasBattlePass,
    battlePassTier,
    isOnPromo,
    promoExpiresAt,
    promoSource,
  ];
}
