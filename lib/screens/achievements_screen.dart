import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/achievement_l10n.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/daily/lb_daily_parts.dart';

/// Trophies (Living Board screen 10): ALL / UNLOCKED / LOCKED filter blocks,
/// a cells progress bar with the summary line, and one row per achievement
/// with its rarity stripe.
class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AchievementService _achievementService = AchievementService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this)
      ..addListener(_onTabChanged);
    _achievementService.addListener(_onAchievementsChanged);
  }

  @override
  void dispose() {
    _achievementService.removeListener(_onAchievementsChanged);
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _onAchievementsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final g = context.lbGutter;
    // Counts use the same logic as the dashboard's AchievementsGrid:
    // total = every catalog row, unlocked = isUnlocked, claimed =
    // rewardClaimed; "waiting" = unlocked but its reward not yet credited.
    final all = _achievementService.achievements;
    final unlocked = _achievementService.getUnlockedAchievements();
    final locked = _achievementService.getLockedAchievements();
    final claimed = all.where((a) => a.rewardClaimed).length;
    final waiting = all.where((a) => a.isUnlocked && !a.rewardClaimed).length;
    final completion = _achievementService.completionPercentage;

    return LBScaffold(
      title: l10n.lbTrophiesTitle,
      subtitle: l10n.lbTrophiesSubtitle(
        context.formatInt(unlocked.length),
        context.formatInt(all.length),
        context.formatInt(locked.length),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(g, context.lbCell * .7, g, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    for (final (i, label) in [
                      l10n.lbFilterAll,
                      l10n.lbFilterUnlocked(context.formatInt(unlocked.length)),
                      l10n.lbFilterLocked(context.formatInt(locked.length)),
                    ].indexed)
                      Expanded(
                        flex: i == 0 ? 4 : 5,
                        child: _FilterBlock(
                          label: label,
                          selected: _tabController.index == i,
                          onTap: () => _tabController.animateTo(i),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                LBCellsBar(
                  count: 16,
                  value: completion,
                  semanticsLabel: l10n.acPercentComplete((completion * 100).round()),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.lbTrophiesSummary(
                    '${(completion * 100).round()}',
                    context.formatInt(claimed),
                    context.formatInt(waiting),
                  ),
                  style: LBText.label(context.lb, color: context.lb.inkDim).copyWith(fontSize: 9.5),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _TrophyList(achievements: all),
                _TrophyList(achievements: unlocked),
                _TrophyList(achievements: locked),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterBlock extends StatelessWidget {
  const _FilterBlock({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final kind = selected ? LBBlockKind.fill : LBBlockKind.outline;
    return Semantics(
      selected: selected,
      child: LBBlock(
        kind: kind,
        height: context.lbCell * 2.5,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        alignment: Alignment.center,
        onTap: onTap,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            maxLines: 1,
            style: LBText.button(p, color: LBBlock.foregroundOf(kind, p), size: 12)
                .copyWith(letterSpacing: 2),
          ),
        ),
      ),
    );
  }
}

class _TrophyList extends StatelessWidget {
  const _TrophyList({required this.achievements});

  final List<Achievement> achievements;

  @override
  Widget build(BuildContext context) {
    final g = context.lbGutter;
    if (achievements.isEmpty) {
      return ListView(
        padding: EdgeInsets.fromLTRB(g, 4, g, context.lbCell),
        children: [
          LBEmptyBlock(icon: LBIcon.trophy, title: AppLocalizations.of(context)!.acEmpty),
        ],
      );
    }
    return ListView.builder(
      padding: EdgeInsets.fromLTRB(g, 4, g, context.lbCell * 1.5),
      itemCount: achievements.length,
      itemBuilder: (context, i) => _TrophyRow(achievement: achievements[i]),
    );
  }
}

/// One achievement: rarity stripe, icon box, name + rarity word, the
/// description, and its state on the right — CLAIMED, the coins waiting to
/// be credited, progress, or a lock.
class _TrophyRow extends StatelessWidget {
  const _TrophyRow({required this.achievement});

  final Achievement achievement;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final a = achievement;
    final rarity = lbRarityColor(a.rarity);
    final unlocked = a.isUnlocked;
    final claimed = a.rewardClaimed;
    final iconBox = context.lbCell * 2;

    final Widget status;
    if (unlocked && claimed) {
      status = Text(l10n.lbClaimed, style: LBText.label(p, color: p.inkDim).copyWith(fontSize: 10));
    } else if (unlocked) {
      // Credited automatically on the next sync — a label, not a button.
      status = LBChip(
        kind: LBChipKind.gold,
        icon: LBIcon.coin,
        height: 26,
        label: l10n.lbCoinsReward(context.formatInt(a.coinReward)),
      );
    } else if (a.currentProgress > 0) {
      status = Text(
        '${context.formatInt(a.currentProgress)}/${context.formatInt(a.targetValue)}',
        style: LBText.button(
          p,
          color: a.rarity == AchievementRarity.legendary ? LB.gold : p.ink,
          size: 12,
        ).copyWith(letterSpacing: .4),
      );
    } else {
      status = LBPixelIcon(LBIcon.lock, cell: 3.4, color: p.inkDim, semanticLabel: l10n.acLocked);
    }

    return LBBlock(
      padding: EdgeInsets.zero,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: iconBox,
                  height: iconBox,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: unlocked ? rarity.withValues(alpha: .08) : p.lime.withValues(alpha: .03),
                    borderRadius: BorderRadius.circular(LB.blockRadius),
                    border: Border.all(
                      color: unlocked ? rarity.withValues(alpha: .55) : p.cellOff,
                    ),
                  ),
                  child: LBPixelIcon(
                    lbTrophyIcon(a.type),
                    cell: iconBox / 7,
                    color: unlocked ? rarity : p.inkDim,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: a.localizedTitle(l10n).toUpperCase(),
                              style: LBText.button(
                                p,
                                color: unlocked ? p.ink : p.inkMuted,
                                size: 12.5,
                              ).copyWith(letterSpacing: 1.4),
                            ),
                            const TextSpan(text: '  '),
                            TextSpan(
                              text: a.localizedRarityName(l10n).toUpperCase(),
                              style: LBText.label(p, color: rarity).copyWith(fontSize: 8.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        a.localizedDescription(l10n),
                        style: LBText.body(p, color: p.ink.withValues(alpha: unlocked ? .7 : .5), size: 11),
                      ),
                      if (!unlocked) ...[
                        const SizedBox(height: 3),
                        Text(
                          l10n.lbRewardCoinsXp(
                            context.formatInt(a.coinReward),
                            context.formatInt(a.xpReward),
                          ),
                          style: LBText.label(p, color: LB.gold.withValues(alpha: .7)).copyWith(fontSize: 9),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                status,
              ],
            ),
          ),
          // The rarity stripe. The rarity word beside the name says the same
          // thing, so colour never carries it alone.
          PositionedDirectional(
            start: 0,
            top: 0,
            bottom: 0,
            width: 5,
            child: ColoredBox(color: rarity.withValues(alpha: unlocked ? 1 : .55)),
          ),
        ],
      ),
    );
  }
}
