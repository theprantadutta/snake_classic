import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/multiplayer/tick_clock.dart';

/// The render clock on its own: frame deltas and arrivals in, a position on
/// the tick axis out.
void main() {
  const frame = 1 / 60;
  const eps = 1e-9;

  /// Runs [seconds] of frames with no limit in the way.
  void run(TickClock clock, double seconds, {double limit = 1e9}) {
    for (var t = 0.0; t < seconds - 1e-9; t += frame) {
      clock.advance(frame, limit: limit);
    }
  }

  test('runs at the tick rate on its own, with no arrivals', () {
    final clock = TickClock()..onArrival(10, tickMs: 300);
    expect(clock.position, 10);
    run(clock, .3);
    expect(clock.position, closeTo(11, 1e-6));
    run(clock, 3);
    expect(clock.position, closeTo(21, 1e-6));
  });

  test('does nothing before its first arrival', () {
    final clock = TickClock();
    run(clock, 1);
    expect(clock.started, isFalse);
    expect(clock.position, 0);
  });

  test('one late arrival barely moves it', () {
    final clock = TickClock()..onArrival(10, tickMs: 300);
    run(clock, .3);
    // Tick 11 lands 120ms late: the clock reads 11.4 when it should read 11.
    run(clock, .12);
    clock.onArrival(11, tickMs: 300);
    final before = clock.position;
    run(clock, .3);
    final moved = clock.position - before;
    expect(moved, lessThan(1.0), reason: 'eases off a little');
    expect(moved, greaterThan(.95), reason: 'but only a little');
  });

  test('phase-locks onto a steady offset without ever changing speed by '
      'more than the bound', () {
    // Every snapshot lands 90ms after the clock reads its tick.
    final clock = TickClock()..onArrival(0, tickMs: 300);
    var maxRate = 0.0, minRate = 9.0;
    for (var tick = 1; tick <= 40; tick++) {
      for (var i = 0; i < 18; i++) {
        final before = clock.position;
        clock.advance(frame, limit: 1e9);
        final rate = (clock.position - before) / (frame * 1000 / 300);
        if (tick > 1) {
          maxRate = rate > maxRate ? rate : maxRate;
          minRate = rate < minRate ? rate : minRate;
        }
      }
      // 18 frames is exactly one 300ms tick; the arrival is 90ms on.
      clock.onArrival(tick, tickMs: 300, lag: -.3);
    }
    // Lag −0.3: it should read tick + 0.3 at each arrival.
    expect(clock.position, closeTo(40.3, .03));
    expect(maxRate, lessThanOrEqualTo(1 + clock.maxRateAdjust + eps));
    expect(minRate, greaterThanOrEqualTo(1 - clock.maxRateAdjust - eps));
  });

  test('follows a change of tick length', () {
    final clock = TickClock()..onArrival(0, tickMs: 300);
    run(clock, .3);
    clock.onArrival(1, tickMs: 200);
    run(clock, .2);
    expect(clock.tickMs, 200);
    expect(clock.position, closeTo(2, .02));
  });

  test('jumps outright beyond the resync threshold, and when told to', () {
    final clock = TickClock()..onArrival(10, tickMs: 300);
    expect(clock.onArrival(12, tickMs: 300), isTrue);
    expect(clock.position, 12);
    expect(clock.resyncs, 1);

    expect(clock.onArrival(13, tickMs: 300, resync: true), isTrue);
    expect(clock.position, 13);
    expect(clock.resyncs, 2);

    run(clock, .1);
    expect(clock.onArrival(14, tickMs: 300), isFalse);
  });

  test('slows into its limit instead of hitting it, and does reach it', () {
    final clock = TickClock(softZone: .3)..onArrival(0, tickMs: 300);
    final positions = <double>[];
    for (var i = 0; i < 60; i++) {
      clock.advance(frame, limit: 1.35);
      positions.add(clock.position);
    }
    expect(positions.last, closeTo(1.35, eps), reason: 'reaches the limit');
    for (var i = 1; i < positions.length; i++) {
      expect(positions[i], greaterThanOrEqualTo(positions[i - 1]));
      expect(positions[i], lessThanOrEqualTo(1.35 + eps));
    }
    // Inside the soft zone it is still moving at a quarter speed or more
    // until the very last step onto the limit.
    final nominal = frame * 1000 / 300;
    for (var i = 1; i < positions.length; i++) {
      final step = positions[i] - positions[i - 1];
      if (positions[i] < 1.35 - eps) {
        expect(step, greaterThanOrEqualTo(nominal * clock.minSoftRate - eps));
      }
    }
  });

  test('time held at the limit is owed, and made up after', () {
    final clock = TickClock()..onArrival(0, tickMs: 300);
    run(clock, .6, limit: 1); // held at 1 for ~0.3s
    expect(clock.position, closeTo(1, eps));
    expect(clock.offset, greaterThan(.9));
    clock.onArrival(2, tickMs: 300); // now known to be behind
    final before = clock.position;
    run(clock, .3);
    expect(clock.position - before, greaterThan(1.05), reason: 'catching up');
  });

  test('well behind, it catches up faster than the normal bound', () {
    final clock = TickClock()..onArrival(0, tickMs: 300);
    run(clock, .9, limit: .5);
    clock.onArrival(2, tickMs: 300); // 1.5 ticks behind: no jump yet
    expect(clock.resyncs, 0);
    final before = clock.position;
    clock.advance(frame, limit: 1e9);
    final rate = (clock.position - before) / (frame * 1000 / 300);
    expect(rate, greaterThan(1 + clock.maxRateAdjust));
    expect(
      rate,
      lessThanOrEqualTo(1 + clock.maxRateAdjust + clock.catchUpBoost + 1e-9),
    );
  });

  test('clampTo pulls it back and owes the difference', () {
    final clock = TickClock()..onArrival(0, tickMs: 300);
    run(clock, .3);
    clock.clampTo(.5);
    expect(clock.position, .5);
    expect(clock.offset, closeTo(.5, 1e-6));
    clock.clampTo(.9);
    expect(clock.position, .5, reason: 'never pushed forward');
  });

  test('measures jitter: calm arrivals settle low, rough ones high', () {
    double jitterFor(List<double> latenessMs) {
      final clock = TickClock()..onArrival(0, tickMs: 300);
      var now = 0.0;
      for (var tick = 1; tick <= latenessMs.length; tick++) {
        final arrive = tick * .3 + latenessMs[tick - 1] / 1000;
        while (now + frame <= arrive) {
          clock.advance(frame, limit: 1e9);
          now += frame;
        }
        clock.onArrival(tick, tickMs: 300);
      }
      return clock.jitter;
    }

    final calm = jitterFor(List.filled(60, 0));
    final rough = jitterFor([
      for (var i = 0; i < 60; i++) i.isEven ? 120 : -120,
    ]);
    expect(calm, lessThan(.06));
    expect(rough, greaterThan(.25));
  });
}
