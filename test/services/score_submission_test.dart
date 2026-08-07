import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/session/game_run_summary.dart';
import 'package:snake_classic/services/sync/score_submission.dart';
import 'package:snake_classic/utils/constants.dart';

/// Guards the score-submission payload.
///
/// This path exists because the backend `scores` table went unwritten for
/// months — the client simply stopped calling the endpoint — which left the
/// daily, weekly and friends leaderboards empty for every player. The way
/// that failure would come back is silently: the batch endpoint drops
/// invalid items individually and still returns 200 for the batch, so a
/// malformed payload loses scores with nothing logged anywhere.
///
/// So these tests pin the two things that would fail quietly: the server's
/// plausibility ceilings, and the mode name the server has to parse.
GameRunSummary run({
  int score = 500,
  int durationSeconds = 60,
  int foods = 20,
  GameMode mode = GameMode.classic,
  Difficulty difficulty = Difficulty.normal,
}) {
  return GameRunSummary(
    score: score,
    level: 3,
    maxCombo: 2,
    snakeLength: 12,
    gameMode: mode.name,
    gameModeWire: mode.wireName,
    difficulty: difficulty.name,
    isTournament: false,
    durationSeconds: durationSeconds,
    foodTypes: {'normal': foods},
    foodPoints: score,
    foodTypesEaten: const {'normal'},
    powerUpsCollected: 0,
    powerUpTypes: const {},
    powerUpTimeSeconds: 0,
    hitWall: true,
    hitSelf: false,
    wallHits: 1,
    selfHits: 0,
    consecutiveGamesWithoutWallHits: 0,
    countsForHighScore: difficulty.postsToLeaderboard,
  );
}

Map<String, dynamic>? build(GameRunSummary s) =>
    ScoreSubmission.build(s, idempotencyKey: 'key-1', playedAt: DateTime.utc(2026, 8, 7, 10));

void main() {
  group('the mode name the server has to parse', () {
    // The bug this guards: GameMode.name is overridden to a DISPLAY label
    // ('Zen Mode', 'Multi-Food', 'Power-Up Madness'). The server does
    // Enum.TryParse(value, true, out var mode) with a `GameMode.Classic`
    // fallback, so sending a label would have recorded every non-classic
    // run as Classic, with no error on either side.
    test('never contains a character the backend enum cannot hold', () {
      for (final mode in GameMode.values) {
        expect(
          RegExp(r'^[A-Za-z]+$').hasMatch(mode.wireName),
          isTrue,
          reason: '${mode.wireName} is not a bare identifier',
        );
      }
    });

    test('is distinct for every mode', () {
      final names = GameMode.values.map((m) => m.wireName).toSet();
      expect(names.length, GameMode.values.length);
    });

    test('matches the backend enum members exactly', () {
      // SnakeClassic.Domain.Enums.GameMode, in declaration order.
      expect(GameMode.values.map((m) => m.wireName).toList(), [
        'Classic',
        'Zen',
        'SpeedChallenge',
        'MultiFood',
        'Survival',
        'TimeAttack',
        'PowerUpMadness',
        'PerfectGame',
      ]);
    });

    test('the display label is NOT what gets sent', () {
      final payload = build(run(mode: GameMode.powerUpMadness))!;
      expect(payload['game_mode'], 'PowerUpMadness');
      expect(payload['game_mode'], isNot(GameMode.powerUpMadness.name));
    });
  });

  group('runs that must not be submitted', () {
    test('Easy difficulty — the picker promises scores stay off the boards', () {
      expect(build(run(difficulty: Difficulty.easy)), isNull);
    });

    test('a zero score', () {
      expect(build(run(score: 0, foods: 0)), isNull);
    });

    test('a score implausibly high for the food eaten', () {
      // Server rule: score <= foods * 300 + 100.
      expect(build(run(score: 3_101, foods: 10)), isNull);
    });

    test('an instant high score', () {
      // Server rule: score >= 100 requires >= 5s of play.
      expect(build(run(score: 500, durationSeconds: 4, foods: 20)), isNull);
    });

    test('an impossible food rate', () {
      // Server rule: foods <= max(1, duration) * 5.
      expect(build(run(score: 500, durationSeconds: 10, foods: 51)), isNull);
    });
  });

  group('boundaries — these must still be accepted', () {
    test('a score exactly at the plausibility ceiling', () {
      expect(build(run(score: 3_100, foods: 10, durationSeconds: 60)), isNotNull);
    });

    test('a sub-threshold score with no duration at all', () {
      // Below 100 the minimum-duration rule does not apply, and a real
      // run can legitimately end in under a second.
      expect(build(run(score: 99, foods: 1, durationSeconds: 0)), isNotNull);
    });

    test('the food rate exactly at the cap', () {
      expect(build(run(score: 500, durationSeconds: 10, foods: 50)), isNotNull);
    });

    test('one food in a zero-second run — the max(1, duration) clamp', () {
      expect(build(run(score: 10, foods: 1, durationSeconds: 0)), isNotNull);
    });
  });

  group('the payload itself', () {
    test('carries every key the server binds, in snake_case', () {
      final payload = build(run())!;
      expect(payload.keys.toSet(), {
        'score',
        'game_duration_seconds',
        'foods_eaten',
        'game_mode',
        'difficulty',
        'idempotency_key',
        'played_at',
      });
    });

    test('foods_eaten is the summed food map, not a count of types', () {
      final summary = run(foods: 37);
      expect(build(summary)!['foods_eaten'], 37);
    });

    test('the idempotency key is passed through unchanged', () {
      // The SyncEngine retries; the server de-duplicates on this value.
      // If it were regenerated per attempt, one game would insert twice
      // and inflate users.total_games_played.
      expect(build(run())!['idempotency_key'], 'key-1');
    });

    test('played_at is sent as a UTC instant', () {
      final payload = ScoreSubmission.build(
        run(),
        idempotencyKey: 'k',
        // A local-time DateTime must still arrive as UTC.
        playedAt: DateTime(2026, 8, 7, 10),
      )!;
      expect(payload['played_at'], endsWith('Z'));
      expect(DateTime.parse(payload['played_at'] as String).isUtc, isTrue);
    });

    test('difficulty is the intrinsic enum name the server parses', () {
      // Difficulty overrides `label`, not `name` — so unlike GameMode this
      // one is safe to send directly. Pinned so an added `name` override
      // does not quietly break it.
      expect(build(run(difficulty: Difficulty.normal))!['difficulty'], 'normal');
      expect(build(run(difficulty: Difficulty.hard))!['difficulty'], 'hard');
    });
  });
}
