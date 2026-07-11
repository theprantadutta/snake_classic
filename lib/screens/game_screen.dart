import 'dart:math' as math;
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/game/engine/tick_result.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';
import 'package:snake_classic/widgets/revive_overlay.dart';
import 'package:snake_classic/widgets/time_bonus_overlay.dart';
import 'package:snake_classic/services/walkthrough_service.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/flame_game_board.dart';
import 'package:snake_classic/widgets/game_hud.dart';
import 'package:snake_classic/widgets/pause_overlay.dart';
import 'package:snake_classic/widgets/swipe_detector.dart';
import 'package:snake_classic/widgets/crash_feedback_overlay.dart';
import 'package:snake_classic/widgets/screen_shake.dart';
import 'package:snake_classic/widgets/debug_perf_overlay.dart';
import 'package:snake_classic/widgets/dialogs/control_choice_dialog.dart';
import 'package:snake_classic/widgets/dialogs/exit_game_dialog.dart';
import 'package:snake_classic/widgets/game_background_painter.dart';
import 'package:snake_classic/widgets/game_bottom_bar.dart';
import 'package:snake_classic/widgets/rejected_input_flash.dart';
import 'package:snake_classic/widgets/score_popup_layer.dart';
import 'package:snake_classic/widgets/snake_compass_indicator.dart';
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
  final GlobalKey<ScorePopupLayerState> _scorePopupLayerKey = GlobalKey<ScorePopupLayerState>();

  // Game tutorial
  bool _tutorialActive = false;
  GameTutorialController? _tutorialController;
  bool _tutorialChecked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // While the game screen is mounted, suppress App Open ads so backgrounding
    // and returning mid-run never drops a full-screen ad over live/paused play.
    getIt<AdService>().setGameActive(true);

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
      await showControlChoiceDialog(context);
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
    getIt<AdService>().setGameActive(false);
    _keyboardFocusNode.dispose();
    _gestureIndicatorController.dispose();
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
      _checkForGameEvents(_previousGameState, gameState, state.tickEvents);
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
        gameCubit.pauseGame(); // also pauses gameplay music
      } else {
        // Already paused (overlay up) — music can still be audible if the
        // user enabled it from the pause menu; silence it with the app.
        // It comes back through resumeGame's resumeGameplayMusic.
        AudioService().pauseGameplayMusic();
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
    showExitGameDialog(context, theme).then((confirmedExit) {
      if (confirmedExit == true) {
        gameCubit.resetGame();
        // The dialog resolves across an async gap; the screen is always
        // still mounted here in practice (it sits beneath the dialog
        // route), so this guard only satisfies the lint without changing
        // behavior.
        if (!context.mounted) return;
        // The game screen can be reached either by pushing onto Home
        // (canPop == true) or via context.go() from game-over "Play
        // Again" / settings, which makes Game the root of the stack
        // (canPop == false). Popping the latter throws GoError "There is
        // nothing to pop", so fall back to navigating Home.
        if (context.canPop()) {
          context.pop();
        } else {
          context.go(AppRoutes.home);
        }
      } else if (confirmedExit == false) {
        // Cancel only resumes a game we actually paused on entry.
        if (didPauseHere && gameCubit.state.isPaused) {
          gameCubit.resumeGame();
        }
      }
    }).whenComplete(() => _exitDialogOpen = false);
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

  /// Screen juice for one state change. Tick-borne effects (eat, power-up,
  /// level) come from the simulation's [TickEvent]s carried on the cubit
  /// state — the same single source Flame's particles use, so this method no
  /// longer re-derives events by diffing states. Crash / game-over remain
  /// status transitions (they arrive on non-tick emits with no events).
  void _checkForGameEvents(
    GameState? previous,
    GameState current,
    List<TickEvent> events,
  ) {
    for (final event in events) {
      switch (event) {
        case FoodEatenEvent():
          // Popup at the exact eaten cell — event-carried, so it lands
          // correctly even in MultiFood mode when an "extra" food was
          // eaten (the old score-diff derivation always used the primary
          // food's position).
          _spawnScorePopup(
            event.food,
            event.awardedPoints,
            current.boardWidth,
            current.boardHeight,
            comboMultiplier: event.newMultiplier,
          );
          switch (event.food.type) {
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
        case PowerUpCollectedEvent():
          _juiceController.powerUpCollected();
        case LeveledUpEvent():
          // ONE consolidated cue: the HUD level badge burst/scale (see
          // GameHUD._triggerLevelUpEffect) plus a light shake.
          _juiceController.levelUp();
        default:
          break;
      }
    }

    if (previous == null) return;

    // Crash effects
    if (current.status == GameStatus.crashed &&
        previous.status != GameStatus.crashed) {
      if (current.crashReason == CrashReason.wallCollision) {
        _juiceController.wallHit();
      } else if (current.crashReason == CrashReason.selfCollision) {
        _juiceController.selfCollision();
      }
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
              // Structural chrome only. Score / level / combo / power-up
              // changes are scoped to the HUD and bottom-bar BlocBuilders
              // below — rebuilding this whole gameplay tree (HUD + gesture
              // row + board layout + overlays) on every bite was a per-eat
              // jank spike that normal ticks never paid.
              if (previous.status != current.status) return true;
              if ((previous.gameState == null) !=
                  (current.gameState == null)) {
                return true;
              }
              if (previous.gameState == null || current.gameState == null) {
                return false;
              }
              final prev = previous.gameState!;
              final curr = current.gameState!;
              return prev.status != curr.status ||
                  prev.showCrashModal != curr.showCrashModal ||
                  previous.tournamentId != current.tournamentId ||
                  previous.offeringRevive != current.offeringRevive ||
                  previous.offeringTimeBonus != current.offeringTimeBonus;
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
                              // Shake scoped to the play area (HUD + board +
                              // controls) — wrapping the whole Scaffold
                              // dragged the banner ad along with the shake.
                              child: GameJuiceWidget(
                                controller: _juiceController,
                                applyShake: settingsState.screenShakeEnabled,
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
                                      painter: GameBackgroundPainter(theme),
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
                                          // HUD — its own scoped rebuild on
                                          // score/level/combo/power-up changes
                                          // so a bite repaints just this strip,
                                          // not the whole gameplay tree.
                                          BlocBuilder<GameCubit,
                                              GameCubitState>(
                                            buildWhen: (previous, current) {
                                              final prev = previous.gameState;
                                              final curr = current.gameState;
                                              if (prev == null ||
                                                  curr == null) {
                                                return true;
                                              }
                                              return prev.score !=
                                                      curr.score ||
                                                  prev.level != curr.level ||
                                                  prev.currentCombo !=
                                                      curr.currentCombo ||
                                                  prev.activePowerUps
                                                          .length !=
                                                      curr.activePowerUps
                                                          .length ||
                                                  prev.status !=
                                                      curr.status ||
                                                  previous.tournamentId !=
                                                      current.tournamentId;
                                            },
                                            builder: (context, hudState) {
                                              return GameHUD(
                                                gameState:
                                                    hudState.gameState ??
                                                        gameState,
                                                theme: theme,
                                                onPause: () => context
                                                    .read<GameCubit>()
                                                    .togglePause(),
                                                onHome: () =>
                                                    _showExitConfirmation(
                                                        context),
                                                isSmallScreen: isSmallScreen,
                                                uiScale: context.uiScale,
                                                tournamentId:
                                                    hudState.tournamentId,
                                                tournamentMode:
                                                    hudState.tournamentMode,
                                                pauseButtonKey:
                                                    GameTutorialKeys
                                                        .pauseButtonKey,
                                              );
                                            },
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
                                                horizontal:
                                                    context.scaled(12),
                                                vertical: context.scaled(
                                                    isSmallScreen ? 4 : 8),
                                              ),
                                              child: LayoutBuilder(
                                                builder: (context, boardConstraints) {
                                                  // Calculate optimal board size.
                                                  // On phones this is min(w,h) as
                                                  // before (cap is infinity → no-op).
                                                  // On tablets the board is capped so
                                                  // it doesn't swell edge-to-edge and
                                                  // dwarf the uiScale-sized HUD/controls
                                                  // — it stays a centered square with
                                                  // breathing room instead.
                                                  final boardCap =
                                                      context.responsive<double>(
                                                    phone: double.infinity,
                                                    tablet: 640,
                                                    largeTablet: 820,
                                                  );
                                                  final availableSize = math.min(
                                                    math.min(
                                                      boardConstraints.maxWidth,
                                                      boardConstraints.maxHeight,
                                                    ),
                                                    boardCap,
                                                  );

                                                  return Center(
                                                    child: SizedBox(
                                                      width: availableSize,
                                                      height: availableSize,
                                                      child: FlameGameBoard(
                                                        gameState: gameState,
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
                                          // Scoped rebuild: it displays snake
                                          // length / level / speed, which
                                          // change on eats and power-ups.
                                          BlocBuilder<GameCubit,
                                              GameCubitState>(
                                            buildWhen: (previous, current) {
                                              final prev = previous.gameState;
                                              final curr = current.gameState;
                                              if (prev == null ||
                                                  curr == null) {
                                                return true;
                                              }
                                              return prev.snake.length !=
                                                      curr.snake.length ||
                                                  prev.level != curr.level ||
                                                  prev.gameSpeed !=
                                                      curr.gameSpeed ||
                                                  prev.status != curr.status;
                                            },
                                            builder: (context, barState) {
                                              return GameBottomBar(
                                                gameState:
                                                    barState.gameState ??
                                                        gameState,
                                                theme: theme,
                                                isSmallScreen: isSmallScreen,
                                                dPadEnabled: settingsState
                                                    .dPadEnabled,
                                                onDirection: _handleSwipe,
                                              );
                                            },
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
                                  ScorePopupLayer(key: _scorePopupLayerKey),

                                  // Level-Up Corner Popup
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
                                isPro:
                                    context.read<GameCubit>().isProSession,
                                onProRevive: () =>
                                    context.read<GameCubit>().revive(),
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
                                  getIt<AdService>().showRewarded(
                                    onReward: gc.revive,
                                    placement: 'revive',
                                  );
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
                                    placement: 'time_bonus',
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
                            const RejectedInputFlash(),

                            // Debug builds only: live tick/frame/event
                            // panel (top-left). Compiled out of release.
                            if (kDebugMode) const DebugPerfOverlay(),
                          ],
                              ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ), // Close Scaffold
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
    // "Living compass": a tiny snake swimming inside a puck. It turns to
    // face the last accepted swipe and dashes with a comet trail in that
    // direction's color, so the chrome cue is the snake itself rather than
    // an abstract arrow + label.
    // directionGetter reads the field live: the game screen no longer
    // rebuilds on swipes, so a by-value Direction would freeze at the last
    // structural rebuild — the swipe animation itself triggers the repaint.
    return SnakeCompassIndicator(
      theme: theme,
      directionGetter: () => _lastSwipeDirection,
      swipeAnimation: _gestureIndicatorController,
      activeColorFor: (d) => _getActiveSwipeColor(d, theme),
      size: context.scaled(isSmallScreen ? 34.0 : 38.0),
    );
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
