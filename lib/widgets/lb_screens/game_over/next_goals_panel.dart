import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/server_text_l10n.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/providers/daily_challenges_provider.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/analytics/retention_events.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// "NEXT UP" on the game-over screen: today's daily challenges, Season XP to
/// the next tier, and tomorrow's login reward. Before this the screen only
/// showed the run itself, a dead end with no reason to come back (retention
/// plan 2026-11, C1; the "never end on a dead screen" idea).
///
/// Every row is optional; with nothing to show the panel takes no space.
class NextGoalsPanel extends ConsumerStatefulWidget {
  const NextGoalsPanel({super.key, required this.onOpen});

  /// Called with `daily` or `season` when a row is tapped, so the screen
  /// can finalize the run before navigating.
  final void Function(String goal) onOpen;

  @override
  ConsumerState<NextGoalsPanel> createState() => _NextGoalsPanelState();
}

class _NextGoalsPanelState extends ConsumerState<NextGoalsPanel> {
  /// Season XP total when the screen opened. The run's XP is flushed a beat
  /// later (GameCubit's post-game sync), so the difference is this run's.
  int? _seasonXpAtOpen;
  bool _logged = false;

  static int _seasonTotal(BattlePassState s) {
    var total = s.currentXP;
    for (var t = 1; t < s.currentTier; t++) {
      total += BattlePassTiers.xpRequiredForTier(t);
    }
    return total;
  }

  void _logShown(List<String> goals) {
    if (_logged || goals.isEmpty) return;
    _logged = true;
    if (!getIt.isRegistered<AnalyticsFacade>()) return;
    unawaited(getIt<AnalyticsFacade>().trackNextGoalShown(goals: goals.join(',')));
  }

  void _open(String goal) {
    if (getIt.isRegistered<AnalyticsFacade>()) {
      unawaited(getIt<AnalyticsFacade>().trackNextGoalTapped(goal: goal));
    }
    widget.onOpen(goal);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final daily = ref.watch(dailyChallengesProvider);
    final bp = context.watch<BattlePassCubit>().state;
    final coins = context.watch<CoinsCubit>().state;

    final rows = <Widget>[];
    final goals = <String>[];

    // Daily: the unfinished challenge closest to done.
    final open = daily.challenges.where((c) => !c.isCompleted).toList()
      ..sort((a, b) => b.progressPercentage.compareTo(a.progressPercentage));
    if (open.isNotEmpty) {
      final DailyChallenge next = open.first;
      goals.add('daily');
      rows.add(
        _GoalRow(
          icon: LBIcon.calendar,
          title: l10n.lbHomeDaily(
            '${daily.completedCount}',
            '${daily.totalCount}',
          ),
          subtitle: next.localizedDescription(l10n),
          progress: next.progressPercentage,
          trailing: '+${next.coinReward}¢',
          onTap: () => _open('daily'),
        ),
      );
    }

    // Season: tier, bar to the next one, and this run's XP once it lands.
    if (bp.isActive && bp.season != null && bp.currentTier < bp.maxTier) {
      final total = _seasonTotal(bp);
      _seasonXpAtOpen ??= total;
      final gained = total - _seasonXpAtOpen!;
      goals.add('season');
      rows.add(
        _GoalRow(
          icon: LBIcon.star,
          title: l10n.goNextSeasonTier('${bp.currentTier}'),
          subtitle: '${bp.currentXP} / ${bp.xpForNextTier} XP',
          progress: bp.tierProgress,
          trailing: gained > 0 ? l10n.goNextSeasonXp('$gained') : null,
          onTap: () => _open('season'),
        ),
      );
    }

    // Tomorrow: the login reward that's waiting, or tomorrow's.
    if (coins.status == CoinsStatus.ready && coins.dailyBonuses.isNotEmpty) {
      String? line;
      if (coins.canCollectDailyBonus) {
        final today = coins.availableDailyBonus;
        if (today != null) line = l10n.goNextBonusReady('${today.coins}');
      } else {
        final day = (coins.dailyBonusCurrentStreak % 7) + 1;
        final reward = coins.dailyBonuses
            .where((b) => b.day == day)
            .map((b) => b.coins)
            .firstOrNull;
        if (reward != null) line = l10n.goNextTomorrow('$day', '$reward');
      }
      if (line != null) {
        goals.add('tomorrow');
        rows.add(_GoalRow(icon: LBIcon.gift, title: line, gold: true));
      }
    }

    if (rows.isEmpty) return const SizedBox.shrink();
    WidgetsBinding.instance.addPostFrameCallback((_) => _logShown(goals));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LBSectionLabel(l10n.goNextUp, color: p.lime),
        for (final row in rows) ...[row, const SizedBox(height: 4)],
      ],
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.progress,
    this.trailing,
    this.onTap,
    this.gold = false,
  });

  final LBIcon icon;
  final String title;
  final String? subtitle;
  final double? progress;
  final String? trailing;
  final VoidCallback? onTap;
  final bool gold;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final fg = gold ? LB.gold : p.head;
    return LBBlock(
      kind: gold ? LBBlockKind.gold : LBBlockKind.outline,
      onTap: onTap,
      semanticLabel: [title, ?subtitle, ?trailing].join(', '),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          LBPixelIcon(icon, cell: 3, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: LBText.label(p, color: fg).copyWith(fontSize: 11),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: LBText.body(p, color: p.inkMuted, size: 11),
                  ),
                ],
                if (progress != null) ...[
                  const SizedBox(height: 6),
                  LBCellsBar(
                    count: 14,
                    value: progress!.clamp(0.0, 1.0),
                    color: fg,
                    offColor: fg.withValues(alpha: .14),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 10),
            Text(trailing!, style: LBText.button(p, color: LB.gold, size: 12)),
          ],
        ],
      ),
    );
  }
}
