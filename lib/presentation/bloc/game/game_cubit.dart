import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/models/game_replay.dart' show GameRecorder;
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/enhanced_audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/utils/direction.dart';

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
  final GameSettingsCubit _settingsCubit;

  Timer? _gameTimer;
  Timer? _animationTimer;
  Timer? _powerUpTimer;

  final GameRecorder _gameRecorder = GameRecorder();

  // Smooth movement
  DateTime? _lastGameUpdate;

  // Achievement tracking
  DateTime? _gameStartTime;
  final Set<String> _foodTypesEatenThisGame = {};
  bool _hitWallThisGame = false;
  bool _hitSelfThisGame = false;
  int _powerUpsCollectedThisGame = 0;

  // Statistics tracking
  final Map<String, int> _currentGameFoodTypes = {};
  int _currentGameFoodPoints = 0;

  GameCubit({
    required AudioService audioService,
    required EnhancedAudioService enhancedAudioService,
    required HapticService hapticService,
    required AchievementService achievementService,
    required StatisticsService statisticsService,
    required GameSettingsCubit settingsCubit,
  })  : _audioService = audioService,
        _enhancedAudioService = enhancedAudioService,
        _hapticService = hapticService,
        _achievementService = achievementService,
        _statisticsService = statisticsService,
        _settingsCubit = settingsCubit,
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

    emit(state.copyWith(
      status: GamePlayStatus.ready,
      gameState: gameState,
    ));
  }

  /// Start a new game
  void startGame() {
    final settings = _settingsCubit.state;

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
    _lastGameUpdate = DateTime.now();

    // Generate initial food
    final food = Food.generateRandom(
      gameState.boardWidth,
      gameState.boardHeight,
      gameState.snake,
    );

    _gameRecorder.startRecording();

    emit(state.copyWith(
      status: GamePlayStatus.playing,
      gameState: gameState.copyWith(food: food),
      moveProgress: 0.0,
      previousGameState: null,
    ));

    _startGameLoop();
    _startSmoothAnimation();
    _startPowerUpTimer();

    _audioService.playSound('game_start');
    _enhancedAudioService.playSfx('game_start', volume: 0.8);
  }

  /// Set tournament mode
  void setTournamentMode(String tournamentId, TournamentGameMode gameMode) {
    emit(state.copyWith(
      tournamentId: tournamentId,
      tournamentMode: gameMode,
    ));
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

    emit(state.copyWith(
      status: GamePlayStatus.paused,
      gameState: state.gameState?.copyWith(status: model.GameStatus.paused),
    ));
  }

  /// Resume the game
  void resumeGame() {
    if (state.status != GamePlayStatus.paused) return;

    _lastGameUpdate = DateTime.now();

    emit(state.copyWith(
      status: GamePlayStatus.playing,
      gameState: state.gameState?.copyWith(status: model.GameStatus.playing),
    ));

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
    final speed = state.gameState?.gameSpeed ?? 150;
    print('[GameCubit] Starting game loop with speed: $speed ms');
    _gameTimer = Timer.periodic(
      Duration(milliseconds: speed),
      (_) => _updateGame(),
    );
  }

  void _startSmoothAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(
      const Duration(milliseconds: 16), // ~60fps
      (_) => _updateAnimation(),
    );
  }

  void _startPowerUpTimer() {
    _powerUpTimer?.cancel();
    _powerUpTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _trySpawnPowerUp(),
    );
  }

  void _updateAnimation() {
    if (state.status != GamePlayStatus.playing) return;
    if (_lastGameUpdate == null) return;

    final elapsed = DateTime.now().difference(_lastGameUpdate!).inMilliseconds;
    final speed = state.gameState?.gameSpeed ?? 150;
    final progress = (elapsed / speed).clamp(0.0, 1.0);

    if ((state.moveProgress - progress).abs() > 0.01) {
      emit(state.copyWith(moveProgress: progress));
    }
  }

  void _updateGame() {
    if (state.status != GamePlayStatus.playing) {
      print('[GameCubit] _updateGame skipped: status=${state.status}');
      return;
    }
    if (state.gameState == null) {
      print('[GameCubit] _updateGame skipped: gameState is null');
      return;
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
    final willEatFood = currentFood != null &&
        snake.head.move(snake.currentDirection) == currentFood.position;
    final willCollectPowerUp = currentPowerUp != null &&
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
    final wallCollision = !hasImmunity &&
        previousState.gameMode.hasWalls &&
        snake.checkWallCollision(previousState.boardWidth, previousState.boardHeight);
    final selfCollision = !hasImmunity && snake.checkSelfCollision();

    if (wallCollision || selfCollision) {
      if (wallCollision) _hitWallThisGame = true;
      if (selfCollision) _hitSelfThisGame = true;

      final crashReason = wallCollision
          ? model.CrashReason.wallCollision
          : model.CrashReason.selfCollision;
      _handleCrash(crashReason, snake.head);
      return;
    }

    // Handle food consumption
    var newScore = previousState.score;
    var newLevel = previousState.level;
    var newCombo = previousState.currentCombo;
    var newMaxCombo = previousState.maxCombo;
    var newComboMultiplier = previousState.comboMultiplier;

    if (willEatFood && currentFood != null) {
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

      // Level up
      if (newScore >= previousState.targetScore && newLevel < 10) {
        newLevel++;
        _audioService.playSound('level_up');
        _enhancedAudioService.playSfx('level_up', volume: 1.0);
        HapticFeedback.mediumImpact();
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
    if (willCollectPowerUp && currentPowerUp != null) {
      _hapticService.powerUpCollected();
      _powerUpsCollectedThisGame++;
      activePowerUps = [...activePowerUps, ActivePowerUp(type: currentPowerUp.type)];
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

    emit(state.copyWith(
      gameState: newGameState,
      previousGameState: previousState,
      moveProgress: 0.0,
    ));

    _lastGameUpdate = DateTime.now();

    // Restart loop if speed changed
    if (newLevel > previousState.level) {
      _startGameLoop();
    }

    _recordFrame(snake, currentFood, currentPowerUp, newGameState, willEatFood, willCollectPowerUp);
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
      foodPosition: food != null ? <int>[food.position.x, food.position.y] : null,
      powerUpPosition: powerUp != null ? <int>[powerUp.position.x, powerUp.position.y] : null,
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
        emit(state.copyWith(
          gameState: state.gameState?.copyWith(powerUp: powerUp),
        ));
      }
    }
  }

  void _handleCrash(model.CrashReason reason, dynamic crashPosition) {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();

    _gameRecorder.stopRecording();

    final finalGameState = state.gameState?.copyWith(
      status: model.GameStatus.gameOver,
      crashReason: reason,
      crashPosition: crashPosition,
    );

    emit(state.copyWith(
      status: GamePlayStatus.gameOver,
      gameState: finalGameState,
    ));

    _audioService.playSound('game_over');
    _hapticService.gameOver();

    // Update high score
    final score = state.gameState?.score ?? 0;
    _settingsCubit.updateHighScore(score);

    // Track statistics
    _trackGameEnd();
  }

  void _trackGameEnd() {
    // Statistics tracking - the statistics service handles internal tracking
    // This method is a placeholder for any additional end-game tracking
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

    final highScore = state.gameState?.highScore ?? _settingsCubit.state.highScore;
    final gameState = model.GameState.initial().copyWith(
      highScore: highScore,
      boardWidth: _settingsCubit.state.boardSize.width,
      boardHeight: _settingsCubit.state.boardSize.height,
    );

    emit(state.copyWith(
      status: GamePlayStatus.ready,
      gameState: gameState,
      previousGameState: null,
      moveProgress: 0.0,
    ));
  }

  /// Return to menu state
  void backToMenu() {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();
    _gameRecorder.stopRecording();

    emit(state.copyWith(
      status: GamePlayStatus.ready,
      previousGameState: null,
      moveProgress: 0.0,
    ));
  }

  /// Skip crash feedback and go directly to game over
  void skipCrashFeedback() {
    if (state.status == GamePlayStatus.crashed) {
      _finalizeGameOver();
    }
  }

  /// Finalize game over after crash feedback
  void _finalizeGameOver() {
    final score = state.gameState?.score ?? 0;
    _settingsCubit.updateHighScore(score);
    _trackGameEnd();

    emit(state.copyWith(
      status: GamePlayStatus.gameOver,
      gameState: state.gameState?.copyWith(status: model.GameStatus.gameOver),
    ));

    _audioService.playSound('game_over');
  }

  @override
  Future<void> close() {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();
    return super.close();
  }
}
