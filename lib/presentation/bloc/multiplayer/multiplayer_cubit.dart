import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/multiplayer_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/utils/direction.dart';

import 'multiplayer_state.dart';

export 'multiplayer_state.dart';

/// Cubit for managing multiplayer game state
class MultiplayerCubit extends Cubit<MultiplayerState> {
  final MultiplayerService _multiplayerService;
  final UnifiedUserService _userService;
  final AudioService _audioService;
  final HapticService _hapticService;

  // Stream subscriptions
  StreamSubscription? _gameSubscription;
  StreamSubscription? _actionsSubscription;

  MultiplayerCubit({
    required MultiplayerService multiplayerService,
    required UnifiedUserService userService,
    required AudioService audioService,
    required HapticService hapticService,
  })  : _multiplayerService = multiplayerService,
        _userService = userService,
        _audioService = audioService,
        _hapticService = hapticService,
        super(MultiplayerState.initial());

  /// Get current player from the game
  MultiplayerPlayer? get currentPlayer {
    if (state.currentGame == null) return null;
    final currentUserId = _userService.currentUser?.uid;
    if (currentUserId == null) return null;

    return state.currentGame!.getPlayer(currentUserId);
  }

  /// Check if current player is host
  bool get isHost {
    if (state.currentGame == null) return false;
    final currentUserId = _userService.currentUser?.uid;
    if (currentUserId == null) return false;

    return state.currentGame!.players.isNotEmpty &&
        state.currentGame!.players.first.userId == currentUserId;
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

  /// Create a new multiplayer game
  Future<bool> createGame({
    required MultiplayerGameMode mode,
    bool isPrivate = false,
    int maxPlayers = 2,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      _audioService.playSound('button_click');
      _hapticService.lightImpact();

      final gameId = await _multiplayerService.createGame(
        mode: mode,
        isPrivate: isPrivate,
        maxPlayers: maxPlayers,
      );

      if (gameId != null) {
        await _startListening();

        _audioService.playSound('high_score');
        _hapticService.mediumImpact();

        emit(state.copyWith(
          status: MultiplayerStatus.inLobby,
          isLoading: false,
        ));
        return true;
      } else {
        _audioService.playSound('game_over');
        _hapticService.heavyImpact();
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to create game',
        ));
        return false;
      }
    } catch (e) {
      _audioService.playSound('game_over');
      _hapticService.heavyImpact();
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error creating game: $e',
      ));
      return false;
    }
  }

  /// Join a game by ID or room code
  Future<bool> joinGame(String gameIdOrRoomCode) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      _audioService.playSound('button_click');
      _hapticService.lightImpact();

      final success = await _multiplayerService.joinGame(gameIdOrRoomCode);

      if (success) {
        await _startListening();

        _audioService.playSound('high_score');
        _hapticService.mediumImpact();

        emit(state.copyWith(
          status: MultiplayerStatus.inLobby,
          isLoading: false,
        ));
        return true;
      } else {
        _audioService.playSound('game_over');
        _hapticService.heavyImpact();
        emit(state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to join game. Game might be full or not exist.',
        ));
        return false;
      }
    } catch (e) {
      _audioService.playSound('game_over');
      _hapticService.heavyImpact();
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error joining game: $e',
      ));
      return false;
    }
  }

  /// Leave current game
  Future<void> leaveGame() async {
    try {
      await _multiplayerService.leaveGame();
      _stopListening();
      emit(state.copyWith(
        status: MultiplayerStatus.idle,
        clearGame: true,
        clearError: true,
      ));
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

  /// Send direction change
  Future<void> changeDirection(Direction direction) async {
    if (state.currentGame?.status != MultiplayerGameStatus.playing) return;

    try {
      final currentUserId = _userService.currentUser?.uid;
      if (currentUserId == null) return;

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
      final games = await _multiplayerService.getAvailableGames();
      emit(state.copyWith(
        status: MultiplayerStatus.idle,
        availableGames: games,
      ));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error loading available games: $e'));
    }
  }

  /// Quick match - find and join a random available game
  Future<bool> quickMatch(MultiplayerGameMode mode) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await loadAvailableGames();

      // Find a game with the same mode
      final availableGame = state.availableGames
          .where((game) => game.mode == mode && !game.isFull)
          .toList()
        ..shuffle();

      if (availableGame.isNotEmpty) {
        return await joinGame(availableGame.first.id);
      } else {
        return await createGame(mode: mode, isPrivate: false);
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        errorMessage: 'Error in quick match: $e',
      ));
      return false;
    }
  }

  /// Generate new food when eaten
  Future<void> generateNewFood() async {
    await _multiplayerService.generateNewFood();
  }

  /// Check if game should end
  Future<void> checkGameEnd() async {
    await _multiplayerService.checkGameEnd();
  }

  /// Handle food consumption
  Future<void> onFoodEaten(int points) async {
    try {
      _audioService.playSound('eat');
      _hapticService.lightImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling food eaten: $e');
      }
    }
  }

  /// Handle player crash
  Future<void> onPlayerCrash() async {
    try {
      _audioService.playSound('game_over');
      _hapticService.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling player crash: $e');
      }
    }
  }

  /// Handle game victory
  Future<void> onGameWon(int finalScore) async {
    try {
      _audioService.playSound('level_up');
      _hapticService.heavyImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling game victory: $e');
      }
    }
  }

  /// Handle game loss
  Future<void> onGameLost(int finalScore) async {
    try {
      _audioService.playSound('game_over');
      _hapticService.mediumImpact();
    } catch (e) {
      if (kDebugMode) {
        print('Error handling game loss: $e');
      }
    }
  }

  /// Utility methods for UI
  String getPlayerDisplayName(String userId) {
    final player = state.currentGame?.players
        .where((p) => p.userId == userId)
        .toList()
        .firstOrNull;
    return player?.displayName ?? 'Unknown Player';
  }

  PlayerStatus getPlayerStatus(String userId) {
    final player = state.currentGame?.players
        .where((p) => p.userId == userId)
        .toList()
        .firstOrNull;
    return player?.status ?? PlayerStatus.waiting;
  }

  int getPlayerScore(String userId) {
    final player = state.currentGame?.players
        .where((p) => p.userId == userId)
        .toList()
        .firstOrNull;
    return player?.score ?? 0;
  }

  List<Position> getPlayerSnake(String userId) {
    final player = state.currentGame?.players
        .where((p) => p.userId == userId)
        .toList()
        .firstOrNull;
    return player?.snake ?? [];
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

    try {
      _audioService.playSound('game_start');
      _hapticService.mediumImpact();

      final success = await _multiplayerService.startGame();
      if (!success) {
        emit(state.copyWith(errorMessage: 'Failed to start game'));
      }
      return success;
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Error starting game: $e'));
      return false;
    }
  }

  /// Notify that current player died
  Future<void> notifyPlayerDied() async {
    try {
      await _multiplayerService.notifyPlayerDied();
    } catch (e) {
      if (kDebugMode) {
        print('Error notifying player died: $e');
      }
    }
  }

  /// Notify game over with final score
  Future<void> notifyGameOver(int finalScore) async {
    try {
      await _multiplayerService.notifyGameOver(finalScore);
    } catch (e) {
      if (kDebugMode) {
        print('Error notifying game over: $e');
      }
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

        MultiplayerStatus newStatus = state.status;
        if (game.status == MultiplayerGameStatus.playing) {
          newStatus = MultiplayerStatus.playing;
        } else if (game.isFinished) {
          newStatus = MultiplayerStatus.finished;
        } else if (game.status == MultiplayerGameStatus.waiting) {
          newStatus = MultiplayerStatus.inLobby;
        }

        emit(state.copyWith(
          status: newStatus,
          currentGame: game,
        ));
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
  }

  void _stopListening() {
    _gameSubscription?.cancel();
    _actionsSubscription?.cancel();
    _gameSubscription = null;
    _actionsSubscription = null;
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
    _multiplayerService.dispose();
    return super.close();
  }
}
