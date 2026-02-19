import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/utils/direction.dart';

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

  // Matchmaking getters
  bool get isInMatchmaking => _isInMatchmaking;
  int get matchmakingQueuePosition => _matchmakingQueuePosition;
  int get matchmakingEstimatedWait => _matchmakingEstimatedWait;

  /// Create a new multiplayer game
  Future<String?> createGame({
    required MultiplayerGameMode mode,
    bool isPrivate = false,
    int maxPlayers = 2,
  }) async {
    try {
      final response = await _apiService.createMultiplayerGame(
        mode: mode.name,
        maxPlayers: maxPlayers,
        gridSize: mode.defaultSettings['boardSize'] ?? 20,
        speed: mode.defaultSettings['speed'] ?? 100,
      );

      if (response == null) return null;

      final gameId = response['game_id'] ?? response['id'];
      final roomCode = response['room_code'];

      if (gameId != null) {
        _currentGameId = gameId.toString();
        _currentRoomCode = roomCode?.toString();

        // Connect to SignalR and join the room
        await _connectSignalR();
        if (_currentRoomCode != null) {
          await _joinRoom(_currentRoomCode!);
        }

        return _currentGameId;
      }

      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error creating multiplayer game: $e');
      }
      return null;
    }
  }

  /// Join a game by ID or room code
  Future<bool> joinGame(String gameIdOrRoomCode) async {
    try {
      final response = await _apiService.joinMultiplayerGame(gameIdOrRoomCode);

      if (response == null) return false;

      final gameId = response['game_id'] ?? response['id'];
      final roomCode = response['room_code'] ?? gameIdOrRoomCode;

      if (gameId != null) {
        _currentGameId = gameId.toString();
        _currentRoomCode = roomCode.toString();

        // Connect to SignalR and join the room
        await _connectSignalR();
        await _joinRoom(_currentRoomCode!);

        return true;
      }

      return false;
    } catch (e) {
      if (kDebugMode) {
        print('Error joining multiplayer game: $e');
      }
      return false;
    }
  }

  /// Leave the current game
  Future<void> leaveGame() async {
    try {
      if (_currentRoomCode != null) {
        await _hubConnection?.invoke('LeaveRoom', args: [_currentRoomCode!]);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving game: $e');
      }
    } finally {
      await _disconnectSignalR();
      _currentGame = null;
      _currentGameId = null;
      _currentRoomCode = null;
      _gameStreamController.add(null);
    }
  }

  /// Mark player as ready
  Future<bool> markPlayerReady({bool isReady = true}) async {
    try {
      if (_currentRoomCode == null) return false;

      await _hubConnection?.invoke(
        'SetReady',
        args: [_currentRoomCode!, isReady],
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking player ready: $e');
      }
      return false;
    }
  }

  /// Start the game (host only)
  Future<bool> startGame() async {
    try {
      if (_currentRoomCode == null) return false;

      await _hubConnection?.invoke('StartGame', args: [_currentRoomCode!]);
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error starting game: $e');
      }
      return false;
    }
  }

  /// Send player action (direction change, game update)
  Future<void> sendPlayerAction(MultiplayerGameAction action) async {
    try {
      if (_currentRoomCode == null) return;

      final moveData = {
        'direction': action.data['direction'],
        'snake_positions': action.data['snake'],
        'score': action.data['score'] ?? 0,
      };

      await _hubConnection?.invoke(
        'SendMove',
        args: [_currentRoomCode!, moveData],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error sending player action: $e');
      }
    }
  }

  /// Update player's snake position and score
  Future<void> updatePlayerGameState({
    required List<Position> snake,
    required int score,
    required PlayerStatus status,
  }) async {
    try {
      if (_currentRoomCode == null) return;

      final moveData = {
        'direction': 'right', // Will be updated by the actual direction
        'snake_positions': snake.map((p) => {'x': p.x, 'y': p.y}).toList(),
        'score': score,
      };

      await _hubConnection?.invoke(
        'SendMove',
        args: [_currentRoomCode!, moveData],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating player game state: $e');
      }
    }
  }

  /// Notify that player died
  Future<void> notifyPlayerDied() async {
    try {
      if (_currentRoomCode == null) return;

      await _hubConnection?.invoke('PlayerDied', args: [_currentRoomCode!]);
    } catch (e) {
      if (kDebugMode) {
        print('Error notifying player died: $e');
      }
    }
  }

  /// Notify game over with final score
  Future<void> notifyGameOver(int finalScore) async {
    try {
      if (_currentRoomCode == null) return;

      await _hubConnection?.invoke(
        'GameOver',
        args: [_currentRoomCode!, finalScore],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error notifying game over: $e');
      }
    }
  }

  /// Update game state (host only - food positions, power-ups)
  Future<void> updateGameState({
    List<Position>? foodPositions,
    List<Map<String, dynamic>>? powerUps,
  }) async {
    try {
      if (_currentRoomCode == null) return;

      final update = {
        if (foodPositions != null)
          'food_positions': foodPositions
              .map((p) => {'x': p.x, 'y': p.y})
              .toList(),
        'power_ups': ?powerUps,
      };

      await _hubConnection?.invoke(
        'UpdateGameState',
        args: [_currentRoomCode!, update],
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating game state: $e');
      }
    }
  }

  /// Get available games to join
  Future<List<MultiplayerGame>> getAvailableGames() async {
    try {
      final response = await _apiService.getAvailableGames();
      if (response == null) return [];

      return response.map((game) {
        return MultiplayerGame(
          id: game['id']?.toString() ?? game['game_id']?.toString() ?? '',
          mode: MultiplayerGameMode.values.firstWhere(
            (m) =>
                m.name.toLowerCase() ==
                (game['mode'] ?? 'classic').toString().toLowerCase(),
            orElse: () => MultiplayerGameMode.classic,
          ),
          status: MultiplayerGameStatus.waiting,
          roomCode: game['room_code']?.toString(),
          players: [],
          maxPlayers: game['max_players'] ?? 2,
          gameSettings: Map<String, dynamic>.from(game['game_settings'] ?? {}),
          createdAt:
              DateTime.tryParse(game['created_at']?.toString() ?? '') ??
              DateTime.now(),
        );
      }).toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting available games: $e');
      }
      return [];
    }
  }

  // =============================================
  // MATCHMAKING
  // =============================================

  /// Join matchmaking queue
  Future<bool> joinMatchmaking({
    required MultiplayerGameMode mode,
    required int playerCount,
  }) async {
    try {
      // Connect to SignalR if not connected
      await _connectSignalR();

      if (!_isConnected) {
        return false;
      }

      await _hubConnection?.invoke(
        'JoinMatchmaking',
        args: [mode.name, playerCount],
      );

      _isInMatchmaking = true;
      _matchmakingStreamController.add(
        MatchmakingStatus(
          isSearching: true,
          queuePosition: 0,
          estimatedWaitSeconds: 0,
          mode: mode,
          playerCount: playerCount,
        ),
      );

      if (kDebugMode) {
        print('Joined matchmaking for ${mode.name} ${playerCount}p');
      }

      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error joining matchmaking: $e');
      }
      return false;
    }
  }

  /// Leave matchmaking queue
  Future<void> leaveMatchmaking() async {
    try {
      if (_isConnected) {
        await _hubConnection?.invoke('LeaveMatchmaking');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving matchmaking: $e');
      }
    } finally {
      _isInMatchmaking = false;
      _matchmakingQueuePosition = 0;
      _matchmakingEstimatedWait = 0;
      _matchmakingStreamController.add(
        MatchmakingStatus(
          isSearching: false,
          queuePosition: 0,
          estimatedWaitSeconds: 0,
        ),
      );
    }
  }

  /// Stream of matchmaking status updates
  Stream<MatchmakingStatus> get matchmakingStream =>
      _matchmakingStreamController.stream;

  // =============================================
  // RECONNECTION
  // =============================================

  /// Attempt to reconnect to a game after disconnect
  Future<bool> attemptReconnect() async {
    if (_currentRoomCode == null) {
      return false;
    }

    try {
      _isReconnecting = true;

      // Reconnect to SignalR
      await _connectSignalR();

      if (!_isConnected) {
        _isReconnecting = false;
        return false;
      }

      // Request reconnection
      await _hubConnection?.invoke('Reconnect', args: [_currentRoomCode!]);

      if (kDebugMode) {
        print('Attempting to reconnect to room: $_currentRoomCode');
      }

      // The result will come via ReconnectSuccess or ReconnectFailed event
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error attempting reconnect: $e');
      }
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
      Duration(seconds: _heartbeatIntervalSeconds),
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
      if (kDebugMode) {
        print('Error sending ping: $e');
      }
      // Connection might be lost, attempt to handle disconnect
      _handleConnectionLost();
    }
  }

  void _handleConnectionLost() {
    if (kDebugMode) {
      print('Connection lost, attempting to handle...');
    }

    _isConnected = false;

    // Notify listeners
    _gameActionsController.add(
      MultiplayerGameAction(
        actionType: 'connection_lost',
        playerId: '',
        timestamp: DateTime.now(),
        data: {},
      ),
    );

    // Attempt reconnection if we have a game
    if (_currentRoomCode != null && !_isReconnecting) {
      attemptReconnect();
    }
  }

  /// Stream of current game updates
  Stream<MultiplayerGame?> get gameStream => _gameStreamController.stream;

  /// Stream of game actions for real-time updates
  Stream<MultiplayerGameAction> get gameActionsStream =>
      _gameActionsController.stream;

  /// Stream of error messages for UI display
  Stream<String> get errorStream => _errorController.stream;

  /// Map backend error messages to user-friendly messages
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

    // Default: show generic message
    return 'Something went wrong. Please try again';
  }

  // SignalR management

  Future<void> _connectSignalR() async {
    try {
      if (_isConnected) return;

      final hubUrl = _apiService.getSignalRHubUrl();
      final accessToken = _apiService.accessToken;

      _hubConnection = HubConnectionBuilder()
          .withUrl(
            hubUrl,
            options: HttpConnectionOptions(
              accessTokenFactory: () async => accessToken ?? '',
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Register event handlers
      _registerEventHandlers();

      await _hubConnection!.start();
      _isConnected = true;

      // Start heartbeat
      _startHeartbeat();

      if (kDebugMode) {
        print('Connected to SignalR hub: $hubUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to SignalR: $e');
      }
      _isConnected = false;
    }
  }

  Future<void> _disconnectSignalR() async {
    try {
      _stopHeartbeat();
      await _hubConnection?.stop();
    } catch (e) {
      if (kDebugMode) {
        print('Error disconnecting from SignalR: $e');
      }
    } finally {
      _hubConnection = null;
      _isConnected = false;
    }
  }

  Future<void> _joinRoom(String roomCode) async {
    try {
      await _hubConnection?.invoke('JoinRoom', args: [roomCode]);
      if (kDebugMode) {
        print('Joined SignalR room: $roomCode');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error joining room: $e');
      }
    }
  }

  void _registerEventHandlers() {
    // Player joined the room
    _hubConnection?.on('PlayerJoined', (arguments) {
      if (kDebugMode) {
        print('PlayerJoined: $arguments');
      }
      _handlePlayerJoined(arguments);
    });

    // Player left the room
    _hubConnection?.on('PlayerLeft', (arguments) {
      if (kDebugMode) {
        print('PlayerLeft: $arguments');
      }
      _handlePlayerLeft(arguments);
    });

    // Player ready status changed
    _hubConnection?.on('PlayerReady', (arguments) {
      if (kDebugMode) {
        print('PlayerReady: $arguments');
      }
      _handlePlayerReady(arguments);
    });

    // Game is starting (countdown)
    _hubConnection?.on('GameStarting', (arguments) {
      if (kDebugMode) {
        print('GameStarting: $arguments');
      }
      _handleGameStarting(arguments);
    });

    // Game has started
    _hubConnection?.on('GameStarted', (arguments) {
      if (kDebugMode) {
        print('GameStarted: $arguments');
      }
      _handleGameStarted(arguments);
    });

    // Player moved
    _hubConnection?.on('PlayerMoved', (arguments) {
      _handlePlayerMoved(arguments);
    });

    // Game state updated (food, power-ups)
    _hubConnection?.on('GameStateUpdated', (arguments) {
      if (kDebugMode) {
        print('GameStateUpdated: $arguments');
      }
      _handleGameStateUpdated(arguments);
    });

    // Player died
    _hubConnection?.on('PlayerDied', (arguments) {
      if (kDebugMode) {
        print('PlayerDied: $arguments');
      }
      _handlePlayerDied(arguments);
    });

    // Game ended
    _hubConnection?.on('GameEnded', (arguments) {
      if (kDebugMode) {
        print('GameEnded: $arguments');
      }
      _handleGameEnded(arguments);
    });

    // Error from server
    _hubConnection?.on('Error', (arguments) {
      if (kDebugMode) {
        print('SignalR Error: $arguments');
      }

      // Extract error message and emit to stream
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

        final userFriendlyError = _mapErrorToUserFriendly(rawError);
        _errorController.add(userFriendlyError);
      } catch (e) {
        if (kDebugMode) {
          print('Error parsing SignalR error: $e');
        }
        _errorController.add('Something went wrong. Please try again');
      }
    });

    // =============================================
    // MATCHMAKING EVENTS
    // =============================================

    // Matchmaking joined confirmation
    _hubConnection?.on('MatchmakingJoined', (arguments) {
      if (kDebugMode) {
        print('MatchmakingJoined: $arguments');
      }
      _handleMatchmakingJoined(arguments);
    });

    // Match found!
    _hubConnection?.on('MatchFound', (arguments) {
      if (kDebugMode) {
        print('MatchFound: $arguments');
      }
      _handleMatchFound(arguments);
    });

    // Matchmaking error
    _hubConnection?.on('MatchmakingError', (arguments) {
      if (kDebugMode) {
        print('MatchmakingError: $arguments');
      }
      _handleMatchmakingError(arguments);
    });

    // Matchmaking left confirmation
    _hubConnection?.on('MatchmakingLeft', (arguments) {
      if (kDebugMode) {
        print('MatchmakingLeft: $arguments');
      }
    });

    // =============================================
    // RECONNECTION EVENTS
    // =============================================

    // Player temporarily disconnected
    _hubConnection?.on('PlayerDisconnected', (arguments) {
      if (kDebugMode) {
        print('PlayerDisconnected: $arguments');
      }
      _handlePlayerDisconnected(arguments);
    });

    // Player reconnected
    _hubConnection?.on('PlayerReconnected', (arguments) {
      if (kDebugMode) {
        print('PlayerReconnected: $arguments');
      }
      _handlePlayerReconnected(arguments);
    });

    // Reconnection success
    _hubConnection?.on('ReconnectSuccess', (arguments) {
      if (kDebugMode) {
        print('ReconnectSuccess: $arguments');
      }
      _handleReconnectSuccess(arguments);
    });

    // Reconnection failed
    _hubConnection?.on('ReconnectFailed', (arguments) {
      if (kDebugMode) {
        print('ReconnectFailed: $arguments');
      }
      _handleReconnectFailed(arguments);
    });

    // =============================================
    // MULTI-PLAYER EVENTS
    // =============================================

    // Player eliminated (for multi-player games)
    _hubConnection?.on('PlayerEliminated', (arguments) {
      if (kDebugMode) {
        print('PlayerEliminated: $arguments');
      }
      _handlePlayerEliminated(arguments);
    });

    // Game cancelled (by cleanup job)
    _hubConnection?.on('GameCancelled', (arguments) {
      if (kDebugMode) {
        print('GameCancelled: $arguments');
      }
      _handleGameCancelled(arguments);
    });

    // =============================================
    // HEARTBEAT
    // =============================================

    // Pong response
    _hubConnection?.on('Pong', (arguments) {
      // Heartbeat response - connection is alive
    });
  }

  void _handlePlayerJoined(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      final userId = (data['UserId'] ?? data['user_id'] ?? '').toString();
      final username = data['Username'] ?? data['username'] ?? 'Player';
      final playerIndex = data['PlayerIndex'] ?? data['player_index'] ?? 0;
      final isReady = data['IsReady'] ?? data['is_ready'] ?? false;

      // Parse snake positions if present (for matchmade games)
      List<Position> snakePositions = [];
      final snakeData =
          data['SnakePositions'] ??
          data['snakePositions'] ??
          data['snake_positions'];
      if (snakeData != null && snakeData is List) {
        snakePositions = snakeData.map((pos) {
          if (pos is Map<String, dynamic>) {
            return Position(
              (pos['x'] ?? pos['X'] ?? 0) as int,
              (pos['y'] ?? pos['Y'] ?? 0) as int,
            );
          }
          return const Position(0, 0);
        }).toList();
      }

      // Parse direction if present
      final directionStr = data['Direction'] ?? data['direction'] ?? 'right';
      final direction = Direction.values.firstWhere(
        (d) => d.name.toLowerCase() == directionStr.toString().toLowerCase(),
        orElse: () => Direction.right,
      );

      if (kDebugMode) {
        print(
          'PlayerJoined: $userId with ${snakePositions.length} snake positions',
        );
      }

      // Create player object
      final newPlayer = MultiplayerPlayer(
        userId: userId,
        displayName: username,
        status: isReady ? PlayerStatus.ready : PlayerStatus.waiting,
        score: 0,
        rank: playerIndex,
        snake: snakePositions,
        currentDirection: direction,
      );

      // Update current game with new player
      if (_currentGame != null) {
        // Check if player already exists
        final existingPlayerIndex = _currentGame!.players.indexWhere(
          (p) => p.userId == userId,
        );

        List<MultiplayerPlayer> updatedPlayers;
        if (existingPlayerIndex >= 0) {
          // Update existing player
          updatedPlayers = List.from(_currentGame!.players);
          updatedPlayers[existingPlayerIndex] = newPlayer;
        } else {
          // Add new player
          updatedPlayers = [..._currentGame!.players, newPlayer];
        }

        _currentGame = _currentGame!.copyWith(players: updatedPlayers);
        _gameStreamController.add(_currentGame);
      }

      // Notify listeners
      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'player_joined',
          playerId: userId,
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling PlayerJoined: $e');
      }
    }
  }

  void _handlePlayerLeft(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      final userId = data['user_id']?.toString() ?? '';

      // Remove player from current game
      if (_currentGame != null) {
        final updatedPlayers = _currentGame!.players
            .where((p) => p.userId != userId)
            .toList();
        _currentGame = _currentGame!.copyWith(players: updatedPlayers);
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
      if (kDebugMode) {
        print('Error handling PlayerLeft: $e');
      }
    }
  }

  void _handlePlayerReady(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      final userId = data['user_id']?.toString() ?? '';
      final isReady = data['is_ready'] ?? true;

      // Update player ready status in current game
      if (_currentGame != null) {
        final playerIndex = _currentGame!.players.indexWhere(
          (p) => p.userId == userId,
        );
        if (playerIndex >= 0) {
          final updatedPlayers = List<MultiplayerPlayer>.from(
            _currentGame!.players,
          );
          updatedPlayers[playerIndex] = updatedPlayers[playerIndex].copyWith(
            status: isReady ? PlayerStatus.ready : PlayerStatus.waiting,
          );
          _currentGame = _currentGame!.copyWith(players: updatedPlayers);
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
      if (kDebugMode) {
        print('Error handling PlayerReady: $e');
      }
    }
  }

  void _handleGameStarting(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

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
      if (kDebugMode) {
        print('Error handling GameStarting: $e');
      }
    }
  }

  void _handleGameStarted(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      if (kDebugMode) {
        print('GameStarted data: $data');
      }

      // Parse players with snake positions from the server
      List<MultiplayerPlayer>? updatedPlayers;
      if (data['Players'] != null || data['players'] != null) {
        final playersData = (data['Players'] ?? data['players']) as List;
        updatedPlayers = playersData.map((p) {
          final playerMap = p as Map<String, dynamic>;

          // Parse snake positions from server format
          List<Position> snakePositions = [];
          final snakeData =
              playerMap['SnakePositions'] ??
              playerMap['snakePositions'] ??
              playerMap['snake_positions'];
          if (snakeData != null && snakeData is List) {
            snakePositions = snakeData.map((pos) {
              if (pos is Map<String, dynamic>) {
                return Position(
                  (pos['x'] ?? pos['X'] ?? 0) as int,
                  (pos['y'] ?? pos['Y'] ?? 0) as int,
                );
              }
              return const Position(0, 0);
            }).toList();
          }

          // Parse direction
          final directionStr =
              playerMap['Direction'] ?? playerMap['direction'] ?? 'right';
          final direction = Direction.values.firstWhere(
            (d) =>
                d.name.toLowerCase() == directionStr.toString().toLowerCase(),
            orElse: () => Direction.right,
          );

          return MultiplayerPlayer(
            userId:
                (playerMap['UserId'] ??
                        playerMap['userId'] ??
                        playerMap['user_id'] ??
                        '')
                    .toString(),
            displayName:
                playerMap['Username'] ??
                playerMap['username'] ??
                playerMap['displayName'] ??
                'Player',
            status: PlayerStatus.playing,
            snake: snakePositions,
            currentDirection: direction,
            score: playerMap['Score'] ?? playerMap['score'] ?? 0,
            rank:
                playerMap['PlayerIndex'] ??
                playerMap['playerIndex'] ??
                playerMap['player_index'] ??
                0,
          );
        }).toList();

        if (kDebugMode) {
          print('Parsed ${updatedPlayers.length} players with snake positions');
          for (var p in updatedPlayers) {
            print('  Player ${p.userId}: ${p.snake.length} snake segments');
          }
        }
      }

      // Parse food position
      Position? foodPosition;
      final foodData =
          data['FoodPositions'] ??
          data['foodPositions'] ??
          data['food_positions'];
      if (foodData != null && foodData is List && foodData.isNotEmpty) {
        final firstFood = foodData.first;
        if (firstFood is Map<String, dynamic>) {
          foodPosition = Position(
            (firstFood['x'] ?? firstFood['X'] ?? 0) as int,
            (firstFood['y'] ?? firstFood['Y'] ?? 0) as int,
          );
        }
      }

      // Parse game settings
      Map<String, dynamic>? gameSettings;
      if (data['GameSettings'] != null || data['gameSettings'] != null) {
        gameSettings = Map<String, dynamic>.from(
          data['GameSettings'] ?? data['gameSettings'] ?? {},
        );
      }
      final boardSize =
          data['BoardSize'] ??
          data['boardSize'] ??
          gameSettings?['boardSize'] ??
          20;
      gameSettings = {...?gameSettings, 'boardSize': boardSize};

      _currentGame = _currentGame?.copyWith(
        status: MultiplayerGameStatus.playing,
        players: updatedPlayers ?? _currentGame?.players,
        foodPosition: foodPosition,
        gameSettings: gameSettings,
      );
      _gameStreamController.add(_currentGame);

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'game_started',
          playerId: '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling GameStarted: $e');
      }
    }
  }

  void _handlePlayerMoved(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'player_moved',
          playerId: data['user_id']?.toString() ?? '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling PlayerMoved: $e');
      }
    }
  }

  void _handleGameStateUpdated(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      // Update food position if provided
      if (data['food_positions'] != null) {
        final foodPositions = (data['food_positions'] as List)
            .map((f) => Position(f['x'] as int, f['y'] as int))
            .toList();

        if (foodPositions.isNotEmpty) {
          _currentGame = _currentGame?.copyWith(
            foodPosition: foodPositions.first,
          );
          _gameStreamController.add(_currentGame);
        }
      }

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'game_state_updated',
          playerId: '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling GameStateUpdated: $e');
      }
    }
  }

  void _handlePlayerDied(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'player_died',
          playerId: data['user_id']?.toString() ?? '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling PlayerDied: $e');
      }
    }
  }

  void _handleGameEnded(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _currentGame = _currentGame?.copyWith(
        status: MultiplayerGameStatus.finished,
        winnerId: data['winner_id']?.toString(),
      );
      _gameStreamController.add(_currentGame);

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'game_ended',
          playerId: '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling GameEnded: $e');
      }
    }
  }

  // =============================================
  // NEW HANDLER IMPLEMENTATIONS
  // =============================================

  void _handleMatchmakingJoined(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _matchmakingQueuePosition = data['queue_position'] ?? 0;
      _matchmakingEstimatedWait = data['estimated_wait_seconds'] ?? 0;

      _matchmakingStreamController.add(
        MatchmakingStatus(
          isSearching: true,
          queuePosition: _matchmakingQueuePosition,
          estimatedWaitSeconds: _matchmakingEstimatedWait,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling MatchmakingJoined: $e');
      }
    }
  }

  void _handleMatchFound(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _isInMatchmaking = false;
      _currentGameId = data['game_id']?.toString();
      _currentRoomCode = data['room_code']?.toString();

      // Parse game mode
      final modeStr = data['mode']?.toString().toLowerCase() ?? 'classic';
      final mode = MultiplayerGameMode.values.firstWhere(
        (m) => m.name.toLowerCase() == modeStr,
        orElse: () => MultiplayerGameMode.classic,
      );

      // Create initial game object
      _currentGame = MultiplayerGame(
        id: _currentGameId ?? '',
        mode: mode,
        status: MultiplayerGameStatus.waiting,
        players: [],
        roomCode: _currentRoomCode,
        maxPlayers: data['player_count'] ?? 2,
        createdAt: DateTime.now(),
        gameSettings: mode.defaultSettings,
      );

      // Emit game to stream
      _gameStreamController.add(_currentGame);

      // Notify matchmaking stream that match was found
      _matchmakingStreamController.add(
        MatchmakingStatus(
          isSearching: false,
          matchFound: true,
          gameId: _currentGameId,
          roomCode: _currentRoomCode,
          playerIndex: data['player_index'],
          mode: mode,
          playerCount: data['player_count'],
        ),
      );

      // Notify game actions
      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'match_found',
          playerId: '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );

      // Auto-join the room
      if (_currentRoomCode != null) {
        _joinRoom(_currentRoomCode!);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling MatchFound: $e');
      }
    }
  }

  void _handleMatchmakingError(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _isInMatchmaking = false;

      _matchmakingStreamController.add(
        MatchmakingStatus(isSearching: false, error: data['error']?.toString()),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling MatchmakingError: $e');
      }
    }
  }

  void _handlePlayerDisconnected(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'player_disconnected',
          playerId: data['user_id']?.toString() ?? '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling PlayerDisconnected: $e');
      }
    }
  }

  void _handlePlayerReconnected(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'player_reconnected',
          playerId: data['user_id']?.toString() ?? '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling PlayerReconnected: $e');
      }
    }
  }

  void _handleReconnectSuccess(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _isReconnecting = false;

      // Restore game state from server data
      _currentGameId = data['game_id']?.toString();
      _currentRoomCode = data['room_code']?.toString();

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'reconnect_success',
          playerId: '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );

      if (kDebugMode) {
        print('Successfully reconnected to game $_currentGameId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling ReconnectSuccess: $e');
      }
    }
  }

  void _handleReconnectFailed(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _isReconnecting = false;

      // Clear game state
      _currentGame = null;
      _currentGameId = null;
      _currentRoomCode = null;
      _gameStreamController.add(null);

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'reconnect_failed',
          playerId: '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );

      if (kDebugMode) {
        print('Reconnection failed: ${data['error']}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling ReconnectFailed: $e');
      }
    }
  }

  void _handlePlayerEliminated(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'player_eliminated',
          playerId: data['user_id']?.toString() ?? '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling PlayerEliminated: $e');
      }
    }
  }

  void _handleGameCancelled(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      _currentGame = _currentGame?.copyWith(
        status: MultiplayerGameStatus.finished,
      );
      _gameStreamController.add(_currentGame);

      _gameActionsController.add(
        MultiplayerGameAction(
          actionType: 'game_cancelled',
          playerId: '',
          timestamp: DateTime.now(),
          data: data,
        ),
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error handling GameCancelled: $e');
      }
    }
  }

  // Helper methods

  List<Position> generateInitialSnakePosition(int playerIndex, int boardSize) {
    final centerY = boardSize ~/ 2;

    switch (playerIndex) {
      case 0:
        // Player 1 starts on the left
        return [
          Position(3, centerY),
          Position(2, centerY),
          Position(1, centerY),
        ];
      case 1:
        // Player 2 starts on the right
        return [
          Position(boardSize - 4, centerY),
          Position(boardSize - 3, centerY),
          Position(boardSize - 2, centerY),
        ];
      default:
        // Additional players (if supported)
        final y = centerY + (playerIndex - 1) * 3;
        return [
          Position(5 + playerIndex * 2, y),
          Position(4 + playerIndex * 2, y),
          Position(3 + playerIndex * 2, y),
        ];
    }
  }

  Position generateFoodPosition(
    int boardSize,
    List<MultiplayerPlayer> players,
  ) {
    final random = Random();
    Position foodPos;

    do {
      foodPos = Position(random.nextInt(boardSize), random.nextInt(boardSize));
    } while (_isFoodOnSnake(foodPos, players));

    return foodPos;
  }

  bool _isFoodOnSnake(Position foodPos, List<MultiplayerPlayer> players) {
    for (final player in players) {
      if (player.snake.contains(foodPos)) {
        return true;
      }
    }
    return false;
  }

  /// Generate new food position when eaten
  Future<void> generateNewFood() async {
    try {
      if (_currentGame != null && _currentRoomCode != null) {
        final boardSize =
            (_currentGame!.gameSettings['boardSize'] as int?) ?? 20;
        final newFood = generateFoodPosition(boardSize, _currentGame!.players);

        await updateGameState(foodPositions: [newFood]);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error generating new food: $e');
      }
    }
  }

  /// Check if game should end
  Future<void> checkGameEnd() async {
    try {
      if (_currentGame == null) return;

      final alivePlayers = _currentGame!.alivePlayers;

      if (alivePlayers.length <= 1) {
        String? winnerId;
        if (alivePlayers.length == 1) {
          winnerId = alivePlayers.first.userId;
        }

        // The server will handle game end notification
        if (kDebugMode) {
          print('Game should end, winner: $winnerId');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking game end: $e');
      }
    }
  }

  /// Dispose the service
  void dispose() {
    _stopHeartbeat();
    _disconnectSignalR();
    _gameStreamController.close();
    _gameActionsController.close();
    _matchmakingStreamController.close();
    _errorController.close();
  }
}

/// Matchmaking status for stream updates
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

  MatchmakingStatus({
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
