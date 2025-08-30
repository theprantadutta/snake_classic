import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/utils/constants.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState.initial();
  Timer? _gameTimer;
  Timer? _animationTimer; // Use Timer instead of Ticker for simplicity
  final StorageService _storageService = StorageService();
  final AudioService _audioService = AudioService();
  
  // Smooth movement interpolation
  DateTime? _lastGameUpdate;
  double _moveProgress = 0.0; // 0.0 to 1.0 progress between moves
  GameState? _previousGameState;

  GameState get gameState => _gameState;
  bool get isPlaying => _gameState.status == GameStatus.playing;
  bool get isPaused => _gameState.status == GameStatus.paused;
  bool get isGameOver => _gameState.status == GameStatus.gameOver;
  
  // Smooth movement properties
  double get moveProgress => _moveProgress;
  GameState? get previousGameState => _previousGameState;

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
    
    // Reset smooth movement state
    _previousGameState = null;
    _moveProgress = 0.0;
    _lastGameUpdate = DateTime.now();
    
    _generateFood();
    _startGameLoop();
    _startSmoothAnimation();
    _audioService.playSound('game_start');
    notifyListeners();
  }

  void pauseGame() {
    if (_gameState.status == GameStatus.playing) {
      _gameTimer?.cancel();
      _animationTimer?.cancel();
      _gameState = _gameState.copyWith(status: GameStatus.paused);
      notifyListeners();
    }
  }

  void resumeGame() {
    if (_gameState.status == GameStatus.paused) {
      _gameState = _gameState.copyWith(status: GameStatus.playing);
      _lastGameUpdate = DateTime.now(); // Reset timing after pause
      _startGameLoop();
      _startSmoothAnimation();
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

    // Store previous state for smooth interpolation
    _previousGameState = _gameState;
    
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

    // Check collisions with specific crash reasons
    final wallCollision = snake.checkWallCollision(_gameState.boardWidth, _gameState.boardHeight);
    final selfCollision = snake.checkSelfCollision();
    
    if (wallCollision || selfCollision) {
      final crashReason = wallCollision ? CrashReason.wallCollision : CrashReason.selfCollision;
      _handleCrash(crashReason);
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

    // Reset interpolation progress
    _moveProgress = 0.0;
    _lastGameUpdate = DateTime.now();

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
  
  void _startSmoothAnimation() {
    _animationTimer?.cancel();
    // Run at 60FPS (approximately 16ms intervals)
    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 16),
      (_) => _updateSmoothAnimation(),
    );
  }
  
  void _updateSmoothAnimation() {
    if (_gameState.status != GameStatus.playing || _lastGameUpdate == null) {
      return;
    }
    
    final now = DateTime.now();
    final timeSinceLastUpdate = now.difference(_lastGameUpdate!).inMilliseconds;
    final gameSpeed = _gameState.gameSpeed;
    
    // Calculate interpolation progress (0.0 to 1.0)
    final newProgress = (timeSinceLastUpdate / gameSpeed).clamp(0.0, 1.0);
    
    // Only update if progress changed meaningfully (reduces repaints)
    if ((newProgress - _moveProgress).abs() > 0.01) {
      _moveProgress = newProgress;
      notifyListeners();
    }
  }

  void _handleCrash(CrashReason crashReason) {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    
    // First show crash feedback with reason
    _gameState = _gameState.copyWith(
      status: GameStatus.crashed,
      crashReason: crashReason,
    );
    
    // Play crash sound and haptic feedback immediately
    _audioService.playSound('game_over');
    HapticFeedback.heavyImpact();
    notifyListeners();
    
    // After crash feedback duration, proceed to game over screen
    Future.delayed(GameConstants.crashFeedbackDuration, () {
      if (_gameState.status == GameStatus.crashed) {
        _gameOver();
      }
    });
  }
  
  void _gameOver() {
    // Update high score if necessary
    int highScore = _gameState.highScore;
    if (_gameState.score > highScore) {
      highScore = _gameState.score;
      _storageService.saveHighScore(highScore);
      _audioService.playSound('high_score');
    }

    _gameState = _gameState.copyWith(
      status: GameStatus.gameOver,
      highScore: highScore,
      crashReason: null, // Clear crash reason
    );

    notifyListeners();
  }
  
  // Method to skip crash feedback and go directly to game over
  void skipCrashFeedback() {
    if (_gameState.status == GameStatus.crashed) {
      _gameOver();
    }
  }

  void resetGame() {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _gameState = GameState.initial().copyWith(
      highScore: _gameState.highScore,
    );
    _previousGameState = null;
    _moveProgress = 0.0;
    notifyListeners();
  }

  void backToMenu() {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _gameState = _gameState.copyWith(status: GameStatus.menu);
    _previousGameState = null;
    _moveProgress = 0.0;
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
    _animationTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}