import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/multiplayer_flame_board.dart';
import 'package:snake_classic/game/flame/rendering/multiplayer_board_painter.dart';
import 'package:snake_classic/widgets/swipe_detector.dart';
import 'package:snake_classic/widgets/screen_shake.dart';

/// The live 1v1 match screen. Server-authoritative: everything on screen
/// (both snakes, food, scores, deaths, the final result) renders from the
/// engine snapshots in [MultiplayerState.snapshot] — the only thing this
/// screen sends is direction inputs via [MultiplayerCubit.changeDirection].
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
  int _lastJuiceScore = 0;
  bool _juiceAliveLastTick = true;

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
      if (cubit.state.status == MultiplayerStatus.playing) {
        cubit.attemptReconnect();
      }
    }
  }

  String? get _currentUserId => context.read<AuthCubit>().state.userId;

  void _handleSwipe(Direction direction) {
    // The cubit guards reversals and dead/ended states — this just sends
    // and animates the local echo.
    context.read<MultiplayerCubit>().changeDirection(direction);
    _lastSwipeDirection = direction;
    HapticService().selectionClick();

    // Animate gesture indicator
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

  /// Snapshot-diff juice: score-up burst and death shake. The cubit owns
  /// sounds/haptics; this only drives the screen-shake widget.
  void _applySnapshotJuice(MatchSnapshot snapshot) {
    final userId = _currentUserId;
    if (userId == null) return;
    final me = snapshot.playerByUserId(userId);
    if (me == null) return;

    if (me.score > _lastJuiceScore) {
      _juiceController.foodEaten();
    }
    if (_juiceAliveLastTick && !me.alive) {
      if (me.deathReason == 'wall') {
        _juiceController.wallHit();
      } else {
        _juiceController.selfCollision();
      }
    }
    _lastJuiceScore = me.score;
    _juiceAliveLastTick = me.alive;
  }

  void _showResultDialog(MatchEndResult result) {
    if (_resultDialogShown) return;
    _resultDialogShown = true;

    final theme = context.read<ThemeCubit>().state.currentTheme;
    final userId = _currentUserId ?? '';
    final won = result.isWinner(userId);
    final draw = result.isDraw;
    final me = result.playerByUserId(userId);
    final opponent = result.players
        .where((p) => p.userId != userId)
        .firstOrNull;

    final titleColor = won
        ? Colors.amber
        : (draw ? theme.accentColor : Colors.red.shade400);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: titleColor.withValues(alpha: 0.5)),
        ),
        title: Row(
          children: [
            Icon(
              won
                  ? Icons.emoji_events
                  : (draw ? Icons.handshake : Icons.sports_score),
              color: titleColor,
              size: 32,
            ),
            const SizedBox(width: 12),
            Text(
              won ? 'VICTORY!' : (draw ? 'DRAW' : 'DEFEAT'),
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _resultSummary(result, me, won: won, draw: draw),
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.accentColor, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    titleColor.withValues(alpha: 0.1),
                    titleColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: titleColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _resultScoreColumn(theme, 'You', me?.score ?? 0),
                  Text(
                    'VS',
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.5),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _resultScoreColumn(
                    theme,
                    opponent?.username ?? 'Opponent',
                    opponent?.score ?? 0,
                  ),
                ],
              ),
            ),
            if (won && result.winnerCoinReward > 0) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Colors.amber,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '+${result.winnerCoinReward} coins',
                      style: const TextStyle(
                        color: Colors.amber,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              dialogContext.pop();
              _navigateToLobby();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Back to Lobby',
                style: TextStyle(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultScoreColumn(GameTheme theme, String label, int score) {
    return Column(
      children: [
        Text(
          label.length > 10 ? '${label.substring(0, 10)}…' : label,
          style: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          '$score',
          style: TextStyle(
            color: theme.accentColor,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// One human line explaining how the match ended, from the winner's or
  /// loser's perspective.
  String _resultSummary(
    MatchEndResult result,
    MatchEndPlayer? me, {
    required bool won,
    required bool draw,
  }) {
    switch (result.reason) {
      case 'timeout':
        return draw
            ? 'Time\'s up — dead even!'
            : 'Time\'s up — ${won ? 'you had' : 'your opponent had'} the higher score.';
      case 'mutual_crash':
        return draw
            ? 'Both snakes crashed — it\'s a tie!'
            : 'Both snakes crashed — ${won ? 'your' : 'their'} score decided it.';
      case 'aborted':
        return 'The match was cancelled.';
      default: // last_alive
        if (won) {
          return 'Your opponent crashed. Last snake standing!';
        }
        switch (me?.deathReason) {
          case 'wall':
            return 'You crashed into the wall.';
          case 'self':
            return 'You crashed into yourself.';
          case 'opponent':
            return 'You crashed into your opponent.';
          case 'head_on':
            return 'Head-on collision!';
          case 'forfeit':
            return 'Disconnected too long — match forfeited.';
          default:
            return 'Better luck next time!';
        }
    }
  }

  void _navigateToLobby() {
    context.read<MultiplayerCubit>().leaveGame();
    context.pushReplacement(AppRoutes.multiplayerLobby);
  }

  void _showExitDialog() {
    final theme = context.read<ThemeCubit>().state.currentTheme;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Leave Game?',
          style: TextStyle(
            color: theme.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'The match keeps running on the server — leaving forfeits it.',
          style: TextStyle(color: theme.accentColor),
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              dialogContext.pop();
              _navigateToLobby();
            },
            child: const Text('Leave', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;

        return BlocListener<MultiplayerCubit, MultiplayerState>(
          listenWhen: (prev, curr) =>
              !identical(prev.snapshot, curr.snapshot) ||
              (prev.matchEnd == null && curr.matchEnd != null),
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
          },
          child: BlocBuilder<MultiplayerCubit, MultiplayerState>(
            builder: (context, multiplayerState) {
              return BlocBuilder<AuthCubit, AuthState>(
                builder: (context, authState) {
                  final snapshot = multiplayerState.snapshot;
                  final currentUserId = authState.userId ?? '';

                  // Waiting for the first authoritative snapshot
                  // (GameStarted lands right after the countdown).
                  if (snapshot == null) {
                    return _buildMatchIntro(theme);
                  }

                  return PopScope(
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
                        applyShake: true,
                        child: Scaffold(
                          body: Container(
                            decoration: BoxDecoration(
                              // Use theme colors, matching single-player
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
                            child: SafeArea(
                              child: Stack(
                                children: [
                                  // Background pattern
                                  Positioned.fill(
                                    child: CustomPaint(
                                      painter: _GameBackgroundPainter(theme),
                                    ),
                                  ),

                                  // Main game content
                                  SwipeDetector(
                                    onSwipe: _handleSwipe,
                                    child: Column(
                                      children: [
                                        // Face-to-face versus header:
                                        // duel panel, live scores, momentum
                                        // bar and match clock.
                                        _buildVersusHeader(
                                          theme,
                                          snapshot,
                                          currentUserId,
                                        ),

                                        // Game Board — renders the
                                        // authoritative snapshots
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: MultiplayerFlameBoard(
                                              snapshot: snapshot,
                                              boardSize:
                                                  multiplayerState.boardSize,
                                              currentUserId: currentUserId,
                                            ),
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
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  String _formatGameClock(int elapsedGameMs) {
    final totalSeconds = elapsedGameMs ~/ 1000;
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Pre-match splash shown while we wait for the first authoritative
  /// snapshot (right after matchmaking, before the countdown lands).
  Widget _buildMatchIntro(GameTheme theme) {
    return Scaffold(
      backgroundColor: theme.backgroundColor,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: [
              theme.accentColor.withValues(alpha: 0.18),
              theme.backgroundColor,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: context.scaled(96),
                height: context.scaled(96),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.accentColor,
                      theme.accentColor.withValues(alpha: 0.5),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha: 0.5),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'VS',
                    style: TextStyle(
                      color: theme.backgroundColor,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ).gameBreathe(intensity: 1.08),
              const SizedBox(height: 28),
              Text(
                'GET READY',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Dropping you into the arena…',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: context.scaled(150),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    minHeight: 4,
                    backgroundColor: theme.accentColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.accentColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// The centerpiece of the match screen: a face-to-face duel panel with
  /// both players' avatars, live scores, a leading-momentum bar, and the
  /// shared match clock.
  Widget _buildVersusHeader(
    GameTheme theme,
    MatchSnapshot snapshot,
    String currentUserId,
  ) {
    final me = snapshot.playerByUserId(currentUserId);
    final opponent = snapshot.players
        .where((p) => p.userId != currentUserId)
        .firstOrNull;

    final myColor = me != null
        ? multiplayerColors[me.playerIndex % multiplayerColors.length]
        : theme.accentColor;
    final oppColor = opponent != null
        ? multiplayerColors[opponent.playerIndex % multiplayerColors.length]
        : Colors.redAccent;

    final myScore = me?.score ?? 0;
    final oppScore = opponent?.score ?? 0;

    return Container(
      margin: EdgeInsets.fromLTRB(12, context.scaled(8), 12, 4),
      padding: EdgeInsets.all(context.scaled(12)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            myColor.withValues(alpha: 0.16),
            theme.backgroundColor.withValues(alpha: 0.55),
            oppColor.withValues(alpha: 0.16),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top control row: back button + live match clock.
          Row(
            children: [
              _circleIconButton(
                theme,
                Icons.arrow_back_ios_new,
                _showExitDialog,
              ),
              const Spacer(),
              _liveTimerChip(theme, snapshot),
            ],
          ),
          SizedBox(height: context.scaled(12)),
          // Duel row: you vs opponent, flanking the VS medallion.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _duelPlayerCell(
                  theme,
                  me,
                  myColor,
                  isMe: true,
                  alignEnd: false,
                  leading: myScore > oppScore,
                ),
              ),
              _vsMedallion(theme),
              Expanded(
                child: _duelPlayerCell(
                  theme,
                  opponent,
                  oppColor,
                  isMe: false,
                  alignEnd: true,
                  leading: oppScore > myScore,
                ),
              ),
            ],
          ),
          SizedBox(height: context.scaled(12)),
          _momentumBar(myColor, oppColor, myScore, oppScore),
        ],
      ),
    );
  }

  Widget _circleIconButton(
    GameTheme theme,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Material(
      color: theme.backgroundColor.withValues(alpha: 0.6),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(context.scaled(8)),
          child: Icon(icon, color: theme.accentColor, size: context.scaled(18)),
        ),
      ),
    );
  }

  Widget _liveTimerChip(GameTheme theme, MatchSnapshot snapshot) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(12),
        vertical: context.scaled(7),
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.foodColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Live indicator dot.
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.foodColor,
              boxShadow: [
                BoxShadow(
                  color: theme.foodColor.withValues(alpha: 0.7),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.timer_outlined,
            color: theme.foodColor.withValues(alpha: 0.8),
            size: 15,
          ),
          const SizedBox(width: 6),
          Text(
            _formatGameClock(snapshot.elapsedGameMs),
            style: TextStyle(
              color: theme.foodColor.withValues(alpha: 0.9),
              fontSize: 13,
              fontWeight: FontWeight.w700,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _vsMedallion(GameTheme theme) {
    final size = context.scaled(46);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.accentColor.withValues(alpha: 0.95),
            theme.accentColor.withValues(alpha: 0.5),
          ],
        ),
        border: Border.all(
          color: theme.backgroundColor.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.4),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          'VS',
          style: TextStyle(
            color: theme.backgroundColor,
            fontSize: 15,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }

  Widget _duelPlayerCell(
    GameTheme theme,
    MatchPlayerState? player,
    Color color, {
    required bool isMe,
    required bool alignEnd,
    required bool leading,
  }) {
    final rawName = player == null ? 'Waiting…' : (isMe ? 'You' : player.username);
    final name = rawName.length > 9 ? '${rawName.substring(0, 9)}…' : rawName;
    final score = player?.score ?? 0;
    final alive = player?.alive ?? true;
    final connected = player?.connected ?? true;
    final initial = (player != null && player.username.isNotEmpty)
        ? player.username[0].toUpperCase()
        : '?';

    final avatar = _playerAvatar(
      theme,
      color,
      initial,
      alive: alive,
      connected: connected,
    );

    final info = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading && !alignEnd) ...[
              const Icon(Icons.emoji_events, color: Colors.amber, size: 13),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                name,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: alive
                      ? theme.accentColor.withValues(alpha: 0.9)
                      : Colors.grey,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  decoration: alive ? null : TextDecoration.lineThrough,
                ),
              ),
            ),
            if (leading && alignEnd) ...[
              const SizedBox(width: 4),
              const Icon(Icons.emoji_events, color: Colors.amber, size: 13),
            ],
          ],
        ),
        const SizedBox(height: 2),
        Text(
          '$score',
          style: TextStyle(
            color: alive ? theme.accentColor : Colors.grey,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.0,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        if (!alive)
          Text(
            'OUT',
            style: TextStyle(
              color: Colors.red.shade400,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
            ),
          )
        else if (!connected)
          Text(
            'reconnecting…',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );

    final children = alignEnd
        ? [
            Expanded(child: info),
            SizedBox(width: context.scaled(10)),
            avatar,
          ]
        : [
            avatar,
            SizedBox(width: context.scaled(10)),
            Expanded(child: info),
          ];

    return Row(mainAxisSize: MainAxisSize.max, children: children);
  }

  Widget _playerAvatar(
    GameTheme theme,
    Color color,
    String initial, {
    required bool alive,
    required bool connected,
  }) {
    final size = context.scaled(46);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: alive ? 0.9 : 0.25),
                color.withValues(alpha: alive ? 0.45 : 0.12),
              ],
            ),
            border: Border.all(
              color: color.withValues(alpha: alive ? 0.85 : 0.3),
              width: 2,
            ),
            boxShadow: alive
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: alive
                ? Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  )
                : const Icon(
                    Icons.close_rounded,
                    color: Colors.white70,
                    size: 24,
                  ),
          ),
        ),
        if (!connected)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: theme.backgroundColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.orange, width: 1),
              ),
              child: const Icon(Icons.wifi_off, color: Colors.orange, size: 11),
            ),
          ),
      ],
    );
  }

  /// A tug-of-war bar: the split point tracks each player's share of the
  /// combined score, so you can read who's ahead at a glance.
  Widget _momentumBar(
    Color myColor,
    Color oppColor,
    int myScore,
    int oppScore,
  ) {
    final total = myScore + oppScore;
    final myFrac = total == 0 ? 0.5 : (myScore / total).clamp(0.06, 0.94);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: context.scaled(8),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final splitX = width * myFrac;
            return Stack(
              children: [
                // Opponent side fills the full track underneath.
                Container(width: width, color: oppColor.withValues(alpha: 0.6)),
                // Your lead grows from the left.
                AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  width: splitX,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [myColor, myColor.withValues(alpha: 0.75)],
                    ),
                  ),
                ),
                // Bead marking the split point.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOut,
                  left: splitX - context.scaled(4),
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: context.scaled(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.6),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
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

  /// Slim bottom strip: your snake length on the left, a live swipe-echo
  /// indicator on the right. For rare >2-player matches a compact scoreboard
  /// fills the middle (the header only frames you vs your primary rival).
  Widget _buildControlStrip(
    GameTheme theme,
    MatchSnapshot snapshot,
    String currentUserId,
  ) {
    final mySnake = snapshot.playerByUserId(currentUserId);
    final manyPlayers = snapshot.players.length > 2;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: context.scaled(10),
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(color: theme.accentColor.withValues(alpha: 0.15)),
        ),
      ),
      child: Row(
        children: [
          _statPill(
            theme,
            Icons.straighten,
            'LENGTH',
            '${mySnake?.body.length ?? 0}',
          ),
          if (manyPlayers) ...[
            const SizedBox(width: 12),
            Expanded(child: _miniLeaderboard(theme, snapshot, currentUserId)),
            const SizedBox(width: 12),
          ] else
            const Spacer(),
          _swipeIndicator(theme),
        ],
      ),
    );
  }

  Widget _statPill(
    GameTheme theme,
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.15)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: theme.accentColor.withValues(alpha: 0.7), size: 16),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.55),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _swipeIndicator(GameTheme theme) {
    return AnimatedBuilder(
      animation: _gestureIndicatorController,
      builder: (context, child) {
        final isActive =
            _lastSwipeDirection != null &&
            _gestureIndicatorController.isAnimating;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: isActive ? 0.7 : 0.25),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedRotation(
                turns: _getDirectionRotation(_lastSwipeDirection),
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: theme.accentColor.withValues(
                    alpha: isActive ? 1.0 : 0.6,
                  ),
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Swipe',
                style: TextStyle(
                  color: theme.accentColor.withValues(
                    alpha: isActive ? 0.9 : 0.6,
                  ),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _miniLeaderboard(
    GameTheme theme,
    MatchSnapshot snapshot,
    String currentUserId,
  ) {
    final sortedPlayers = List<MatchPlayerState>.from(snapshot.players)
      ..sort((a, b) => b.score.compareTo(a.score));

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sortedPlayers.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final player = sortedPlayers[index];
          final isMe = player.userId == currentUserId;
          final playerColor =
              multiplayerColors[player.playerIndex % multiplayerColors.length];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isMe
                  ? playerColor.withValues(alpha: 0.2)
                  : theme.backgroundColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: player.alive
                    ? playerColor.withValues(alpha: 0.5)
                    : Colors.grey.withValues(alpha: 0.3),
                width: isMe ? 2 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: index == 0 ? Colors.amber : Colors.grey.shade500,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isMe
                          ? 'You'
                          : (player.username.length > 8
                                ? '${player.username.substring(0, 8)}…'
                                : player.username),
                      style: TextStyle(
                        color: player.alive ? theme.accentColor : Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        decoration:
                            player.alive ? null : TextDecoration.lineThrough,
                      ),
                    ),
                    Text(
                      '${player.score} pts',
                      style: TextStyle(
                        color: player.alive
                            ? theme.accentColor.withValues(alpha: 0.7)
                            : Colors.grey,
                        fontSize: 10,
                      ),
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

/// Background pattern painter (matching single-player)
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
