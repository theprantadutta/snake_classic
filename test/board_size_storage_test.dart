import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/utils/constants.dart';

/// Mirrors StorageService._resolveBoardSize.
///
/// The production copy is a private method on a service that needs Drift, so
/// the resolution rules are duplicated here to be tested directly. These tests
/// exist because the stored value has now had THREE encodings, and a player's
/// saved board must survive every one of them — silently resolving someone's
/// board to the wrong arena changes the game under them.
BoardSize resolveBoardSize(int stored) {
  final sizes = GameConstants.availableBoardSizes;

  if (stored >= 1000) {
    final w = stored ~/ 1000;
    final h = stored % 1000;
    return sizes.firstWhere(
      (s) => s.width == w && s.height == h,
      orElse: () => BoardSize.classic,
    );
  }
  if (stored >= 15) {
    return sizes.firstWhere(
      (s) => s.width == stored && s.width == s.height,
      orElse: () => BoardSize.classic,
    );
  }
  return sizes[stored.clamp(0, sizes.length - 1)];
}

void main() {
  group('packed width+height (current format)', () {
    test('round-trips every available board', () {
      for (final size in GameConstants.availableBoardSizes) {
        final resolved = resolveBoardSize(size.storageKey);
        expect(
          resolved.width,
          size.width,
          reason: '${size.name} lost its width through storage',
        );
        expect(
          resolved.height,
          size.height,
          reason: '${size.name} lost its height through storage',
        );
      }
    });

    test('distinguishes boards that share a width', () {
      // The whole reason the format changed. 20x20 and any 20xN tall board
      // would be indistinguishable under width-only storage.
      const square = BoardSize(20, 20, 'Classic', '');
      const tall = BoardSize(20, 36, 'Hypothetical', '');
      expect(square.storageKey, isNot(tall.storageKey));
    });

    test('an unknown packed value falls back to Classic, never throws', () {
      final resolved = resolveBoardSize(99 * 1000 + 99);
      expect(resolved.width, BoardSize.classic.width);
      expect(resolved.height, BoardSize.classic.height);
    });
  });

  group('legacy width-only saves', () {
    test('still resolve to the SQUARE board of that width', () {
      // A save written before tall boards existed meant the square board.
      // It must keep meaning that even now a tall board could share the width.
      for (final size in GameConstants.availableBoardSizes.where(
        (s) => s.width == s.height,
      )) {
        final resolved = resolveBoardSize(size.width);
        expect(resolved.width, size.width);
        expect(
          resolved.height,
          size.width,
          reason: 'legacy save for ${size.width} must stay square',
        );
      }
    });

    test('never resolve to a tall board', () {
      for (final tall
          in GameConstants.availableBoardSizes.where((s) => s.isTall)) {
        final resolved = resolveBoardSize(tall.width);
        expect(
          resolved.isTall,
          isFalse,
          reason: 'a legacy width-only save must never become a tall board',
        );
      }
    });
  });

  group('legacy index saves', () {
    test('resolve within range', () {
      for (var i = 0; i < 7; i++) {
        expect(() => resolveBoardSize(i), returnsNormally);
      }
    });

    test('an out-of-range index clamps instead of throwing', () {
      expect(() => resolveBoardSize(14), returnsNormally);
      expect(() => resolveBoardSize(0), returnsNormally);
    });
  });

  group('the tall boards themselves', () {
    test('are taller than they are wide', () {
      final tall =
          GameConstants.availableBoardSizes.where((s) => s.isTall).toList();
      expect(tall, isNotEmpty);
      for (final s in tall) {
        expect(s.height, greaterThan(s.width));
      }
    });

    test('roughly match a phone aspect, so they actually fill the screen', () {
      for (final s
          in GameConstants.availableBoardSizes.where((s) => s.isTall)) {
        final aspect = s.height / s.width;
        // A modern phone is ~2.0-2.2 tall. Anything under 1.5 would not be
        // worth the score-comparability tradeoff.
        expect(aspect, greaterThan(1.5));
        expect(aspect, lessThan(2.4));
      }
    });

    test('the default board is still square', () {
      // Tall boards are opt-in. Making one the default would silently change
      // scoring for every existing player.
      expect(BoardSize.classic.isTall, isFalse);
      expect(GameConstants.availableBoardSizes[1].isTall, isFalse);
    });
  });
}
