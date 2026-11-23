import 'package:flutter/foundation.dart';

/// Another game by the same developer, shown in Settings → "More games".
///
/// Store-policy rules (owner asked for full compliance, 2026-11-23):
/// * No reward of any kind for installing or opening a promoted game
///   (Google Play's incentivized-install ban, App Store guideline 3.2.2).
/// * A plain list row, opened only by the player's own tap: never at launch,
///   during play, on game over, or as a pop-up.
/// * Each platform links to its own store only; a Play link never shows on
///   iOS and vice versa. A game without a link for the platform is hidden.
/// * Only our own games, with the name and icon of the live store listing.
/// * Snake Classic is 13+ (Play) / 12+ (App Store) and outside Designed for
///   Families / the Kids category; if it ever enters them, store links need
///   a parental gate. Re-check these rules if that changes.
class PromotedGame {
  const PromotedGame({
    required this.id,
    required this.name,
    required this.iconAsset,
    this.androidUrl,
    this.iosUrl,
  });

  /// Analytics id (`game` param of the `more_games` event).
  final String id;

  /// The store listing's name. Not translated.
  final String name;
  final String iconAsset;

  /// Google Play listing, with a referrer so installs are attributable in
  /// Play Console (Acquisition → by referrer / utm_source).
  final String? androidUrl;

  /// App Store listing; `ct` shows in App Store Connect → App Analytics →
  /// Campaigns.
  final String? iosUrl;

  /// The store link for [platform], or null when there is none (web,
  /// desktop, or no listing on that store).
  String? urlFor(TargetPlatform platform, {bool isWeb = kIsWeb}) {
    if (isWeb) return null;
    return switch (platform) {
      TargetPlatform.android => androidUrl,
      TargetPlatform.iOS => iosUrl,
      _ => null,
    };
  }
}

abstract final class CrossPromo {
  /// The owner's other GAMES (not the productivity apps), in display order:
  /// action first, then puzzles. Owner, 2026-11-23. A game shows only on
  /// the store where it is live: Screw Out is Play-only and Jadewell
  /// App Store-only for now; add the missing link when it launches there.
  /// Cosmo Strike spec: cosmo-strike repo, marketing/cross-promo/MORE_GAMES_SPEC.md.
  static const List<PromotedGame> games = [
    PromotedGame(
      id: 'cosmo_strike',
      name: 'Cosmo Strike',
      iconAsset: 'assets/images/cross_promo/cosmo_strike.png',
      androidUrl: '$_play=com.pranta.cosmostrike$_playRef',
      iosUrl: '$_appStore/id6824382793$_appStoreRef',
    ),
    PromotedGame(
      id: 'sunstone',
      name: 'Sunstone',
      iconAsset: 'assets/images/cross_promo/sunstone.png',
      androidUrl: '$_play=com.pranta.sunstone$_playRef',
      iosUrl: '$_appStore/id6818707768$_appStoreRef',
    ),
    PromotedGame(
      id: 'pourfect',
      name: 'Pourfect',
      iconAsset: 'assets/images/cross_promo/pourfect.png',
      androidUrl: '$_play=com.pranta.pourfect$_playRef',
      iosUrl: '$_appStore/id6824137375$_appStoreRef',
    ),
    PromotedGame(
      id: 'screw_out',
      name: 'Screw Out',
      iconAsset: 'assets/images/cross_promo/screw_out.png',
      androidUrl: '$_play=com.pranta.screwout$_playRef',
    ),
    PromotedGame(
      id: 'gridwell',
      name: 'Gridwell',
      iconAsset: 'assets/images/cross_promo/gridwell.png',
      androidUrl: '$_play=com.pranta.gridwell$_playRef',
      iosUrl: '$_appStore/id6834377123$_appStoreRef',
    ),
    PromotedGame(
      id: 'jadewell',
      name: 'Jadewell',
      iconAsset: 'assets/images/cross_promo/jadewell.png',
      iosUrl: '$_appStore/id6837629101$_appStoreRef',
    ),
  ];

  static const _play = 'https://play.google.com/store/apps/details?id';
  static const _playRef =
      '&referrer=utm_source%3Dsnake_classic%26utm_medium%3Dmore_games';
  static const _appStore = 'https://apps.apple.com/app';
  static const _appStoreRef = '?ct=snake_classic_more_games&mt=8';

  /// The games that have a store link on [platform].
  static List<PromotedGame> forPlatform(
    TargetPlatform platform, {
    bool isWeb = kIsWeb,
  }) => [
    for (final g in games)
      if (g.urlFor(platform, isWeb: isWeb) != null) g,
  ];
}
