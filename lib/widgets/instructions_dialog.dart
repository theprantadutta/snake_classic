import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

class InstructionsDialog extends StatelessWidget {
  final GameTheme theme;

  const InstructionsDialog({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.backgroundColor,
              theme.backgroundColor.withValues(alpha: 0.95),
            ],
          ),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.6),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: theme.accentColor.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'HOW TO PLAY',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    onPressed: () => context.pop(),
                    icon: Icon(Icons.close, color: theme.accentColor, size: 28),
                  ),
                ],
              ).gameEntrance(delay: 50.ms),

              const SizedBox(height: 24),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Game Objective
                      _buildSection(
                        'OBJECTIVE',
                        'Control the snake to eat food and grow as long as possible without hitting walls or yourself!',
                        Icons.flag,
                        theme,
                        0,
                      ),

                      const SizedBox(height: 20),

                      // Controls Section
                      _buildSection(
                        'CONTROLS',
                        '',
                        Icons.touch_app,
                        theme,
                        1,
                        children: [
                          _buildControlItem(
                            'Swipe Up ↑',
                            'Move snake up',
                            theme,
                          ),
                          _buildControlItem(
                            'Swipe Down ↓',
                            'Move snake down',
                            theme,
                          ),
                          _buildControlItem(
                            'Swipe Left ←',
                            'Move snake left',
                            theme,
                          ),
                          _buildControlItem(
                            'Swipe Right →',
                            'Move snake right',
                            theme,
                          ),
                          _buildControlItem(
                            'Tap Screen',
                            'Pause/Resume game',
                            theme,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Food Types
                      _buildSection(
                        'FOOD TYPES',
                        '',
                        Icons.apple,
                        theme,
                        2,
                        children: [
                          _buildFoodItem(
                            'Normal Food',
                            '10 points',
                            theme.foodColor,
                            theme,
                          ),
                          _buildFoodItem(
                            'Bonus Food',
                            '25 points',
                            Colors.orange,
                            theme,
                          ),
                          _buildFoodItem(
                            'Special Food',
                            '50 points + Level Up',
                            const Color(0xFFFFD700),
                            theme,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Rules
                      _buildSection(
                        'RULES',
                        '',
                        Icons.rule,
                        theme,
                        3,
                        children: [
                          _buildRuleItem(
                            '• Eat food to grow and increase score',
                            theme,
                          ),
                          _buildRuleItem(
                            '• Snake speeds up as you level up',
                            theme,
                          ),
                          _buildRuleItem(
                            '• Game ends if you hit walls or yourself',
                            theme,
                          ),
                          _buildRuleItem(
                            '• Special food appears every 10 normal foods',
                            theme,
                          ),
                          _buildRuleItem(
                            '• Bonus food expires after 15 seconds',
                            theme,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Tips
                      _buildSection(
                        'PRO TIPS',
                        '',
                        Icons.lightbulb,
                        theme,
                        4,
                        children: [
                          _buildTipItem('Plan your moves ahead of time', theme),
                          _buildTipItem(
                            'Use edges to create safe spaces',
                            theme,
                          ),
                          _buildTipItem(
                            'Watch for visual swipe feedback',
                            theme,
                          ),
                          _buildTipItem(
                            'Practice different difficulty levels',
                            theme,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Close Button
              GradientButton(
                    onPressed: () => context.pop(),
                    text: 'GOT IT!',
                    primaryColor: theme.accentColor,
                    secondaryColor: theme.foodColor,
                    icon: Icons.check,
                    width: 160,
                  )
                  .gamePop(delay: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    String title,
    String description,
    IconData icon,
    GameTheme theme,
    int index, {
    List<Widget>? children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: theme.accentColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.8),
                fontSize: 14,
                height: 1.4,
              ),
            ),
          ],
          if (children != null) ...[const SizedBox(height: 12), ...children],
        ],
      ),
    ).gameListItem(index);
  }

  Widget _buildControlItem(String gesture, String action, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 120,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              gesture,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              action,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(
    String name,
    String points,
    Color color,
    GameTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            points,
            style: TextStyle(
              color: theme.foodColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String rule, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Text(
        rule,
        style: TextStyle(
          color: theme.accentColor.withValues(alpha: 0.8),
          fontSize: 13,
          height: 1.3,
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.star, color: theme.foodColor, size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
