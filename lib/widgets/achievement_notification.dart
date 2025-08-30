import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snake_classic/models/achievement.dart';

class AchievementNotification extends StatelessWidget {
  final Achievement achievement;
  final VoidCallback? onDismiss;

  const AchievementNotification({
    super.key,
    required this.achievement,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              achievement.rarityColor.withValues(alpha: 0.9),
              achievement.rarityColor.withValues(alpha: 0.7),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: achievement.rarityColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Achievement Icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    achievement.icon,
                    color: Colors.white,
                    size: 32,
                  ),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                 .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.1, 1.1), duration: 1000.ms),

                const SizedBox(width: 16),

                // Achievement Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Achievement Unlocked!',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        achievement.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      
                      const SizedBox(height: 4),
                      
                      Text(
                        achievement.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Close Button
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Points and Rarity
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    achievement.rarityName.toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${achievement.points} pts',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      )
      .animate()
      .slideY(begin: -1.0, duration: 500.ms, curve: Curves.elasticOut)
      .fadeIn(duration: 300.ms),
    );
  }

  static void show(BuildContext context, Achievement achievement) {
    final overlay = Overlay.of(context);
    OverlayEntry? overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 16,
        left: 0,
        right: 0,
        child: AchievementNotification(
          achievement: achievement,
          onDismiss: () {
            overlayEntry?.remove();
          },
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Auto dismiss after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      overlayEntry?.remove();
    });
  }
}