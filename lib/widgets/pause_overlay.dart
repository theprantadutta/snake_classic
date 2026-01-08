import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/gradient_button.dart';
import 'package:snake_classic/screens/store_screen.dart';
import 'package:snake_classic/screens/premium_benefits_screen.dart';

class PauseOverlay extends StatelessWidget {
  final GameTheme theme;
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onHome;

  const PauseOverlay({
    super.key,
    required this.theme,
    required this.onResume,
    required this.onRestart,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pause Icon
              Icon(
                Icons.pause_circle_filled,
                size: 64,
                color: theme.accentColor,
              ).animate().scale(delay: 100.ms),

              const SizedBox(height: 16),

              // Pause Text
              Text(
                'PAUSED',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 24),

              // Store Access Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildStoreButton(
                    context: context,
                    icon: Icons.star,
                    label: 'Premium',
                    colors: [Colors.purple, Colors.blue],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PremiumBenefitsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildStoreButton(
                    context: context,
                    icon: Icons.store,
                    label: 'Store',
                    colors: [Colors.orange, Colors.amber],
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const StoreScreen(),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 250.ms),

              const SizedBox(height: 16),

              // Game Guide Section (moved from game screen)
              _buildGameGuideSection(),

              const SizedBox(height: 16),

              // Main Action Buttons
              Column(
                children: [
                  GradientButton(
                    onPressed: onResume,
                    text: 'RESUME',
                    primaryColor: theme.accentColor,
                    secondaryColor: theme.foodColor,
                    icon: Icons.play_arrow,
                    width: 200,
                  ).animate().slideX(begin: -1, delay: 300.ms),

                  const SizedBox(height: 16),

                  GradientButton(
                    onPressed: onRestart,
                    text: 'RESTART',
                    primaryColor: theme.accentColor.withValues(alpha: 0.8),
                    secondaryColor: theme.accentColor.withValues(alpha: 0.6),
                    icon: Icons.refresh,
                    width: 200,
                    outlined: true,
                  ).animate().slideX(begin: 1, delay: 400.ms),

                  const SizedBox(height: 16),

                  GradientButton(
                    onPressed: onHome,
                    text: 'HOME',
                    primaryColor: theme.snakeColor.withValues(alpha: 0.8),
                    secondaryColor: theme.snakeColor.withValues(alpha: 0.6),
                    icon: Icons.home,
                    width: 200,
                    outlined: true,
                  ).animate().slideY(begin: 1, delay: 500.ms),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameGuideSection() {
    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: false,
          tilePadding: const EdgeInsets.symmetric(horizontal: 12),
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.help_outline,
                color: theme.accentColor.withValues(alpha: 0.8),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'GAME GUIDE',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.9),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          iconColor: theme.accentColor,
          collapsedIconColor: theme.accentColor.withValues(alpha: 0.6),
          children: [
            // Food types
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildFoodItem('🍎', '10 pts'),
                _buildFoodItem('✨', '25 pts'),
                _buildFoodItem('⭐', '50 pts'),
              ],
            ),
            const SizedBox(height: 8),
            // Control hints
            Text(
              'Swipe or tap D-pad to move\nAvoid walls & yourself',
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.7),
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: 280.ms);
  }

  Widget _buildFoodItem(String emoji, String points) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 2),
        Text(
          points,
          style: TextStyle(
            color: theme.foodColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildStoreButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors.map((c) => c.withValues(alpha: 0.2)).toList(),
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colors.first.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: colors.first, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: colors.first,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
