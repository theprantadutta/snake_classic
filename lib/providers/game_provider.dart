import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/game_replay.dart';
import 'package:snake_classic/utils/direction.dart';
// Future imports for enhanced features:
// import 'package:snake_classic/services/preferences_service.dart';
// import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/auth_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/enhanced_audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/tournament_service.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/utils/constants.dart';

class GameProvider extends ChangeNotifier {
  GameState _gameState = GameState.initial();
  Timer? _gameTimer;
  Timer? _animationTimer; // Use Timer instead of Ticker for simplicity
  // Future: Use these services for enhanced features
  // PreferencesService? _preferencesService;
  // UnifiedUserService? _userService;
  final AudioService _audioService = AudioService();
  final EnhancedAudioService _enhancedAudioService = EnhancedAudioService();
  final HapticService _hapticService = HapticService();
  final AchievementService _achievementService = AchievementService();
  final StatisticsService _statisticsService = StatisticsService();
  
  // Keep legacy services for compatibility until full migration
  final StorageService _storageService = StorageService();
  final AuthService _authService = AuthService();
  final TournamentService _tournamentService = TournamentService();
  final GameRecorder _gameRecorder = GameRecorder();
  
  // Tournament mode
  String? _tournamentId;
  TournamentGameMode? _tournamentMode;
  
  // Smooth movement interpolation
  DateTime? _lastGameUpdate;
  double _moveProgress = 0.0; // 0.0 to 1.0 progress between moves
  GameState? _previousGameState;

  GameState get gameState => _gameState;
  bool get isPlaying => _gameState.status == GameStatus.playing;
  bool get isPaused => _gameState.status == GameStatus.paused;
  bool get isGameOver => _gameState.status == GameStatus.gameOver;
  Duration get crashFeedbackDuration => _crashFeedbackDuration;
  
  // Tournament mode getters
  String? get tournamentId => _tournamentId;
  TournamentGameMode? get tournamentMode => _tournamentMode;
  bool get isTournamentMode => _tournamentId != null;
  
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
  
  // Statistics tracking for current game
  final Map<String, int> _currentGameFoodTypes = {};
  final Map<String, int> _currentGamePowerUpTypes = {};
  int _currentGameFoodPoints = 0;
  int _currentGamePowerUpTime = 0; // Total time with active power-ups
  
  // Dynamic crash feedback duration
  Duration _crashFeedbackDuration = GameConstants.defaultCrashFeedbackDuration;

  GameProvider() {
    _initializeGame();
    // Start a new session when the provider is created
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _statisticsService.startNewSession();
    });
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
    await _enhancedAudioService.initialize();
    await _achievementService.initialize();
    await _statisticsService.initialize();
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
    
    // Reset statistics tracking
    _currentGameFoodTypes.clear();
    _currentGamePowerUpTypes.clear();
    _currentGameFoodPoints = 0;
    _currentGamePowerUpTime = 0;
    
    // Start recording gameplay
    _gameRecorder.startRecording();
    
    _generateFood();
    _startGameLoop();
    _startSmoothAnimation();
    _startPowerUpTimer();
    _audioService.playSound('game_start');
    _enhancedAudioService.playSfx('game_start', volume: 0.8);
    notifyListeners();
  }

  void setTournamentMode(String tournamentId, TournamentGameMode gameMode) {
    _tournamentId = tournamentId;
    _tournamentMode = gameMode;
    
    // Apply tournament-specific game settings
    _applyTournamentSettings(gameMode);
    notifyListeners();
  }
  
  void exitTournamentMode() {
    _tournamentId = null;
    _tournamentMode = null;
    notifyListeners();
  }
  
  void _applyTournamentSettings(TournamentGameMode gameMode) {
    switch (gameMode) {
      case TournamentGameMode.speedRun:
        // Speed increases more rapidly
        break;
      case TournamentGameMode.survival:
        // Focus on survival time over score
        break;
      case TournamentGameMode.noWalls:
        // Snake wraps around edges
        break;
      case TournamentGameMode.powerUpMadness:
        // More frequent power-ups
        break;
      case TournamentGameMode.perfectGame:
        // Any collision ends game immediately
        break;
      case TournamentGameMode.classic:
        // Standard rules
        break;
    }
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
      _hapticService.powerUpCollected(); // Add haptic feedback
      _collectPowerUp(_gameState.powerUp!);
    }

    _gameState = _gameState.copyWith(
      snake: snake,
      lastMoveTime: DateTime.now(),
    );

    // Reset interpolation progress
    _moveProgress = 0.0;
    _lastGameUpdate = DateTime.now();

    // Record current frame for replay
    Map<String, dynamic>? gameEvent;
    if (willEatFood) {
      gameEvent = {'type': 'food_consumed', 'foodType': _gameState.food?.type.name};
    } else if (willCollectPowerUp) {
      gameEvent = {'type': 'power_up_collected', 'powerUpType': _gameState.powerUp?.type.name};
    }

    _gameRecorder.recordFrame(
      snakePositions: snake.body.map((pos) => [pos.x, pos.y]).toList(),
      foodPosition: _gameState.food != null ? [_gameState.food!.position.x, _gameState.food!.position.y] : null,
      powerUpPosition: _gameState.powerUp != null ? [_gameState.powerUp!.position.x, _gameState.powerUp!.position.y] : null,
      powerUpType: _gameState.powerUp?.type.name,
      score: _gameState.score,
      level: _gameState.level,
      direction: snake.currentDirection.name,
      activePowerUps: _gameState.activePowerUps.map((p) => p.type.name).toList(),
      gameEvent: gameEvent,
    );

    notifyListeners();
  }

  void _consumeFood(Food food) {
    final basePoints = food.type.points;
    final multipliedPoints = basePoints * _gameState.scoreMultiplier;
    final newScore = _gameState.score + multipliedPoints;
    int newLevel = _gameState.level;

    // Track food types for achievements
    _foodTypesEatenThisGame.add(food.type.name);
    
    // Track food types for statistics
    _currentGameFoodTypes[food.type.name] = (_currentGameFoodTypes[food.type.name] ?? 0) + 1;
    _currentGameFoodPoints += multipliedPoints;

    // Level up logic
    if (newScore >= _gameState.targetScore && newLevel < 10) {
      newLevel++;
      _audioService.playSound('level_up');
      _enhancedAudioService.playSfx('level_up', volume: 1.0);
      HapticFeedback.mediumImpact();
    } else {
      _audioService.playSound('eat');
      // Enhanced spatial audio for food consumption
      final foodPos = _gameState.food?.position;
      if (foodPos != null) {
        _enhancedAudioService.playSfx('eat', 
          volume: 0.8,
          position: SpatialAudioPosition(
            x: foodPos.x / _gameState.boardWidth,
            y: foodPos.y / _gameState.boardHeight,
          ),
        );
      }
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
    
    // Track power-up types for statistics
    _currentGamePowerUpTypes[powerUp.type.name] = (_currentGamePowerUpTypes[powerUp.type.name] ?? 0) + 1;
    
    _audioService.playSound('power_up');
    // Enhanced spatial audio for power-up collection
    _enhancedAudioService.playSfx('power_up',
      volume: 1.0,
      position: SpatialAudioPosition(
        x: powerUp.position.x / _gameState.boardWidth,
        y: powerUp.position.y / _gameState.boardHeight,
      ),
    );
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
    // Add haptic feedback based on crash type
    if (crashReason == CrashReason.wallCollision) {
      _hapticService.wallHit();
    } else if (crashReason == CrashReason.selfCollision) {
      _hapticService.selfCollision();
    }
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
    _enhancedAudioService.playSfx('game_over', volume: 1.0);
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
    _hapticService.gameOver(); // Add haptic feedback for game over
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
      _enhancedAudioService.playSfx('high_score', volume: 1.0);
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

    // Calculate power-up time (approximate)
    _currentGamePowerUpTime = _gameState.activePowerUps
        .map((p) => p.duration.inSeconds - p.remainingTime.inSeconds)
        .fold(0, (sum, time) => sum + time);

    // Record game statistics
    await _statisticsService.recordGameResult(
      score: _gameState.score,
      gameTime: gameDurationSeconds,
      level: _gameState.level,
      foodConsumed: _currentGameFoodTypes.values.fold(0, (sum, count) => sum + count),
      foodTypes: _currentGameFoodTypes,
      foodPoints: _currentGameFoodPoints,
      powerUpsCollected: _powerUpsCollectedThisGame,
      powerUpTypes: _currentGamePowerUpTypes,
      powerUpTime: _currentGamePowerUpTime,
      hitWall: _hitWallThisGame,
      hitSelf: _hitSelfThisGame,
      isPerfectGame: !_hitWallThisGame && !_hitSelfThisGame && gameDurationSeconds > 30,
      unlockedAchievements: [], // This would need to be tracked separately
    );

    // Save game replay
    final crashReason = _hitWallThisGame ? 'wall' : _hitSelfThisGame ? 'self' : null;
    final gameReplay = _gameRecorder.finishRecording(
      playerName: _authService.currentUser?.displayName ?? 'Player',
      finalScore: _gameState.score,
      gameMode: 'classic',
      gameSettings: {
        'boardWidth': _gameState.boardWidth,
        'boardHeight': _gameState.boardHeight,
        'gameSpeed': _gameState.gameSpeed,
      },
      crashReason: crashReason,
      gameStats: {
        'level': _gameState.level,
        'foodConsumed': _currentGameFoodTypes.values.fold(0, (sum, count) => sum + count),
        'powerUpsCollected': _powerUpsCollectedThisGame,
        'gameDurationSeconds': gameDurationSeconds,
      },
    );

    // Save replay to storage (only save if it's a decent game or has a crash)
    if (gameReplay != null && (_gameState.score >= 100 || crashReason != null)) {
      try {
        await _storageService.saveReplay(gameReplay.id, gameReplay.toJsonString());
      } catch (e) {
        if (kDebugMode) {
          print('Failed to save game replay: $e');
        }
      }
    }

    // Submit score to tournament if in tournament mode
    if (isTournamentMode && _tournamentId != null) {
      try {
        await _tournamentService.submitScore(
          _tournamentId!,
          _gameState.score,
          {
            'level': _gameState.level,
            'foodConsumed': _currentGameFoodTypes.values.fold(0, (sum, count) => sum + count),
            'powerUpsCollected': _powerUpsCollectedThisGame,
            'gameDurationSeconds': gameDurationSeconds,
            'gameMode': _tournamentMode?.name ?? 'classic',
          },
        );
      } catch (e) {
        if (kDebugMode) {
          print('Failed to submit tournament score: $e');
        }
      }
    }

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
    _gameRecorder.stopRecording(); // Stop recording if active
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
    _gameRecorder.stopRecording(); // Stop recording if active
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
    _enhancedAudioService.dispose();
    super.dispose();
  }
}