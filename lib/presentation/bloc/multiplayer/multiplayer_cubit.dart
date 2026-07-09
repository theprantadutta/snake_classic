import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/multiplayer_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/utils/direction.dart';

import 'multiplayer_state.dart';

export 'multiplayer_state.dart';

/// Cubit for managing multiplayer game state.
///
/// The match itself is server-authoritative: this cubit forwards
/// direction inputs ([changeDirection] → SendInput) and holds the latest
/// engine snapshot in [MultiplayerState.snapshot] for the board to
/// render. It runs no simulation, detects no collisions, and never
/// self-awards score — the only local judgement calls are cosmetic
/// (eat/crash sounds derived from snapshot diffs).
class MultiplayerCubit extends Cubit<MultiplayerState> {
  final MultiplayerService _multiplayerService;
  final UnifiedUserService _userService;
  final AudioService _audioService;
  final HapticService _hapticService;
  final AnalyticsFacade _analytics;
  final CoinsCubit _coinsCubit;
  final BattlePassCubit _battlePassCubit;

  // Stream subscriptions
  StreamSubscription? _gameSubscription;
  StreamSubscription? _actionsSubscription;
  StreamSubscription? _matchmakingSubscription;
  StreamSubscription? _errorSubscription;
  StreamSubscription? _snapshotSubscription;
  StreamSubscription? _matchEndSubscription;

  // Matchmaking timer
  Timer? _matchmakingTimer;
  static const int matchmakingTimeoutSeconds = 60;

  // Start game timeout
  Timer? _startGameTimeoutTimer;

  // Per-match bookkeeping. Everything here is reset by the first
  // snapshot of a match and consumed exactly once by GameEnded — the
  // guards make stats + rewards idempotent even if the hub replays the
  // end event.
  final Stopwatch _matchTimer = Stopwatch();
  bool _matchActive = false;
  bool _matchStatsRecorded = false;
  bool _matchRewardsCredited = false;
  int _lastMyScore = 0;
  bool _myAliveLastTick = true;
  final StatisticsService _statisticsService = StatisticsService();

  MultiplayerCubit({
    required MultiplayerService multiplayerService,
    required UnifiedUserService userService,
    required AudioService audioService,
    required HapticService hapticService,
    required AnalyticsFacade analytics,
    required CoinsCubit coinsCubit,
    required BattlePassCubit battlePassCubit,
  }) : _multiplayerService = multiplayerService,
       _userService = userService,
       _audioService = audioService,
       _hapticService = hapticService,
       _analytics = analytics,
       _coinsCubit = coinsCubit,
       _battlePassCubit = battlePassCubit,
       super(MultiplayerState.initial()) {
    // Start listening to matchmaking stream
    _startMatchmakingListener();
    // Start listening to error stream
    _startErrorListener();
    // Match streams are hub-wide, not per-lobby — subscribe for the
    // cubit's whole lifetime so a resumed match is never missed.
    _startMatchListeners();
  }

  void _startErrorListener() {
    _errorSubscription = _multiplayerService.errorStream.listen((error) {
      _hapticService.heavyImpact();
      _startGameTimeoutTimer?.cancel();
      emit(state.copyWith(errorMessage: error, isLoading: false));
    });
  }

  void _startMatchmakingListener() {
    _matchmakingSubscription = _multiplayerService.matchmakingStream.listen(
      (status) {
        if (status.matchFound && status.gameId != null) {
          // Match found! Stop timer and transition to lobby
          _stopMatchmakingTimer();
          _audioService.playSound('high_score');
          _hapticService.mediumImpact();

          // First emit the status change with clear matchmaking
          // Don't set currentGame here - let the stream listener handle it
          emit(
            state.copyWith(
              status: MultiplayerStatus.inLobby,
              clearMatchmaking: true,
            ),
          );

          // Start listening to game updates
          _startListening();
        } else if (status.error != null) {
          _stopMatchmakingTimer();
          _audioService.playSound('game_over');
          emit(
            state.copyWith(
              status: MultiplayerStatus.error,
              errorMessage: status.error,
              clearMatchmaking: true,
            ),
          );
        } else if (status.isSearching) {
          emit(
            state.copyWith(
              status: MultiplayerStatus.inMatchmaking,
              isMatchmaking: true,
              matchmakingQueuePosition: status.queuePosition,
              matchmakingEstimatedWait: status.estimatedWaitSeconds,
              matchmakingMode: status.mode,
              matchmakingPlayerCount: status.playerCount,
            ),
          );
        }
      },
      onError: (error) {
        _stopMatchmakingTimer();
        emit(
          state.copyWith(
            errorMessage: 'Matchmaking error: $error',
            clearMatchmaking: true,
          ),
        );
      },
    );
  }

  /// Subscribe to the authoritative match streams (tick snapshots +
  /// the GameEnded result).
  void _startMatchListeners() {
    _snapshotSubscription = _multiplayerService.snapshotStream.listen(
      _handleSnapshot,
      onError: (error) {
        if (kDebugMode) {
          print('Snapshot stream error: $error');
        }
      },
    );

    _matchEndSubscription = _multiplayerService.matchEndStream.listen(
      _handleMatchEnd,
      onError: (error) {
        if (kDebugMode) {
          print('Match end stream error: $error');
        }
      },
    );
  }

  /// Get current player from the game
  MultiplayerPlayer? get currentPlayer {
    if (state.currentGame == null) return null;
    final currentUserId = _userService.currentUser?.uid;
    if (currentUserId == null) return null;

    return state.currentGame!.getPlayer(currentUserId);
  }

  /// My side of the latest server snapshot (null outside a live match).
  MatchPlayerState? get mySnapshotPlayer {
    final snapshot = state.snapshot;
    final currentUserId = _userService.currentUser?.uid;
    if (snapshot == null || currentUserId == null) return null;
    return snapshot.playerByUserId(currentUserId);
  }

  /// The opponent's side of the latest server snapshot.
  MatchPlayerState? get opponentSnapshotPlayer {
    final snapshot = state.snapshot;
    final currentUserId = _userService.currentUser?.uid;
    if (snapshot == null || currentUserId == null) return null;
    for (final p in snapshot.players) {
      if (p.userId != currentUserId) return p;
    }
    return null;
  }

  /// Check if current player is host
  /// Host is determined by playerIndex (rank) == 0, not by list order
  bool get isHost {
    if (state.currentGame == null) return false;
    final currentUserId = _userService.currentUser?.uid;
    if (currentUserId == null) return false;

    final currentPlayer = state.currentGame!.getPlayer(currentUserId);
    return currentPlayer?.rank == 0;
  }

  /// Get opponent player
  MultiplayerPlayer? getOpponent() {
    if (state.currentGame == null) return null;
    final currentUserId = _userService.currentUser?.uid;
    if (currentUserId == null) return null;

    final opponents = state.currentGame!.players
        .where((player) => player.userId != currentUserId)
        .toList();

    return opponents.isNotEmpty ? opponents.first : null;
  }

  /// Create a new multiplayer game (1v1 classic room).
  Future<bool> createGame({
    MultiplayerGameMode mode = MultiplayerGameMode.classic,
    int maxPlayers = 2,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      _audioService.playSound('button_click');
      _hapticService.lightImpact();

      final gameId = await _multiplayerService.createGame(
        mode: mode,
        maxPlayers: maxPlayers,
      );

      if (gameId != null) {
        await _startListening();

        _audioService.playSound('high_score');
        _hapticService.mediumImpact();

        emit(
          state.copyWith(status: MultiplayerStatus.inLobby, isLoading: false),
        );
        return true;
      } else {
        _audioService.playSound('game_over');
        _hapticService.heavyImpact();
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage: 'Failed to create game',
          ),
        );
        return false;
      }
    } catch (e) {
      _audioService.playSound('game_over');
      _hapticService.heavyImpact();
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error creating game: $e',
        ),
      );
      return false;
    }
  }

  /// Join a game by room code
  Future<bool> joinGame(String roomCode) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      _audioService.playSound('button_click');
      _hapticService.lightImpact();

      final success = await _multiplayerService.joinGame(roomCode);

      if (success) {
        await _startListening();

        _audioService.playSound('high_score');
        _hapticService.mediumImpact();

        emit(
          state.copyWith(status: MultiplayerStatus.inLobby, isLoading: false),
        );
        return true;
      } else {
        _audioService.playSound('game_over');
        _hapticService.heavyImpact();
        emit(
          state.copyWith(
            isLoading: false,
            errorMessage:
                'Failed to join game. Game might be full or not exist.',
          ),
        );
        return false;
      }
    } catch (e) {
      _audioService.playSound('game_over');
      _hapticService.heavyImpact();
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error joining game: $e',
        ),
      );
      return false;
    }
  }

  /// Leave current game
  Future<void> leaveGame() async {
    try {
      await _multiplayerService.leaveGame();
      _stopListening();
      _matchActive = false;
      _matchTimer.stop();
      emit(
        state.copyWith(
          status: MultiplayerStatus.idle,
          clearGame: true,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error leaving game: $e'));
    }
  }

  /// Mark current player as ready
  Future<bool> markPlayerReady() async {
    try {
      _audioService.playSound('button_click');
      _hapticService.lightImpact();

      final success = await _multiplayerService.markPlayerReady();
      if (success) {
        _audioService.playSound('high_score');
        _hapticService.mediumImpact();
      } else {
        _audioService.playSound('game_over');
        emit(state.copyWith(errorMessage: 'Failed to mark player as ready'));
      }
      return success;
    } catch (e) {
      _audioService.playSound('game_over');
      emit(state.copyWith(errorMessage: 'Error marking player ready: $e'));
      return false;
    }
  }

  /// Send a direction input to the server engine. Fire-and-forget — the
  /// input takes effect on the next tick snapshot; [MultiplayerState.
  /// intentDirection] echoes it locally for immediate input feedback.
  void changeDirection(Direction direction) {
    final snapshot = state.snapshot;
    if (state.status != MultiplayerStatus.playing || snapshot == null) return;

    final currentUserId = _userService.currentUser?.uid;
    if (currentUserId == null) return;

    final me = snapshot.playerByUserId(currentUserId);
    if (me == null || !me.alive) return;

    // Skip obvious reversals against the last committed/intended
    // direction — the server would drop them anyway.
    final reference = state.intentDirection ?? me.direction;
    if (direction == reference.opposite) return;

    _hapticService.lightImpact();
    unawaited(_multiplayerService.sendInput(direction));
    emit(state.copyWith(intentDirection: direction));
  }

  /// Load available games (public room browsing is disabled in the 1v1
  /// release — this keeps the lobby section wired but empty).
  Future<void> loadAvailableGames() async {
    try {
      final games = await _multiplayerService.getAvailableGames();
      emit(
        state.copyWith(status: MultiplayerStatus.idle, availableGames: games),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error loading available games: $e'));
    }
  }

  /// Quick match using matchmaking system
  Future<bool> quickMatch(
    MultiplayerGameMode mode, {
    int playerCount = 2,
  }) async {
    emit(
      state.copyWith(isLoading: true, clearError: true, clearMatchmaking: true),
    );

    try {
      _audioService.playSound('button_click');
      _hapticService.lightImpact();

      await _multiplayerService.joinMatchmaking(
        mode: mode,
        playerCount: playerCount,
      );

      emit(
        state.copyWith(
          status: MultiplayerStatus.inMatchmaking,
          isLoading: false,
          isMatchmaking: true,
          matchmakingMode: mode,
          matchmakingPlayerCount: playerCount,
          matchmakingElapsedSeconds: 0,
          matchmakingTimedOut: false,
        ),
      );

      _analytics.trackMultiplayerQueueJoined();

      // Start the matchmaking timer
      _startMatchmakingTimer();

      return true;
    } catch (e) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Error starting matchmaking: $e',
        ),
      );
      return false;
    }
  }

  /// Start matchmaking countdown timer
  void _startMatchmakingTimer() {
    _stopMatchmakingTimer();

    _matchmakingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final elapsed = timer.tick;

      if (elapsed >= matchmakingTimeoutSeconds) {
        // Timeout reached
        _onMatchmakingTimeout();
      } else {
        // Update elapsed time
        emit(state.copyWith(matchmakingElapsedSeconds: elapsed));
      }
    });
  }

  /// Stop matchmaking timer
  void _stopMatchmakingTimer() {
    _matchmakingTimer?.cancel();
    _matchmakingTimer = null;
  }

  /// Handle matchmaking timeout
  Future<void> _onMatchmakingTimeout() async {
    _stopMatchmakingTimer();

    _audioService.playSound('game_over');
    _hapticService.mediumImpact();

    // Cancel matchmaking on the server
    try {
      await _multiplayerService.leaveMatchmaking();
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving matchmaking after timeout: $e');
      }
    }

    emit(
      state.copyWith(
        status: MultiplayerStatus.idle,
        isMatchmaking: false,
        matchmakingTimedOut: true,
        matchmakingElapsedSeconds: matchmakingTimeoutSeconds,
      ),
    );
  }

  /// Cancel matchmaking
  Future<void> cancelMatchmaking() async {
    _stopMatchmakingTimer();

    try {
      _audioService.playSound('button_click');
      await _multiplayerService.leaveMatchmaking();

      emit(
        state.copyWith(status: MultiplayerStatus.idle, clearMatchmaking: true),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error canceling matchmaking: $e'));
    }
  }

  /// Clear matchmaking timeout state (to dismiss the timeout message)
  void clearMatchmakingTimeout() {
    emit(state.copyWith(matchmakingTimedOut: false, clearMatchmaking: true));
  }

  /// Attempt to reconnect to a game after disconnect
  Future<bool> attemptReconnect() async {
    emit(
      state.copyWith(status: MultiplayerStatus.reconnecting, isLoading: true),
    );

    try {
      final success = await _multiplayerService.attemptReconnect();

      if (success) {
        _audioService.playSound('high_score');
        _hapticService.mediumImpact();

        await _startListening();

        // The MatchResumed snapshot (or ReconnectFailed) that follows
        // settles the real status; playing is the optimistic default.
        emit(
          state.copyWith(status: MultiplayerStatus.playing, isLoading: false),
        );
        return true;
      } else {
        _audioService.playSound('game_over');
        emit(
          state.copyWith(
            status: MultiplayerStatus.idle,
            isLoading: false,
            errorMessage: 'Could not reconnect to game',
          ),
        );
        return false;
      }
    } catch (e) {
      emit(
        state.copyWith(
          status: MultiplayerStatus.idle,
          isLoading: false,
          errorMessage: 'Reconnection failed: $e',
        ),
      );
      return false;
    }
  }

  /// Utility methods for UI
  String getPlayerDisplayName(String userId) {
    final player = state.currentGame?.players
        .where((p) => p.userId == userId)
        .toList()
        .firstOrNull;
    return player?.publicLabel ?? 'Unknown Player';
  }

  /// Winner display name
  String? get winner {
    if (state.currentGame?.winnerId == null) return null;
    return getPlayerDisplayName(state.currentGame!.winnerId!);
  }

  /// Check if game is ready to start (all players ready)
  bool get isReadyToStart => state.currentGame?.canStart ?? false;

  /// Check if game is actively playing
  bool get isGameActive =>
      state.currentGame?.status == MultiplayerGameStatus.playing;

  /// Check if game is finished
  bool get isGameFinished => state.currentGame?.isFinished ?? false;

  /// Get formatted room code for display (XXX-XXX format)
  String? get formattedRoomCode {
    final code = _multiplayerService.currentRoomCode;
    if (code == null) return null;

    // Format as XXX-XXX
    if (code.length == 6) {
      return '${code.substring(0, 3)}-${code.substring(3)}';
    }
    return code;
  }

  /// Get raw room code
  String? get roomCode => _multiplayerService.currentRoomCode;

  /// Get game duration since start
  Duration? get gameDuration {
    if (state.currentGame?.startedAt == null) return null;
    return DateTime.now().difference(state.currentGame!.startedAt!);
  }

  /// Start the game (host only)
  Future<bool> startGame() async {
    if (!isHost) return false;

    // Show loading state
    emit(state.copyWith(isLoading: true));

    try {
      _audioService.playSound('game_start');
      _hapticService.mediumImpact();

      final success = await _multiplayerService.startGame();
      if (success) {
        _analytics.trackMultiplayerGameStarted();
      }
      if (!success) {
        emit(
          state.copyWith(
            errorMessage: 'Failed to start game',
            isLoading: false,
          ),
        );
        return false;
      }

      // Set timeout - if no GameStarting received in 5 seconds, show error
      _startGameTimeoutTimer?.cancel();
      _startGameTimeoutTimer = Timer(const Duration(seconds: 5), () {
        if (state.isLoading && state.status != MultiplayerStatus.playing) {
          emit(
            state.copyWith(
              errorMessage: 'Start game timed out. Please try again.',
              isLoading: false,
            ),
          );
        }
      });

      return success;
    } catch (e) {
      emit(
        state.copyWith(
          errorMessage: 'Error starting game: $e',
          isLoading: false,
        ),
      );
      return false;
    }
  }

  /// Clear error message
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Private helper methods
  Future<void> _startListening() async {
    _stopListening();

    // Listen to game updates
    _gameSubscription = _multiplayerService.gameStream.listen(
      (game) {
        if (game == null) return;
        _applyGameUpdate(game);
      },
      onError: (error) {
        emit(state.copyWith(errorMessage: 'Game stream error: $error'));
      },
    );

    // Listen to game actions
    _actionsSubscription = _multiplayerService.gameActionsStream.listen(
      (action) {
        _handleGameAction(action);
      },
      onError: (error) {
        if (kDebugMode) {
          print('Game actions stream error: $error');
        }
      },
    );

    // Immediately emit the current game state (since broadcast streams don't replay)
    final currentGame = _multiplayerService.currentGame;
    if (currentGame != null) {
      _applyGameUpdate(currentGame);
    }
  }

  /// Fold a lobby-level game update into the cubit state.
  void _applyGameUpdate(MultiplayerGame game) {
    MultiplayerStatus newStatus = state.status;
    bool shouldClearLoading = false;

    if (game.status == MultiplayerGameStatus.starting) {
      // Game is starting (countdown) - clear loading state
      shouldClearLoading = true;
      _startGameTimeoutTimer?.cancel();
    } else if (game.status == MultiplayerGameStatus.playing) {
      newStatus = MultiplayerStatus.playing;
      shouldClearLoading = true;
      _startGameTimeoutTimer?.cancel();
    } else if (game.isFinished) {
      // Stats + rewards ride on the GameEnded payload (matchEndStream),
      // not on this status flip.
      newStatus = MultiplayerStatus.finished;
      shouldClearLoading = true;
    } else if (game.status == MultiplayerGameStatus.waiting) {
      newStatus = MultiplayerStatus.inLobby;
    }

    emit(
      state.copyWith(
        status: newStatus,
        currentGame: game,
        isLoading: shouldClearLoading ? false : null,
      ),
    );
  }

  /// Fold an authoritative snapshot into the state. The first snapshot
  /// of a match resets the per-match bookkeeping and starts the
  /// fallback duration stopwatch.
  void _handleSnapshot(MatchSnapshot snapshot) {
    if (!_matchActive) {
      _matchActive = true;
      _matchStatsRecorded = false;
      _matchRewardsCredited = false;
      _lastMyScore = 0;
      _myAliveLastTick = true;
      _matchTimer
        ..reset()
        ..start();
    }

    // Cosmetic snapshot-diff feedback: eat chirp on my score rising,
    // crash feedback the tick my snake dies. Purely presentational —
    // the server already settled the outcome.
    final currentUserId = _userService.currentUser?.uid;
    final me = currentUserId != null
        ? snapshot.playerByUserId(currentUserId)
        : null;
    if (me != null) {
      if (me.score > _lastMyScore) {
        _audioService.playSound('eat');
        _hapticService.lightImpact();
      }
      if (_myAliveLastTick && !me.alive) {
        _audioService.playSound('game_over');
        _hapticService.heavyImpact();
      }
      _lastMyScore = me.score;
      _myAliveLastTick = me.alive;
    }

    emit(
      state.copyWith(
        status: MultiplayerStatus.playing,
        snapshot: snapshot,
        boardSize: _multiplayerService.boardSize,
        isLoading: false,
      ),
    );
  }

  /// Handle the server's GameEnded verdict: record stats, credit
  /// rewards (both guarded to fire once per match), and surface the
  /// result to the screen.
  void _handleMatchEnd(MatchEndResult result) {
    _startGameTimeoutTimer?.cancel();
    if (_matchTimer.isRunning) _matchTimer.stop();

    final currentUserId = _userService.currentUser?.uid;
    final won = currentUserId != null && result.isWinner(currentUserId);
    final myResult = currentUserId != null
        ? result.playerByUserId(currentUserId)
        : null;

    if (won) {
      _audioService.playSound('level_up');
      _hapticService.heavyImpact();
    } else {
      _audioService.playSound('game_over');
      _hapticService.mediumImpact();
    }
    _analytics.trackMultiplayerGameEnded(
      score: myResult?.score ?? 0,
      result: won ? 'win' : (result.isDraw ? 'draw' : 'loss'),
    );

    _recordMatchStats(myResult);
    _creditMatchRewards(result, won);

    _matchActive = false;
    emit(
      state.copyWith(
        status: MultiplayerStatus.finished,
        matchEnd: result,
        isLoading: false,
      ),
    );
  }

  /// Record a finished multiplayer match into the per-user statistics,
  /// entirely from server-reported values (score, foods eaten, death
  /// reason). Duration prefers the snapshot's game clock over the local
  /// stopwatch. Idempotent within a single match.
  void _recordMatchStats(MatchEndPlayer? me) {
    if (_matchStatsRecorded || me == null) return;
    _matchStatsRecorded = true;

    final gameTimeSeconds = state.snapshot != null
        ? state.snapshot!.elapsedGameMs ~/ 1000
        : _matchTimer.elapsed.inSeconds;

    final wallHits = me.deathReason == 'wall' ? 1 : 0;
    // self / opponent / head_on all bucket into selfHits — statistics
    // has no "other snake" column and multiplayer walls are always on.
    final selfHits = (!me.alive && wallHits == 0) ? 1 : 0;

    _statisticsService.recordGameResult(
      score: me.score,
      gameTime: gameTimeSeconds,
      level: 1,
      foodConsumed: me.foodsEaten,
      foodTypes: {'apple': me.foodsEaten},
      foodPoints: me.score,
      powerUpsCollected: 0,
      powerUpTypes: const <String, int>{},
      powerUpTime: 0,
      wallHits: wallHits,
      selfHits: selfHits,
      isPerfectGame: me.alive && gameTimeSeconds >= 30,
      unlockedAchievements: const [],
      // Not a GameMode enum value on purpose — multiplayer matches must
      // not count toward the per-mode / mode-exploration achievements.
      gameMode: 'multiplayer',
    );
  }

  /// Credit end-of-match rewards through the standard economy paths:
  /// the winner earns the server-announced coin amount via CoinsCubit
  /// (caps/animations/sync apply) and both sides earn battle-pass XP
  /// via the usual buffer→flush flow. Guarded to run once per match.
  void _creditMatchRewards(MatchEndResult result, bool won) {
    if (_matchRewardsCredited) return;
    _matchRewardsCredited = true;

    if (won && result.winnerCoinReward > 0) {
      unawaited(
        _coinsCubit.earnCoins(
          CoinEarningSource.multiplayer,
          customAmount: result.winnerCoinReward,
          itemName: 'Multiplayer Victory',
        ),
      );
    }

    final xpKey = won ? 'multiplayer_win' : 'multiplayer_participation';
    final xp = BattlePassXpSource.getXpForAction(xpKey);
    if (xp > 0) {
      _battlePassCubit.bufferXP(xp, source: xpKey);
    }
    unawaited(_battlePassCubit.flushXP());
  }

  void _stopListening() {
    _gameSubscription?.cancel();
    _actionsSubscription?.cancel();
    _gameSubscription = null;
    _actionsSubscription = null;
  }

  void _stopMatchmakingListener() {
    _matchmakingSubscription?.cancel();
    _matchmakingSubscription = null;
  }

  void _handleGameAction(MultiplayerGameAction action) {
    if (kDebugMode) {
      print('Received action: ${action.actionType} from ${action.playerId}');
    }
    // Actions are already reflected in the game state
  }

  @override
  Future<void> close() {
    _stopListening();
    _stopMatchmakingListener();
    _stopMatchmakingTimer();
    _startGameTimeoutTimer?.cancel();
    _errorSubscription?.cancel();
    _snapshotSubscription?.cancel();
    _matchEndSubscription?.cancel();
    _multiplayerService.dispose();
    return super.close();
  }
}
