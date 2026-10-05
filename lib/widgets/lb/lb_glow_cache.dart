import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

/// Pre-rendered Living Board glows.
///
/// Every glow in the design is a [MaskFilter.blur] — a separate blur pass on
/// the GPU, recomputed every frame the screen draws. Profiled on a Realme
/// RMX3771 (120 Hz, 8.3 ms per frame) a static page already cost 5-7 ms of
/// raster, mostly glows, so a screen transition (two pages at once) missed
/// the budget on most frames. A title's or a button's glow never changes, so
/// it is rendered once into an image and drawn as that image afterwards,
/// which is close to free and looks the same: the glow is blurred, so the
/// image needs no more resolution than [_scale].
///
/// Keyed by everything that shapes the glow; least-recently-used entries are
/// evicted past [_capacity].
abstract final class LBGlowCache {
  static const int _capacity = 48;

  /// Glows are soft; this is ample even on 3x screens and keeps the images
  /// small.
  static const double _scale = 1.5;

  // Map literals keep insertion order, which is the LRU order here.
  static final _entries = <Object, _Glow>{};

  /// Draws [path] filled with [color] and blurred by [sigma] (normal style),
  /// from cache when [key] has been drawn before.
  static void drawPathGlow(
    Canvas canvas, {
    required Object key,
    required Path path,
    required Color color,
    required double sigma,
  }) {
    final glow = _entries.remove(key) ?? _render(path, color, sigma, BlurStyle.normal);
    _store(key, glow);
    glow.paint(canvas);
  }

  /// Draws [rrect]'s glow with [style] (e.g. [BlurStyle.outer]).
  static void drawRRectGlow(
    Canvas canvas, {
    required RRect rrect,
    required Color color,
    required double sigma,
    BlurStyle style = BlurStyle.normal,
  }) {
    // Position-independent: cache the glow of the rrect at the origin.
    final local = rrect.shift(-rrect.outerRect.topLeft);
    final key = (local, color, sigma, style);
    final glow = _entries.remove(key) ?? _render(Path()..addRRect(local), color, sigma, style);
    _store(key, glow);
    canvas.save();
    canvas.translate(rrect.left, rrect.top);
    glow.paint(canvas);
    canvas.restore();
  }

  static void _store(Object key, _Glow glow) {
    _entries[key] = glow;
    while (_entries.length > _capacity) {
      final oldest = _entries.keys.first;
      _entries.remove(oldest)!.image.dispose();
    }
  }

  static _Glow _render(Path path, Color color, double sigma, BlurStyle style) {
    // A gaussian with this sigma is visually gone by 3 sigma.
    final bounds = path.getBounds().inflate(sigma * 3);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(_scale)
      ..translate(-bounds.left, -bounds.top);
    canvas.drawPath(
      path,
      Paint()
        ..color = color
        ..maskFilter = MaskFilter.blur(style, sigma),
    );
    final picture = recorder.endRecording();
    final image = picture.toImageSync(
      (bounds.width * _scale).ceil().clamp(1, 4096),
      (bounds.height * _scale).ceil().clamp(1, 4096),
    );
    picture.dispose();
    return _Glow(image, bounds);
  }
}

class _Glow {
  _Glow(this.image, this.bounds);

  final ui.Image image;
  final Rect bounds;

  void paint(Canvas canvas) => canvas.drawImageRect(
        image,
        Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
        bounds,
        Paint()..filterQuality = FilterQuality.low,
      );
}
