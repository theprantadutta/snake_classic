import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/utils/constants.dart';

/// Celebratory dialog shown when the player crosses a level threshold.
/// Shows the coin reward that ProgressionService credited for the level.
class LevelUpPopup extends StatelessWidget {
  final GameTheme theme;
  final int level;

  const LevelUpPopup({super.key, required this.theme, required this.level});

  static Future<void> show({
    required BuildContext context,
    required GameTheme theme,
    required int level,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (dialogContext) => LevelUpPopup(theme: theme, level: level),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.backgroundColor,
              theme.backgroundColor.withValues(alpha: 0.92),
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.45),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.accentColor.withValues(alpha: 0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [theme.accentColor, theme.foodColor],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.foodColor.withValues(alpha: 0.5),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Icon(
                Icons.military_tech_rounded,
                color: Colors.white,
                size: 56,
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  duration: 900.ms,
                  begin: const Offset(1, 1),
                  end: const Offset(1.08, 1.08),
                ),
            const SizedBox(height: 20),
            Text(
              'LEVEL UP!',
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You reached Level $level',
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.85),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            // Coin reward chip — the amount ProgressionService credited
            // for this level (already in the balance by the time this
            // dialog shows).
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 6),
                  Text(
                    '+${ProgressionService.coinRewardForLevel(level)} coins',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => dialogContextPop(context),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [theme.accentColor, theme.foodColor],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Text(
                  'NICE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(duration: 250.ms)
          .scale(begin: const Offset(0.85, 0.85)),
    );
  }

  void dialogContextPop(BuildContext context) => context.pop();
}
