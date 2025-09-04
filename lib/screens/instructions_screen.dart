import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/gradient_button.dart';
import 'package:snake_classic/widgets/app_background.dart';

class InstructionsScreen extends StatelessWidget {
  const InstructionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Text(
              'HOW TO PLAY',
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 24,
                letterSpacing: 2,
                shadows: [
                  Shadow(
                    offset: const Offset(0, 2),
                    blurRadius: 4,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: theme.accentColor,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: AppBackground(
            theme: theme,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      
                      // Game Objective
                      _buildSection(
                        'OBJECTIVE',
                        'Control the snake to eat food and grow as long as possible without hitting walls or yourself!',
                        Icons.flag,
                        theme,
                        0,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Controls Section
                      _buildSection(
                        'CONTROLS',
                        '',
                        Icons.touch_app,
                        theme,
                        1,
                        children: [
                          _buildControlItem('Swipe Up ↑', 'Move snake up', theme),
                          _buildControlItem('Swipe Down ↓', 'Move snake down', theme),
                          _buildControlItem('Swipe Left ←', 'Move snake left', theme),
                          _buildControlItem('Swipe Right →', 'Move snake right', theme),
                          _buildControlItem('Tap Screen', 'Pause/Resume game', theme),
                          const SizedBox(height: 8),
                          _buildControlItem('Arrow Keys (Desktop)', 'Change direction', theme),
                          _buildControlItem('WASD (Desktop)', 'Change direction', theme),
                          _buildControlItem('Spacebar (Desktop)', 'Pause/Resume game', theme),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Food Types
                      _buildSection(
                        'FOOD TYPES',
                        '',
                        Icons.apple,
                        theme,
                        2,
                        children: [
                          _buildFoodItem('Normal Food', '10 points', theme.foodColor, theme),
                          _buildFoodItem('Bonus Food', '25 points', Colors.orange, theme),
                          _buildFoodItem('Special Food', '50 points + Level Up', const Color(0xFFFFD700), theme),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Rules
                      _buildSection(
                        'RULES',
                        '',
                        Icons.rule,
                        theme,
                        3,
                        children: [
                          _buildRuleItem('• Eat food to grow and increase score', theme),
                          _buildRuleItem('• Snake speeds up as you level up', theme),
                          _buildRuleItem('• Game ends if you hit walls or yourself', theme),
                          _buildRuleItem('• Special food appears every 10 normal foods', theme),
                          _buildRuleItem('• Bonus food expires after 15 seconds', theme),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Tips
                      _buildSection(
                        'PRO TIPS',
                        '',
                        Icons.lightbulb,
                        theme,
                        4,
                        children: [
                          _buildTipItem('Plan your moves ahead of time', theme),
                          _buildTipItem('Use edges to create safe spaces', theme),
                          _buildTipItem('Watch for visual swipe feedback', theme),
                          _buildTipItem('Practice different difficulty levels', theme),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Back to Game Button
                      Center(
                        child: GradientButton(
                          onPressed: () => Navigator.of(context).pop(),
                          text: 'BACK TO GAME',
                          primaryColor: theme.accentColor,
                          secondaryColor: theme.foodColor,
                          icon: Icons.arrow_back,
                          width: 250,
                        ),
                      ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.1),
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: theme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          if (description.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.8),
                fontSize: 16,
                height: 1.5,
              ),
            ),
          ],
          if (children != null) ...[
            const SizedBox(height: 16),
            ...children,
          ],
        ],
      ),
    ).animate().fadeIn(delay: (200 + index * 100).ms).slideY(begin: 0.3);
  }

  Widget _buildControlItem(String gesture, String action, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 140,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              gesture,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              action,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.8),
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodItem(String name, String points, Color color, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: theme.foodColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              points,
              style: TextStyle(
                color: theme.foodColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String rule, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        rule,
        style: TextStyle(
          color: theme.accentColor.withValues(alpha: 0.8),
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildTipItem(String tip, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.star,
            color: theme.foodColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.8),
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}