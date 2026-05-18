import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/models/game_replay.dart' show GameRecorder;
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/power_up/power_up_cubit.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/enhanced_audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/notification_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/services/daily_challenge_service.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
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
  final BattlePassCubit _battlePassCubit;
  final AnalyticsFacade _analytics;
  final DataSyncService _dataSyncService = DataSyncService();
  final DailyChallengeService _dailyChallengeService = DailyChallengeService();

  Timer? _gameTimer;
  Timer? _animationTimer;
  Timer? _powerUpTimer;
  Timer? _timeAttackTimer;
  Duration? _timeAttackRemaining;

  final GameRecorder _gameRecorder = GameRecorder();

  // Note: Smooth movement animation is now handled locally in GameBoard widget

  // Achievement tracking
  DateTime? _gameStartTime;
  final Set<String> _foodTypesEatenThisGame = {};
  // Per-game collision tracking. The booleans answer "did this game have
  // any wall/self hits at all" (used by achievements + cause-of-death
  // reporting). The int counters accumulate each crash so Survival mode's
  // multi-respawn games record the true number of collisions instead of 1.
  bool _hitWallThisGame = false;
  bool _hitSelfThisGame = false;
  int _wallHitsThisGame = 0;
  int _selfHitsThisGame = 0;
  int _powerUpsCollectedThisGame = 0;
  int _consecutiveGamesWithoutWallHits = 0;

  // Battle pass milestone tracking (reset per game)
  final Set<String> _bpMilestonesThisGame = {};

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
    required BattlePassCubit battlePassCubit,
    required AnalyticsFacade analytics,
  }) : _audioService = audioService,
       _enhancedAudioService = enhancedAudioService,
       _hapticService = hapticService,
       _achievementService = achievementService,
       _statisticsService = statisticsService,
       _storageService = storageService,
       _settingsCubit = settingsCubit,
       _coinsCubit = coinsCubit,
       _battlePassCubit = battlePassCubit,
       _analytics = analytics,
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
      gameMode: _settingsCubit.state.gameMode,
    );

    emit(state.copyWith(status: GamePlayStatus.ready, gameState: gameState));
  }

  /// Start a new game
  void startGame() {
    debugPrint('🎮 [GameCubit] startGame() called');

    final settings = _settingsCubit.state;
    debugPrint(
      '🎮 [GameCubit] Settings: boardSize=${settings.boardSize.width}x${settings.boardSize.height}, gameMode=${settings.gameMode.name}, highScore=${settings.highScore}',
    );

    final initialLives = settings.gameMode.initialLives;
    final startTime = DateTime.now();
    final gameState = model.GameState.initial().copyWith(
      highScore: settings.highScore,
      boardWidth: settings.boardSize.width,
      boardHeight: settings.boardSize.height,
      gameMode: settings.gameMode,
      status: model.GameStatus.playing,
      currentCombo: 0,
      maxCombo: 0,
      comboMultiplier: 1.0,
      initialLives: initialLives,
      livesRemaining: initialLives,
      gameStartTime: startTime,
    );

    // Reset tracking
    _gameStartTime = DateTime.now();
    _foodTypesEatenThisGame.clear();
    _hitWallThisGame = false;
    _hitSelfThisGame = false;
    _wallHitsThisGame = 0;
    _selfHitsThisGame = 0;
    _powerUpsCollectedThisGame = 0;
    _currentGameFoodTypes.clear();
    _currentGameFoodPoints = 0;
    _currentGamePowerUpTypes.clear();
    _currentGamePowerUpTime = 0;
    _updateCount = 0;
    _bpMilestonesThisGame.clear();
    _achievementService.resetLastGameUnlocks();

    // Daily first game XP
    _awardDailyFirstGameXP();

    // Generate initial food. MultiFood mode spawns 3 simultaneously.
    final food = Food.generateRandom(
      gameState.boardWidth,
      gameState.boardHeight,
      gameState.snake,
    );
    final List<Food> extraFoods = [];
    if (gameState.gameMode.hasMultipleFood) {
      for (var i = 0; i < 2; i++) {
        extraFoods.add(
          _generateNonOverlappingFood(
            gameState.boardWidth,
            gameState.boardHeight,
            gameState.snake,
            existing: [food, ...extraFoods],
          ),
        );
      }
    }

    _gameRecorder.startRecording();

    final newState = state.copyWith(
      status: GamePlayStatus.playing,
      gameState: gameState.copyWith(food: food, foods: extraFoods),
      moveProgress: 0.0,
      clearPreviousGameState: true,
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
    _startTimeAttackTimer(settings.gameMode);

    // Pre-game power-up activation: if the user armed a power-up via the
    // home-screen loadout, fire it 5 seconds into the game so they have
    // time to settle into the run before the effect kicks in. Consuming
    // from inventory + clearing the armed slot is handled by the cubit.
    _activateArmedPowerUpIfAny();

    _audioService.playSound('game_start');
    _enhancedAudioService.playSfx('game_start', volume: 0.8);

    _analytics.trackGameStarted(
      boardWidth: gameState.boardWidth,
      boardHeight: gameState.boardHeight,
      gameMode: state.isTournamentMode ? 'tournament' : gameState.gameMode.name,
    );

    debugPrint('🎮 [GameCubit] startGame() completed');
  }

  /// Consume the user's armed pre-game power-up (if any) and schedule its
  /// in-game activation 5 seconds in. The PowerUpCubit handles the
  /// server round-trip + inventory decrement; we just inject the
  /// ActivePowerUp into the game state once the delay elapses.
  void _activateArmedPowerUpIfAny() {
    final powerUpCubit = getIt<PowerUpCubit>();
    final armedKey = powerUpCubit.state.armed;
    if (armedKey == null) return;
    final type = PowerUpCubit.typeFromInventoryKey(armedKey);
    if (type == null) {
      AppLogger.warning('Armed power-up key has no PowerUpType mapping: $armedKey');
      return;
    }
    // Consume eagerly so the user can't double-spend by exiting and
    // restarting before the timer fires. consume() also clears the armed
    // slot — re-arming for the next game is intentional.
    unawaited(powerUpCubit.consume(armedKey));
    Future.delayed(const Duration(seconds: 5), () {
      // If the game ended (game over / quit) before the activation
      // window, silently drop. Inventory was already consumed — that's
      // a deliberate "you paid for it" cost.
      if (state.status != GamePlayStatus.playing) return;
      final gameState = state.gameState;
      if (gameState == null) return;
      final updated = gameState.copyWith(
        activePowerUps: [
          ...gameState.activePowerUps,
          ActivePowerUp(type: type),
        ],
      );
      emit(state.copyWith(gameState: updated));
      _audioService.playSound('power_up_collect');
      _enhancedAudioService.playSfx('power_up_collect', volume: 0.8);
    });
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

    // TimeAttack: snapshot how much time is left so resume can re-arm.
    if (_timeAttackTimer != null && _timeAttackScheduledAt != null) {
      final elapsed = DateTime.now().difference(_timeAttackScheduledAt!);
      final remaining = (_timeAttackRemaining ?? Duration.zero) - elapsed;
      _timeAttackRemaining =
          remaining.isNegative ? Duration.zero : remaining;
      _timeAttackTimer?.cancel();
      _timeAttackTimer = null;
    }

    emit(
      state.copyWith(
        status: GamePlayStatus.paused,
        gameState: state.gameState?.copyWith(status: model.GameStatus.paused),
      ),
    );

    _analytics.trackGamePaused();
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
    _scheduleTimeAttackTimer();

    _analytics.trackGameResumed();
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
      const Duration(seconds: GameConstants.powerUpSpawnIntervalSeconds),
      (_) => _trySpawnPowerUp(),
    );
  }

  /// TimeAttack mode: schedule a one-shot timer that ends the game when
  /// the mode's timeLimit elapses. _timeAttackRemaining tracks the
  /// outstanding duration so pause/resume can re-arm with the leftover.
  void _startTimeAttackTimer(GameMode mode) {
    _timeAttackTimer?.cancel();
    final limit = mode.timeLimit;
    if (limit == null) {
      _timeAttackRemaining = null;
      return;
    }
    _timeAttackRemaining = limit;
    _scheduleTimeAttackTimer();
  }

  void _scheduleTimeAttackTimer() {
    final remaining = _timeAttackRemaining;
    if (remaining == null || remaining <= Duration.zero) return;
    final scheduledAt = DateTime.now();
    _timeAttackTimer?.cancel();
    _timeAttackTimer = Timer(remaining, () async {
      if (state.status == GamePlayStatus.playing) {
        _timeAttackRemaining = Duration.zero;
        await _gameOver();
      }
    });
    // Remember the scheduling moment so resumeGame can compute leftover.
    _timeAttackScheduledAt = scheduledAt;
  }

  DateTime? _timeAttackScheduledAt;

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
    final isMultiFood = previousState.gameMode.hasMultipleFood;

    // Check for expired food
    var currentFood = previousState.food;
    if (currentFood?.isExpired == true) {
      currentFood = Food.generateRandom(
        previousState.boardWidth,
        previousState.boardHeight,
        snake,
      );
    }

    // MultiFood: refresh any expired extras so the board always has the
    // target count of simultaneously-visible foods.
    var extraFoods = List<Food>.from(previousState.foods);
    if (isMultiFood) {
      for (var i = 0; i < extraFoods.length; i++) {
        if (extraFoods[i].isExpired) {
          extraFoods[i] = _generateNonOverlappingFood(
            previousState.boardWidth,
            previousState.boardHeight,
            snake,
            existing: [
              ?currentFood,
              ...extraFoods.where((f) => f != extraFoods[i]),
            ],
          );
        }
      }
    }

    // Check for expired power-up
    var currentPowerUp = previousState.powerUp;
    var shouldClearPowerUp = false;
    if (currentPowerUp?.isExpired == true) {
      currentPowerUp = null;
      shouldClearPowerUp = true;
    }

    // Check collisions before moving
    final nextHeadPosition = snake.head.move(snake.currentDirection);
    final willEatPrimaryFood =
        currentFood != null &&
        nextHeadPosition == currentFood.position;
    // MultiFood: also check the extras list. Track which index was eaten
    // so we can regenerate just that slot.
    int eatenExtraIndex = -1;
    if (!willEatPrimaryFood && isMultiFood) {
      for (var i = 0; i < extraFoods.length; i++) {
        if (extraFoods[i].position == nextHeadPosition) {
          eatenExtraIndex = i;
          break;
        }
      }
    }
    final willEatFood = willEatPrimaryFood || eatenExtraIndex >= 0;

    // Check power-up collision: both current position AND next position
    // This ensures we don't miss collection if snake spawned on or passed through
    final willCollectPowerUp =
        currentPowerUp != null &&
        (nextHeadPosition == currentPowerUp.position ||
         snake.head == currentPowerUp.position);

    // Debug logging for power-up collision detection (throttled to avoid perf impact)
    if (currentPowerUp != null && (_updateCount <= 5 || _updateCount % 100 == 0)) {
      debugPrint('🎯 Power-up at: ${currentPowerUp.position} (type: ${currentPowerUp.type.name})');
      debugPrint('🐍 Snake head: ${snake.head}, next: $nextHeadPosition');
      debugPrint('✅ Will collect power-up: $willCollectPowerUp');
    }

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
      // Identify which food was actually consumed (primary vs an extra).
      final eatenFood = willEatPrimaryFood ? currentFood : extraFoods[eatenExtraIndex];

      _foodTypesEatenThisGame.add(eatenFood.type.name);
      _currentGameFoodTypes[eatenFood.type.name] =
          (_currentGameFoodTypes[eatenFood.type.name] ?? 0) + 1;

      newCombo++;
      newMaxCombo = max(newMaxCombo, newCombo);
      newComboMultiplier = model.GameState.calculateComboMultiplier(newCombo);

      final basePoints = eatenFood.type.points;
      final comboBonus = (basePoints * newComboMultiplier).round();
      final multipliedPoints = comboBonus * previousState.scoreMultiplier;
      newScore += multipliedPoints;
      _currentGameFoodPoints += multipliedPoints;

      // Battle pass score milestones - deferred to avoid event loop contention
      // during the game tick (addXP can trigger HTTP calls on first invocation)
      Future.microtask(() => _checkScoreMilestones(newScore));

      // Level up (unlimited levels with progressive difficulty).
      // Loop so that a high-combo or multiplied bite can cross multiple
      // level thresholds in a single tick.
      final previousLevel = newLevel;
      while (newScore >= model.GameState.getTargetScoreForLevel(newLevel + 1)) {
        newLevel++;
      }
      if (newLevel > previousLevel) {
        debugPrint(
          '🎮 [GameCubit] LEVEL UP! $previousLevel -> $newLevel (next target: ${model.GameState.getTargetScoreForLevel(newLevel + 1)})',
        );
        _audioService.playSound('level_up');
        HapticFeedback.mediumImpact();
        _analytics.trackLevelUp(newLevel);

        // Award coins for every level gained this tick.
        for (var lvl = previousLevel + 1; lvl <= newLevel; lvl++) {
          final levelForCoins = lvl;
          Future.microtask(() => _coinsCubit.earnCoins(
            CoinEarningSource.levelUp,
            metadata: {'level': levelForCoins},
          ));
        }
      } else {
        _audioService.playSound('eat');
        HapticFeedback.lightImpact();
      }

      // Regenerate only the eaten food slot. In single-food mode this just
      // replaces currentFood; in multi-food mode it preserves the other
      // visible foods so the board stays populated.
      if (willEatPrimaryFood) {
        currentFood = _generateNonOverlappingFood(
          previousState.boardWidth,
          previousState.boardHeight,
          snake,
          existing: extraFoods,
        );
      } else {
        extraFoods[eatenExtraIndex] = _generateNonOverlappingFood(
          previousState.boardWidth,
          previousState.boardHeight,
          snake,
          existing: [
            ?currentFood,
            ...extraFoods.where((f) => f != extraFoods[eatenExtraIndex]),
          ],
        );
      }
    }

    // Handle power-up collection
    // Performance: inline filter instead of removeExpiredPowerUps() which
    // creates a throwaway GameState copy with 20+ fields just to get a list
    var activePowerUps = previousState.activePowerUps
        .where((p) => !p.isExpired)
        .toList();
    if (willCollectPowerUp) {
      debugPrint('🎁 Collecting power-up: ${currentPowerUp.type.name}');
      _hapticService.powerUpCollected();
      _powerUpsCollectedThisGame++;
      _analytics.trackPowerUpUsed(currentPowerUp.type.name);

      // Buffer battle pass XP for power-up collection (flushed at game end)
      _battlePassCubit.bufferXP(
        BattlePassXpSource.getXpForAction('power_up_collected'),
        source: 'power_up_collected',
      );

      // Track power-up type for statistics
      _currentGamePowerUpTypes[currentPowerUp.type.name] =
          (_currentGamePowerUpTypes[currentPowerUp.type.name] ?? 0) + 1;

      // Pre-credit the full duration to the power-up-time counter. At
      // game-end (_trackGameEndLocal) we subtract any leftover time on
      // power-ups that are still active. Net effect: every expired
      // power-up contributes its full duration; active-at-end power-ups
      // contribute the time actually spent under the effect. Previously
      // the counter was computed only from active-at-end power-ups,
      // erasing every expired one entirely.
      _currentGamePowerUpTime += currentPowerUp.type.duration.inSeconds;

      activePowerUps = [
        ...activePowerUps,
        ActivePowerUp(type: currentPowerUp.type),
      ];
      currentPowerUp = null;
      shouldClearPowerUp = true;
      _audioService.playSound('power_up');
    }

    final newGameState = previousState.copyWith(
      snake: snake,
      food: currentFood,
      foods: extraFoods,
      powerUp: currentPowerUp,
      clearPowerUp: shouldClearPowerUp,
      score: newScore,
      level: newLevel,
      currentCombo: newCombo,
      maxCombo: newMaxCombo,
      comboMultiplier: newComboMultiplier,
      activePowerUps: activePowerUps,
      lastMoveTime: now, // Reuse timestamp from start of tick instead of calling DateTime.now() again
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

  /// Generate a Food whose position doesn't overlap the snake, any of the
  /// already-placed foods, or the active power-up. Used by MultiFood mode so
  /// the simultaneous foods don't stack onto the same cell or land on a
  /// power-up that the player would then "eat" instead of collect.
  Food _generateNonOverlappingFood(
    int boardWidth,
    int boardHeight,
    Snake snake, {
    Iterable<Food> existing = const [],
  }) {
    final taken = <Position>{
      ...existing.map((f) => f.position),
      ?state.gameState?.powerUp?.position,
    };
    // Bounded retry: at most 32 attempts. If everything collides (effectively
    // never on a normal-size board) fall back to the unguarded generator so
    // we never deadlock the game tick.
    for (var attempt = 0; attempt < 32; attempt++) {
      final candidate = Food.generateRandom(boardWidth, boardHeight, snake);
      if (!taken.contains(candidate.position)) {
        return candidate;
      }
    }
    return Food.generateRandom(boardWidth, boardHeight, snake);
  }

  void _trySpawnPowerUp() {
    if (state.status != GamePlayStatus.playing) return;
    if (state.gameState?.powerUp != null) return;

    final random = Random();
    if (random.nextDouble() < 0.5) {
      final current = state.gameState!;
      // Avoid every visible food (primary + multi-food extras) so the new
      // power-up doesn't share a cell with an eatable target.
      final powerUp = PowerUp.generateRandom(
        current.boardWidth,
        current.boardHeight,
        current.snake,
        foodPosition: current.food?.position,
        foodPositions: current.foods.map((f) => f.position),
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

  /// Survival-mode respawn: rebuild snake at spawn, regenerate food, keep
  /// the current score and level, and decrement livesRemaining by one.
  /// Plays a softer "crash" cue rather than the full game-over flow.
  void _respawnAfterCrash(model.GameState current) {
    _audioService.playSound('game_over');
    _enhancedAudioService.playSfx('game_over', volume: 0.6);
    HapticFeedback.heavyImpact();

    final newSnake = Snake.initial();
    final newFood = Food.generateRandom(
      current.boardWidth,
      current.boardHeight,
      newSnake,
    );
    // Re-seed extras list if the active mode wants multiple simultaneous foods.
    final extras = <Food>[];
    if (current.gameMode.hasMultipleFood) {
      for (var i = 0; i < 2; i++) {
        extras.add(
          _generateNonOverlappingFood(
            current.boardWidth,
            current.boardHeight,
            newSnake,
            existing: [newFood, ...extras],
          ),
        );
      }
    }

    emit(
      state.copyWith(
        gameState: current.copyWith(
          snake: newSnake,
          food: newFood,
          foods: extras,
          activePowerUps: const [],
          clearPowerUp: true,
          currentCombo: 0,
          comboMultiplier: 1.0,
          livesRemaining: current.livesRemaining - 1,
          status: model.GameStatus.playing,
          crashReason: null,
          crashPosition: null,
          collisionBodyPart: null,
          showCrashModal: false,
        ),
        previousGameState: current,
        moveProgress: 0.0,
      ),
    );
  }

  void _handleCrash(
    model.CrashReason reason,
    Position? crashPosition, {
    Position? collisionBodyPart,
  }) {
    debugPrint(
      '🎮 [GameCubit] _handleCrash called: reason=$reason, crashPosition=$crashPosition',
    );

    // Track what type of crash for achievements + per-game counts. In
    // Survival mode this method fires once per life lost; the int counters
    // accumulate while the booleans stay true after the first hit.
    if (reason == model.CrashReason.wallCollision) {
      _hitWallThisGame = true;
      _wallHitsThisGame++;
      _hapticService.wallHit();
    } else if (reason == model.CrashReason.selfCollision) {
      _hitSelfThisGame = true;
      _selfHitsThisGame++;
      _hapticService.selfCollision();
    }

    // Survival mode: consume a life and respawn instead of ending the game.
    final currentGameState = state.gameState;
    if (currentGameState != null &&
        currentGameState.gameMode.initialLives > 1 &&
        currentGameState.livesRemaining > 1) {
      _respawnAfterCrash(currentGameState);
      return;
    }

    // Cancel all timers
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();
    _timeAttackTimer?.cancel();
    _timeAttackTimer = null;
    _timeAttackRemaining = null;

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
      Future.delayed(const Duration(milliseconds: 500), () async {
        if (state.status == GamePlayStatus.crashed) {
          await _gameOver();
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
        Future.delayed(modalDuration, () async {
          if (state.status == GamePlayStatus.crashed) {
            await _gameOver();
          }
        });
      }
    });
  }

  /// Local-only game end processing: achievement checks + coin awards + recording.
  /// No API calls — all syncing is deferred to [_postGameSync].
  void _trackGameEndLocal() {
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

    // Check achievements locally (no API calls — _unlockAchievementLocal only).
    // `totalGamesPlayed` is the count BEFORE this game is recorded, so +1
    // reflects the game we're finishing right now.
    final projectedTotalGames =
        _statisticsService.statistics.totalGamesPlayed + 1;
    final scoreUnlocks = _achievementService.checkScoreAchievements(
      gameState.score,
    );
    final gamesUnlocks = _achievementService.checkGamePlayedAchievements(
      projectedTotalGames,
    );
    final survivalUnlocks = _achievementService.checkSurvivalAchievements(
      gameDurationSeconds,
    );
    final specialUnlocks = _achievementService.checkSpecialAchievements(
      level: gameState.level,
      hitWall: _hitWallThisGame,
      hitSelf: _hitSelfThisGame,
      foodTypesEaten: _foodTypesEatenThisGame,
      noWallGames: _consecutiveGamesWithoutWallHits,
      maxCombo: gameState.maxCombo,
      snakeLength: gameState.snake.body.length,
      gameEndTime: DateTime.now(),
    );

    // Buffer battle pass XP for newly unlocked achievements. (Coin and
    // backend-XP rewards are NOT credited locally — the backend's
    // ClaimAchievementRewardCommand grants them atomically into User.Coins
    // and User.Experience, then the next CoinsCubit.syncWithBackend pulls
    // the new balance. Crediting locally too would double-grant for online
    // players; offline players will see the credit appear on next sync.)
    final allNewUnlocks = [
      ...scoreUnlocks,
      ...gamesUnlocks,
      ...survivalUnlocks,
      ...specialUnlocks,
    ];
    for (final achievement in allNewUnlocks) {
      final xpKey = 'achievement_unlocked_${achievement.rarity.name}';
      final xp = BattlePassXpSource.getXpForAction(xpKey);
      if (xp > 0) {
        _battlePassCubit.bufferXP(xp, source: xpKey);
      }
    }

    // Calculate power-up time. `_currentGamePowerUpTime` was pre-credited
    // with each collected power-up's full duration at collection time.
    // Subtract any time that wasn't actually spent — the remaining time
    // on power-ups still active when the game ended.
    final unspentPowerUpSeconds = gameState.activePowerUps.fold<int>(
      0,
      (sum, p) => sum + p.remainingTime.inSeconds,
    );
    _currentGamePowerUpTime = (_currentGamePowerUpTime - unspentPowerUpSeconds)
        .clamp(0, 1 << 30);

    // Finish game recording (local only)
    final crashReasonStr = _hitWallThisGame
        ? 'wall'
        : _hitSelfThisGame
        ? 'self'
        : null;
    _gameRecorder.finishRecording(
      playerName: 'Player',
      finalScore: gameState.score,
      gameMode: gameState.gameMode.name,
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
    _timeAttackTimer?.cancel();
    _timeAttackTimer = null;
    _timeAttackRemaining = null;
    _gameRecorder.stopRecording();

    final highScore =
        state.gameState?.highScore ?? _settingsCubit.state.highScore;
    final gameState = model.GameState.initial().copyWith(
      highScore: highScore,
      boardWidth: _settingsCubit.state.boardSize.width,
      boardHeight: _settingsCubit.state.boardSize.height,
      gameMode: _settingsCubit.state.gameMode,
      foods: const [],
    );

    emit(
      state.copyWith(
        status: GamePlayStatus.ready,
        gameState: gameState,
        clearPreviousGameState: true,
        moveProgress: 0.0,
      ),
    );
  }

  /// Return to menu state
  void backToMenu() {
    _gameTimer?.cancel();
    _animationTimer?.cancel();
    _powerUpTimer?.cancel();
    _timeAttackTimer?.cancel();
    _timeAttackTimer = null;
    _timeAttackRemaining = null;
    _gameRecorder.stopRecording();

    emit(
      state.copyWith(
        status: GamePlayStatus.ready,
        clearPreviousGameState: true,
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
  Future<void> _gameOver() async {
    debugPrint('🎮 [GameCubit] _gameOver called');

    _hapticService.gameOver();

    final gameState = state.gameState;
    if (gameState == null) return;

    // Determine high score FIRST (sync operation)
    int highScore = gameState.highScore;
    bool isNewHighScore = gameState.score > highScore;
    if (isNewHighScore) {
      highScore = gameState.score;
    }

    // Local-only achievement checks (no API calls) so game over screen has data
    _trackGameEndLocal();

    // Track game over analytics
    final gameDuration = _gameStartTime != null
        ? DateTime.now().difference(_gameStartTime!).inSeconds
        : 0;
    final totalFoodEaten = _currentGameFoodTypes.values.fold(0, (a, b) => a + b);
    final cause = _hitWallThisGame
        ? 'wall'
        : _hitSelfThisGame
            ? 'self'
            : 'unknown';
    _analytics.trackGameOver(
      score: gameState.score,
      level: gameState.level,
      durationSeconds: gameDuration,
      cause: cause,
      foodEaten: totalFoodEaten,
      powerUpsCollected: _powerUpsCollectedThisGame,
      maxCombo: gameState.maxCombo,
      isNewHighScore: isNewHighScore,
    );

    // EMIT STATE immediately — UI transitions to game over screen INSTANTLY
    emit(
      state.copyWith(
        status: GamePlayStatus.gameOver,
        gameState: gameState.copyWith(
          status: model.GameStatus.gameOver,
          highScore: highScore,
        ),
      ),
    );

    // All remaining work is fire-and-forget — user already sees game over screen
    unawaited(_postGameSync(
      gameState: gameState,
      isNewHighScore: isNewHighScore,
      highScore: highScore,
    ));

    // Stop recording
    _gameRecorder.stopRecording();
  }

  /// Runs all post-game API syncs in the background (non-blocking).
  Future<void> _postGameSync({
    required model.GameState gameState,
    required bool isNewHighScore,
    required int highScore,
  }) async {
    try {
      if (isNewHighScore) {
        await _storageService.saveHighScore(highScore);
        _settingsCubit.updateHighScore(highScore);
        _audioService.playSound('high_score');
        _enhancedAudioService.playSfx('high_score', volume: 1.0);
      }

      final gameDurationSeconds = _gameStartTime != null
          ? DateTime.now().difference(_gameStartTime!).inSeconds
          : 0;
      final foodEaten = _currentGameFoodTypes.values.fold(
        0,
        (sum, count) => sum + count,
      );

      // Queue regular score sync (counts toward the global leaderboard +
      // high-score + lifetime stats, regardless of tournament mode).
      final nowMs = DateTime.now().millisecondsSinceEpoch;
      _dataSyncService.queueSync('score', {
        'score': gameState.score,
        'gameDuration': gameDurationSeconds,
        'foodsEaten': foodEaten,
        'gameMode':
            state.isTournamentMode ? 'tournament' : gameState.gameMode.name,
        'difficulty': 'normal',
        'playedAt': DateTime.now().toIso8601String(),
        'idempotencyKey': '${nowMs}_${gameState.score}',
      }, priority: SyncPriority.high);

      // Tournament dual-write: when a tournament-mode game ends, ALSO
      // submit to the tournament-specific endpoint so the tournament
      // leaderboard receives the score. Without this the score only
      // lands on the global leaderboard and the user never appears in
      // the tournament's standings. Distinct idempotency key keeps the
      // two paths' retries from colliding on the server.
      if (state.isTournamentMode && state.tournamentId != null) {
        _dataSyncService.queueSync('tournament_score', {
          'tournamentId': state.tournamentId,
          'score': gameState.score,
          'gameDuration': gameDurationSeconds,
          'foodsEaten': foodEaten,
          'playedAt': DateTime.now().toIso8601String(),
          'idempotencyKey':
              'tour_${state.tournamentId}_${nowMs}_${gameState.score}',
        }, priority: SyncPriority.critical);
      }

      // Award coins for game completion (local)
      await _awardGameCompletionCoins(
        score: gameState.score,
        level: gameState.level,
        foodEaten: foodEaten,
        gameDurationSeconds: gameDurationSeconds,
      );

      // Buffer remaining battle pass XP and flush once
      _bufferBattlePassXP(
        score: gameState.score,
        foodEaten: foodEaten,
        survivalSeconds: gameDurationSeconds,
      );

      // STEP A — Local stats update + cache refresh first. These are all
      // fast local writes (Drift + in-memory snapshot copy). Doing this
      // before the network-bearing Future.wait below guarantees that when
      // the user navigates to the Profile or Statistics screen right after
      // game-over, the AppDataCache snapshot already reflects the new high
      // score. Previously the refresh fired after the Future.wait, which
      // could take 200ms–1.5s online (and used to take ~15s offline before
      // the BattlePass connectivity gate landed), producing a visible
      // stale-then-fresh flash on those screens.
      await _statisticsService.recordGameResult(
        score: gameState.score,
        gameTime: gameDurationSeconds,
        level: gameState.level,
        foodConsumed: foodEaten,
        foodTypes: _currentGameFoodTypes,
        foodPoints: _currentGameFoodPoints,
        powerUpsCollected: _powerUpsCollectedThisGame,
        powerUpTypes: _currentGamePowerUpTypes,
        powerUpTime: _currentGamePowerUpTime,
        wallHits: _wallHitsThisGame,
        selfHits: _selfHitsThisGame,
        // Perfect game = no wall/self hits + lasted >= 30 seconds. The
        // original spec; TimeAttack timeouts naturally satisfy this since
        // surviving the full 3 minutes without crashing IS impressive.
        isPerfectGame:
            !_hitWallThisGame && !_hitSelfThisGame && gameDurationSeconds >= 30,
        unlockedAchievements: [],
      );

      // Now that lifetime stats include this game, check the catalog's
      // lifetime-driven achievements (power-ups, food variety, perfect
      // games, streaks, weekend days).
      final stats = _statisticsService.statistics;
      _achievementService.checkLifetimeAchievements(
        totalPowerUps: stats.totalPowerUpsCollected,
        powerUpTypeCount: stats.powerUpTypeCount,
        foodTypeCount: stats.foodTypeCount,
        perfectGames: stats.perfectGames,
        currentWinStreak: stats.currentWinStreak,
        dailyPlayTime: stats.dailyPlayTime,
      );

      // Refresh the daily local reminder with the now-current streak so
      // tomorrow's notification reflects this game's outcome. Fire-and-
      // forget — replaces whatever was previously scheduled.
      unawaited(NotificationService().scheduleSmartDailyReminder(
        currentWinStreak: stats.currentWinStreak,
        hasIncompleteDailyChallenge: false,
        highScore: stats.highScore,
      ));

      await getIt<AppDataCache>().refreshStatistics();

      // STEP B — Network-bearing syncs. _postGameSync is already wrapped in
      // unawaited(...) by the caller, so even if these block on slow API
      // calls the user-visible game-over flow doesn't wait on them.
      await Future.wait([
        _achievementService.syncUnlockedAchievements(),
        _dailyChallengeService.updateProgressBatch([
          if (gameState.score > 0)
            (type: ChallengeType.score, value: gameState.score, gameMode: null),
          if (foodEaten > 0)
            (type: ChallengeType.foodEaten, value: foodEaten, gameMode: null),
          if (gameDurationSeconds > 0)
            (type: ChallengeType.survival, value: gameDurationSeconds, gameMode: null),
          (type: ChallengeType.gamesPlayed, value: 1, gameMode: null),
          (
            type: ChallengeType.gameMode,
            value: 1,
            gameMode: gameState.gameMode.name,
          ),
        ]),
        _battlePassCubit.flushXP(),
      ]);

      // Refetch achievements so any server-derived unlocks (score / games /
      // survival auto-evaluated during the queued score submit) replace the
      // local-only state. The sync also auto-claims pending rewards, which
      // increments User.Coins / User.Experience server-side — so chase it
      // with a coin balance refresh to pull the new total client-side.
      // Fire-and-forget — next refresh cycle catches anything missed if
      // the score POST is still queued.
      unawaited(() async {
        await _achievementService.syncWithBackend();
        await _coinsCubit.syncWithBackend();
      }());
    } catch (e) {
      debugPrint('🎮 [GameCubit] Post-game sync error: $e');
    }
  }

  /// Award coins for completing a game based on performance
  Future<void> _awardGameCompletionCoins({
    required int score,
    required int level,
    required int foodEaten,
    required int gameDurationSeconds,
  }) async {
    try {
      // Base coins + bonus based on score (1 base + 1 per 200 points, max 10)
      final coinsEarned = (1 + (score ~/ 200)).clamp(1, 10);

      await _coinsCubit.earnCoins(
        CoinEarningSource.gameCompleted,
        customAmount: coinsEarned,
        metadata: {'score': score, 'level': level, 'foodEaten': foodEaten},
      );

      // Bonus for perfect game (no wall/self hits, played >= 30 seconds).
      // Threshold matches GameStatistics.updateWithGameResult so the
      // perfect-game counter and the coin-bonus award are consistent.
      final isPerfectGame = !_hitWallThisGame &&
          !_hitSelfThisGame &&
          gameDurationSeconds >= 30;

      if (isPerfectGame) {
        await _coinsCubit.earnCoins(
          CoinEarningSource.perfectGame,
          metadata: {
            'duration': gameDurationSeconds,
            'score': score,
          },
        );
      }

      // Bonus for long survival (> 5 minutes = 300 seconds)
      if (gameDurationSeconds > 300) {
        await _coinsCubit.earnCoins(
          CoinEarningSource.longSurvival,
          metadata: {
            'duration': gameDurationSeconds,
            'score': score,
          },
        );
      }

      AppLogger.info(
        'Awarded game completion coins: $coinsEarned (score: $score, perfect: $isPerfectGame, long: ${gameDurationSeconds > 300})',
      );
    } catch (e) {
      AppLogger.error('Error awarding game completion coins', e);
    }
  }

  /// Buffer battle pass XP locally based on game performance.
  /// Called before [flushXP] sends everything in one API call.
  void _bufferBattlePassXP({
    required int score,
    required int foodEaten,
    required int survivalSeconds,
  }) {
    // Game completed XP
    final gameCompletedXp = BattlePassXpSource.getXpForAction('game_completed');
    if (gameCompletedXp > 0) {
      _battlePassCubit.bufferXP(gameCompletedXp, source: 'game_completed');
    }

    // Survival milestone XP (only if not already awarded this game)
    if (survivalSeconds >= 300 && !_bpMilestonesThisGame.contains('survival_300s')) {
      _bpMilestonesThisGame.add('survival_300s');
      final xp = BattlePassXpSource.getXpForAction('survival_300s');
      if (xp > 0) {
        _battlePassCubit.bufferXP(xp, source: 'survival_300s');
      }
    }
    if (survivalSeconds >= 60 && !_bpMilestonesThisGame.contains('survival_60s')) {
      _bpMilestonesThisGame.add('survival_60s');
      final xp = BattlePassXpSource.getXpForAction('survival_60s');
      if (xp > 0) {
        _battlePassCubit.bufferXP(xp, source: 'survival_60s');
      }
    }
  }

  /// Check and award battle pass XP for score milestones
  void _checkScoreMilestones(int score) {
    if (score >= 1000 && !_bpMilestonesThisGame.contains('score_1000')) {
      _bpMilestonesThisGame.add('score_1000');
      final xp = BattlePassXpSource.getXpForAction('score_milestone_1000');
      if (xp > 0) _battlePassCubit.bufferXP(xp, source: 'score_milestone_1000');
    }
    if (score >= 500 && !_bpMilestonesThisGame.contains('score_500')) {
      _bpMilestonesThisGame.add('score_500');
      final xp = BattlePassXpSource.getXpForAction('score_milestone_500');
      if (xp > 0) _battlePassCubit.bufferXP(xp, source: 'score_milestone_500');
    }
    if (score >= 100 && !_bpMilestonesThisGame.contains('score_100')) {
      _bpMilestonesThisGame.add('score_100');
      final xp = BattlePassXpSource.getXpForAction('score_milestone_100');
      if (xp > 0) _battlePassCubit.bufferXP(xp, source: 'score_milestone_100');
    }
  }

  /// Award daily first game XP if this is the first game today
  Future<void> _awardDailyFirstGameXP() async {
    try {
      final lastPlayDate = await _storageService.getLastPlayDate();
      final today = DateTime.now();
      final isFirstGameToday = lastPlayDate == null ||
          lastPlayDate.year != today.year ||
          lastPlayDate.month != today.month ||
          lastPlayDate.day != today.day;

      if (isFirstGameToday) {
        final xp = BattlePassXpSource.getXpForAction('daily_game');
        if (xp > 0) {
          _battlePassCubit.bufferXP(xp, source: 'daily_game');
        }
        await _storageService.saveLastPlayDate(today);
      }
    } catch (e) {
      AppLogger.error('Error checking daily first game', e);
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
    _timeAttackTimer?.cancel();
    return super.close();
  }
}
