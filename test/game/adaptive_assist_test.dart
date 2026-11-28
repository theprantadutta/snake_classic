import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/game/assist/adaptive_assist.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/services/tuning/game_tuning.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

/// Adaptive assist: a gentler pace for players who keep dying early. The
/// guarantees pinned here are the narrow scope (Normal, free-play modes, no
/// tournaments, below the best-score cap), that it only ever slows the game,
/// and that a rampScale of 1.0 leaves the speed curve exactly as before.
void main() {
  const on = GameTuning(assistEnabled: true);

  group('AdaptiveAssist.levelFor', () {
    test('off when assist is disabled (the default)', () {
      expect(
        AdaptiveAssist.levelFor(
          tuning: GameTuning.defaults,
          recentRunSeconds: const [3, 4, 5, 6, 7],
          bestScore: 0,
        ),
        0,
      );
    });

    test('needs at least two runs', () {
      expect(
        AdaptiveAssist.levelFor(
            tuning: on, recentRunSeconds: const [3], bestScore: 0),
        0,
      );
    });

    test('scales with the share of early deaths in the window', () {
      int level(List<int> runs) => AdaptiveAssist.levelFor(
          tuning: on, recentRunSeconds: runs, bestScore: 0);
      expect(level(const [60, 60, 60, 60, 60]), 0); // 0%
      expect(level(const [5, 60, 60, 60, 60]), 0); // 20% -> floor(0.8)
      expect(level(const [5, 5, 60, 60, 60]), 1); // 40%
      expect(level(const [5, 5, 5, 60, 60]), 2); // 60%
      expect(level(const [5, 5, 5, 5, 60]), 3); // 80%
      expect(level(const [5, 5, 5, 5, 5]), 3); // 100%, capped at max
    });

    test('only looks at the last N runs', () {
      // Five early deaths long ago, five good runs since.
      expect(
        AdaptiveAssist.levelFor(
          tuning: on,
          recentRunSeconds: const [5, 5, 5, 5, 5, 90, 90, 90, 90, 90],
          bestScore: 0,
        ),
        0,
      );
    });

    test('stops at the best-score cap', () {
      expect(
        AdaptiveAssist.levelFor(
          tuning: on,
          recentRunSeconds: const [5, 5, 5, 5, 5],
          bestScore: on.assistBestScoreCap,
        ),
        0,
      );
    });

    test('respects a lower max level and max 0', () {
      expect(
        AdaptiveAssist.levelFor(
          tuning: const GameTuning(assistEnabled: true, assistMaxLevel: 1),
          recentRunSeconds: const [5, 5, 5, 5, 5],
          bestScore: 0,
        ),
        1,
      );
      expect(
        AdaptiveAssist.levelFor(
          tuning: const GameTuning(assistEnabled: true, assistMaxLevel: 0),
          recentRunSeconds: const [5, 5, 5, 5, 5],
          bestScore: 0,
        ),
        0,
      );
    });
  });

  group('AdaptiveAssist.paceFor', () {
    RunPace pace({
      GameTuning tuning = on,
      Difficulty difficulty = Difficulty.normal,
      GameMode mode = GameMode.classic,
      bool tournament = false,
      bool onboarding = false,
      List<int> runs = const [5, 5, 5, 5, 5],
      int best = 0,
    }) =>
        AdaptiveAssist.paceFor(
          tuning: tuning,
          difficulty: difficulty,
          mode: mode,
          isTournament: tournament,
          onboarding: onboarding,
          recentRunSeconds: runs,
          bestScore: best,
        );

    test('without assist, onboarding keeps its 380 ms start (control group '
        'plays exactly as before)', () {
      final p = pace(tuning: GameTuning.defaults, onboarding: true);
      expect(p.assistLevel, 0);
      expect(p.startingSpeedMs, 380);
      expect(p.rampScale, 1.0);

      final veteran = pace(tuning: GameTuning.defaults);
      expect(veteran.startingSpeedMs, isNull);
      expect(veteran.rampScale, 1.0);
    });

    test('level 3 on Normal: slower start and a softer ramp', () {
      final p = pace();
      expect(p.assistLevel, 3);
      expect(p.startingSpeedMs, 300 + 3 * 25);
      expect(p.rampScale, closeTo(1 - 3 * 0.15, 1e-9));
    });

    test('never faster than the onboarding pace', () {
      final p = pace(
        onboarding: true,
        runs: const [5, 5, 60, 60, 60], // level 1 -> 325 ms
      );
      expect(p.assistLevel, 1);
      expect(p.startingSpeedMs, 380);
    });

    test('never in tournaments or on Easy / Hard', () {
      expect(pace(tournament: true), same(RunPace.standard));
      expect(pace(difficulty: Difficulty.easy), same(RunPace.standard));
      expect(pace(difficulty: Difficulty.hard), same(RunPace.standard));
    });

    test('never in timed or precision modes', () {
      for (final mode in [
        GameMode.speedChallenge,
        GameMode.timeAttack,
        GameMode.perfectGame,
        GameMode.zen,
      ]) {
        expect(pace(mode: mode).assistLevel, 0, reason: mode.name);
      }
    });

    test('ramp scale never drops below 0.4', () {
      final p = pace(
        tuning: const GameTuning(assistEnabled: true, assistRampStep: 0.3),
      );
      expect(p.rampScale, 0.4);
    });
  });

  group('GameState.rampScale', () {
    GameState grown(int extra, {double ramp = 1.0, int level = 1}) {
      final body = List.generate(
        Snake.initialLength + extra,
        (i) => Position(i, 0),
      );
      return GameState.initial().copyWith(
        snake: Snake(body: body, currentDirection: Direction.left),
        level: level,
        rampScale: ramp,
      );
    }

    test('1.0 leaves the speed curve exactly as before', () {
      // Pre-tuning formula, written out.
      int legacy(int extra, int level) {
        const base = 300;
        var speed = (base - (level - 1) * 10).clamp(50, base);
        final f = (1.0 - extra * 0.008).clamp(0.60, 1.0);
        return (speed * f).round().clamp(50, base);
      }

      for (final extra in [0, 5, 10, 30, 50, 80]) {
        for (final level in [1, 2, 5, 9]) {
          expect(grown(extra, level: level).gameSpeed, legacy(extra, level),
              reason: 'extra=$extra level=$level');
        }
      }
    });

    test('a lower ramp scale keeps a grown snake slower', () {
      final normal = grown(30, level: 4).gameSpeed;
      final assisted = grown(30, level: 4, ramp: 0.55).gameSpeed;
      expect(assisted, greaterThan(normal));
    });

    test('ramp scale 0 holds the snake at its starting speed', () {
      expect(grown(40, level: 6, ramp: 0).gameSpeed, 300);
    });
  });

  group('RunHistoryStore', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('keeps the newest runs and survives a restart', () async {
      final prefs = await SharedPreferences.getInstance();
      final store = RunHistoryStore.createForTest();
      await store.initialize(prefs: prefs);
      for (var i = 1; i <= RunHistoryStore.capacity + 3; i++) {
        await store.record(i);
      }
      expect(store.recentRunSeconds, hasLength(RunHistoryStore.capacity));
      expect(store.recentRunSeconds.first, 4);
      expect(store.recentRunSeconds.last, RunHistoryStore.capacity + 3);

      final again = RunHistoryStore.createForTest();
      await again.initialize(prefs: prefs);
      expect(again.recentRunSeconds, store.recentRunSeconds);
    });

    test('ignores negative durations and corrupt entries', () async {
      SharedPreferences.setMockInitialValues({
        'assist_recent_runs_v1': ['12', 'oops', '30'],
      });
      final store = RunHistoryStore.createForTest();
      await store.initialize();
      expect(store.recentRunSeconds, [12, 30]);
      await store.record(-5);
      expect(store.recentRunSeconds, [12, 30]);
    });
  });
}
