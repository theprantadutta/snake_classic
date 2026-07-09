import 'dart:async';

import 'package:signalr_netcore/signalr_client.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/logger.dart';

/// Matchmaking status snapshot consumed by the multiplayer cubit.
class MatchmakingStatus {
  final bool isSearching;
  final int queuePosition;
  final int estimatedWaitSeconds;
  final bool matchFound;
  final String? gameId;
  final String? roomCode;
  final int? playerIndex;
  final String? error;
  final MultiplayerGameMode? mode;
  final int? playerCount;

  const MatchmakingStatus({
    this.isSearching = false,
    this.queuePosition = 0,
    this.estimatedWaitSeconds = 0,
    this.matchFound = false,
    this.gameId,
    this.roomCode,
    this.playerIndex,
    this.error,
    this.mode,
    this.playerCount,
  });
}

/// Live 1v1 multiplayer transport: REST for room create/join (the hub
/// requires the player row to exist first) + a SignalR connection for
/// everything real-time.
///
/// The server is authoritative for the match itself. This service sends
/// nothing but direction tokens ([sendInput]) once a match is running and
/// renders whatever the engine broadcasts: `GameStarted` / `Tick` /
/// `MatchResumed` snapshots stream out on [snapshotStream], the final
/// `GameEnded` result on [matchEndStream]. There is no client-side move
/// relay, food generation, or game-end detection anymore.
///
/// Multiplayer is deliberately exempt from the offline-first doctrine —
/// a live match is inherently online, so direct REST + hub calls are
/// correct here.
class MultiplayerService {
  static MultiplayerService? _instance;
  final ApiService _apiService = ApiService();

  // SignalR connection
  HubConnection? _hubConnection;
  bool _isConnected = false;

  // Current game state
  MultiplayerGame? _currentGame;
  String? _currentGameId;
  String? _currentRoomCode;
  int _boardSize = 20;

  // Matchmaking state
  bool _isInMatchmaking = false;
  int _matchmakingQueuePosition = 0;
  int _matchmakingEstimatedWait = 0;

  // Heartbeat timer
  Timer? _heartbeatTimer;
  static const int _heartbeatIntervalSeconds = 10;

  // Reconnection state
  bool _isReconnecting = false;

  // Stream controllers for game events
  final _gameStreamController = StreamController<MultiplayerGame?>.broadcast();
  final _gameActionsController =
      StreamController<MultiplayerGameAction>.broadcast();
  final _matchmakingStreamController =
      StreamController<MatchmakingStatus>.broadcast();
  final _errorController = StreamController<String>.broadcast();
  final _snapshotController = StreamController<MatchSnapshot>.broadcast();
  final _matchEndController = StreamController<MatchEndResult>.broadcast();

  MultiplayerService._internal();

  factory MultiplayerService() {
    _instance ??= MultiplayerService._internal();
    return _instance!;
  }

  // Current game getters
  MultiplayerGame? get currentGame => _currentGame;
  String? get currentGameId => _currentGameId;
  String? get currentRoomCode => _currentRoomCode;
  bool get isInGame => _currentGame != null;
  bool get isConnected => _isConnected;

  /// Board size announced by GameStarted (the engine is 20x20 in this
  /// build, but the wire carries it so this never hardcodes).
  int get boardSize => _boardSize;

  // Matchmaking getters
  bool get isInMatchmaking => _isInMatchmaking;
  int get matchmakingQueuePosition => _matchmakingQueuePosition;
  int get matchmakingEstimatedWait => _matchmakingEstimatedWait;

  /// Stream of current game updates (lobby membership / status).
  Stream<MultiplayerGame?> get gameStream => _gameStreamController.stream;

  /// Stream of discrete lobby/connection events.
  Stream<MultiplayerGameAction> get gameActionsStream =>
      _gameActionsController.stream;

  /// Stream of matchmaking status updates.
  Stream<MatchmakingStatus> get matchmakingStream =>
      _matchmakingStreamController.stream;

  /// Stream of error messages for UI display.
  Stream<String> get errorStream => _errorController.stream;

  /// Authoritative match snapshots (GameStarted / Tick / MatchResumed).
  Stream<MatchSnapshot> get snapshotStream => _snapshotController.stream;

  /// The parsed GameEnded payload, exactly once per match.
  Stream<MatchEndResult> get matchEndStream => _matchEndController.stream;

  /// Create a new multiplayer game (room). 1v1 classic only in this
  /// release — the lobby hardcodes the arguments, the defaults just
  /// keep call sites honest.
  Future<String?> createGame({
    MultiplayerGameMode mode = MultiplayerGameMode.classic,
    int maxPlayers = 2,
  }) async {
    try {
      final response = await _apiService.createMultiplayerGame(
        mode: mode.name,
        maxPlayers: maxPlayers,
      );
      if (response == null) return null;

      final gameId = response['game_id'] ?? response['id'];
      final roomCode = response['room_code'];
      if (gameId == null || roomCode == null) return null;

      _currentGameId = gameId.toString();
      _currentRoomCode = roomCode.toString();
      _seedLobbyGame(mode: mode, maxPlayers: maxPlayers);

      // Connect to SignalR and join the room — the hub replays every
      // existing player (including ourselves) as PlayerJoined events,
      // which populate the seeded game.
      await _connectSignalR();
      await _joinRoom(_currentRoomCode!);

      return _currentGameId;
    } catch (e) {
      AppLogger.error('Error creating multiplayer game', e);
      return null;
    }
  }

  /// Join a game by room code.
  Future<bool> joinGame(String roomCode) async {
    try {
      final normalized = roomCode.replaceAll('-', '').toUpperCase();
      final response = await _apiService.joinMultiplayerGame(normalized);
      if (response == null) return false;

      final gameId = response['game_id'] ?? response['id'];
      if (gameId == null) return false;

      _currentGameId = gameId.toString();
      _currentRoomCode = normalized;
      _seedLobbyGame(mode: MultiplayerGameMode.classic, maxPlayers: 2);

      await _connectSignalR();
      await _joinRoom(_currentRoomCode!);

      return true;
    } catch (e) {
      AppLogger.error('Error joining multiplayer game', e);
      return false;
    }
  }

  /// Leave the current game and tear the connection down.
  Future<void> leaveGame() async {
    try {
      if (_currentRoomCode != null && _isConnected) {
        await _hubConnection?.invoke('LeaveRoom', args: [_currentRoomCode!]);
      }
    } catch (e) {
      AppLogger.error('Error leaving game', e);
    } finally {
      await _disconnectSignalR();
      _currentGame = null;
      _currentGameId = null;
      _currentRoomCode = null;
      _boardSize = 20;
      _gameStreamController.add(null);
    }
  }

  /// Mark player as ready.
  Future<bool> markPlayerReady({bool isReady = true}) async {
    try {
      if (_currentRoomCode == null) return false;
      await _hubConnection?.invoke(
        'SetReady',
        args: [_currentRoomCode!, isReady],
      );
      return true;
    } catch (e) {
      AppLogger.error('Error marking player ready', e);
      return false;
    }
  }

  /// Start the game (host only). Success means the invoke landed — the
  /// server answers with GameStarting/GameStarted or an Error event.
  Future<bool> startGame() async {
    try {
      if (_currentRoomCode == null) return false;
      await _hubConnection?.invoke('StartGame', args: [_currentRoomCode!]);
      return true;
    } catch (e) {
      AppLogger.error('Error starting game', e);
      return false;
    }
  }

  /// Per-turn hot path: queue a direction on the server engine. Fire and
  /// forget — the server never replies on success and silently drops
  /// invalid inputs, so there is nothing to await for the UI.
  Future<void> sendInput(Direction direction) async {
    final roomCode = _currentRoomCode;
    final hub = _hubConnection;
    if (roomCode == null || hub == null || !_isConnected) return;
    try {
      await hub.send('SendInput', args: [roomCode, direction.name]);
    } catch (e) {
      AppLogger.error('Error sending input', e);
    }
  }

  /// Public room browsing is not part of the 1v1 release — quick match
  /// and friend room codes are the two entry points.
  Future<List<MultiplayerGame>> getAvailableGames() async => const [];

  // =============================================
  // MATCHMAKING
  // =============================================

  /// Join matchmaking queue.
  Future<bool> joinMatchmaking({
    required MultiplayerGameMode mode,
    required int playerCount,
  }) async {
    try {
      await _connectSignalR();
      if (!_isConnected) return false;

      await _hubConnection?.invoke(
        'JoinMatchmaking',
        args: [mode.name, playerCount],
      );

      _isInMatchmaking = true;
      _matchmakingStreamController.add(
        MatchmakingStatus(
          isSearching: true,
          mode: mode,
          playerCount: playerCount,
        ),
      );
      return true;
    } catch (e) {
      AppLogger.error('Error joining matchmaking', e);
      return false;
    }
  }

  /// Leave matchmaking queue.
  Future<void> leaveMatchmaking() async {
    try {
      if (_isConnected) {
        await _hubConnection?.invoke('LeaveMatchmaking');
      }
    } catch (e) {
      AppLogger.error('Error leaving matchmaking', e);
    } finally {
      _isInMatchmaking = false;
      _matchmakingQueuePosition = 0;
      _matchmakingEstimatedWait = 0;
      _matchmakingStreamController.add(const MatchmakingStatus());
    }
  }

  // =============================================
  // RECONNECTION
  // =============================================

  /// Attempt to reconnect to a live game. Rediscovers the room via
  /// GET /multiplayer/current when the in-memory code is gone (app
  /// restart). The outcome arrives as ReconnectSuccess (+ MatchResumed
  /// with the current snapshot when the engine match is still live) or
  /// ReconnectFailed.
  Future<bool> attemptReconnect() async {
    if (_isReconnecting) return true;
    try {
      if (_currentRoomCode == null) {
        final current = await _apiService.getCurrentMultiplayerGame();
        final roomCode = current?['room_code'];
        if (roomCode == null) return false;
        _currentRoomCode = roomCode.toString();
        _currentGameId = current?['id']?.toString();
      }

      _isReconnecting = true;
      await _connectSignalR();
      if (!_isConnected) {
        _isReconnecting = false;
        return false;
      }

      await _hubConnection?.invoke('Reconnect', args: [_currentRoomCode!]);
      return true;
    } catch (e) {
      AppLogger.error('Error attempting reconnect', e);
      _isReconnecting = false;
      return false;
    }
  }

  // =============================================
  // HEARTBEAT
  // =============================================

  void _startHeartbeat() {
    _stopHeartbeat();
    _heartbeatTimer = Timer.periodic(
      const Duration(seconds: _heartbeatIntervalSeconds),
      (_) => _sendPing(),
    );
  }

  void _stopHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  Future<void> _sendPing() async {
    try {
      if (_isConnected && _hubConnection != null) {
        await _hubConnection!.invoke('Ping');
      }
    } catch (e) {
      AppLogger.error('Error sending ping', e);
    }
  }

  // =============================================
  // SIGNALR MANAGEMENT
  // =============================================

  Future<void> _connectSignalR() async {
    try {
      if (_hubConnection?.state == HubConnectionState.Connected) {
        _isConnected = true;
        return;
      }

      final hubUrl = _apiService.getSignalRHubUrl();

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => _apiService.accessToken ?? '',
            ),
          )
          .withAutomaticReconnect()
          .build();

      _registerEventHandlers();

      // Transport-level auto-reconnect gives us a fresh connection id, so
      // the server no longer has us in the room's SignalR group. Invoke
      // Reconnect to rejoin + cancel the engine's disconnect grace — the
      // MatchResumed reply re-syncs the snapshot mid-match.
      _hubConnection!.onreconnected(({connectionId}) {
        _isConnected = true;
        final roomCode = _currentRoomCode;
        if (roomCode != null) {
          _hubConnection?.invoke('Reconnect', args: [roomCode]).catchError((
            Object e,
          ) {
            AppLogger.error('Error re-joining room after reconnect', e);
            return null;
          });
        }
      });

      _hubConnection!.onreconnecting(({error}) {
        _isConnected = false;
      });

      _hubConnection!.onclose(({error}) {
        _isConnected = false;
        _gameActionsController.add(
          MultiplayerGameAction(
            actionType: 'connection_lost',
            playerId: '',
            timestamp: DateTime.now(),
            data: const {},
          ),
        );
      });

      await _hubConnection!.start();
      _isConnected = true;
      _startHeartbeat();

      AppLogger.network('Connected to SignalR hub: $hubUrl');
    } catch (e) {
      AppLogger.error('Error connecting to SignalR', e);
      _isConnected = false;
    }
  }

  Future<void> _disconnectSignalR() async {
    try {
      _stopHeartbeat();
      await _hubConnection?.stop();
    } catch (e) {
      AppLogger.error('Error disconnecting from SignalR', e);
    } finally {
      _hubConnection = null;
      _isConnected = false;
    }
  }

  Future<void> _joinRoom(String roomCode) async {
    try {
      await _hubConnection?.invoke('JoinRoom', args: [roomCode]);
    } catch (e) {
      AppLogger.error('Error joining room', e);
    }
  }

  /// Seed a minimal lobby game so PlayerJoined events (replayed by the
  /// hub right after JoinRoom, including our own row) have something to
  /// populate.
  void _seedLobbyGame({
    required MultiplayerGameMode mode,
    required int maxPlayers,
  }) {
    _currentGame = MultiplayerGame(
      id: _currentGameId ?? '',
      mode: mode,
      status: MultiplayerGameStatus.waiting,
      players: const [],
      roomCode: _currentRoomCode,
      maxPlayers: maxPlayers,
      createdAt: DateTime.now(),
      gameSettings: mode.defaultSettings,
    );
    _gameStreamController.add(_currentGame);
  }

  void _registerEventHandlers() {
    // ---- Lobby events ----
    _hubConnection?.on('PlayerJoined', _handlePlayerJoined);
    _hubConnection?.on('PlayerLeft', _handlePlayerLeft);
    _hubConnection?.on('PlayerReady', _handlePlayerReady);
    _hubConnection?.on('GameStarting', _handleGameStarting);
    _hubConnection?.on('GameStarted', _handleGameStarted);

    // ---- Server-authoritative match events ----
    _hubConnection?.on('Tick', _handleTick);
    _hubConnection?.on('GameEnded', _handleGameEnded);
    _hubConnection?.on('MatchResumed', _handleMatchResumed);

    // ---- Matchmaking events ----
    _hubConnection?.on('MatchmakingJoined', _handleMatchmakingJoined);
    _hubConnection?.on('MatchFound', _handleMatchFound);
    _hubConnection?.on('MatchmakingError', _handleMatchmakingError);
    _hubConnection?.on('MatchmakingLeft', (_) {});

    // ---- Reconnection events ----
    _hubConnection?.on('PlayerDisconnected', _handlePlayerDisconnected);
    _hubConnection?.on('PlayerReconnected', _handlePlayerReconnected);
    _hubConnection?.on('ReconnectSuccess', _handleReconnectSuccess);
    _hubConnection?.on('ReconnectFailed', _handleReconnectFailed);

    // ---- Heartbeat ----
    _hubConnection?.on('Pong', (_) {
      // Heartbeat response — connection is alive.
    });

    // ---- Errors ----
    _hubConnection?.on('Error', (arguments) {
      try {
        final data = arguments?.firstOrNull;
        String rawError;
        if (data is String) {
          rawError = data;
        } else if (data is Map<String, dynamic>) {
          rawError =
              data['message']?.toString() ??
              data['error']?.toString() ??
              'Unknown error';
        } else {
          rawError = 'Unknown error';
        }
        _errorController.add(_mapErrorToUserFriendly(rawError));
      } catch (e) {
        AppLogger.error('Error parsing SignalR error', e);
        _errorController.add('Something went wrong. Please try again');
      }
    });
  }

  Map<String, dynamic>? _firstArgAsMap(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return null;
    final data = arguments[0];
    return data is Map<String, dynamic> ? data : null;
  }

  // ---- Lobby handlers ----

  void _handlePlayerJoined(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    try {
      final userId = data['user_id']?.toString() ?? '';
      final username = data['username']?.toString() ?? 'Player';
      final playerIndex = (data['player_index'] as num?)?.toInt() ?? 0;
      final isReady = data['is_ready'] as bool? ?? false;

      final newPlayer = MultiplayerPlayer(
        userId: userId,
        displayName: username,
        username: username,
        status: isReady ? PlayerStatus.ready : PlayerStatus.waiting,
        rank: playerIndex,
      );

      final game = _currentGame;
      if (game != null) {
        final existingIndex = game.players.indexWhere(
          (p) => p.userId == userId,
        );
        final updatedPlayers = List<MultiplayerPlayer>.from(game.players);
        if (existingIndex >= 0) {
          updatedPlayers[existingIndex] = newPlayer;
        } else {
          updatedPlayers.add(newPlayer);
          updatedPlayers.sort((a, b) => a.rank.compareTo(b.rank));
        }
        _currentGame = game.copyWith(players: updatedPlayers);
        _gameStreamController.add(_currentGame);
      }

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'player_joined',
          playerId: userId,
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      AppLogger.error('Error handling PlayerJoined', e);
    }
  }

  void _handlePlayerLeft(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    try {
      final userId = data['user_id']?.toString() ?? '';

      final game = _currentGame;
      if (game != null) {
        _currentGame = game.copyWith(
          players: game.players.where((p) => p.userId != userId).toList(),
        );
        _gameStreamController.add(_currentGame);
      }

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'player_left',
          playerId: userId,
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      AppLogger.error('Error handling PlayerLeft', e);
    }
  }

  void _handlePlayerReady(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    try {
      final userId = data['user_id']?.toString() ?? '';
      final isReady = data['is_ready'] as bool? ?? true;

      final game = _currentGame;
      if (game != null) {
        final playerIndex = game.players.indexWhere((p) => p.userId == userId);
        if (playerIndex >= 0) {
          final updatedPlayers = List<MultiplayerPlayer>.from(game.players);
          updatedPlayers[playerIndex] = updatedPlayers[playerIndex].copyWith(
            status: isReady ? PlayerStatus.ready : PlayerStatus.waiting,
          );
          _currentGame = game.copyWith(players: updatedPlayers);
          _gameStreamController.add(_currentGame);
        }
      }

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'player_ready',
          playerId: userId,
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      AppLogger.error('Error handling PlayerReady', e);
    }
  }

  void _handleGameStarting(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    try {
      _currentGame = _currentGame?.copyWith(
        status: MultiplayerGameStatus.starting,
      );
      _gameStreamController.add(_currentGame);

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'game_starting',
          playerId: '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      AppLogger.error('Error handling GameStarting', e);
    }
  }

  /// `GameStarted {started_at, board_size, snapshot}` — the countdown is
  /// over and the engine loop is live. From here on the match is rendered
  /// exclusively from snapshots.
  void _handleGameStarted(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    try {
      _boardSize = (data['board_size'] as num?)?.toInt() ?? 20;

      final game = _currentGame;
      if (game != null) {
        _currentGame = game.copyWith(
          status: MultiplayerGameStatus.playing,
          startedAt: DateTime.now(),
          players: game.players
              .map((p) => p.copyWith(status: PlayerStatus.playing))
              .toList(),
          gameSettings: {...game.gameSettings, 'boardSize': _boardSize},
        );
        _gameStreamController.add(_currentGame);
      }

      _emitSnapshot(data['snapshot']);
    } catch (e) {
      AppLogger.error('Error handling GameStarted', e);
    }
  }

  // ---- Server-authoritative match handlers ----

  /// The Tick payload IS the snapshot object directly.
  void _handleTick(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;
    _emitSnapshot(data);
  }

  /// `MatchResumed {snapshot}` — reply to a successful Reconnect while
  /// the engine match is still live.
  void _handleMatchResumed(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;
    _isReconnecting = false;
    _currentGame = _currentGame?.copyWith(
      status: MultiplayerGameStatus.playing,
    );
    _gameStreamController.add(_currentGame);
    _emitSnapshot(data['snapshot']);
  }

  void _emitSnapshot(Object? raw) {
    if (raw is! Map<String, dynamic>) return;
    try {
      _snapshotController.add(MatchSnapshot.fromJson(raw));
    } catch (e) {
      AppLogger.error('Error parsing match snapshot', e);
    }
  }

  void _handleGameEnded(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    try {
      final result = MatchEndResult.fromJson(data);

      final game = _currentGame;
      if (game != null) {
        _currentGame = game.copyWith(
          status: MultiplayerGameStatus.finished,
          finishedAt: DateTime.now(),
          winnerId: result.winnerUserId,
          players: game.players.map((p) {
            final endPlayer = result.playerByUserId(p.userId);
            if (endPlayer == null) return p;
            return p.copyWith(
              score: endPlayer.score,
              status: endPlayer.alive
                  ? PlayerStatus.playing
                  : PlayerStatus.crashed,
            );
          }).toList(),
        );
        _gameStreamController.add(_currentGame);
      }

      _matchEndController.add(result);
    } catch (e) {
      AppLogger.error('Error handling GameEnded', e);
    }
  }

  // ---- Matchmaking handlers ----

  void _handleMatchmakingJoined(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    try {
      _matchmakingQueuePosition =
          (data['queue_position'] as num?)?.toInt() ?? 0;
      _matchmakingEstimatedWait =
          (data['estimated_wait_seconds'] as num?)?.toInt() ?? 0;

      _matchmakingStreamController.add(
        MatchmakingStatus(
          isSearching: true,
          queuePosition: _matchmakingQueuePosition,
          estimatedWaitSeconds: _matchmakingEstimatedWait,
        ),
      );
    } catch (e) {
      AppLogger.error('Error handling MatchmakingJoined', e);
    }
  }

  void _handleMatchFound(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    try {
      _isInMatchmaking = false;
      _currentGameId = data['game_id']?.toString();
      _currentRoomCode = data['room_code']?.toString();

      final modeStr = data['mode']?.toString().toLowerCase() ?? 'classic';
      final mode = MultiplayerGameMode.values.firstWhere(
        (m) => m.name.toLowerCase() == modeStr,
        orElse: () => MultiplayerGameMode.classic,
      );
      final playerCount = (data['player_count'] as num?)?.toInt() ?? 2;

      _seedLobbyGame(mode: mode, maxPlayers: playerCount);

      _matchmakingStreamController.add(
        MatchmakingStatus(
          matchFound: true,
          gameId: _currentGameId,
          roomCode: _currentRoomCode,
          playerIndex: (data['player_index'] as num?)?.toInt(),
          mode: mode,
          playerCount: playerCount,
        ),
      );

      // The matchmaker already created our player row, so the hub-side
      // join is all that's left.
      if (_currentRoomCode != null) {
        _joinRoom(_currentRoomCode!);
      }
    } catch (e) {
      AppLogger.error('Error handling MatchFound', e);
    }
  }

  void _handleMatchmakingError(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    _isInMatchmaking = false;
    _matchmakingStreamController.add(
      MatchmakingStatus(error: data['error']?.toString()),
    );
  }

  // ---- Reconnection handlers ----

  void _handlePlayerDisconnected(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    _gameActionsController.add(
      MultiplayerGameAction(
        actionType: 'player_disconnected',
        playerId: data['user_id']?.toString() ?? '',
        timestamp: DateTime.now(),
        data: data,
      ),
    );
  }

  void _handlePlayerReconnected(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    _gameActionsController.add(
      MultiplayerGameAction(
        actionType: 'player_reconnected',
        playerId: data['user_id']?.toString() ?? '',
        timestamp: DateTime.now(),
        data: data,
      ),
    );
  }

  void _handleReconnectSuccess(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);
    if (data == null) return;

    try {
      _isReconnecting = false;
      _currentGameId = data['game_id']?.toString() ?? _currentGameId;
      _currentRoomCode = data['room_code']?.toString() ?? _currentRoomCode;

      final statusStr = data['status']?.toString().toLowerCase() ?? 'waiting';
      final status = MultiplayerGameStatus.values.firstWhere(
        (s) => s.name.toLowerCase() == statusStr,
        orElse: () => MultiplayerGameStatus.playing,
      );

      final players = (data['players'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(
            (p) => MultiplayerPlayer(
              userId: p['user_id']?.toString() ?? '',
              displayName: p['username']?.toString() ?? 'Player',
              username: p['username']?.toString(),
              status: (p['is_alive'] as bool? ?? true)
                  ? ((p['is_ready'] as bool? ?? false) &&
                            status == MultiplayerGameStatus.waiting
                        ? PlayerStatus.ready
                        : PlayerStatus.playing)
                  : PlayerStatus.crashed,
              score: (p['score'] as num?)?.toInt() ?? 0,
              rank: (p['player_index'] as num?)?.toInt() ?? 0,
            ),
          )
          .toList();

      _currentGame = MultiplayerGame(
        id: _currentGameId ?? '',
        mode: MultiplayerGameMode.classic,
        status: status,
        players: players,
        roomCode: _currentRoomCode,
        maxPlayers: 2,
        createdAt: DateTime.now(),
        gameSettings: MultiplayerGameMode.classic.defaultSettings,
      );
      _gameStreamController.add(_currentGame);

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'reconnect_success',
          playerId: '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      AppLogger.error('Error handling ReconnectSuccess', e);
    }
  }

  void _handleReconnectFailed(List<Object?>? arguments) {
    final data = _firstArgAsMap(arguments);

    _isReconnecting = false;
    _currentGame = null;
    _currentGameId = null;
    _currentRoomCode = null;
    _gameStreamController.add(null);

    _gameActionsController.add(
      MultiplayerGameAction(
        actionType: 'reconnect_failed',
        playerId: '',
        timestamp: DateTime.now(),
        data: data ?? const {},
      ),
    );
  }

  /// Map backend error messages to user-friendly messages.
  String _mapErrorToUserFriendly(String error) {
    final errorLower = error.toLowerCase();

    if (errorLower.contains('not all players are ready')) {
      return 'Waiting for all players to be ready';
    }
    if (errorLower.contains('only the host can start')) {
      return 'Only the host can start the game';
    }
    if (errorLower.contains('game not found')) {
      return 'Game session expired. Please create a new game';
    }
    if (errorLower.contains('game already in progress') ||
        errorLower.contains('game cannot be started')) {
      return 'This game has already started';
    }
    if (errorLower.contains('exactly 2 players')) {
      return 'Matches need exactly 2 players';
    }
    if (errorLower.contains('user not authenticated') ||
        errorLower.contains('not authenticated')) {
      return 'Please sign in to play multiplayer';
    }
    if (errorLower.contains('reconnection window expired') ||
        errorLower.contains('reconnect')) {
      return 'Reconnection time expired';
    }
    if (errorLower.contains('connection')) {
      return 'Connection lost. Please check your internet';
    }
    if (errorLower.contains('must join the game via api first')) {
      return 'Unable to join room. Please try again';
    }

    return 'Something went wrong. Please try again';
  }

  /// Dispose the service.
  void dispose() {
    _stopHeartbeat();
    _disconnectSignalR();
    _gameStreamController.close();
    _gameActionsController.close();
    _matchmakingStreamController.close();
    _errorController.close();
    _snapshotController.close();
    _matchEndController.close();
  }
}
