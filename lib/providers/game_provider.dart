import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/audio_service.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState.initial();
  Timer? _gameTimer;
  final StorageService _storageService = StorageService();
  final AudioService _audioService = AudioService();

  GameState get gameState => _gameState;
  bool get isPlaying => _gameState.status == GameStatus.playing;
  bool get isPaused => _gameState.status == GameStatus.paused;
  bool get isGameOver => _gameState.status == GameStatus.gameOver;

  GameProvider() {
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final highScore = await _storageService.getHighScore();
    _gameState = _gameState.copyWith(highScore: highScore);
    await _audioService.initialize();
    notifyListeners();
  }

  void startGame() {
    _gameState = GameState.initial().copyWith(
      highScore: _gameState.highScore,
      status: GameStatus.playing,
    );
    
    _generateFood();
    _startGameLoop();
    _audioService.playSound('game_start');
    notifyListeners();
  }

  void pauseGame() {
    if (_gameState.status == GameStatus.playing) {
      _gameTimer?.cancel();
      _gameState = _gameState.copyWith(status: GameStatus.paused);
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_gameState.status == GameStatus.paused) {
      _gameState = _gameState.copyWith(status: GameStatus.playing);
      _startGameLoop();
      notifyListeners();
    }
  }

  void togglePause() {
    if (isPlaying) {
      pauseGame();
    } else if (isPaused) {
      resumeGame();
    }
  }

  void changeDirection(Direction newDirection) {
    if (_gameState.status == GameStatus.playing) {
      _gameState.snake.changeDirection(newDirection);
      HapticFeedback.selectionClick();
    }
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(
      Duration(milliseconds: _gameState.gameSpeed),
      (_) => _updateGame(),
    );
  }

  void _updateGame() {
    if (_gameState.status != GameStatus.playing) return;

    final snake = _gameState.snake.copy();
    
    // Check if food exists and if it expired
    if (_gameState.food?.isExpired == true) {
      _generateFood();
    }

    // Check for food collision before moving
    final willEatFood = _gameState.food != null && 
        snake.head.move(snake.currentDirection) == _gameState.food!.position;

    // Move snake
    snake.move(ateFood: willEatFood);

    // Check collisions
    if (snake.checkWallCollision(_gameState.boardWidth, _gameState.boardHeight) ||
        snake.checkSelfCollision()) {
      _gameOver();
      return;
    }

    // Handle food consumption
    if (willEatFood && _gameState.food != null) {
      _consumeFood(_gameState.food!);
      _generateFood();
    }

    _gameState = _gameState.copyWith(
      snake: snake,
      lastMoveTime: DateTime.now(),
    );

    notifyListeners();
  }

  void _consumeFood(Food food) {
    final newScore = _gameState.score + food.type.points;
    int newLevel = _gameState.level;

    // Level up logic
    if (newScore >= _gameState.targetScore && newLevel < 10) {
      newLevel++;
      _audioService.playSound('level_up');
      HapticFeedback.mediumImpact();
    } else {
      _audioService.playSound('eat');
      HapticFeedback.lightImpact();
    }

    _gameState = _gameState.copyWith(
      score: newScore,
      level: newLevel,
    );

    // Update game speed if level changed
    if (newLevel > _gameState.level) {
      _startGameLoop();
    }
  }

  void _generateFood() {
    final food = Food.generateRandom(
      _gameState.boardWidth,
      _gameState.boardHeight,
      _gameState.snake,
    );
    
    _gameState = _gameState.copyWith(food: food);
  }

  void _gameOver() {
    _gameTimer?.cancel();
    
    // Update high score if necessary
    int highScore = _gameState.highScore;
    if (_gameState.score > highScore) {
      highScore = _gameState.score;
      _storageService.saveHighScore(highScore);
      _audioService.playSound('high_score');
    } else {
      _audioService.playSound('game_over');
    }

    _gameState = _gameState.copyWith(
      status: GameStatus.gameOver,
      highScore: highScore,
    );

    HapticFeedback.heavyImpact();
    notifyListeners();
  }

  void resetGame() {
    _gameTimer?.cancel();
    _gameState = GameState.initial().copyWith(
      highScore: _gameState.highScore,
    );
    notifyListeners();
  }

  void backToMenu() {
    _gameTimer?.cancel();
    _gameState = _gameState.copyWith(status: GameStatus.menu);
    notifyListeners();
  }

  // Debug method to increase score (for testing)
  void addDebugScore(int points) {
    if (kDebugMode) {
      _gameState = _gameState.copyWith(
        score: _gameState.score + points,
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}