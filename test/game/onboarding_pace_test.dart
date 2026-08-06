import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/utils/constants.dart';

/// Guards the first-run pace override (RETENTION_PLAN.md, T2.7).
///
/// The whole point of [GameState.startingSpeedMs] is that it slows a new
/// player's opening games WITHOUT reclassifying them as Easy runs — because
/// `Difficulty.easy.postsToLeaderboard` is false, and that flag feeds
/// `countsForHighScore`. If someone ever "simplifies" this by assigning
/// `difficulty: Difficulty.easy` instead, these tests fail loudly.
void main() {
  GameState stateWith({Difficulty? difficulty, int? startingSpeedMs}) {
    return GameState(
      snake: Snake.initial(),
      difficulty: difficulty ?? Difficulty.normal,
      startingSpeedMs: startingSpeedMs,
      status: GameStatus.playing,
    );
  }

  group('startingSpeedMs override', () {
    test('null override falls back to the difficulty base speed', () {
      expect(
        stateWith(difficulty: Difficulty.normal).gameSpeed,
        Difficulty.normal.baseSpeed,
      );
      expect(
        stateWith(difficulty: Difficulty.hard).gameSpeed,
        Difficulty.hard.baseSpeed,
      );
    });

    test('override replaces the base tick at level 1', () {
      final state = stateWith(
        difficulty: Difficulty.normal,
        startingSpeedMs: Difficulty.easy.baseSpeed,
      );
      expect(state.gameSpeed, Difficulty.easy.baseSpeed);
      expect(
        state.gameSpeed,
        greaterThan(Difficulty.normal.baseSpeed),
        reason: 'a higher ms/tick is a SLOWER snake — the gentler on-ramp',
      );
    });

    test('override does not change difficulty or leaderboard eligibility', () {
      final state = stateWith(
        difficulty: Difficulty.normal,
        startingSpeedMs: Difficulty.easy.baseSpeed,
      );

      // The regression this file exists to prevent: an onboarding-paced run is
      // still a Normal run, so it posts to the leaderboard and — critically —
      // still counts for the player's personal best.
      expect(state.difficulty, Difficulty.normal);
      expect(state.difficulty.postsToLeaderboard, isTrue);
    });

    test('the per-level ramp still applies on top of the override', () {
      final level1 = stateWith(
        startingSpeedMs: Difficulty.easy.baseSpeed,
      );
      final level5 = stateWith(
        startingSpeedMs: Difficulty.easy.baseSpeed,
      ).copyWith(level: 5);

      expect(
        level5.gameSpeed,
        lessThan(level1.gameSpeed),
        reason: 'overridden runs must still accelerate with level',
      );
      expect(
        level5.gameSpeed,
        Difficulty.easy.baseSpeed - 4 * GameMode.classic.speedIncreaseRate,
      );
    });

    test('copyWith carries the override forward', () {
      final state = stateWith(startingSpeedMs: 380).copyWith(score: 10);
      expect(state.startingSpeedMs, 380);
      expect(state.gameSpeed, 380);
    });
  });
}
