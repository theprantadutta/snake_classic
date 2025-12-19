import 'package:flutter/material.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/utils/constants.dart';

class GameHUD extends StatefulWidget {
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
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  int _displayedScore = 0;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _displayedScore = widget.gameState.score;
  }

  @override
  void didUpdateWidget(GameHUD oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Check if any power-up is urgent (< 3 seconds)
    final hasUrgentPowerUp = widget.gameState.activePowerUps.any(
      (p) => !p.isExpired && p.remainingTime.inSeconds <= 3,
    );
    if (hasUrgentPowerUp && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!hasUrgentPowerUp && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // Getters for cleaner code
  GameState get gameState => widget.gameState;
  GameTheme get theme => widget.theme;
  bool get isSmallScreen => widget.isSmallScreen;
  String? get tournamentId => widget.tournamentId;
  TournamentGameMode? get tournamentMode => widget.tournamentMode;

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
            onPressed: widget.onHome,
            icon: Icon(
              Icons.home,
              color: theme.accentColor,
              size: isSmallScreen ? 20 : 24,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
            constraints: const BoxConstraints(),
          ),

          const Spacer(),

          // Score section with progress bar, food indicator, and combo
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Score label with food type indicator and combo
                Row(
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
                    if (gameState.food != null) ...[
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      _buildFoodTypeIndicator(gameState.food!),
                    ],
                    // Combo indicator (show when combo >= 3)
                    if (gameState.currentCombo >= 3) ...[
                      SizedBox(width: isSmallScreen ? 4 : 6),
                      _buildComboIndicator(),
                    ],
                  ],
                ),
              SizedBox(height: isSmallScreen ? 2 : 4),
              // Animated score counter
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: _displayedScore, end: gameState.score),
                duration: const Duration(milliseconds: 300),
                onEnd: () {
                  _displayedScore = gameState.score;
                },
                builder: (context, value, child) {
                  return Text(
                    '$value',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: isSmallScreen ? 20 : 24,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
              SizedBox(height: isSmallScreen ? 4 : 6),
                // Level progress bar
                _buildLevelProgressBar(),
              ],
            ),
          ),

          // Enhanced Tournament indicator
          if (tournamentId != null && tournamentMode != null) ...[
            SizedBox(width: isSmallScreen ? 8 : 12),
            _buildTournamentIndicator(isSmallScreen),
          ],

          const Spacer(),

          // Active power-ups display
          if (gameState.activePowerUps.isNotEmpty)
            Flexible(
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 6 : 10,
                  vertical: isSmallScreen ? 3 : 5,
                ),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 14),
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
            ),

          if (gameState.activePowerUps.isNotEmpty)
            SizedBox(width: isSmallScreen ? 6 : 10),

          // Pause button
          IconButton(
            onPressed: widget.onPause,
            icon: Icon(
              gameState.status == GameStatus.playing
                ? Icons.pause
                : Icons.play_arrow,
              color: theme.accentColor,
              size: isSmallScreen ? 20 : 24,
            ),
            padding: EdgeInsets.all(isSmallScreen ? 4 : 8),
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  /// Builds a small food type indicator showing current food on board
  Widget _buildFoodTypeIndicator(Food food) {
    final emoji = switch (food.type) {
      FoodType.normal => '🍎',
      FoodType.bonus => '⭐',
      FoodType.special => '💎',
    };
    final color = switch (food.type) {
      FoodType.normal => Colors.red,
      FoodType.bonus => Colors.amber,
      FoodType.special => Colors.purple,
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 4 : 6,
        vertical: isSmallScreen ? 1 : 2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 4,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
          ),
          SizedBox(width: isSmallScreen ? 2 : 3),
          Text(
            '+${food.type.points}',
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 9 : 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a combo indicator showing current streak and multiplier
  Widget _buildComboIndicator() {
    final combo = gameState.currentCombo;
    final multiplier = gameState.comboMultiplier;

    // Color intensity based on combo level
    final color = combo >= 20
        ? Colors.red
        : combo >= 10
            ? Colors.orange
            : combo >= 5
                ? Colors.amber
                : Colors.green;

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 1.15),
      duration: const Duration(milliseconds: 200),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 6 : 8,
          vertical: isSmallScreen ? 2 : 3,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.3),
              color.withValues(alpha: 0.15),
            ],
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
          border: Border.all(
            color: color.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '🔥',
              style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
            ),
            SizedBox(width: isSmallScreen ? 2 : 3),
            Text(
              'x$combo',
              style: TextStyle(
                color: color,
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (multiplier > 1.0) ...[
              SizedBox(width: isSmallScreen ? 3 : 4),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 3 : 4,
                  vertical: isSmallScreen ? 1 : 2,
                ),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${multiplier.toStringAsFixed(1)}X',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isSmallScreen ? 8 : 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds a progress bar showing progress to next level
  Widget _buildLevelProgressBar() {
    // Calculate progress within current level
    final previousLevelTarget = (gameState.level - 1) * 100;
    final currentLevelTarget = gameState.level * 100;
    final levelRange = currentLevelTarget - previousLevelTarget;
    final scoreInLevel = gameState.score - previousLevelTarget;
    final progress = (scoreInLevel / levelRange).clamp(0.0, 1.0);
    final isNearLevelUp = progress >= 0.8;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar
        Container(
          width: isSmallScreen ? 80 : 100,
          height: isSmallScreen ? 4 : 5,
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(isSmallScreen ? 2 : 3),
          ),
          child: Stack(
            children: [
              // Progress fill with gradient
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: (isSmallScreen ? 80 : 100) * progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isNearLevelUp
                        ? [theme.accentColor, Colors.amber, Colors.orange]
                        : [theme.snakeColor, theme.accentColor],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 2 : 3),
                  boxShadow: isNearLevelUp
                      ? [
                          BoxShadow(
                            color: Colors.amber.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 1,
                          ),
                        ]
                      : null,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: isSmallScreen ? 2 : 3),
        // Level indicator
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LVL ${gameState.level}',
              style: TextStyle(
                color: isNearLevelUp
                    ? Colors.amber
                    : theme.accentColor.withValues(alpha: 0.7),
                fontSize: isSmallScreen ? 8 : 9,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
            if (gameState.level < 10) ...[
              Text(
                ' → $currentLevelTarget',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.5),
                  fontSize: isSmallScreen ? 7 : 8,
                ),
              ),
            ] else ...[
              Text(
                ' MAX',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: isSmallScreen ? 7 : 8,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
  
  Widget _buildPowerUpIndicator(ActivePowerUp powerUp, bool isSmallScreen) {
    final size = isSmallScreen ? 24.0 : 30.0;
    final progress = 1.0 - powerUp.progress; // Reverse progress for countdown
    final remainingTime = powerUp.remainingTime;
    final isUrgent = remainingTime.inSeconds <= 3; // Last 3 seconds
    final isLow = progress < 0.25; // Last 25% of duration

    // Build the indicator with optional pulse animation
    Widget indicator = Container(
      margin: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simple glow effect for active power-ups
          if (powerUp.type == PowerUpType.invincibility ||
              powerUp.type == PowerUpType.speedBoost ||
              isLow)
            Container(
              width: size * 1.2,
              height: size * 1.2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: powerUp.type.color.withValues(alpha: isUrgent ? 0.5 : 0.2),
                    blurRadius: isUrgent ? 12 : 8,
                    spreadRadius: isUrgent ? 3 : 2,
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
                    ? Colors.red
                    : isLow
                        ? Color.lerp(powerUp.type.color, Colors.orange, 0.3)!
                        : powerUp.type.color,
              ),
            ),
          ),

          // Power-up icon container
          Container(
            width: size * 0.65,
            height: size * 0.65,
            decoration: BoxDecoration(
              color: isUrgent
                  ? Colors.red.withValues(alpha: 0.9)
                  : powerUp.type.color.withValues(alpha: 0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isUrgent ? Colors.red : powerUp.type.color)
                      .withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
              border: isUrgent
                  ? Border.all(
                      color: Colors.white.withValues(alpha: 0.8),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Center(
              child: Text(
                powerUp.type.icon,
                style: TextStyle(
                  fontSize: isSmallScreen
                      ? (isUrgent ? 11 : 10)
                      : (isUrgent ? 14 : 12),
                  fontWeight: FontWeight.bold,
                  color: isUrgent ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ),

          // Time remaining indicator - always show countdown
          Positioned(
            bottom: size * 0.85,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 3 : 4,
                vertical: isSmallScreen ? 1 : 2,
              ),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red.shade800 : Colors.black87,
                borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                border:
                    isUrgent ? Border.all(color: Colors.white, width: 0.5) : null,
              ),
              child: Text(
                '${remainingTime.inSeconds}s${isUrgent ? '!' : ''}',
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

    // Wrap with pulsing animation if urgent
    if (isUrgent) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.15),
            child: child,
          );
        },
        child: indicator,
      );
    }

    return indicator;
  }

  /// Enhanced tournament indicator with gradient border, mode, and visual flair
  Widget _buildTournamentIndicator(bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.15),
            Colors.amber.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.1),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophy icon with glow
          Container(
            width: isSmallScreen ? 20 : 24,
            height: isSmallScreen ? 20 : 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.orange],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: isSmallScreen ? 12 : 14,
            ),
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          // Tournament info column
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    tournamentMode!.emoji,
                    style: TextStyle(fontSize: isSmallScreen ? 10 : 12),
                  ),
                  SizedBox(width: isSmallScreen ? 2 : 4),
                  Text(
                    tournamentMode!.displayName.toUpperCase(),
                    style: TextStyle(
                      color: Colors.purple,
                      fontSize: isSmallScreen ? 9 : 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmallScreen ? 1 : 2),
              Text(
                'TOURNAMENT MODE',
                style: TextStyle(
                  color: Colors.purple.withValues(alpha: 0.7),
                  fontSize: isSmallScreen ? 7 : 8,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}