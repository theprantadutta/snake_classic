import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/typography.dart';

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

        return Container(
          width: double.infinity,
          margin: EdgeInsets.symmetric(vertical: compact ? 6 : 8),
          padding: EdgeInsets.symmetric(
            horizontal: 14,
            vertical: compact ? 10 : 12,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber.withValues(alpha: 0.16),
                theme.accentColor.withValues(alpha: 0.10),
              ],
            ),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.35),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.card_giftcard_rounded,
                color: Colors.amber.withValues(alpha: 0.95),
                size: compact ? 20 : 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.goTomorrowLabel,
                      style: TextStyle(
                        fontSize: compact ? 9 : 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.amber.withValues(alpha: 0.9),
                        letterSpacing: context.letterSpacing(1.4),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      l10n.goTomorrowReward(next.coins, next.day),
                      style: TextStyle(
                        fontSize: compact ? 12 : 13.5,
                        height: 1.3,
                        fontWeight: FontWeight.w600,
                        color: theme.primaryColor.withValues(alpha: 0.95),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
