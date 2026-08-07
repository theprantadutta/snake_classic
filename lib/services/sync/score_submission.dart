import 'package:snake_classic/game/session/game_run_summary.dart';

/// Builds the `/scores/batch` payload for one finished run.
///
/// ## Why this exists at all
///
/// The `scores` table on the backend is the ONLY source for the daily,
/// weekly and friends leaderboards, for the mode/difficulty-filtered global
/// leaderboard, and for the admin console's score distribution and
/// games-played series. Nothing else can substitute for it: the statistics
/// sync stores one aggregate blob per user, which cannot produce a daily
/// ranking or a distribution.
///
/// The client stopped calling `POST /scores` at some point and nothing
/// replaced it, so every one of those surfaces has been empty in production
/// — the leaderboards silently, for players. This is the path that fills it
/// back in, routed through the normal offline-first pipeline (Drift outbox →
/// SyncEngine) rather than a direct API call, per the architecture rules.
///
/// ## Kept as a pure function
///
/// The server applies anti-cheat ceilings and REJECTS anything outside them
/// (`ScoreSubmitDtoValidator`). A payload that trips one of those is dropped
/// per-item with the rest of the batch still applying, so a bug here would
/// lose scores silently — exactly the failure mode this whole change is
/// fixing. Being a pure function of the summary means the ceilings can be
/// tested directly.
class ScoreSubmission {
  const ScoreSubmission._();

  // Mirrors of the server's ceilings in ScoreSubmitDtoValidator. These are
  // duplicated deliberately: the client should not ship a payload it knows
  // the server will reject, and a local check turns a silent server-side
  // drop into something we can reason about. If the server relaxes a
  // ceiling this copy only ever refuses MORE, never less, so the two
  // drifting apart cannot cause a bad score to be accepted.
  static const int _maxPointsPerFood = 300;
  static const int _scoreSlack = 100;
  static const int _maxFoodsPerSecond = 5;
  static const int _instantScoreThreshold = 100;
  static const int _minDurationForHighScore = 5;

  /// Returns the JSON body for one score, or null if the run must not be
  /// submitted at all.
  ///
  /// [idempotencyKey] must be stable for a given run — the server uses it
  /// to make retries safe, and the SyncEngine WILL retry (that is the point
  /// of the outbox). Generating a fresh key on retry would insert the same
  /// game twice and inflate `users.total_games_played`.
  static Map<String, dynamic>? build(
    GameRunSummary summary, {
    required String idempotencyKey,
    required DateTime playedAt,
  }) {
    // Easy runs are excluded by product rule, not by accident: the
    // difficulty picker tells the player "Scores stay off the leaderboards"
    // for Easy, and `Difficulty.postsToLeaderboard` is the existing
    // expression of that. Submitting them would put Easy runs on the daily
    // and weekly boards, which is a behaviour change nobody asked for.
    if (!summary.countsForHighScore) return null;

    final score = summary.score;
    final foods = summary.foodEaten;
    final duration = summary.durationSeconds;

    // A zero-score run carries no leaderboard signal. It would still count
    // toward total_games_played, but the batch handler treats every accepted
    // row the same, so admitting them only adds rows nothing reads.
    if (score <= 0) return null;

    // Below: the server's three ceilings, in the server's order. Any run
    // that trips one is a bug in our own tracking rather than a cheat —
    // dropping it locally keeps a malformed row out of the leaderboard and
    // out of the games count.
    if (score < 0 || foods < 0 || duration < 0) return null;
    if (score > (foods * _maxPointsPerFood) + _scoreSlack) return null;
    if (score >= _instantScoreThreshold && duration < _minDurationForHighScore) {
      return null;
    }
    if (foods > (duration < 1 ? 1 : duration) * _maxFoodsPerSecond) return null;

    return {
      'score': score,
      'game_duration_seconds': duration,
      'foods_eaten': foods,
      // `wireName`, NOT `name` — GameMode.name is a display label ('Zen
      // Mode', 'Multi-Food') that the server cannot parse and would
      // silently coerce to Classic.
      'game_mode': summary.gameModeWire,
      'difficulty': summary.difficulty,
      'idempotency_key': idempotencyKey,
      // UTC on the wire. The server stores `played_at` as
      // `timestamp with time zone` and stamps its own `created_at`; the
      // overview and leaderboards filter on created_at, so played_at is
      // only there to preserve the true time of an offline run.
      'played_at': playedAt.toUtc().toIso8601String(),
    };
  }
}
