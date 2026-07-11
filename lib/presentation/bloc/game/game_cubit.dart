import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/data/database/app_database.dart' show ReplaysCompanion;
import 'package:snake_classic/game/engine/snake_simulation.dart';
import 'package:snake_classic/game/engine/tick_result.dart';
import 'package:snake_classic/game/session/game_feedback.dart';
import 'package:snake_classic/game/session/game_run_summary.dart';
import 'package:snake_classic/game/session/pause_shift.dart';
import 'package:snake_classic/services/game_end_pipeline.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/models/game_replay.dart' show GameRecorder, GameReplay;
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/power_up/power_up_cubit.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/services/review_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/tournament_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
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
  final HapticService _hapticService;
  final AchievementService _achievementService;
  final StatisticsService _statisticsService;
  final StorageService _storageService;
  final GameSettingsCubit _settingsCubit;
  final CoinsCubit _coinsCubit;
  final BattlePassCubit _battlePassCubit;
  final AnalyticsFacade _analytics;

  /// All end-of-run rewards / stats / achievements / sync choreography.
  /// The cubit packages the run into a [GameRunSummary] and delegates.
  final GameEndPipeline _endPipeline;

  // Collaborators that used to be resolved ad hoc (getIt / singleton
  // constructors) deep inside methods. Injected so the cubit's true
  // dependency fan-out is visible at the constructor.
  final PremiumCubit _premiumCubit;
  final PowerUpCubit _powerUpCubit;
  final ReviewService _reviewService;
  final TournamentService _tournamentService;
  final UnifiedUserService _userService;

  /// Null when ads are unavailable in this build/platform — every use is
  /// null-guarded (previously `getIt.isRegistered<AdService>()` checks).
  final AdService? _adService;

  Timer? _gameTimer;
  Timer? _powerUpTimer;
  Timer? _timeAttackTimer;
  Duration? _timeAttackRemaining;

  // Delays the post-crash revive offer until the death animation has played
  // (the offer used to cover the crash the instant it happened). Guarded by
  // run id + status inside the callback; cancelled on reset/close.
  Timer? _reviveOfferTimer;

  final GameRecorder _gameRecorder = GameRecorder();

  /// Pure game mechanics (movement, collision, spawning, combo/level). The
  /// cubit drives it each tick and translates the returned [TickEvent]s into
  /// audio / haptic / analytics / coin / XP / replay side effects.
  final SnakeSimulation _simulation = SnakeSimulation();

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

  // PerfectGame mode visited-cell tracking now lives in [_simulation].

  // Brief tick-rate slowdown after a level-up so the moment lands. Cleared
  // automatically when the window passes (checked in _scheduleNextGameTick).
  DateTime? _levelUpSlowdownUntil;

  // Timer that clears state.lastRejectedInputAt after the gesture indicators
  // have flashed red. Cancelled on each new rejection so back-to-back
  // rejections keep the flash visible.
  Timer? _rejectedInputClearTimer;

  // Same pattern for accepted inputs — drives the edge bloom + snake-head
  // intent shimmer. Cancelled on each new acceptance so back-to-back swipes
  // each get a fresh pulse.
  Timer? _acceptedInputClearTimer;

  // Wall-clock timestamp of the moment pauseGame() last fired. resumeGame
  // reads it to shift every wall-clock-driven game timer (active power-ups,
  // on-board power-up expiry, TimeAttack countdown) forward by the pause
  // duration — otherwise a 10s power-up sitting under a 20s pause is gone
  // when the player resumes.
  DateTime? _pauseStartedAt;

  /// The single audio+haptic mapping for in-play tick events (eat, level,
  /// combo, power-ups, countdown buzzes). Constructed over the injected
  /// services; reset per run.
  late final GameFeedback _feedback = GameFeedback(
    audioService: _audioService,
    hapticService: _hapticService,
  );

  // Battle pass milestone tracking (reset per game)
  final Set<String> _bpMilestonesThisGame = {};

  // Statistics tracking
  final Map<String, int> _currentGameFoodTypes = {};
  int _currentGameFoodPoints = 0;
  final Map<String, int> _currentGamePowerUpTypes = {};
  int _currentGamePowerUpTime = 0;

  // Pro perks (read from PremiumCubit at game start). Drives the boosted
  // special-food rate in Food.generateRandom and the boosted in-game
  // power-up spawn chance in _trySpawnPowerUp. Sticky for the duration of
  // a single game so a mid-session Pro lapse doesn't visibly degrade what
  // the player was just experiencing.
  bool _isPro = false;

  /// Whether this run's player is Pro (snapshotted at game start). Used by the
  /// revive overlay to offer a free Pro life instead of the watch-ad button.
  bool get isProSession => _isPro;

  // Coins credited during this game session — snapshotted from balance.earned
  // diffs around each earnCoins call so it stays accurate after the daily
  // cap or Pro multiplier adjusts the actual grant. Reset on game start;
  // surfaced via GameCubitState.coinsEarnedThisGame for the game-over screen.
  int _currentGameCoinsEarned = 0;

  // Level-up coin grants buffered during play. Awarding coins does a Drift
  // write + outbox enqueue + CoinsCubit emit + SharedPreferences daily-cap
  // write — too heavy to ride a gameplay tick (it landed exactly on the
  // level-up bite and contributed to the post-eat lag). Buffered here and
  // flushed at game end / reset / close instead.
  final List<int> _pendingLevelUpCoinLevels = [];

  // Snapshot of the finished run, built once in _trackGameEndLocal and
  // consumed by _postGameSync. Null while a run is in progress.
  GameRunSummary? _lastRunSummary;

  /// Package the per-run trackers into the pipeline's input.
  GameRunSummary _buildRunSummary(
    model.GameState gameState,
    int gameDurationSeconds,
  ) {
    return GameRunSummary(
      score: gameState.score,
      level: gameState.level,
      maxCombo: gameState.maxCombo,
      snakeLength: gameState.snake.body.length,
      gameMode: gameState.gameMode.name,
      isTournament: state.isTournamentMode,
      durationSeconds: gameDurationSeconds,
      foodTypes: Map<String, int>.from(_currentGameFoodTypes),
      foodPoints: _currentGameFoodPoints,
      foodTypesEaten: Set<String>.from(_foodTypesEatenThisGame),
      powerUpsCollected: _powerUpsCollectedThisGame,
      powerUpTypes: Map<String, int>.from(_currentGamePowerUpTypes),
      powerUpTimeSeconds: _currentGamePowerUpTime,
      hitWall: _hitWallThisGame,
      hitSelf: _hitSelfThisGame,
      wallHits: _wallHitsThisGame,
      selfHits: _selfHitsThisGame,
      consecutiveGamesWithoutWallHits: _consecutiveGamesWithoutWallHits,
    );
  }

  GameCubit({
    required this._audioService,
    required this._hapticService,
    required this._achievementService,
    required this._statisticsService,
    required this._storageService,
    required this._settingsCubit,
    required this._coinsCubit,
    required this._battlePassCubit,
    required this._analytics,
    required this._endPipeline,
    required this._premiumCubit,
    required this._powerUpCubit,
    required this._reviewService,
    required this._tournamentService,
    required this._userService,
    this._adService,
  }) : super(GameCubitState.initial());

  /// Initialize the game cubit
  Future<void> initialize() async {
    await _audioService.initialize();
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
  /// Coin cost of an offline / no-ad revive. Also the rewarded-ad alternative.
  static const int reviveCoinCost = 1500;

  /// One revive per run — flips true on [revive], reset on [startGame].
  bool _revivedThisGame = false;

  /// Time-Attack rewarded "+30s" extension: how many seconds each ad grants,
  /// and how many extensions a single run may earn (kept low so it can't beat
  /// a fresh game). Reset per run on [startGame].
  static const int timeBonusSeconds = 30;
  static const int maxTimeBonusesPerRun = 2;
  int _timeBonusesUsed = 0;

  /// Monotonic run counter — bumped by every startGame(). Delayed
  /// callbacks capture it to detect "a different run is now playing".
  int _runId = 0;

  void startGame() {
    debugPrint('🎮 [GameCubit] startGame() called');

    final settings = _settingsCubit.state;
    // Tournament mode: honor the tournament's declared rules instead of the
    // user's settings mode. Previously the cubit ignored tournamentMode at
    // tick time, so PowerUpMadness tournaments played identically to Classic.
    final effectiveGameMode =
        state.tournamentMode?.toGameMode() ?? settings.gameMode;
    debugPrint(
      '🎮 [GameCubit] Settings: boardSize=${settings.boardSize.width}x${settings.boardSize.height}, gameMode=${effectiveGameMode.name}, highScore=${settings.highScore}',
    );

    final initialLives = effectiveGameMode.initialLives;
    final startTime = DateTime.now();
    final gameState = model.GameState.initial().copyWith(
      highScore: settings.highScore,
      boardWidth: settings.boardSize.width,
      boardHeight: settings.boardSize.height,
      gameMode: effectiveGameMode,
      status: model.GameStatus.playing,
      currentCombo: 0,
      maxCombo: 0,
      comboMultiplier: 1.0,
      initialLives: initialLives,
      livesRemaining: initialLives,
      gameStartTime: startTime,
    );

    // Reset tracking
    _runId++;
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
    _currentGameCoinsEarned = 0;
    _pendingLevelUpCoinLevels.clear();
    _lastRunSummary = null;
    _revivedThisGame = false;
    _timeBonusesUsed = 0;
    // Snapshot Pro status once at game start — sticky for the session.
    // (PremiumCubit is injected, so registration is guaranteed.)
    _isPro = _premiumCubit.state.hasPremium;
    _achievementService.resetLastGameUnlocks();
    _simulation.reset(snakeBody: gameState.snake.body, isPro: _isPro);
    _feedback.resetForNewRun();

    // Daily first game XP
    _awardDailyFirstGameXP();

    // Generate initial food. MultiFood mode spawns 3 simultaneously.
    final initialFoods = _simulation.generateInitialFoods(
      gameState.boardWidth,
      gameState.boardHeight,
      gameState.snake,
      gameState.gameMode,
    );

    _gameRecorder.startRecording();

    final newState = state.copyWith(
      status: GamePlayStatus.playing,
      gameState: gameState.copyWith(
        food: initialFoods.primary,
        foods: initialFoods.extras,
      ),
      clearPreviousGameState: true,
      tournamentScoreSubmission: TournamentScoreSubmission.none,
    );

    debugPrint(
      '🎮 [GameCubit] Emitting new state: status=${newState.status}, gameState.snake.length=${newState.gameState?.snake.length}',
    );
    emit(newState);
    debugPrint(
      '🎮 [GameCubit] State emitted. Current state.status=${state.status}',
    );

    // Brief "Ready" beat before the first tick fires so the player gets a
    // moment to focus on the snake's starting position. Reuses the
    // level-up slowdown plumbing — set the deadline 500ms out and
    // _scheduleNextGameTick will stretch the very first tick by 1.5x.
    // Auto-clears once the window passes.
    _levelUpSlowdownUntil =
        DateTime.now().add(const Duration(milliseconds: 500));

    _startGameLoop();
    _startPowerUpTimer();
    // Must be the EFFECTIVE mode — a TimeAttack tournament played while
    // the user's settings say Classic previously never started its
    // end-of-time timer.
    _startTimeAttackTimer(effectiveGameMode);

    // Pre-game power-up activation: if the user armed a power-up via the
    // home-screen loadout, fire it 5 seconds into the game so they have
    // time to settle into the run before the effect kicks in. Consuming
    // from inventory + clearing the armed slot is handled by the cubit.
    _activateArmedPowerUpIfAny();

    // Tournament-mode start sounds louder + adds a medium haptic so the
    // moment registers as different from a casual run. Casual play keeps
    // the original 0.8 game_start volume with no haptic.
    //
    // Single service only — a previous build also called the legacy
    // _audioService.playSound('game_start') here, which double-played
    // the cue on cold start (one service warm, one loading lazily =
    // two audible plays ~half a second apart).
    if (state.isTournamentMode) {
      _audioService.playSound('game_start', volume: 1.0);
      unawaited(_hapticService.mediumImpact());
    } else {
      _audioService.playSound('game_start', volume: 0.8);
    }

    // Looping background track for the run — gated inside the service on
    // the user's Background Music setting, paused/resumed with the game,
    // stopped at game over / quit.
    unawaited(_audioService.startGameplayMusic());

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
    final powerUpCubit = _powerUpCubit;
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
    // Capture the run id so the callback can tell "this run is still
    // going" apart from "a NEW run started within the 5s window" — the
    // status==playing check alone let game A's armed power-up inject
    // itself into game B.
    final runId = _runId;
    Future.delayed(const Duration(seconds: 5), () {
      if (isClosed) return;
      // If the game ended (game over / quit) before the activation
      // window, silently drop. Inventory was already consumed — that's
      // a deliberate "you paid for it" cost.
      if (runId != _runId) return;
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
      // Single service only — see startGame() for the cold-start
      // double-play story this avoids. The id must be 'power_up' —
      // that's the shipped asset (power_up.wav); there is no
      // power_up_collect.wav, and a bad id fails silently.
      _audioService.playSound('power_up', volume: 0.8);
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
    _powerUpTimer?.cancel();
    unawaited(_audioService.pauseGameplayMusic());

    // TimeAttack: snapshot how much time is left so resume can re-arm.
    if (_timeAttackTimer != null && _timeAttackScheduledAt != null) {
      final elapsed = DateTime.now().difference(_timeAttackScheduledAt!);
      final remaining = (_timeAttackRemaining ?? Duration.zero) - elapsed;
      _timeAttackRemaining =
          remaining.isNegative ? Duration.zero : remaining;
      _timeAttackTimer?.cancel();
      _timeAttackTimer = null;
    }

    final pauseStamp = DateTime.now();
    _pauseStartedAt = pauseStamp;

    final current = state.gameState;
    if (current != null) {
      // Freeze every wall-clock-driven object (pure math in pause_shift.dart;
      // preserves premium power-up identity). Without this, the HUD's 60fps
      // animation controllers tick the displayed seconds down even while the
      // game tick timer is cancelled.
      emit(
        state.copyWith(
          status: GamePlayStatus.paused,
          gameState: stampPausedAt(current, pauseStamp)
              .copyWith(status: model.GameStatus.paused),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: GamePlayStatus.paused,
          gameState: state.gameState?.copyWith(status: model.GameStatus.paused),
        ),
      );
    }

    _analytics.trackGamePaused();
  }

  /// Resume the game
  void resumeGame() {
    if (state.status != GamePlayStatus.paused) return;

    unawaited(_audioService.resumeGameplayMusic());

    // Shift every wall-clock timer forward by the time we spent paused so
    // power-ups + TimeAttack pick up where they left off instead of losing
    // their remaining seconds to real-world time.
    final pauseDuration = _pauseStartedAt != null
        ? DateTime.now().difference(_pauseStartedAt!)
        : Duration.zero;
    _pauseStartedAt = null;

    // The end-of-game duration stats are measured from this private anchor, so
    // it must skip the paused window too — otherwise time spent paused (incl.
    // the app being backgrounded for hours, which auto-pauses) is recorded as
    // play time. Mirrors the state.gameStartTime shift applied below for the
    // HUD; the two anchors must move together to stay consistent.
    if (pauseDuration > Duration.zero) {
      _gameStartTime = _gameStartTime?.add(pauseDuration);
    }

    final current = state.gameState;
    if (current != null && pauseDuration > Duration.zero) {
      // Unfreeze: shift every wall-clock anchor forward by the pause window
      // AND clear pausedAt (pure math in pause_shift.dart). The two halves
      // keep the displayed remaining time stable across the pause boundary:
      // the shift cancels out the elapsed real-world time, the pausedAt
      // clear makes the math use DateTime.now() again.
      emit(
        state.copyWith(
          status: GamePlayStatus.playing,
          gameState: shiftAfterPause(current, pauseDuration)
              .copyWith(status: model.GameStatus.playing),
        ),
      );
    } else {
      emit(
        state.copyWith(
          status: GamePlayStatus.playing,
          gameState: current?.copyWith(
            status: model.GameStatus.playing,
            clearPausedAt: true,
          ),
        ),
      );
    }

    // Resume cue: reuse the button_click SFX at low volume + light haptic so
    // the player feels the world come back to life rather than silently
    // sliding from frozen to running.
    _audioService.playSound('button_click', volume: 0.4);
    unawaited(_hapticService.lightImpact());

    _startGameLoop();
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

    final accepted = state.gameState!.snake.changeDirection(newDirection);
    if (accepted) {
      _hapticService.selectionClick();
      // Emit timestamp + direction so the edge bloom and snake-head intent
      // shimmer can fire. Clears after 300ms.
      final stamp = DateTime.now();
      emit(state.copyWith(
        lastAcceptedInputAt: stamp,
        lastAcceptedDirection: newDirection,
      ));
      _acceptedInputClearTimer?.cancel();
      _acceptedInputClearTimer = Timer(const Duration(milliseconds: 300), () {
        if (state.lastAcceptedInputAt == stamp) {
          emit(state.copyWith(clearAcceptedInput: true));
        }
      });
    } else {
      // Denied: surface a double-buzz haptic + timestamp the rejection so
      // the gesture indicators can flash red. Without this, reverse-into-
      // self attempts look like the game ignored the input entirely.
      _hapticService.selectionClick();
      Future.delayed(const Duration(milliseconds: 80), () {
        _hapticService.selectionClick();
      });
      final stamp = DateTime.now();
      emit(state.copyWith(lastRejectedInputAt: stamp));
      _rejectedInputClearTimer?.cancel();
      _rejectedInputClearTimer = Timer(const Duration(milliseconds: 250), () {
        if (state.lastRejectedInputAt == stamp) {
          emit(state.copyWith(clearRejectedInput: true));
        }
      });
    }
  }

  void _startGameLoop() {
    _gameTimer?.cancel();
    _scheduleNextGameTick();
  }

  /// Tick duration computed by _updateGame for the tick it just emitted, so
  /// the armed timer and the state's [tickDurationMs] snapshot are the exact
  /// same number. Consumed (and cleared) by _scheduleNextGameTick; null when
  /// scheduling happens outside a tick (loop start / resume).
  int? _pendingTickDurationMs;

  /// Duration of the upcoming tick: current speed, stretched 1.5x while the
  /// level-up beat window is open. The window is cleared automatically when
  /// DateTime.now() passes the deadline.
  int _computeNextTickDurationMs(int baseSpeed) {
    var speed = baseSpeed;
    final slowdown = _levelUpSlowdownUntil;
    if (slowdown != null) {
      if (DateTime.now().isBefore(slowdown)) {
        speed = (speed * 1.5).round();
      } else {
        _levelUpSlowdownUntil = null;
      }
    }
    return speed;
  }

  /// Schedules the next game tick using the current game speed.
  /// This pattern allows speed changes to take effect immediately
  /// without causing a pause when the timer is restarted.
  void _scheduleNextGameTick() {
    final speed = _pendingTickDurationMs ??
        _computeNextTickDurationMs(state.gameState?.gameSpeed ?? 150);
    _pendingTickDurationMs = null;
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

  void _startPowerUpTimer() {
    _powerUpTimer?.cancel();
    final mode = state.gameState?.gameMode;
    final intervalSeconds = mode?.powerUpSpawnIntervalSecondsOverride ??
        GameConstants.powerUpSpawnIntervalSeconds;
    _powerUpTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
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
        // Offer a rewarded "+30s" extension before ending the run, if eligible
        // and an ad is (or can become) ready. Otherwise just end the game.
        if (_canOfferTimeBonus()) {
          final ads = _adService;
          final adReady = ads != null && ads.isRewardedReady;
          ads?.preloadRewarded();
          if (adReady) {
            _offerTimeBonus();
            return;
          }
        }
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

    // Advance the pure simulation by one tick. It returns the next state plus
    // a list of domain events; the cubit translates those into side effects.
    final result = _simulation.step(previousState);

    if (result.crashed) {
      final crash = result.crashEvent!;
      _handleCrash(
        crash.reason,
        crash.position,
        collisionBodyPart: crash.collisionBodyPart,
        fatalSnake: crash.fatalSnake,
      );
      return;
    }

    final newGameState = result.nextState!;
    var ateFood = false;
    var collectedPowerUp = false;

    // Bookkeeping per event (trackers / analytics / XP / coin buffering).
    // Audio + haptics for the same events are handled by _feedback below —
    // the sound/vibration mapping lives in ONE place (GameFeedback).
    for (final event in result.events) {
      switch (event) {
        case FoodEatenEvent():
          ateFood = true;
          _foodTypesEatenThisGame.add(event.food.type.name);
          _currentGameFoodTypes[event.food.type.name] =
              (_currentGameFoodTypes[event.food.type.name] ?? 0) + 1;
          _currentGameFoodPoints += event.awardedPoints;

          // Battle pass score milestones - deferred to avoid event loop
          // contention during the tick (addXP can trigger HTTP on first call).
          Future.microtask(() => _checkScoreMilestones(newGameState.score));
        case LeveledUpEvent():
          debugPrint(
            '🎮 [GameCubit] LEVEL UP! ${event.fromLevel} -> ${event.toLevel} (next target: ${model.GameState.getTargetScoreForLevel(event.toLevel + 1)})',
          );
          // 300ms tick slowdown so the level transition reads as an event
          // rather than a silent counter increment.
          _levelUpSlowdownUntil =
              DateTime.now().add(const Duration(milliseconds: 300));
          _analytics.trackLevelUp(event.toLevel);

          // Buffer the coin award for every level gained this tick; the
          // actual grant (Drift write + emits) is flushed at game end so
          // no storage work runs during the tick.
          for (var lvl = event.fromLevel + 1; lvl <= event.toLevel; lvl++) {
            _pendingLevelUpCoinLevels.add(lvl);
          }
        case PowerUpCollectedEvent():
          collectedPowerUp = true;
          debugPrint('🎁 Collecting power-up: ${event.powerUp.type.name}');
          _powerUpsCollectedThisGame++;
          _analytics.trackPowerUpUsed(event.powerUp.type.name);

          // Buffer battle pass XP for power-up collection (flushed at game end).
          _battlePassCubit.bufferXP(
            BattlePassXpSource.getXpForAction('power_up_collected'),
            source: 'power_up_collected',
          );

          // Track power-up type for statistics.
          _currentGamePowerUpTypes[event.powerUp.type.name] =
              (_currentGamePowerUpTypes[event.powerUp.type.name] ?? 0) + 1;

          // Pre-credit the full duration to the power-up-time counter; at
          // game-end we subtract any leftover time on still-active power-ups.
          _currentGamePowerUpTime += event.powerUp.type.duration.inSeconds;
        case ComboBrokenEvent():
          break; // Feedback-only event — handled by _feedback below.
        case CrashEvent():
          break; // Handled above via result.crashed.
      }
    }

    // Audio + haptics for this tick, in one place.
    _feedback.onTickEvents(result.events);
    _feedback.onActivePowerUps(newGameState.activePowerUps);

    // Snapshot the upcoming tick's duration once: the emitted state carries it
    // for the renderer's interpolation window, and _scheduleNextGameTick (which
    // runs right after this method returns) arms the timer with the same value.
    final nextTickMs = _computeNextTickDurationMs(newGameState.gameSpeed);
    _pendingTickDurationMs = nextTickMs;

    final newCubitState = state.copyWith(
      gameState: newGameState,
      previousGameState: previousState,
      tickDurationMs: nextTickMs,
      tickEvents: result.events,
    );

    if (_updateCount <= 5) {
      debugPrint(
        '🎮 [GameCubit] _updateGame #$_updateCount emitting: snake moved to ${newGameState.snake.head}',
      );
    }

    emit(newCubitState);

    // Note: No need to restart the game loop on level-up — _scheduleNextGameTick
    // reads speed fresh each tick, so level-up speed changes apply immediately.

    _recordFrame(
      newGameState.snake,
      newGameState.food,
      newGameState.powerUp,
      newGameState,
      ateFood,
      collectedPowerUp,
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
    final current = state.gameState;
    if (current == null || current.powerUp != null) return;

    final powerUp = _simulation.trySpawnPowerUp(current);
    if (powerUp != null) {
      emit(state.copyWith(gameState: current.copyWith(powerUp: powerUp)));
    }
  }

  /// Survival-mode respawn: rebuild snake at spawn, regenerate food, keep
  /// the current score and level, and decrement livesRemaining by one.
  /// Plays a softer "crash" cue rather than the full game-over flow.
  void _respawnAfterCrash(model.GameState current) {
    // Single service only — the legacy _audioService.playSound('game_over')
    // alongside this double-played the cue. The enhanced call stays because
    // it supports the softer 0.6 volume this per-life crash wants.
    _audioService.playSound('game_over', volume: 0.6);
    _hapticService.heavyImpact();

    final newSnake = Snake.initial();
    // PerfectGame respawns get a fresh visited-cell map; the rule applies
    // per-life rather than across the whole run.
    _simulation.reset(snakeBody: newSnake.body);
    // Re-seed food (and MultiFood extras) for the fresh snake.
    final respawnFoods = _simulation.generateInitialFoods(
      current.boardWidth,
      current.boardHeight,
      newSnake,
      current.gameMode,
    );

    emit(
      state.copyWith(
        gameState: current.copyWith(
          snake: newSnake,
          food: respawnFoods.primary,
          foods: respawnFoods.extras,
          activePowerUps: const [],
          clearPowerUp: true,
          // Survival respawn: preserve combo across lives instead of zeroing
          // it. Resetting punished the player twice — once with the lost life,
          // once by dropping their multiplier — which felt unfair.
          currentCombo: current.currentCombo,
          comboMultiplier: current.comboMultiplier,
          livesRemaining: current.livesRemaining - 1,
          status: model.GameStatus.playing,
          crashReason: null,
          crashPosition: null,
          collisionBodyPart: null,
          showCrashModal: false,
        ),
        previousGameState: current,
        ),
    );
  }

  void _handleCrash(
    model.CrashReason reason,
    Position? crashPosition, {
    Position? collisionBodyPart,
    Snake? fatalSnake,
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

    // Crash render: we commit the FATAL snake ([fatalSnake], head on the cell
    // it died on — into the wall / onto its body) as the crash-frame snake, and
    // pin previousGameState to the pre-move state (head on the last valid cell).
    // The board interpolates the head from previousGameState → gameState, so it
    // gets a clean one-cell delta to lunge across; the board plays that as a
    // short one-shot "lunge into the wall" on crash (see GameBoard's crash
    // lunge controller). Without committing the fatal snake the head would stay
    // a cell back from where it died.
    final preMoveState = currentGameState;

    // Cancel all timers
    _gameTimer?.cancel();
    _powerUpTimer?.cancel();
    _timeAttackTimer?.cancel();
    _timeAttackTimer = null;
    _timeAttackRemaining = null;

    // Play crash sound and haptic feedback immediately. Music freezes with
    // the run; revive() resumes it. Self-collision plays the same asset
    // pitch-shifted down — a duller "thud" that matches the distinct
    // haptic patterns the two death causes already have.
    _audioService.playSound(
      'game_over',
      volume: 1.0,
      playbackRate:
          reason == model.CrashReason.selfCollision ? 0.85 : 1.0,
    );
    unawaited(_audioService.pauseGameplayMusic());
    _hapticService.heavyImpact();

    // Offer a revive (rewarded ad or coins) before ending the game. Once per
    // run, single-life modes only, and whenever a revive path is *possible*:
    // ads are enabled (so a rewarded ad can be shown — even if it's still
    // loading), or the player can afford the coin cost. We intentionally gate
    // on "ads enabled" rather than "ad already loaded" so the popup still
    // appears while the ad finishes loading; the ReviveOverlay greys the
    // watch-ad button until it's ready (live re-check) and re-enables it the
    // moment it loads during the countdown — same UX as the greyed-out coin
    // button. revive() / declineRevive() resolve it. We DON'T schedule
    // game-over here — the overlay owns that timeout.
    if (_canOfferRevive()) {
      final adsPossible = _adService != null && _adService.adsEnabled;
      // Kick a (re)load so the ad can become ready during the offer countdown
      // — the overlay re-checks readiness live and enables the button then.
      if (adsPossible) _adService.preloadRewarded();
      final canAfford = _coinsCubit.state.balance.total >= reviveCoinCost;
      // Pro users never see ads, so the watch-ad path is off for them — but
      // their revive is FREE: always offer it (the overlay shows a free-life
      // button instead of watch-ad/coins). Without this, a Pro user short on
      // coins would get no revive offer at all.
      if (adsPossible || canAfford || _isPro) {
        // Commit the crash frame FIRST — without the revive offer — so the
        // player actually sees what killed them: the death lunge, white
        // blink, shockwave + X/self-collision marker, and the tail-to-head
        // disintegration (the in-world sequence runs ~1.5s). The offer used
        // to appear in the same frame as the crash, covering all of it —
        // players had no idea what happened before being asked to revive.
        emit(
          state.copyWith(
            status: GamePlayStatus.crashed,
            gameState: state.gameState?.copyWith(
              snake: fatalSnake,
              status: model.GameStatus.crashed,
              crashReason: reason,
              crashPosition: crashPosition,
              collisionBodyPart: collisionBodyPart,
              showCrashModal: false,
            ),
            previousGameState: preMoveState,
          ),
        );

        // Raise the offer once the death has played out. Players who chose
        // the "skip" crash-feedback setting have said they want speed —
        // they get a short impact beat instead of the full sequence.
        final skipFeedback = _settingsCubit.state.crashFeedbackDuration
                .inSeconds ==
            GameConstants.crashFeedbackSkip;
        final reviveDelay = skipFeedback
            ? const Duration(milliseconds: 600)
            : const Duration(milliseconds: 1800);
        final runId = _runId;
        _reviveOfferTimer?.cancel();
        _reviveOfferTimer = Timer(reviveDelay, () {
          // Only offer if this exact crash is still on screen: same run,
          // still crashed, nothing else resolved it meanwhile.
          if (runId != _runId) return;
          if (state.status != GamePlayStatus.crashed) return;
          if (state.offeringRevive) return;
          emit(state.copyWith(offeringRevive: true));
        });
        return;
      }
    }

    // Get crash feedback duration from settings
    final crashFeedbackDuration = _settingsCubit.state.crashFeedbackDuration;
    final durationSeconds = crashFeedbackDuration.inSeconds;

    // Skip mode: go directly to game over with minimal feedback
    if (durationSeconds == GameConstants.crashFeedbackSkip) {
      final crashedGameState = state.gameState?.copyWith(
        snake: fatalSnake,
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
          previousGameState: preMoveState,
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
      snake: fatalSnake,
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
        previousGameState: preMoveState,
      ),
    );

    // Let the in-world death sequence play (lunge + flash + tail-to-head
    // disintegration ends at ~1.5s — see SnakeFlameGame), then slide the
    // crash banner in over the settled scene.
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (state.status == GamePlayStatus.crashed) {
        // Now show the crash banner (bottom chrome, no scrim)
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

  /// Revive eligibility: once per run, and not in Time Attack (a fresh game
  /// loop there would hand back a full timer, which would be exploitable).
  bool _canOfferRevive() {
    if (_revivedThisGame) return false;
    final gs = state.gameState;
    if (gs == null) return false;
    if (gs.gameMode == GameMode.timeAttack) return false;
    return true;
  }

  /// Continue the current run after a crash — this is a true "revive", not a
  /// restart. The snake the player crashed with is KEPT as-is (same length,
  /// same score/level/combo/food/power-ups). The crash FRAME's snake is the
  /// fatal snake (head lunged into the wall / onto its body, possibly out of
  /// bounds) used only for the death animation — so we revive from the
  /// pre-crash snake we pinned into `previousGameState`, which is the last
  /// valid in-bounds snake.
  ///
  /// The only thing we change is the heading — it's still pointed at the wall
  /// / its own body that killed it, so without turning it the next tick would
  /// re-crash instantly. We pick a safe direction to continue in and grant a
  /// short invincibility grace period so the player can reorient.
  ///
  /// Driven by the ReviveOverlay after a rewarded ad or coin spend; the caller
  /// owns the ad/coin side, this just resumes play.
  void revive() {
    final current = state.gameState;
    if (current == null || _revivedThisGame) return;
    _revivedThisGame = true;

    // The run continues — pick the music back up from where the crash
    // paused it (see _handleCrash).
    unawaited(_audioService.resumeGameplayMusic());

    // Restore the last valid (in-bounds) snake from the pinned pre-crash state,
    // not the fatal crash-frame snake; only steer it somewhere safe to continue.
    final preCrash = state.previousGameState ?? current;
    final snake = preCrash.snake.copy();
    final safeDir = _safeReviveDirection(snake, current);
    final revivedSnake = safeDir != null
        ? Snake.fromPositions(snake.body, safeDir)
        : snake;

    // 3-second invincibility grace so the immediate surroundings (and the
    // wall/body it just hit) can't re-kill before the player reacts.
    final grace = ActivePowerUp(
      type: PowerUpType.invincibility,
      duration: const Duration(seconds: 3),
    );

    emit(
      state.copyWith(
        status: GamePlayStatus.playing,
        offeringRevive: false,
        gameState: current.copyWith(
          snake: revivedSnake,
          activePowerUps: [...current.activePowerUps, grace],
          status: model.GameStatus.playing,
          crashReason: null,
          crashPosition: null,
          collisionBodyPart: null,
          showCrashModal: false,
        ),
        ),
    );

    // A brief "ready" beat before the first tick, same as startGame.
    _levelUpSlowdownUntil =
        DateTime.now().add(const Duration(milliseconds: 600));
    _startGameLoop();
    _startPowerUpTimer();
    _hapticService.mediumImpact();
  }

  /// Pick a direction to continue in after a revive that won't immediately
  /// re-crash: prefer a heading whose next cell is in-bounds and not part of
  /// the snake's body, and never a 180° reverse into the neck. Returns null
  /// if the snake is fully boxed in (the invincibility grace then covers it).
  Direction? _safeReviveDirection(Snake snake, model.GameState gs) {
    final head = snake.head;
    final body = snake.body.toSet();
    final reverse = snake.currentDirection.opposite;
    for (final dir in Direction.values) {
      if (dir == reverse) continue; // can't flip straight back into the body
      final next = head.move(dir);
      final inBounds = !gs.gameMode.hasWalls ||
          next.isWithinBounds(gs.boardWidth, gs.boardHeight);
      if (inBounds && !body.contains(next)) return dir;
    }
    return null;
  }

  /// Dismiss the revive offer and fall through to the normal game-over flow.
  Future<void> declineRevive() async {
    if (state.status != GamePlayStatus.crashed) return;
    emit(state.copyWith(offeringRevive: false));
    await _gameOver();
  }

  /// Time-Attack "+30s" eligibility: only in Time Attack, capped per run.
  bool _canOfferTimeBonus() {
    final gs = state.gameState;
    if (gs == null) return false;
    if (gs.gameMode != GameMode.timeAttack) return false;
    return _timeBonusesUsed < maxTimeBonusesPerRun;
  }

  /// The Time-Attack timer hit zero with an extension still available and an ad
  /// ready. Freeze the run (reusing the pause freeze so power-up timers don't
  /// bleed during the offer) and flag the offer; the TimeBonusOverlay drives
  /// [grantTimeBonus] / [declineTimeBonus].
  void _offerTimeBonus() {
    pauseGame(); // sets status=paused, cancels loops, stamps wall-clock anchors
    emit(state.copyWith(offeringTimeBonus: true));
  }

  /// Player watched a rewarded ad: add [timeBonusSeconds] to the Time-Attack
  /// clock and resume the frozen run. The caller owns the ad side; this just
  /// extends the timer and unfreezes (resumeGame reschedules the TA timer with
  /// the bumped remaining and shifts power-ups past the offer window).
  void grantTimeBonus() {
    if (!state.offeringTimeBonus) return;
    _timeBonusesUsed++;
    _timeAttackRemaining = (_timeAttackRemaining ?? Duration.zero) +
        const Duration(seconds: timeBonusSeconds);
    emit(state.copyWith(offeringTimeBonus: false));
    resumeGame();
  }

  /// Dismiss the Time-Attack offer and end the run.
  Future<void> declineTimeBonus() async {
    if (!state.offeringTimeBonus) return;
    emit(state.copyWith(offeringTimeBonus: false));
    await _gameOver();
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

    // Package the run once; _postGameSync reuses the same summary.
    _lastRunSummary = _buildRunSummary(gameState, gameDurationSeconds);

    // Local (offline-capable) achievement evaluation + per-unlock BP XP.
    // Server-only unlocks earn their XP after the post-game sync completes
    // (handled inside the pipeline's runPostGame).
    _endPipeline.evaluateLocalUnlocks(_lastRunSummary!);

    // Finish game recording (local only)
    final crashReasonStr = _hitWallThisGame
        ? 'wall'
        : _hitSelfThisGame
        ? 'self'
        : null;
    final replay = _gameRecorder.finishRecording(
      // Falls back to 'Player' inside the getter for signed-out users.
      playerName: _userService.displayName,
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

    // Persist the replay locally. GameDao's saveReplay enforces the
    // retention policy (top 10 by score + 10 most recent), so the
    // table can never exceed 20 rows even after a long play session.
    // Fire-and-forget — a failed write must not block the game-over
    // UI; talker logs catch any errors.
    if (replay != null) {
      unawaited(_persistReplay(replay, gameState));
    }
  }

  Future<void> _persistReplay(
    GameReplay replay,
    model.GameState gameState,
  ) async {
    try {
      await _storageService.gameDao.saveReplay(
        ReplaysCompanion(
          id: Value(replay.id),
          name: Value(replay.playerName),
          score: Value(replay.finalScore),
          snakeLength: Value(gameState.snake.length),
          gameDurationSeconds: Value(replay.gameTimeSeconds),
          gameMode: Value(replay.gameMode),
          boardSize: Value('${gameState.boardWidth}x${gameState.boardHeight}'),
          replayData: Value(jsonEncode(replay.toJson())),
          recordedAt: Value(replay.createdAt),
        ),
      );
    } catch (e) {
      AppLogger.error('Failed to persist replay', e);
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
    _powerUpTimer?.cancel();
    _timeAttackTimer?.cancel();
    _timeAttackTimer = null;
    _timeAttackRemaining = null;
    _reviveOfferTimer?.cancel();
    unawaited(_audioService.stopGameplayMusic());
    _gameRecorder.stopRecording();
    // Don't lose level-up coins if the run is abandoned before game over.
    unawaited(_flushPendingLevelUpCoins());

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
        ),
    );
  }

  /// Return to menu state
  void backToMenu() {
    _gameTimer?.cancel();
    _powerUpTimer?.cancel();
    _timeAttackTimer?.cancel();
    _timeAttackTimer = null;
    _timeAttackRemaining = null;
    _reviveOfferTimer?.cancel();
    _gameRecorder.stopRecording();
    // Don't lose level-up coins if the run is abandoned before game over.
    unawaited(_flushPendingLevelUpCoins());

    emit(
      state.copyWith(
        status: GamePlayStatus.ready,
        clearPreviousGameState: true,
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
    unawaited(_audioService.stopGameplayMusic());

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

    // If this game unlocked anything rare or better, treat it as a positive
    // moment worth asking for an app-store review. The service runs all
    // eligibility gates (cap, install grace period, lifetime games) and
    // self-throttles, so it's safe to fire on every qualifying unlock.
    final unlockedSomethingMeaningful =
        _achievementService.lastGameUnlocks.any(
      (a) => a.rarity.index >= AchievementRarity.rare.index,
    );
    if (unlockedSomethingMeaningful) {
      unawaited(
        _reviewService.maybeRequestReview(ReviewTrigger.achievementUnlocked),
      );
    }

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

    // Tournament runs: submit the final score. Fire-and-forget — the
    // game-over ribbon renders live from state.tournamentScoreSubmission,
    // so it never claims "submitted" unless the server actually accepted.
    if (state.tournamentId != null) {
      unawaited(_submitTournamentScore(
        tournamentId: state.tournamentId!,
        score: gameState.score,
        durationSeconds: gameDuration,
        foodsEaten: totalFoodEaten,
      ));
    }

    // Stop recording
    _gameRecorder.stopRecording();
  }

  /// Submit a tournament score and reflect the outcome in state.
  /// TournamentService.submitScore is a live call with a client-side
  /// idempotency key; it returns false on any failure (offline, 4xx/5xx).
  Future<void> _submitTournamentScore({
    required String tournamentId,
    required int score,
    required int durationSeconds,
    required int foodsEaten,
  }) async {
    emit(state.copyWith(
      tournamentScoreSubmission: TournamentScoreSubmission.submitting,
    ));
    final ok = await _tournamentService.submitScore(tournamentId, score, {
      'gameDurationSeconds': durationSeconds,
      'foodsEaten': foodsEaten,
    });
    if (isClosed) return;
    // A new run may have started while the call was in flight — only
    // stamp the outcome if we're still on the same tournament.
    if (state.tournamentId != tournamentId) return;
    emit(state.copyWith(
      tournamentScoreSubmission: ok
          ? TournamentScoreSubmission.submitted
          : TournamentScoreSubmission.failed,
    ));
  }

  /// Runs all post-game syncs in the background (non-blocking). The high
  /// score is settled here (it touches settings + audio + review prompts —
  /// single-player chrome, not economy); everything else is the shared
  /// [GameEndPipeline].
  Future<void> _postGameSync({
    required model.GameState gameState,
    required bool isNewHighScore,
    required int highScore,
  }) async {
    try {
      if (isNewHighScore) {
        await _storageService.saveHighScore(highScore);
        _settingsCubit.updateHighScore(highScore);
        // Single service — the legacy playSound('high_score') isn't in
        // AudioService's preload list, so it degraded to a system click
        // on top of this fanfare.
        _audioService.playSound('high_score', volume: 1.0);

        // Strongest positive signal we have — ask the platform to consider
        // a review prompt. Service self-throttles to once per 60 days and
        // gates on lifetime games + install age.
        unawaited(
          _reviewService.maybeRequestReview(ReviewTrigger.newHighScore),
        );
      }

      // _trackGameEndLocal already packaged the run; fall back to a fresh
      // build only if the call order ever changes.
      final summary = _lastRunSummary ??
          _buildRunSummary(
            gameState,
            _gameStartTime != null
                ? DateTime.now().difference(_gameStartTime!).inSeconds
                : 0,
          );

      await _endPipeline.runPostGame(
        summary,
        pendingLevelUpCoinLevels: _pendingLevelUpCoinLevels,
        awardedMilestones: _bpMilestonesThisGame,
        onCoinsAwarded: (granted) {
          _currentGameCoinsEarned += granted;
          // Surface the running per-game total so the game-over screen can
          // render it. Emitted even when 0 (e.g., daily cap maxed out) so
          // the screen always reads a fresh value.
          if (!isClosed) {
            emit(state.copyWith(
              coinsEarnedThisGame: _currentGameCoinsEarned,
            ));
          }
        },
      );
    } catch (e) {
      debugPrint('🎮 [GameCubit] Post-game sync error: $e');
    }
  }

  /// Grant every buffered level-up coin award (used when a run is abandoned
  /// before game over — resetGame / backToMenu). Safe to call more than
  /// once; the buffer is drained up front.
  Future<void> _flushPendingLevelUpCoins() async {
    if (_pendingLevelUpCoinLevels.isEmpty) return;
    final levels = List<int>.from(_pendingLevelUpCoinLevels);
    _pendingLevelUpCoinLevels.clear();
    final granted = await _endPipeline.flushLevelUpCoins(levels);
    if (granted > 0) _currentGameCoinsEarned += granted;
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
    _powerUpTimer?.cancel();
    _timeAttackTimer?.cancel();
    _reviveOfferTimer?.cancel();
    _rejectedInputClearTimer?.cancel();
    _acceptedInputClearTimer?.cancel();
    return super.close();
  }
}
