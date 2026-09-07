import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/flame/rendering/game_board_painter.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';

/// The snake head is drawn with a three-stop radial gradient, so whatever a
/// skin's palette looks like, the head must be handed EXACTLY three colours.
///
/// The Golden skin has two. Fed straight in, Flutter threw "colors and
/// colorStops arguments must have equal length" on every frame of every run
/// for everyone who owned it — the top new crash of 6.4.2, 57 events from a
/// single player in a day. This pins the contract for every skin that
/// exists, so the next two-colour palette cannot do it again.
void main() {
  Color tint(Color c) => Color.lerp(c, Colors.white, 0.34) ?? c;

  for (final skin in SnakeSkinType.values) {
    test('${skin.name} (${skin.colors.length} colours) yields three stops', () {
      expect(headGradientFromSkin(skin.colors, tint: tint), hasLength(3));
    });
  }

  test('a two-colour palette bridges its colours with their midpoint', () {
    const a = Color(0xFFFFD700);
    const b = Color(0xFFB8860B);
    final head = headGradientFromSkin(const [a, b], tint: tint);
    expect(head[0], tint(a), reason: 'the leading stop is lifted');
    expect(head[1], Color.lerp(a, b, 0.5));
    expect(head[2], b);
  });

  test('a long palette uses its first three, leading stop lifted', () {
    final palette = List.generate(12, (i) => Color(0xFF000000 + i * 0x101010));
    final head = headGradientFromSkin(palette, tint: tint);
    expect(head, [tint(palette[0]), palette[1], palette[2]]);
  });

  test('the gradient itself accepts every skin', () {
    for (final skin in SnakeSkinType.values) {
      final gradient = RadialGradient(
        colors: headGradientFromSkin(skin.colors, tint: tint),
        stops: const [0.0, 0.6, 1.0],
      );
      expect(
        () => gradient.createShader(const Rect.fromLTWH(0, 0, 20, 20)),
        returnsNormally,
        reason: skin.name,
      );
    }
  });
}
