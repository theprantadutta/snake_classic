import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/services/unified_user_service.dart';
// Services commented out until methods are implemented
// import 'package:snake_classic/services/leaderboard_service.dart';
// import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/utils/direction.dart';

class MultiplayerService {
  static MultiplayerService? _instance;
  final UnifiedUserService _userService = UnifiedUserService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // Services commented out until methods are implemented
  // final LeaderboardService _leaderboardService = LeaderboardService();
  // final NotificationService _notificationService = NotificationService();
  
  // Stream subscriptions
  StreamSubscription? _gameStreamSubscription;
  StreamSubscription? _gameActionsSubscription;
  
  // Current game state
  MultiplayerGame? _currentGame;
  String? _currentGameId;

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
      final currentUserId = _userService.currentUser?.uid;
      final currentUserProfile = _userService.currentUser;
      if (currentUserId == null || currentUserProfile == null) return null;

      final gameId = _firestore.collection('multiplayerGames').doc().id;
      final roomCode = isPrivate ? _generateRoomCode() : null;
      
      final hostPlayer = MultiplayerPlayer(
        userId: currentUserId,
        displayName: currentUserProfile.username.isNotEmpty ? currentUserProfile.username : currentUserProfile.displayName,
        photoUrl: currentUserProfile.photoURL,
        status: PlayerStatus.waiting,
        snake: _generateInitialSnakePosition(0, mode.defaultSettings['boardSize'] ?? 20),
        currentDirection: Direction.right,
      );

      final game = MultiplayerGame(
        id: gameId,
        mode: mode,
        status: MultiplayerGameStatus.waiting,
        players: [hostPlayer],
        createdAt: DateTime.now(),
        maxPlayers: maxPlayers,
        isPrivate: isPrivate,
        roomCode: roomCode,
        gameSettings: mode.defaultSettings,
      );

      await _firestore.collection('multiplayerGames').doc(gameId).set(game.toJson());
      
      // Start listening to this game
      await joinGame(gameId);
      
      return gameId;
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
      final currentUserId = _userService.currentUser?.uid;
      final currentUserProfile = _userService.currentUser;
      if (currentUserId == null || currentUserProfile == null) return false;

      // First, try to find the game by ID
      DocumentSnapshot gameDoc = await _firestore
          .collection('multiplayerGames')
          .doc(gameIdOrRoomCode)
          .get();

      // If not found, try to find by room code
      if (!gameDoc.exists) {
        final roomQuery = await _firestore
            .collection('multiplayerGames')
            .where('roomCode', isEqualTo: gameIdOrRoomCode.toUpperCase())
            .where('status', whereIn: [MultiplayerGameStatus.waiting.name, MultiplayerGameStatus.starting.name])
            .limit(1)
            .get();

        if (roomQuery.docs.isEmpty) return false;
        gameDoc = roomQuery.docs.first;
      }

      if (!gameDoc.exists) return false;

      final game = MultiplayerGame.fromJson(gameDoc.data() as Map<String, dynamic>);
      
      // Check if game is joinable
      if (game.isFull || game.isFinished) return false;
      
      // Check if user is already in the game
      if (game.getPlayer(currentUserId) != null) {
        _currentGameId = game.id;
        _currentGame = game;
        _startListeningToGame();
        return true;
      }

      // Add player to the game
      final playerIndex = game.players.length;
      final newPlayer = MultiplayerPlayer(
        userId: currentUserId,
        displayName: currentUserProfile.username.isNotEmpty ? currentUserProfile.username : (currentUserProfile.displayName.isNotEmpty ? currentUserProfile.displayName : 'Player ${playerIndex + 1}'),
        photoUrl: currentUserProfile.photoURL,
        status: PlayerStatus.waiting,
        snake: _generateInitialSnakePosition(playerIndex, game.gameSettings['boardSize'] ?? 20),
        currentDirection: Direction.right,
      );

      final updatedPlayers = [...game.players, newPlayer];
      
      await _firestore.collection('multiplayerGames').doc(game.id).update({
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
      });

      _currentGameId = game.id;
      _currentGame = game.copyWith(players: updatedPlayers);
      _startListeningToGame();
      
      return true;
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
      final currentUserId = _userService.currentUser?.uid;
      if (currentUserId == null || _currentGame == null) return;

      // Remove player from the game or mark as disconnected
      final updatedPlayers = _currentGame!.players
          .where((player) => player.userId != currentUserId)
          .toList();

      if (updatedPlayers.isEmpty) {
        // If no players left, delete the game
        await _firestore.collection('multiplayerGames').doc(_currentGameId!).delete();
      } else {
        // Update game without this player
        await _firestore.collection('multiplayerGames').doc(_currentGameId!).update({
          'players': updatedPlayers.map((p) => p.toJson()).toList(),
          'status': MultiplayerGameStatus.abandoned.name,
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error leaving game: $e');
      }
    } finally {
      _stopListeningToGame();
      _currentGame = null;
      _currentGameId = null;
    }
  }

  /// Mark player as ready
  Future<bool> markPlayerReady() async {
    try {
      final currentUserId = _userService.currentUser?.uid;
      if (currentUserId == null || _currentGame == null) return false;

      final updatedPlayers = _currentGame!.players.map((player) {
        if (player.userId == currentUserId) {
          return player.copyWith(status: PlayerStatus.ready);
        }
        return player;
      }).toList();

      await _firestore.collection('multiplayerGames').doc(_currentGameId!).update({
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
      });

      // Check if all players are ready to start the game
      if (updatedPlayers.length >= 2 && updatedPlayers.every((p) => p.status == PlayerStatus.ready)) {
        await _startGame();
      }

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
      if (_currentGameId == null) return;

      // Add action to game actions subcollection
      await _firestore
          .collection('multiplayerGames')
          .doc(_currentGameId!)
          .collection('actions')
          .add(action.toJson());

      // For direction changes, also update the player's current direction in the main game document
      if (action.actionType == 'changeDirection') {
        await _updatePlayerDirection(action.playerId, action.data['direction']);
      }
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
      final currentUserId = _userService.currentUser?.uid;
      if (currentUserId == null || _currentGame == null) return;

      final updatedPlayers = _currentGame!.players.map((player) {
        if (player.userId == currentUserId) {
          return player.copyWith(
            snake: snake,
            score: score,
            status: status,
            lastUpdate: DateTime.now(),
          );
        }
        return player;
      }).toList();

      await _firestore.collection('multiplayerGames').doc(_currentGameId!).update({
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
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
      final query = await _firestore
          .collection('multiplayerGames')
          .where('status', isEqualTo: MultiplayerGameStatus.waiting.name)
          .where('isPrivate', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return query.docs
          .map((doc) => MultiplayerGame.fromJson(doc.data()))
          .where((game) => !game.isFull)
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting available games: $e');
      }
      return [];
    }
  }

  /// Stream of current game updates
  Stream<MultiplayerGame?> get gameStream {
    if (_currentGameId == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('multiplayerGames')
        .doc(_currentGameId!)
        .snapshots()
        .map((doc) {
      if (!doc.exists) return null;
      final game = MultiplayerGame.fromJson(doc.data()!);
      _currentGame = game;
      return game;
    });
  }

  /// Stream of game actions for real-time updates
  Stream<MultiplayerGameAction> get gameActionsStream {
    if (_currentGameId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('multiplayerGames')
        .doc(_currentGameId!)
        .collection('actions')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .expand((snapshot) => snapshot.docChanges)
        .where((change) => change.type == DocumentChangeType.added)
        .map((change) => MultiplayerGameAction.fromJson(change.doc.data()!));
  }

  // Private helper methods

  void _startListeningToGame() {
    _stopListeningToGame();
    
    // Listen to game updates
    _gameStreamSubscription = gameStream.listen((game) {
      if (game != null) {
        _currentGame = game;
        
        // Check for game end conditions
        if (game.isFinished) {
          _handleGameFinished(game);
        }
      }
    });

    // Listen to game actions
    _gameActionsSubscription = gameActionsStream.listen((action) {
      _handleGameAction(action);
    });
  }

  void _stopListeningToGame() {
    _gameStreamSubscription?.cancel();
    _gameActionsSubscription?.cancel();
    _gameStreamSubscription = null;
    _gameActionsSubscription = null;
  }

  Future<void> _startGame() async {
    try {
      if (_currentGame == null) return;

      // Initialize game state
      final boardSize = _currentGame!.gameSettings['boardSize'] ?? 20;
      final initialFood = _generateFoodPosition(boardSize, _currentGame!.players);

      final updatedPlayers = _currentGame!.players.map((player) {
        return player.copyWith(status: PlayerStatus.playing);
      }).toList();

      await _firestore.collection('multiplayerGames').doc(_currentGameId!).update({
        'status': MultiplayerGameStatus.playing.name,
        'startedAt': FieldValue.serverTimestamp(),
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
        'foodPosition': initialFood.toJson(),
      });
      
      // Update current game instance
      _currentGame = _currentGame!.copyWith(
        status: MultiplayerGameStatus.playing,
        players: updatedPlayers,
        foodPosition: initialFood,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error starting game: $e');
      }
    }
  }

  Future<void> _updatePlayerDirection(String playerId, String directionName) async {
    try {
      if (_currentGame == null) return;

      final direction = Direction.values.firstWhere((d) => d.name == directionName);
      final updatedPlayers = _currentGame!.players.map((player) {
        if (player.userId == playerId) {
          return player.copyWith(currentDirection: direction);
        }
        return player;
      }).toList();

      await _firestore.collection('multiplayerGames').doc(_currentGameId!).update({
        'players': updatedPlayers.map((p) => p.toJson()).toList(),
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error updating player direction: $e');
      }
    }
  }

  void _handleGameAction(MultiplayerGameAction action) {
    // Handle real-time game actions
    if (kDebugMode) {
      print('Game action received: ${action.actionType} from ${action.playerId}');
    }
  }

  void _handleGameFinished(MultiplayerGame game) async {
    // Handle game finished
    if (kDebugMode) {
      print('Game finished: ${game.id}');
    }
    
    try {
      // Update leaderboards with final scores
      for (final player in game.players) {
        if (player.score > 0) {
          // await _leaderboardService.submitScore( // TODO: Implement
          //   player.userId, 
          //   player.displayName, 
          //   player.score,
          //   gameMode: 'multiplayer_${game.mode.name}'
          // );
        }
        
        // Send game finished notification to players
        if (game.winnerId == player.userId) {
          // _notificationService.sendGameWonNotification(player.userId, player.score); // TODO: Implement
        } else {
          // _notificationService.sendGameLostNotification(player.userId, player.score); // TODO: Implement
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error handling game finished: $e');
      }
    }
  }

  List<Position> _generateInitialSnakePosition(int playerIndex, int boardSize) {
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

  Position _generateFoodPosition(int boardSize, List<MultiplayerPlayer> players) {
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

  String _generateRoomCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Generate new food position when eaten
  Future<void> generateNewFood() async {
    try {
      if (_currentGame == null) return;
      
      final boardSize = _currentGame!.gameSettings['boardSize'] ?? 20;
      final newFood = _generateFoodPosition(boardSize, _currentGame!.players);
      
      await _firestore.collection('multiplayerGames').doc(_currentGameId!).update({
        'foodPosition': newFood.toJson(),
      });
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
        
        await _firestore.collection('multiplayerGames').doc(_currentGameId!).update({
          'status': MultiplayerGameStatus.finished.name,
          'finishedAt': FieldValue.serverTimestamp(),
          'winnerId': winnerId,
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
    _stopListeningToGame();
  }
}