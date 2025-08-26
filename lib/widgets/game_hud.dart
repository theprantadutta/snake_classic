import 'package:flutter/material.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';

class GameHUD extends StatelessWidget {
  final GameState gameState;
  final GameTheme theme;
  final VoidCallback onPause;
  final VoidCallback onHome;

  const GameHUD({
    super.key,
    required this.gameState,
    required this.theme,
    required this.onPause,
    required this.onHome,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.backgroundColor,
            theme.backgroundColor.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: Row(
        children: [
          // Home button
          IconButton(
            onPressed: onHome,
            icon: Icon(
              Icons.home,
              color: theme.accentColor,
            ),
          ),
          
          const Spacer(),
          
          // Score section
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SCORE',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${gameState.score}',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const Spacer(),
          
          // Pause button
          IconButton(
            onPressed: onPause,
            icon: Icon(
              gameState.status == GameStatus.playing 
                ? Icons.pause 
                : Icons.play_arrow,
              color: theme.accentColor,
            ),
          ),
        ],
      ),
    );
  }
}