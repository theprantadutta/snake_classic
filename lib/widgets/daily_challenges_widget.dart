import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/providers/daily_challenges_provider.dart';
import 'package:snake_classic/utils/constants.dart';

/// Compact widget for displaying daily challenges on the home screen
class DailyChallengesWidget extends ConsumerWidget {
  final GameTheme theme;
  final VoidCallback? onTap;
  final VoidCallback? onClaimReward;

  const DailyChallengesWidget({
    super.key,
    required this.theme,
    this.onTap,
    this.onClaimReward,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the provider for reactive state updates
    final state = ref.watch(dailyChallengesProvider);
    final challenges = state.challenges;
    final hasRewards = state.hasUnclaimedRewards;

    return GestureDetector(
          onTap: onTap,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.primaryColor.withValues(alpha: 0.3),
                  theme.accentColor.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasRewards
                    ? Colors.amber.withValues(alpha: 0.8)
                    : theme.primaryColor.withValues(alpha: 0.3),
                width: hasRewards ? 2 : 1,
              ),
              boxShadow: hasRewards
                  ? [
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.3),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.accentColor,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Daily Challenges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Progress indicator
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: state.allCompleted
                            ? Colors.green.withValues(alpha: 0.3)
                            : theme.primaryColor.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: state.allCompleted
                              ? Colors.green
                              : theme.primaryColor.withValues(
                                  alpha: 0.5,
                                ),
                        ),
                      ),
                      child: Text(
                        '${state.completedCount}/${state.totalCount}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: state.allCompleted
                              ? Colors.green
                              : theme.accentColor,
                        ),
                      ),
                    ),
                    if (hasRewards) ...[
                      const SizedBox(width: 8),
                      _buildClaimBadge(state),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Challenge list or empty state (no spinner — data shows instantly from cache)
                if (challenges.isEmpty)
                  _buildEmptyState()
                else
                  ...challenges
                      .take(3)
                      .map((challenge) => _buildChallengeItem(challenge, ref)),

                // Bonus indicator
                if (state.allCompleted && state.bonusCoins > 0)
                  _buildBonusIndicator(state),
              ],
            ),
          ),
        )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.1, end: 0, duration: 400.ms);
  }

  Widget _buildClaimBadge(DailyChallengesState state) {
    final unclaimedCount = state.challenges
        .where((c) => c.isCompleted && !c.claimedReward)
        .length;
    return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star, color: Colors.white, size: 14),
              const SizedBox(width: 4),
              Text(
                '$unclaimedCount',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.1, 1.1),
          duration: 800.ms,
        );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Text(
          'No challenges available',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildChallengeItem(DailyChallenge challenge, WidgetRef ref) {
    final isCompleted = challenge.isCompleted;
    final canClaim = challenge.canClaim;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: isCompleted
                  ? Colors.green.withValues(alpha: 0.2)
                  : theme.primaryColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: isCompleted ? Colors.green : theme.primaryColor,
                width: 2,
              ),
            ),
            child: isCompleted
                ? Icon(Icons.check, color: Colors.green, size: 16)
                : _getChallengeTypeIcon(challenge.type),
          ),
          const SizedBox(width: 10),

          // Challenge info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    decoration: challenge.claimedReward
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: challenge.progressPercentage,
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation(
                      isCompleted ? Colors.green : theme.accentColor,
                    ),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Progress text or claim button
          if (canClaim)
            _buildClaimButton(challenge, ref)
          else
            Text(
              '${challenge.currentProgress}/${challenge.targetValue}',
              style: TextStyle(
                color: isCompleted
                    ? Colors.green
                    : Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildClaimButton(DailyChallenge challenge, WidgetRef ref) {
    return GestureDetector(
          onTap: () async {
            final success = await ref.read(dailyChallengesProvider.notifier).claimReward(challenge.id);
            if (success && onClaimReward != null) {
              onClaimReward!();
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.monetization_on, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  '+${challenge.coinReward}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        )
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 600.ms,
        );
  }

  Widget _buildBonusIndicator(DailyChallengesState state) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.3),
            Colors.orange.withValues(alpha: 0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.celebration, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Text(
            'All Complete!',
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '+${state.bonusCoins} Bonus',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    ).animate().shimmer(duration: 2000.ms, delay: 500.ms);
  }

  Widget _getChallengeTypeIcon(ChallengeType type) {
    IconData iconData;
    switch (type) {
      case ChallengeType.score:
        iconData = Icons.stars;
        break;
      case ChallengeType.foodEaten:
        iconData = Icons.restaurant;
        break;
      case ChallengeType.gameMode:
        iconData = Icons.games;
        break;
      case ChallengeType.survival:
        iconData = Icons.timer;
        break;
      case ChallengeType.gamesPlayed:
        iconData = Icons.play_circle_outline;
        break;
    }
    return Icon(iconData, color: theme.primaryColor, size: 14);
  }
}
