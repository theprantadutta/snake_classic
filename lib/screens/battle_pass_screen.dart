import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/ranks/lb_list_bits.dart';
import 'package:snake_classic/widgets/lb_screens/season/season_widgets.dart';

/// Season (Living Board screen 11): the tier hero, NEXT UP, the rewarded
/// +50 XP row, anything claimable right now, and the FREE / PRO tier table
/// with the current tier marked. Gold means reward; the current tier is the
/// one lime block in the table.
class BattlePassScreen extends StatefulWidget {
  const BattlePassScreen({super.key});

  @override
  State<BattlePassScreen> createState() => _BattlePassScreenState();
}

class _BattlePassScreenState extends State<BattlePassScreen> {
  /// The table opens on a window starting just before the current tier
  /// (the mock); the toggle under it shows every tier.
  bool _showAllTiers = false;
  final Set<String> _claiming = <String>{};

  @override
  void initState() {
    super.initState();
    // Silent refresh on entry so a Pro purchase made elsewhere in the app
    // immediately reflects in the premium track. The cubit also listens
    // to PremiumCubit; this handles cold starts where the order races.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<BattlePassCubit>().refresh();
    });
  }

  Future<void> _claim({
    required int tier,
    required bool isPremium,
    required BattlePassReward reward,
  }) async {
    final claimKey = '${isPremium ? 'p' : 'f'}:$tier';
    if (_claiming.contains(claimKey)) return;
    setState(() => _claiming.add(claimKey));

    // Captured before the await — the claim call is an async gap.
    final l10n = AppLocalizations.of(context)!;
    try {
      final cubit = context.read<BattlePassCubit>();
      final ok = isPremium
          ? await cubit.claimPremiumReward(tier)
          : await cubit.claimFreeReward(tier);

      if (!mounted) return;
      if (ok) {
        HapticService().mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          arcadeSnackBar(
            context,
            message: l10n.bpClaimedToast(
              localizedBattlePassRewardName(reward.name, l10n),
            ),
            tone: ArcadeSnackTone.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _claiming.remove(claimKey));
    }
  }

  void _openRewardDetail(
    BuildContext context,
    BattlePassReward reward,
    int tier,
    bool unlocked,
  ) {
    showLBSheet(
      context: context,
      builder: (_) => SeasonRewardSheet(
        reward: reward,
        tier: tier,
        unlocked: unlocked,
      ),
    );
  }

  Future<void> _watchAdForXp(AppLocalizations l10n) async {
    final bp = context.read<BattlePassCubit>();
    // Capture the messenger up front — onReward fires after the ad is
    // dismissed (an async gap), so we can't safely read context then.
    final messenger = ScaffoldMessenger.of(context);
    await getIt<AdService>().showRewardedFor(
      placement: AdService.placementBattlePassXp,
      onReward: () {
        bp.bufferXP(50, source: 'ad_boost');
        bp.flushXP();
        messenger.showSnackBar(
          arcadeSnackBar(
            context,
            message: l10n.bpXpEarned,
            icon: Icons.bolt,
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BattlePassCubit, BattlePassState>(
      builder: (context, bpState) {
        final l10n = AppLocalizations.of(context)!;
        final season = bpState.season;

        if (bpState.status == BattlePassStatus.loading && season == null) {
          return LBScaffold(
            title: l10n.lbSeasonTitle,
            body: LBLoadingState(label: l10n.bpLoading),
          );
        }

        if (season == null) {
          return LBScaffold(
            title: l10n.lbSeasonTitle,
            body: LBEmptyState(
              icon: LBIcon.hourglass,
              title: l10n.bpBetweenSeasons,
              line: l10n.bpNoSeasonBody,
              actionLabel: l10n.bpCheckNewSeason,
              onAction: () => context.read<BattlePassCubit>().refresh(),
            ),
          );
        }

        final maxTier = season.levels.length;
        final g = context.lbGutter;
        final cell = context.lbCell;
        final levels = _visibleLevels(season, bpState);

        return LBScaffold(
          title: l10n.lbSeasonTitle,
          subtitle: _subtitle(l10n, season),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(g, cell * .9, g, 0),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    SeasonHero(state: bpState, maxTier: maxTier),
                    _buildNextUp(context, bpState, season),
                    SeasonXpAdRow(
                      label: l10n.lbXpAd('50'),
                      onWatch: () => _watchAdForXp(l10n),
                    ),
                    ..._buildAvailable(context, l10n, bpState, season),
                    SizedBox(height: cell * .8),
                    const SeasonTierHeader(),
                  ]),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: g),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final level = levels[index];
                    return SeasonTierRow(
                      state: bpState,
                      level: level,
                      claiming: _claiming,
                      onClaim: (reward, isPremium) => _claim(
                        tier: level.level,
                        isPremium: isPremium,
                        reward: reward,
                      ),
                      onTapReward: (r) => _openRewardDetail(
                        context,
                        r,
                        level.level,
                        level.level <= bpState.currentTier,
                      ),
                    );
                  }, childCount: levels.length),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(g, 2, g, cell * 1.2),
                sliver: SliverToBoxAdapter(
                  child: _buildTiersToggle(context, l10n, maxTier),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _subtitle(AppLocalizations l10n, BattlePassSeason season) {
    final name = localizedBattlePassSeasonName(season.name, l10n);
    if (season.hasEnded) return l10n.lbSeasonEnded(name);
    final days = season.daysRemaining;
    if (days <= 0) {
      final hours = season.timeRemaining.inHours;
      return l10n.lbSeasonSubtitleSoon(
        name,
        hours <= 0 ? l10n.storeEndingSoon : l10n.bpHoursLeft(hours),
      );
    }
    return l10n.lbSeasonSubtitle(name, days);
  }

  /// Every tier, or a window from the tier before the current one.
  List<BattlePassLevel> _visibleLevels(
    BattlePassSeason season,
    BattlePassState state,
  ) {
    if (_showAllTiers) return season.levels;
    final total = season.levels.length;
    // As many tier rows as the phone has room for under the sections above
    // them (5 on the 780 dp reference frame), so a tall phone shows a
    // longer stretch of the ladder instead of an empty band.
    final height = MediaQuery.sizeOf(context).height;
    final rows = ((height - 480) / (context.lbCell * 3)).floor().clamp(4, 14);
    // From the tier before the current one, skipping tiers with nothing on
    // either track (a row of two dashes says nothing and costs a row) —
    // except the current tier, which carries YOU ARE HERE.
    final start = (state.currentTier - 1).clamp(1, total < 1 ? 1 : total);
    final out = <BattlePassLevel>[];
    for (var t = start; t <= total && out.length < rows; t++) {
      final level = season.levels[t - 1];
      if (level.hasRewards || t == state.currentTier) out.add(level);
    }
    return out;
  }

  Widget _buildTiersToggle(
    BuildContext context,
    AppLocalizations l10n,
    int totalTiers,
  ) {
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.dashed,
      height: context.lbCell * 2.5,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      onTap: () => setState(() => _showAllTiers = !_showAllTiers),
      child: Text(
        (_showAllTiers ? l10n.bpHideTiers : l10n.bpViewAllTiers(totalTiers))
            .toUpperCase(),
        style: LBText.button(p, color: p.head, size: 11.5),
      ),
    );
  }

  /// The next reward the player will earn (whichever tier above current
  /// actually has a reward), preferring premium when the player owns the
  /// pass.
  ({BattlePassReward reward, int tier, bool isPremium})? _findNext(
    BattlePassState state,
    BattlePassSeason season,
  ) {
    final hasPremium = state.isActive;
    for (int i = state.currentTier + 1; i <= season.levels.length; i++) {
      final level = season.levels[i - 1];
      // Prefer premium when the player owns the pass — that's the reward
      // they're chasing. Free is still surfaced when there's no premium
      // (and as a fallback when this tier has only a free reward).
      if (hasPremium && level.premiumReward != null) {
        return (reward: level.premiumReward!, tier: i, isPremium: true);
      }
      if (level.freeReward != null) {
        return (reward: level.freeReward!, tier: i, isPremium: false);
      }
      if (!hasPremium && level.premiumReward != null) {
        // Still preview locked premium so the player can SEE what Pro
        // would unlock. The card carries the Unlock-Pro action.
        return (reward: level.premiumReward!, tier: i, isPremium: true);
      }
    }
    return null;
  }

  Widget _buildNextUp(
    BuildContext context,
    BattlePassState state,
    BattlePassSeason season,
  ) {
    final next = _findNext(state, season);
    if (next == null) return const SeasonComplete();
    return SeasonNextUp(
      reward: next.reward,
      tier: next.tier,
      isPremium: next.isPremium,
      distance: next.tier - state.currentTier,
      lockedBehindPro: next.isPremium && !state.isActive,
      onTap: () => _openRewardDetail(context, next.reward, next.tier, false),
      onUnlockPro: () => context.push(AppRoutes.store),
    );
  }

  /// AVAILABLE NOW: every unlocked, unclaimed reward, plus the Pro teaser
  /// when premium rewards are waiting behind the pass.
  List<Widget> _buildAvailable(
    BuildContext context,
    AppLocalizations l10n,
    BattlePassState state,
    BattlePassSeason season,
  ) {
    // Gate premium on isValid (not just isActive) so we never surface a
    // claim the claim path (claimPremiumReward → requires isValid) would
    // reject.
    final hasPremium = state.isValid;
    final available = <({BattlePassReward reward, int tier, bool isPremium})>[];
    for (int i = 1; i <= state.currentTier && i <= season.levels.length; i++) {
      final level = season.levels[i - 1];
      if (level.freeReward != null && !state.isFreeTierClaimed(i)) {
        available.add((reward: level.freeReward!, tier: i, isPremium: false));
      }
      if (hasPremium &&
          level.premiumReward != null &&
          !state.isPremiumTierClaimed(i)) {
        available.add((reward: level.premiumReward!, tier: i, isPremium: true));
      }
    }
    final hasLockedPremium =
        !state.isActive &&
        season.levels.any(
          (l) =>
              l.level <= state.currentTier &&
              l.premiumReward != null &&
              !state.isPremiumTierClaimed(l.level),
        );

    if (available.isEmpty && !hasLockedPremium) return const [];

    return [
      SizedBox(height: context.lbCell * .8),
      if (available.isNotEmpty) ...[
        LBSectionLabel(l10n.bpAvailableNow, trailing: '${available.length}', color: LB.gold),
        for (final entry in available)
          SeasonClaimRow(
            reward: entry.reward,
            tier: entry.tier,
            isPremium: entry.isPremium,
            claiming: _claiming.contains('${entry.isPremium ? 'p' : 'f'}:${entry.tier}'),
            onClaim: () => _claim(
              tier: entry.tier,
              isPremium: entry.isPremium,
              reward: entry.reward,
            ),
          ),
      ],
      if (hasLockedPremium)
        SeasonPremiumTeaser(onTap: () => context.push(AppRoutes.store)),
    ];
  }
}
