import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/models/game_replay.dart' show GameRecorder;
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/enhanced_audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/daily_challenge_service.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/utils/constants.dart';

import 'game_state.dart';
import 'game_settings_cubit.dart';

export 'game_state.dart';
export 'game_settings_state.dart';
export 'game_settings_cubit.dart';

/// Cubit for managing the game loop and gameplay state
class GameCubit extends Cubit<GameCubitState> {
  final AudioService _audioService;
  final EnhancedAudioService _enhancedAudioService;
  final HapticService _hapticService;
  final AchievementService _achievementService;
  final StatisticsService _statisticsService;
  final StorageService _storageService;
  final GameSettingsCubit _settingsCubit;
  final CoinsCubit _coinsCubit;
  final DataSyncService _dataSyncService = DataSyncService();
  final DailyChallengeService _dailyChallengeService = DailyChallengeService();
  final ApiService _apiService = ApiService();

  Timer? _gameTimer;
  Timer? _animationTimer;
  Timer? _powerUpTimer;

  final GameRecorder _gameRecorder = GameRecorder();

  // Note: Smooth movement animation is now handled locally in GameBoard widget

  // Achievement tracking
  DateTime? _gameStartTime;
  final Set<String> _foodTypesEatenThisGame = {};
  bool _hitWallThisGame = false;
  bool _hitSelfThisGame = false;
  int _powerUpsCollectedThisGame = 0;
  int _consecutiveGamesWithoutWallHits = 0;

  // Statistics tracking
  final Map<String, int> _currentGameFoodTypes = {};
  int _currentGameFoodPoints = 0;
  final Map<String, int> _currentGamePowerUpTypes = {};
  int _currentGamePowerUpTime = 0;

  GameCubit({
    required AudioService audioService,
    required EnhancedAudioService enhancedAudioService,
    required HapticService hapticService,
    required AchievementService achievementService,
    required StatisticsService statisticsService,
    required StorageService storageService,
    required GameSettingsCubit settingsCubit,
    required CoinsCubit coinsCubit,
  }) : _audioService = audioService,
       _enhancedAudioService = enhancedAudioService,
       _hapticService = hapticService,
       _achievementService = achievementService,
       _statisticsService = statisticsService,
       _storageService = storageService,
       _settingsCubit = settingsCubit,
       _coinsCubit = coinsCubit,
       super(GameCubitState.initial());

  /// Initialize the game cubit
  Future<void> initialize() async {
    await _audioService.initialize();
    await _enhancedAudioService.initialize();
    await _achievementService.initialize();
    await _statisticsService.initialize();

    _statisticsService.startNewSession();

    final gameState = model.GameState.initial().copyWith(
      highScore: _settingsCubit.state.highScore,
      boardWidth: _settingsCubit.state.boardSize.width,
      boardHeight: _settingsCubit.state.boardSize.height,
    );

    emit(state.copyWith(status: GamePlayStatus.ready, gameState: gameState));
  }

  /// Start a new game
  void startGame() {
    debugPrint('🎮 [GameCubit] startGame() called');

    final settings = _settingsCubit.state;
    debugPrint(
      '🎮 [GameCubit] Settings: boardSize=${settings.boardSize.width}x${settings.boardSize.height}, highScore=${settings.highScore}',
    );

    final gameState = model.GameState.initial().copyWith(
      highScore: settings.highScore,
      boardWidth: settings.boardSize.width,
      boardHeight: settings.boardSize.height,
      status: model.GameStatus.playing,
      currentCombo: 0,
      maxCombo: 0,
      comboMultiplier: 1.0,
    );

    // Reset tracking
    _gameStartTime = DateTime.now();
    _foodTypesEatenThisGame.clear();
    _hitWallThisGame = false;
    _hitSelfThisGame = false;
    _powerUpsCollectedThisGame = 0;
    _currentGameFoodTypes.clear();
    _currentGameFoodPoints = 0;
    _updateCount = 0;

    // Generate initial food
    final food = Food.generateRandom(
      gameState.boardWidth,
      gameState.boardHeight,
      gameState.snake,
    );

    _gameRecorder.startRecording();

    final newState = state.copyWith(
      status: GamePlayStatus.playing,
      gameState: gameState.copyWith(food: food),
      moveProgress: 0.0,
      previousGameState: null,
    );

    debugPrint(
      '🎮 [GameCubit] Emitting new state: status=${newState.status}, gameState.snake.length=${newState.gameState?.snake.length}',
    );
    emit(newState);
    debugPrint(
      '🎮 [GameCubit] State emitted. Current state.status=${state.status}',
    );

    _startGameLoop();
    _startSmoothAnimation();
    _startPowerUpTimer();

    _audioService.playSound('game_start');
    _enhancedAudioService.playSfx('game_start', volume: 0.8);
    debugPrint('🎮 [GameCubit] startGame() completed');
  }

  /// Set tournament mode
  void setTournamentMode(String tournamentId, TournamentGameMode gameMode) {
    emit(state.copyWith(tournamentId: tournamentId, tournamentMode: gameMode));
  }

  /// Exit tournament mode
  void exitTournamentMode() {
    emit(state.copyWith(clearTournament: true));
  }

  /// Pause the game
  void pauseGame() {
    if (state.status != GamePlayStatus.playing) return;

    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();

    emit(
      state.copyWith(
        status: GamePlayStatus.paused,
        gameState: state.gameState?.copyWith(status: model.GameStatus.paused),
      ),
    );
  }

  /// Resume the game
  void resumeGame() {
    if (state.status != GamePlayStatus.paused) return;

    emit(
      state.copyWith(
        status: GamePlayStatus.playing,
        gameState: state.gameState?.copyWith(status: model.GameStatus.playing),
      ),
    );

    _startGameLoop();
    _startSmoothAnimation();
    _startPowerUpTimer();
  }

  /// Toggle pause
  void togglePause() {
    if (state.isPlaying) {
      pauseGame();
    } else if (state.isPaused) {
      resumeGame();
    }
  }

  /// Change snake direction
  void changeDirection(Direction newDirection) {
    if (state.status != GamePlayStatus.playing) return;
    if (state.gameState == null) return;

    state.gameState!.snake.changeDirection(newDirection);
    HapticFeedback.selectionClick();
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _scheduleNextGameTick();
  }

  /// Schedules the next game tick using the current game speed.
  /// This pattern allows speed changes to take effect immediately
  /// without causing a pause when the timer is restarted.
  void _scheduleNextGameTick() {
    final speed = state.gameState?.gameSpeed ?? 150;
    final level = state.gameState?.level ?? 1;
    if (_updateCount <= 5 || _updateCount % 100 == 0) {
      debugPrint(
        '🎮 [GameCubit] Scheduling next tick: speed=${speed}ms, level=$level',
      );
    }

    _gameTimer = Timer(Duration(milliseconds: speed), () {
      try {
        _updateGame();
      } catch (e, stackTrace) {
        debugPrint('🎮 [GameCubit] ERROR in game update loop: $e');
        AppLogger.error('Error in game update loop', e, stackTrace);
      }

      // Schedule next tick only if game is still active (playing or paused)
      // Speed is read fresh each time, so level-up speed changes apply immediately
      final currentStatus = state.status;
      if (currentStatus == GamePlayStatus.playing) {
        _scheduleNextGameTick();
      } else if (currentStatus == GamePlayStatus.paused) {
        // Game is paused - don't schedule. resumeGame() will restart the loop.
      }
      // For crashed/gameOver/ready - don't schedule, game has ended
    });
  }

  void _startSmoothAnimation() {
    // DISABLED: Animation is now handled locally in GameBoard widget
    // using AnimatedBuilder + local Ticker. This avoids Bloc state updates
    // entirely for animation, giving better performance.
    // The widget calculates moveProgress based on time since last game state change.
  }

  void _startPowerUpTimer() {
    _powerUpTimer?.cancel();
    _powerUpTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _trySpawnPowerUp(),
    );
  }

  // Note: _updateAnimation removed - animation is now handled locally in GameBoard widget

  // Track update count for debugging (disabled in production)
  int _updateCount = 0;
  DateTime? _lastTickTime;

  void _updateGame() {
    _updateCount++;
    final now = DateTime.now();
    if (_lastTickTime != null) {
      final timeSinceLastTick = now.difference(_lastTickTime!).inMilliseconds;
      final expectedSpeed = state.gameState?.gameSpeed ?? 150;
      // Warn if tick took much longer than expected (more than 50% over)
      if (timeSinceLastTick > expectedSpeed * 1.5) {
        debugPrint(
          '🎮 [GameCubit] WARNING: ${timeSinceLastTick}ms since last tick (expected ~${expectedSpeed}ms)',
        );
      }
    }
    _lastTickTime = now;

    if (state.status != GamePlayStatus.playing) {
      if (_updateCount <= 5) {
        debugPrint(
          '🎮 [GameCubit] _updateGame #$_updateCount skipped: status=${state.status}',
        );
      }
      return;
    }
    if (state.gameState == null) {
      debugPrint(
        '🎮 [GameCubit] _updateGame #$_updateCount skipped: gameState is null',
      );
      return;
    }

    if (_updateCount <= 5 || _updateCount % 50 == 0) {
      debugPrint(
        '🎮 [GameCubit] _updateGame #$_updateCount running, snake at ${state.gameState!.snake.head}',
      );
    }

    final previousState = state.gameState!;
    final snake = previousState.snake.copy();

    // Check for expired food
    var currentFood = previousState.food;
    if (currentFood?.isExpired == true) {
      currentFood = Food.generateRandom(
        previousState.boardWidth,
        previousState.boardHeight,
        snake,
      );
    }

    // Check for expired power-up
    var currentPowerUp = previousState.powerUp;
    if (currentPowerUp?.isExpired == true) {
      currentPowerUp = null;
    }

    // Check collisions before moving
    final willEatFood =
        currentFood != null &&
        snake.head.move(snake.currentDirection) == currentFood.position;
    final willCollectPowerUp =
        currentPowerUp != null &&
        snake.head.move(snake.currentDirection) == currentPowerUp.position;

    // Move snake
    snake.move(
      ateFood: willEatFood,
      boardWidth: previousState.boardWidth,
      boardHeight: previousState.boardHeight,
      wrapAround: !previousState.gameMode.hasWalls,
    );

    // Check collisions
    final hasImmunity =
        previousState.hasInvincibility || previousState.hasGhostMode;
    final wallCollision =
        !hasImmunity &&
        previousState.gameMode.hasWalls &&
        snake.checkWallCollision(
          previousState.boardWidth,
          previousState.boardHeight,
        );
    final selfCollision = !hasImmunity && snake.checkSelfCollision();

    if (wallCollision || selfCollision) {
      final crashReason = wallCollision
          ? model.CrashReason.wallCollision
          : model.CrashReason.selfCollision;

      // Get collision body part for self-collision feedback
      Position? collisionBodyPart;
      if (selfCollision) {
        collisionBodyPart = snake.getSelfCollisionBodyPart();
      }

      _handleCrash(
        crashReason,
        snake.head,
        collisionBodyPart: collisionBodyPart,
      );
      return;
    }

    // Handle food consumption
    var newScore = previousState.score;
    var newLevel = previousState.level;
    var newCombo = previousState.currentCombo;
    var newMaxCombo = previousState.maxCombo;
    var newComboMultiplier = previousState.comboMultiplier;

    if (willEatFood) {
      _foodTypesEatenThisGame.add(currentFood.type.name);
      _currentGameFoodTypes[currentFood.type.name] =
          (_currentGameFoodTypes[currentFood.type.name] ?? 0) + 1;

      newCombo++;
      newMaxCombo = max(newMaxCombo, newCombo);
      newComboMultiplier = model.GameState.calculateComboMultiplier(newCombo);

      final basePoints = currentFood.type.points;
      final comboBonus = (basePoints * newComboMultiplier).round();
      final multipliedPoints = comboBonus * previousState.scoreMultiplier;
      newScore += multipliedPoints;
      _currentGameFoodPoints += multipliedPoints;

      // Level up (unlimited levels with progressive difficulty)
      if (newScore >= previousState.targetScore) {
        newLevel++;
        debugPrint(
          '🎮 [GameCubit] LEVEL UP! Now level $newLevel (target was ${previousState.targetScore}, next target: ${model.GameState.getTargetScoreForLevel(newLevel + 1)})',
        );
        _audioService.playSound('level_up');
        HapticFeedback.mediumImpact();

        // Award coins for level up
        _coinsCubit.earnCoins(
          CoinEarningSource.levelUp,
          metadata: {'level': newLevel},
        );
      } else {
        _audioService.playSound('eat');
        HapticFeedback.lightImpact();
      }

      // Generate new food
      currentFood = Food.generateRandom(
        previousState.boardWidth,
        previousState.boardHeight,
        snake,
      );
    }

    // Handle power-up collection
    var activePowerUps = previousState.removeExpiredPowerUps().activePowerUps;
    if (willCollectPowerUp) {
      _hapticService.powerUpCollected();
      _powerUpsCollectedThisGame++;
      activePowerUps = [
        ...activePowerUps,
        ActivePowerUp(type: currentPowerUp.type),
      ];
      currentPowerUp = null;
      _audioService.playSound('power_up');
    }

    final newGameState = previousState.copyWith(
      snake: snake,
      food: currentFood,
      powerUp: currentPowerUp,
      score: newScore,
      level: newLevel,
      currentCombo: newCombo,
      maxCombo: newMaxCombo,
      comboMultiplier: newComboMultiplier,
      activePowerUps: activePowerUps,
      lastMoveTime: DateTime.now(),
    );

    final newCubitState = state.copyWith(
      gameState: newGameState,
      previousGameState: previousState,
      moveProgress: 0.0,
    );

    if (_updateCount <= 5) {
      debugPrint(
        '🎮 [GameCubit] _updateGame #$_updateCount emitting: snake moved to ${snake.head}',
      );
    }

    emit(newCubitState);

    // Note: No need to restart game loop on level-up anymore.
    // The new timer pattern (_scheduleNextGameTick) reads speed fresh each tick,
    // so speed changes from level-ups apply immediately without a pause.

    _recordFrame(
      snake,
      currentFood,
      currentPowerUp,
      newGameState,
      willEatFood,
      willCollectPowerUp,
    );
  }

  void _recordFrame(
    Snake snake,
    Food? food,
    PowerUp? powerUp,
    model.GameState gameState,
    bool ateFood,
    bool collectedPowerUp,
  ) {
    Map<String, dynamic>? event;
    if (ateFood) {
      event = {'type': 'food_consumed', 'foodType': food?.type.name};
    } else if (collectedPowerUp) {
      event = {'type': 'power_up_collected', 'powerUpType': powerUp?.type.name};
    }

    final snakePositions = <List<int>>[];
    for (final pos in snake.body) {
      snakePositions.add(<int>[pos.x, pos.y]);
    }

    _gameRecorder.recordFrame(
      snakePositions: snakePositions,
      foodPosition: food != null
          ? <int>[food.position.x, food.position.y]
          : null,
      powerUpPosition: powerUp != null
          ? <int>[powerUp.position.x, powerUp.position.y]
          : null,
      powerUpType: powerUp?.type.name,
      score: gameState.score,
      level: gameState.level,
      direction: snake.currentDirection.name,
      activePowerUps: gameState.activePowerUps.map((p) => p.type.name).toList(),
      gameEvent: event,
    );
  }

  void _trySpawnPowerUp() {
    if (state.status != GamePlayStatus.playing) return;
    if (state.gameState?.powerUp != null) return;

    final random = Random();
    if (random.nextDouble() < 0.3) {
      final powerUp = PowerUp.generateRandom(
        state.gameState!.boardWidth,
        state.gameState!.boardHeight,
        state.gameState!.snake,
        foodPosition: state.gameState?.food?.position,
      );

      if (powerUp != null) {
        emit(
          state.copyWith(
            gameState: state.gameState?.copyWith(powerUp: powerUp),
          ),
        );
      }
    }
  }

  void _handleCrash(
    model.CrashReason reason,
    Position? crashPosition, {
    Position? collisionBodyPart,
  }) {
    debugPrint(
      '🎮 [GameCubit] _handleCrash called: reason=$reason, crashPosition=$crashPosition',
    );

    // Track what type of crash for achievements
    if (reason == model.CrashReason.wallCollision) {
      _hitWallThisGame = true;
      _hapticService.wallHit();
    } else if (reason == model.CrashReason.selfCollision) {
      _hitSelfThisGame = true;
      _hapticService.selfCollision();
    }

    // Cancel all timers
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();

    // Play crash sound and haptic feedback immediately
    _audioService.playSound('game_over');
    _enhancedAudioService.playSfx('game_over', volume: 1.0);
    HapticFeedback.heavyImpact();

    // Get crash feedback duration from settings
    final crashFeedbackDuration = _settingsCubit.state.crashFeedbackDuration;
    final durationSeconds = crashFeedbackDuration.inSeconds;

    // Skip mode: go directly to game over with minimal feedback
    if (durationSeconds == GameConstants.crashFeedbackSkip) {
      final crashedGameState = state.gameState?.copyWith(
        status: model.GameStatus.crashed,
        crashReason: reason,
        crashPosition: crashPosition,
        collisionBodyPart: collisionBodyPart,
        showCrashModal: false,
      );

      emit(
        state.copyWith(
          status: GamePlayStatus.crashed,
          gameState: crashedGameState,
        ),
      );

      // Immediately transition to game over after short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (state.status == GamePlayStatus.crashed) {
          _gameOver();
        }
      });
      return;
    }

    // First show crash feedback with reason and position details (visual only)
    final crashedGameState = state.gameState?.copyWith(
      status: model.GameStatus.crashed,
      crashReason: reason,
      crashPosition: crashPosition,
      collisionBodyPart: collisionBodyPart,
      showCrashModal: false, // Start with visual feedback only
    );

    emit(
      state.copyWith(
        status: GamePlayStatus.crashed,
        gameState: crashedGameState,
      ),
    );

    // Show visual crash feedback for 2 seconds, then show modal
    Future.delayed(const Duration(seconds: 2), () {
      if (state.status == GamePlayStatus.crashed) {
        // Now show the crash feedback modal
        emit(
          state.copyWith(
            gameState: state.gameState?.copyWith(showCrashModal: true),
          ),
        );

        // Until Tap mode: don't auto-advance, wait for user to skip
        if (durationSeconds == GameConstants.crashFeedbackUntilTap) {
          // User must tap to continue - handled by skipCrashFeedback()
          return;
        }

        // Normal mode: use configured duration
        final modalDuration = Duration(seconds: durationSeconds.clamp(1, 10));
        Future.delayed(modalDuration, () {
          if (state.status == GamePlayStatus.crashed) {
            _gameOver();
          }
        });
      }
    });
  }

  Future<void> _trackGameEnd() async {
    // Calculate game duration
    final gameDurationSeconds = _gameStartTime != null
        ? DateTime.now().difference(_gameStartTime!).inSeconds
        : 0;

    // Track consecutive games without wall hits
    if (_hitWallThisGame) {
      _consecutiveGamesWithoutWallHits = 0;
    } else {
      _consecutiveGamesWithoutWallHits++;
    }

    final gameState = state.gameState;
    if (gameState == null) return;

    // Check achievements and award coins for newly unlocked ones
    final scoreUnlocks = await _achievementService.checkScoreAchievements(
      gameState.score,
    );
    final survivalUnlocks = await _achievementService.checkSurvivalAchievements(
      gameDurationSeconds,
    );
    final specialUnlocks = await _achievementService.checkSpecialAchievements(
      level: gameState.level,
      hitWall: _hitWallThisGame,
      hitSelf: _hitSelfThisGame,
      foodTypesEaten: _foodTypesEatenThisGame,
      noWallGames: _consecutiveGamesWithoutWallHits,
    );

    // Award coins for newly unlocked achievements
    final allNewUnlocks = [...scoreUnlocks, ...survivalUnlocks, ...specialUnlocks];
    for (final achievement in allNewUnlocks) {
      await _coinsCubit.earnCoins(
        CoinEarningSource.achievementUnlocked,
        customAmount: achievement.points,
        itemName: achievement.title,
        metadata: {
          'achievementId': achievement.id,
          'type': achievement.type.name,
          'rarity': achievement.rarity.name,
        },
      );
    }

    // Calculate power-up time
    _currentGamePowerUpTime = gameState.activePowerUps
        .map((p) => p.duration.inSeconds - p.remainingTime.inSeconds)
        .fold(0, (sum, time) => sum + time);

    // Record game statistics
    await _statisticsService.recordGameResult(
      score: gameState.score,
      gameTime: gameDurationSeconds,
      level: gameState.level,
      foodConsumed: _currentGameFoodTypes.values.fold(
        0,
        (sum, count) => sum + count,
      ),
      foodTypes: _currentGameFoodTypes,
      foodPoints: _currentGameFoodPoints,
      powerUpsCollected: _powerUpsCollectedThisGame,
      powerUpTypes: _currentGamePowerUpTypes,
      powerUpTime: _currentGamePowerUpTime,
      hitWall: _hitWallThisGame,
      hitSelf: _hitSelfThisGame,
      isPerfectGame:
          !_hitWallThisGame && !_hitSelfThisGame && gameDurationSeconds > 30,
      unlockedAchievements: [],
    );

    // Finish game recording
    final crashReasonStr = _hitWallThisGame
        ? 'wall'
        : _hitSelfThisGame
        ? 'self'
        : null;
    _gameRecorder.finishRecording(
      playerName: 'Player',
      finalScore: gameState.score,
      gameMode: 'classic',
      gameSettings: {
        'boardWidth': gameState.boardWidth,
        'boardHeight': gameState.boardHeight,
        'gameSpeed': gameState.gameSpeed,
      },
      crashReason: crashReasonStr,
      gameStats: {
        'level': gameState.level,
        'foodConsumed': _currentGameFoodTypes.values.fold(
          0,
          (sum, count) => sum + count,
        ),
        'powerUpsCollected': _powerUpsCollectedThisGame,
        'gameDurationSeconds': gameDurationSeconds,
      },
    );

    // Update daily challenge progress
    _updateDailyChallengeProgress(
      score: gameState.score,
      foodEaten: _currentGameFoodTypes.values.fold(
        0,
        (sum, count) => sum + count,
      ),
      survivalSeconds: gameDurationSeconds,
      gameMode: 'classic',
    );
  }

  /// Update daily challenge progress after game ends
  Future<void> _updateDailyChallengeProgress({
    required int score,
    required int foodEaten,
    required int survivalSeconds,
    required String gameMode,
  }) async {
    try {
      // Update score challenge (takes max value)
      if (score > 0) {
        await _dailyChallengeService.updateProgress(ChallengeType.score, score);
      }

      // Update food eaten challenge (accumulates)
      if (foodEaten > 0) {
        await _dailyChallengeService.updateProgress(
          ChallengeType.foodEaten,
          foodEaten,
        );
      }

      // Update survival challenge (takes max value)
      if (survivalSeconds > 0) {
        await _dailyChallengeService.updateProgress(
          ChallengeType.survival,
          survivalSeconds,
        );
      }

      // Update games played (always increment by 1)
      await _dailyChallengeService.updateProgress(ChallengeType.gamesPlayed, 1);

      // Update game mode specific challenge
      await _dailyChallengeService.updateProgress(
        ChallengeType.gameMode,
        1,
        gameMode: gameMode,
      );

      AppLogger.info('Daily challenge progress updated');
    } catch (e) {
      AppLogger.error('Error updating daily challenge progress', e);
    }
  }

  /// Get game recording data (simplified)
  Map<String, dynamic>? getRecordingData() {
    try {
      return {
        'score': state.gameState?.score ?? 0,
        'level': state.gameState?.level ?? 1,
        'maxCombo': state.gameState?.maxCombo ?? 0,
        'foodEaten': _currentGameFoodTypes.values.fold(0, (a, b) => a + b),
        'powerUpsCollected': _powerUpsCollectedThisGame,
      };
    } catch (e) {
      return null;
    }
  }

  /// Reset the game to initial state while preserving high score
  void resetGame() {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();
    _gameRecorder.stopRecording();

    final highScore =
        state.gameState?.highScore ?? _settingsCubit.state.highScore;
    final gameState = model.GameState.initial().copyWith(
      highScore: highScore,
      boardWidth: _settingsCubit.state.boardSize.width,
      boardHeight: _settingsCubit.state.boardSize.height,
    );

    emit(
      state.copyWith(
        status: GamePlayStatus.ready,
        gameState: gameState,
        previousGameState: null,
        moveProgress: 0.0,
      ),
    );
  }

  /// Return to menu state
  void backToMenu() {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();
    _gameRecorder.stopRecording();

    emit(
      state.copyWith(
        status: GamePlayStatus.ready,
        previousGameState: null,
        moveProgress: 0.0,
      ),
    );
  }

  /// Skip crash feedback and go directly to game over
  void skipCrashFeedback() {
    if (state.status == GamePlayStatus.crashed) {
      _finalizeGameOver();
    }
  }

  /// Finalize game over after crash feedback - transitions from crashed to gameOver
  void _gameOver() async {
    debugPrint('🎮 [GameCubit] _gameOver called');

    _hapticService.gameOver();

    final gameState = state.gameState;
    if (gameState == null) return;

    // Update high score if necessary
    int highScore = gameState.highScore;
    bool isNewHighScore = gameState.score > highScore;

    if (isNewHighScore) {
      highScore = gameState.score;
      await _storageService.saveHighScore(highScore);
      _audioService.playSound('high_score');
      _enhancedAudioService.playSfx('high_score', volume: 1.0);
    }

    // Queue score for background sync (offline-first: non-blocking)
    final gameDurationSeconds = _gameStartTime != null
        ? DateTime.now().difference(_gameStartTime!).inSeconds
        : 0;
    final foodEaten = _currentGameFoodTypes.values.fold(
      0,
      (sum, count) => sum + count,
    );

    _dataSyncService.queueSync('score', {
      'score': gameState.score,
      'gameDuration': gameDurationSeconds,
      'foodsEaten': foodEaten,
      'gameMode': state.isTournamentMode ? 'tournament' : 'classic',
      'difficulty': 'normal',
      'playedAt': DateTime.now().toIso8601String(),
      'idempotencyKey':
          '${DateTime.now().millisecondsSinceEpoch}_${gameState.score}',
    }, priority: SyncPriority.high);

    // Track game end statistics and achievements
    await _trackGameEnd();

    // Award coins for game completion
    await _awardGameCompletionCoins(
      score: gameState.score,
      level: gameState.level,
      foodEaten: foodEaten,
      gameDurationSeconds: gameDurationSeconds,
    );

    // Add battle pass XP based on game performance
    await _addBattlePassXP(
      score: gameState.score,
      foodEaten: foodEaten,
      survivalSeconds: gameDurationSeconds,
    );

    // Stop recording
    _gameRecorder.stopRecording();

    // Emit game over state
    emit(
      state.copyWith(
        status: GamePlayStatus.gameOver,
        gameState: gameState.copyWith(
          status: model.GameStatus.gameOver,
          highScore: highScore,
        ),
      ),
    );
  }

  /// Award coins for completing a game based on performance
  Future<void> _awardGameCompletionCoins({
    required int score,
    required int level,
    required int foodEaten,
    required int gameDurationSeconds,
  }) async {
    try {
      // Base coins + bonus based on score (1 base + 1 per 100 points, max 20)
      final coinsEarned = (1 + (score ~/ 100)).clamp(1, 20);

      await _coinsCubit.earnCoins(
        CoinEarningSource.gameCompleted,
        customAmount: coinsEarned,
        metadata: {'score': score, 'level': level, 'foodEaten': foodEaten},
      );

      // Bonus for perfect game (no wall/self hits, played > 30 seconds)
      final isPerfectGame = !_hitWallThisGame &&
          !_hitSelfThisGame &&
          gameDurationSeconds > 30;

      if (isPerfectGame) {
        await _coinsCubit.earnCoins(
          CoinEarningSource.perfectGame,
          metadata: {
            'duration': gameDurationSeconds,
            'score': score,
          },
        );
      }

      // Bonus for long survival (> 3 minutes = 180 seconds)
      if (gameDurationSeconds > 180) {
        await _coinsCubit.earnCoins(
          CoinEarningSource.longSurvival,
          metadata: {
            'duration': gameDurationSeconds,
            'score': score,
          },
        );
      }

      AppLogger.info(
        'Awarded game completion coins: $coinsEarned (score: $score, perfect: $isPerfectGame, long: ${gameDurationSeconds > 180})',
      );
    } catch (e) {
      AppLogger.error('Error awarding game completion coins', e);
    }
  }

  /// Calculate and add XP to battle pass based on game performance
  Future<void> _addBattlePassXP({
    required int score,
    required int foodEaten,
    required int survivalSeconds,
  }) async {
    // Calculate XP earned from game
    // Base XP from score (1 XP per 10 points)
    int xp = score ~/ 10;
    // Bonus from food (2 XP per food)
    xp += foodEaten * 2;
    // Bonus from survival time (1 XP per 30 seconds)
    xp += survivalSeconds ~/ 30;
    // Minimum XP of 1 for playing
    xp = xp.clamp(1, 500);

    if (xp > 0 && _apiService.isAuthenticated) {
      try {
        await _apiService.addBattlePassXP(xp: xp, source: 'gameplay');
        AppLogger.info('Added $xp XP to battle pass');
      } catch (e) {
        AppLogger.error('Failed to add battle pass XP', e);
      }
    }
  }

  /// Alias for _gameOver - kept for compatibility with skipCrashFeedback
  void _finalizeGameOver() {
    _gameOver();
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();
    return super.close();
  }
}
