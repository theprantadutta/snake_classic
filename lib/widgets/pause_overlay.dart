import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

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
              
              const SizedBox(height: 32),
              
              // Buttons
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
}