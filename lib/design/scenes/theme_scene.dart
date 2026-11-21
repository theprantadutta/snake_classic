// Snake Classic: per-theme scenes (the "worth buying" layer of a theme).
//
// A GameTheme recolours the app through LBPalette. A ThemeScene adds what a
// palette can't: a painted backdrop behind every screen and the game board,
// a card base so text never sits on busy art, a primary-button gradient, a
// snake body style and a food accent.
//
// Performance contract (60 fps on a Galaxy A24):
//  - paintBackdrop is called ONCE per (theme, size, menu, pixel ratio) and
//    baked into a cached GPU image by ThemeScenes.paint; it may be as rich
//    as it likes (per-frame cost is one image blit).
//  - paintMotion runs every frame on the game board only: keep it to a few
//    dozen primitives, no blur, no saveLayer, no allocations in loops.
//  - Generic imagery only: no real brands, logos, landmarks or characters.
import 'dart:math' as math;
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

  // No food ring: the owner rejected rings around food (2026-11-19).

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

  static final Map<String, ui.Image> _cache = {};
  static final Paint _blit = Paint()..filterQuality = FilterQuality.low;

  /// The device pixel ratio of the main view (1 when there is none, e.g.
  /// in tests).
  static double get devicePixelRatio {
    final views = ui.PlatformDispatcher.instance.views;
    return views.isEmpty ? 1.0 : views.first.devicePixelRatio;
  }

  /// Draws [theme]'s backdrop at [size]. [pixelRatio] is device pixels per
  /// canvas unit, so the baked image is sharp on screen.
  ///
  /// The backdrop is baked ONCE into a GPU image (Picture.toImageSync) and
  /// blitted every frame. Replaying the recorded Picture instead re-ran
  /// every gradient and blur per frame: Space measured 38 ms of raster a
  /// frame on the A24 (26 fps), Crystal ~16 ms (2026-11-21). A blit costs
  /// the same however rich the art is.
  static void paint(Canvas canvas, Size size, GameTheme theme,
      {required bool menu, double pixelRatio = 1}) {
    final scene = _scenes[theme];
    if (scene == null || size.isEmpty) return;
    // Cap the texture: a full-screen phone backdrop is ~1080x2340.
    final longest = math.max(size.width, size.height);
    final ratio = math.min(pixelRatio, 2600 / longest).clamp(.5, 4.0);
    final rq = (ratio * 4).round() / 4; // fewer cache keys while resizing
    final key = '${theme.index}:${size.width.round()}x${size.height.round()}'
        ':$menu:$rq';
    var img = _cache[key];
    if (img == null) {
      if (_cache.length >= 6) {
        for (final old in _cache.values) {
          old.dispose();
        }
        _cache.clear();
      }
      final rec = ui.PictureRecorder();
      final c = Canvas(rec)..scale(rq);
      scene.paintBackdrop(c, size, menu: menu);
      final pic = rec.endRecording();
      img = pic.toImageSync(
          math.max(1, (size.width * rq).ceil()),
          math.max(1, (size.height * rq).ceil()));
      pic.dispose();
      _cache[key] = img;
    }
    canvas.drawImageRect(
      img,
      Rect.fromLTWH(0, 0, img.width.toDouble(), img.height.toDouble()),
      Rect.fromLTWH(0, 0, img.width / rq, img.height / rq),
      _blit,
    );
  }
}
