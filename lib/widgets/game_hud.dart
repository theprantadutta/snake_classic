import 'package:flutter/material.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';

class GameHUD extends StatelessWidget {
  final GameState gameState;
  final GameTheme theme;
  final VoidCallback onPause;
  final VoidCallback onHome;
  final bool isSmallScreen;

  const GameHUD({
    super.key,
    required this.gameState,
    required this.theme,
    required this.onPause,
    required this.onHome,
    this.isSmallScreen = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
              size: isSmallScreen ? 20 : 24,
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
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1,
                ),
              ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              Text(
                '${gameState.score}',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: isSmallScreen ? 20 : 24,
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
              size: isSmallScreen ? 20 : 24,
            ),
          ),
        ],
      ),
    );
  }
}