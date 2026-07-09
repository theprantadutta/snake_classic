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
                    return Scaffold(
                      backgroundColor: theme.backgroundColor,
                      body: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.accentColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Starting game...',
                              style: TextStyle(
                                color: theme.accentColor,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
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
                                        // Multiplayer HUD
                                        _buildMultiplayerHUD(
                                          theme,
                                          snapshot,
                                          currentUserId,
                                        ),

                                        // Game hint row
                                        _buildGameHintRow(theme, snapshot),

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

                                        // Bottom info bar
                                        _buildBottomInfoBar(
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

  Widget _buildGameHintRow(GameTheme theme, MatchSnapshot snapshot) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Server game clock (3:00 cap, then higher score wins)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: theme.backgroundColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.foodColor.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.timer_outlined,
                  color: theme.foodColor.withValues(alpha: 0.7),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatGameClock(snapshot.elapsedGameMs),
                  style: TextStyle(
                    color: theme.foodColor.withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Gesture indicator
          AnimatedBuilder(
            animation: _gestureIndicatorController,
            builder: (context, child) {
              final isActive =
                  _lastSwipeDirection != null &&
                  _gestureIndicatorController.isAnimating;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: theme.backgroundColor.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.accentColor.withValues(
                      alpha: isActive ? 0.7 : 0.3,
                    ),
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
          ),
        ],
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

  Widget _buildMultiplayerHUD(
    GameTheme theme,
    MatchSnapshot snapshot,
    String currentUserId,
  ) {
    final me = snapshot.playerByUserId(currentUserId);
    final opponent = snapshot.players
        .where((p) => p.userId != currentUserId)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: _showExitDialog,
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: theme.accentColor,
              size: 22,
            ),
          ),

          const SizedBox(width: 8),

          // Mode indicator with theme-based styling
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.purple.withValues(alpha: 0.3),
                  Colors.amber.withValues(alpha: 0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.purple.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.sports_esports, color: Colors.amber, size: 16),
                SizedBox(width: 6),
                Text(
                  'VS',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Opponent name + score
          if (opponent != null) ...[
            _hudScoreChip(
              theme,
              label: opponent.username,
              score: opponent.score,
              color:
                  multiplayerColors[opponent.playerIndex %
                      multiplayerColors.length],
              alive: opponent.alive,
              connected: opponent.connected,
            ),
            const SizedBox(width: 12),
          ],

          // Your score
          _hudScoreChip(
            theme,
            label: 'You',
            score: me?.score ?? 0,
            color: me != null
                ? multiplayerColors[me.playerIndex % multiplayerColors.length]
                : theme.accentColor,
            alive: me?.alive ?? true,
            connected: true,
            emphasized: true,
          ),
        ],
      ),
    );
  }

  Widget _hudScoreChip(
    GameTheme theme, {
    required String label,
    required int score,
    required Color color,
    required bool alive,
    required bool connected,
    bool emphasized = false,
  }) {
    final display = label.length > 8 ? '${label.substring(0, 8)}…' : label;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: emphasized ? 16 : 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: emphasized ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: alive ? 0.4 : 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: alive ? color : Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            display,
            style: TextStyle(
              color: alive
                  ? theme.accentColor.withValues(alpha: 0.85)
                  : Colors.grey,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              decoration: alive ? null : TextDecoration.lineThrough,
            ),
          ),
          if (!connected) ...[
            const SizedBox(width: 4),
            const Icon(Icons.wifi_off, color: Colors.orange, size: 12),
          ],
          const SizedBox(width: 8),
          Text(
            '$score',
            style: TextStyle(
              color: alive ? theme.accentColor : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: emphasized ? 20 : 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomInfoBar(
    GameTheme theme,
    MatchSnapshot snapshot,
    String currentUserId,
  ) {
    // Sort players by score (descending)
    final sortedPlayers = List<MatchPlayerState>.from(snapshot.players)
      ..sort((a, b) => b.score.compareTo(a.score));
    final mySnake = snapshot.playerByUserId(currentUserId);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(color: theme.accentColor.withValues(alpha: 0.2)),
        ),
      ),
      child: Row(
        children: [
          // Leaderboard
          Expanded(
            child: SizedBox(
              height: 50,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: sortedPlayers.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final player = sortedPlayers[index];
                  final isMe = player.userId == currentUserId;
                  final playerColor =
                      multiplayerColors[player.playerIndex %
                          multiplayerColors.length];

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
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
                        // Rank indicator
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: index == 0
                                ? Colors.amber
                                : Colors.grey.shade400,
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
                        // Player color dot
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: player.alive ? playerColor : Colors.grey,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Name and score
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isMe
                                  ? 'You'
                                  : (player.username.length > 8
                                        ? '${player.username.substring(0, 8)}...'
                                        : player.username),
                              style: TextStyle(
                                color: player.alive
                                    ? theme.accentColor
                                    : Colors.grey,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                decoration: player.alive
                                    ? null
                                    : TextDecoration.lineThrough,
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
            ),
          ),

          const SizedBox(width: 12),

          // Snake length indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.straighten,
                  color: theme.accentColor.withValues(alpha: 0.7),
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  '${mySnake?.body.length ?? 0}',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
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
