import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/services/api_service.dart';

class MultiplayerService {
  static MultiplayerService? _instance;
  final ApiService _apiService = ApiService();

  // WebSocket connection
  WebSocketChannel? _channel;
  StreamSubscription? _wsSubscription;

  // Current game state
  MultiplayerGame? _currentGame;
  String? _currentGameId;

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
  bool get isInGame => _currentGame != null;

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
      if (gameId != null) {
        _currentGameId = gameId.toString();
        await _connectWebSocket(_currentGameId!);
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
      if (gameId != null) {
        _currentGameId = gameId.toString();
        await _connectWebSocket(_currentGameId!);
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
      _sendWebSocketMessage({'action': 'leave'});
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving game: $e');
      }
    } finally {
      _disconnectWebSocket();
      _currentGame = null;
      _currentGameId = null;
      _gameStreamController.add(null);
    }
  }

  /// Mark player as ready
  Future<bool> markPlayerReady() async {
    try {
      _sendWebSocketMessage({'action': 'ready'});
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error marking player ready: $e');
      }
      return false;
    }
  }

  /// Send player action (direction change, game update)
  Future<void> sendPlayerAction(MultiplayerGameAction action) async {
    try {
      _sendWebSocketMessage({
        'action': action.actionType,
        'data': action.data,
        'timestamp': action.timestamp.toIso8601String(),
      });
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
      _sendWebSocketMessage({
        'action': 'update_state',
        'snake': snake.map((p) => p.toJson()).toList(),
        'score': score,
        'status': status.name,
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating player game state: $e');
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

  // WebSocket management

  Future<void> _connectWebSocket(String gameId) async {
    try {
      final wsUrl = _apiService.getMultiplayerWebSocketUrl(gameId);

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _wsSubscription = _channel!.stream.listen(
        _handleWebSocketMessage,
        onError: _handleWebSocketError,
        onDone: _handleWebSocketDone,
      );

      if (kDebugMode) {
        print('Connected to multiplayer WebSocket: $wsUrl');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error connecting to WebSocket: $e');
      }
    }
  }

  void _disconnectWebSocket() {
    _wsSubscription?.cancel();
    _wsSubscription = null;
    _channel?.sink.close();
    _channel = null;
  }

  void _sendWebSocketMessage(Map<String, dynamic> message) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(message));
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
      final data = jsonDecode(message.toString());
      final type = data['type'] as String?;

      switch (type) {
        case 'game_state':
          _currentGame = MultiplayerGame.fromJson(data['game']);
          _gameStreamController.add(_currentGame);
          break;

        case 'player_action':
          final action = MultiplayerGameAction.fromJson(data);
          _gameActionsController.add(action);
          break;

        case 'game_started':
          _currentGame = _currentGame?.copyWith(
            status: MultiplayerGameStatus.playing,
          );
          _gameStreamController.add(_currentGame);
          break;

        case 'game_ended':
          _currentGame = _currentGame?.copyWith(
            status: MultiplayerGameStatus.finished,
            winnerId: data['winner_id'],
          );
          _gameStreamController.add(_currentGame);
          break;

        case 'player_joined':
        case 'player_left':
        case 'player_ready':
          // Update game state with new player info
          if (data['game'] != null) {
            _currentGame = MultiplayerGame.fromJson(data['game']);
            _gameStreamController.add(_currentGame);
          }
          break;

        case 'food_eaten':
          // Handle food position update
          if (data['new_food_position'] != null) {
            final newFood = Position.fromJson(data['new_food_position']);
            _currentGame = _currentGame?.copyWith(foodPosition: newFood);
            _gameStreamController.add(_currentGame);
          }
          break;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling WebSocket message: $e');
      }
    }
  }

  void _handleWebSocketError(dynamic error) {
    if (kDebugMode) {
      print('WebSocket error: $error');
    }
  }

  void _handleWebSocketDone() {
    if (kDebugMode) {
      print('WebSocket connection closed');
    }
    _currentGame = null;
    _currentGameId = null;
    _gameStreamController.add(null);
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
      _sendWebSocketMessage({'action': 'food_eaten'});
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

        _sendWebSocketMessage({
          'action': 'game_over',
          'winner_id': winnerId,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking game end: $e');
      }
    }
  }

  /// Dispose the service
  void dispose() {
    _disconnectWebSocket();
    _gameStreamController.close();
    _gameActionsController.close();
  }
}
