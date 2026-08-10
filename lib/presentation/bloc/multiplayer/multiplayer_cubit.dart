import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/multiplayer_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/logger.dart';

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

  /// Shared end-of-game rewards/stats pipeline (same instance the
  /// single-player GameCubit uses) — keeps reward rules in one place.
  final MultiplayerSettlementService _settlementService;
  StreamSubscription<MultiplayerSettlement>? _settlementSubscription;

  /// The game whose settlement the result screen is waiting on. Captured at
  /// match end because a settlement being repaired in the background belongs
  /// to a different match and must not relabel this one.
  String? _settlingGameId;

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

  // Reconnect settle timeout (see _startReconnectTimeout)
  Timer? _reconnectTimeoutTimer;

  /// Ticks the visible READY deadline in a matchmade lobby.
  Timer? _readyDeadlineTimer;

  /// Watches the gap between GameStarting and GameStarted.
  Timer? _countdownWatchdog;

  /// How long two matched strangers get to both confirm READY.
  static const int _readyDeadlineSeconds = 30;

  /// Whether the current/last session came from quick match — drives the
  /// "Play Again" re-queue action on the result screen.
  bool _quickMatchSession = false;
  bool get lastMatchWasQuickMatch => _quickMatchSession;

  // Per-match bookkeeping. Everything here is reset by the first
  // snapshot of a match and consumed exactly once by GameEnded — the
  // guards make stats + rewards idempotent even if the hub replays the
  // end event.
  final Stopwatch _matchTimer = Stopwatch();
  bool _matchActive = false;
  int _lastMyScore = 0;
  bool _myAliveLastTick = true;

  MultiplayerCubit({
    required this._multiplayerService,
    required this._userService,
    required this._audioService,
    required this._hapticService,
    required this._analytics,
    required this._settlementService,
  }) : super(MultiplayerState.initial()) {
    // Start listening to matchmaking stream
    _startMatchmakingListener();
    // Start listening to error stream
    _startErrorListener();
    // Match streams are hub-wide, not per-lobby — subscribe for the
    // cubit's whole lifetime so a resumed match is never missed.
    _startMatchListeners();
    // Settlements can land long after the match — a retry, a reconnect, the
    // next launch — so this listens for the cubit's whole lifetime too.
    _startSettlementListener();
  }

  /// Reflect an applied settlement into the result screen, replacing
  /// "processing" with what the server actually awarded.
  void _startSettlementListener() {
    _settlementSubscription =
        _settlementService.appliedStream.listen((settlement) {
      // Only the settlement for the match currently on screen. An older one
      // being repaired in the background must not relabel this result.
      if (_settlingGameId != null && settlement.gameId != _settlingGameId) {
        return;
      }
      emit(state.copyWith(
        settlementStatus: SettlementStatus.applied,
        settlement: settlement,
      ));
    });
  }

  void _startErrorListener() {
    _errorSubscription = _multiplayerService.errorStream.listen((error) {
      _hapticService.heavyImpact();
      _startGameTimeoutTimer?.cancel();
      emit(state.copyWith(errorCode: error, isLoading: false));
    });
  }

  void _startMatchmakingListener() {
    _matchmakingSubscription = _multiplayerService.matchmakingStream.listen(
      (status) {
        if (status.matchFound && status.gameId != null) {
          // Match found! Stop timer and transition to lobby
          _stopMatchmakingTimer();
          _startReadyDeadline();
          _audioService.playSound('high_score');
          _hapticService.mediumImpact();

          // First emit the status change with clear matchmaking
          // Don't set currentGame here - let the stream listener handle it
          emit(
            state.copyWith(
              status: MultiplayerStatus.inLobby,
              isMatchmadeLobby: true,
              readyDeadlineSeconds: _readyDeadlineSeconds,
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
              errorCode: status.error,
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
        AppLogger.error('Matchmaking stream error', error);
        emit(
          state.copyWith(
            errorCode: MultiplayerError.matchmaking,
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
      _quickMatchSession = false;
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
            errorCode: MultiplayerError.createFailed,
          ),
        );
        return false;
      }
    } catch (e) {
      _audioService.playSound('game_over');
      _hapticService.heavyImpact();
      AppLogger.error('Error creating game', e);
      emit(
        state.copyWith(
          isLoading: false,
          errorCode: MultiplayerError.createFailed,
        ),
      );
      return false;
    }
  }

  /// Join a game by room code
  Future<bool> joinGame(String roomCode) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      _quickMatchSession = false;
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
            errorCode: MultiplayerError.joinFailed,
          ),
        );
        return false;
      }
    } catch (e) {
      _audioService.playSound('game_over');
      _hapticService.heavyImpact();
      AppLogger.error('Error joining game', e);
      emit(
        state.copyWith(
          isLoading: false,
          errorCode: MultiplayerError.joinFailed,
        ),
      );
      return false;
    }
  }

  /// Leave current game
  Future<void> leaveGame() async {
    try {
      // Stop the lobby timers before the room goes away — otherwise the
      // ready deadline keeps ticking against a game that no longer exists
      // and eventually tries to abandon it a second time.
      _stopReadyDeadline();
      _stopCountdownWatchdog();
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
      AppLogger.error('Error leaving game', e);
      emit(state.copyWith(errorCode: MultiplayerError.generic));
    }
  }

  /// Set the current player's ready flag. Toggling back to not-ready is
  /// allowed while the room is still waiting (SetReady carries the bool).
  Future<bool> markPlayerReady({bool isReady = true}) async {
    try {
      _audioService.playSound('button_click');
      _hapticService.lightImpact();

      final success = await _multiplayerService.markPlayerReady(
        isReady: isReady,
      );
      if (success) {
        if (isReady) {
          _audioService.playSound('high_score');
          _hapticService.mediumImpact();
        }
      } else {
        _audioService.playSound('game_over');
        emit(state.copyWith(errorCode: MultiplayerError.readyFailed));
      }
      return success;
    } catch (e) {
      _audioService.playSound('game_over');
      AppLogger.error('Error updating ready status', e);
      emit(state.copyWith(errorCode: MultiplayerError.readyFailed));
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

    // Same-direction dedupe: repeated identical swipes and keyboard
    // auto-repeat would each cost a hub message for a no-op.
    if (direction == state.intentDirection) return;

    // Skip obvious reversals against the last committed/intended
    // direction — the server would drop them anyway.
    final reference = state.intentDirection ?? me.direction;
    if (direction == reference.opposite) return;

    _hapticService.lightImpact();
    unawaited(_multiplayerService.sendInput(direction));
    emit(state.copyWith(intentDirection: direction));
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
      _quickMatchSession = true;
      _audioService.playSound('button_click');
      _hapticService.lightImpact();

      // The service's answer is now load-bearing. It used to be discarded,
      // so a hub that was never connected still put the UI into "searching"
      // — a queue the server had no idea about, counting down to a timeout
      // that could never have been anything else.
      final joined = await _multiplayerService.joinMatchmaking(
        mode: mode,
        playerCount: playerCount,
      );
      if (!joined) {
        emit(
          state.copyWith(
            isLoading: false,
            errorCode: MultiplayerError.matchmaking,
          ),
        );
        return false;
      }

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
      AppLogger.error('Error starting matchmaking', e);
      emit(
        state.copyWith(
          isLoading: false,
          errorCode: MultiplayerError.matchmaking,
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
      AppLogger.error('Error canceling matchmaking', e);
      emit(state.copyWith(errorCode: MultiplayerError.generic));
    }
  }

  /// From the result screen: dump the finished room and immediately
  /// re-queue for another quick match.
  Future<void> queueAgain() async {
    await leaveGame();
    await quickMatch(MultiplayerGameMode.classic);
  }

  /// Clear matchmaking timeout state (to dismiss the timeout message)
  void clearMatchmakingTimeout() {
    emit(state.copyWith(matchmakingTimedOut: false, clearMatchmaking: true));
  }

  /// Attempt to reconnect to a game after disconnect. Stays in
  /// [MultiplayerStatus.reconnecting] until the server settles it: a
  /// MatchResumed/Tick snapshot or a lobby game update flips us back,
  /// ReconnectFailed (or the local timeout below) gives up.
  Future<bool> attemptReconnect() async {
    emit(
      state.copyWith(status: MultiplayerStatus.reconnecting, isLoading: true),
    );

    try {
      final success = await _multiplayerService.attemptReconnect();

      if (success) {
        await _startListening();
        _startReconnectTimeout();
        return true;
      } else {
        _audioService.playSound('game_over');
        _giveUpOnMatch(MultiplayerError.reconnectFailed);
        return false;
      }
    } catch (e) {
      AppLogger.error('Error attempting reconnect', e);
      _giveUpOnMatch(MultiplayerError.reconnectFailed);
      return false;
    }
  }

  /// If nothing settles a pending reconnect (no snapshot, no game
  /// update, no ReconnectFailed), stop waiting instead of leaving the
  /// player on a frozen board forever.
  void _startReconnectTimeout() {
    _reconnectTimeoutTimer?.cancel();
    _reconnectTimeoutTimer = Timer(const Duration(seconds: 12), () {
      if (state.status == MultiplayerStatus.reconnecting) {
        _giveUpOnMatch(MultiplayerError.connectionLost);
      }
    });
  }

  void _cancelReconnectTimeout() {
    _reconnectTimeoutTimer?.cancel();
    _reconnectTimeoutTimer = null;
  }

  /// Terminal exit from a match we can no longer reach: clear the match
  /// state and surface an error code. The game screen reacts to the
  /// status change by returning to the lobby.
  void _giveUpOnMatch(MultiplayerError code) {
    _cancelReconnectTimeout();
    _matchActive = false;
    if (_matchTimer.isRunning) _matchTimer.stop();
    emit(
      state.copyWith(
        status: MultiplayerStatus.idle,
        isLoading: false,
        clearGame: true,
        errorCode: code,
      ),
    );
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
            errorCode: MultiplayerError.startFailed,
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
              errorCode: MultiplayerError.startTimeout,
              isLoading: false,
            ),
          );
        }
      });

      return success;
    } catch (e) {
      AppLogger.error('Error starting game', e);
      emit(
        state.copyWith(
          errorCode: MultiplayerError.startFailed,
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
        AppLogger.error('Game stream error', error);
        emit(state.copyWith(errorCode: MultiplayerError.generic));
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
    // Any game update means the connection is alive again (e.g. the
    // ReconnectSuccess state replay) — a pending reconnect has settled.
    _cancelReconnectTimeout();
    MultiplayerStatus newStatus = state.status;
    bool shouldClearLoading = false;

    if (game.status == MultiplayerGameStatus.starting) {
      // Game is starting (countdown) - clear loading state
      shouldClearLoading = true;
      _startGameTimeoutTimer?.cancel();
      _stopReadyDeadline();
      _startCountdownWatchdog();
    } else if (game.status == MultiplayerGameStatus.playing) {
      newStatus = MultiplayerStatus.playing;
      shouldClearLoading = true;
      _startGameTimeoutTimer?.cancel();
      _stopReadyDeadline();
      _stopCountdownWatchdog();
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

    // The lobby no longer starts itself. Both players press READY and the
    // host presses START — see _startReadyDeadline for why a matchmade
    // lobby still cannot sit here forever.
  }

  /// Arm the matchmade READY deadline.
  ///
  /// A matchmade lobby used to skip the ready check entirely: the server
  /// created both player rows pre-ready and the host auto-started, so a
  /// player was dropped into a live match having pressed nothing. Both
  /// halves of that are gone, which restores consent but reintroduces the
  /// problem auto-ready existed to dodge — two strangers, either of whom
  /// may simply walk away, with no way to talk to each other.
  ///
  /// So the check is bounded. Thirty seconds, counted down visibly, and if
  /// both sides have not confirmed by then the room is abandoned and
  /// whoever is still here goes back to the queue to find someone else.
  /// Nobody is stranded, and nobody is force-started into a match.
  void _startReadyDeadline() {
    _readyDeadlineTimer?.cancel();
    _readyDeadlineTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      final remaining = (state.readyDeadlineSeconds ?? 0) - 1;
      if (remaining > 0) {
        emit(state.copyWith(readyDeadlineSeconds: remaining));
        return;
      }
      _stopReadyDeadline();
      unawaited(_abandonUnreadyLobby());
    });
  }

  void _stopReadyDeadline() {
    _readyDeadlineTimer?.cancel();
    _readyDeadlineTimer = null;
  }

  /// Watch the gap between GameStarting and GameStarted.
  ///
  /// The server runs its 3s countdown inside a fire-and-forget `Task.Run`
  /// and only then flips the match to Playing. If that task dies — process
  /// recycle, an unhandled throw — no GameStarted is ever broadcast and
  /// both clients sit on the countdown overlay forever, because the
  /// existing start timeout was already cancelled the moment GameStarting
  /// arrived. This covers the second half of that handoff.
  ///
  /// Generous on purpose: the countdown the server announced, plus seven
  /// seconds for the engine to spin the room up and the snapshot to land.
  /// It is a last resort against a hang, not a latency budget.
  void _startCountdownWatchdog() {
    _countdownWatchdog?.cancel();
    _countdownWatchdog = Timer(
      Duration(seconds: state.countdownSeconds + 7),
      () {
        if (state.status == MultiplayerStatus.playing) return;
        emit(
          state.copyWith(
            errorCode: MultiplayerError.startTimeout,
            isLoading: false,
          ),
        );
      },
    );
  }

  void _stopCountdownWatchdog() {
    _countdownWatchdog?.cancel();
    _countdownWatchdog = null;
  }

  /// Deadline expired with someone still unready: leave the room and stop.
  ///
  /// This used to requeue automatically, on the reasoning that from the
  /// player's side nothing had gone wrong — they asked for a match and were
  /// still waiting. That reasoning holds only when requeueing has a chance of
  /// working. With an opponent that could never become ready it produced an
  /// unbreakable cycle of thirty-second lobbies, and the player had no way to
  /// tell that anything was wrong, because each requeue also cleared the
  /// error that would have explained it.
  ///
  /// So it surfaces the reason and stops. Searching again is one tap, and it
  /// is the player's tap — which also means an idle app cannot sit there
  /// queueing against the server indefinitely.
  Future<void> _abandonUnreadyLobby() async {
    try {
      await leaveGame();
    } catch (_) {
      // Leaving is best-effort: the room is being abandoned either way,
      // and the server drops an unready Waiting room on disconnect.
    }

    emit(
      state.copyWith(
        status: MultiplayerStatus.idle,
        errorCode: MultiplayerError.readyTimeout,
        clearGame: true,
        clearReadyDeadline: true,
        isMatchmaking: false,
      ),
    );
  }

  /// Fold an authoritative snapshot into the state. The first snapshot
  /// of a match resets the per-match bookkeeping and starts the
  /// fallback duration stopwatch.
  void _handleSnapshot(MatchSnapshot snapshot) {
    if (!_matchActive) {
      _matchActive = true;
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

    // A snapshot settles any pending reconnect and expires the local
    // input echo: each tick commits at most one input, so the committed
    // direction is the fresh reversal reference. Without this, an input
    // the server dropped left a stale intent that blocked its opposite
    // forever.
    _cancelReconnectTimeout();
    emit(
      state.copyWith(
        status: MultiplayerStatus.playing,
        snapshot: snapshot,
        boardSize: _multiplayerService.boardSize,
        isLoading: false,
        clearIntentDirection: true,
      ),
    );
  }

  /// Handle the server's GameEnded verdict: record stats, credit
  /// rewards (both guarded to fire once per match), and surface the
  /// result to the screen.
  void _handleMatchEnd(MatchEndResult result) {
    _startGameTimeoutTimer?.cancel();
    _stopCountdownWatchdog();
    _stopReadyDeadline();
    _cancelReconnectTimeout();
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

    // Rewards and statistics are NOT applied from this broadcast any more.
    // They come from the server's settlement for this match, fetched here and
    // repaired on the next launch if this fetch fails — which is the whole
    // point: a socket that died a second earlier used to lose them outright,
    // with nothing anywhere recording that anything was owed.
    // Rewards are shown as processing until the settlement lands. The fetch
    // retries on its own (backoff, connectivity, next launch), so a failure
    // here is a delay rather than a loss.
    unawaited(_settlementService.syncPending());

    _matchActive = false;
    _settlingGameId = _multiplayerService.currentGameId;
    emit(
      state.copyWith(
        status: MultiplayerStatus.finished,
        matchEnd: result,
        isLoading: false,
        settlementStatus: SettlementStatus.processing,
      ),
    );
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

    switch (action.actionType) {
      // Server announces the countdown length in GameStarting; feed it
      // to the lobby overlay so a server-side tuning change can't drift.
      case 'game_starting':
        final seconds =
            (action.data['countdown_seconds'] as num?)?.toInt() ?? 3;
        emit(state.copyWith(countdownSeconds: seconds));
        break;

      // The transport gave up (auto-reconnect exhausted or hard drop).
      // Only mid-match does this need active recovery — the lobby
      // reconnects lazily on the next user action.
      case 'connection_lost':
        if (state.status == MultiplayerStatus.playing ||
            state.status == MultiplayerStatus.reconnecting) {
          unawaited(attemptReconnect());
        }
        break;

      // The server revalidated the room when the countdown expired and
      // refused to start it — someone left, dropped, or un-readied in those
      // three seconds. Before the server had this check the match started
      // anyway and the client sat on a countdown overlay that never resolved.
      case 'countdown_cancelled':
        _stopCountdownWatchdog();
        _stopReadyDeadline();
        emit(
          state.copyWith(
            status: MultiplayerStatus.idle,
            errorCode: MultiplayerError.startFailed,
            isLoading: false,
            clearGame: true,
            clearReadyDeadline: true,
          ),
        );
        break;

      // The server refused the reconnect (match ended, window expired,
      // or the room is gone). Without this, the player stayed on a
      // frozen board forever.
      case 'reconnect_failed':
        if (state.status == MultiplayerStatus.playing ||
            state.status == MultiplayerStatus.reconnecting) {
          _giveUpOnMatch(MultiplayerError.matchEndedAway);
        }
        break;

      // Opponent presence changes render from the per-player `connected`
      // flag in each snapshot; reconnect_success is followed by the
      // game-state replay which _applyGameUpdate folds in.
      default:
        break;
    }
  }

  @override
  Future<void> close() {
    _stopListening();
    _stopMatchmakingListener();
    _stopMatchmakingTimer();
    _startGameTimeoutTimer?.cancel();
    _stopReadyDeadline();
    _stopCountdownWatchdog();
    _reconnectTimeoutTimer?.cancel();
    _errorSubscription?.cancel();
    _snapshotSubscription?.cancel();
    _matchEndSubscription?.cancel();
    _settlementSubscription?.cancel();
    _multiplayerService.dispose();
    return super.close();
  }
}
