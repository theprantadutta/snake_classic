import 'package:flutter/material.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/utils/constants.dart';

class GameHUD extends StatelessWidget {
  final GameState gameState;
  final GameTheme theme;
  final VoidCallback onPause;
  final VoidCallback onHome;
  final bool isSmallScreen;
  final String? tournamentId;
  final TournamentGameMode? tournamentMode;

  const GameHUD({
    super.key,
    required this.gameState,
    required this.theme,
    required this.onPause,
    required this.onHome,
    this.isSmallScreen = false,
    this.tournamentId,
    this.tournamentMode,
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
          
          // Tournament indicator
          if (tournamentId != null && tournamentMode != null) ...[
            SizedBox(width: isSmallScreen ? 8 : 12),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 6 : 8,
                vertical: isSmallScreen ? 2 : 4,
              ),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                border: Border.all(
                  color: Colors.purple.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tournamentMode!.emoji,
                    style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                  ),
                  SizedBox(width: isSmallScreen ? 2 : 4),
                  Text(
                    'TOURNAMENT',
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: isSmallScreen ? 8 : 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const Spacer(),
          
          // Active power-ups display
          if (gameState.activePowerUps.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 12,
                vertical: isSmallScreen ? 4 : 6,
              ),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: gameState.activePowerUps
                    .where((powerUp) => !powerUp.isExpired)
                    .map((powerUp) => _buildPowerUpIndicator(powerUp, isSmallScreen))
                    .toList(),
              ),
            ),
          
          if (gameState.activePowerUps.isNotEmpty)
            SizedBox(width: isSmallScreen ? 8 : 12),
          
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
  
  Widget _buildPowerUpIndicator(ActivePowerUp powerUp, bool isSmallScreen) {
    final size = isSmallScreen ? 24.0 : 30.0;
    final progress = 1.0 - powerUp.progress; // Reverse progress for countdown
    final remainingTime = powerUp.remainingTime;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular progress background
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: isSmallScreen ? 2.0 : 3.0,
              backgroundColor: powerUp.type.color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(powerUp.type.color),
            ),
          ),
          
          // Power-up icon
          Container(
            width: size * 0.6,
            height: size * 0.6,
            decoration: BoxDecoration(
              color: powerUp.type.color.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: powerUp.type.color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Center(
              child: Text(
                powerUp.type.icon,
                style: TextStyle(
                  fontSize: isSmallScreen ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          
          // Time remaining tooltip (shown on long press - for future enhancement)
          Positioned(
            bottom: size + 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${remainingTime.inSeconds}s',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 8 : 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}