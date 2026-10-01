import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_state.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// Pieces of the Season screen (Living Board screen 11).

/// The pixel icon standing in for a reward's emoji.
LBIcon seasonRewardIcon(BattlePassRewardType type) => switch (type) {
      BattlePassRewardType.xp => LBIcon.star,
      BattlePassRewardType.coins => LBIcon.coin,
      BattlePassRewardType.theme => LBIcon.grid,
      BattlePassRewardType.skin => LBIcon.apple,
      BattlePassRewardType.trail => LBIcon.flame,
      BattlePassRewardType.powerUp => LBIcon.bolt,
      BattlePassRewardType.tournamentEntry => LBIcon.trophy,
      BattlePassRewardType.title => LBIcon.crown,
      BattlePassRewardType.avatar => LBIcon.user,
      BattlePassRewardType.special => LBIcon.gift,
    };

/// TIER {n} / 100, the track chip and the XP cells to the next tier.
class SeasonHero extends StatelessWidget {
  const SeasonHero({super.key, required this.state, required this.maxTier});

  final BattlePassState state;
  final int maxTier;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final complete = state.currentTier >= maxTier;
    final xpLine = complete
        ? l10n.bpSeasonCompleteUpper
        : l10n.lbXpToTier(
            context.formatInt(state.currentXP),
            context.formatInt(state.xpForNextTier),
            '${state.currentTier + 1}',
          );
    return LBBlock(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Semantics(
            label: '${l10n.lbTier} ${state.currentTier} ${l10n.lbTierOf('$maxTier')}',
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.lbTier, style: LBText.label(p)),
                const SizedBox(height: 4),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    LBCellText('${state.currentTier}', cell: 11 * context.uiScale, glow: true),
                    const SizedBox(width: 10),
                    Text(
                      l10n.lbTierOf('$maxTier'),
                      style: LBText.value(p, color: p.inkMuted, size: 15),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: state.isActive
                      ? LBChip(label: l10n.lbProTrack, kind: LBChipKind.gold, icon: LBIcon.crown)
                      : LBChip(label: l10n.lbFreeTrack, icon: LBIcon.lock),
                ),
                const SizedBox(height: 18),
                LBCellsBar(
                  count: 9,
                  value: complete ? 1 : state.tierProgress,
                  semanticsLabel: xpLine,
                ),
                const SizedBox(height: 8),
                Text(
                  xpLine,
                  maxLines: 2,
                  style: LBText.label(p).copyWith(letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// NEXT UP · TIER {n} · FREE/PRO: the next reward the player will earn.
class SeasonNextUp extends StatelessWidget {
  const SeasonNextUp({
    super.key,
    required this.reward,
    required this.tier,
    required this.isPremium,
    required this.distance,
    required this.lockedBehindPro,
    required this.onTap,
    required this.onUnlockPro,
  });

  final BattlePassReward reward;
  final int tier;
  final bool isPremium;
  final int distance;
  final bool lockedBehindPro;
  final VoidCallback onTap;
  final VoidCallback onUnlockPro;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final name = localizedBattlePassRewardName(reward.name, l10n);
    return LBBlock(
      kind: LBBlockKind.gold,
      onTap: onTap,
      semanticLabel: '${l10n.lbNextUp('$tier', isPremium ? l10n.lbPro : l10n.lbFree)}, $name',
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.lbNextUp('$tier', isPremium ? l10n.lbPro : l10n.lbFree),
                  style: LBText.label(p, color: LB.gold),
                ),
                const SizedBox(height: 8),
                Text(
                  name.toUpperCase(),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.value(p, color: p.ink, size: 19).copyWith(letterSpacing: 1.4),
                ),
                const SizedBox(height: 6),
                if (lockedBehindPro)
                  LBBlock(
                    kind: LBBlockKind.gold,
                    selected: true,
                    onTap: onUnlockPro,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const LBPixelIcon(LBIcon.crown, cell: 2.6, color: LB.gold),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            l10n.bpUnlockWithPro,
                            style: LBText.button(p, color: LB.gold, size: 11),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const LBPixelIcon(LBIcon.next, cell: 2.2, color: LB.gold),
                      ],
                    ),
                  )
                else
                  Text(l10n.lbTiersAwayLine(distance), style: LBText.body(p, size: 11.5)),
              ],
            ),
          ),
          const SizedBox(width: 12),
          LBPixelIcon(seasonRewardIcon(reward.type), cell: 7, color: LB.gold),
        ],
      ),
    );
  }
}

/// Shown instead of NEXT UP once every tier is earned.
class SeasonComplete extends StatelessWidget {
  const SeasonComplete({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.gold,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          const LBPixelIcon(LBIcon.trophy, cell: 6, color: LB.gold),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.bpSeasonCompleteUpper, style: LBText.button(p, color: LB.gold, size: 14)),
                const SizedBox(height: 4),
                Text(l10n.bpUnlockedEverything, style: LBText.body(p, size: 11.5)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// "+50 XP · WATCH AD". A Living Board skin over the exact behaviour of
/// [RewardedActionButton], which this row replaces on the Season screen:
/// hidden for Pro / when ads are off, preloads on mount, enabled the moment
/// [AdService.rewardedReadyListenable] reports a loaded ad, and awaits
/// [onWatch] (the screen's own ad call).
class SeasonXpAdRow extends StatefulWidget {
  const SeasonXpAdRow({super.key, required this.label, required this.onWatch});

  final String label;
  final Future<void> Function() onWatch;

  @override
  State<SeasonXpAdRow> createState() => _SeasonXpAdRowState();
}

class _SeasonXpAdRowState extends State<SeasonXpAdRow> {
  AdService? get _ads =>
      GetIt.I.isRegistered<AdService>() ? GetIt.I<AdService>() : null;

  @override
  void initState() {
    super.initState();
    _ads?.preloadRewarded();
    _ads?.rewardedReadyListenable.addListener(_onReadyChanged);
    // Ads may not be enabled yet (SDK still initialising on a cold start).
    _ads?.adsEnabledListenable.addListener(_onReadyChanged);
  }

  void _onReadyChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _ads?.rewardedReadyListenable.removeListener(_onReadyChanged);
    _ads?.adsEnabledListenable.removeListener(_onReadyChanged);
    super.dispose();
  }

  Future<void> _onTap() async {
    await widget.onWatch();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final ads = _ads;
    if (ads == null || !ads.adsEnabled) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final enabled = ads.isRewardedReady;
    return Opacity(
      opacity: enabled ? 1 : .5,
      child: LBBlock(
        onTap: enabled ? _onTap : null,
        feedback: false,
        semanticLabel: widget.label,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            LBPixelIcon(LBIcon.tv, cell: 4, color: p.lime),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.label, style: LBText.button(p, size: 13)),
                  const SizedBox(height: 2),
                  Text(
                    enabled ? l10n.raOptIn : l10n.rcNoAd,
                    style: LBText.body(p, color: p.inkDim, size: 10.5),
                  ),
                ],
              ),
            ),
            LBPixelIcon(LBIcon.next, cell: 2.4, color: p.head),
          ],
        ),
      ),
    );
  }
}

/// The small solid-gold CLAIM button.
class SeasonClaimButton extends StatelessWidget {
  const SeasonClaimButton({super.key, required this.claiming, required this.onClaim});

  final bool claiming;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final fg = LBBlock.foregroundOf(LBBlockKind.goldFill, p);
    return Opacity(
      opacity: claiming ? .55 : 1,
      child: LBBlock(
        kind: LBBlockKind.goldFill,
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        semanticLabel: l10n.bpClaim,
        onTap: claiming ? null : onClaim,
        child: Text(l10n.bpClaim, style: LBText.button(p, color: fg, size: 11.5)),
      ),
    );
  }
}

/// One claimable reward in the AVAILABLE NOW list.
class SeasonClaimRow extends StatelessWidget {
  const SeasonClaimRow({
    super.key,
    required this.reward,
    required this.tier,
    required this.isPremium,
    required this.claiming,
    required this.onClaim,
  });

  final BattlePassReward reward;
  final int tier;
  final bool isPremium;
  final bool claiming;
  final VoidCallback onClaim;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.gold,
      padding: const EdgeInsets.fromLTRB(14, 6, 6, 6),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(l10n.bpTierAbbrev(tier), style: LBText.button(p, color: LB.gold, size: 11)),
          ),
          LBPixelIcon(seasonRewardIcon(reward.type), cell: 3, color: LB.gold),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizedBattlePassRewardName(reward.name, l10n).toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: p.ink, size: 11.5),
                ),
                Text(
                  isPremium ? l10n.lbPro : l10n.lbFree,
                  style: LBText.label(p, color: isPremium ? LB.gold : p.inkDim),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SeasonClaimButton(claiming: claiming, onClaim: onClaim),
        ],
      ),
    );
  }
}

/// "Premium rewards waiting · Subscribe to Pro to claim them." → store.
class SeasonPremiumTeaser extends StatelessWidget {
  const SeasonPremiumTeaser({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBBlock(
      kind: LBBlockKind.gold,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          const LBPixelIcon(LBIcon.crown, cell: 4, color: LB.gold),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(l10n.bpPremiumWaiting.toUpperCase(), style: LBText.button(p, color: LB.gold, size: 12)),
                const SizedBox(height: 2),
                Text(l10n.bpSubscribeToClaim, style: LBText.body(p, size: 11)),
              ],
            ),
          ),
          const LBPixelIcon(LBIcon.next, cell: 2.4, color: LB.gold),
        ],
      ),
    );
  }
}

/// TIER · FREE · PRO column labels over the tier table.
class SeasonTierHeader extends StatelessWidget {
  const SeasonTierHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: context.lbCell * 2.4,
            child: Text(l10n.lbTier, style: LBText.label(p, color: p.inkDim)),
          ),
          Expanded(child: Text(l10n.lbFree, style: LBText.label(p, color: p.inkDim))),
          Expanded(child: Text(l10n.lbPro, style: LBText.label(p, color: LB.gold))),
        ],
      ),
    );
  }
}

/// One tier: the tier block (lime on the current tier, gold on milestones)
/// and its FREE and PRO reward cells.
class SeasonTierRow extends StatelessWidget {
  const SeasonTierRow({
    super.key,
    required this.state,
    required this.level,
    required this.claiming,
    required this.onClaim,
    required this.onTapReward,
  });

  final BattlePassState state;
  final BattlePassLevel level;
  final Set<String> claiming;
  final void Function(BattlePassReward reward, bool isPremium) onClaim;
  final ValueChanged<BattlePassReward> onTapReward;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final isCurrent = level.level == state.currentTier;
    final tierKind = isCurrent
        ? LBBlockKind.fill
        : (level.isMilestone ? LBBlockKind.gold : LBBlockKind.outline);
    final h = context.lbCell * 3 - LB.inset * 2;
    return Row(
      children: [
        SizedBox(
          width: context.lbCell * 2.4,
          child: LBBlock(
            kind: tierKind,
            height: h,
            padding: EdgeInsets.zero,
            alignment: Alignment.center,
            semanticLabel: l10n.bpTierN(level.level),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                l10n.bpTierAbbrev(level.level),
                style: LBText.button(p, color: LBBlock.foregroundOf(tierKind, p), size: 12.5),
              ),
            ),
          ),
        ),
        Expanded(child: _cell(context, level.freeReward, false, h)),
        Expanded(child: _cell(context, level.premiumReward, true, h)),
      ],
    );
  }

  Widget _cell(BuildContext context, BattlePassReward? reward, bool isPremium, double h) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final tier = level.level;
    final isCurrent = tier == state.currentTier;
    final marker = isCurrent && !isPremium;

    if (reward == null) {
      return LBBlock(
        kind: LBBlockKind.muted,
        height: h,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('—', style: LBText.button(p, color: p.inkDim)),
            if (marker)
              Text(l10n.lbYouAreHere, maxLines: 1, style: LBText.label(p, color: p.lime)),
          ],
        ),
      );
    }

    final unlocked = tier <= state.currentTier;
    final claimed = isPremium
        ? state.isPremiumTierClaimed(tier)
        : state.isFreeTierClaimed(tier);
    final lockedByPremium = isPremium && !state.isActive;
    // Premium claims gate on isValid, like the claim path itself.
    final canClaim = unlocked && !claimed && (!isPremium || state.isValid);
    final claimKey = '${isPremium ? 'p' : 'f'}:$tier';
    final name = localizedBattlePassRewardName(reward.name, l10n);

    final kind = canClaim
        ? LBBlockKind.gold
        : (isPremium || claimed ? LBBlockKind.muted : LBBlockKind.outline);

    final String? sub = marker
        ? l10n.lbYouAreHere
        : (!unlocked && !lockedByPremium ? l10n.lbTiersAway(tier - state.currentTier) : null);
    final Color subColor = marker ? p.lime : p.inkDim;

    Widget? trailing;
    if (canClaim) {
      trailing = SeasonClaimButton(
        claiming: claiming.contains(claimKey),
        onClaim: () => onClaim(reward, isPremium),
      );
    } else if (claimed) {
      trailing = LBPixelIcon(LBIcon.check, cell: 2.6, color: p.inkDim);
    } else if (lockedByPremium) {
      trailing = LBPixelIcon(LBIcon.crown, cell: 2.6, color: LB.gold.withValues(alpha: .7));
    }

    final nameColor = claimed || (!unlocked || lockedByPremium) && !canClaim
        ? p.inkMuted
        : p.ink;

    return LBBlock(
      kind: kind,
      height: h,
      onTap: () => onTapReward(reward),
      semanticLabel: '$name, ${isPremium ? l10n.lbPro : l10n.lbFree}'
          '${claimed ? ', ${l10n.lbClaimed}' : ''}${sub != null ? ', $sub' : ''}',
      padding: EdgeInsets.fromLTRB(12, 0, canClaim ? 4 : 10, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.button(p, color: nameColor, size: 11).copyWith(letterSpacing: .8),
                ),
                if (sub != null)
                  Text(sub, maxLines: 1, overflow: TextOverflow.ellipsis, style: LBText.label(p, color: subColor)),
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 6), trailing],
        ],
      ),
    );
  }
}

/// Reward detail, opened from NEXT UP or any tier cell.
class SeasonRewardSheet extends StatelessWidget {
  const SeasonRewardSheet({
    super.key,
    required this.reward,
    required this.tier,
    required this.unlocked,
  });

  final BattlePassReward reward;
  final int tier;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final accent = reward.isPremium ? LB.gold : p.lime;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LBBlock(
                kind: reward.isPremium ? LBBlockKind.gold : LBBlockKind.outline,
                width: context.lbCell * 4 - LB.inset * 2,
                height: context.lbCell * 4 - LB.inset * 2,
                padding: EdgeInsets.zero,
                alignment: Alignment.center,
                child: LBPixelIcon(seasonRewardIcon(reward.type), cell: 8, color: accent),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizedBattlePassRewardName(reward.name, l10n).toUpperCase(),
                      style: LBText.value(p, color: p.ink, size: 18).copyWith(letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        LBChip(
                          label: reward.isPremium ? l10n.lbPro : l10n.lbFree,
                          kind: reward.isPremium ? LBChipKind.gold : LBChipKind.outline,
                        ),
                        LBChip(label: l10n.bpTierUpperN(tier)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            reward.isPremium
                ? l10n.bpRewardDescPremium(reward.type.localizedName(l10n))
                : l10n.bpRewardDescFree(reward.type.localizedName(l10n)),
            style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 12.5),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              LBPixelIcon(unlocked ? LBIcon.check : LBIcon.lock, cell: 3, color: unlocked ? p.lime : p.inkMuted),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  (unlocked ? l10n.bpUnlocked : l10n.bpReachTier(tier)).toUpperCase(),
                  style: LBText.label(p, color: unlocked ? p.lime : p.inkMuted),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
