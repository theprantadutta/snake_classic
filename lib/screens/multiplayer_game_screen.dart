import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/input_result.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:snake_classic/widgets/dpad_row_layout.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/versus/versus_match_widgets.dart';
import 'package:snake_classic/widgets/lb_screens/versus/versus_widgets.dart';
import 'package:snake_classic/widgets/steerable_dpad.dart';
import 'package:snake_classic/widgets/turn_buttons.dart';
import 'package:snake_classic/widgets/joystick_controls.dart';
import 'package:snake_classic/widgets/multiplayer_flame_board.dart';
import 'package:snake_classic/widgets/swipe_detector.dart';
import 'package:snake_classic/widgets/screen_shake.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';

/// The live 1v1 match screen (Living Board renders 19 and 20).
/// Server-authoritative: everything on screen (both snakes, food, scores,
/// deaths, the final result) renders from the engine snapshots in
/// [MultiplayerState.snapshot] — the only thing this screen sends is
/// direction inputs via [MultiplayerCubit.changeDirection].
class MultiplayerGameScreen extends StatefulWidget {
  const MultiplayerGameScreen({super.key});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  late FocusNode _keyboardFocusNode;

  // Juice effects controller (like single-player)
  late GameJuiceController _juiceController;

  // Animation controllers for UI polish
  late AnimationController _gestureIndicatorController;
  Direction? _lastSwipeDirection;

  // One-shot guards for listener-driven effects
  bool _resultDialogShown = false;
  bool _exiting = false;
  bool _juiceAliveLastTick = true;

  /// Match clock at the snapshot where my snake was first seen dead — the
  /// SURVIVED row on the result. Null while alive (survived = the match).
  int? _mySurvivedMs;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Note: the status bar is hidden app-wide via WindowInsetsController in
    // MainActivity.kt — no per-screen tweak needed. The nav bar stays
    // visible for back-gesture access.

    _keyboardFocusNode = FocusNode();

    // Initialize juice controller for screen shake and effects
    _juiceController = GameJuiceController();

    // Gesture indicator animation
    _gestureIndicatorController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _keyboardFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _keyboardFocusNode.dispose();
    _juiceController.dispose();
    _gestureIndicatorController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // The match kept ticking on the server while we were backgrounded;
      // if the transport dropped, this rejoins and pulls a MatchResumed
      // snapshot. No-op when still connected.
      final cubit = context.read<MultiplayerCubit>();
      if (cubit.state.status == MultiplayerStatus.playing ||
          cubit.state.status == MultiplayerStatus.reconnecting) {
        cubit.attemptReconnect();
      }
    }
  }

  String? get _currentUserId => context.read<AuthCubit>().state.userId;

  /// A press on the two-button layout, resolved off my snake's heading
  /// and then handled exactly like a swipe.
  void _handleRelativeTurn(RelativeTurn turn) {
    final target = context.read<MultiplayerCubit>().relativeTarget(turn);
    if (target != null) _handleSwipe(target);
  }

  void _handleSwipe(Direction direction) {
    // One result, one owner of the feedback.
    //
    // This used to call the cubit and then unconditionally add its own
    // selectionClick and success animation. The cubit already emits a
    // lightImpact for an accepted input, so an accepted turn buzzed TWICE —
    // and a refused or ignored one (dead, reconnecting, a reversal) still got
    // a positive click and the accepted cue, which is the game telling the
    // player it did something it did not do.
    final result = context.read<MultiplayerCubit>().changeDirection(direction);
    if (!result.isAccepted) return;

    _lastSwipeDirection = direction;
    _gestureIndicatorController.forward().then((_) {
      _gestureIndicatorController.reverse();
    });
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
        case LogicalKeyboardKey.escape:
          _showExitDialog();
          break;
      }

      if (direction != null) {
        _handleSwipe(direction);
      }
    }
  }

  /// Snapshot-diff juice: the death shake. The cubit owns sounds/haptics;
  /// this only drives the screen-shake widget. The score-up burst is not
  /// here: it fires when the board shows the bite ([_onLocalFoodShown]).
  void _applySnapshotJuice(MatchSnapshot snapshot) {
    final userId = _currentUserId;
    if (userId == null) return;
    final me = snapshot.playerByUserId(userId);
    if (me == null) return;

    if (_juiceAliveLastTick && !me.alive) {
      _mySurvivedMs ??= snapshot.elapsedGameMs;
      if (me.deathReason == 'wall') {
        _juiceController.wallHit();
      } else {
        _juiceController.selfCollision();
      }
    }
    _juiceAliveLastTick = me.alive;
  }

  /// The board has just shown one of my bites — the snake reaching the food
  /// on screen, which is not when the snapshot saying so arrived. The chirp
  /// and the burst belong to that moment.
  void _onLocalFoodShown() {
    if (!mounted) return;
    context.read<MultiplayerCubit>().playLocalEatFeedback();
    _juiceController.foodEaten();
  }

  void _showResultDialog(MatchEndResult result) {
    if (_resultDialogShown) return;
    _resultDialogShown = true;

    final l10n = AppLocalizations.of(context)!;
    final userId = _currentUserId ?? '';
    final won = result.isWinner(userId);
    final draw = result.isDraw;
    final me = result.playerByUserId(userId);
    final opponent = result.players
        .where((p) => p.userId != userId)
        .firstOrNull;
    final rival = opponent?.username ?? l10n.mpOpponent;
    final aborted = result.reason == 'aborted';

    // Plain first, funny second (COPY.md): the first line says how it
    // ended, the second is the joke — never on a cancelled match.
    final summary = _resultSummary(l10n, result, me, won: won, draw: draw);
    final VersusOutcome outcome;
    final String line;
    String? line2;
    if (won) {
      outcome = VersusOutcome.victory;
      line = summary;
      line2 = aborted ? null : l10n.lbVictoryLine(rival);
    } else if (draw) {
      outcome = VersusOutcome.draw;
      line = summary;
      line2 = aborted ? null : l10n.lbDrawLine;
    } else {
      outcome = VersusOutcome.defeat;
      line = result.reason == 'mutual_crash'
          ? l10n.lbDefeatBothCrashed
          : (_isUnexplainedLoss(result, me) ? l10n.lbDefeatLine(rival) : summary);
      line2 = aborted ? null : l10n.lbDefeatLine2(rival);
    }

    // Lengths and survival come from the last authoritative snapshot; the
    // GameEnded payload carries scores, not bodies.
    final snapshot = context.read<MultiplayerCubit>().state.snapshot;
    final myLen = snapshot?.playerByUserId(userId)?.body.length;
    final rivalLen = opponent == null
        ? null
        : snapshot?.playerByUserId(opponent.userId)?.body.length;
    final lengths = myLen == null
        ? null
        : (rivalLen == null ? '$myLen' : '$myLen · $rivalLen');
    final survivedMs = _mySurvivedMs ?? snapshot?.elapsedGameMs;

    // Quick-match sessions get a one-tap re-queue; friend rooms
    // don't (the room is finished — they re-invite from the lobby).
    final canRematch = context.read<MultiplayerCubit>().lastMatchWasQuickMatch;

    showVersusResultDialog(
      context: context,
      card: (dialogContext) => VersusResultCard(
        outcome: outcome,
        line: line,
        line2: line2,
        myScore: me?.score ?? 0,
        rivalScore: opponent?.score ?? 0,
        lengths: lengths,
        survived: survivedMs == null ? null : versusClock(survivedMs),
        onBackToLobby: () {
          dialogContext.pop();
          _navigateToLobby();
        },
        onRematch: !canRematch
            ? null
            : () {
                dialogContext.pop();
                _exiting = true;
                final cubit = context.read<MultiplayerCubit>();
                context.pushReplacement(AppRoutes.multiplayerLobby);
                cubit.queueAgain();
              },
      ),
    );
  }

  /// A loss with no specific cause on record — the summary would only say
  /// "better luck next time", so the rival's name says it better.
  bool _isUnexplainedLoss(MatchEndResult result, MatchEndPlayer? me) {
    if (result.reason == 'timeout' ||
        result.reason == 'mutual_crash' ||
        result.reason == 'aborted') {
      return false;
    }
    const known = {'wall', 'self', 'opponent', 'head_on', 'forfeit'};
    return !known.contains(me?.deathReason);
  }

  /// One human line explaining how the match ended, from the winner's or
  /// loser's perspective. Full sentences per branch (never assembled from
  /// fragments) so every language can use natural word order.
  String _resultSummary(
    AppLocalizations l10n,
    MatchEndResult result,
    MatchEndPlayer? me, {
    required bool won,
    required bool draw,
  }) {
    switch (result.reason) {
      case 'timeout':
        return draw
            ? l10n.mpTimeUpDraw
            : (won ? l10n.mpTimeUpYouWon : l10n.mpTimeUpYouLost);
      case 'mutual_crash':
        return draw
            ? l10n.mpMutualCrashDraw
            : (won ? l10n.mpMutualCrashYouWon : l10n.mpMutualCrashYouLost);
      case 'aborted':
        return l10n.mpMatchCancelled;
      default: // last_alive
        if (won) {
          return l10n.mpLastSnakeStanding;
        }
        switch (me?.deathReason) {
          case 'wall':
            return l10n.mpDeathWall;
          case 'self':
            return l10n.mpDeathSelf;
          case 'opponent':
            return l10n.mpDeathOpponent;
          case 'head_on':
            return l10n.mpDeathHeadOn;
          case 'forfeit':
            return l10n.mpDeathForfeit;
          default:
            return l10n.mpBetterLuck;
        }
    }
  }

  void _navigateToLobby() {
    // leaveGame emits idle — flag first so the stranded-exit listener
    // doesn't navigate a second time.
    _exiting = true;
    context.read<MultiplayerCubit>().leaveGame();
    context.pushReplacement(AppRoutes.multiplayerLobby);
  }

  void _showExitDialog() {
    final l10n = AppLocalizations.of(context)!;

    showLBDialog<void>(
      context: context,
      title: l10n.mpLeaveGameTitle,
      body: l10n.mpLeaveGameBody,
      primaryLabel: l10n.mpLeave,
      primaryKind: LBBlockKind.danger,
      titleColor: LB.bonk,
      onPrimary: () {
        // showDialog mounts on the root navigator; pop exactly that route.
        Navigator.of(context, rootNavigator: true).pop();
        _navigateToLobby();
      },
      secondaryLabel: l10n.commonCancel,
    ).whenComplete(_restoreGameplayFocus);
  }

  /// Give the keyboard back to the match after a modal takes it away.
  ///
  /// A dialog route steals focus and does not hand it back on dismissal, so
  /// on desktop and web the arrow keys silently stopped steering after any
  /// Cancel — in a live match, where the snake keeps moving.
  void _restoreGameplayFocus() {
    if (!mounted) return;
    if (_keyboardFocusNode.hasFocus) return;
    _keyboardFocusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final shakeEnabled = context
        .watch<GameSettingsCubit>()
        .state
        .screenShakeEnabled;
    _juiceController.shakeEnabled = shakeEnabled;

    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;

        return BlocListener<MultiplayerCubit, MultiplayerState>(
          listenWhen: (prev, curr) =>
              !identical(prev.snapshot, curr.snapshot) ||
              (prev.matchEnd == null && curr.matchEnd != null) ||
              prev.status != curr.status,
          listener: (context, state) {
            final snapshot = state.snapshot;
            if (snapshot != null) {
              _applySnapshotJuice(snapshot);
            }
            final matchEnd = state.matchEnd;
            if (matchEnd != null && !_resultDialogShown) {
              // Give the death shake a beat to land before the verdict.
              Future.delayed(const Duration(milliseconds: 900), () {
                if (mounted && !_resultDialogShown) {
                  _showResultDialog(matchEnd);
                }
              });
            }

            // Stranded exit: the cubit gave up on the match (reconnect
            // refused/timed out) with no GameEnded result. Leave the
            // dead board instead of freezing on it.
            final stranded =
                !_exiting &&
                !_resultDialogShown &&
                state.matchEnd == null &&
                (state.status == MultiplayerStatus.idle ||
                    state.status == MultiplayerStatus.error);
            if (stranded) {
              _exiting = true;
              final errorCode = state.errorCode;
              if (errorCode != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  arcadeSnackBar(
                    context,
                    message: errorCode.localizedMessage(
                      AppLocalizations.of(context)!,
                    ),
                  ),
                );
              }
              context.pushReplacement(AppRoutes.multiplayerLobby);
            }
          },
          // Everything from here down to the Stack depends on the THEME, not
          // on the snapshot: the board background, the keyboard listener,
          // the exit guard. Only the parts that actually read the snapshot
          // rebuild per tick.
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (!didPop) {
                _showExitDialog();
              }
            },
            child: KeyboardListener(
              focusNode: _keyboardFocusNode,
              onKeyEvent: _handleKeyPress,
              child: GameJuiceWidget(
                controller: _juiceController,
                // The player's motion setting applies here too. This was
                // hard-coded true, so someone who had turned shake off still
                // got shaken by every multiplayer crash. The controller is
                // told as well as the widget, exactly as single-player does
                // it, so a disabled shake is never animated in the first
                // place rather than animated into a widget that drops it.
                applyShake: shakeEnabled,
                child: Scaffold(
                  backgroundColor: context.lb.board,
                  // No SafeArea at this level: the grid and the reconnecting
                  // scrim must reach the status-bar and nav-bar strips, or
                  // they show through as flat bands. The gameplay column
                  // pads its own insets below; the match intro is centred
                  // and needs none.
                  body: LBGridBackground(
                    child: BlocBuilder<MultiplayerCubit, MultiplayerState>(
                      builder: (context, multiplayerState) {
                        return BlocBuilder<AuthCubit, AuthState>(
                          builder: (context, authState) {
                            final snapshot = multiplayerState.snapshot;
                            final currentUserId = authState.userId ?? '';

                            // Waiting for the first authoritative
                            // snapshot — GameStarted lands right after
                            // the countdown. The exit guard is above
                            // this, so backing out of "GET READY"
                            // still cannot silently leave the room
                            // joined server-side.
                            if (snapshot == null) {
                              return _buildMatchIntro();
                            }

                            final me = snapshot.playerByUserId(currentUserId);
                            final opponent = snapshot.players
                                .where((p) => p.userId != currentUserId)
                                .firstOrNull;

                            return Stack(
                              children: [
                                // Main game content, padded for the insets
                                // the Stack ignores.
                                SafeArea(
                                  child: Column(
                                    children: [
                                      // YOU · clock · RIVAL (render 19).
                                      VersusMatchHeader(
                                        me: me,
                                        opponent: opponent,
                                        elapsedGameMs: snapshot.elapsedGameMs,
                                        onLeave: _showExitDialog,
                                      ),

                                      Expanded(
                                        child: _buildBoardArea(
                                          multiplayerState,
                                          snapshot,
                                          currentUserId,
                                          me,
                                          opponent,
                                        ),
                                      ),

                                      // Bottom control strip
                                      _buildControlStrip(
                                        theme,
                                        snapshot,
                                        currentUserId,
                                      ),
                                    ],
                                  ),
                                ),

                                // Connection-loss overlay: the board
                                // freezes on the last snapshot while
                                // the cubit retries; say so instead of
                                // looking hung.
                                if (multiplayerState.status ==
                                    MultiplayerStatus.reconnecting)
                                  Positioned.fill(
                                    child: _buildReconnectingOverlay(),
                                  ),
                              ],
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The split cell row, the board and the gap line (render 19).
  Widget _buildBoardArea(
    MultiplayerState multiplayerState,
    MatchSnapshot snapshot,
    String currentUserId,
    MatchPlayerState? me,
    MatchPlayerState? opponent,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final gapLineH = context.lbCell * 1.6;
    return LayoutBuilder(
      builder: (context, c) {
        // The board uses every column on phones (DESIGN_SPEC §2), capped on
        // tablets so it doesn't dwarf the uiScale-sized HUD and controls.
        final cap = context.responsive<double>(
          phone: double.infinity,
          tablet: 640,
          largeTablet: 820,
        );
        // The split row is one cell per column (18), plus its 3 dp gap and
        // 1 dp wall, plus 4 dp before the board.
        const splitCells = 18;
        var side = math.min(c.maxWidth, cap);
        final maxH = c.maxHeight - gapLineH - 8;
        if (side + side / splitCells > maxH) {
          side = math.max(0.0, maxH / (1 + 1 / splitCells));
        }

        final myScore = me?.score ?? 0;
        final rivalScore = opponent?.score ?? 0;
        final gap = (rivalScore - myScore).abs();
        final String? gapLine = opponent == null
            ? null
            : rivalScore > myScore
            ? l10n.lbMatchBehind(opponent.username, context.formatInt(gap))
            : myScore > rivalScore
            ? l10n.lbMatchAhead(context.formatInt(gap))
            : l10n.lbMatchTied;

        // The board is square (the server's grid), so on a tall phone
        // there is height to spare: centre the board group in it rather
        // than leaving one empty band under the board.
        return Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: side,
                child: VersusSplitBar(
                  myScore: myScore,
                  rivalScore: rivalScore,
                  count: splitCells,
                ),
              ),
              const SizedBox(height: 4),
              // Swipe recognition is scoped to the board rectangle. It used
              // to wrap the whole column, so a drag starting on the versus
              // header or the control strip could steer. The board is
              // square; size it HERE, so the frame wraps the playfield
              // exactly.
              SizedBox(
                width: side,
                height: side,
                child: SwipeDetector(
                  onSwipe: _handleSwipe,
                  child: MultiplayerFlameBoard(
                    snapshot: snapshot,
                    boardSize: multiplayerState.boardSize,
                    currentUserId: currentUserId,
                    prediction: multiplayerState.localPrediction,
                    onLocalFoodEaten: _onLocalFoodShown,
                  ),
                ),
              ),
              SizedBox(
                height: gapLineH,
                width: side,
                child: gapLine == null
                    ? null
                    : Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
                          child: Text(
                            gapLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: LBText.body(p, size: 11.5),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Dim the frozen board and say what's happening while the cubit
  /// retries the connection. The match keeps running server-side.
  Widget _buildReconnectingOverlay() {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return ColoredBox(
      color: p.board.withValues(alpha: .82),
      child: Center(
        child: Semantics(
          liveRegion: true,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const VersusBusyCells(cell: 10),
              const SizedBox(height: 22),
              Text(
                l10n.mpReconnecting.toUpperCase(),
                style: LBText.button(p, color: p.lime, size: 16).copyWith(letterSpacing: 3),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: context.lbGutter),
                child: Text(
                  l10n.mpReconnectingBody,
                  textAlign: TextAlign.center,
                  style: LBText.body(p, size: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Pre-match splash shown while we wait for the first authoritative
  /// snapshot (right after matchmaking, before the countdown lands).
  Widget _buildMatchIntro() {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LBCellText(l10n.lbVs, cell: 14 * context.uiScale, glow: true).gameBreathe(intensity: 1.08),
          const SizedBox(height: 30),
          Text(
            l10n.mpGetReady.toUpperCase(),
            style: LBText.button(p, color: p.lime, size: 18).copyWith(letterSpacing: 4),
          ),
          const SizedBox(height: 8),
          Text(l10n.mpDroppingIntoArena, style: LBText.body(p, size: 12)),
          const SizedBox(height: 26),
          const VersusBusyCells(count: 5, cell: 8),
        ],
      ),
    );
  }

  double _getDirectionRotation(Direction? direction) {
    // The pixel arrow (LBIcon.next) points right.
    if (direction == null) return 0.0;
    switch (direction) {
      case Direction.right:
        return 0.0;
      case Direction.down:
        return 0.25;
      case Direction.left:
        return 0.5;
      case Direction.up:
        return 0.75;
    }
  }

  /// Bottom strip: your length on the left, the steering echo on the right
  /// (render 19). For rare >2-player matches a compact scoreboard fills the
  /// middle (the header only frames you vs your primary rival). On-screen
  /// control layouts keep their own widgets, flanked by the same two blocks.
  Widget _buildControlStrip(
    GameTheme theme,
    MatchSnapshot snapshot,
    String currentUserId,
  ) {
    final mySnake = snapshot.playerByUserId(currentUserId);
    final manyPlayers = snapshot.players.length > 2;
    final length = mySnake?.body.length ?? 0;
    final cell = context.lbCell;

    // Same dpad_enabled setting as single-player — D-pad users get their
    // D-pad in VS matches too. watch: the pause-less match screen still
    // reflects a toggle made before entering.
    final settings = context.watch<GameSettingsCubit>().state;
    final dPadEnabled = settings.dPadEnabled;
    final dPadPosition = settings.dPadPosition;
    final turnButtons = settings.controlLayout == ControlLayout.turnButtons;
    final joystick = settings.controlLayout == ControlLayout.joystick;
    final dpadSize = 120.0 * context.uiScale;

    // Whether this player can steer AT ALL right now — dead, ended, or
    // reconnecting all mean no. The cubit already refused those inputs; the
    // control carried on looking pressable, which is the game inviting an
    // action it will silently discard.
    final canSteer = context.watch<MultiplayerCubit>().canSteer;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        context.lbGutter,
        cell * .2,
        context.lbGutter,
        cell * .5,
      ),
      child: dPadEnabled
          ? (turnButtons
                ? SteerableTurnButtons(
                    onTurn: _handleRelativeTurn,
                    theme: theme,
                    height: dpadSize,
                    canSteer: canSteer,
                    centre: _lenBlock(length, width: cell * 4),
                  )
                : joystick
                ? Row(
                    children: [
                      _lenBlock(length, width: cell * 4),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SteerableJoystick(
                          onDirection: _handleSwipe,
                          theme: theme,
                          height: dpadSize,
                          canSteer: canSteer,
                        ),
                      ),
                      const SizedBox(width: 10),
                      _swipeIndicator(maxWidth: cell * 5),
                    ],
                  )
                : _buildDPadRow(
                    theme: theme,
                    dpadSize: dpadSize,
                    dPadPosition: dPadPosition,
                    canSteer: canSteer,
                    snakeLength: length,
                  ))
          : Row(
              children: [
                Expanded(flex: 5, child: _lenBlock(length)),
                if (manyPlayers) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 6,
                    child: _miniLeaderboard(snapshot, currentUserId),
                  ),
                  const SizedBox(width: 8),
                ] else
                  const Spacer(flex: 3),
                Expanded(flex: 5, child: _swipeIndicator()),
              ],
            ),
    );
  }

  /// The lower control row, honouring the player's saved d-pad position.
  ///
  /// Same treatment as single-player: the setting was stored, synced and
  /// offered in Settings, and then ignored here. Placement is a reorder inside
  /// the existing strip, so the board's geometry does not move with it.
  Widget _buildDPadRow({
    required GameTheme theme,
    required double dpadSize,
    required DPadPosition dPadPosition,
    required bool canSteer,
    required int snakeLength,
  }) {
    final cell = context.lbCell;
    final dPad = SteerableDPad(
      onDirection: _handleSwipe,
      theme: theme,
      size: dpadSize,
      canSteer: canSteer,
    );

    Widget lengthBlock(Alignment alignment) => Align(
      alignment: alignment,
      child: _lenBlock(snakeLength, width: cell * 4),
    );
    Widget indicator(Alignment alignment) => Align(
      alignment: alignment,
      child: _swipeIndicator(maxWidth: cell * 5),
    );

    return DPadRowLayout.build(
      position: dPadPosition,
      dPad: dPad,
      leading: lengthBlock,
      trailing: indicator,
    );
  }

  /// `LEN 4` (render 19).
  Widget _lenBlock(int length, {double? width}) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBBlock(
      width: width,
      height: context.lbCell * 2.4,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      semanticLabel: '${l10n.mpLength} $length',
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            l10n.lbHudLen('$length'),
            maxLines: 1,
            style: LBText.button(p, color: p.ink.withValues(alpha: .8), size: 13)
                .copyWith(letterSpacing: 2.4),
          ),
        ),
      ),
    );
  }

  /// The steering indicator: idle, accepted, or refused.
  ///
  /// Three states, deliberately, because two were not enough. An accepted
  /// turn lights the block in lime and points it the way you went; a
  /// refused one — a reversal into your own neck, or a repeat of the
  /// direction already sent — turns it red and shows a cross, so it can never
  /// be mistaken for the accepted cue. An input from a player who cannot
  /// steer leaves the block exactly as it was.
  ///
  /// Both cues are local and immediate. Neither waits for the server: the
  /// refusal never left the device, and the acceptance is the client's own
  /// echo until the next snapshot overrides it.
  Widget _swipeIndicator({double? maxWidth}) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return BlocBuilder<MultiplayerCubit, MultiplayerState>(
      buildWhen: (prev, curr) =>
          prev.lastRejectedInputAt != curr.lastRejectedInputAt ||
          prev.lastRejectedDirection != curr.lastRejectedDirection,
      builder: (context, state) {
        final rejectedDirection = state.lastRejectedInputAt == null
            ? null
            : state.lastRejectedDirection;

        return AnimatedBuilder(
          animation: _gestureIndicatorController,
          builder: (context, child) {
            final isRejected = rejectedDirection != null;
            final isActive =
                !isRejected &&
                _lastSwipeDirection != null &&
                _gestureIndicatorController.isAnimating;

            final kind = isRejected
                ? LBBlockKind.danger
                : (isActive ? LBBlockKind.outline : LBBlockKind.muted);
            final color = isRejected
                ? LB.bonk
                : (isActive ? p.lime : p.inkMuted);

            final block = LBBlock(
              kind: kind,
              selected: isActive,
              height: context.lbCell * 2.4,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isRejected)
                    const LBPixelIcon(LBIcon.x, cell: 2.6, color: LB.bonk)
                  else if (_lastSwipeDirection != null)
                    AnimatedRotation(
                      turns: _getDirectionRotation(_lastSwipeDirection),
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      child: LBPixelIcon(
                        LBIcon.next,
                        cell: 2.6,
                        color: isActive ? p.lime : p.lime.withValues(alpha: .6),
                      ),
                    ),
                  if (isRejected || _lastSwipeDirection != null)
                    const SizedBox(width: 8),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        isRejected
                            ? l10n.mpTurnBlocked.toUpperCase()
                            : l10n.lbSwipeToSteer,
                        maxLines: 1,
                        style: LBText.button(p, color: color, size: 11.5)
                            .copyWith(letterSpacing: 2),
                      ),
                    ),
                  ),
                ],
              ),
            );
            return maxWidth == null
                ? block
                : ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: maxWidth),
                    child: block,
                  );
          },
        );
      },
    );
  }

  Widget _miniLeaderboard(
    MatchSnapshot snapshot,
    String currentUserId,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final sortedPlayers = List<MatchPlayerState>.from(snapshot.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return SizedBox(
      height: context.lbCell * 2.4 + LB.inset * 2,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortedPlayers.length,
        itemBuilder: (context, index) {
          final player = sortedPlayers[index];
          final isMe = player.userId == currentUserId;
          final color = !player.alive
              ? p.inkDim
              : (isMe ? p.lime : LB.rival);

          return LBBlock(
            kind: isMe ? LBBlockKind.outline : LBBlockKind.muted,
            selected: isMe,
            height: context.lbCell * 2.4,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${index + 1}',
                  style: LBText.button(p, color: index == 0 ? LB.gold : p.inkDim, size: 12),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 76),
                      child: Text(
                        isMe ? l10n.lbYou : player.username,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LBText.label(p, color: color).copyWith(
                          letterSpacing: 1,
                          decoration: player.alive ? null : TextDecoration.lineThrough,
                        ),
                      ),
                    ),
                    Text(
                      '${context.formatInt(player.score)} ${l10n.lbPts}',
                      style: LBText.body(p, color: color, size: 10),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
