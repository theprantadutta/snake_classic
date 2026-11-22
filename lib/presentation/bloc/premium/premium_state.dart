import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:snake_classic/models/coin_cosmetic.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/models/season_cosmetics.dart';
import 'package:snake_classic/models/temporary_grant.dart';
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

  /// Premium themes sold on their own and included with Pro, but NOT part
  /// of the "all 6 premium themes" bundle (bundle buyers paid for six).
  /// Kept out of [premiumThemes] because the bundle grant loops over it.
  /// Backend mirror: ProductCatalog.Themes has it, BundleThemes doesn't.
  static const Set<GameTheme> nonBundleThemes = {GameTheme.miamiNights};

  /// Every premium theme Pro includes.
  static Set<GameTheme> get allPremiumThemes =>
      {...premiumThemes, ...nonBundleThemes};

  /// Bare store product id -> theme. The backend reports owned themes by
  /// these ids ("crystal_theme"), never by display name.
  static const Map<String, GameTheme> themeProductIds = {
    'crystal_theme': GameTheme.crystal,
    'cyberpunk_theme': GameTheme.cyberpunk,
    'space_theme': GameTheme.space,
    'ocean_theme': GameTheme.ocean,
    'desert_theme': GameTheme.desert,
    'forest_theme': GameTheme.forest,
    'miami_nights_theme': GameTheme.miamiNights,
  };

  /// Miami Nights is free for everyone until this local time (the first
  /// moment it is NOT free). After that it is a paid theme: bought on its
  /// own (store product miami_nights_theme) or included with Pro. Launched
  /// for the big Nov 19 2026 game release week.
  static final DateTime miamiNightsFreeUntil = DateTime(2026, 12, 8);

  /// Last day Miami Nights is free, for the "free until" store copy.
  static DateTime get miamiNightsLastFreeDay =>
      miamiNightsFreeUntil.subtract(const Duration(days: 1));

  /// Whether [theme] is in a free-for-everyone event window right now.
  static bool isEventFree(GameTheme theme, [DateTime? now]) =>
      theme == GameTheme.miamiNights &&
      (now ?? DateTime.now()).isBefore(miamiNightsFreeUntil);

  /// Check if a theme requires premium (right now: an event theme in its
  /// free window does not).
  static bool isPremiumTheme(GameTheme theme) =>
      allPremiumThemes.contains(theme) &&
      !isEventFree(theme);
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

  /// Active temporary cosmetic unlocks (daily-bonus theme, ad trials) as
  /// [TemporaryGrant.key] -> expiry. Device-local: never part of the owned
  /// sets above, never synced. PremiumCubit drops entries the moment they
  /// expire, so membership alone means "active".
  final Map<String, DateTime> temporaryUnlocks;

  /// Cosmetics the server sells for coins, with their server prices
  /// (premium-content `coin_cosmetics` / GET /cosmetics/coin-catalog).
  /// Empty until the server has answered: no coin price is ever shown
  /// from a client-side guess.
  final List<CoinCosmeticOffer> coinCosmetics;

  /// Skins / trails / themes claimed in the Season, derived from the
  /// battle pass's claimed tiers (BattlePassCubit pushes it here). Counts
  /// as permanent ownership in the checks below, but is never merged into
  /// the owned sets above, never stored and never synced upward: the
  /// server's owned lists don't know these claims and would strip them.
  final SeasonCosmetics seasonCosmetics;

  /// The coin offer for [type] (`skin` / `trail` / `theme`) and [id], if
  /// the server sells it for coins.
  CoinCosmeticOffer? coinOfferFor(String type, String id) => coinCosmetics
      .where((o) => o.type == type && o.id == id)
      .firstOrNull;

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
    this.temporaryUnlocks = const {},
    this.coinCosmetics = const [],
    this.seasonCosmetics = SeasonCosmetics.none,
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
    Map<String, DateTime>? temporaryUnlocks,
    List<CoinCosmeticOffer>? coinCosmetics,
    SeasonCosmetics? seasonCosmetics,
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
      temporaryUnlocks: temporaryUnlocks ?? this.temporaryUnlocks,
      coinCosmetics: coinCosmetics ?? this.coinCosmetics,
      seasonCosmetics: seasonCosmetics ?? this.seasonCosmetics,
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
  bool isThemeOwned(GameTheme theme) =>
      ownedThemes.contains(theme) || seasonCosmetics.themes.contains(theme);

  /// Check if a theme is unlocked (free themes always unlocked, premium needs purchase or subscription)
  bool isThemeUnlocked(GameTheme theme) =>
      isThemePermanentlyUnlocked(theme) || hasTemporaryTheme(theme);

  /// [isThemeUnlocked] without temporary grants: owned, free or Pro. The
  /// purchase reconciler uses this so a theme on trial doesn't read as bought.
  bool isThemePermanentlyUnlocked(GameTheme theme) =>
      _debugAllThemes ||
      !PremiumContent.isPremiumTheme(theme) || hasPremium || isThemeOwned(theme);

  /// Whether [kind]/[id] is temporarily unlocked right now.
  bool hasTemporaryUnlock(TemporaryGrantKind kind, String id) =>
      temporaryUnlocks.containsKey(TemporaryGrant.keyFor(kind, id));

  /// When the temporary unlock of [kind]/[id] ends, or null if there is none.
  DateTime? temporaryUnlockExpiry(TemporaryGrantKind kind, String id) =>
      temporaryUnlocks[TemporaryGrant.keyFor(kind, id)];

  bool hasTemporaryTheme(GameTheme theme) => hasTemporaryUnlock(
        TemporaryGrantKind.theme,
        TemporaryGrant.themeGrantId(theme),
      );

  /// Whether the skin [skinId] may be equipped and drawn: owned (Pro's
  /// skins are in the owned set too) or temporarily unlocked. Renderers and
  /// the equip guard use this; [isSkinOwned] stays strict for the
  /// purchase reconciler.
  bool isSkinUsable(String skinId) =>
      isSkinOwned(skinId) ||
      hasTemporaryUnlock(TemporaryGrantKind.skin, skinId);

  /// Trail equivalent of [isSkinUsable].
  bool isTrailUsable(String trailId) =>
      isTrailOwned(trailId) ||
      hasTemporaryUnlock(TemporaryGrantKind.trail, trailId);

  /// Debug-only: `--dart-define=LB_ALL_THEMES=true` unlocks every theme so
  /// theme art can be tuned without owning it. Compiled out of release.
  static const bool _debugAllThemes =
      kDebugMode && bool.fromEnvironment('LB_ALL_THEMES');

  /// Check if a skin is owned: in the (server-mirrored) owned set, or
  /// claimed in the Season ([seasonCosmetics], derived). Independent of Pro
  /// status and of temporary unlocks; the purchase-pending reconciler
  /// (`_isProductOwned`) relies on that.
  bool isSkinOwned(String skinId) =>
      ownedSkins.contains(skinId) || seasonCosmetics.skins.contains(skinId);

  /// Check if a trail is owned. Same semantics as [isSkinOwned].
  bool isTrailOwned(String trailId) =>
      ownedTrails.contains(trailId) || seasonCosmetics.trails.contains(trailId);

  /// Check if a skin is usable by the player — free skins always are; premium
  /// skins unlock either through individual purchase OR an active Pro
  /// subscription (Pro bundles all premium cosmetics, mirroring the theme
  /// fast-path). Use this in UI gating (store equip buttons, paint logic).
  bool isSkinUnlocked(SnakeSkinType skin) =>
      !skin.isPremium ||
      hasPremium ||
      isSkinOwned(skin.id) ||
      hasTemporaryUnlock(TemporaryGrantKind.skin, skin.id);

  /// Check if a trail is usable by the player. Same Pro-bundle fast-path
  /// as [isSkinUnlocked].
  bool isTrailUnlocked(TrailEffectType trail) =>
      !trail.isPremium ||
      hasPremium ||
      isTrailOwned(trail.id) ||
      hasTemporaryUnlock(TemporaryGrantKind.trail, trail.id);

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
    temporaryUnlocks,
    coinCosmetics,
    seasonCosmetics,
  ];
}
