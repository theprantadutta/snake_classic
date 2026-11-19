import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/design/lb_motion.dart';
import 'package:snake_classic/game/effects/effect_curves.dart';

void main() {
  group('rippleIntensity', () {
    test('is zero outside the ripple window', () {
      expect(EffectCurves.rippleIntensity(-.01, 3, 10), 0);
      expect(EffectCurves.rippleIntensity(1, 3, 10), 0);
      expect(EffectCurves.rippleIntensity(.5, -1, 10), 0);
      expect(EffectCurves.rippleIntensity(.5, 10, 10), 0);
      expect(EffectCurves.rippleIntensity(.5, 0, 0), 0);
    });

    test('stays within 0..1', () {
      for (var t = 0.0; t < 1; t += .05) {
        for (var i = 0; i < 30; i++) {
          final k = EffectCurves.rippleIntensity(t, i, 30);
          expect(k, inInclusiveRange(0, 1));
        }
      }
    });

    test('travels head to tail: each segment peaks later than the one before',
        () {
      const n = 20;
      double peakTime(int i) {
        var best = 0.0, bestT = 0.0;
        for (var t = 0.0; t < 1; t += .002) {
          final k = EffectCurves.rippleIntensity(t, i, n);
          if (k > best) {
            best = k;
            bestT = t;
          }
        }
        return bestT;
      }

      var last = -1.0;
      for (var i = 0; i < n; i++) {
        final p = peakTime(i);
        expect(p, greaterThan(last), reason: 'segment $i');
        last = p;
      }
    });

    test('every segment, head and tail included, reaches full brightness', () {
      for (final i in [0, 7, 14]) {
        var best = 0.0;
        for (var t = 0.0; t < 1; t += .001) {
          final k = EffectCurves.rippleIntensity(t, i, 15);
          if (k > best) best = k;
        }
        expect(best, greaterThan(.95), reason: 'segment $i');
      }
    });

    test('lights only a band, not the whole body', () {
      const n = 40;
      var lit = 0;
      for (var i = 0; i < n; i++) {
        if (EffectCurves.rippleIntensity(.5, i, n) > 0) lit++;
      }
      expect(lit, lessThan(n ~/ 2));
      expect(lit, greaterThan(0));
    });

    test('band half-width is clamped', () {
      expect(EffectCurves.rippleHalfWidth(2), .35);
      expect(EffectCurves.rippleHalfWidth(100), .12);
      expect(EffectCurves.rippleHalfWidth(20), closeTo(.15, 1e-9));
    });
  });

  group('combo scale', () {
    test('grows 3% per step past combo 2 and caps at +12%', () {
      expect(EffectCurves.comboBaseScale(0), 1);
      expect(EffectCurves.comboBaseScale(2), 1);
      expect(EffectCurves.comboBaseScale(3), closeTo(1.03, 1e-9));
      expect(EffectCurves.comboBaseScale(5), closeTo(1.09, 1e-9));
      expect(EffectCurves.comboBaseScale(6), closeTo(1.12, 1e-9));
      expect(EffectCurves.comboBaseScale(50), closeTo(1.12, 1e-9));
    });

    test('pop starts at from, overshoots, and lands on 1', () {
      expect(EffectCurves.comboPopScale(0, from: .6), closeTo(.6, 1e-9));
      expect(EffectCurves.comboPopScale(1, from: .6), closeTo(1, 1e-9));
      var peak = 0.0;
      for (var t = 0.0; t <= 1; t += .01) {
        final s = EffectCurves.comboPopScale(t);
        if (s > peak) peak = s;
      }
      expect(peak, greaterThan(1));
    });
  });

  group('bumpScale', () {
    test('is 1 outside the bump and settles back to 1', () {
      expect(EffectCurves.bumpScale(-.1), 1);
      expect(EffectCurves.bumpScale(1), 1);
      expect(EffectCurves.bumpScale(.999), closeTo(1, .01));
    });

    test('jumps by amp at the start', () {
      expect(EffectCurves.bumpScale(0, amp: .06), closeTo(1.06, 1e-9));
    });
  });

  group('eat pop', () {
    test('ring springs out to just under a cell', () {
      expect(EffectCurves.popRingRadius(0), closeTo(.35, 1e-9));
      expect(EffectCurves.popRingRadius(1), closeTo(.95, 1e-9));
    });

    test('sparks travel outward monotonically', () {
      var last = -1.0;
      for (var t = 0.0; t <= 1; t += .05) {
        final d = EffectCurves.sparkDistance(t);
        expect(d, greaterThanOrEqualTo(last));
        last = d;
      }
      expect(EffectCurves.sparkDistance(1), closeTo(1.25, 1e-9));
    });

    test('fadeOut goes 1 to 0', () {
      expect(EffectCurves.fadeOut(0), 1);
      expect(EffectCurves.fadeOut(1), 0);
      expect(EffectCurves.fadeOut(.5), closeTo(.25, 1e-9));
    });
  });

  group('level wall sweep', () {
    test('lights one cell per cellStagger, capped at count', () {
      final step = LBMotion.cellStagger.inMilliseconds;
      expect(EffectCurves.wallLitCells(-1, 20), 0);
      expect(EffectCurves.wallLitCells(0, 20), 1);
      expect(EffectCurves.wallLitCells(step, 20), 2);
      expect(EffectCurves.wallLitCells(step * 5 + 1, 20), 6);
      expect(EffectCurves.wallLitCells(step * 100, 20), 20);
    });

    test('sweep lasts count cell staggers', () {
      expect(EffectCurves.wallSweepDuration(20), LBMotion.cellStagger * 20);
      expect(EffectCurves.wallSweepDuration(0), LBMotion.cellStagger);
    });
  });
}
