import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/screens/game_over_screen.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/game_board.dart';
import 'package:snake_classic/widgets/game_hud.dart';
import 'package:snake_classic/widgets/pause_overlay.dart';
import 'package:snake_classic/widgets/swipe_detector.dart';
import 'package:snake_classic/widgets/crash_feedback_overlay.dart';
import 'package:snake_classic/widgets/screen_shake.dart';
import 'package:snake_classic/models/food.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  Direction? _lastSwipeDirection;
  late AnimationController _gestureIndicatorController;
  late GameJuiceController _juiceController;
  GameState? _previousGameState;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize gesture indicator animation controller
    _gestureIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize game juice controller
    _juiceController = GameJuiceController();

    // Start the game when screen loads (only if not already playing)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      gameProvider.setContext(context); // Set context for premium features
      if (gameProvider.gameState.status == GameStatus.menu) {
        gameProvider.startGame();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gestureIndicatorController.dispose();
    _juiceController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final gameProvider = context.read<GameProvider>();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (gameProvider.isPlaying) {
        gameProvider.pauseGame();
      }
    }
  }

  void _handleSwipe(Direction direction) {
    context.read<GameProvider>().changeDirection(direction);

    // Update last swipe direction and animate indicator
    setState(() {
      _lastSwipeDirection = direction;
    });

    // Animate the gesture indicator
    _gestureIndicatorController.forward().then((_) {
      _gestureIndicatorController.reverse();
    });
  }

  void _showExitConfirmation(BuildContext context) {
    final gameProvider = context.read<GameProvider>();
    final themeProvider = context.read<ThemeProvider>();
    final theme = themeProvider.currentTheme;

    // Pause the game if it's playing
    if (gameProvider.isPlaying) {
      gameProvider.pauseGame();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
        ),
        title: Text(
          'Exit Game?',
          style: TextStyle(
            color: theme.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to exit? Your current progress will be lost.',
          style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              if (gameProvider.gameState.status == GameStatus.paused) {
                gameProvider.resumeGame(); // Resume if was playing
              }
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Exit game
            },
            child: Text('Exit', style: TextStyle(color: theme.foodColor)),
          ),
        ],
      ),
    );
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      Direction? direction;

      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.keyW:
          direction = Direction.up;
          break;
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.keyS:
          direction = Direction.down;
          break;
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.keyA:
          direction = Direction.left;
          break;
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.keyD:
          direction = Direction.right;
          break;
        case LogicalKeyboardKey.space:
          context.read<GameProvider>().togglePause();
          break;
      }

      if (direction != null) {
        _handleSwipe(direction);
      }
    }
  }

  void _checkForGameEvents(GameState? previous, GameState current) {
    if (previous == null) return;

    // Food consumption effects
    if (current.score > previous.score && previous.food != null) {
      switch (previous.food!.type) {
        case FoodType.normal:
          _juiceController.foodEaten();
          break;
        case FoodType.bonus:
          _juiceController.bonusFoodEaten();
          break;
        case FoodType.special:
          _juiceController.specialFoodEaten();
          break;
      }
    }

    // Power-up collection effects
    if (previous.powerUp != null && current.powerUp == null) {
      _juiceController.powerUpCollected();
    }

    // Crash effects
    if (current.status == GameStatus.crashed &&
        previous.status != GameStatus.crashed) {
      if (current.crashReason == CrashReason.wallCollision) {
        _juiceController.wallHit();
      } else if (current.crashReason == CrashReason.selfCollision) {
        _juiceController.selfCollision();
      }
    }

    // Level up effects
    if (current.level > previous.level) {
      _juiceController.levelUp();
    }

    // Game over effects
    if (current.status == GameStatus.gameOver &&
        previous.status != GameStatus.gameOver) {
      _juiceController.gameOver();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, ThemeProvider>(
      builder: (context, gameProvider, themeProvider, child) {
        final gameState = gameProvider.gameState;
        final theme = themeProvider.currentTheme;

        // Check for game events and trigger screen shake effects
        _checkForGameEvents(_previousGameState, gameState);
        _previousGameState = gameState;

        // Navigate to game over screen when game ends
        if (gameState.status == GameStatus.gameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const GameOverScreen()),
            );
          });
        }

        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: _handleKeyPress,
          child: GameJuiceWidget(
            controller: _juiceController,
            applyShake: true,
            applyScale: false, // Don't apply scale to the entire screen
            child: Scaffold(
              backgroundColor: theme.backgroundColor,
              body: SafeArea(
                child: SwipeDetector(
                  onSwipe: _handleSwipe,
                  showFeedback: false, // Disable animated feedback
                  child: Stack(
                    children: [
                      // Background gradient - matching home screen
                      Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.topRight,
                            radius: 1.5,
                            colors: [
                              theme.accentColor.withValues(alpha: 0.15),
                              theme.backgroundColor,
                              theme.backgroundColor.withValues(alpha: 0.9),
                              Colors.black.withValues(alpha: 0.1),
                            ],
                            stops: const [0.0, 0.4, 0.8, 1.0],
                          ),
                        ),
                      ),

                      // Background pattern overlay - matching home screen
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _GameBackgroundPainter(theme),
                        ),
                      ),

                      // Main game content
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final screenHeight = constraints.maxHeight;
                          final isSmallScreen = screenHeight < 700;

                          return Column(
                            children: [
                              // HUD
                              GameHUD(
                                gameState: gameState,
                                theme: theme,
                                onPause: () => gameProvider.togglePause(),
                                onHome: () => _showExitConfirmation(context),
                                isSmallScreen: isSmallScreen,
                                tournamentId: gameProvider.tournamentId,
                                tournamentMode: gameProvider.tournamentMode,
                              ),

                              // Compact Game Instructions (consistent spacing)
                              _buildCompactInstructions(theme, isSmallScreen),

                              // Static row above game board - Game Hint and Gesture Indicator
                              _buildStaticGameRow(theme, isSmallScreen),

                              // Game Board
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: isSmallScreen ? 8 : 12,
                                  ),
                                  child: LayoutBuilder(
                                    builder: (context, boardConstraints) {
                                      // Calculate optimal board size
                                      final availableSize = math.min(
                                        boardConstraints.maxWidth,
                                        boardConstraints.maxHeight -
                                            (isSmallScreen
                                                ? 40
                                                : 60), // Reserve space for info
                                      );

                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // Game Board
                                          SizedBox(
                                            width: availableSize,
                                            height: availableSize,
                                            child: GameBoard(
                                              gameState: gameState,
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),

                              // Compact Game Info Footer
                              _buildCompactGameInfo(
                                gameState,
                                theme,
                                isSmallScreen,
                              ),
                            ],
                          );
                        },
                      ),

                      // Pause Overlay
                      if (gameState.status == GameStatus.paused)
                        PauseOverlay(
                          theme: theme,
                          onResume: () => gameProvider.resumeGame(),
                          onRestart: () {
                            gameProvider.startGame();
                          },
                          onHome: () => Navigator.of(context).pop(),
                        ),

                      // Crash Feedback Overlay
                      if (gameState.status == GameStatus.crashed &&
                          gameState.crashReason != null &&
                          gameState.showCrashModal)
                        CrashFeedbackOverlay(
                          crashReason: gameState.crashReason!,
                          theme: theme,
                          onSkip: () => gameProvider.skipCrashFeedback(),
                          duration: const Duration(
                            seconds: 3,
                          ), // Reduced from 5 to 3 seconds
                        ),
                    ],
                  ),
                ),
              ),
            ), // Close Scaffold
          ), // Close GameJuiceWidget
        ); // Close KeyboardListener
      }, // Close Consumer2 builder
    );
  }

  Widget _buildCompactGameInfo(
    GameState gameState,
    GameTheme theme,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildCompactInfoCard(
            'Length',
            '${gameState.snake.length}',
            Icons.straighten,
            theme,
            isSmallScreen,
          ),
          _buildCompactInfoCard(
            'Level',
            '${gameState.level}',
            Icons.trending_up,
            theme,
            isSmallScreen,
          ),
          _buildCompactInfoCard(
            'Speed',
            '${((400 - gameState.gameSpeed) / 3).round()}%',
            Icons.speed,
            theme,
            isSmallScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInfoCard(
    String label,
    String value,
    IconData icon,
    GameTheme theme,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 12,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.accentColor.withValues(alpha: 0.8),
            size: isSmallScreen ? 14 : 16,
          ),
          SizedBox(height: isSmallScreen ? 2 : 4),
          Text(
            value,
            style: TextStyle(
              color: theme.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: isSmallScreen ? 11 : 12,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.6),
              fontSize: isSmallScreen ? 8 : 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactInstructions(GameTheme theme, bool isSmallScreen) {
    // Always return a container with consistent spacing to prevent layout shifts
    return Container(
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        top: isSmallScreen ? 6 : 8,
        bottom: isSmallScreen ? 4 : 6,
      ),
      constraints: BoxConstraints(
        minHeight: isSmallScreen ? 24 : 50, // Minimum height for layout stability
        maxHeight: isSmallScreen ? 32 : 90, // Allow more height to prevent overflow
      ),
      child: isSmallScreen
          ? // Simple hint for small screens - guaranteed to fit
            Center(
              child: Text(
                'Swipe to control • Tap to pause • Collect food to grow',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            )
          : // Optimized instructions for larger screens
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.accentColor.withValues(alpha: 0.08),
                    theme.foodColor.withValues(alpha: 0.05),
                  ],
                ),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.2),
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: theme.accentColor.withValues(alpha: 0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: IntrinsicHeight(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Compact title
                    Text(
                      'COLLECT FOOD',
                      style: TextStyle(
                        color: theme.accentColor.withValues(alpha: 0.8),
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Compact food types row
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildCompactInstruction('🍎', '10', theme),
                          _buildCompactInstruction('✨', '25', theme),
                          _buildCompactInstruction('⭐', '50', theme),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildCompactInstruction(String emoji, String points, GameTheme theme) {
    return Flexible(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji, 
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            points,
            style: TextStyle(
              color: theme.foodColor.withValues(alpha: 0.9),
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStaticGameRow(GameTheme theme, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side - Game hint
          _buildGameHint(theme, isSmallScreen),
          // Right side - Static gesture indicator
          _buildStaticGestureIndicator(theme, isSmallScreen),
        ],
      ),
    );
  }

  Widget _buildGameHint(GameTheme theme, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 8 : 10,
        vertical: isSmallScreen ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.foodColor.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.lightbulb_outline,
            color: theme.foodColor.withValues(alpha: 0.7),
            size: isSmallScreen ? 14 : 16,
          ),
          SizedBox(width: isSmallScreen ? 6 : 8),
          Text(
            'Avoid walls & yourself',
            style: TextStyle(
              color: theme.foodColor.withValues(alpha: 0.8),
              fontSize: isSmallScreen ? 10 : 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticGestureIndicator(GameTheme theme, bool isSmallScreen) {
    return AnimatedBuilder(
      animation: _gestureIndicatorController,
      builder: (context, child) {
        final isActive = _lastSwipeDirection != null &&
            _gestureIndicatorController.isAnimating;
        final activeColor = isActive
            ? _getActiveSwipeColor(_lastSwipeDirection!, theme)
            : theme.accentColor;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: activeColor.withValues(alpha: isActive ? 0.7 : 0.3),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? activeColor.withValues(alpha: 0.25)
                    : Colors.black.withValues(alpha: 0.1),
                blurRadius: isActive ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Direction arrow with rotation
              AnimatedRotation(
                turns: _getDirectionRotation(_lastSwipeDirection),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: AnimatedScale(
                  scale: isActive ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 150),
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: activeColor.withValues(alpha: isActive ? 1.0 : 0.6),
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              // "Swipe" label
              Text(
                'Swipe',
                style: TextStyle(
                  color: activeColor.withValues(alpha: isActive ? 0.9 : 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  double _getDirectionRotation(Direction? direction) {
    if (direction == null) return 0.0;
    switch (direction) {
      case Direction.up:
        return 0.0;
      case Direction.right:
        return 0.25;
      case Direction.down:
        return 0.5;
      case Direction.left:
        return 0.75;
    }
  }

  Color _getActiveSwipeColor(Direction direction, GameTheme theme) {
    switch (direction) {
      case Direction.up:
        return const Color(0xFF00BCD4); // Cyan
      case Direction.down:
        return const Color(0xFF4CAF50); // Green
      case Direction.left:
        return const Color(0xFFFF9800); // Orange
      case Direction.right:
        return const Color(0xFF9C27B0); // Purple
    }
  }

}

// Custom painter for game background pattern - matching home screen
class _GameBackgroundPainter extends CustomPainter {
  final GameTheme theme;

  _GameBackgroundPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = theme.accentColor.withValues(alpha: 0.05);

    // Draw subtle grid pattern
    const gridSize = 30.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw decorative shapes
    final shapePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = theme.foodColor.withValues(alpha: 0.02);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.25),
      50,
      shapePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      70,
      shapePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _GameBackgroundPainter || oldDelegate.theme != theme;
  }
}
