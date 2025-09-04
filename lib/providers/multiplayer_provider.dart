import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/services/multiplayer_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
// Services commented out until methods are implemented
// import 'package:snake_classic/services/achievement_service.dart';
// import 'package:snake_classic/services/statistics_service.dart';
// import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/utils/direction.dart';

class MultiplayerProvider extends ChangeNotifier {
  final MultiplayerService _multiplayerService = MultiplayerService();
  final UnifiedUserService _userService = UnifiedUserService();
  final AudioService _audioService = AudioService();
  final HapticService _hapticService = HapticService();
  // Services commented out until methods are implemented
  // final AchievementService _achievementService = AchievementService();
  // final StatisticsService _statisticsService = StatisticsService();
  // final NotificationService _notificationService = NotificationService();
  
  // Current game state
  MultiplayerGame? _currentGame;
  List<MultiplayerGame> _availableGames = [];
  bool _isLoading = false;
  String? _error;
  
  // Stream subscriptions
  StreamSubscription? _gameSubscription;
  StreamSubscription? _actionsSubscription;

  // Getters
  MultiplayerGame? get currentGame => _currentGame;
  List<MultiplayerGame> get availableGames => _availableGames;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isInGame => _currentGame != null;
  bool get canStartGame => _currentGame?.canStart ?? false;
  
  MultiplayerPlayer? get currentPlayer {
    if (_currentGame == null) return null;
    final currentUserId = _userService.currentUser?.uid;
    if (currentUserId == null) return null;
    
    return _currentGame!.getPlayer(currentUserId);
  }

  /// Create a new multiplayer game
  Future<bool> createGame({
    required MultiplayerGameMode mode,
    bool isPrivate = false,
    int maxPlayers = 2,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Play creation sound
      _audioService.playSound('button_click');
      _hapticService.lightImpact();
      
      final gameId = await _multiplayerService.createGame(
        mode: mode,
        isPrivate: isPrivate,
        maxPlayers: maxPlayers,
      );

      if (gameId != null) {
        await _startListening();
        
        // Play success sound
        _audioService.playSound('high_score');
        _hapticService.mediumImpact();
        
        // Track statistics
        // _statisticsService.incrementMultiplayerGamesCreated(); // TODO: Implement
        
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to create game');
        _audioService.playSound('game_over');
        _hapticService.heavyImpact();
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error creating game: $e');
      _audioService.playSound('game_over');
      _hapticService.heavyImpact();
      _setLoading(false);
      return false;
    }
  }

  /// Join a game by ID or room code
  Future<bool> joinGame(String gameIdOrRoomCode) async {
    _setLoading(true);
    _clearError();

    try {
      // Play join attempt sound
      _audioService.playSound('button_click');
      _hapticService.lightImpact();
      
      final success = await _multiplayerService.joinGame(gameIdOrRoomCode);

      if (success) {
        await _startListening();
        
        // Play success sound
        _audioService.playSound('high_score');
        _hapticService.mediumImpact();
        
        // Track statistics
        // _statisticsService.incrementMultiplayerGamesJoined(); // TODO: Implement
        
        _setLoading(false);
        return true;
      } else {
        _setError('Failed to join game. Game might be full or not exist.');
        _audioService.playSound('game_over');
        _hapticService.heavyImpact();
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Error joining game: $e');
      _audioService.playSound('game_over');
      _hapticService.heavyImpact();
      _setLoading(false);
      return false;
    }
  }

  /// Leave current game
  Future<void> leaveGame() async {
    try {
      await _multiplayerService.leaveGame();
      _stopListening();
      _currentGame = null;
      _clearError();
      notifyListeners();
    } catch (e) {
      _setError('Error leaving game: $e');
    }
  }

  /// Mark current player as ready
  Future<bool> markPlayerReady() async {
    try {
      // Play ready sound
      _audioService.playSound('button_click');
      _hapticService.lightImpact();
      
      final success = await _multiplayerService.markPlayerReady();
      if (success) {
        _audioService.playSound('high_score');
        _hapticService.mediumImpact();
      } else {
        _setError('Failed to mark player as ready');
        _audioService.playSound('game_over');
      }
      return success;
    } catch (e) {
      _setError('Error marking player ready: $e');
      _audioService.playSound('game_over');
      return false;
    }
  }

  /// Send direction change
  Future<void> changeDirection(Direction direction) async {
    if (_currentGame?.status != MultiplayerGameStatus.playing) return;

    try {
      final currentUserId = _userService.currentUser?.uid;
      if (currentUserId == null) return;
      
      // Play swipe sound and haptic feedback
      _audioService.playSound('button_click');
      _hapticService.lightImpact();
      
      final action = MultiplayerGameAction.changeDirection(
        currentUserId,
        direction,
      );
      await _multiplayerService.sendPlayerAction(action);
    } catch (e) {
      if (kDebugMode) {
        print('Error changing direction: $e');
      }
    }
  }

  /// Update player's game state (position, score, status)
  Future<void> updateGameState({
    required List<Position> snake,
    required int score,
    required PlayerStatus status,
  }) async {
    try {
      await _multiplayerService.updatePlayerGameState(
        snake: snake,
        score: score,
        status: status,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Error updating game state: $e');
      }
    }
  }

  /// Load available games
  Future<void> loadAvailableGames() async {
    try {
      _availableGames = await _multiplayerService.getAvailableGames();
      notifyListeners();
    } catch (e) {
      _setError('Error loading available games: $e');
    }
  }

  /// Quick match - find and join a random available game
  Future<bool> quickMatch(MultiplayerGameMode mode) async {
    _setLoading(true);
    _clearError();

    try {
      await loadAvailableGames();
      
      // Find a game with the same mode
      final availableGame = _availableGames
          .where((game) => game.mode == mode && !game.isFull)
          .toList()
          ..shuffle();

      if (availableGame.isNotEmpty) {
        // Join the first available game
        return await joinGame(availableGame.first.id);
      } else {
        // Create a new game if no available games
        return await createGame(mode: mode, isPrivate: false);
      }
    } catch (e) {
      _setError('Error in quick match: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Get opponent player
  MultiplayerPlayer? getOpponent() {
    if (_currentGame == null) return null;
    final currentUserId = _userService.currentUser?.uid;
    if (currentUserId == null) return null;
    
    final opponents = _currentGame!.players
        .where((player) => player.userId != currentUserId)
        .toList();
        
    return opponents.isNotEmpty ? opponents.first : null;
  }

  /// Check if current player is host
  bool get isHost {
    if (_currentGame == null) return false;
    final currentUserId = _userService.currentUser?.uid;
    if (currentUserId == null) return false;
    
    return _currentGame!.players.isNotEmpty && 
           _currentGame!.players.first.userId == currentUserId;
  }

  /// Get game duration
  Duration? get gameDuration {
    if (_currentGame?.startedAt == null) return null;
    return DateTime.now().difference(_currentGame!.startedAt!);
  }

  /// Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  Future<void> _startListening() async {
    _stopListening();

    // Listen to game updates
    _gameSubscription = _multiplayerService.gameStream.listen(
      (game) {
        _currentGame = game;
        notifyListeners();
      },
      onError: (error) {
        _setError('Game stream error: $error');
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
  }

  void _stopListening() {
    _gameSubscription?.cancel();
    _actionsSubscription?.cancel();
    _gameSubscription = null;
    _actionsSubscription = null;
  }

  void _handleGameAction(MultiplayerGameAction action) {
    // Handle real-time actions from other players
    if (kDebugMode) {
      print('Received action: ${action.actionType} from ${action.playerId}');
    }
    
    // Actions are already reflected in the game state through Firestore
    // This method can be used for immediate UI feedback or sound effects
    notifyListeners();
  }

  @override
  void dispose() {
    _stopListening();
    _multiplayerService.dispose();
    super.dispose();
  }

  /// Utility methods for UI
  String getPlayerDisplayName(String userId) {
    final player = _currentGame?.players
        .where((p) => p.userId == userId)
        .toList()
        .firstOrNull;
    return player?.displayName ?? 'Unknown Player';
  }

  PlayerStatus getPlayerStatus(String userId) {
    final player = _currentGame?.players
        .where((p) => p.userId == userId)
        .toList()
        .firstOrNull;
    return player?.status ?? PlayerStatus.waiting;
  }

  int getPlayerScore(String userId) {
    final player = _currentGame?.players
        .where((p) => p.userId == userId)
        .toList()
        .firstOrNull;
    return player?.score ?? 0;
  }

  List<Position> getPlayerSnake(String userId) {
    final player = _currentGame?.players
        .where((p) => p.userId == userId)
        .toList()
        .firstOrNull;
    return player?.snake ?? [];
  }

  /// Game state helpers
  bool get isWaitingForPlayers => 
      _currentGame?.status == MultiplayerGameStatus.waiting && 
      !_currentGame!.isFull;

  bool get isReadyToStart => 
      _currentGame?.canStart ?? false;

  bool get isGameActive => 
      _currentGame?.status == MultiplayerGameStatus.playing;

  bool get isGameFinished => 
      _currentGame?.isFinished ?? false;

  String? get winner {
    if (_currentGame?.winnerId == null) return null;
    return getPlayerDisplayName(_currentGame!.winnerId!);
  }

  /// Format room code for display
  String? get formattedRoomCode {
    final code = _currentGame?.roomCode;
    if (code == null) return null;
    
    // Format as XXX-XXX
    if (code.length == 6) {
      return '${code.substring(0, 3)}-${code.substring(3)}';
    }
    return code;
  }
  
  /// Generate new food when eaten
  Future<void> generateNewFood() async {
    await _multiplayerService.generateNewFood();
  }
  
  /// Check if game should end
  Future<void> checkGameEnd() async {
    await _multiplayerService.checkGameEnd();
  }
  
  /// Handle food consumption with audio and achievement tracking
  Future<void> onFoodEaten(int points) async {
    try {
      // Play food consumption sound
      _audioService.playSound('eat');
      _hapticService.lightImpact();
      
      // Track statistics
      // _statisticsService.incrementFoodEaten(); // TODO: Implement
      // _statisticsService.addScore(points); // TODO: Implement
      
      // Check for achievements
      await _checkFoodAchievements(points);
      
    } catch (e) {
      if (kDebugMode) {
        print('Error handling food eaten: $e');
      }
    }
  }
  
  /// Handle player crash with effects
  Future<void> onPlayerCrash() async {
    try {
      // Play crash sound
      _audioService.playSound('game_over');
      _hapticService.heavyImpact();
      
      // Track statistics
      // _statisticsService.incrementGamesCrashed(); // TODO: Implement
      
    } catch (e) {
      if (kDebugMode) {
        print('Error handling player crash: $e');
      }
    }
  }
  
  /// Handle game victory
  Future<void> onGameWon(int finalScore) async {
    try {
      // Play victory sound
      _audioService.playSound('level_up');
      _hapticService.heavyImpact();
      
      // Track statistics
      // _statisticsService.incrementGamesWon(); // TODO: Implement
      // _statisticsService.recordHighScore(finalScore); // TODO: Implement
      
      // Check for achievements
      await _checkVictoryAchievements(finalScore);
      
      // Send victory notification
      // _notificationService.showVictoryNotification('Multiplayer Victory!', 'You won with $finalScore points!'); // TODO: Implement
      
    } catch (e) {
      if (kDebugMode) {
        print('Error handling game victory: $e');
      }
    }
  }
  
  /// Handle game loss
  Future<void> onGameLost(int finalScore) async {
    try {
      // Play loss sound
      _audioService.playSound('game_over');
      _hapticService.mediumImpact();
      
      // Track statistics
      // _statisticsService.incrementGamesLost(); // TODO: Implement
      
    } catch (e) {
      if (kDebugMode) {
        print('Error handling game loss: $e');
      }
    }
  }
  
  /// Check for food-related achievements
  Future<void> _checkFoodAchievements(int points) async {
    try {
      if (points >= 50) {
        // await _achievementService.unlockAchievement('special_food_master'); // TODO: Implement
      }
      if (points >= 25) {
        // await _achievementService.unlockAchievement('bonus_food_hunter'); // TODO: Implement
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking food achievements: $e');
      }
    }
  }
  
  /// Check for victory-related achievements
  Future<void> _checkVictoryAchievements(int finalScore) async {
    try {
      // await _achievementService.unlockAchievement('multiplayer_winner'); // TODO: Implement
      
      if (finalScore >= 500) {
        // await _achievementService.unlockAchievement('multiplayer_master'); // TODO: Implement
      }
      if (finalScore >= 1000) {
        // await _achievementService.unlockAchievement('multiplayer_legend'); // TODO: Implement
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error checking victory achievements: $e');
      }
    }
  }
}