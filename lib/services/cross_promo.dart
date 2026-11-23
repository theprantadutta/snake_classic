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
/// * Both apps are 12+/9+ and outside Designed for Families / the Kids
///   category; re-check these rules if that ever changes.
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
  /// The owner's other games, in display order. Owner, 2026-11-23: only
  /// Cosmo Strike for now. Spec: cosmo-strike repo,
  /// marketing/cross-promo/MORE_GAMES_SPEC.md.
  static const List<PromotedGame> games = [
    PromotedGame(
      id: 'cosmo_strike',
      name: 'Cosmo Strike',
      iconAsset: 'assets/images/cross_promo/cosmo_strike.png',
      androidUrl:
          'https://play.google.com/store/apps/details?id=com.pranta.cosmostrike'
          '&referrer=utm_source%3Dsnake_classic%26utm_medium%3Dmore_games',
      iosUrl:
          'https://apps.apple.com/app/id6824382793'
          '?ct=snake_classic_more_games&mt=8',
    ),
  ];

  /// The games that have a store link on [platform].
  static List<PromotedGame> forPlatform(
    TargetPlatform platform, {
    bool isWeb = kIsWeb,
  }) => [
    for (final g in games)
      if (g.urlFor(platform, isWeb: isWeb) != null) g,
  ];
}
