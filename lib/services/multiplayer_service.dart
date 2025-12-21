import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/services/api_service.dart';

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

  // Stream controllers for game events
  final _gameStreamController = StreamController<MultiplayerGame?>.broadcast();
  final _gameActionsController = StreamController<MultiplayerGameAction>.broadcast();

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
        await _hubConnection?.invoke('LeaveRoom', args: [_currentRoomCode]);
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

      await _hubConnection?.invoke('SetReady', args: [_currentRoomCode, isReady]);
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

      await _hubConnection?.invoke('StartGame', args: [_currentRoomCode]);
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

      await _hubConnection?.invoke('SendMove', args: [_currentRoomCode, moveData]);
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

      await _hubConnection?.invoke('SendMove', args: [_currentRoomCode, moveData]);
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

      await _hubConnection?.invoke('PlayerDied', args: [_currentRoomCode]);
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

      await _hubConnection?.invoke('GameOver', args: [_currentRoomCode, finalScore]);
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
          'food_positions': foodPositions.map((p) => {'x': p.x, 'y': p.y}).toList(),
        if (powerUps != null) 'power_ups': powerUps,
      };

      await _hubConnection?.invoke('UpdateGameState', args: [_currentRoomCode, update]);
    } catch (e) {
      if (kDebugMode) {
        print('Error updating game state: $e');
      }
    }
  }

  /// Get available games to join
  Future<List<MultiplayerGame>> getAvailableGames() async {
    try {
      // For now, we don't have a list endpoint, so return empty
      // The backend would need a /multiplayer/available endpoint
      return [];
    } catch (e) {
      if (kDebugMode) {
        print('Error getting available games: $e');
      }
      return [];
    }
  }

  /// Stream of current game updates
  Stream<MultiplayerGame?> get gameStream => _gameStreamController.stream;

  /// Stream of game actions for real-time updates
  Stream<MultiplayerGameAction> get gameActionsStream => _gameActionsController.stream;

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
              logging: (level, message) {
                if (kDebugMode) {
                  print('SignalR [$level]: $message');
                }
              },
            ),
          )
          .withAutomaticReconnect()
          .build();

      // Register event handlers
      _registerEventHandlers();

      await _hubConnection!.start();
      _isConnected = true;

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
    });
  }

  void _handlePlayerJoined(List<Object?>? arguments) {
    if (arguments == null || arguments.isEmpty) return;

    try {
      final data = arguments[0] as Map<String, dynamic>?;
      if (data == null) return;

      // Update current game with new player
      // For now, just notify listeners
      _gameActionsController.add(MultiplayerGameAction(
        actionType: 'player_joined',
        playerId: data['user_id']?.toString() ?? '',
        timestamp: DateTime.now(),
        data: data,
      ));
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

      _gameActionsController.add(MultiplayerGameAction(
        actionType: 'player_left',
        playerId: data['user_id']?.toString() ?? '',
        timestamp: DateTime.now(),
        data: data,
      ));
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

      _gameActionsController.add(MultiplayerGameAction(
        actionType: 'player_ready',
        playerId: data['user_id']?.toString() ?? '',
        timestamp: DateTime.now(),
        data: data,
      ));
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
        status: MultiplayerGameStatus.countdown,
      );
      _gameStreamController.add(_currentGame);

      _gameActionsController.add(MultiplayerGameAction(
        actionType: 'game_starting',
        playerId: '',
        timestamp: DateTime.now(),
        data: data,
      ));
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

      _currentGame = _currentGame?.copyWith(
        status: MultiplayerGameStatus.playing,
      );
      _gameStreamController.add(_currentGame);

      _gameActionsController.add(MultiplayerGameAction(
        actionType: 'game_started',
        playerId: '',
        timestamp: DateTime.now(),
        data: data,
      ));
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

      _gameActionsController.add(MultiplayerGameAction(
        actionType: 'player_moved',
        playerId: data['user_id']?.toString() ?? '',
        timestamp: DateTime.now(),
        data: data,
      ));
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

      _gameActionsController.add(MultiplayerGameAction(
        actionType: 'game_state_updated',
        playerId: '',
        timestamp: DateTime.now(),
        data: data,
      ));
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

      _gameActionsController.add(MultiplayerGameAction(
        actionType: 'player_died',
        playerId: data['user_id']?.toString() ?? '',
        timestamp: DateTime.now(),
        data: data,
      ));
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

      _gameActionsController.add(MultiplayerGameAction(
        actionType: 'game_ended',
        playerId: '',
        timestamp: DateTime.now(),
        data: data,
      ));
    } catch (e) {
      if (kDebugMode) {
        print('Error handling GameEnded: $e');
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

  Position generateFoodPosition(int boardSize, List<MultiplayerPlayer> players) {
    final random = Random();
    Position foodPos;

    do {
      foodPos = Position(
        random.nextInt(boardSize),
        random.nextInt(boardSize),
      );
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
        final boardSize = _currentGame!.boardSize;
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
    _disconnectSignalR();
    _gameStreamController.close();
    _gameActionsController.close();
  }
}
