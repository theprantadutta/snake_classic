import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/pickup_icon.dart';

class GameHUD extends StatefulWidget {
  final GameState gameState;
  final GameTheme theme;
  final VoidCallback onPause;
  final VoidCallback onHome;
  final bool isSmallScreen;
  /// Multiplier applied to fixed structural sizes (paddings, icon/button
  /// sizes, fixed chip/row heights) so the HUD scales up on tablets. `1.0` on
  /// phones (no change). Font sizes are NOT multiplied here — the root
  /// `MediaQuery.textScaler` already grows text on tablets, so scaling the
  /// heights/paddings by this keeps the enlarged text from overflowing.
  final double uiScale;
  final String? tournamentId;
  final TournamentGameMode? tournamentMode;
  /// Optional GlobalKey attached to the pause button so the tutorial's
  /// "Pause Anytime" step can spotlight it. game_screen.dart passes
  /// `GameTutorialKeys.pauseButtonKey` here; everywhere else omit it.
  final Key? pauseButtonKey;

  const GameHUD({
    super.key,
    required this.gameState,
    required this.theme,
    required this.onPause,
    required this.onHome,
    this.isSmallScreen = false,
    this.uiScale = 1.0,
    this.tournamentId,
    this.tournamentMode,
    this.pauseButtonKey,
  });

  @override
  State<GameHUD> createState() => _GameHUDState();
}

class _GameHUDState extends State<GameHUD> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _levelUpController;
  late AnimationController _foodPulseController;
  late Animation<double> _levelUpScale;
  late Animation<double> _levelUpGlow;
  int _displayedScore = 0;
  int _previousLevel = 1;
  bool _showLevelUpEffect = false;
  FoodType? _previousFoodType;

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

    _foodPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _displayedScore = widget.gameState.score;
    _previousLevel = widget.gameState.level;
    _previousFoodType = widget.gameState.food?.type;
  }

  @override
  void didUpdateWidget(GameHUD oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Performance: Skip expensive work if nothing HUD-relevant changed.
    // With Fix 1's buildWhen, this is largely a safety net, but protects
    // against any remaining cases.
    if (identical(widget.gameState, oldWidget.gameState) &&
        widget.theme == oldWidget.theme) {
      return;
    }

    // Check for level up
    if (widget.gameState.level > _previousLevel) {
      _triggerLevelUpEffect();
      _previousLevel = widget.gameState.level;
    }

    // Food type changed — one-shot pulse so the player sees the type swap.
    final currentFoodType = widget.gameState.food?.type;
    if (currentFoodType != null && currentFoodType != _previousFoodType) {
      _previousFoodType = currentFoodType;
      _foodPulseController.forward(from: 0.0);
    }

    // Pulse driver — shared between urgent power-up indicator and combo
    // chip heat. (The time-attack chip drives its own ticker — see
    // _TimeAttackChip — because wall-clock time advances between HUD
    // rebuilds and this driver only re-evaluates on rebuild.)
    final hasUrgentPowerUp = widget.gameState.activePowerUps.any(
      (p) => !p.isExpired && p.remainingTime.inSeconds <= 3,
    );
    final hasComboHeat = widget.gameState.currentCombo >= 5;
    final shouldPulse = hasUrgentPowerUp || hasComboHeat;
    if (shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!shouldPulse && _pulseController.isAnimating) {
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
    _foodPulseController.dispose();
    super.dispose();
  }

  GameState get gameState => widget.gameState;
  GameTheme get theme => widget.theme;
  bool get isSmallScreen => widget.isSmallScreen;
  String? get tournamentId => widget.tournamentId;
  TournamentGameMode? get tournamentMode => widget.tournamentMode;

  /// Scale a fixed structural dimension for the current device (tablet-aware).
  double _s(double value) => value * widget.uiScale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _s(16),
        vertical: _s(isSmallScreen ? 8 : 12),
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

              // Right: Pause button — KeyedSubtree so the tutorial's
              // spotlight target points at this widget when a key is supplied.
              KeyedSubtree(
                key: widget.pauseButtonKey,
                child: _buildIconButton(
                  icon: gameState.status == GameStatus.playing
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  onTap: widget.onPause,
                  color: theme.accentColor,
                  isPrimary: true,
                ),
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
        width: _s(isSmallScreen ? 36 : 42),
        height: _s(isSmallScreen ? 36 : 42),
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
        child: Icon(icon, color: color, size: _s(isSmallScreen ? 18 : 22)),
      ),
    );
  }

  Widget _buildScoreSection() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _s(isSmallScreen ? 16 : 24),
        vertical: _s(isSmallScreen ? 8 : 10),
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
                  return Semantics(
                    label: 'Score $value',
                    child: Text(
                      '$value',
                      // Use the theme's primary color so the score blends with
                      // the rest of the HUD instead of standing out as the lone
                      // white element. The dark drop shadow below keeps it
                      // legible over the subtle accent-tinted background on
                      // every theme (incl. neon / pastel palettes).
                      style: TextStyle(
                        color: theme.primaryColor,
                        fontSize: isSmallScreen ? 26 : 32,
                        fontWeight: FontWeight.w900,
                        height: 1.0,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.6),
                            offset: const Offset(0.5, 1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
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
    final hasMultipleLives = gameState.initialLives > 1;
    final hasTimeLimit = gameState.gameMode.timeLimit != null;
    // Lock the secondary row to a fixed height so adding/removing the
    // power-ups card mid-game doesn't reflow the layout and shove the
    // game board up/down. The height accommodates the chip-style cards
    // (food / lives / time / level) AND the slightly taller power-up
    // progress-ring indicator — chosen to match so both render
    // identically when present.
    final rowHeight = _s(isSmallScreen ? 32.0 : 38.0);
    return SizedBox(
      height: rowHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Level progress
          Expanded(flex: 2, child: _buildLevelCard()),

          const SizedBox(width: 8),

          // TimeAttack countdown
          if (hasTimeLimit) ...[
            _buildTimeAttackChip(),
            const SizedBox(width: 8),
          ],

          // Lives indicator (survival mode)
          if (hasMultipleLives) ...[
            _buildLivesChip(),
            const SizedBox(width: 8),
          ],

          // Food indicator
          if (gameState.food != null) ...[
            _buildFoodChip(gameState.food!),
            const SizedBox(width: 8),
          ],

          // Power-ups — clipped to the row's fixed height so the
          // indicator doesn't push past the chip line. The card sizes
          // to its children but the SizedBox above bounds it.
          if (gameState.activePowerUps.isNotEmpty)
            Expanded(flex: 2, child: _buildPowerUpsCard()),
        ],
      ),
    );
  }

  Widget _buildTimeAttackChip() {
    return _TimeAttackChip(
      gameState: gameState,
      theme: theme,
      isSmallScreen: isSmallScreen,
      uiScale: widget.uiScale,
    );
  }

  Widget _buildLivesChip() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: _s(isSmallScreen ? 8 : 10),
        vertical: _s(isSmallScreen ? 6 : 8),
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.redAccent.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(gameState.initialLives, (i) {
          final isAlive = i < gameState.livesRemaining;
          return Padding(
            padding: EdgeInsets.only(right: i < gameState.initialLives - 1 ? 2 : 0),
            child: Icon(
              isAlive ? Icons.favorite : Icons.favorite_border,
              size: _s(isSmallScreen ? 14 : 16),
              color: isAlive
                  ? Colors.redAccent
                  : Colors.redAccent.withValues(alpha: 0.35),
            ),
          );
        }),
      ),
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
        horizontal: _s(isSmallScreen ? 10 : 12),
        vertical: _s(isSmallScreen ? 6 : 8),
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
          // Level badge with animation — wrapped in a Stack so the level-up
          // particle burst can fan out from behind the badge without
          // displacing the row layout.
          AnimatedBuilder(
            animation: _levelUpController,
            builder: (context, child) {
              return Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (_showLevelUpEffect)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _LevelUpBurstPainter(
                          progress: _levelUpController.value,
                          color: Colors.amber,
                        ),
                      ),
                    ),
                  Transform.scale(
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
              ),
                ],
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
                  // height:1.0 strips the inherent line-height padding
                  // (default ~1.5) so the text occupies exactly fontSize
                  // pixels. Without this, fontSize 9 actually renders at
                  // ~14px tall and combined with the progress bar +
                  // 2px gap exceeds the 20px content slot the secondary
                  // row reserves on small screens, producing a 1px
                  // overflow warning.
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.5),
                    fontSize: isSmallScreen ? 8 : 9,
                    height: 1.0,
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
    final color = switch (food.type) {
      FoodType.normal => Colors.red,
      FoodType.bonus => Colors.amber,
      FoodType.special => Colors.purple,
    };

    // Pin the chip to a fixed height so the secondary HUD row doesn't
    // re-layout when the food type changes (apple/star/diamond emojis
    // rasterize at slightly different heights on Android, and the parent
    // Row was matching whichever chip happened to be tallest — pushing
    // the game board down a couple of pixels each time).
    //
    // Heights chosen to match the neighbouring Lives/TimeAttack chips
    // (icon 14/16 + vertical padding 6/8 ≈ 26/32).
    final chipHeight = _s(isSmallScreen ? 26.0 : 32.0);

    return SizedBox(
      height: chipHeight,
      child: AnimatedBuilder(
        animation: _foodPulseController,
        builder: (context, child) {
          // Pulse: 1.0 → 1.18 → 1.0 over the controller's 280ms lifetime.
          final t = _foodPulseController.value;
          final scale = t < 0.5
              ? 1.0 + (0.18 * t * 2)
              : 1.18 - (0.18 * (t - 0.5) * 2);
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
        padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 8 : 10),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // The board's sprite art, so the chip previews exactly what's
            // sitting on the playfield (fixed square, no font-metric
            // height variance).
            PickupIcon.food(
              food.type,
              size: isSmallScreen ? 14 : 16,
            ),
            const SizedBox(width: 4),
            Text(
              '+${food.type.points}',
              style: TextStyle(
                color: color,
                fontSize: isSmallScreen ? 11 : 12,
                fontWeight: FontWeight.w700,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
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

    // Combo heat tier — drives the pulse intensity. 0 = idle, 1 = warm,
    // 2 = hot, 3 = scorching. Glow only at hot/scorching.
    final heatTier = combo >= 20
        ? 3
        : combo >= 10
        ? 2
        : combo >= 5
        ? 1
        : 0;

    final chip = Container(
      padding: EdgeInsets.symmetric(
        horizontal: _s(isSmallScreen ? 8 : 10),
        vertical: _s(isSmallScreen ? 4 : 6),
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.25), color.withValues(alpha: 0.1)],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
        boxShadow: heatTier >= 2
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: heatTier == 3 ? 14 : 9,
                  spreadRadius: heatTier == 3 ? 1.5 : 0.5,
                ),
              ]
            : null,
      ),
      child: IntrinsicWidth(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('🔥',
                    style: TextStyle(fontSize: isSmallScreen ? 12 : 14)),
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
            const SizedBox(height: 3),
            // Decay warning: drains through the last seconds before the
            // combo breaks. Always mounted at fixed height so the chip
            // never changes size (no board reflow) — invisible outside
            // the danger window.
            _ComboDecayBar(gameState: gameState),
          ],
        ),
      ),
    );

    if (heatTier == 0) return chip;
    // Scale grows with tier so a 20-combo bite reads as "scorching".
    final scaleAmplitude = 0.04 * heatTier;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final scale = 1.0 + scaleAmplitude * _pulseController.value;
        return Transform.scale(scale: scale, child: child);
      },
      child: chip,
    );
  }

  Widget _buildPowerUpsCard() {
    final activePowerUps = gameState.activePowerUps
        .where((powerUp) => !powerUp.isExpired)
        .toList();

    if (activePowerUps.isEmpty) return const SizedBox.shrink();

    // Fill the parent's fixed-height slot completely so the indicators
    // can center inside it without nudging the row taller. Padding kept
    // tight horizontal-only; the SizedBox-bounded parent provides the
    // vertical room.
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 6 : 8),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
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
    final size = _s(isSmallScreen ? 22.0 : 28.0);
    return _PowerUpRing(
      key: ValueKey(
        '${powerUp.type.name}-${powerUp.activatedAt.microsecondsSinceEpoch}',
      ),
      powerUp: powerUp,
      size: size,
      isSmallScreen: isSmallScreen,
    );
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

/// Per-indicator active power-up ring with its own 60fps ticker so the
/// drain animates smoothly across the full duration. Previously the ring
/// only repainted when the parent HUD rebuilt — which only fires on game
/// ticks (~150–300ms) or when _pulseController happens to be running — so
/// the visual sat at its initial value, snapped to ~empty during the last
/// 3 seconds, then disappeared. The ticker rebuilds JUST this widget at
/// 60fps; the rest of the HUD stays untouched.
class _PowerUpRing extends StatefulWidget {
  final ActivePowerUp powerUp;
  final double size;
  final bool isSmallScreen;

  const _PowerUpRing({
    super.key,
    required this.powerUp,
    required this.size,
    required this.isSmallScreen,
  });

  @override
  State<_PowerUpRing> createState() => _PowerUpRingState();
}

class _PowerUpRingState extends State<_PowerUpRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    // 1s repeating tick — value isn't read, the ticker just drives 60fps
    // rebuilds via AnimatedBuilder so progress/remainingTime read fresh
    // from the model on every frame.
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        final powerUp = widget.powerUp;
        final size = widget.size;
        final progress = 1.0 - powerUp.progress;
        final isUrgent = powerUp.remainingTime.inSeconds <= 3;

        // Urgent pulse driven off the same ticker — scale oscillates with
        // the controller's 0..1 sweep so the indicator visibly throbs in
        // the last seconds without needing the shared _pulseController.
        final urgentScale = isUrgent
            ? 1.0 + (math.sin(_ticker.value * math.pi * 2) * 0.06).abs()
            : 1.0;

        return Transform.scale(
          scale: urgentScale,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 3.0,
                    strokeCap: StrokeCap.round,
                    backgroundColor:
                        powerUp.type.color.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation(
                      isUrgent ? Colors.red : powerUp.type.color,
                    ),
                  ),
                ),
                // The board's token sprite (already a round badge), so the
                // ring previews exactly what was collected. Urgency is
                // carried by the red ring + throb; when urgent a red disc
                // behind the token keeps the old "flashing red" read.
                if (isUrgent)
                  Container(
                    width: size * 0.66,
                    height: size * 0.66,
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.85),
                      shape: BoxShape.circle,
                    ),
                  ),
                PickupIcon.powerUp(powerUp.type, size: size * 0.72),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Self-ticking Time Attack countdown chip. `timeAttackSecondsRemaining`
/// is wall-clock derived, so it advances between HUD rebuilds — but the
/// parent HUD only rebuilds on score/level/status changes. Without its own
/// ticker the clock visibly froze between bites and jumped on the next
/// eat. Same pattern as _PowerUpRing: a repeating controller rebuilds JUST
/// this chip, reading the model fresh each frame. The <10s critical throb
/// is driven off the same ticker instead of the HUD's shared pulse
/// controller (which had the same staleness problem).
class _TimeAttackChip extends StatefulWidget {
  final GameState gameState;
  final GameTheme theme;
  final bool isSmallScreen;
  final double uiScale;

  const _TimeAttackChip({
    required this.gameState,
    required this.theme,
    required this.isSmallScreen,
    required this.uiScale,
  });

  @override
  State<_TimeAttackChip> createState() => _TimeAttackChipState();
}

class _TimeAttackChipState extends State<_TimeAttackChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _syncTicker();
  }

  @override
  void didUpdateWidget(_TimeAttackChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTicker();
  }

  /// Freeze the ticker while paused — the getter is frozen via pausedAt
  /// anyway, so ticking would just burn frames on a static value.
  void _syncTicker() {
    final paused = widget.gameState.pausedAt != null;
    if (paused && _ticker.isAnimating) {
      _ticker.stop();
    } else if (!paused && !_ticker.isAnimating) {
      _ticker.repeat();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  double _s(double value) => value * widget.uiScale;

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = widget.isSmallScreen;
    final theme = widget.theme;
    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        final seconds = widget.gameState.timeAttackSecondsRemaining;
        final mm = (seconds ~/ 60).toString().padLeft(2, '0');
        final ss = (seconds % 60).toString().padLeft(2, '0');
        final isLow = seconds <= 30;
        final isCritical = seconds <= 10 && seconds > 0;
        final accent = isLow ? Colors.redAccent : Colors.amber;
        // 0.95–1.05 throb driven off the ticker's 0..1 sweep.
        final scale = isCritical
            ? 0.95 + (math.sin(_ticker.value * math.pi * 2) * 0.10).abs()
            : 1.0;
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: _s(isSmallScreen ? 8 : 10),
              vertical: _s(isSmallScreen ? 6 : 8),
            ),
            decoration: BoxDecoration(
              color: theme.backgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: accent.withValues(alpha: isLow ? 0.7 : 0.4),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: _s(isSmallScreen ? 14 : 16),
                  color: accent,
                ),
                const SizedBox(width: 4),
                Text(
                  '$mm:$ss',
                  style: TextStyle(
                    color: accent,
                    fontSize: isSmallScreen ? 12 : 13,
                    fontWeight: FontWeight.bold,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Drain bar inside the combo chip that warns the player the streak is
/// about to break. The combo decays after [GameConstants.comboDecayMs] of
/// game-time without a bite (see SnakeSimulation) — without a visible
/// countdown, a broken combo reads as random. The bar appears in the
/// last [_dangerWindowMs] and empties toward the break.
///
/// Self-ticking (same pattern as _TimeAttackChip): comboIdleMs only
/// advances per game tick, so between HUD rebuilds the bar extrapolates
/// using wall-time since the state's lastMoveTime — during live play
/// game-time and wall-time advance 1:1. Extrapolation is skipped while
/// paused/ended and clamped so a resume transient can't overshoot.
class _ComboDecayBar extends StatefulWidget {
  final GameState gameState;

  const _ComboDecayBar({required this.gameState});

  @override
  State<_ComboDecayBar> createState() => _ComboDecayBarState();
}

class _ComboDecayBarState extends State<_ComboDecayBar>
    with SingleTickerProviderStateMixin {
  static const int _dangerWindowMs = 2500;

  late final AnimationController _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  /// 1.0 = window just entered, 0.0 = combo breaks now. Null when outside
  /// the danger window (or decay doesn't apply).
  double? _dangerFraction() {
    final gs = widget.gameState;
    if (gs.currentCombo <= 0 || gs.gameMode == GameMode.zen) return null;

    var idleMs = gs.comboIdleMs;
    if (gs.status == GameStatus.playing &&
        gs.pausedAt == null &&
        gs.lastMoveTime != null) {
      final sinceTick =
          DateTime.now().difference(gs.lastMoveTime!).inMilliseconds;
      // Ticks are <= ~600ms apart in play; the clamp bounds the brief
      // stale-anchor window right after a resume.
      idleMs += sinceTick.clamp(0, 1000);
    }

    final remaining = GameConstants.comboDecayMs - idleMs;
    if (remaining > _dangerWindowMs) return null;
    return (remaining / _dangerWindowMs).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ticker,
      builder: (context, _) {
        final fraction = _dangerFraction();
        return SizedBox(
          height: 3,
          child: fraction == null
              ? const SizedBox.shrink()
              : DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: fraction,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

/// Lightweight 8-spoke radial burst drawn behind the level badge for the
/// duration of `_levelUpController` (1500ms). Each particle slides outward
/// and fades; the burst never moves the surrounding layout because it
/// paints inside a Positioned.fill.
class _LevelUpBurstPainter extends CustomPainter {
  final double progress;
  final Color color;

  _LevelUpBurstPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.max(size.width, size.height) * 1.6;
    final paint = Paint()
      ..color = color.withValues(alpha: (1.0 - progress) * 0.85)
      ..style = PaintingStyle.fill;
    const count = 8;
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * 2 * math.pi;
      final dist = maxRadius * progress;
      final px = center.dx + math.cos(angle) * dist;
      final py = center.dy + math.sin(angle) * dist;
      final r = math.max(1.0, 3.0 * (1.0 - progress));
      canvas.drawCircle(Offset(px, py), r, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _LevelUpBurstPainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}
