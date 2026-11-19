// Snake Classic: per-theme scenes (the "worth buying" layer of a theme).
//
// A GameTheme recolours the app through LBPalette. A ThemeScene adds what a
// palette can't: a painted backdrop behind every screen and the game board,
// a card base so text never sits on busy art, a primary-button gradient, a
// snake body style and a food accent.
//
// Performance contract (60 fps on a Galaxy A24):
//  - paintBackdrop is called ONCE per (theme, size, menu) and recorded into
//    a cached ui.Picture by ThemeScenes.paint; it may be as rich as it likes.
//  - paintMotion runs every frame on the game board only: keep it to a few
//    dozen primitives, no blur, no saveLayer, no allocations in loops.
//  - Generic imagery only: no real brands, logos, landmarks or characters.
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/utils/constants.dart';

/// How a theme dresses the snake on the board (the Living Board snake).
@immutable
class SnakeStyle {
  const SnakeStyle({
    this.bodyGradient,
    this.edge,
    this.shine = 0,
    this.tailFade = .4,
  });

  /// Body colours from neck to tail (2+ stops). Null = palette lime.
  final List<Color>? bodyGradient;

  /// Thin outline on each segment. Null = none.
  final Color? edge;

  /// Top highlight strength 0..1 (0 = none).
  final double shine;

  /// How much segments fade toward the tail (0 = solid, 1 = gone).
  final double tailFade;

  /// Body colour for segment position [t] (0 neck, 1 tail).
  Color bodyAt(double t, Color fallback) {
    final g = bodyGradient;
    if (g == null || g.isEmpty) return fallback;
    if (g.length == 1) return g.first;
    final x = (t.clamp(0.0, 1.0)) * (g.length - 1);
    final i = x.floor().clamp(0, g.length - 2);
    return Color.lerp(g[i], g[i + 1], x - i)!;
  }
}

abstract class ThemeScene {
  const ThemeScene();

  /// Paints the full backdrop filling [size]. [menu] is true behind
  /// screens (keep it calmer: text sits on it), false on the game board.
  /// Recorded once into a cached picture; never called per frame.
  void paintBackdrop(Canvas canvas, Size size, {required bool menu});

  /// Per-frame motion on the game board (cheap!). [seconds] is a monotonic
  /// clock. Only called when [hasMotion].
  void paintMotion(Canvas canvas, Size size, double seconds) {}
  bool get hasMotion => false;

  /// Base painted under translucent cards (outline/muted/gold blocks) so
  /// text never sits directly on the art. Usually the scene's darkest tone
  /// at ~70% alpha.
  Color get cardBase;

  /// Solid band colour for pinned screen headers.
  Color get headerBand;

  /// Primary (filled) button paint; null = the palette's flat lime.
  Gradient? get primaryGradient => null;

  /// The snake's dress on the board.
  SnakeStyle get snakeStyle => const SnakeStyle();

  /// A ring around food on the board so it reads on the art (null = none).
  Color? get foodRing => null;

  /// The in-game ghost score needs a dark backing on busy scenes.
  bool get busyBoard => true;
}

/// Registry + picture cache. Themes without a scene keep the flat board.
abstract class ThemeScenes {
  static final Map<GameTheme, ThemeScene> _scenes = {};

  /// Called once at startup by `registerThemeScenes()`.
  static void register(GameTheme theme, ThemeScene scene) =>
      _scenes[theme] = scene;

  static ThemeScene? of(GameTheme theme) => _scenes[theme];

  /// The theme a palette belongs to (palettes are cached per theme).
  static GameTheme? themeOfPalette(LBPalette p) {
    for (final t in GameTheme.values) {
      if (identical(LBPalette.of(t), p)) return t;
    }
    return null;
  }

  static ThemeScene? ofPalette(LBPalette p) {
    final t = themeOfPalette(p);
    return t == null ? null : _scenes[t];
  }

  static final Map<String, ui.Picture> _cache = {};

  /// Draws [theme]'s cached backdrop at [size].
  static void paint(Canvas canvas, Size size, GameTheme theme,
      {required bool menu}) {
    final scene = _scenes[theme];
    if (scene == null || size.isEmpty) return;
    final key =
        '${theme.index}:${size.width.round()}x${size.height.round()}:$menu';
    var pic = _cache[key];
    if (pic == null) {
      if (_cache.length > 12) _cache.clear();
      final rec = ui.PictureRecorder();
      scene.paintBackdrop(Canvas(rec), size, menu: menu);
      pic = rec.endRecording();
      _cache[key] = pic;
    }
    canvas.drawPicture(pic);
  }
}
