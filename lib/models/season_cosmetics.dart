import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/models/temporary_grant.dart';
import 'package:snake_classic/utils/constants.dart';

/// Skins, trails and themes the player owns because they claimed them in
/// the Season (battle pass).
///
/// DERIVED, never stored: computed from the claimed free / premium tiers
/// (which sync through the battle-pass snapshot, so they survive reinstall
/// and reach other devices) and the app's built-in season reward table. The
/// server does not know these claims (the app runs its own season), so its
/// owned lists omit them; PremiumState overlays this set on top of the
/// server's so a sync never strips or unequips a Season reward. It is never
/// sent upward as ownership.
///
/// Premium-track rewards stay owned after Pro or the pass lapses: the claim
/// is what counts, not the current entitlement.
class SeasonCosmetics {
  const SeasonCosmetics({
    this.skins = const {},
    this.trails = const {},
    this.themes = const {},
  });

  static const SeasonCosmetics none = SeasonCosmetics();

  /// Skin ids (`galaxy`).
  final Set<String> skins;

  /// Trail ids (`trail_cosmic`).
  final Set<String> trails;
  final Set<GameTheme> themes;

  bool get isEmpty => skins.isEmpty && trails.isEmpty && themes.isEmpty;

  /// The cosmetics behind the claimed tiers of [season].
  factory SeasonCosmetics.fromClaims(
    BattlePassSeason? season, {
    required Set<int> claimedFreeTiers,
    required Set<int> claimedPremiumTiers,
  }) {
    if (season == null) return none;
    final skins = <String>{};
    final trails = <String>{};
    final themes = <GameTheme>{};

    void add(BattlePassReward? reward) {
      final id = reward?.itemId;
      if (reward == null || id == null || id.isEmpty) return;
      switch (reward.type) {
        case BattlePassRewardType.skin:
          skins.add(id.startsWith('skin_') ? id.substring(5) : id);
        case BattlePassRewardType.trail:
          trails.add(id.startsWith('trail_') ? id : 'trail_$id');
        case BattlePassRewardType.theme:
          final theme = TemporaryGrant.themeFromGrantId(id);
          if (theme != null) themes.add(theme);
        default:
          break;
      }
    }

    for (final tier in claimedFreeTiers) {
      add(season.getLevelData(tier)?.freeReward);
    }
    for (final tier in claimedPremiumTiers) {
      add(season.getLevelData(tier)?.premiumReward);
    }
    return SeasonCosmetics(skins: skins, trails: trails, themes: themes);
  }

  @override
  bool operator ==(Object other) =>
      other is SeasonCosmetics &&
      _setEq(other.skins, skins) &&
      _setEq(other.trails, trails) &&
      _setEq(other.themes, themes);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(skins),
    Object.hashAllUnordered(trails),
    Object.hashAllUnordered(themes),
  );

  static bool _setEq<T>(Set<T> a, Set<T> b) =>
      a.length == b.length && a.containsAll(b);
}
