import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/multiplayer/snake_glide.dart';
import 'package:snake_classic/models/position.dart';

void main() {
  group('glideBody', () {
    const from = [Position(5, 5), Position(4, 5), Position(3, 5)];
    const to = [Position(6, 5), Position(5, 5), Position(4, 5)];

    test('slides every segment a fraction of a cell, in grid units', () {
      expect(glideBody(from, to, 0), const [
        Offset(5.5, 5.5),
        Offset(4.5, 5.5),
        Offset(3.5, 5.5),
      ]);
      expect(glideBody(from, to, .5), const [
        Offset(6, 5.5),
        Offset(5, 5.5),
        Offset(4, 5.5),
      ]);
      expect(glideBody(from, to, 1), const [
        Offset(6.5, 5.5),
        Offset(5.5, 5.5),
        Offset(4.5, 5.5),
      ]);
    });

    test('a grown tail segment sits on its cell instead of sliding', () {
      const grown = [...to, Position(3, 5)];
      expect(glideBody(from, grown, .5).last, const Offset(3.5, 5.5));
    });

    test('a jump longer than a step is not slid across the board', () {
      const far = [Position(15, 5), Position(14, 5), Position(13, 5)];
      expect(glideBody(from, far, .5).first, const Offset(15.5, 5.5));
    });

    test('a held snake stays exactly where it is', () {
      expect(glideBody(from, from, .7), glideBody(from, from, 0));
    });
  });

  group('CorrectionBlend', () {
    const shown = [Offset(6, 5.5), Offset(5, 5.5)];
    const target = [Offset(5.5, 5), Offset(5, 5.5)];

    test('eases from what was on screen into the new path', () {
      final blend = CorrectionBlend()..begin(shown, target);
      expect(blend.active, isTrue);

      final first = blend.apply(target, 0);
      expect(
        first.first,
        shown.first,
        reason: 'no jump on the frame it starts',
      );

      final mid = blend.apply(target, .03);
      expect(
        (mid.first - target.first).distance,
        lessThan((shown.first - target.first).distance),
      );
      expect((mid.first - target.first).distance, greaterThan(0));

      final done = blend.apply(target, .2);
      expect(done, target);
      expect(blend.active, isFalse);
    });

    test('an invisible change is not eased', () {
      final blend = CorrectionBlend()
        ..begin(const [Offset(5.5, 5.5)], const [Offset(5.505, 5.5)]);
      expect(blend.active, isFalse);
    });

    test('a jump too large to be a misprediction is shown at once', () {
      final blend = CorrectionBlend()
        ..begin(const [Offset(1, 1)], const [Offset(12, 1)]);
      expect(blend.active, isFalse);
      expect(blend.apply(const [Offset(12, 1)], .016), const [Offset(12, 1)]);
    });

    test('a target longer than the shown body keeps its extra segments', () {
      final blend = CorrectionBlend()
        ..begin(shown, [...target, const Offset(4, 5.5)]);
      final out = blend.apply([...target, const Offset(4, 5.5)], .01);
      expect(out.length, 3);
      expect(out.last, const Offset(4, 5.5));
    });
  });
}
