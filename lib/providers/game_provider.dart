import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/auth_service.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/utils/constants.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState.initial();
  Timer? _gameTimer;
  Timer? _animationTimer; // Use Timer instead of Ticker for simplicity
  final StorageService _storageService = StorageService();
  final AudioService _audioService = AudioService();
  final AuthService _authService = AuthService();
  final AchievementService _achievementService = AchievementService();
  
  // Smooth movement interpolation
  DateTime? _lastGameUpdate;
  double _moveProgress = 0.0; // 0.0 to 1.0 progress between moves
  GameState? _previousGameState;

  GameState get gameState => _gameState;
  bool get isPlaying => _gameState.status == GameStatus.playing;
  bool get isPaused => _gameState.status == GameStatus.paused;
  bool get isGameOver => _gameState.status == GameStatus.gameOver;
  Duration get crashFeedbackDuration => _crashFeedbackDuration;
  
  // Smooth movement properties
  double get moveProgress => _moveProgress;
  GameState? get previousGameState => _previousGameState;
  
  // Achievement tracking
  DateTime? _gameStartTime;
  final Set<String> _foodTypesEatenThisGame = {};
  int _consecutiveGamesWithoutWallHits = 0;
  bool _hitWallThisGame = false;
  bool _hitSelfThisGame = false;
  
  // Power-up tracking
  Timer? _powerUpTimer;
  int _powerUpsCollectedThisGame = 0;
  
  // Dynamic crash feedback duration
  Duration _crashFeedbackDuration = GameConstants.defaultCrashFeedbackDuration;

  GameProvider() {
    _initializeGame();
  }

  Future<void> _initializeGame() async {
    final highScore = await _storageService.getHighScore();
    final boardSize = await _storageService.getBoardSize();
    _crashFeedbackDuration = await _storageService.getCrashFeedbackDuration();
    _gameState = _gameState.copyWith(
      highScore: highScore,
      boardWidth: boardSize.width,
      boardHeight: boardSize.height,
    );
    await _audioService.initialize();
    await _achievementService.initialize();
    notifyListeners();
  }

  void startGame() {
    _gameState = GameState.initial().copyWith(
      highScore: _gameState.highScore,
      boardWidth: _gameState.boardWidth,
      boardHeight: _gameState.boardHeight,
      status: GameStatus.playing,
    );
    
    // Reset smooth movement state
    _previousGameState = null;
    _moveProgress = 0.0;
    _lastGameUpdate = DateTime.now();
    
    // Reset achievement tracking
    _gameStartTime = DateTime.now();
    _foodTypesEatenThisGame.clear();
    _hitWallThisGame = false;
    _hitSelfThisGame = false;
    _powerUpsCollectedThisGame = 0;
    
    _generateFood();
    _startGameLoop();
    _startSmoothAnimation();
    _startPowerUpTimer();
    _audioService.playSound('game_start');
    notifyListeners();
  }

  void pauseGame() {
    if (_gameState.status == GameStatus.playing) {
      _gameTimer?.cancel();
      _animationTimer?.cancel();
      _powerUpTimer?.cancel();
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
      _startPowerUpTimer();
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
    
    // Check if power-up exists and if it expired
    if (_gameState.powerUp?.isExpired == true) {
      _gameState = _gameState.clearPowerUp();
    }
    
    // Remove expired active power-ups
    _gameState = _gameState.removeExpiredPowerUps();

    // Check for food collision before moving
    final willEatFood = _gameState.food != null && 
        snake.head.move(snake.currentDirection) == _gameState.food!.position;
        
    // Check for power-up collision before moving
    final willCollectPowerUp = _gameState.powerUp != null && 
        snake.head.move(snake.currentDirection) == _gameState.powerUp!.position;

    // Move snake
    snake.move(ateFood: willEatFood);

    // Check collisions with specific crash reasons (unless invincible)
    final wallCollision = !_gameState.hasInvincibility && 
        snake.checkWallCollision(_gameState.boardWidth, _gameState.boardHeight);
    final selfCollision = !_gameState.hasInvincibility && snake.checkSelfCollision();
    
    if (wallCollision || selfCollision) {
      // Track collision types for achievements
      if (wallCollision) _hitWallThisGame = true;
      if (selfCollision) _hitSelfThisGame = true;
      
      final crashReason = wallCollision ? CrashReason.wallCollision : CrashReason.selfCollision;
      final crashPosition = snake.head;
      final collisionBodyPart = selfCollision ? snake.getSelfCollisionBodyPart() : null;
      
      _handleCrash(crashReason, crashPosition: crashPosition, collisionBodyPart: collisionBodyPart);
      return;
    }

    // Handle food consumption
    if (willEatFood && _gameState.food != null) {
      _consumeFood(_gameState.food!);
      _generateFood();
    }
    
    // Handle power-up collection
    if (willCollectPowerUp && _gameState.powerUp != null) {
      _collectPowerUp(_gameState.powerUp!);
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
    final basePoints = food.type.points;
    final multipliedPoints = basePoints * _gameState.scoreMultiplier;
    final newScore = _gameState.score + multipliedPoints;
    int newLevel = _gameState.level;

    // Track food types for achievements
    _foodTypesEatenThisGame.add(food.type.name);

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
  
  void _generatePowerUp() {
    final powerUp = PowerUp.generateRandom(
      _gameState.boardWidth,
      _gameState.boardHeight,
      _gameState.snake,
      foodPosition: _gameState.food?.position,
    );
    
    if (powerUp != null) {
      _gameState = _gameState.copyWith(powerUp: powerUp);
    }
  }
  
  void _collectPowerUp(PowerUp powerUp) {
    final activePowerUp = ActivePowerUp(type: powerUp.type);
    
    _gameState = _gameState.addActivePowerUp(activePowerUp);
    _gameState = _gameState.clearPowerUp();
    
    _powerUpsCollectedThisGame++;
    
    _audioService.playSound('power_up');
    HapticFeedback.mediumImpact();
    
    // Restart game loop if speed changed
    if (powerUp.type == PowerUpType.speedBoost || powerUp.type == PowerUpType.slowMotion) {
      _startGameLoop();
    }
  }
  
  void _startPowerUpTimer() {
    _powerUpTimer?.cancel();
    // Spawn power-ups every 20-30 seconds randomly
    _powerUpTimer = Timer.periodic(
      const Duration(seconds: 25),
      (_) => _generatePowerUp(),
    );
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

  void _handleCrash(CrashReason crashReason, {Position? crashPosition, Position? collisionBodyPart}) {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();
    
    // First show crash feedback with reason and position details (visual only)
    _gameState = _gameState.copyWith(
      status: GameStatus.crashed,
      crashReason: crashReason,
      crashPosition: crashPosition,
      collisionBodyPart: collisionBodyPart,
      showCrashModal: false, // Start with visual feedback only
    );
    
    // Play crash sound and haptic feedback immediately
    _audioService.playSound('game_over');
    HapticFeedback.heavyImpact();
    notifyListeners();
    
    // Show visual crash feedback for 2 seconds, then show modal
    Future.delayed(const Duration(seconds: 2), () {
      if (_gameState.status == GameStatus.crashed) {
        // Now show the crash feedback modal
        _gameState = _gameState.copyWith(showCrashModal: true);
        notifyListeners();
        
        // After modal duration (3 seconds), proceed to game over screen
        Future.delayed(const Duration(seconds: 3), () {
          if (_gameState.status == GameStatus.crashed) {
            _gameOver();
          }
        });
      }
    });
  }
  
  void _gameOver() async {
    // Calculate game duration
    final gameDurationSeconds = _gameStartTime != null 
      ? DateTime.now().difference(_gameStartTime!).inSeconds 
      : 0;

    // Update high score if necessary
    int highScore = _gameState.highScore;
    bool isNewHighScore = _gameState.score > highScore;
    
    if (isNewHighScore) {
      highScore = _gameState.score;
      _storageService.saveHighScore(highScore);
      _audioService.playSound('high_score');
    }

    // Update Firebase user stats and get user profile for achievement tracking
    Map<String, dynamic>? userProfile;
    try {
      await _authService.updateHighScore(_gameState.score);
      userProfile = await _authService.getUserProfile();
    } catch (e) {
      if (kDebugMode) {
        // Failed to update Firebase high score
      }
    }

    // Track consecutive games without wall hits
    if (_hitWallThisGame) {
      _consecutiveGamesWithoutWallHits = 0;
    } else {
      _consecutiveGamesWithoutWallHits++;
    }

    // Check achievements
    final totalGames = userProfile?['totalGamesPlayed'] ?? 0;
    
    // Check score achievements
    _achievementService.checkScoreAchievements(_gameState.score);
    
    // Check games played achievements
    _achievementService.checkGamePlayedAchievements(totalGames);
    
    // Check survival achievements
    _achievementService.checkSurvivalAchievements(gameDurationSeconds);
    
    // Check special achievements
    _achievementService.checkSpecialAchievements(
      level: _gameState.level,
      hitWall: _hitWallThisGame,
      hitSelf: _hitSelfThisGame,
      foodTypesEaten: _foodTypesEatenThisGame,
      noWallGames: _consecutiveGamesWithoutWallHits,
    );

    _gameState = _gameState.copyWith(
      status: GameStatus.gameOver,
      highScore: highScore,
      crashReason: null, // Clear crash reason
      crashPosition: null, // Clear crash position
      collisionBodyPart: null, // Clear collision body part
      showCrashModal: false, // Clear crash modal flag
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
    _powerUpTimer?.cancel();
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
    _powerUpTimer?.cancel();
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

  Future<void> updateBoardSize(BoardSize boardSize) async {
    // Save the board size preference
    await _storageService.saveBoardSize(boardSize);
    
    // Update current game state if not playing
    if (_gameState.status != GameStatus.playing) {
      _gameState = _gameState.copyWith(
        boardWidth: boardSize.width,
        boardHeight: boardSize.height,
      );
      notifyListeners();
    }
  }

  Future<void> updateCrashFeedbackDuration(Duration duration) async {
    // Save the crash feedback duration preference
    await _storageService.saveCrashFeedbackDuration(duration);
    
    // Update current setting
    _crashFeedbackDuration = duration;
    notifyListeners();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();
    _audioService.dispose();
    super.dispose();
  }
}