import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/walkthrough_service.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/game_board.dart';
import 'package:snake_classic/widgets/game_hud.dart';
import 'package:snake_classic/widgets/pause_overlay.dart';
import 'package:snake_classic/widgets/swipe_detector.dart';
import 'package:snake_classic/widgets/crash_feedback_overlay.dart';
import 'package:snake_classic/widgets/screen_shake.dart';
import 'package:snake_classic/widgets/dpad_controls.dart';
import 'package:snake_classic/widgets/score_popup.dart';
import 'package:snake_classic/widgets/walkthrough/game_tutorial.dart';
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
  late FocusNode _keyboardFocusNode;
  bool _hasNavigatedToGameOver = false;

  // Score popup system
  final ScorePopupManager _scorePopupManager = ScorePopupManager();
  Size? _boardSize;
  Offset? _boardOffset;

  // Level-up corner popup
  bool _showLevelUpPopup = false;
  int _levelUpPopupLevel = 1;
  late AnimationController _levelUpPopupController;

  // Game tutorial
  bool _tutorialActive = false;
  GameTutorialController? _tutorialController;
  bool _tutorialChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize keyboard focus node
    _keyboardFocusNode = FocusNode();

    // Initialize gesture indicator animation controller
    _gestureIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Initialize level-up corner popup controller
    _levelUpPopupController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _levelUpPopupController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _showLevelUpPopup = false);
        _levelUpPopupController.reset();
      }
    });

    // Initialize game juice controller
    _juiceController = GameJuiceController();

    // Start the game when screen loads (only if not already playing)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameCubit = context.read<GameCubit>();
      debugPrint(
        '[GameScreen] initState callback - cubit status: ${gameCubit.state.status}',
      );
      if (gameCubit.state.status == GamePlayStatus.ready ||
          gameCubit.state.status == GamePlayStatus.initial) {
        debugPrint('[GameScreen] Starting game...');
        gameCubit.startGame();
        debugPrint(
          '[GameScreen] startGame() called, new status: ${gameCubit.state.status}',
        );
      } else {
        debugPrint(
          '[GameScreen] Game already in status: ${gameCubit.state.status}, not starting',
        );
      }
      // Request keyboard focus
      _keyboardFocusNode.requestFocus();

      // Check for game tutorial
      _checkTutorial();
    });
  }

  /// Check if game tutorial should be shown
  Future<void> _checkTutorial() async {
    if (_tutorialChecked) return;
    _tutorialChecked = true;

    final walkthroughService = WalkthroughService();
    await walkthroughService.initialize();

    if (!walkthroughService.isComplete(WalkthroughService.gameTutorialId)) {
      if (mounted) {
        _startTutorial();
      }
    }
  }

  /// Start the game tutorial
  void _startTutorial() {
    final gameCubit = context.read<GameCubit>();
    gameCubit.pauseGame();

    setState(() {
      _tutorialActive = true;
      _tutorialController = GameTutorialController();
      _tutorialController!.onComplete = _onTutorialComplete;
      _tutorialController!.start();
    });
  }

  /// Called when tutorial is complete
  void _onTutorialComplete() async {
    final walkthroughService = WalkthroughService();
    await walkthroughService.markComplete(WalkthroughService.gameTutorialId);

    if (mounted) {
      setState(() {
        _tutorialActive = false;
        _tutorialController?.dispose();
        _tutorialController = null;
      });

      // Resume the game
      context.read<GameCubit>().resumeGame();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _keyboardFocusNode.dispose();
    _gestureIndicatorController.dispose();
    _levelUpPopupController.dispose();
    _juiceController.dispose();
    _tutorialController?.dispose();
    super.dispose();
  }

  // Listener for game state changes - handles navigation and events
  void _onGameStateChanged(GameCubitState state) {
    if (!mounted) return;

    final gameState = state.gameState;
    if (gameState == null) return;

    // Only check for game events when the actual game state object changes
    // (not on animation frame updates which only change moveProgress)
    // This reduces overhead from ~60 calls/sec to ~3-5 calls/sec
    if (!identical(_previousGameState, gameState)) {
      _checkForGameEvents(_previousGameState, gameState);
      _previousGameState = gameState;
    }

    // Handle game over navigation
    if (state.status == GamePlayStatus.gameOver && !_hasNavigatedToGameOver) {
      _hasNavigatedToGameOver = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.pushReplacement(AppRoutes.gameOver);
        }
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final gameCubit = context.read<GameCubit>();

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (gameCubit.state.isPlaying) {
        gameCubit.pauseGame();
      }
    }
  }

  void _handleSwipe(Direction direction) {
    // If tutorial is active, send swipe to tutorial controller
    if (_tutorialActive && _tutorialController != null) {
      _tutorialController!.onSwipeDetected(direction);
      return;
    }

    context.read<GameCubit>().changeDirection(direction);

    // Update last swipe direction and animate indicator
    setState(() {
      _lastSwipeDirection = direction;
    });

    // Animate the gesture indicator
    _gestureIndicatorController.forward().then((_) {
      _gestureIndicatorController.reverse();
    });
  }

  // Convert game speed (ms per tick) to human-readable label
  String _getSpeedLabel(int gameSpeed) {
    if (gameSpeed >= 280) return 'Normal';
    if (gameSpeed >= 230) return 'Fast';
    if (gameSpeed >= 180) return 'Faster';
    if (gameSpeed >= 130) return 'Blazing';
    if (gameSpeed >= 80) return 'Insane';
    return 'MAX';
  }

  // Get icon for current speed level
  IconData _getSpeedIcon(int gameSpeed) {
    if (gameSpeed >= 230) return Icons.speed;
    if (gameSpeed >= 130) return Icons.local_fire_department;
    return Icons.bolt;
  }

  void _showExitConfirmation(BuildContext context) {
    final gameCubit = context.read<GameCubit>();
    final theme = context.read<ThemeCubit>().state.currentTheme;

    // Pause the game if it's playing
    if (gameCubit.state.isPlaying) {
      gameCubit.pauseGame();
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
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
              Navigator.of(dialogContext).pop(); // Close dialog
              if (gameCubit.state.isPaused) {
                gameCubit.resumeGame(); // Resume if was playing
              }
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(); // Close dialog
              gameCubit.resetGame(); // Reset game state before exiting
              context.pop(); // Exit game
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
          context.read<GameCubit>().togglePause();
          break;
      }

      if (direction != null) {
        _handleSwipe(direction);
      }
    }
  }

  void _checkForGameEvents(GameState? previous, GameState current) {
    if (previous == null) return;

    // Food consumption effects with score popup
    if (current.score > previous.score && previous.food != null) {
      final food = previous.food!;
      final pointsEarned = current.score - previous.score;

      // Spawn score popup at food position with combo multiplier
      _spawnScorePopup(
        food,
        pointsEarned,
        current.boardWidth,
        current.boardHeight,
        comboMultiplier: current.comboMultiplier,
      );

      switch (food.type) {
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

    // Level up effects (HUD pulse + corner popup - no pause)
    if (current.level > previous.level) {
      _juiceController.levelUp();
      _showLevelUpCornerPopup(current.level);
      // Note: HUD also shows a pulse animation on the level badge
      // Game continues without interruption
    }

    // Game over effects
    if (current.status == GameStatus.gameOver &&
        previous.status != GameStatus.gameOver) {
      _juiceController.gameOver();
    }
  }

  /// Spawns a score popup at the food position
  void _spawnScorePopup(
    Food food,
    int points,
    int boardWidth,
    int boardHeight, {
    double comboMultiplier = 1.0,
  }) {
    if (_boardSize == null || _boardOffset == null) return;

    // Calculate screen position from grid position
    final cellWidth = _boardSize!.width / boardWidth;
    final cellHeight = _boardSize!.height / boardHeight;

    final screenX = _boardOffset!.dx + (food.position.x + 0.5) * cellWidth;
    final screenY = _boardOffset!.dy + (food.position.y + 0.5) * cellHeight;

    final color = switch (food.type) {
      FoodType.normal => Colors.red,
      FoodType.bonus => Colors.amber,
      FoodType.special => Colors.purple,
    };

    // Show multiplier if combo is active (1.5x or higher)
    final displayMultiplier = comboMultiplier >= 1.5
        ? comboMultiplier.round()
        : 1;

    setState(() {
      _scorePopupManager.addPopup(
        points: points,
        position: Offset(screenX, screenY),
        color: color,
        multiplier: displayMultiplier,
      );
    });
  }

  /// Shows the level-up corner popup
  void _showLevelUpCornerPopup(int newLevel) {
    setState(() {
      _showLevelUpPopup = true;
      _levelUpPopupLevel = newLevel;
    });
    _levelUpPopupController.forward();
  }

  /// Builds the level-up corner popup widget
  Widget _buildLevelUpCornerPopup(GameTheme theme) {
    return AnimatedBuilder(
      animation: _levelUpPopupController,
      builder: (context, child) {
        final progress = _levelUpPopupController.value;

        // Animation phases:
        // 0.0-0.15: Slide in + scale up
        // 0.15-0.85: Hold
        // 0.85-1.0: Fade out + slide up
        double opacity;
        double slideY;
        double scale;

        if (progress < 0.15) {
          // Slide in phase
          final phase = progress / 0.15;
          final curved = Curves.easeOut.transform(phase);
          opacity = curved;
          slideY = 20 * (1 - curved);
          scale = 0.8 + (0.2 * curved);
        } else if (progress < 0.85) {
          // Hold phase
          opacity = 1.0;
          slideY = 0;
          scale = 1.0;
        } else {
          // Fade out phase
          final phase = (progress - 0.85) / 0.15;
          final curved = Curves.easeIn.transform(phase);
          opacity = 1.0 - curved;
          slideY = -15 * curved;
          scale = 1.0 - (0.1 * curved);
        }

        return Positioned(
          top: 120 + slideY,
          right: 16,
          child: Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('⬆️', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'LEVEL UP!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1,
                            shadows: [
                              Shadow(
                                color: Colors.black45,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Level $_levelUpPopupLevel',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            shadows: const [
                              Shadow(
                                color: Colors.black38,
                                offset: Offset(1, 1),
                                blurRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    const Text('⬆️', style: TextStyle(fontSize: 18)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Builds the D-Pad control bar with stats on either side
  /// Layout: [Length] [D-Pad] [Speed]
  Widget _buildDPadControlBar(
    GameState gameState,
    DPadPosition position,
    GameTheme theme,
    bool isSmallScreen,
  ) {
    final dpadSize = isSmallScreen ? 115.0 : 135.0;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isSmallScreen ? 8 : 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left stat: Length
          Expanded(
            child: _buildControlBarStat(
              'Length',
              '${gameState.snake.length}',
              Icons.straighten,
              theme,
              isSmallScreen,
              alignment: Alignment.centerLeft,
            ),
          ),

          // Center: D-Pad
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: DPadControls(
              onDirection: _handleSwipe,
              theme: theme,
              opacity: 0.8,
              size: dpadSize,
            ),
          ),

          // Right stat: Speed
          Expanded(
            child: _buildControlBarStat(
              'Speed',
              _getSpeedLabel(gameState.gameSpeed),
              _getSpeedIcon(gameState.gameSpeed),
              theme,
              isSmallScreen,
              alignment: Alignment.centerRight,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds a stat display for the control bar
  Widget _buildControlBarStat(
    String label,
    String value,
    IconData icon,
    GameTheme theme,
    bool isSmallScreen, {
    required Alignment alignment,
  }) {
    return Align(
      alignment: alignment,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 10 : 14,
          vertical: isSmallScreen ? 8 : 10,
        ),
        decoration: BoxDecoration(
          color: theme.backgroundColor.withValues(alpha: 0.6),
          border: Border.all(color: theme.accentColor.withValues(alpha: 0.25)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: theme.accentColor.withValues(alpha: 0.7),
              size: isSmallScreen ? 16 : 20,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 14 : 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.5),
                fontSize: isSmallScreen ? 9 : 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GameCubit, GameCubitState>(
      listener: (context, state) {
        _onGameStateChanged(state);
      },
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          final theme = themeState.currentTheme;

          return BlocBuilder<GameCubit, GameCubitState>(
            builder: (context, gameCubitState) {
              final gameState = gameCubitState.gameState;
              final settingsState = context.watch<GameSettingsCubit>().state;

              // Sync shake enabled state with controller to prevent background animation loops
              _juiceController.shakeEnabled = settingsState.screenShakeEnabled;

              // Handle null gameState gracefully
              if (gameState == null) {
                return Scaffold(
                  backgroundColor: theme.backgroundColor,
                  body: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.accentColor,
                      ),
                    ),
                  ),
                );
              }

              return PopScope(
                canPop: false,
                onPopInvokedWithResult: (didPop, result) {
                  if (!didPop) {
                    _showExitConfirmation(context);
                  }
                },
                child: KeyboardListener(
                  focusNode: _keyboardFocusNode,
                  onKeyEvent: _handleKeyPress,
                  child: GameJuiceWidget(
                    controller: _juiceController,
                    applyShake: settingsState.screenShakeEnabled,
                    applyScale: false, // Don't apply scale to the entire screen
                    child: Scaffold(
                      backgroundColor: theme.backgroundColor,
                      body: SafeArea(
                        child: Stack(
                          children: [
                            // SwipeDetector only wraps the game content, not overlays
                            SwipeDetector(
                              onSwipe: _handleSwipe,
                              onTap: () {
                                // Only toggle pause when playing (not when crashed or game over)
                                if (gameState.status == GameStatus.playing ||
                                    gameState.status == GameStatus.paused) {
                                  context.read<GameCubit>().togglePause();
                                }
                              },
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
                                          theme.accentColor.withValues(
                                            alpha: 0.15,
                                          ),
                                          theme.backgroundColor,
                                          theme.backgroundColor.withValues(
                                            alpha: 0.9,
                                          ),
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
                                      final screenHeight =
                                          constraints.maxHeight;
                                      final isSmallScreen = screenHeight < 700;

                                      return Column(
                                        children: [
                                          // HUD
                                          GameHUD(
                                            gameState: gameState,
                                            theme: theme,
                                            onPause: () => context
                                                .read<GameCubit>()
                                                .togglePause(),
                                            onHome: () =>
                                                _showExitConfirmation(context),
                                            isSmallScreen: isSmallScreen,
                                            tournamentId:
                                                gameCubitState.tournamentId,
                                            tournamentMode:
                                                gameCubitState.tournamentMode,
                                          ),

                                          // Note: Instructions moved to pause menu for cleaner gameplay view

                                          // Static row above game board - Game Hint and Gesture Indicator
                                          _buildStaticGameRow(
                                            theme,
                                            isSmallScreen,
                                          ),

                                          // Game Board - always clean, no overlays
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                horizontal: 12,
                                                vertical: isSmallScreen ? 4 : 8,
                                              ),
                                              child: LayoutBuilder(
                                                builder: (context, boardConstraints) {
                                                  // Calculate optimal board size
                                                  final availableSize = math.min(
                                                    boardConstraints.maxWidth,
                                                    boardConstraints.maxHeight,
                                                  );

                                                  // Track board size for score popups
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback((_) {
                                                    if (mounted) {
                                                      _boardSize = Size(
                                                        availableSize,
                                                        availableSize,
                                                      );
                                                    }
                                                  });

                                                  return Center(
                                                    child: Builder(
                                                      builder: (boardContext) {
                                                        WidgetsBinding.instance
                                                            .addPostFrameCallback((_) {
                                                          if (mounted) {
                                                            final box = boardContext
                                                                    .findRenderObject()
                                                                as RenderBox?;
                                                            if (box != null) {
                                                              _boardOffset =
                                                                  box.localToGlobal(
                                                                Offset.zero,
                                                              );
                                                            }
                                                          }
                                                        });

                                                        return SizedBox(
                                                          width: availableSize,
                                                          height: availableSize,
                                                          child: GameBoard(
                                                            gameState: gameState,
                                                            isTournamentMode:
                                                                gameCubitState
                                                                    .isTournamentMode,
                                                          ),
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),

                                          // Control bar: D-Pad with stats on sides (when D-Pad enabled)
                                          // OR: Compact stats footer (when D-Pad disabled)
                                          if (settingsState.dPadEnabled &&
                                              gameState.status == GameStatus.playing)
                                            _buildDPadControlBar(
                                              gameState,
                                              settingsState.dPadPosition,
                                              theme,
                                              isSmallScreen,
                                            )
                                          else
                                            _buildCompactGameInfo(
                                              gameState,
                                              theme,
                                              isSmallScreen,
                                            ),
                                        ],
                                      );
                                    },
                                  ),

                                  // Pause Overlay (don't show during tutorial)
                                  if (gameState.status == GameStatus.paused && !_tutorialActive)
                                    PauseOverlay(
                                      theme: theme,
                                      onResume: () => context
                                          .read<GameCubit>()
                                          .resumeGame(),
                                      onRestart: () {
                                        context.read<GameCubit>().startGame();
                                      },
                                      onHome: () =>
                                          _showExitConfirmation(context),
                                    ),

                                  // Score Popups Layer
                                  ..._scorePopupManager.activePopups.map((
                                    popupData,
                                  ) {
                                    return ScorePopup(
                                      key: ValueKey(popupData.id),
                                      points: popupData.points,
                                      multiplier: popupData.multiplier,
                                      position: popupData.position,
                                      color: popupData.color,
                                      onComplete: () {
                                        setState(() {
                                          _scorePopupManager.removePopup(
                                            popupData.id,
                                          );
                                        });
                                      },
                                    );
                                  }),

                                  // Level-Up Corner Popup
                                  if (_showLevelUpPopup)
                                    _buildLevelUpCornerPopup(theme),
                                ],
                              ),
                            ),

                            // Crash Feedback Overlay - OUTSIDE SwipeDetector so taps work
                            if (gameState.status == GameStatus.crashed &&
                                gameState.crashReason != null &&
                                gameState.showCrashModal)
                              CrashFeedbackOverlay(
                                crashReason: gameState.crashReason!,
                                theme: theme,
                                onSkip: () => context
                                    .read<GameCubit>()
                                    .skipCrashFeedback(),
                                duration: settingsState.crashFeedbackDuration,
                              ),

                            // Game Tutorial Overlay
                            if (_tutorialActive && _tutorialController != null)
                              GameTutorialOverlay(
                                controller: _tutorialController!,
                                theme: theme,
                                onSkip: _onTutorialComplete,
                              ),
                          ],
                        ),
                      ),
                    ), // Close Scaffold
                  ), // Close GameJuiceWidget
                ), // Close KeyboardListener
              ); // Close PopScope
            },
          );
        },
      ),
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
            _getSpeedLabel(gameState.gameSpeed),
            _getSpeedIcon(gameState.gameSpeed),
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

  // NOTE: Instructions moved to pause_overlay.dart - _buildGameGuideSection()

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
        final isActive =
            _lastSwipeDirection != null &&
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
