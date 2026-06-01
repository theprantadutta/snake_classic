import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/config/feature_flags.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';
import 'package:snake_classic/widgets/revive_overlay.dart';
import 'package:snake_classic/widgets/time_bonus_overlay.dart';
import 'package:snake_classic/services/walkthrough_service.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/flame_game_board.dart';
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
  // Per-swipe direction + animation controller driving the centered
  // gesture-indicator chip above the board. Rotates an arrow to match
  // the most recent accepted direction and glows for ~800ms after each
  // input, so the player sees confirmation in dedicated chrome (the
  // edge-bloom on the board itself handles in-arena feedback).
  Direction? _lastSwipeDirection;
  late AnimationController _gestureIndicatorController;
  late GameJuiceController _juiceController;
  GameState? _previousGameState;
  late FocusNode _keyboardFocusNode;
  bool _hasNavigatedToGameOver = false;
  // Prevents the exit-confirmation dialog from stacking when a rapid tap on
  // the exit button fires _showExitConfirmation twice before the first dialog
  // is on screen. Cleared in the dialog's then() so both Cancel and Exit
  // reset it.
  bool _exitDialogOpen = false;


  // Score popup system - extracted into separate widget to avoid full screen rebuilds
  final GlobalKey<_ScorePopupLayerState> _scorePopupLayerKey = GlobalKey<_ScorePopupLayerState>();

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

    // Note: the status bar is hidden app-wide via WindowInsetsController in
    // MainActivity.kt — no per-screen SystemUiMode tweak needed here. The
    // navigation bar stays visible during gameplay so the back gesture
    // remains accessible (matches the original SystemUiMode.manual +
    // [SystemUiOverlay.bottom] behavior the app shipped with).

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
      _keyboardFocusNode.requestFocus();
      // Drives the full pre-game sequence: control-choice (if first time)
      // → startGame → tutorial (if first time). Sequenced so the game
      // never starts behind a blocking modal.
      _bootstrapGame();
    });
  }

  /// Pre-game onboarding + start. Runs once per GameScreen mount.
  ///   1. If the player has never picked a control scheme, show the
  ///      d-pad / swipe modal FIRST and wait for their answer.
  ///   2. Then call `startGame()` so the snake doesn't start moving
  ///      behind a blocking dialog.
  ///   3. After the game is running, kick off the gameplay tutorial if
  ///      they haven't seen it (the tutorial itself handles pausing).
  Future<void> _bootstrapGame() async {
    if (_tutorialChecked) return;
    _tutorialChecked = true;

    final walkthroughService = WalkthroughService();
    await walkthroughService.initialize();

    if (!mounted) return;

    if (!walkthroughService.isComplete(WalkthroughService.controlChoiceId)) {
      await _showControlChoiceDialog();
      if (!mounted) return;
      await walkthroughService.markComplete(WalkthroughService.controlChoiceId);
      if (!mounted) return;
    }

    final gameCubit = context.read<GameCubit>();
    debugPrint(
      '[GameScreen] bootstrap - cubit status: ${gameCubit.state.status}',
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

    if (!walkthroughService.isComplete(WalkthroughService.gameTutorialId)) {
      _startTutorial();
    }
  }

  /// First-launch modal asking the player to pick gestures or the D-Pad.
  /// Now called before [GameCubit.startGame], so the snake isn't already
  /// moving behind the dialog — no pause/resume dance needed. Whatever
  /// they choose is persisted via [GameSettingsCubit.updateDPadEnabled]
  /// and surfaced with a "change this anytime in Settings → Controls"
  /// footer.
  Future<void> _showControlChoiceDialog() async {
    final settingsCubit = context.read<GameSettingsCubit>();
    final theme = context.read<ThemeCubit>().state.currentTheme;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          backgroundColor: theme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
            side: BorderSide(
              color: theme.accentColor.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'How do you want to play?',
                style: TextStyle(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Pick one — you can change it anytime in Settings → Controls.',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlChoiceCard(
                dialogContext: dialogContext,
                theme: theme,
                icon: Icons.swipe_rounded,
                title: 'Swipe Gestures',
                subtitle: 'Swipe anywhere on the board to turn.',
                onTap: () async {
                  await settingsCubit.updateDPadEnabled(false);
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
              ),
              const SizedBox(height: 12),
              _buildControlChoiceCard(
                dialogContext: dialogContext,
                theme: theme,
                icon: Icons.gamepad_rounded,
                title: 'D-Pad Controls',
                subtitle: 'On-screen directional buttons.',
                onTap: () async {
                  await settingsCubit.updateDPadEnabled(true);
                  if (dialogContext.mounted) Navigator.of(dialogContext).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlChoiceCard({
    required BuildContext dialogContext,
    required GameTheme theme,
    required IconData icon,
    required String title,
    required String subtitle,
    required Future<void> Function() onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: theme.accentColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: theme.accentColor.withValues(alpha: 0.6),
            ),
          ],
        ),
      ),
    );
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

    // Drive the centered gesture-indicator chip above the board: rotates
    // its arrow to match the swipe direction and glows for ~800ms. The
    // board's edge-bloom (accepted) and centered red ring (rejected)
    // still handle in-arena feedback — this chip is the chrome-side cue.
    _lastSwipeDirection = direction;
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
    if (_exitDialogOpen) return;
    final gameCubit = context.read<GameCubit>();
    final theme = context.read<ThemeCubit>().state.currentTheme;

    // Remember whether we paused on entry so Cancel only resumes a game we
    // actually paused. If the user crashed between tap and dialog or it was
    // already paused, Cancel must not flip the state.
    final didPauseHere = gameCubit.state.isPlaying;
    if (didPauseHere) {
      gameCubit.pauseGame();
    }

    _exitDialogOpen = true;
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
              Navigator.of(dialogContext).pop();
              if (didPauseHere && gameCubit.state.isPaused) {
                gameCubit.resumeGame();
              }
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              gameCubit.resetGame();
              context.pop();
            },
            child: Text('Exit', style: TextStyle(color: theme.foodColor)),
          ),
        ],
      ),
    ).whenComplete(() => _exitDialogOpen = false);
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
  /// Delegates to the _ScorePopupLayer widget to avoid full game screen rebuilds
  void _spawnScorePopup(
    Food food,
    int points,
    int boardWidth,
    int boardHeight, {
    double comboMultiplier = 1.0,
  }) {
    _scorePopupLayerKey.currentState?.addPopup(
      food: food,
      points: points,
      boardWidth: boardWidth,
      boardHeight: boardHeight,
      comboMultiplier: comboMultiplier,
    );
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
  /// The bottom bar reserves a fixed footprint regardless of whether the
  /// D-Pad is enabled or the current game status. Previous build had two
  /// completely separate widgets here (a tall D-Pad bar vs a short compact-
  /// stats footer) and switched between them based on
  /// `dPadEnabled && status == playing`, which caused:
  ///   - The board to shift up/down whenever the D-Pad setting toggled.
  ///   - The D-Pad to vanish entirely the moment the snake crashed,
  ///     because status went from playing → crashed.
  ///
  /// Now we always render the same Row skeleton (left stat / center / right
  /// stat) at a fixed height. The center swaps:
  ///   - dPadEnabled = true  → DPadControls, interactive while playing,
  ///     dimmed + non-interactive otherwise.
  ///   - dPadEnabled = false → a single Level stat card centered in the
  ///     same footprint.
  Widget _buildBottomBar(
    GameState gameState,
    GameTheme theme,
    bool isSmallScreen, {
    required bool dPadEnabled,
  }) {
    final dpadSize = isSmallScreen ? 115.0 : 135.0;
    final verticalPadding = isSmallScreen ? 8.0 : 12.0;
    // Total reserved height = dpad footprint + the row's own padding so the
    // box is the SAME pixel height in every branch and every status.
    final barHeight = dpadSize + verticalPadding * 2;
    final isInteractive = gameState.status == GameStatus.playing;

    return SizedBox(
      height: barHeight,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: verticalPadding,
        ),
        child: dPadEnabled
            // D-Pad on: center reserves the dpadSize square, side stats
            // shrink to fit the remaining columns. Compact cards aligned
            // to the outer edges so the d-pad has breathing room.
            ? Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(
                      width: dpadSize,
                      height: dpadSize,
                      child: Opacity(
                        opacity: isInteractive ? 1.0 : 0.45,
                        child: IgnorePointer(
                          ignoring: !isInteractive,
                          child: DPadControls(
                            onDirection: _handleSwipe,
                            theme: theme,
                            opacity: 0.8,
                            size: dpadSize,
                          ),
                        ),
                      ),
                    ),
                  ),
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
              )
            // D-Pad off: no center widget eats the middle, so the three
            // stats spread across the full row in even thirds. Each card
            // is normal-size — wider, not taller — and vertically
            // centered in the same-height bar.
            : Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildWideStat(
                      'Length',
                      '${gameState.snake.length}',
                      Icons.straighten,
                      theme,
                      isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildWideStat(
                      'Level',
                      '${gameState.level}',
                      Icons.trending_up,
                      theme,
                      isSmallScreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildWideStat(
                      'Speed',
                      _getSpeedLabel(gameState.gameSpeed),
                      _getSpeedIcon(gameState.gameSpeed),
                      theme,
                      isSmallScreen,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Stat card used when the D-Pad is disabled — fills its 1/3 of the
  /// bottom bar's width but only takes the height it needs. Normal text
  /// sizes; the extra space we won is horizontal, not vertical.
  Widget _buildWideStat(
    String label,
    String value,
    IconData icon,
    GameTheme theme,
    bool isSmallScreen,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 10 : 12,
        vertical: isSmallScreen ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.6),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.25),
        ),
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
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
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
            // Performance: Only rebuild when UI-visible state changes,
            // NOT on every snake move tick. The GameBoard handles its own
            // snake rendering via its internal BlocBuilder + AnimatedBuilder.
            buildWhen: (previous, current) {
              if (previous.status != current.status) return true;
              if (previous.gameState == null || current.gameState == null) {
                return true;
              }
              final prev = previous.gameState!;
              final curr = current.gameState!;
              return prev.score != curr.score ||
                  prev.level != curr.level ||
                  prev.status != curr.status ||
                  prev.showCrashModal != curr.showCrashModal ||
                  prev.currentCombo != curr.currentCombo ||
                  prev.activePowerUps.length != curr.activePowerUps.length ||
                  previous.tournamentId != current.tournamentId;
            },
            builder: (context, gameCubitState) {
              final gameState = gameCubitState.gameState;
              // Performance: Use read instead of watch. Settings don't change
              // during gameplay, so we don't need to subscribe to changes here.
              final settingsState = context.read<GameSettingsCubit>().state;

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
                        child: Column(
                          children: [
                            // Aggressive monetization: a banner anchored at the
                            // very top — above the HUD and OUTSIDE the
                            // SwipeDetector — so it's far from the board/d-pad
                            // (no accidental clicks) and never intercepts a
                            // swipe. Pro users get a zero-height widget, so the
                            // board stays full size for them.
                            const SnakeBannerAd(),
                            Expanded(
                              child: Stack(
                          children: [
                            // SwipeDetector only wraps the game content, not overlays.
                            // No onTap handler — pause is reserved for the HUD's
                            // pause button (and spacebar on keyboard). Previously
                            // this called togglePause() on any tap, which made
                            // accidental finger-rests near the d-pad or HUD edges
                            // pause the game with no obvious cause.
                            SwipeDetector(
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
                                            pauseButtonKey: GameTutorialKeys
                                                .pauseButtonKey,
                                          ),

                                          // Note: Instructions moved to pause menu for cleaner gameplay view.
                                          // The "Avoid walls" hint that used to share this strip
                                          // with the gesture indicator was removed (tutorial-only
                                          // noise after game 2). The gesture indicator stays —
                                          // centered now that it's alone — because it's the
                                          // chrome-side per-swipe confirmation that pairs with
                                          // the board's edge-bloom.
                                          _buildGestureIndicatorRow(
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

                                                  return Center(
                                                    child: SizedBox(
                                                      width: availableSize,
                                                      height: availableSize,
                                                      child: FeatureFlags
                                                              .useFlameBoard
                                                          ? FlameGameBoard(
                                                              gameState:
                                                                  gameState,
                                                              isTournamentMode:
                                                                  gameCubitState
                                                                      .isTournamentMode,
                                                            )
                                                          : GameBoard(
                                                              gameState:
                                                                  gameState,
                                                              isTournamentMode:
                                                                  gameCubitState
                                                                      .isTournamentMode,
                                                            ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),

                                          // Unified bottom bar — same fixed
                                          // height in every state (d-pad on,
                                          // d-pad off, paused, crashed,
                                          // game over) so the board never
                                          // shifts. Center swaps between
                                          // DPadControls and a Level card.
                                          _buildBottomBar(
                                            gameState,
                                            theme,
                                            isSmallScreen,
                                            dPadEnabled:
                                                settingsState.dPadEnabled,
                                          ),
                                        ],
                                      );
                                    },
                                  ),

                                  // Pause Overlay (don't show during tutorial,
                                  // or while the Time-Attack bonus offer — which
                                  // freezes the run via the same paused status —
                                  // is on screen).
                                  if (gameState.status == GameStatus.paused &&
                                      !_tutorialActive &&
                                      !gameCubitState.offeringTimeBonus)
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
                                      onShowTutorial: _startTutorial,
                                    ),

                                   // Score Popups Layer - isolated StatefulWidget
                                  // to avoid full game screen rebuilds on popup add/remove
                                  _ScorePopupLayer(key: _scorePopupLayerKey),

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

                            // Revive offer — shown instead of the crash modal
                            // while the cubit is awaiting a revive decision.
                            // Outside SwipeDetector so the buttons receive taps.
                            if (gameCubitState.offeringRevive)
                              ReviveOverlay(
                                theme: theme,
                                seconds: 10,
                                coinCost: GameCubit.reviveCoinCost,
                                isAdReady: () =>
                                    getIt<AdService>().isRewardedReady,
                                canAffordCoins: context
                                        .read<CoinsCubit>()
                                        .state
                                        .balance
                                        .total >=
                                    GameCubit.reviveCoinCost,
                                onWatchAd: () {
                                  final gc = context.read<GameCubit>();
                                  getIt<AdService>()
                                      .showRewarded(onReward: gc.revive);
                                },
                                onUseCoins: () async {
                                  final gc = context.read<GameCubit>();
                                  final ok = await context
                                      .read<CoinsCubit>()
                                      .spendCoins(
                                        GameCubit.reviveCoinCost,
                                        CoinSpendingCategory.extraLives,
                                        itemName: 'Revive',
                                      );
                                  if (ok) gc.revive();
                                },
                                onDecline: () =>
                                    context.read<GameCubit>().declineRevive(),
                              ),

                            // Time-Attack "+30s" offer — shown when the clock
                            // hits zero with an extension still available.
                            // Outside SwipeDetector so the buttons receive taps.
                            if (gameCubitState.offeringTimeBonus)
                              TimeBonusOverlay(
                                theme: theme,
                                bonusSeconds: GameCubit.timeBonusSeconds,
                                isAdReady: () =>
                                    getIt<AdService>().isRewardedReady,
                                onWatchAd: () {
                                  final gc = context.read<GameCubit>();
                                  getIt<AdService>().showRewarded(
                                    onReward: gc.grantTimeBonus,
                                  );
                                },
                                onDecline: () => context
                                    .read<GameCubit>()
                                    .declineTimeBonus(),
                              ),

                            // Game Tutorial Overlay
                            if (_tutorialActive && _tutorialController != null)
                              GameTutorialOverlay(
                                controller: _tutorialController!,
                                theme: theme,
                                onSkip: _onTutorialComplete,
                              ),
                            // Rejected-input flash. Paints a brief centered
                            // red ring whenever the cubit denies a direction
                            // change (reverse-into-self or already-queued).
                            // Independent BlocSelector keeps it isolated from
                            // the main rebuild path.
                            //
                            // Accepted-input edge bloom lives INSIDE the
                            // board painter (game_board.dart) so it scopes
                            // to the play area and rides the existing 60fps
                            // repaint cycle — no extra full-screen paints.
                            const _RejectedInputFlash(),
                          ],
                              ),
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

  // NOTE: Instructions moved to pause_overlay.dart - _buildGameGuideSection()

  /// Thin strip between HUD and board holding the centered gesture
  /// indicator chip. Mirrors the original static-row vertical margin so
  /// the board sits at the same Y position it did before — no shift on
  /// hot-reload from earlier builds.
  Widget _buildGestureIndicatorRow(GameTheme theme, bool isSmallScreen) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: isSmallScreen ? 6 : 8,
      ),
      alignment: Alignment.center,
      child: _buildStaticGestureIndicator(theme, isSmallScreen),
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
                    size: isSmallScreen ? 16 : 18,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Swipe',
                style: TextStyle(
                  color: activeColor.withValues(alpha: isActive ? 0.9 : 0.6),
                  fontSize: isSmallScreen ? 11 : 12,
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

/// Brief red ring flashed at screen center when the cubit denies a direction
/// change. Subscribes only to `lastRejectedInputAt` so it doesn't drag the
/// game screen into per-tick rebuilds.
class _RejectedInputFlash extends StatelessWidget {
  const _RejectedInputFlash();

  @override
  Widget build(BuildContext context) {
    return BlocSelector<GameCubit, GameCubitState, DateTime?>(
      selector: (state) => state.lastRejectedInputAt,
      builder: (context, stamp) {
        if (stamp == null) return const SizedBox.shrink();
        final age = DateTime.now().difference(stamp).inMilliseconds;
        if (age > 250) return const SizedBox.shrink();
        // Fade out over the 250ms window. The starting opacity is high so
        // the flash registers even on a fast glance.
        final t = (age.clamp(0, 250)) / 250.0;
        final opacity = (1.0 - t).clamp(0.0, 1.0);
        return IgnorePointer(
          child: Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: opacity * 0.25),
                border: Border.all(
                  color: Colors.red.withValues(alpha: opacity * 0.85),
                  width: 3,
                ),
              ),
              child: Icon(
                Icons.do_disturb_alt_rounded,
                color: Colors.white.withValues(alpha: opacity * 0.85),
                size: 36,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Isolated widget for score popups - its own setState only rebuilds
/// the popup layer, not the entire game screen.
class _ScorePopupLayer extends StatefulWidget {
  const _ScorePopupLayer({super.key});

  @override
  State<_ScorePopupLayer> createState() => _ScorePopupLayerState();
}

class _ScorePopupLayerState extends State<_ScorePopupLayer> {
  final ScorePopupManager _scorePopupManager = ScorePopupManager();
  Size? _boardSize;
  Offset? _boardOffset;

  @override
  void initState() {
    super.initState();
    // Pre-resolve board metrics after the first frame renders, so the
    // expensive element tree walk happens before any food is eaten.
    // Previously this was lazy (on first food), causing a visible pause.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveBoardMetrics();
    });
  }

  void addPopup({
    required Food food,
    required int points,
    required int boardWidth,
    required int boardHeight,
    double comboMultiplier = 1.0,
  }) {
    // Ensure metrics are resolved (fast no-op if already cached)
    if (_boardSize == null || _boardOffset == null) {
      _resolveBoardMetrics();
    }
    if (_boardSize == null || _boardOffset == null) return;

    final cellWidth = _boardSize!.width / boardWidth;
    final cellHeight = _boardSize!.height / boardHeight;

    final screenX = _boardOffset!.dx + (food.position.x + 0.5) * cellWidth;
    final screenY = _boardOffset!.dy + (food.position.y + 0.5) * cellHeight;

    final color = switch (food.type) {
      FoodType.normal => Colors.red,
      FoodType.bonus => Colors.amber,
      FoodType.special => Colors.purple,
    };

    final displayMultiplier =
        comboMultiplier >= 1.5 ? comboMultiplier.round() : 1;

    setState(() {
      _scorePopupManager.addPopup(
        points: points,
        position: Offset(screenX, screenY),
        color: color,
        multiplier: displayMultiplier,
      );
    });
  }

  void _resolveBoardMetrics() {
    if (_boardSize != null && _boardOffset != null) return;

    // Find the GameBoard render object via the element tree.
    void visitor(Element element) {
      if (_boardSize != null && _boardOffset != null) return;
      if (element.widget is GameBoard) {
        final box = element.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          _boardSize = box.size;
          _boardOffset = box.localToGlobal(Offset.zero);
        }
        return;
      }
      element.visitChildren(visitor);
    }

    context.visitAncestorElements((element) {
      if (element.widget is Stack) {
        element.visitChildren(visitor);
        return _boardSize == null;
      }
      return true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: _scorePopupManager.activePopups.map((popupData) {
        return ScorePopup(
          key: ValueKey(popupData.id),
          points: popupData.points,
          multiplier: popupData.multiplier,
          position: popupData.position,
          color: popupData.color,
          onComplete: () {
            setState(() {
              _scorePopupManager.removePopup(popupData.id);
            });
          },
        );
      }).toList(),
    );
  }
}
