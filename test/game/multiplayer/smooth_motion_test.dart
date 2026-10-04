import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/flame/multiplayer_flame_game.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';

import 'jitter_harness.dart';

/// The board under network jitter: snapshots from a steady server, delivered
/// early, late, in bursts and after gaps, played through the predictor and
/// the board at 60 fps. What has to hold is what the player sees: each snake
/// moves forward by about the same amount every frame — never backwards,
/// never jumping, never sitting still for long — and the local snake stays
/// within its bounds around the server.
void main() {
  const lead = MultiplayerFlameGame.maxLocalLead;
  const eps = 1e-6;

  // The first second and a half is the match starting: the rival's
  // playback deliberately holds on the first snapshot until it is a delay
  // behind, and the clocks are still settling.
  const warmUp = 1.5;

  MatchRun play(List<Delivery> plan, {double tail = .2}) {
    final run = MatchRun(plan)..start();
    run.runAll(tail: tail);
    return run;
  }

  void expectLocalBounds(MatchRun run, {double behind = 1.0}) {
    for (final s in run.samples) {
      final x = s.localX;
      if (x == null) continue;
      final ahead = x - s.newestHeadCentre;
      expect(
        ahead,
        lessThanOrEqualTo(lead + eps),
        reason:
            'never drawn more than $lead ticks past the server '
            '(t=${s.time.toStringAsFixed(3)})',
      );
      expect(
        ahead,
        greaterThanOrEqualTo(-behind - eps),
        reason:
            'never more than $behind ticks behind the newest snapshot '
            '(t=${s.time.toStringAsFixed(3)})',
      );
    }
  }

  group('your own snake', () {
    test(
      'steady snapshots: exactly the server speed, peaking a tick ahead',
      () {
        final run = play(
          deliveries(ticks: 60, tickMsAt: (_) => 300, jitterMs: 0),
        );
        final m = MotionStats(run.samples, (s) => s.localX);
        expect(m.minStep, greaterThan(0));
        expect(m.maxStepRatio, lessThan(1.02));
        expect(m.longestStall, 0);
        expectLocalBounds(run, behind: 0);
      },
    );

    test('arrivals ±150ms around a 300ms tick: never backwards, never '
        'stalls, never jumps', () {
      for (final seed in [1, 2, 3, 4, 5]) {
        final run = play(
          deliveries(
            ticks: 100,
            tickMsAt: (_) => 300,
            jitterMs: 150,
            seed: seed,
          ),
        );
        final m = MotionStats(run.samples, (s) => s.localX);
        expect(m.minStep, greaterThan(0), reason: 'seed $seed: $m');
        expect(m.maxStepRatio, lessThan(1.25), reason: 'seed $seed: $m');
        expect(m.longestStall, 0, reason: 'seed $seed: $m');
        expectLocalBounds(run);
        expect(run.predictor.mispredictions, 0);
      }
    });

    test('bursts and 500ms gaps: it slows for a gap but never freezes for a '
        'tick, and never runs backwards', () {
      for (final seed in [1, 2, 3]) {
        final run = play(
          deliveries(
            ticks: 100,
            tickMsAt: (_) => 300,
            jitterMs: 150,
            burstEvery: 9,
            gapEvery: 13,
            seed: seed,
          ),
        );
        final m = MotionStats(run.samples, (s) => s.localX);
        expect(m.minStep, greaterThanOrEqualTo(0), reason: 'seed $seed: $m');
        expect(m.maxStepRatio, lessThan(1.25), reason: 'seed $seed: $m');
        expect(m.longestStall, lessThan(.25), reason: 'seed $seed: $m');
        expectLocalBounds(run, behind: 1.5);
      }
    });

    test('a packet two ticks late: the snake eases to a stop at the '
        'lookahead and catches up after, without a jump', () {
      final normal = deliveries(ticks: 60, tickMsAt: (_) => 300, jitterMs: 50);
      // Tick 40 is held 600ms; everything behind it queues up and lands in
      // a burst right after it.
      final late = normal.firstWhere((d) => d.snapshot.tick == 40).at + .6;
      final plan = [
        for (final d in normal)
          d.snapshot.tick < 40
              ? d
              : Delivery(d.snapshot, d.at < late ? late : d.at),
      ];
      final run = play(plan);
      final m = MotionStats(run.samples, (s) => s.localX);
      expect(m.minStep, greaterThanOrEqualTo(0), reason: '$m');
      // Catching up runs faster for a while, but nothing like a jump.
      expect(m.maxStepRatio, lessThan(1.4), reason: '$m');
      // Some of the wait is unavoidable — the snake is never drawn past
      // the lookahead — but most of it is spent moving.
      expect(m.longestStall, lessThan(.4), reason: '$m');
      expectLocalBounds(run, behind: 2);
    });

    test('at the fastest tick (200ms) with Wi-Fi jitter it is just as '
        'smooth', () {
      final run = play(
        deliveries(ticks: 150, tickMsAt: (_) => 200, jitterMs: 100),
      );
      final m = MotionStats(run.samples, (s) => s.localX);
      expect(m.minStep, greaterThan(0), reason: '$m');
      expect(m.maxStepRatio, lessThan(1.25), reason: '$m');
      expect(m.longestStall, 0, reason: '$m');
      expectLocalBounds(run);
    });

    test('the speed ramp changes the tick mid-match without a hitch', () {
      int tickMs(int tick) => tick < 50 ? 300 : (tick < 90 ? 250 : 200);
      final run = play(deliveries(ticks: 140, tickMsAt: tickMs, jitterMs: 100));
      final m = MotionStats(run.samples, (s) => s.localX);
      expect(m.minStep, greaterThan(0), reason: '$m');
      expect(m.maxStepRatio, lessThan(1.25), reason: '$m');
      expect(m.longestStall, 0, reason: '$m');
      expectLocalBounds(run);

      // Over the last two seconds it moves at the new speed, 5 cells/s.
      final end = run.samples.where((s) => s.newestTick > 110).toList();
      final span = end.last.time - end.first.time;
      final cells = end.last.localX! - end.first.localX!;
      expect(cells / span, closeTo(5, .5));
    });

    test(
      'a reconnect that skipped ticks resyncs at once, then runs smooth',
      () {
        final full = deliveries(ticks: 91, tickMsAt: (_) => 300, jitterMs: 80);
        // Ticks 41..59 never reach the phone.
        final plan = [
          for (final d in full)
            if (d.snapshot.tick <= 40 || d.snapshot.tick >= 60) d,
        ];
        final run = play(plan);

        final after = run.samples.where((s) => s.newestTick >= 60).toList();
        // The very first frame after the jump is on the new stretch...
        expect(after.first.localX, greaterThanOrEqualTo(headXAt(60) + .5 - .5));
        expect(after.first.localTick, greaterThanOrEqualTo(60 - eps));
        // ...nothing was drawn in between...
        for (final s in run.samples) {
          final x = s.localX!;
          final inGap = x > headXAt(41) + .5 + lead && x < headXAt(60) - .5;
          expect(inGap, isFalse, reason: 'no slide across the gap at $x');
        }
        // ...and from there it is smooth again.
        final m = MotionStats(after, (s) => s.localX);
        expect(m.minStep, greaterThan(0), reason: '$m');
        expect(m.maxStepRatio, lessThan(1.25), reason: '$m');
        expect(m.longestStall, 0, reason: '$m');
        expectLocalBounds(MatchRun(const [])..samples.addAll(after));
      },
    );

    test('a new match restarts the clocks', () {
      final run = play(
        deliveries(ticks: 60, tickMsAt: (_) => 300, jitterMs: 50),
      );
      expect(run.game.localRenderTick, greaterThan(60));

      // Tick numbers restart (a rematch on the same board).
      run.predictor.reset();
      run.deliver(serverSnapshot(startTick, tickMs: 300));
      run.runFor(.1);
      expect(
        run.game.localRenderTick,
        inInclusiveRange(startTick, startTick + 1),
      );
      expect(run.game.remoteRenderTick, lessThanOrEqualTo(startTick + eps));
      expect(
        run.game.localCells!.first.dx,
        closeTo(headXAt(startTick) + .5, .5),
      );
    });

    test('your bite is shown when your snake reaches the food, not before', () {
      const eatTick = 40;
      final food = Position(headXAt(eatTick), myRow);
      MatchSnapshot build(int tick, int tickMs) => tick < eatTick
          ? serverSnapshot(tick, tickMs: tickMs, food: food)
          : serverSnapshot(tick, tickMs: tickMs, myLength: 5, myScore: 10);
      final plan = deliveries(
        ticks: 60,
        tickMsAt: (_) => 300,
        jitterMs: 100,
        build: build,
      );
      final arrival = plan.firstWhere((d) => d.snapshot.tick == eatTick).at;

      FrameSample? shown;
      var seen = 0;
      final run = MatchRun(
        plan,
        onFrame: (run, s) {
          if (run.localBites > seen) {
            seen = run.localBites;
            shown ??= s;
          }
          if (run.localBites == 0) {
            expect(run.game.displayedFood, food, reason: 'still uneaten');
          }
        },
      )..start();
      run.runAll(tail: .2);

      expect(run.localBites, 1, reason: 'exactly one chirp');
      expect(run.game.displayedFood, const Position(399, 399));
      expect(shown!.localTick, greaterThanOrEqualTo(eatTick - eps));
      expect(shown!.time, greaterThanOrEqualTo(arrival - eps));
      // The head is on the food's cell, or just past it if the snapshot
      // landed after the snake got there.
      expect(shown!.localX, greaterThanOrEqualTo(food.x + .5 - eps));
      expect(shown!.localX, lessThan(food.x + .5 + .6));
    });
  });

  group('the rival', () {
    test('arrivals ±150ms: played back on a steady clock — never backwards, '
        'never stalls, never jumps', () {
      for (final seed in [1, 2, 3, 4, 5]) {
        final run = play(
          deliveries(
            ticks: 100,
            tickMsAt: (_) => 300,
            jitterMs: 150,
            seed: seed,
          ),
        );
        final m = MotionStats(run.samples, (s) => s.rivalX, after: warmUp);
        expect(m.minStep, greaterThan(0), reason: 'seed $seed: $m');
        expect(m.maxStepRatio, lessThan(1.25), reason: 'seed $seed: $m');
        expect(m.longestStall, 0, reason: 'seed $seed: $m');
        for (final s in run.samples) {
          // Only ever drawn between snapshots that have both arrived.
          expect(s.remoteTick, lessThanOrEqualTo(s.newestTick + eps));
          expect(s.remoteDelay, inInclusiveRange(1.15, 2.0));
        }
      }
    });

    test('bursts and 500ms gaps barely show', () {
      for (final seed in [1, 2, 3]) {
        final run = play(
          deliveries(
            ticks: 100,
            tickMsAt: (_) => 300,
            jitterMs: 150,
            burstEvery: 9,
            gapEvery: 13,
            seed: seed,
          ),
        );
        final m = MotionStats(run.samples, (s) => s.rivalX, after: warmUp);
        expect(m.minStep, greaterThanOrEqualTo(0), reason: 'seed $seed: $m');
        expect(m.maxStepRatio, lessThan(1.25), reason: 'seed $seed: $m');
        expect(m.longestStall, lessThan(.2), reason: 'seed $seed: $m');
        for (final s in run.samples) {
          expect(s.remoteTick, lessThanOrEqualTo(s.newestTick + eps));
          // Behind by the delay plus at most the gap it is catching up on.
          expect(s.newestTick - s.remoteTick, lessThan(4));
        }
      }
    });

    test('the playout delay follows the measured jitter', () {
      double delayFor(double jitterMs) {
        final run = play(
          deliveries(ticks: 80, tickMsAt: (_) => 300, jitterMs: jitterMs),
        );
        return run.samples.last.remoteDelay;
      }

      final calm = delayFor(0);
      final wifi = delayFor(100);
      final rough = delayFor(150);
      expect(calm, closeTo(1.15, .05));
      expect(wifi, greaterThan(calm));
      expect(rough, greaterThan(wifi));
      expect(rough, lessThanOrEqualTo(2.0));
    });

    test("the rival's bite is shown when it reaches the food, not when the "
        'snapshot lands', () {
      const eatTick = 40;
      final eatenAt = Position(headXAt(eatTick), rivalRow);
      const respawn = Position(60, 60);
      MatchSnapshot build(int tick, int tickMs) => tick < eatTick
          ? serverSnapshot(tick, tickMs: tickMs, food: eatenAt)
          : serverSnapshot(
              tick,
              tickMs: tickMs,
              food: respawn,
              rivalLength: 5,
              rivalScore: 10,
            );
      final plan = deliveries(
        ticks: 60,
        tickMsAt: (_) => 300,
        jitterMs: 100,
        build: build,
      );
      final arrival = plan.firstWhere((d) => d.snapshot.tick == eatTick).at;

      FrameSample? shown;
      double? headWhenShown;
      final run = MatchRun(
        plan,
        onFrame: (run, s) {
          if (shown == null && run.game.displayedFood == respawn) {
            shown = s;
            headWhenShown = run.game.remotePoses[1]!.cells.first.dx;
          }
        },
      )..start();
      run.runAll(tail: .2);

      expect(run.localBites, 0, reason: "the rival's bite is not yours");
      expect(shown, isNotNull);
      expect(shown!.remoteTick, greaterThanOrEqualTo(eatTick - eps));
      expect(
        shown!.time - arrival,
        greaterThan(.25),
        reason: 'held until the playback gets there, a tick and more later',
      );
      // On the frame it is shown, the rival's head is on the food's cell.
      expect(headWhenShown, closeTo(eatenAt.x + .5, .1));
    });

    test("the rival's crash is shown when playback reaches it", () {
      const deathTick = 40;
      MatchSnapshot build(int tick, int tickMs) {
        if (tick < deathTick) return serverSnapshot(tick, tickMs: tickMs);
        final s = serverSnapshot(deathTick, tickMs: tickMs, rivalAlive: false);
        return MatchSnapshot(
          tick: tick,
          tickMs: tickMs,
          elapsedGameMs: tick * tickMs,
          food: s.food,
          players: [
            serverSnapshot(tick, tickMs: tickMs).players.first,
            s.players.last,
          ],
        );
      }

      final plan = deliveries(
        ticks: 50,
        tickMsAt: (_) => 300,
        jitterMs: 100,
        build: build,
      );
      final run = MatchRun(
        plan,
        onFrame: (run, s) {
          final pose = run.game.remotePoses[1]!;
          if (s.remoteTick < deathTick - eps) {
            expect(pose.alive, isTrue, reason: 'not yet at t=${s.time}');
          } else {
            expect(pose.alive, isFalse);
            expect(pose.cells.first.dx, closeTo(headXAt(deathTick) + .5, eps));
          }
          expect(
            pose.cells.first.dx,
            lessThanOrEqualTo(headXAt(deathTick) + .5 + eps),
          );
        },
      )..start();
      run.runAll(tail: 1);
      expect(run.game.remotePoses[1]!.alive, isFalse);
    });
  });

  test('the same arrivals always draw the same frames', () {
    List<double?> draw() {
      final run = play(
        deliveries(
          ticks: 40,
          tickMsAt: (_) => 300,
          jitterMs: 150,
          burstEvery: 7,
          gapEvery: 11,
        ),
      );
      return [
        for (final s in run.samples) ...[s.localX, s.rivalX],
      ];
    }

    expect(draw(), draw());
  });
}
