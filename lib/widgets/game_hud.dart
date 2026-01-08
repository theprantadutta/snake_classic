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

class _GameHUDState extends State<GameHUD> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _levelUpController;
  late Animation<double> _levelUpScale;
  late Animation<double> _levelUpGlow;
  int _displayedScore = 0;
  int _previousLevel = 1;
  bool _showLevelUpEffect = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Level-up celebration animation (1.5 seconds total)
    _levelUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Scale animation: 1.0 -> 1.4 -> 1.0
    _levelUpScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.4,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.4,
          end: 1.15,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.15,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(_levelUpController);

    // Glow animation: 0 -> 1 -> 0
    _levelUpGlow = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 70,
      ),
    ]).animate(_levelUpController);

    _levelUpController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showLevelUpEffect = false);
        _levelUpController.reset();
      }
    });

    _displayedScore = widget.gameState.score;
    _previousLevel = widget.gameState.level;
  }

  @override
  void didUpdateWidget(GameHUD oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check for level up
    if (widget.gameState.level > _previousLevel) {
      _triggerLevelUpEffect();
      _previousLevel = widget.gameState.level;
    }

    // Power-up urgent pulse
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

  void _triggerLevelUpEffect() {
    setState(() => _showLevelUpEffect = true);
    _levelUpController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _levelUpController.dispose();
    super.dispose();
  }

  GameState get gameState => widget.gameState;
  GameTheme get theme => widget.theme;
  bool get isSmallScreen => widget.isSmallScreen;
  String? get tournamentId => widget.tournamentId;
  TournamentGameMode? get tournamentMode => widget.tournamentMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isSmallScreen ? 8 : 12,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Main HUD Row
          Row(
            children: [
              // Left: Home button
              _buildIconButton(
                icon: Icons.home_rounded,
                onTap: widget.onHome,
                color: theme.accentColor.withValues(alpha: 0.7),
              ),

              const SizedBox(width: 12),

              // Center: Score display (expanded)
              Expanded(child: _buildScoreSection()),

              const SizedBox(width: 12),

              // Right: Pause button
              _buildIconButton(
                icon: gameState.status == GameStatus.playing
                    ? Icons.pause_rounded
                    : Icons.play_arrow_rounded,
                onTap: widget.onPause,
                color: theme.accentColor,
                isPrimary: true,
              ),
            ],
          ),

          // Secondary row: Level progress + Power-ups + Food indicator
          const SizedBox(height: 8),
          _buildSecondaryRow(),

          // Tournament indicator if active
          if (tournamentId != null && tournamentMode != null) ...[
            const SizedBox(height: 8),
            _buildTournamentBanner(),
          ],
        ],
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required VoidCallback onTap,
    required Color color,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: isSmallScreen ? 36 : 42,
        height: isSmallScreen ? 36 : 42,
        decoration: BoxDecoration(
          color: isPrimary
              ? color.withValues(alpha: 0.15)
              : theme.backgroundColor.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withValues(alpha: isPrimary ? 0.4 : 0.2),
            width: 1.5,
          ),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(icon, color: color, size: isSmallScreen ? 18 : 22),
      ),
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 24,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.accentColor.withValues(alpha: 0.08),
            theme.snakeColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Score
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SCORE',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.6),
                  fontSize: isSmallScreen ? 9 : 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 2),
              TweenAnimationBuilder<int>(
                tween: IntTween(begin: _displayedScore, end: gameState.score),
                duration: const Duration(milliseconds: 300),
                onEnd: () => _displayedScore = gameState.score,
                builder: (context, value, child) {
                  return Text(
                    '$value',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: isSmallScreen ? 26 : 32,
                      fontWeight: FontWeight.w900,
                      height: 1.0,
                    ),
                  );
                },
              ),
            ],
          ),

          // Combo indicator (if active)
          if (gameState.currentCombo >= 3) ...[
            const SizedBox(width: 16),
            _buildComboChip(),
          ],
        ],
      ),
    );
  }

  Widget _buildSecondaryRow() {
    return Row(
      children: [
        // Level progress
        Expanded(flex: 2, child: _buildLevelCard()),

        const SizedBox(width: 8),

        // Food indicator
        if (gameState.food != null) ...[
          _buildFoodChip(gameState.food!),
          const SizedBox(width: 8),
        ],

        // Power-ups
        if (gameState.activePowerUps.isNotEmpty)
          Expanded(flex: 2, child: _buildPowerUpsCard()),
      ],
    );
  }

  Widget _buildLevelCard() {
    // Use the new triangular progression getters from GameState
    final progress = gameState.levelProgress;
    final pointsInLevel = gameState.pointsInCurrentLevel;
    final pointsNeeded = gameState.pointsForCurrentLevel;
    final isNearLevelUp = progress >= 0.8;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isNearLevelUp
              ? Colors.amber.withValues(alpha: 0.5)
              : theme.accentColor.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Level badge with animation
          AnimatedBuilder(
            animation: _levelUpController,
            builder: (context, child) {
              return Transform.scale(
                scale: _showLevelUpEffect ? _levelUpScale.value : 1.0,
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8,
                    vertical: isSmallScreen ? 2 : 3,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _showLevelUpEffect
                          ? [Colors.amber, Colors.orange]
                          : isNearLevelUp
                          ? [Colors.amber, Colors.orange]
                          : [theme.snakeColor, theme.accentColor],
                    ),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: _showLevelUpEffect
                        ? [
                            BoxShadow(
                              color: Colors.amber.withValues(
                                alpha: _levelUpGlow.value * 0.8,
                              ),
                              blurRadius: 12 * _levelUpGlow.value,
                              spreadRadius: 4 * _levelUpGlow.value,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_showLevelUpEffect) ...[
                        Text(
                          '⬆️',
                          style: TextStyle(fontSize: isSmallScreen ? 8 : 10),
                        ),
                        const SizedBox(width: 2),
                      ],
                      Text(
                        'LV${gameState.level}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isSmallScreen ? 10 : 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (_showLevelUpEffect) ...[
                        const SizedBox(width: 2),
                        Text(
                          '⬆️',
                          style: TextStyle(fontSize: isSmallScreen ? 8 : 10),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          // Progress bar
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: theme.accentColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(
                      isNearLevelUp ? Colors.amber : theme.snakeColor,
                    ),
                    minHeight: isSmallScreen ? 4 : 5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$pointsInLevel/$pointsNeeded',
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.5),
                    fontSize: isSmallScreen ? 8 : 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodChip(Food food) {
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
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
          const SizedBox(width: 4),
          Text(
            '+${food.type.points}',
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComboChip() {
    final combo = gameState.currentCombo;
    final multiplier = gameState.comboMultiplier;
    final color = combo >= 20
        ? Colors.red
        : combo >= 10
        ? Colors.orange
        : combo >= 5
        ? Colors.amber
        : Colors.green;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('🔥', style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
          const SizedBox(width: 4),
          Text(
            '${multiplier.toStringAsFixed(1)}x',
            style: TextStyle(
              color: color,
              fontSize: isSmallScreen ? 12 : 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpsCard() {
    final activePowerUps = gameState.activePowerUps
        .where((powerUp) => !powerUp.isExpired)
        .toList();

    if (activePowerUps.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 4 : 6,
      ),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: activePowerUps
            .map((powerUp) => _buildPowerUpIndicator(powerUp))
            .toList(),
      ),
    );
  }

  Widget _buildPowerUpIndicator(ActivePowerUp powerUp) {
    final size = isSmallScreen ? 28.0 : 34.0;
    final progress = 1.0 - powerUp.progress;
    final remainingTime = powerUp.remainingTime;
    final isUrgent = remainingTime.inSeconds <= 3;

    Widget indicator = Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Progress ring
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2.5,
              strokeCap: StrokeCap.round,
              backgroundColor: powerUp.type.color.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation(
                isUrgent ? Colors.red : powerUp.type.color,
              ),
            ),
          ),
          // Icon
          Container(
            width: size * 0.65,
            height: size * 0.65,
            decoration: BoxDecoration(
              color: isUrgent
                  ? Colors.red.withValues(alpha: 0.9)
                  : powerUp.type.color.withValues(alpha: 0.85),
              shape: BoxShape.circle,
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
          // Time badge
          Positioned(
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
              decoration: BoxDecoration(
                color: isUrgent ? Colors.red : Colors.black87,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '${remainingTime.inSeconds}s',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmallScreen ? 7 : 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    if (isUrgent) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 + (_pulseController.value * 0.12),
            child: child,
          );
        },
        child: indicator,
      );
    }

    return indicator;
  }

  Widget _buildTournamentBanner() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 12 : 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.15),
            Colors.amber.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.purple.withValues(alpha: 0.4),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.4),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.white,
              size: isSmallScreen ? 12 : 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${tournamentMode!.emoji} ${tournamentMode!.displayName.toUpperCase()}',
            style: TextStyle(
              color: Colors.purple,
              fontSize: isSmallScreen ? 11 : 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 6 : 8,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: Colors.purple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'TOURNAMENT',
              style: TextStyle(
                color: Colors.purple.withValues(alpha: 0.8),
                fontSize: isSmallScreen ? 8 : 9,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
