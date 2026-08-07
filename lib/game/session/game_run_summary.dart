/// Immutable summary of one finished single-player run — everything the
/// post-game pipeline needs, captured at game-over time.
///
/// GameCubit owns the per-run trackers while the game is live; when the run
/// ends it packages them into this object and hands it to
/// [GameEndPipeline]. Keeping the pipeline's input explicit (instead of
/// letting it reach into cubit fields) is what makes the game-end flow
/// testable and reusable.
class GameRunSummary {
  const GameRunSummary({
    required this.score,
    required this.level,
    required this.maxCombo,
    required this.snakeLength,
    required this.gameMode,
    required this.gameModeWire,
    required this.difficulty,
    required this.isTournament,
    required this.durationSeconds,
    required this.foodTypes,
    required this.foodPoints,
    required this.foodTypesEaten,
    required this.powerUpsCollected,
    required this.powerUpTypes,
    required this.powerUpTimeSeconds,
    required this.hitWall,
    required this.hitSelf,
    required this.wallHits,
    required this.selfHits,
    required this.consecutiveGamesWithoutWallHits,
    this.countsForHighScore = true,
  });

  final int score;
  final int level;
  final int maxCombo;
  final int snakeLength;

  /// GameMode.name of the finished run — the DISPLAY label ('Zen Mode',
  /// 'Multi-Food'). This is a statistics key: `GameStatistics.gameModeCount`
  /// is keyed by it and so is every achievement that counts modes played,
  /// so its value is load-bearing for stored data and must not be changed.
  final String gameMode;

  /// The same mode as the BACKEND names it (`GameMode.wireName`), for score
  /// submission. Separate from [gameMode] because the display label is not
  /// parseable server-side and would be silently coerced to Classic.
  final String gameModeWire;

  /// `Difficulty.name` — the intrinsic enum identifier ('easy', 'normal',
  /// 'hard'), which the server parses case-insensitively. Difficulty
  /// overrides `label`, not `name`, so this one is safe to send as-is.
  final String difficulty;

  final bool isTournament;
  final int durationSeconds;

  /// Eaten-food counts keyed by FoodType.name.
  final Map<String, int> foodTypes;

  /// Total points earned from food (pre-completion-bonus).
  final int foodPoints;

  /// Distinct FoodType.names eaten this run (achievement input).
  final Set<String> foodTypesEaten;

  final int powerUpsCollected;

  /// Collected power-up counts keyed by PowerUpType.name.
  final Map<String, int> powerUpTypes;

  /// Seconds of power-up effect actually spent (unspent remainder on
  /// still-active power-ups is already subtracted).
  final int powerUpTimeSeconds;

  final bool hitWall;
  final bool hitSelf;

  /// Crash counters — can exceed 1 in Survival mode (multi-respawn).
  final int wallHits;
  final int selfHits;

  /// Lifetime streak including this run (achievement input).
  final int consecutiveGamesWithoutWallHits;

  /// False for Easy-difficulty runs. Everything else about the run still
  /// counts — coins, XP, achievements, games-played, food totals — but the
  /// score must not raise GameSettings.highScore, which is the value that
  /// syncs to the backend and renders the global / friends leaderboards.
  final bool countsForHighScore;

  int get foodEaten => foodTypes.values.fold(0, (sum, c) => sum + c);

  /// Original spec: no wall/self hits and lasted at least 30 seconds.
  /// Must stay in lockstep with GameStatistics.updateWithGameResult so the
  /// perfect-game counter and the coin bonus agree.
  bool get isPerfectGame => !hitWall && !hitSelf && durationSeconds >= 30;
}
