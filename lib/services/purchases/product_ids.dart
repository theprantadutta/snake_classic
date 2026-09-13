/// Store product IDs.
///
/// Store IDs use the `com.pranta.snakeclassic.` prefix for Google Play and
/// the App Store. Internal IDs (SharedPreferences, database) stay unprefixed
/// for backward compatibility.
class ProductIds {
  // Store product ID prefix
  static const String prefix = 'com.pranta.snakeclassic.';

  /// Strip the store prefix to get the internal ID.
  static String stripPrefix(String id) {
    if (id.startsWith(prefix)) return id.substring(prefix.length);
    return id;
  }

  /// Add the store prefix to an internal ID.
  static String withPrefix(String id) {
    if (id.startsWith(prefix)) return id;
    return '$prefix$id';
  }

  /// Convert a bare skin name (e.g. 'golden') to its store product ID.
  static String skinStoreId(String skinId) => '${prefix}skin_$skinId';

  // Premium Themes
  static const String crystalTheme = '${prefix}crystal_theme';
  static const String cyberpunkTheme = '${prefix}cyberpunk_theme';
  static const String spaceTheme = '${prefix}space_theme';
  static const String oceanTheme = '${prefix}ocean_theme';
  static const String desertTheme = '${prefix}desert_theme';
  static const String forestTheme = '${prefix}forest_theme';
  static const String themesBundle = '${prefix}premium_themes_bundle';

  // Snake Coins (Consumable)
  static const String coinPackSmall = '${prefix}coin_pack_small';
  static const String coinPackMedium = '${prefix}coin_pack_medium';
  static const String coinPackLarge = '${prefix}coin_pack_large';
  static const String coinPackMega = '${prefix}coin_pack_mega';

  // Snake Skins (store IDs use skin_ category prefix)
  static const String goldenSnake = '${prefix}skin_golden';
  static const String rainbowSnake = '${prefix}skin_rainbow';
  static const String galaxySnake = '${prefix}skin_galaxy';
  static const String dragonSnake = '${prefix}skin_dragon';
  static const String electricSnake = '${prefix}skin_electric';
  static const String fireSnake = '${prefix}skin_fire';
  static const String iceSnake = '${prefix}skin_ice';
  static const String shadowSnake = '${prefix}skin_shadow';
  static const String neonSnake = '${prefix}skin_neon';
  static const String crystalSnake = '${prefix}skin_crystal';
  static const String cosmicSnake = '${prefix}skin_cosmic';

  // Trail Effects
  static const String particleTrail = '${prefix}trail_particle';
  static const String glowTrail = '${prefix}trail_glow';
  static const String rainbowTrail = '${prefix}trail_rainbow';
  static const String fireTrail = '${prefix}trail_fire';
  static const String electricTrail = '${prefix}trail_electric';
  static const String starTrail = '${prefix}trail_star';
  static const String cosmicTrail = '${prefix}trail_cosmic';
  static const String neonTrail = '${prefix}trail_neon';
  static const String shadowTrail = '${prefix}trail_shadow';
  static const String crystalTrail = '${prefix}trail_crystal';
  static const String dragonTrail = '${prefix}trail_dragon';

  // Subscriptions
  static const String snakeClassicProMonthly = '${prefix}pro_monthly';
  static const String snakeClassicProYearly = '${prefix}pro_yearly';

  // Tournament Entries (Consumable). Bronze (daily) entries are earned via
  // rewarded ad or Pro and are no longer sold as an IAP.
  static const String tournamentSilver = '${prefix}tournament_silver';
  static const String tournamentGold = '${prefix}tournament_gold';

  /// All active store product IDs (37 products).
  /// Battle Pass and power-up IAPs are excluded.
  static List<String> get allProductIds => [
    // Themes (7)
    crystalTheme, cyberpunkTheme, spaceTheme,
    oceanTheme, desertTheme, forestTheme, themesBundle,
    // Coins (4)
    coinPackSmall, coinPackMedium, coinPackLarge, coinPackMega,
    // Snake skins (11)
    goldenSnake, rainbowSnake, galaxySnake, dragonSnake, electricSnake,
    fireSnake, iceSnake, shadowSnake, neonSnake, crystalSnake, cosmicSnake,
    // Trail effects (11)
    particleTrail, glowTrail, rainbowTrail, fireTrail, electricTrail, starTrail,
    cosmicTrail, neonTrail, shadowTrail, crystalTrail, dragonTrail,
    // Subscriptions (2)
    snakeClassicProMonthly, snakeClassicProYearly,
    // Tournament entries (2)
    tournamentSilver, tournamentGold,
  ];

  /// One-time products: everything that is not a subscription.
  static List<String> get oneTimeProductIds => allProductIds
      .where((id) => !subscriptionIds.contains(id))
      .toList(growable: false);

  static List<String> get consumableIds => [
    // Coins
    coinPackSmall, coinPackMedium, coinPackLarge, coinPackMega,
    // Tournament entries
    tournamentSilver, tournamentGold,
  ];

  static List<String> get subscriptionIds => [
    snakeClassicProMonthly,
    snakeClassicProYearly,
  ];

  static bool isSubscription(String id) => subscriptionIds.contains(id);
  static bool isConsumable(String id) => consumableIds.contains(id);
}
