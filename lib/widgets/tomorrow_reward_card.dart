import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/lb/lb.dart';

/// "Come back tomorrow for X" strip on the game-over screen.
///
/// The daily login bonus already existed, but it was only ever a *surprise* —
/// the player discovered it on their next launch, which means it could never
/// influence the decision they are making right now, at the exact moment they
/// are deciding whether there is a reason to open this app again tomorrow.
/// An unannounced reward cannot pull anyone back; an announced one can. Same
/// bonus, moved to where it can do retention work.
///
/// Renders nothing when there is nothing concrete to promise (bonus data not
/// loaded yet, or the next day carries no coins), so it never occupies space
/// with a vague message.
class TomorrowRewardCard extends StatelessWidget {
  const TomorrowRewardCard({
    super.key,
    required this.theme,
    this.compact = false,
  });

  final GameTheme theme;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CoinsCubit, CoinsState>(
      // The card only depends on the 7-day ladder and where the player sits on
      // it — not on their balance, which changes constantly during a game-over.
      buildWhen: (prev, curr) =>
          prev.dailyBonuses != curr.dailyBonuses ||
          prev.dailyBonusCurrentStreak != curr.dailyBonusCurrentStreak ||
          prev.wasDailyBonusClaimedToday != curr.wasDailyBonusClaimedToday,
      builder: (context, state) {
        final next = _nextReward(state);
        if (next == null || next.coins <= 0) return const SizedBox.shrink();

        final l10n = AppLocalizations.of(context)!;
        final p = context.lb;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: compact ? 4 : 6),
          child: LBBlock(
            kind: LBBlockKind.gold,
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: compact ? 10 : 12),
            child: Row(
              children: [
                LBPixelIcon(LBIcon.gift, cell: compact ? 3.4 : 4, color: LB.gold),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.goTomorrowLabel.toUpperCase(),
                        style: LBText.label(p, color: LB.gold),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        l10n.goTomorrowReward(next.coins, next.day),
                        style: LBText.body(p, color: p.ink, size: compact ? 11.5 : 12.5),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// The bonus the player will be able to claim on their next calendar day.
  ///
  /// Walks the 7-day ladder for the first uncollected rung, skipping today's
  /// if it is still unclaimed — promising a reward they could collect right
  /// now by relaunching would be misleading, and the daily-bonus popup already
  /// handles that case on Home.
  DailyLoginBonus? _nextReward(CoinsState state) {
    final ladder = state.dailyBonuses;
    if (ladder.isEmpty) return null;

    // Claimed today → the next rung is genuinely tomorrow's.
    // Not claimed today → today's rung is still pending, so tomorrow's is the
    // one after it.
    final claimedToday = state.wasDailyBonusClaimedToday;
    final uncollected = ladder.where((b) => !b.isCollected).toList();
    if (uncollected.isEmpty) return null;

    if (claimedToday) return uncollected.first;
    return uncollected.length > 1 ? uncollected[1] : null;
  }
}
