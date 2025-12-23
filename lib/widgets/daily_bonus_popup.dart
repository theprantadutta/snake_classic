import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snake_classic/utils/constants.dart';

/// Data class for daily bonus reward
class DailyBonusReward {
  final int day;
  final int coins;
  final String? bonusItem;
  final bool claimed;

  const DailyBonusReward({
    required this.day,
    required this.coins,
    this.bonusItem,
    this.claimed = false,
  });

  factory DailyBonusReward.fromJson(Map<String, dynamic> json) {
    return DailyBonusReward(
      day: json['day'],
      coins: json['coins'],
      bonusItem: json['bonus_item'],
      claimed: json['claimed'] ?? false,
    );
  }
}

/// Daily bonus status from API
class DailyBonusStatus {
  final bool canClaim;
  final int currentStreak;
  final DateTime? lastClaimDate;
  final DailyBonusReward? todayReward;
  final List<DailyBonusReward> weekRewards;

  const DailyBonusStatus({
    required this.canClaim,
    required this.currentStreak,
    this.lastClaimDate,
    this.todayReward,
    required this.weekRewards,
  });

  factory DailyBonusStatus.fromJson(Map<String, dynamic> json) {
    return DailyBonusStatus(
      canClaim: json['can_claim'] ?? false,
      currentStreak: json['current_streak'] ?? 0,
      lastClaimDate: json['last_claim_date'] != null
          ? DateTime.parse(json['last_claim_date'])
          : null,
      todayReward: json['today_reward'] != null
          ? DailyBonusReward.fromJson(json['today_reward'])
          : null,
      weekRewards: (json['week_rewards'] as List?)
              ?.map((r) => DailyBonusReward.fromJson(r))
              .toList() ??
          [],
    );
  }

  /// Create a default/fallback status for offline mode
  factory DailyBonusStatus.offline() {
    return DailyBonusStatus(
      canClaim: false,
      currentStreak: 0,
      weekRewards: _defaultWeekRewards,
    );
  }

  static const List<DailyBonusReward> _defaultWeekRewards = [
    DailyBonusReward(day: 1, coins: 10),
    DailyBonusReward(day: 2, coins: 15),
    DailyBonusReward(day: 3, coins: 20, bonusItem: 'Speed Boost'),
    DailyBonusReward(day: 4, coins: 25),
    DailyBonusReward(day: 5, coins: 30, bonusItem: '2x XP Boost'),
    DailyBonusReward(day: 6, coins: 40),
    DailyBonusReward(day: 7, coins: 50, bonusItem: 'Premium Theme'),
  ];
}

/// A popup dialog for daily login bonus
class DailyBonusPopup extends StatefulWidget {
  final GameTheme theme;
  final DailyBonusStatus status;
  final VoidCallback onClaim;
  final VoidCallback onClose;
  final bool isLoading;

  const DailyBonusPopup({
    super.key,
    required this.theme,
    required this.status,
    required this.onClaim,
    required this.onClose,
    this.isLoading = false,
  });

  /// Show the daily bonus popup as a dialog
  /// [onClaim] is called when the user taps claim - it should handle the reward immediately
  /// and queue any API calls for background sync (offline-first approach)
  static Future<void> show({
    required BuildContext context,
    required GameTheme theme,
    required DailyBonusStatus status,
    required Future<bool> Function() onClaim,
  }) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.85),
      builder: (dialogContext) {
        return DailyBonusPopup(
          theme: theme,
          status: status,
          isLoading: false, // Never show loading - instant feedback
          onClaim: () async {
            // Close popup immediately for instant feedback
            Navigator.of(dialogContext).pop();
            // Call the claim handler (handles coins + background sync)
            await onClaim();
          },
          onClose: () => Navigator.of(dialogContext).pop(),
        );
      },
    );
  }

  @override
  State<DailyBonusPopup> createState() => _DailyBonusPopupState();
}

class _DailyBonusPopupState extends State<DailyBonusPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todayReward = widget.status.todayReward;
    final currentDay = widget.status.currentStreak > 0
        ? widget.status.currentStreak
        : 1;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360),
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.3),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Week progress
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildWeekProgress(currentDay),
            ),

            const SizedBox(height: 16),

            // Today's reward
            if (todayReward != null) _buildTodayReward(todayReward),

            const SizedBox(height: 20),

            // Claim button
            _buildClaimButton(),

            const SizedBox(height: 16),

            // Close button (if can't claim)
            if (!widget.status.canClaim) _buildCloseButton(),

            const SizedBox(height: 16),
          ],
        ),
      ).animate().scale(
            begin: const Offset(0.8, 0.8),
            end: const Offset(1, 1),
            duration: 300.ms,
            curve: Curves.easeOutBack,
          ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.3),
            Colors.orange.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        children: [
          // Close button
          Align(
            alignment: Alignment.topRight,
            child: GestureDetector(
              onTap: widget.onClose,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.theme.backgroundColor.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: widget.theme.accentColor.withValues(alpha: 0.7),
                  size: 20,
                ),
              ),
            ),
          ),

          // Gift icon with animation
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Text(
              '🎁',
              style: TextStyle(fontSize: 40),
            ),
          )
              .animate(
                onPlay: (controller) => controller.repeat(reverse: true),
              )
              .scale(
                begin: const Offset(1, 1),
                end: const Offset(1.1, 1.1),
                duration: 1000.ms,
              ),

          const SizedBox(height: 12),

          Text(
            'Daily Bonus',
            style: TextStyle(
              color: widget.theme.accentColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            widget.status.canClaim
                ? 'Claim your daily reward!'
                : 'Come back tomorrow!',
            style: TextStyle(
              color: widget.theme.accentColor.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),

          if (widget.status.currentStreak > 1) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔥', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.status.currentStreak} day streak!',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWeekProgress(int currentDay) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(7, (index) {
            final day = index + 1;
            final reward = widget.status.weekRewards.length > index
                ? widget.status.weekRewards[index]
                : DailyBonusReward(day: day, coins: 10 + (day * 5));

            final isClaimed = reward.claimed;
            final isToday = day == currentDay;
            final isFuture = day > currentDay;

            return _buildDayCircle(
              day: day,
              coins: reward.coins,
              hasBonus: reward.bonusItem != null,
              isClaimed: isClaimed,
              isToday: isToday,
              isFuture: isFuture,
            );
          }),
        ),
      ],
    );
  }

  Widget _buildDayCircle({
    required int day,
    required int coins,
    required bool hasBonus,
    required bool isClaimed,
    required bool isToday,
    required bool isFuture,
  }) {
    Color bgColor;
    Color borderColor;
    Widget icon;

    if (isClaimed) {
      bgColor = Colors.green.withValues(alpha: 0.3);
      borderColor = Colors.green;
      icon = const Icon(Icons.check, color: Colors.green, size: 16);
    } else if (isToday) {
      bgColor = Colors.amber.withValues(alpha: 0.3);
      borderColor = Colors.amber;
      icon = Text(
        '🎁',
        style: TextStyle(fontSize: hasBonus ? 14 : 12),
      );
    } else {
      bgColor = widget.theme.backgroundColor.withValues(alpha: 0.5);
      borderColor = widget.theme.accentColor.withValues(alpha: 0.3);
      icon = Text(
        hasBonus ? '⭐' : '🪙',
        style: TextStyle(
          fontSize: 12,
          color: isFuture ? Colors.grey : null,
        ),
      );
    }

    Widget circle = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: isToday ? 2 : 1),
        boxShadow: isToday
            ? [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
      child: Center(child: icon),
    );

    if (isToday && widget.status.canClaim) {
      circle = circle
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1), duration: 800.ms);
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        circle,
        const SizedBox(height: 4),
        Text(
          'D$day',
          style: TextStyle(
            color: isToday
                ? Colors.amber
                : widget.theme.accentColor.withValues(alpha: isFuture ? 0.4 : 0.7),
            fontSize: 10,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildTodayReward(DailyBonusReward reward) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.amber.withValues(alpha: 0.15),
            Colors.orange.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Text(
            "Today's Reward",
            style: TextStyle(
              color: widget.theme.accentColor.withValues(alpha: 0.7),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Coins
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🪙', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 8),
                    Text(
                      '+${reward.coins}',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // Bonus item if any
              if (reward.bonusItem != null) ...[
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.purple.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.purple.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🎁', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        reward.bonusItem!,
                        style: const TextStyle(
                          color: Colors.purple,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildClaimButton() {
    if (!widget.status.canClaim) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: widget.theme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: widget.theme.accentColor.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.access_time,
              color: widget.theme.accentColor.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'Already claimed today',
              style: TextStyle(
                color: widget.theme.accentColor.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: widget.isLoading ? null : widget.onClaim,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.amber, Colors.orange],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: widget.isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '🎉',
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'CLAIM REWARD',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
      ),
    ).animate(delay: 300.ms).fadeIn().scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildCloseButton() {
    return TextButton(
      onPressed: widget.onClose,
      child: Text(
        'Close',
        style: TextStyle(
          color: widget.theme.accentColor.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
    );
  }
}
