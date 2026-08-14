import 'dart:math' as math;

// painting, not dart:ui — HSLColor lives here, and it re-exports Color.
import 'package:flutter/painting.dart';

/// Rules for painting text on a coloured fill.
///
/// The game has several bright surfaces — theme accents, and the amber/orange
/// gradients used for reward and premium actions — and every one of them used
/// to carry hardcoded white text. White on those fills measures under 2:1,
/// where large text needs 3:1 to be legible. It was tolerable while the
/// accents were mid-tone olives and it stopped being tolerable the moment the
/// palette was pulled up toward the logo.
///
/// Rather than hand-picking a text colour per button, measure the fill.

/// Ink used wherever a fill is too light to carry white.
///
/// Near-black with a green cast, so it reads as part of the palette rather
/// than as a hole punched in it.
const Color kDarkInk = Color(0xFF13210B);

/// Pulls a colour down the lightness axis, keeping its hue and saturation.
///
/// An accent is tuned to be legible as a thin thing — a border, an icon, a
/// label. Poured into a button-sized slab at full strength it glares, and the
/// brighter the theme, the worse it gets.
Color shadeFill(Color c, double factor) {
  final hsl = HSLColor.fromColor(c);
  return hsl.withLightness((hsl.lightness * factor).clamp(0.0, 1.0)).toColor();
}

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  return (math.max(la, lb) + 0.05) / (math.min(la, lb) + 0.05);
}

/// The more readable of white or [kDarkInk] on the given fill.
///
/// Pass both stops of a gradient and the midpoint is measured; pass one for a
/// flat fill.
///
/// Deliberately a measurement and not a luminance threshold. A threshold
/// guesses, and on yellow-green it guesses wrong: that fill's luminance reads
/// as "dark enough for white" while white only reaches 2.3:1 against it, and
/// dark ink reaches 7.6:1.
Color inkOn(Color fill, [Color? fillEnd]) {
  final mid = fillEnd == null ? fill : Color.lerp(fill, fillEnd, 0.5)!;
  return _contrast(mid, kDarkInk) >= _contrast(mid, const Color(0xFFFFFFFF))
      ? kDarkInk
      : const Color(0xFFFFFFFF);
}
