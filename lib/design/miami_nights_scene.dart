import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// The Miami Nights backdrop: a dusk sky fading into a sunset, a striped
/// retro sun on the horizon, palm silhouettes and a neon floor grid.
///
/// Generic synthwave / retro-sunset imagery only. Never add another game's
/// name, logo, lettering, characters or map art to this scene.
///
/// Painted into a cached [ui.Picture] per size, so drawing it every frame
/// (the gameplay board) costs one drawPicture call.
class MiamiNightsScene {
  MiamiNightsScene._();

  static const Color night = Color(0xFF12052B);
  static const Color dusk = Color(0xFF3B0D5C);
  static const Color magenta = Color(0xFF9C1F74);
  static const Color coral = Color(0xFFFF5E62);
  static const Color amber = Color(0xFFFF9E44);
  static const Color sunTop = Color(0xFFFFD86B);
  static const Color sunBottom = Color(0xFFFF3C8E);
  static const Color floor = Color(0xFF240640);
  static const Color neonPink = Color(0xFFFF3CAC);
  static const Color neonCyan = Color(0xFF2DE2E6);
  static const Color silhouette = Color(0xFF0A0216);

  static final Map<String, ui.Picture> _cache = {};

  /// Paints the scene filling [size], then a black veil of [dim] (0..1) so
  /// whatever sits on top stays readable. [lines] scales the neon floor
  /// grid and [sun] the sun's opacity (menus keep both soft so neither
  /// fights the text sitting on top).
  static void paint(
    Canvas canvas,
    Size size, {
    double dim = 0,
    double lines = 1,
    double sun = 1,
    double horizonVeil = 0,
  }) {
    if (size.isEmpty) return;
    final key = '${size.width.round()}x${size.height.round()}'
        '@${(dim * 100).round()}/${(lines * 100).round()}/${(sun * 100).round()}/${(horizonVeil * 100).round()}';
    var picture = _cache[key];
    if (picture == null) {
      if (_cache.length > 8) _cache.clear();
      final recorder = ui.PictureRecorder();
      _paintScene(Canvas(recorder), size, dim, lines, sun, horizonVeil);
      picture = recorder.endRecording();
      _cache[key] = picture;
    }
    canvas.drawPicture(picture);
  }

  static void _paintScene(
    Canvas canvas,
    Size size,
    double dim,
    double lines,
    double sunAlpha,
    double horizonVeil,
  ) {
    final w = size.width;
    final h = size.height;
    final horizon = h * 0.64;

    // Sky.
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, horizon),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [night, dusk, magenta, coral, amber],
          stops: [0.0, 0.35, 0.65, 0.88, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, w, horizon)),
    );

    // A few stars high up, placed deterministically.
    final star = Paint()..color = Colors.white.withValues(alpha: .7);
    final rnd = math.Random(7);
    for (var i = 0; i < 26; i++) {
      final p = Offset(rnd.nextDouble() * w, rnd.nextDouble() * horizon * .42);
      canvas.drawCircle(p, (rnd.nextDouble() * 1.2 + .5) * (w / 400), star);
    }

    // Sun: upper half above the horizon, cut into bands that thin out
    // toward the bottom.
    final r = math.min(w, h) * 0.30;
    final c = Offset(w / 2, horizon);
    final sunRect = Rect.fromCircle(center: c, radius: r);
    final sun = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          sunTop.withValues(alpha: sunAlpha),
          sunBottom.withValues(alpha: sunAlpha),
        ],
      ).createShader(sunRect);
    // Glow behind the sun.
    canvas.drawCircle(
      c,
      r * 1.25,
      Paint()
        ..color = sunBottom.withValues(alpha: .35 * sunAlpha)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r * .25),
    );
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, horizon));
    canvas.clipPath(Path()..addOval(sunRect));
    final band = r / 7;
    var y = c.dy - r;
    for (var i = 0; y < horizon; i++) {
      final gap = i < 3 ? 0.0 : (i - 2) * band * 0.22;
      final bottom = math.min(y + band - gap, horizon);
      if (bottom > y) {
        canvas.drawRect(Rect.fromLTRB(c.dx - r, y, c.dx + r, bottom), sun);
      }
      y += band;
    }
    canvas.restore();

    // Floor with a neon perspective grid.
    final floorRect = Rect.fromLTRB(0, horizon, w, h);
    canvas.drawRect(
      floorRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [floor, night],
        ).createShader(floorRect),
    );
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w / 300);
    grid.color = neonPink.withValues(alpha: .9 * lines);
    canvas.drawLine(Offset(0, horizon), Offset(w, horizon), grid);
    grid.color = neonPink.withValues(alpha: .45 * lines);
    final depth = h - horizon;
    for (var k = 1; k <= 8; k++) {
      final t = k / 8;
      final gy = horizon + depth * t * t;
      canvas.drawLine(Offset(0, gy), Offset(w, gy), grid);
    }
    grid.color = neonCyan.withValues(alpha: .35 * lines);
    for (var k = -10; k <= 10; k++) {
      canvas.drawLine(
        Offset(w / 2 + k * w * .03, horizon),
        Offset(w / 2 + k * w * .22, h),
        grid,
      );
    }

    // Palms, left and right, standing on the horizon line.
    final s = math.min(w, h);
    _palm(canvas, Offset(w * 0.10, horizon + s * .02), s * .42, -0.18);
    _palm(canvas, Offset(w * 0.24, horizon + s * .01), s * .27, 0.10);
    _palm(canvas, Offset(w * 0.90, horizon + s * .02), s * .46, 0.20);
    _palm(canvas, Offset(w * 0.78, horizon + s * .01), s * .24, -0.08);

    if (dim > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.black.withValues(alpha: dim.clamp(0.0, 1.0)),
      );
    }
    // Extra shade over the bright sunset band just above the horizon, the
    // one place light text and captions lose contrast.
    if (horizonVeil > 0) {
      final band = Rect.fromLTRB(0, horizon - h * .22, w, horizon + h * .06);
      final veil = Colors.black.withValues(alpha: horizonVeil.clamp(0.0, 1.0));
      canvas.drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [veil.withValues(alpha: 0), veil, veil.withValues(alpha: 0)],
            stops: const [0, .78, 1],
          ).createShader(band),
      );
    }
  }

  /// A palm silhouette rooted at [base], [height] tall, trunk leaning by
  /// [lean] (fraction of height, + = right).
  static void _palm(Canvas canvas, Offset base, double height, double lean) {
    final paint = Paint()
      ..color = silhouette
      ..isAntiAlias = true;
    final top = base + Offset(lean * height, -height);
    final ctrl = base + Offset(lean * height * 0.2, -height * 0.55);
    final tw = height * 0.045;

    // Trunk: a tapered curved band.
    final trunk = Path()
      ..moveTo(base.dx - tw, base.dy)
      ..quadraticBezierTo(ctrl.dx - tw * .8, ctrl.dy, top.dx - tw * .45, top.dy)
      ..lineTo(top.dx + tw * .45, top.dy)
      ..quadraticBezierTo(ctrl.dx + tw * .8, ctrl.dy, base.dx + tw, base.dy)
      ..close();
    canvas.drawPath(trunk, paint);

    // Fronds: drooping leaves fanned around the crown.
    const angles = [-160.0, -130.0, -100.0, -70.0, -40.0, -15.0, -195.0];
    for (final deg in angles) {
      final a = deg * math.pi / 180;
      final len = height * 0.42;
      final dir = Offset(math.cos(a), math.sin(a));
      final tip = top + dir * len + Offset(0, len * 0.38); // droop
      final mid = top + dir * (len * 0.55) - Offset(0, len * 0.12);
      final normal = Offset(-dir.dy, dir.dx) * (len * 0.10);
      final leaf = Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(mid.dx + normal.dx, mid.dy + normal.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(mid.dx - normal.dx, mid.dy - normal.dy, top.dx, top.dy)
        ..close();
      canvas.drawPath(leaf, paint);
    }
    canvas.drawCircle(top, tw * 1.4, paint);
  }
}
