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
    final isUrgent = progress < 0.25; // Last 25% of duration
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simple glow effect for active power-ups
          if (powerUp.type == PowerUpType.invincibility || 
              powerUp.type == PowerUpType.speedBoost ||
              isUrgent)
            Container(
              width: size * 1.2,
              height: size * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: powerUp.type.color.withValues(alpha: isUrgent ? 0.3 : 0.2),
                    blurRadius: 8,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          
          // Circular progress background
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: isSmallScreen ? 2.5 : 3.5,
              strokeCap: StrokeCap.round,
              backgroundColor: powerUp.type.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(
                isUrgent 
                  ? Color.lerp(powerUp.type.color, Colors.red, 0.3)!
                  : powerUp.type.color
              ),
            ),
          ),
          
          // Power-up icon container
          Container(
            width: size * 0.65,
            height: size * 0.65,
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
              border: isUrgent ? Border.all(
                color: Colors.white.withValues(alpha: 0.6),
                width: 1.0,
              ) : null,
            ),
            child: Center(
              child: Text(
                powerUp.type.icon,
                style: TextStyle(
                  fontSize: isSmallScreen ? (isUrgent ? 11 : 10) : (isUrgent ? 14 : 12),
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),
          
          // Time remaining indicator
          if (progress < 0.5) // Only show when halfway through duration
            Positioned(
              bottom: size * 0.85,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 3 : 4, 
                  vertical: isSmallScreen ? 1 : 2
                ),
                decoration: BoxDecoration(
                  color: isUrgent ? Colors.red.shade800 : Colors.black87,
                  borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                  border: isUrgent ? Border.all(color: Colors.white, width: 0.5) : null,
                ),
                child: Text(
                  '${remainingTime.inSeconds}${isUrgent ? '!' : ''}',
                  style: TextStyle(
                    color: isUrgent ? Colors.white : Colors.white70,
                    fontSize: isSmallScreen ? 8 : 9,
                    fontWeight: isUrgent ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}