import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/premium_provider.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/advanced_particle_system.dart';
import 'package:snake_classic/widgets/snake_trail_system.dart';
import 'package:snake_classic/widgets/shader_effects.dart';

class GameBoard extends StatefulWidget {
  final GameState gameState;
  final double cellSize;
  final bool isTournamentMode;

  const GameBoard({
    super.key,
    required this.gameState,
    this.cellSize = GameConstants.cellSize,
    this.isTournamentMode = false,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  GameState? _cachedGameState;
  GameTheme? _cachedTheme;

  // Enhanced effects
  final ParticleManager _particleManager = ParticleManager();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ), // Slightly slower for smoother feel
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _particleManager.clear(); // Clean up particle emissions to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, PremiumProvider>(
      builder: (context, themeProvider, premiumProvider, child) {
        final theme = themeProvider.currentTheme;

        // Performance optimization: Only rebuild if gameState actually changed
        final shouldRebuild =
            _cachedGameState != widget.gameState || _cachedTheme != theme;

        if (shouldRebuild) {
          _checkForGameEvents(_cachedGameState, widget.gameState, theme);
          _cachedGameState = widget.gameState;
          _cachedTheme = theme;
        }

        return RepaintBoundary(
          // Isolate repaints to this widget
          child: Container(
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              // Enhanced gradient background matching home screen exactly
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  theme.accentColor.withValues(alpha: 0.12),
                  theme.backgroundColor.withValues(alpha: 0.98),
                  theme.backgroundColor,
                  Colors.black.withValues(alpha: 0.08),
                ],
                stops: const [0.0, 0.4, 0.8, 1.0],
              ),
              // Enhanced border with premium glow effect (tournament mode uses purple/gold)
              border: Border.all(
                color: widget.isTournamentMode
                    ? Colors.purple.withValues(alpha: 0.7)
                    : theme.accentColor.withValues(alpha: 0.5),
                width: widget.isTournamentMode ? 4.0 : 3.0,
              ),
              borderRadius: BorderRadius.circular(0),
              // Premium multi-layer shadow system (tournament mode uses purple/gold glow)
              boxShadow: widget.isTournamentMode
                  ? [
                      // Primary purple glow effect
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.35),
                        blurRadius: 20,
                        spreadRadius: 0,
                        offset: const Offset(0, 0),
                      ),
                      // Gold accent glow
                      BoxShadow(
                        color: Colors.amber.withValues(alpha: 0.25),
                        blurRadius: 28,
                        spreadRadius: 2,
                        offset: const Offset(0, 0),
                      ),
                      // Depth shadow
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.5),
                        blurRadius: 24,
                        spreadRadius: 1,
                        offset: const Offset(0, 12),
                      ),
                      // Pulsing outer glow
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.2),
                        blurRadius: 48,
                        spreadRadius: -4,
                        offset: const Offset(0, 0),
                      ),
                    ]
                  : [
                      // Primary glow effect
                      BoxShadow(
                        color: theme.accentColor.withValues(alpha: 0.25),
                        blurRadius: 16,
                        spreadRadius: -1,
                        offset: const Offset(0, 0),
                      ),
                      // Depth shadow
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 1,
                        offset: const Offset(0, 12),
                      ),
                      // Inner highlight
                      BoxShadow(
                        color: theme.accentColor.withValues(alpha: 0.1),
                        blurRadius: 8,
                        spreadRadius: -4,
                        offset: const Offset(0, -4),
                      ),
                      // Ambient outer glow
                      BoxShadow(
                        color: theme.accentColor.withValues(alpha: 0.15),
                        blurRadius: 48,
                        spreadRadius: -8,
                        offset: const Offset(0, 0),
                      ),
                    ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(0),
              child: Container(
                // Inner container with enhanced pattern overlay matching home screen
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.backgroundColor.withValues(alpha: 0.95),
                      theme.backgroundColor.withValues(alpha: 0.98),
                      theme.accentColor.withValues(alpha: 0.05),
                      theme.foodColor.withValues(alpha: 0.02),
                    ],
                    stops: const [0.0, 0.4, 0.8, 1.0],
                  ),
                ),
                child: Stack(
                  children: [
                    // Subtle pattern overlay
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _GameBoardBackgroundPainter(theme),
                      ),
                    ),
                    // Game content
                    AspectRatio(
                      aspectRatio:
                          widget.gameState.boardWidth /
                          widget.gameState.boardHeight,
                      child: Consumer<GameProvider>(
                        builder: (context, gameProvider, child) {
                          return CustomPaint(
                            painter: OptimizedGameBoardPainter(
                              gameState: widget.gameState,
                              theme: theme,
                              pulseAnimation: _pulseAnimation,
                              // Smooth movement properties
                              moveProgress: gameProvider.moveProgress,
                              previousGameState: gameProvider.previousGameState,
                              premiumProvider: premiumProvider,
                              // Pass time once per frame to avoid DateTime.now() in paint loop
                              animationTimeMs: DateTime.now().millisecondsSinceEpoch,
                            ),
                            size: Size.infinite,
                            // Performance: Only repaint when needed
                            isComplex: false,
                            willChange: true,
                          );
                        },
                      ),
                    ),
                    // Snake trail system (conditionally shown)
                    if (themeProvider.isTrailSystemEnabled)
                      Positioned.fill(
                        child: SnakeTrailSystem(
                          snakeBody: widget.gameState.snake.body,
                          trailType: _getTrailTypeForTheme(theme),
                          theme: theme,
                          cellWidth: widget.cellSize,
                          cellHeight: widget.cellSize,
                          isPlaying:
                              widget.gameState.status == GameStatus.playing,
                        ),
                      ),
                    // Advanced particle system
                    Positioned.fill(
                      child: AdvancedParticleSystem(
                        emissions: _particleManager.emissions,
                        autoRemoveEmissions: true,
                      ),
                    ),
                    // Shader effects overlay
                    if (_shouldUseShaderEffects(theme))
                      Positioned.fill(
                        child: ShaderEnhancedBackground(
                          theme: theme,
                          enabled: true,
                          child: const SizedBox.expand(),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  TrailType _getTrailTypeForTheme(GameTheme theme) {
    switch (theme) {
      case GameTheme.classic:
        return TrailType.basic;
      case GameTheme.modern:
        return TrailType.glow;
      case GameTheme.neon:
        return TrailType.glow;
      case GameTheme.retro:
        return TrailType.basic;
      case GameTheme.space:
        return TrailType.particles;
      case GameTheme.ocean:
        return TrailType.glow;
      case GameTheme.cyberpunk:
        return TrailType.lightning;
      case GameTheme.forest:
        return TrailType.particles;
      case GameTheme.desert:
        return TrailType.fire;
      case GameTheme.crystal:
        return TrailType.ice;
    }
  }

  void _addFoodParticleEffect(Offset position, GameTheme theme, FoodType foodType) {
    ParticleConfig particleConfig;
    
    // Choose particle effect based on food type
    switch (foodType) {
      case FoodType.normal:
        particleConfig = ParticleConfig.appleFoodExplosion;
        break;
      case FoodType.bonus:
        particleConfig = ParticleConfig.bonusFoodExplosion;
        break;
      case FoodType.special:
        particleConfig = ParticleConfig.specialFoodExplosion;
        break;
    }
    
    _particleManager.emitAt(
      position,
      particleConfig,
      duration: Duration(milliseconds: particleConfig.lifetime.inMilliseconds),
    );
  }

  void _addPowerUpParticleEffect(Offset position, PowerUpType powerUpType) {
    ParticleConfig particleConfig;
    
    // Choose particle effect based on power-up type
    switch (powerUpType) {
      case PowerUpType.speedBoost:
        particleConfig = ParticleConfig.speedBoostCollection;
        break;
      case PowerUpType.invincibility:
        particleConfig = ParticleConfig.invincibilityCollection;
        break;
      case PowerUpType.scoreMultiplier:
        particleConfig = ParticleConfig.scoreMultiplierCollection;
        break;
      case PowerUpType.slowMotion:
        particleConfig = ParticleConfig.slowMotionCollection;
        break;
    }
    
    _particleManager.emitAt(
      position,
      particleConfig,
      duration: Duration(milliseconds: particleConfig.lifetime.inMilliseconds),
    );
  }

  void _checkForGameEvents(
    GameState? previousState,
    GameState currentState,
    GameTheme theme,
  ) {
    if (previousState == null) return;

    // Check if food was consumed (score increased)
    if (currentState.score > previousState.score && previousState.food != null) {
      // Calculate food position in screen coordinates accounting for container margin
      const containerMargin = 8.0; // Match the margin in the Container
      final foodScreenX = previousState.food!.position.x * widget.cellSize + 
          widget.cellSize / 2 + containerMargin;
      final foodScreenY = previousState.food!.position.y * widget.cellSize + 
          widget.cellSize / 2 + containerMargin;
      final foodPosition = Offset(foodScreenX, foodScreenY);

      // Add food consumption particle effect with food type
      _addFoodParticleEffect(foodPosition, theme, previousState.food!.type);
    }

    // Check if power-up was collected
    if (previousState.powerUp != null && currentState.powerUp == null) {
      // Calculate power-up position accounting for container margin
      const containerMargin = 8.0; // Match the margin in the Container
      final powerUpScreenX = previousState.powerUp!.position.x * widget.cellSize + 
          widget.cellSize / 2 + containerMargin;
      final powerUpScreenY = previousState.powerUp!.position.y * widget.cellSize + 
          widget.cellSize / 2 + containerMargin;
      final powerUpPosition = Offset(powerUpScreenX, powerUpScreenY);

      // Add power-up collection effect with power-up type
      _addPowerUpParticleEffect(powerUpPosition, previousState.powerUp!.type);
    }

    // Check for game over/crash
    if (currentState.status == GameStatus.crashed &&
        previousState.status != GameStatus.crashed) {
      if (currentState.crashPosition != null) {
        final crashScreenX =
            currentState.crashPosition!.x * widget.cellSize +
            widget.cellSize / 2;
        final crashScreenY =
            currentState.crashPosition!.y * widget.cellSize +
            widget.cellSize / 2;
        final crashPosition = Offset(crashScreenX, crashScreenY);

        // Add crash explosion effect
        _particleManager.emitAt(
          crashPosition,
          ParticleConfig.explosion,
          duration: const Duration(milliseconds: 1000),
        );
      }
    }
  }

  bool _shouldUseShaderEffects(GameTheme theme) {
    // Enable shader effects for modern themes
    return [
      GameTheme.neon,
      GameTheme.cyberpunk,
      GameTheme.space,
      GameTheme.ocean,
      GameTheme.crystal,
    ].contains(theme);
  }
}

class OptimizedGameBoardPainter extends CustomPainter {
  final GameState gameState;
  final GameTheme theme;
  final Animation<double> pulseAnimation;
  final double moveProgress;
  final GameState? previousGameState;
  final PremiumProvider premiumProvider;
  final int animationTimeMs; // Passed once per frame to avoid DateTime.now() in paint

  // Cache paint objects to avoid recreation
  late final Paint _snakeHeadPaint;
  late final Paint _snakeBodyPaint;
  late final Paint _foodPaint;
  late final Paint _gridPaint;
  late final Paint _crashPaint;
  late final Paint _collisionPaint;

  OptimizedGameBoardPainter({
    required this.gameState,
    required this.theme,
    required this.pulseAnimation,
    this.moveProgress = 0.0,
    this.previousGameState,
    required this.premiumProvider,
    this.animationTimeMs = 0,
  }) : super(repaint: pulseAnimation) {
    _initializePaints();
  }

  void _initializePaints() {
    _snakeHeadPaint = Paint()..isAntiAlias = true;
    _snakeBodyPaint = Paint()..isAntiAlias = true;
    _foodPaint = Paint()..isAntiAlias = true;
    _gridPaint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.08)
      ..strokeWidth = 0.5
      ..isAntiAlias = false; // Grid doesn't need antialiasing

    // Crash indicator paints
    _crashPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.fill;

    _collisionPaint = Paint()
      ..isAntiAlias = true
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / gameState.boardWidth;
    final cellHeight = size.height / gameState.boardHeight;

    // Draw in optimal order (back to front)
    _drawGrid(canvas, size, cellWidth, cellHeight);

    // Draw wall warning if snake is near edges (visual safety indicator)
    if (gameState.status == GameStatus.playing) {
      _drawWallWarning(canvas, size, cellWidth, cellHeight);
    }

    _drawFood(canvas, cellWidth, cellHeight);
    _drawPowerUp(canvas, cellWidth, cellHeight);
    _drawSnake(canvas, cellWidth, cellHeight);

    // Draw crash indicators on top if crashed
    if (gameState.status == GameStatus.crashed &&
        gameState.crashPosition != null) {
      _drawCrashIndicators(canvas, cellWidth, cellHeight);
    }
  }

  // Draw warning glow when snake head approaches walls
  void _drawWallWarning(Canvas canvas, Size size, double cellWidth, double cellHeight) {
    final headPosition = gameState.snake.head;

    // Calculate distances to each wall
    final distanceLeft = headPosition.x;
    final distanceRight = gameState.boardWidth - 1 - headPosition.x;
    final distanceTop = headPosition.y;
    final distanceBottom = gameState.boardHeight - 1 - headPosition.y;

    // Warning threshold from constants
    const threshold = GameConstants.wallWarningThreshold;

    // Calculate intensity for each edge (0.0 = safe, 1.0 = danger)
    final leftIntensity = _calculateWarningIntensity(distanceLeft, threshold);
    final rightIntensity = _calculateWarningIntensity(distanceRight, threshold);
    final topIntensity = _calculateWarningIntensity(distanceTop, threshold);
    final bottomIntensity = _calculateWarningIntensity(distanceBottom, threshold);

    // Draw warning glows where needed
    if (leftIntensity > 0) {
      _drawEdgeGlow(canvas, size, 'left', leftIntensity);
    }
    if (rightIntensity > 0) {
      _drawEdgeGlow(canvas, size, 'right', rightIntensity);
    }
    if (topIntensity > 0) {
      _drawEdgeGlow(canvas, size, 'top', topIntensity);
    }
    if (bottomIntensity > 0) {
      _drawEdgeGlow(canvas, size, 'bottom', bottomIntensity);
    }
  }

  double _calculateWarningIntensity(int distance, int threshold) {
    if (distance > threshold) return 0.0;
    if (distance <= 0) return GameConstants.wallWarningMaxIntensity;
    return GameConstants.wallWarningMaxIntensity * (1.0 - (distance / threshold));
  }

  void _drawEdgeGlow(Canvas canvas, Size size, String edge, double intensity) {
    // Warning color blends orange to red based on intensity
    final warningColor = Color.lerp(
      Colors.orange.withValues(alpha: intensity * 0.4),
      Colors.red.withValues(alpha: intensity * 0.6),
      intensity,
    )!;

    // Glow width based on intensity
    final glowWidth = 20.0 + (intensity * 15.0);

    Rect glowRect;
    Alignment gradientStart;
    Alignment gradientEnd;

    switch (edge) {
      case 'left':
        glowRect = Rect.fromLTWH(0, 0, glowWidth, size.height);
        gradientStart = Alignment.centerLeft;
        gradientEnd = Alignment.centerRight;
        break;
      case 'right':
        glowRect = Rect.fromLTWH(size.width - glowWidth, 0, glowWidth, size.height);
        gradientStart = Alignment.centerRight;
        gradientEnd = Alignment.centerLeft;
        break;
      case 'top':
        glowRect = Rect.fromLTWH(0, 0, size.width, glowWidth);
        gradientStart = Alignment.topCenter;
        gradientEnd = Alignment.bottomCenter;
        break;
      case 'bottom':
        glowRect = Rect.fromLTWH(0, size.height - glowWidth, size.width, glowWidth);
        gradientStart = Alignment.bottomCenter;
        gradientEnd = Alignment.topCenter;
        break;
      default:
        return;
    }

    final paint = Paint()
      ..shader = LinearGradient(
        begin: gradientStart,
        end: gradientEnd,
        colors: [
          warningColor,
          warningColor.withValues(alpha: 0),
        ],
      ).createShader(glowRect);

    canvas.drawRect(glowRect, paint);
  }

  void _drawGrid(
    Canvas canvas,
    Size size,
    double cellWidth,
    double cellHeight,
  ) {
    if (theme == GameTheme.neon) {
      // Only draw grid for neon theme and optimize drawing
      final path = Path();

      // Draw vertical lines in one path
      for (int i = 0; i <= gameState.boardWidth; i++) {
        final x = i * cellWidth;
        path.moveTo(x, 0);
        path.lineTo(x, size.height);
      }

      // Draw horizontal lines in same path
      for (int i = 0; i <= gameState.boardHeight; i++) {
        final y = i * cellHeight;
        path.moveTo(0, y);
        path.lineTo(size.width, y);
      }

      canvas.drawPath(path, _gridPaint);
    }
  }

  void _drawSnake(Canvas canvas, double cellWidth, double cellHeight) {
    final snake = gameState.snake;
    final snakeLength = snake.body.length;
    final previousSnake = previousGameState?.snake;

    // Draw snake body with enhanced visuals and smooth interpolation
    for (int i = 0; i < snakeLength; i++) {
      final currentPosition = snake.body[i];
      final isHead = i == 0;
      final isTail = i == snakeLength - 1;

      // Calculate interpolated position for smooth movement

      if (previousSnake != null &&
          i < previousSnake.body.length &&
          moveProgress < 1.0) {
        final previousPosition = previousSnake.body[i];

        // Linear interpolation between previous and current position
        final deltaX = currentPosition.x - previousPosition.x;
        final deltaY = currentPosition.y - previousPosition.y;

        // For more precise interpolation, use floating point
        final exactX = previousPosition.x + deltaX * moveProgress;
        final exactY = previousPosition.y + deltaY * moveProgress;

        // Calculate cell rect with smooth positioning
        final padding = cellWidth * 0.05;
        final rect = Rect.fromLTWH(
          exactX * cellWidth + padding,
          exactY * cellHeight + padding,
          cellWidth - padding * 2,
          cellHeight - padding * 2,
        );

        if (isHead) {
          _drawSnakeHead(canvas, rect, snake.currentDirection);
        } else {
          _drawSnakeBody(canvas, rect, i, snakeLength, isTail);
        }
      } else {
        // No interpolation needed, use standard positioning
        final padding = cellWidth * 0.05;
        final rect = Rect.fromLTWH(
          currentPosition.x * cellWidth + padding,
          currentPosition.y * cellHeight + padding,
          cellWidth - padding * 2,
          cellHeight - padding * 2,
        );

        if (isHead) {
          _drawSnakeHead(canvas, rect, snake.currentDirection);
        } else {
          _drawSnakeBody(canvas, rect, i, snakeLength, isTail);
        }
      }
    }
  }

  void _drawSnakeHead(Canvas canvas, Rect rect, Direction direction) {
    // Breathing animation - subtle size variation
    final breathingScale = 1.0 + 0.03 * math.sin(pulseAnimation.value * 2 * math.pi * 2.5); // 2.5 breaths per second
    final breathingRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * breathingScale,
      height: rect.height * breathingScale,
    );

    // Enhanced shadow for depth - drawn first
    _drawEnhancedHeadShadow(canvas, breathingRect);

    // Enhanced head with better gradient and glow effect
    final gradient = RadialGradient(
      center: Alignment.center,
      radius: 0.8,
      colors: _getHeadGradientColors(),
      stops: const [0.0, 0.6, 1.0],
    );

    _snakeHeadPaint.shader = gradient.createShader(breathingRect);

    // Enhanced glow effects based on theme
    _snakeHeadPaint.maskFilter = _getHeadMaskFilter();

    // Draw glow background for neon theme with breathing effect
    if (theme == GameTheme.neon) {
      _drawNeonGlow(canvas, breathingRect, theme.snakeColor, 8.0 * breathingScale);
    }

    // Enhanced head shape with better radius
    final radius = Radius.circular(breathingRect.width * 0.3);
    canvas.drawRRect(RRect.fromRectAndRadius(breathingRect, radius), _snakeHeadPaint);

    // Draw enhanced snake eyes with breathing
    _drawSnakeEyes(canvas, breathingRect, direction);

    // Add directional indicator (small triangle)
    _drawDirectionIndicator(canvas, breathingRect, direction);

    // Add breathing highlight effect
    _drawBreathingHighlight(canvas, breathingRect, breathingScale);
  }

  List<Color> _getHeadGradientColors() {
    // Use selected skin colors if available, otherwise fall back to theme colors
    final skinColors = _getSelectedSkinColors();
    
    if (skinColors.isNotEmpty && premiumProvider.selectedSkinId != 'classic') {
      // Use skin colors for premium skins
      if (skinColors.length == 1) {
        return [
          skinColors[0].withValues(alpha: 1.0),
          skinColors[0].withValues(alpha: 0.8),
          skinColors[0].withValues(alpha: 0.6),
        ];
      } else {
        // For multi-color skins, use the colors directly with varying alpha
        return skinColors.take(3).toList();
      }
    }
    
    // Fall back to original theme-based colors for classic skin
    switch (theme) {
      case GameTheme.classic:
        return [
          theme.snakeColor.withValues(alpha: 1.0),
          theme.snakeColor.withValues(alpha: 0.8),
          theme.snakeColor.withValues(alpha: 0.6),
        ];
      case GameTheme.modern:
        return [
          theme.snakeColor.withValues(alpha: 1.0),
          theme.snakeColor.withValues(alpha: 0.9),
          theme.snakeColor.withValues(alpha: 0.7),
        ];
      case GameTheme.neon:
        return [
          theme.snakeColor.withValues(alpha: 1.0),
          theme.snakeColor.withValues(alpha: 0.9),
          theme.accentColor.withValues(alpha: 0.8),
        ];
      case GameTheme.retro:
        return [
          theme.snakeColor.withValues(alpha: 1.0),
          theme.snakeColor.withValues(alpha: 0.8),
          theme.foodColor.withValues(alpha: 0.6),
        ];
      case GameTheme.space:
        return [
          theme.snakeColor.withValues(alpha: 1.0),
          theme.snakeColor.withValues(alpha: 0.9),
          theme.accentColor.withValues(alpha: 0.7),
        ];
      case GameTheme.ocean:
        return [
          theme.snakeColor.withValues(alpha: 1.0),
          theme.snakeColor.withValues(alpha: 0.9),
          theme.accentColor.withValues(alpha: 0.8),
        ];
      case GameTheme.cyberpunk:
        return [
          theme.snakeColor.withValues(alpha: 1.0),
          theme.snakeColor.withValues(alpha: 0.9),
          theme.accentColor.withValues(alpha: 0.8),
        ];
      case GameTheme.forest:
        return [
          theme.snakeColor.withValues(alpha: 1.0),
          theme.snakeColor.withValues(alpha: 0.9),
          theme.accentColor.withValues(alpha: 0.7),
        ];
      case GameTheme.desert:
        return [
          theme.snakeColor.withValues(alpha: 1.0),
          theme.snakeColor.withValues(alpha: 0.8),
          theme.foodColor.withValues(alpha: 0.6),
        ];
      case GameTheme.crystal:
        return [
          theme.snakeColor.withValues(alpha: 1.0),
          theme.snakeColor.withValues(alpha: 0.9),
          theme.accentColor.withValues(alpha: 0.8),
        ];
    }
  }

  MaskFilter? _getHeadMaskFilter() {
    switch (theme) {
      case GameTheme.classic:
        return null;
      case GameTheme.modern:
        return const MaskFilter.blur(BlurStyle.normal, 1.5);
      case GameTheme.neon:
        return const MaskFilter.blur(BlurStyle.normal, 4.0);
      case GameTheme.retro:
        return const MaskFilter.blur(BlurStyle.normal, 1.0);
      case GameTheme.space:
        return const MaskFilter.blur(BlurStyle.normal, 3.0);
      case GameTheme.ocean:
        return const MaskFilter.blur(BlurStyle.normal, 2.0);
      case GameTheme.cyberpunk:
        return const MaskFilter.blur(BlurStyle.normal, 3.0);
      case GameTheme.forest:
        return const MaskFilter.blur(BlurStyle.normal, 1.5);
      case GameTheme.desert:
        return const MaskFilter.blur(BlurStyle.normal, 1.0);
      case GameTheme.crystal:
        return const MaskFilter.blur(BlurStyle.normal, 4.0);
    }
  }

  void _drawNeonGlow(Canvas canvas, Rect rect, Color color, double intensity) {
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, intensity)
      ..isAntiAlias = true;

    // Draw multiple glow layers for more intense effect
    for (int i = 0; i < 3; i++) {
      final glowRect = Rect.fromCenter(
        center: rect.center,
        width: rect.width + (i + 1) * 4,
        height: rect.height + (i + 1) * 4,
      );
      canvas.drawOval(glowRect, glowPaint);
    }
  }

  void _drawSnakeBody(
    Canvas canvas,
    Rect rect,
    int index,
    int totalLength,
    bool isTail,
  ) {
    // Calculate opacity based on position (head to tail fade)
    final fadeRatio = (totalLength - index) / totalLength;
    final opacity = isTail ? 0.5 : (0.6 + 0.4 * fadeRatio);

    // Add breathing effect to body segments near head
    final breathingIntensity = math.max(0.0, (5 - index) / 5.0); // First 5 segments get breathing
    final breathingScale = 1.0 + (0.02 * breathingIntensity * math.sin(pulseAnimation.value * 2 * math.pi * 2.5));
    
    final breathingRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * breathingScale,
      height: rect.height * breathingScale,
    );

    // Draw enhanced shadow for body segments
    if (!isTail) {
      _drawBodyShadow(canvas, breathingRect, fadeRatio);
    }

    // Theme-specific body styling
    _snakeBodyPaint.color = _getBodyColor(opacity);
    _snakeBodyPaint.maskFilter = _getBodyMaskFilter();

    // Draw neon glow for body segments with breathing effect
    if (theme == GameTheme.neon && !isTail) {
      _drawNeonGlow(canvas, breathingRect, theme.snakeColor, 4.0 * fadeRatio * breathingScale);
    }

    // Enhanced body shape with smooth curves
    final radius = _getBodyRadius(breathingRect);
    canvas.drawRRect(RRect.fromRectAndRadius(breathingRect, radius), _snakeBodyPaint);

    // Add theme-specific highlights with breathing
    _drawBodyHighlight(canvas, breathingRect, isTail, fadeRatio * breathingScale);
  }

  Color _getBodyColor(double opacity) {
    // Use selected skin colors if available, otherwise fall back to theme colors
    final skinColors = _getSelectedSkinColors();
    
    if (skinColors.isNotEmpty && premiumProvider.selectedSkinId != 'classic') {
      // For single color skins, use the color with opacity
      if (skinColors.length == 1) {
        return skinColors[0].withValues(alpha: opacity);
      } else {
        // For multi-color skins, cycle through colors using passed animation time
        final colorIndex = (animationTimeMs ~/ GameConstants.colorCycleIntervalMs) % skinColors.length;
        return skinColors[colorIndex].withValues(alpha: opacity);
      }
    }
    
    // Fall back to original theme-based colors for classic skin
    switch (theme) {
      case GameTheme.classic:
        return theme.snakeColor.withValues(alpha: opacity);
      case GameTheme.modern:
        return theme.snakeColor.withValues(alpha: opacity * 0.9);
      case GameTheme.neon:
        return theme.snakeColor.withValues(alpha: opacity);
      case GameTheme.retro:
        return theme.snakeColor.withValues(alpha: opacity * 0.95);
      case GameTheme.space:
        return theme.snakeColor.withValues(alpha: opacity);
      case GameTheme.ocean:
        return theme.snakeColor.withValues(alpha: opacity * 0.9);
      case GameTheme.cyberpunk:
        return theme.snakeColor.withValues(alpha: opacity);
      case GameTheme.forest:
        return theme.snakeColor.withValues(alpha: opacity * 0.9);
      case GameTheme.desert:
        return theme.snakeColor.withValues(alpha: opacity * 0.95);
      case GameTheme.crystal:
        return theme.snakeColor.withValues(alpha: opacity);
    }
  }

  MaskFilter? _getBodyMaskFilter() {
    switch (theme) {
      case GameTheme.classic:
        return null;
      case GameTheme.modern:
        return const MaskFilter.blur(BlurStyle.normal, 0.5);
      case GameTheme.neon:
        return const MaskFilter.blur(BlurStyle.normal, 2.0);
      case GameTheme.retro:
        return null;
      case GameTheme.space:
        return const MaskFilter.blur(BlurStyle.normal, 1.5);
      case GameTheme.ocean:
        return const MaskFilter.blur(BlurStyle.normal, 1.0);
      case GameTheme.cyberpunk:
        return const MaskFilter.blur(BlurStyle.normal, 2.5);
      case GameTheme.forest:
        return const MaskFilter.blur(BlurStyle.normal, 0.8);
      case GameTheme.desert:
        return null;
      case GameTheme.crystal:
        return const MaskFilter.blur(BlurStyle.normal, 3.0);
    }
  }

  Radius _getBodyRadius(Rect rect) {
    switch (theme) {
      case GameTheme.classic:
        return Radius.circular(rect.width * 0.15);
      case GameTheme.modern:
        return Radius.circular(rect.width * 0.25);
      case GameTheme.neon:
        return Radius.circular(rect.width * 0.3);
      case GameTheme.retro:
        return Radius.circular(rect.width * 0.2);
      case GameTheme.space:
        return Radius.circular(rect.width * 0.3);
      case GameTheme.ocean:
        return Radius.circular(rect.width * 0.25);
      case GameTheme.cyberpunk:
        return Radius.circular(rect.width * 0.2);
      case GameTheme.forest:
        return Radius.circular(rect.width * 0.3);
      case GameTheme.desert:
        return Radius.circular(rect.width * 0.15);
      case GameTheme.crystal:
        return Radius.circular(rect.width * 0.35);
    }
  }

  void _drawBodyHighlight(
    Canvas canvas,
    Rect rect,
    bool isTail,
    double fadeRatio,
  ) {
    if (isTail) return;

    switch (theme) {
      case GameTheme.classic:
        // No highlight for classic theme
        break;
      case GameTheme.modern:
        final highlightRect = Rect.fromLTWH(
          rect.left + rect.width * 0.2,
          rect.top + rect.height * 0.2,
          rect.width * 0.3,
          rect.height * 0.3,
        );

        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.2 * fadeRatio)
          ..isAntiAlias = true;

        canvas.drawOval(highlightRect, highlightPaint);
        break;
      case GameTheme.neon:
        // Core bright spot for neon effect
        final coreRect = Rect.fromLTWH(
          rect.left + rect.width * 0.3,
          rect.top + rect.height * 0.3,
          rect.width * 0.4,
          rect.height * 0.4,
        );

        final corePaint = Paint()
          ..color = theme.accentColor.withValues(alpha: 0.6 * fadeRatio)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0)
          ..isAntiAlias = true;

        canvas.drawOval(coreRect, corePaint);
        break;
      case GameTheme.retro:
        // Warm highlight for retro theme
        final highlightRect = Rect.fromLTWH(
          rect.left + rect.width * 0.2,
          rect.top + rect.height * 0.2,
          rect.width * 0.4,
          rect.height * 0.4,
        );

        final highlightPaint = Paint()
          ..color = theme.foodColor.withValues(alpha: 0.3 * fadeRatio)
          ..isAntiAlias = true;

        canvas.drawOval(highlightRect, highlightPaint);
        break;
      case GameTheme.space:
        // Cosmic glow for space theme
        final glowRect = Rect.fromLTWH(
          rect.left + rect.width * 0.25,
          rect.top + rect.height * 0.25,
          rect.width * 0.5,
          rect.height * 0.5,
        );

        final glowPaint = Paint()
          ..color = theme.accentColor.withValues(alpha: 0.4 * fadeRatio)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
          ..isAntiAlias = true;

        canvas.drawOval(glowRect, glowPaint);
        break;
      case GameTheme.ocean:
        // Aquatic shimmer for ocean theme
        final shimmerRect = Rect.fromLTWH(
          rect.left + rect.width * 0.15,
          rect.top + rect.height * 0.15,
          rect.width * 0.7,
          rect.height * 0.7,
        );

        final shimmerPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.25 * fadeRatio)
          ..isAntiAlias = true;

        canvas.drawOval(shimmerRect, shimmerPaint);
        break;
      case GameTheme.cyberpunk:
        // Digital matrix highlight for cyberpunk theme
        final highlightRect = Rect.fromLTWH(
          rect.left + rect.width * 0.2,
          rect.top + rect.height * 0.2,
          rect.width * 0.6,
          rect.height * 0.6,
        );

        final highlightPaint = Paint()
          ..color = theme.accentColor.withValues(alpha: 0.3 * fadeRatio)
          ..isAntiAlias = true;

        canvas.drawRect(highlightRect, highlightPaint);
        break;
      case GameTheme.forest:
        // Natural organic highlight for forest theme
        final highlightRect = Rect.fromLTWH(
          rect.left + rect.width * 0.25,
          rect.top + rect.height * 0.25,
          rect.width * 0.5,
          rect.height * 0.5,
        );

        final highlightPaint = Paint()
          ..color = theme.foodColor.withValues(alpha: 0.4 * fadeRatio)
          ..isAntiAlias = true;

        canvas.drawOval(highlightRect, highlightPaint);
        break;
      case GameTheme.desert:
        // Sandy shimmer highlight for desert theme
        final highlightRect = Rect.fromLTWH(
          rect.left + rect.width * 0.3,
          rect.top + rect.height * 0.3,
          rect.width * 0.4,
          rect.height * 0.4,
        );

        final highlightPaint = Paint()
          ..color = theme.accentColor.withValues(alpha: 0.35 * fadeRatio)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
          ..isAntiAlias = true;

        canvas.drawOval(highlightRect, highlightPaint);
        break;
      case GameTheme.crystal:
        // Crystalline refraction highlight
        final highlightRect = Rect.fromLTWH(
          rect.left + rect.width * 0.2,
          rect.top + rect.height * 0.2,
          rect.width * 0.6,
          rect.height * 0.6,
        );

        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.5 * fadeRatio)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
          ..isAntiAlias = true;

        canvas.drawOval(highlightRect, highlightPaint);
        break;
    }
  }

  void _drawPowerUp(Canvas canvas, double cellWidth, double cellHeight) {
    final powerUp = gameState.powerUp;
    if (powerUp == null) return;

    // Force square power-up by using the smaller dimension
    final cellSize = math.min(cellWidth, cellHeight);
    final padding = cellSize * 0.05;

    // Center the square power-up in the cell
    final powerUpSize = cellSize - padding * 2;
    final centerX = powerUp.position.x * cellWidth + cellWidth / 2;
    final centerY = powerUp.position.y * cellHeight + cellHeight / 2;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: powerUpSize,
      height: powerUpSize,
    );

    // Draw expiration warning ring if power-up is about to expire
    if (powerUp.isExpiringSoon) {
      _drawExpirationWarning(canvas, rect, powerUp.warningIntensity);
    }

    switch (powerUp.type) {
      case PowerUpType.speedBoost:
        _drawSpeedBoostPowerUp(canvas, rect, powerUp);
        break;
      case PowerUpType.invincibility:
        _drawInvincibilityPowerUp(canvas, rect, powerUp);
        break;
      case PowerUpType.scoreMultiplier:
        _drawScoreMultiplierPowerUp(canvas, rect, powerUp);
        break;
      case PowerUpType.slowMotion:
        _drawSlowMotionPowerUp(canvas, rect, powerUp);
        break;
    }
  }

  // Draw flashing warning ring around power-up about to expire
  void _drawExpirationWarning(Canvas canvas, Rect rect, double intensity) {
    // Rapid flashing effect using animation time
    final flashPhase = (animationTimeMs ~/ 200) % 2;
    final flashAlpha = flashPhase == 0 ? intensity : intensity * 0.3;

    // Warning color blends from orange to red
    final warningColor = Color.lerp(
      Colors.orange,
      Colors.red,
      intensity,
    )!.withValues(alpha: flashAlpha * 0.8);

    // Draw expanding ring
    final expandedRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * (1.3 + intensity * 0.2),
      height: rect.height * (1.3 + intensity * 0.2),
    );

    final warningPaint = Paint()
      ..color = warningColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0 + intensity * 2.0
      ..isAntiAlias = true;

    // Draw warning ring
    canvas.drawOval(expandedRect, warningPaint);

    // Draw inner glow for high intensity
    if (intensity > 0.5) {
      final glowPaint = Paint()
        ..color = warningColor.withValues(alpha: (intensity - 0.5) * 0.4)
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);

      canvas.drawOval(expandedRect, glowPaint);
    }
  }

  void _drawSpeedBoostPowerUp(Canvas canvas, Rect rect, PowerUp powerUp) {
    final pulseScale = 0.9 + 0.1 * powerUp.pulsePhase;
    final scaledRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * pulseScale,
      height: rect.height * pulseScale,
    );

    // Lightning bolt effect
    final paint = Paint()
      ..color = PowerUpType.speedBoost.color
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    // Draw glow effect for certain themes
    if (theme == GameTheme.neon) {
      _drawNeonGlow(canvas, scaledRect, PowerUpType.speedBoost.color, 8.0);
    }

    // Draw lightning bolt shape
    _drawLightningBolt(canvas, scaledRect, paint);
  }

  void _drawInvincibilityPowerUp(Canvas canvas, Rect rect, PowerUp powerUp) {
    final pulseScale = 0.9 + 0.1 * powerUp.pulsePhase;
    final scaledRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * pulseScale,
      height: rect.height * pulseScale,
    );

    // Shield effect with gradient
    final gradient = RadialGradient(
      colors: [
        PowerUpType.invincibility.color.withValues(alpha: 1.0),
        PowerUpType.invincibility.color.withValues(alpha: 0.3),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(scaledRect)
      ..isAntiAlias = true;

    if (theme == GameTheme.neon) {
      _drawNeonGlow(canvas, scaledRect, PowerUpType.invincibility.color, 10.0);
    }

    // Draw shield shape
    _drawShield(canvas, scaledRect, paint);
  }

  void _drawScoreMultiplierPowerUp(Canvas canvas, Rect rect, PowerUp powerUp) {
    final pulseScale = 0.9 + 0.1 * powerUp.pulsePhase;
    final scaledRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * pulseScale,
      height: rect.height * pulseScale,
    );

    // Golden coin effect
    final paint = Paint()
      ..color = PowerUpType.scoreMultiplier.color
      ..isAntiAlias = true
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    if (theme == GameTheme.neon) {
      _drawNeonGlow(canvas, scaledRect, PowerUpType.scoreMultiplier.color, 6.0);
    }

    // Draw coin with dollar sign
    _drawCoin(canvas, scaledRect, paint);
  }

  void _drawSlowMotionPowerUp(Canvas canvas, Rect rect, PowerUp powerUp) {
    final pulseScale = 0.9 + 0.1 * powerUp.pulsePhase;
    final scaledRect = Rect.fromCenter(
      center: rect.center,
      width: rect.width * pulseScale,
      height: rect.height * pulseScale,
    );

    // Spiral/clock effect with gradient
    final gradient = RadialGradient(
      colors: [
        PowerUpType.slowMotion.color.withValues(alpha: 1.0),
        PowerUpType.slowMotion.color.withValues(alpha: 0.5),
      ],
    );

    final paint = Paint()
      ..shader = gradient.createShader(scaledRect)
      ..isAntiAlias = true;

    if (theme == GameTheme.neon) {
      _drawNeonGlow(canvas, scaledRect, PowerUpType.slowMotion.color, 7.0);
    }

    // Draw clock/spiral shape
    _drawSpiral(canvas, scaledRect, paint);
  }

  void _drawLightningBolt(Canvas canvas, Rect rect, Paint paint) {
    final path = Path();
    final center = rect.center;
    final width = rect.width * 0.6;
    final height = rect.height * 0.8;

    // Create zigzag lightning bolt
    path.moveTo(center.dx - width * 0.3, center.dy - height * 0.5);
    path.lineTo(center.dx + width * 0.1, center.dy - height * 0.1);
    path.lineTo(center.dx - width * 0.1, center.dy - height * 0.1);
    path.lineTo(center.dx + width * 0.3, center.dy + height * 0.5);
    path.lineTo(center.dx - width * 0.1, center.dy + height * 0.1);
    path.lineTo(center.dx + width * 0.1, center.dy + height * 0.1);
    path.close();

    canvas.drawPath(path, paint);
  }

  void _drawShield(Canvas canvas, Rect rect, Paint paint) {
    final path = Path();
    final center = rect.center;
    final width = rect.width * 0.7;
    final height = rect.height * 0.8;

    // Create shield shape
    path.moveTo(center.dx, center.dy - height * 0.5);
    path.quadraticBezierTo(
      center.dx + width * 0.5,
      center.dy - height * 0.3,
      center.dx + width * 0.5,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx + width * 0.5,
      center.dy + height * 0.3,
      center.dx,
      center.dy + height * 0.5,
    );
    path.quadraticBezierTo(
      center.dx - width * 0.5,
      center.dy + height * 0.3,
      center.dx - width * 0.5,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx - width * 0.5,
      center.dy - height * 0.3,
      center.dx,
      center.dy - height * 0.5,
    );

    canvas.drawPath(path, paint);
  }

  void _drawCoin(Canvas canvas, Rect rect, Paint paint) {
    // Draw circular coin
    canvas.drawOval(rect, paint);

    // Draw dollar sign
    final center = rect.center;
    final textPaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = true;

    final path = Path();
    final size = rect.width * 0.4;

    // Simple dollar sign shape
    path.moveTo(center.dx - size * 0.2, center.dy - size * 0.3);
    path.quadraticBezierTo(
      center.dx - size * 0.3,
      center.dy - size * 0.1,
      center.dx,
      center.dy,
    );
    path.quadraticBezierTo(
      center.dx + size * 0.3,
      center.dy + size * 0.1,
      center.dx - size * 0.2,
      center.dy + size * 0.3,
    );

    // Vertical line
    path.moveTo(center.dx, center.dy - size * 0.4);
    path.lineTo(center.dx, center.dy + size * 0.4);

    textPaint.strokeWidth = 2.0;
    textPaint.style = PaintingStyle.stroke;
    canvas.drawPath(path, textPaint);
  }

  void _drawSpiral(Canvas canvas, Rect rect, Paint paint) {
    final center = rect.center;
    final maxRadius = rect.width * 0.4;

    final path = Path();
    const turns = 2.5;
    const points = 60;

    for (int i = 0; i <= points; i++) {
      final t = i / points;
      final angle = t * turns * 2 * math.pi;
      final radius = maxRadius * t;

      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 3.0;
    canvas.drawPath(path, paint);
  }

  void _drawSnakeEyes(Canvas canvas, Rect rect, Direction direction) {
    final eyeSize = rect.width * 0.08;
    final eyePaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = true;
    final pupilPaint = Paint()
      ..color = Colors.black
      ..isAntiAlias = true;

    late Offset leftEye, rightEye;

    switch (direction) {
      case Direction.up:
        leftEye = Offset(
          rect.center.dx - rect.width * 0.15,
          rect.top + rect.height * 0.25,
        );
        rightEye = Offset(
          rect.center.dx + rect.width * 0.15,
          rect.top + rect.height * 0.25,
        );
        break;
      case Direction.down:
        leftEye = Offset(
          rect.center.dx - rect.width * 0.15,
          rect.bottom - rect.height * 0.25,
        );
        rightEye = Offset(
          rect.center.dx + rect.width * 0.15,
          rect.bottom - rect.height * 0.25,
        );
        break;
      case Direction.left:
        leftEye = Offset(
          rect.left + rect.width * 0.25,
          rect.center.dy - rect.height * 0.15,
        );
        rightEye = Offset(
          rect.left + rect.width * 0.25,
          rect.center.dy + rect.height * 0.15,
        );
        break;
      case Direction.right:
        leftEye = Offset(
          rect.right - rect.width * 0.25,
          rect.center.dy - rect.height * 0.15,
        );
        rightEye = Offset(
          rect.right - rect.width * 0.25,
          rect.center.dy + rect.height * 0.15,
        );
        break;
    }

    // Draw eyes
    canvas.drawCircle(leftEye, eyeSize, eyePaint);
    canvas.drawCircle(rightEye, eyeSize, eyePaint);
    canvas.drawCircle(leftEye, eyeSize * 0.6, pupilPaint);
    canvas.drawCircle(rightEye, eyeSize * 0.6, pupilPaint);
  }

  void _drawDirectionIndicator(Canvas canvas, Rect rect, Direction direction) {
    final indicatorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..isAntiAlias = true;

    final path = Path();
    final center = rect.center;
    final size = rect.width * 0.1;

    switch (direction) {
      case Direction.up:
        path.moveTo(center.dx, rect.top + rect.height * 0.1);
        path.lineTo(center.dx - size, rect.top + rect.height * 0.25);
        path.lineTo(center.dx + size, rect.top + rect.height * 0.25);
        break;
      case Direction.down:
        path.moveTo(center.dx, rect.bottom - rect.height * 0.1);
        path.lineTo(center.dx - size, rect.bottom - rect.height * 0.25);
        path.lineTo(center.dx + size, rect.bottom - rect.height * 0.25);
        break;
      case Direction.left:
        path.moveTo(rect.left + rect.width * 0.1, center.dy);
        path.lineTo(rect.left + rect.width * 0.25, center.dy - size);
        path.lineTo(rect.left + rect.width * 0.25, center.dy + size);
        break;
      case Direction.right:
        path.moveTo(rect.right - rect.width * 0.1, center.dy);
        path.lineTo(rect.right - rect.width * 0.25, center.dy - size);
        path.lineTo(rect.right - rect.width * 0.25, center.dy + size);
        break;
    }

    path.close();
    canvas.drawPath(path, indicatorPaint);
  }

  void _drawEnhancedHeadShadow(Canvas canvas, Rect rect) {
    // Create shadow with multiple layers for more realistic depth
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
      ..isAntiAlias = true;

    // Main shadow - offset down and right slightly
    final shadowRect = Rect.fromLTWH(
      rect.left + 2,
      rect.top + 3,
      rect.width,
      rect.height,
    );
    
    final radius = Radius.circular(rect.width * 0.3);
    canvas.drawRRect(RRect.fromRectAndRadius(shadowRect, radius), shadowPaint);

    // Deeper shadow for more dramatic effect on certain themes
    if (theme == GameTheme.neon || theme == GameTheme.space || theme == GameTheme.cyberpunk) {
      final deepShadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0)
        ..isAntiAlias = true;

      final deepShadowRect = Rect.fromLTWH(
        rect.left + 4,
        rect.top + 5,
        rect.width,
        rect.height,
      );
      
      canvas.drawRRect(RRect.fromRectAndRadius(deepShadowRect, radius), deepShadowPaint);
    }
  }

  void _drawBreathingHighlight(Canvas canvas, Rect rect, double breathingScale) {
    // Subtle breathing highlight that pulses
    final highlightIntensity = 0.15 + 0.05 * (breathingScale - 1.0) / 0.03; // Scale intensity with breathing
    
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: highlightIntensity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
      ..isAntiAlias = true;

    // Small highlight spot that moves slightly with breathing
    final highlightRect = Rect.fromLTWH(
      rect.left + rect.width * 0.25,
      rect.top + rect.height * 0.2,
      rect.width * 0.3 * breathingScale,
      rect.height * 0.3 * breathingScale,
    );

    canvas.drawOval(highlightRect, highlightPaint);
  }

  void _drawBodyShadow(Canvas canvas, Rect rect, double fadeRatio) {
    // Body shadow with opacity based on position
    final shadowOpacity = 0.2 * fadeRatio;
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: shadowOpacity)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
      ..isAntiAlias = true;

    // Offset shadow slightly
    final shadowRect = Rect.fromLTWH(
      rect.left + 1,
      rect.top + 2,
      rect.width,
      rect.height,
    );
    
    final radius = Radius.circular(rect.width * 0.25);
    canvas.drawRRect(RRect.fromRectAndRadius(shadowRect, radius), shadowPaint);
  }

  void _drawFood(Canvas canvas, double cellWidth, double cellHeight) {
    final food = gameState.food;
    if (food == null) return;

    // Force square food by using the smaller dimension
    final cellSize = math.min(cellWidth, cellHeight);
    final padding = _getFoodPadding(cellSize, food.type);

    // Center the square food in the cell
    final foodSize = cellSize - padding * 2;
    final centerX = food.position.x * cellWidth + cellWidth / 2;
    final centerY = food.position.y * cellHeight + cellHeight / 2;

    final rect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: foodSize,
      height: foodSize,
    );

    switch (food.type) {
      case FoodType.normal:
        _drawNormalFood(canvas, rect);
        break;
      case FoodType.bonus:
        _drawBonusFood(canvas, rect);
        break;
      case FoodType.special:
        _drawSpecialFood(canvas, rect);
        break;
    }
  }

  double _getFoodPadding(double cellSize, FoodType type) {
    switch (type) {
      case FoodType.normal:
        return cellSize * 0.12; // Normal size - more padding for cleaner look
      case FoodType.bonus:
        return cellSize * 0.08; // Slightly bigger
      case FoodType.special:
        return cellSize * 0.04; // Much bigger - almost fills cell
    }
  }

  void _drawNormalFood(Canvas canvas, Rect rect) {
    // Draw apple-like shape for normal food
    _drawAppleFood(canvas, rect);
  }

  void _drawAppleFood(Canvas canvas, Rect rect) {
    final center = rect.center;
    final size = rect.width; // rect is now guaranteed to be square
    final radius = size / 2;

    // Draw neon glow for neon theme first
    if (theme == GameTheme.neon) {
      _drawNeonGlow(canvas, rect, theme.foodColor, 6.0);
    }

    // Apple body - perfect circle for clean look
    final appleRadius = radius * 0.85; // Slightly smaller than the full rect

    // Apple gradient - red to darker red
    final appleGradient = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 0.8,
      colors: [
        const Color(0xFFFF6B6B), // Light red
        const Color(0xFFDC143C), // Crimson
        const Color(0xFF8B0000), // Dark red
      ],
      stops: const [0.0, 0.6, 1.0],
    );

    final appleRect = Rect.fromCenter(
      center: center,
      width: appleRadius * 2,
      height: appleRadius * 2,
    );

    final applePaint = Paint()
      ..shader = appleGradient.createShader(appleRect)
      ..isAntiAlias = true;

    if (theme == GameTheme.neon) {
      applePaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);
    }

    // Draw apple body as perfect circle
    canvas.drawCircle(center, appleRadius, applePaint);

    // Apple highlight - smaller and better positioned
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..isAntiAlias = true;

    final highlightCenter = Offset(
      center.dx - appleRadius * 0.25,
      center.dy - appleRadius * 0.35,
    );

    canvas.drawCircle(highlightCenter, appleRadius * 0.2, highlightPaint);

    // Apple stem - small rectangle at top
    final stemPaint = Paint()
      ..color =
          const Color(0xFF8B4513) // Brown
      ..isAntiAlias = true;

    final stemRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - appleRadius - radius * 0.08),
      width: radius * 0.12,
      height: radius * 0.15,
    );

    canvas.drawRect(stemRect, stemPaint);

    // Small leaf on stem
    final leafPaint = Paint()
      ..color =
          const Color(0xFF228B22) // Forest green
      ..isAntiAlias = true;

    final leafRect = Rect.fromCenter(
      center: Offset(
        center.dx + radius * 0.08,
        center.dy - appleRadius - radius * 0.05,
      ),
      width: radius * 0.15,
      height: radius * 0.08,
    );

    canvas.drawOval(leafRect, leafPaint);
  }

  MaskFilter? _getFoodMaskFilter() {
    switch (theme) {
      case GameTheme.classic:
        return null;
      case GameTheme.modern:
        return const MaskFilter.blur(BlurStyle.normal, 1.0);
      case GameTheme.neon:
        return const MaskFilter.blur(BlurStyle.normal, 3.0);
      case GameTheme.retro:
        return const MaskFilter.blur(BlurStyle.normal, 0.5);
      case GameTheme.space:
        return const MaskFilter.blur(BlurStyle.normal, 2.0);
      case GameTheme.ocean:
        return const MaskFilter.blur(BlurStyle.normal, 1.5);
      case GameTheme.cyberpunk:
        return const MaskFilter.blur(BlurStyle.normal, 2.5);
      case GameTheme.forest:
        return const MaskFilter.blur(BlurStyle.normal, 1.0);
      case GameTheme.desert:
        return const MaskFilter.blur(BlurStyle.normal, 0.8);
      case GameTheme.crystal:
        return const MaskFilter.blur(BlurStyle.normal, 3.5);
    }
  }

  void _drawBonusFood(Canvas canvas, Rect rect) {
    // Enhanced bonus food with theme-specific effects
    final colors = theme == GameTheme.neon
        ? [theme.foodColor, theme.accentColor, const Color(0xFFFFD700)]
        : [theme.foodColor, Colors.orange, const Color(0xFFFFD700)];

    final outerGradient = LinearGradient(colors: colors).createShader(rect);
    _foodPaint.shader = outerGradient;
    _foodPaint.maskFilter = _getFoodMaskFilter();

    // Enhanced glow for bonus food
    if (theme == GameTheme.neon) {
      _drawNeonGlow(canvas, rect, theme.foodColor, 8.0);
    }

    // Use guaranteed square dimensions
    final radius = rect.width / 2; // rect is now square
    canvas.drawCircle(rect.center, radius * 0.9, _foodPaint);

    // Theme-specific inner effects
    final innerAlpha = theme == GameTheme.neon ? 0.7 : 0.5;
    final innerPaint = Paint()
      ..color = Colors.white.withValues(alpha: innerAlpha)
      ..isAntiAlias = true;

    if (theme == GameTheme.neon) {
      innerPaint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    }

    canvas.drawCircle(rect.center, radius * 0.4, innerPaint);

    // Enhanced sparkle effect
    final sparkleCount = theme == GameTheme.neon ? 5 : 3;
    _drawSparkles(canvas, rect, sparkleCount);
  }

  void _drawSpecialFood(Canvas canvas, Rect rect) {
    final scale = pulseAnimation.value;

    // Theme-specific special food colors
    final colors = theme == GameTheme.neon
        ? [
            const Color(0xFFFFD700), // Gold
            theme.accentColor, // Neon green
            theme.foodColor, // Deep pink
            const Color(0xFF00FFFF), // Electric cyan
          ]
        : [
            const Color(0xFFFFD700), // Gold
            theme.foodColor,
            const Color(0xFF9C27B0), // Purple
            const Color(0xFF00BCD4), // Cyan
          ];

    // Draw massive glow for neon theme
    if (theme == GameTheme.neon) {
      _drawNeonGlow(canvas, rect, const Color(0xFFFFD700), 15.0 * scale);
    }

    // Draw special food as a star shape instead of circle for distinction
    _drawSpecialFoodStar(canvas, rect, colors, scale);

    // Enhanced sparkle effect with theme-specific count
    final sparkleCount = theme == GameTheme.neon ? 12 : 8;
    _drawSparkles(canvas, rect, sparkleCount);
  }

  void _drawSpecialFoodStar(
    Canvas canvas,
    Rect rect,
    List<Color> colors,
    double scale,
  ) {
    final center = rect.center;
    final outerRadius = (rect.width / 2) * scale;
    final innerRadius = outerRadius * 0.4;

    // Multi-layer star with enhanced effects
    for (int i = colors.length - 1; i >= 0; i--) {
      final layerOuterRadius = outerRadius * (1.0 - i * 0.15);
      final layerInnerRadius = innerRadius * (1.0 - i * 0.15);

      final layerPaint = Paint()
        ..color = colors[i].withValues(alpha: 0.95)
        ..isAntiAlias = true;

      // Enhanced blur effects based on theme
      final blurIntensity = theme == GameTheme.neon
          ? 4.0 + i.toDouble() * 2.0
          : 2.0 + i.toDouble();

      layerPaint.maskFilter = MaskFilter.blur(BlurStyle.normal, blurIntensity);

      // Draw 8-pointed star
      final starPath = _createStarPath(
        center,
        layerOuterRadius,
        layerInnerRadius,
        8,
      );
      canvas.drawPath(starPath, layerPaint);
    }
  }

  Path _createStarPath(
    Offset center,
    double outerRadius,
    double innerRadius,
    int points,
  ) {
    final path = Path();
    final angleStep = (math.pi * 2) / (points * 2);

    for (int i = 0; i < points * 2; i++) {
      final angle = i * angleStep - math.pi / 2; // Start from top
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final x = center.dx + radius * math.cos(angle);
      final y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    return path;
  }

  void _drawSparkles(Canvas canvas, Rect rect, int count) {
    final sparklePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..strokeWidth = 1.5
      ..isAntiAlias = true;

    final sparkleSize = rect.width * 0.1;

    for (int i = 0; i < count; i++) {
      final angle = (i * 60.0 + animationTimeMs * 0.01) * (3.14159 / 180);
      final radius = rect.width * (0.3 + 0.2 * (i % 2));
      final sparkleCenter = Offset(
        rect.center.dx + radius * math.cos(angle),
        rect.center.dy + radius * math.sin(angle),
      );

      // Draw cross sparkle
      canvas.drawLine(
        Offset(sparkleCenter.dx - sparkleSize, sparkleCenter.dy),
        Offset(sparkleCenter.dx + sparkleSize, sparkleCenter.dy),
        sparklePaint,
      );
      canvas.drawLine(
        Offset(sparkleCenter.dx, sparkleCenter.dy - sparkleSize),
        Offset(sparkleCenter.dx, sparkleCenter.dy + sparkleSize),
        sparklePaint,
      );
    }
  }

  void _drawCrashIndicators(
    Canvas canvas,
    double cellWidth,
    double cellHeight,
  ) {
    final crashPosition = gameState.crashPosition!;
    final crashReason = gameState.crashReason!;

    // Blinking animation for better visibility (rapid on/off blinking)
    final blinkValue = pulseAnimation.value;
    final isVisible =
        (blinkValue > 0.5); // Creates strong on/off blinking effect

    if (isVisible) {
      final pulseIntensity = 1.0; // Full intensity when visible
      if (crashReason == CrashReason.wallCollision) {
        _drawWallCrashIndicator(
          canvas,
          crashPosition,
          cellWidth,
          cellHeight,
          pulseIntensity,
        );
      } else if (crashReason == CrashReason.selfCollision) {
        _drawSelfCollisionIndicator(
          canvas,
          crashPosition,
          cellWidth,
          cellHeight,
          pulseIntensity,
        );
      }
    }
  }

  void _drawWallCrashIndicator(
    Canvas canvas,
    Position crashPosition,
    double cellWidth,
    double cellHeight,
    double pulseIntensity,
  ) {
    // Show wall collision with red "X" and warning signs
    final rect = Rect.fromLTWH(
      crashPosition.x * cellWidth,
      crashPosition.y * cellHeight,
      cellWidth,
      cellHeight,
    );

    // Background flash
    _crashPaint.color = Colors.red.withValues(alpha: 0.6 * pulseIntensity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cellWidth * 0.1)),
      _crashPaint,
    );

    // Draw "X" mark
    _collisionPaint.color = Colors.white.withValues(
      alpha: 0.9 * pulseIntensity,
    );
    _collisionPaint.strokeWidth = cellWidth * 0.15;

    final margin = cellWidth * 0.2;
    canvas.drawLine(
      Offset(rect.left + margin, rect.top + margin),
      Offset(rect.right - margin, rect.bottom - margin),
      _collisionPaint,
    );
    canvas.drawLine(
      Offset(rect.right - margin, rect.top + margin),
      Offset(rect.left + margin, rect.bottom - margin),
      _collisionPaint,
    );

    // Draw border around crash position
    _collisionPaint.color = Colors.red.withValues(alpha: 0.8 * pulseIntensity);
    _collisionPaint.strokeWidth = 4.0;
    _collisionPaint.style = PaintingStyle.stroke;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cellWidth * 0.15)),
      _collisionPaint,
    );
  }

  void _drawSelfCollisionIndicator(
    Canvas canvas,
    Position crashPosition,
    double cellWidth,
    double cellHeight,
    double pulseIntensity,
  ) {
    final rect = Rect.fromLTWH(
      crashPosition.x * cellWidth,
      crashPosition.y * cellHeight,
      cellWidth,
      cellHeight,
    );

    // Head crash position - orange flash
    _crashPaint.color = Colors.orange.withValues(alpha: 0.7 * pulseIntensity);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cellWidth * 0.1)),
      _crashPaint,
    );

    // Draw collision point marker at head
    _collisionPaint.color = Colors.white.withValues(
      alpha: 0.9 * pulseIntensity,
    );
    _collisionPaint.style = PaintingStyle.fill;
    canvas.drawCircle(rect.center, cellWidth * 0.15, _collisionPaint);

    // Highlight the body part that was hit (if available)
    if (gameState.collisionBodyPart != null) {
      final bodyPartRect = Rect.fromLTWH(
        gameState.collisionBodyPart!.x * cellWidth,
        gameState.collisionBodyPart!.y * cellHeight,
        cellWidth,
        cellHeight,
      );

      // Yellow highlight for the body part that was hit
      _crashPaint.color = Colors.yellow.withValues(alpha: 0.6 * pulseIntensity);
      canvas.drawRRect(
        RRect.fromRectAndRadius(bodyPartRect, Radius.circular(cellWidth * 0.1)),
        _crashPaint,
      );

      // Draw connection line between head and collision body part
      _collisionPaint.color = Colors.red.withValues(
        alpha: 0.7 * pulseIntensity,
      );
      _collisionPaint.style = PaintingStyle.stroke;
      _collisionPaint.strokeWidth = 3.0;

      canvas.drawLine(rect.center, bodyPartRect.center, _collisionPaint);

      // Draw border around collision body part
      _collisionPaint.color = Colors.yellow.withValues(
        alpha: 0.8 * pulseIntensity,
      );
      _collisionPaint.strokeWidth = 3.0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          bodyPartRect,
          Radius.circular(cellWidth * 0.15),
        ),
        _collisionPaint,
      );
    }

    // Draw border around head crash position
    _collisionPaint.color = Colors.orange.withValues(
      alpha: 0.8 * pulseIntensity,
    );
    _collisionPaint.strokeWidth = 4.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(cellWidth * 0.15)),
      _collisionPaint,
    );
  }

  // Get the selected skin colors
  List<Color> _getSelectedSkinColors() {
    final selectedSkinType = SnakeSkinType.values.firstWhere(
      (type) => type.id == premiumProvider.selectedSkinId,
      orElse: () => SnakeSkinType.classic,
    );
    return selectedSkinType.colors;
  }


  @override
  bool shouldRepaint(covariant OptimizedGameBoardPainter oldDelegate) {
    return oldDelegate.gameState != gameState ||
        oldDelegate.theme != theme ||
        oldDelegate.pulseAnimation.value != pulseAnimation.value ||
        oldDelegate.moveProgress != moveProgress ||
        oldDelegate.previousGameState != previousGameState ||
        oldDelegate.premiumProvider.selectedSkinId != premiumProvider.selectedSkinId ||
        oldDelegate.premiumProvider.selectedTrailId != premiumProvider.selectedTrailId;
  }
}

// Background painter for enhanced visual effects matching home screen
class _GameBoardBackgroundPainter extends CustomPainter {
  final GameTheme theme;

  _GameBoardBackgroundPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    // Base grid pattern matching home screen
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = theme.accentColor.withValues(alpha: 0.08);

    const gridSize = 35.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Decorative shapes matching home screen
    final shapePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = theme.foodColor.withValues(alpha: 0.025);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.25),
      60,
      shapePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      80,
      shapePaint,
    );

    // Additional theme-specific enhancements
    switch (theme) {
      case GameTheme.neon:
        _drawNeonEnhancements(canvas, size);
        break;
      case GameTheme.space:
        _drawSpaceEnhancements(canvas, size);
        break;
      case GameTheme.ocean:
        _drawOceanEnhancements(canvas, size);
        break;
      case GameTheme.modern:
        _drawModernEnhancements(canvas, size);
        break;
      case GameTheme.retro:
        _drawRetroEnhancements(canvas, size);
        break;
      case GameTheme.cyberpunk:
        _drawCyberpunkEnhancements(canvas, size);
        break;
      case GameTheme.forest:
        _drawForestEnhancements(canvas, size);
        break;
      case GameTheme.desert:
        _drawDesertEnhancements(canvas, size);
        break;
      case GameTheme.crystal:
        _drawCrystalEnhancements(canvas, size);
        break;
      case GameTheme.classic:
        // Minimal enhancements for classic theme
        break;
    }
  }

  void _drawNeonEnhancements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.04)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

    // Subtle glowing circuit lines
    for (int i = 0; i < 6; i++) {
      final y = (i + 1) * size.height / 7;
      final path = Path()
        ..moveTo(0, y)
        ..lineTo(size.width * 0.4, y)
        ..lineTo(size.width * 0.45, y - 3)
        ..lineTo(size.width * 0.55, y - 3)
        ..lineTo(size.width * 0.6, y)
        ..lineTo(size.width, y);
      canvas.drawPath(path, paint);
    }
  }

  void _drawSpaceEnhancements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    // Subtle floating stars
    for (int i = 0; i < 12; i++) {
      final x = (i * 53) % size.width;
      final y = (i * 79) % size.height;
      _drawTinystar(canvas, Offset(x, y), 1.5, paint);
    }
  }

  void _drawOceanEnhancements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Subtle wave ripples
    for (int i = 0; i < 4; i++) {
      final y = (i + 1) * size.height / 5;
      final path = Path()..moveTo(0, y);

      for (double x = 0; x <= size.width; x += 15) {
        final waveY = y + math.sin((x + i * 20) * 0.03) * 6;
        path.lineTo(x, waveY);
      }
      canvas.drawPath(path, paint);
    }
  }

  void _drawModernEnhancements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.03)
      ..style = PaintingStyle.fill;

    // Subtle geometric dots
    for (int i = 0; i < 8; i++) {
      final x = (i * 71) % size.width;
      final y = (i * 97) % size.height;
      final rect = Rect.fromCenter(center: Offset(x, y), width: 3, height: 3);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1.5)),
        paint,
      );
    }
  }

  void _drawRetroEnhancements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.04)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Subtle retro diagonal accents
    for (int i = 0; i < 15; i++) {
      final offset = i * 40.0;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset - size.height * 0.3, size.height * 0.3),
        paint,
      );
    }
  }

  void _drawCyberpunkEnhancements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);

    // Digital matrix-like grid pattern
    for (int i = 0; i < 8; i++) {
      final x = (i + 1) * size.width / 9;
      final path = Path()
        ..moveTo(x, 0)
        ..lineTo(x, size.height * 0.3)
        ..moveTo(x, size.height * 0.7)
        ..lineTo(x, size.height);
      canvas.drawPath(path, paint);
    }

    // Glowing data streams
    paint.color = theme.foodColor.withValues(alpha: 0.04);
    for (int i = 0; i < 3; i++) {
      final y = (i + 1) * size.height / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  void _drawForestEnhancements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    // Organic leaf-like patterns
    for (int i = 0; i < 6; i++) {
      final x = (i * 73) % size.width;
      final y = (i * 101) % size.height;
      _drawLeafShape(canvas, Offset(x, y), 3.0, paint);
    }

    // Subtle branch patterns
    final branchPaint = Paint()
      ..color = theme.foodColor.withValues(alpha: 0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 4; i++) {
      final startX = i * size.width / 4;
      final path = Path()
        ..moveTo(startX, size.height)
        ..quadraticBezierTo(
          startX + size.width / 8,
          size.height * 0.7,
          startX + size.width / 6,
          size.height * 0.3,
        );
      canvas.drawPath(path, branchPaint);
    }
  }

  void _drawDesertEnhancements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.04)
      ..style = PaintingStyle.fill;

    // Sand dune patterns
    for (int i = 0; i < 5; i++) {
      final x = (i * 89) % size.width;
      final y = (i * 67) % size.height;
      _drawSandDune(canvas, Offset(x, y), 4.0, paint);
    }

    // Subtle wind lines
    final windPaint = Paint()
      ..color = theme.foodColor.withValues(alpha: 0.02)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final y = i * size.height / 8;
      final path = Path()..moveTo(0, y);

      for (double x = 0; x <= size.width; x += 20) {
        final waveY = y + math.sin((x + i * 30) * 0.02) * 3;
        path.lineTo(x, waveY);
      }
      canvas.drawPath(path, windPaint);
    }
  }

  void _drawCrystalEnhancements(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    // Crystalline patterns
    for (int i = 0; i < 10; i++) {
      final x = (i * 59) % size.width;
      final y = (i * 83) % size.height;
      _drawCrystalShape(canvas, Offset(x, y), 2.0, paint);
    }

    // Prismatic light rays
    final rayPaint = Paint()
      ..color = theme.foodColor.withValues(alpha: 0.06)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 6; i++) {
      final angle = i * math.pi / 3;
      final startX = size.width / 2;
      final startY = size.height / 2;
      final endX = startX + math.cos(angle) * size.width * 0.4;
      final endY = startY + math.sin(angle) * size.height * 0.4;

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), rayPaint);
    }
  }

  void _drawLeafShape(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..quadraticBezierTo(
        center.dx + size * 0.7,
        center.dy - size * 0.3,
        center.dx,
        center.dy + size,
      )
      ..quadraticBezierTo(
        center.dx - size * 0.7,
        center.dy - size * 0.3,
        center.dx,
        center.dy - size,
      );
    canvas.drawPath(path, paint);
  }

  void _drawSandDune(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path()
      ..moveTo(center.dx - size * 2, center.dy)
      ..quadraticBezierTo(
        center.dx - size,
        center.dy - size,
        center.dx,
        center.dy,
      )
      ..quadraticBezierTo(
        center.dx + size,
        center.dy + size * 0.5,
        center.dx + size * 2,
        center.dy,
      );
    canvas.drawPath(path, paint);
  }

  void _drawCrystalShape(
    Canvas canvas,
    Offset center,
    double size,
    Paint paint,
  ) {
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx + size * 0.7, center.dy - size * 0.3)
      ..lineTo(center.dx + size * 0.3, center.dy + size)
      ..lineTo(center.dx - size * 0.3, center.dy + size)
      ..lineTo(center.dx - size * 0.7, center.dy - size * 0.3)
      ..close();
    canvas.drawPath(path, paint);
  }

  void _drawTinystar(Canvas canvas, Offset center, double size, Paint paint) {
    final path = Path();
    for (int i = 0; i < 4; i++) {
      final angle = i * math.pi / 2;
      final x = center.dx + size * math.cos(angle);
      final y = center.dy + size * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
