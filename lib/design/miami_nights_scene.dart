import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';

/// The Miami Nights backdrop: a layered synthwave sunset. Deep sky with
/// streak clouds and stars, a big banded sun with a halo, distant ridges, a
/// city skyline with lit windows, a glowing horizon, the sun's reflection
/// on the floor, a neon perspective grid, palms in two depths, scanlines
/// and a vignette.
///
/// Generic synthwave / retro-sunset imagery only. Never add another game's
/// name, logo, lettering, characters, landmarks or map art to this scene.
///
/// The static scene is cached as a [ui.Picture] per size and options, so
/// drawing it every frame costs one drawPicture. The only per-frame part is
/// [paintFloorMotion] (a dozen lines), used by the gameplay board.
class MiamiNightsScene {
  MiamiNightsScene._();

  // Sky, top to horizon.
  static const Color night = Color(0xFF0B0320);
  static const Color indigo = Color(0xFF1E0640);
  static const Color plum = Color(0xFF4A0E63);
  static const Color magenta = Color(0xFF8E1C78);
  static const Color rose = Color(0xFFE0306E);
  static const Color coral = Color(0xFFFF6B5A);
  static const Color amber = Color(0xFFFFB347);

  // Sun, top to bottom.
  static const Color sunWhite = Color(0xFFFFF1A8);
  static const Color sunTop = Color(0xFFFFC44D);
  static const Color sunMid = Color(0xFFFF7A59);
  static const Color sunBottom = Color(0xFFFF2E88);

  static const Color floor = Color(0xFF2A0846);
  static const Color neonPink = Color(0xFFFF3CAC);
  static const Color neonCyan = Color(0xFF2DE2E6);
  static const Color silhouette = Color(0xFF0A0216);
  static const Color cityInk = Color(0xFF160530);
  static const Color ridgeInk = Color(0xFF2B0B4A);

  /// Horizon height as a fraction of the scene height.
  static const double horizonAt = 0.64;

  static final Map<String, ui.Picture> _cache = {};

  /// Paints the scene filling [size], then a black veil of [dim] (0..1) so
  /// whatever sits on top stays readable. [lines] scales the neon floor
  /// grid and [sun] the sun's opacity (menus keep both soft so neither
  /// fights the text sitting on top). [horizonVeil] shades the bright band
  /// just above the horizon. With [animatedFloor] the horizontal floor
  /// lines are left out, for [paintFloorMotion] to draw moving ones.
  static void paint(
    Canvas canvas,
    Size size, {
    double dim = 0,
    double lines = 1,
    double sun = 1,
    double horizonVeil = 0,
    bool animatedFloor = false,
  }) {
    if (size.isEmpty) return;
    final key = '${size.width.round()}x${size.height.round()}'
        '@${(dim * 100).round()}/${(lines * 100).round()}/${(sun * 100).round()}'
        '/${(horizonVeil * 100).round()}/$animatedFloor';
    var picture = _cache[key];
    if (picture == null) {
      if (_cache.length > 8) _cache.clear();
      final recorder = ui.PictureRecorder();
      _paintScene(Canvas(recorder), size,
          dim: dim,
          lines: lines,
          sunAlpha: sun,
          horizonVeil: horizonVeil,
          animatedFloor: animatedFloor);
      picture = recorder.endRecording();
      _cache[key] = picture;
    }
    canvas.drawPicture(picture);
  }

  /// The floor's horizontal grid lines, scrolling toward the viewer.
  /// [seconds] is any monotonically increasing clock. Draw it after
  /// [paint] with `animatedFloor: true`. Cheap: ~12 lines per frame.
  static void paintFloorMotion(
    Canvas canvas,
    Size size,
    double seconds, {
    double lines = 1,
    double dim = 0,
  }) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final horizon = h * horizonAt;
    final depth = h - horizon;
    const n = 12;
    final phase = (seconds / 2.4) % 1.0; // one line spacing per 2.4 s
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w / 320);
    final fade = 1 - dim.clamp(0.0, 1.0);
    for (var k = 0; k < n; k++) {
      final t = (k + phase) / n; // 0 at horizon, 1 at the bottom edge
      final gy = horizon + depth * t * t;
      // Fainter near the horizon, brightest close to the viewer.
      paint.color = neonPink.withValues(alpha: (.15 + .55 * t) * lines * fade);
      canvas.drawLine(Offset(0, gy), Offset(w, gy), paint);
    }
  }

  static void _paintScene(
    Canvas canvas,
    Size size, {
    required double dim,
    required double lines,
    required double sunAlpha,
    required double horizonVeil,
    required bool animatedFloor,
  }) {
    final w = size.width;
    final h = size.height;
    final horizon = h * horizonAt;
    final s = math.min(w, h);
    final rnd = math.Random(7);

    // 1. Sky.
    final skyRect = Rect.fromLTWH(0, 0, w, horizon);
    canvas.drawRect(
      skyRect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [night, indigo, plum, magenta, rose, coral, amber],
          stops: [0.0, 0.22, 0.42, 0.6, 0.78, 0.9, 1.0],
        ).createShader(skyRect),
    );

    // 2. Stars, densest high up, plus a few four-point sparkles.
    final star = Paint();
    for (var i = 0; i < 70; i++) {
      final y = math.pow(rnd.nextDouble(), 1.6) * horizon * .55;
      final p = Offset(rnd.nextDouble() * w, y.toDouble());
      star.color = Colors.white.withValues(alpha: .35 + rnd.nextDouble() * .5);
      canvas.drawCircle(p, (rnd.nextDouble() * 1.1 + .35) * (s / 420), star);
    }
    final sparkle = Paint()..color = Colors.white.withValues(alpha: .9);
    for (var i = 0; i < 6; i++) {
      final p = Offset(rnd.nextDouble() * w, rnd.nextDouble() * horizon * .35);
      final r = s * (.008 + rnd.nextDouble() * .008);
      final path = Path()
        ..moveTo(p.dx, p.dy - r)
        ..quadraticBezierTo(p.dx, p.dy, p.dx + r, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy + r)
        ..quadraticBezierTo(p.dx, p.dy, p.dx - r, p.dy)
        ..quadraticBezierTo(p.dx, p.dy, p.dx, p.dy - r)
        ..close();
      canvas.drawPath(path, sparkle);
    }

    // 3. Streak clouds: thin horizontal bands lit from below.
    for (var i = 0; i < 7; i++) {
      final cy = horizon * (.38 + rnd.nextDouble() * .42);
      final cw = w * (.25 + rnd.nextDouble() * .4);
      final cx = rnd.nextDouble() * w;
      final ch = s * (.006 + rnd.nextDouble() * .012);
      final r = Rect.fromCenter(center: Offset(cx, cy), width: cw, height: ch);
      final tint = Color.lerp(neonPink, amber, cy / horizon)!;
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, Radius.circular(ch)),
        Paint()
          ..shader = LinearGradient(colors: [
            tint.withValues(alpha: 0),
            tint.withValues(alpha: .38),
            tint.withValues(alpha: 0),
          ]).createShader(r),
      );
    }

    // 4. Sun: halo, then the banded disc.
    final r = s * 0.33;
    final c = Offset(w / 2, horizon);
    canvas.drawCircle(
      c,
      r * 2.0,
      Paint()
        ..shader = RadialGradient(colors: [
          sunBottom.withValues(alpha: .42 * sunAlpha),
          sunMid.withValues(alpha: .16 * sunAlpha),
          sunBottom.withValues(alpha: 0),
        ], stops: const [0.3, 0.6, 1.0])
            .createShader(Rect.fromCircle(center: c, radius: r * 2.0)),
    );
    final sunRect = Rect.fromCircle(center: c, radius: r);
    final sunPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.center,
        colors: [
          sunWhite.withValues(alpha: sunAlpha),
          sunTop.withValues(alpha: sunAlpha),
          sunMid.withValues(alpha: sunAlpha),
          sunBottom.withValues(alpha: sunAlpha),
        ],
        stops: const [0.0, 0.3, 0.65, 1.0],
      ).createShader(sunRect);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, horizon));
    canvas.clipPath(Path()..addOval(sunRect));
    final band = r / 8;
    var y = c.dy - r;
    for (var i = 0; y < horizon; i++) {
      final gap = i < 3 ? 0.0 : (i - 2) * band * 0.2;
      final bottom = math.min(y + band - gap, horizon);
      if (bottom > y) {
        canvas.drawRect(Rect.fromLTRB(c.dx - r, y, c.dx + r, bottom), sunPaint);
      }
      y += band;
    }
    canvas.restore();

    // 5. Distant ridges with a pink rim.
    final ridge = Path()..moveTo(0, horizon);
    final ridgeTop = <Offset>[];
    var x = 0.0;
    while (x <= w) {
      final ry = horizon - s * (.03 + rnd.nextDouble() * .07);
      ridgeTop.add(Offset(x, ry));
      ridge.lineTo(x, ry);
      x += w * (.05 + rnd.nextDouble() * .07);
    }
    ridge
      ..lineTo(w, horizon)
      ..close();
    canvas.drawPath(ridge, Paint()..color = ridgeInk.withValues(alpha: .92));
    final rim = Path()..moveTo(ridgeTop.first.dx, ridgeTop.first.dy);
    for (final p in ridgeTop.skip(1)) {
      rim.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, s / 360)
        ..color = neonPink.withValues(alpha: .55),
    );

    // 6. City skyline with lit windows (generic boxes, no landmarks).
    final city = Paint()..color = cityInk;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, s / 420);
    final windowPaint = Paint();
    const windowTints = [neonCyan, neonPink, Color(0xFFFFD86B)];
    x = w * .3;
    while (x < w * .7) {
      final bw = w * (.018 + rnd.nextDouble() * .03);
      final bh = s * (.04 + rnd.nextDouble() * .13);
      final b = Rect.fromLTWH(x, horizon - bh, bw, bh);
      canvas.drawRect(b, city);
      if (rnd.nextDouble() < .35) {
        // Antenna on some towers.
        canvas.drawLine(Offset(b.center.dx, b.top),
            Offset(b.center.dx, b.top - bh * .18), edge..color = cityInk);
      }
      if (rnd.nextDouble() < .4) {
        canvas.drawLine(b.topLeft, b.topRight,
            edge..color = neonPink.withValues(alpha: .7));
      }
      final ww = math.max(1.0, bw * .14);
      for (var wy = b.top + ww * 2; wy < b.bottom - ww * 2; wy += ww * 2.6) {
        for (var wx = b.left + ww; wx < b.right - ww; wx += ww * 2.2) {
          if (rnd.nextDouble() < .28) {
            windowPaint.color = windowTints[rnd.nextInt(3)]
                .withValues(alpha: .55 + rnd.nextDouble() * .4);
            canvas.drawRect(Rect.fromLTWH(wx, wy, ww, ww), windowPaint);
          }
        }
      }
      x += bw + w * (.002 + rnd.nextDouble() * .006);
    }

    // 7. Floor.
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

    // 8. The sun's reflection: shimmer dashes under the horizon.
    final depth = h - horizon;
    for (var i = 0; i < 9; i++) {
      final t = i / 9;
      final ry = horizon + depth * (.02 + t * .32);
      final rw = r * (1.6 - t * 1.1) * (.7 + rnd.nextDouble() * .5);
      final rh = math.max(1.0, s * (.006 - t * .003));
      final rr = Rect.fromCenter(center: Offset(w / 2, ry), width: rw, height: rh);
      canvas.drawRect(
        rr,
        Paint()
          ..shader = LinearGradient(colors: [
            sunMid.withValues(alpha: 0),
            Color.lerp(sunTop, sunBottom, t)!.withValues(alpha: (.7 - t * .6) * sunAlpha),
            sunMid.withValues(alpha: 0),
          ]).createShader(rr),
      );
    }

    // 9. Neon grid: cyan verticals that fade toward the horizon, and pink
    // horizontals (static unless the board animates them).
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, w / 320);
    grid.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        neonCyan.withValues(alpha: .08 * lines),
        neonCyan.withValues(alpha: .5 * lines),
      ],
    ).createShader(floorRect);
    for (var k = -12; k <= 12; k++) {
      canvas.drawLine(
        Offset(w / 2 + k * w * .028, horizon),
        Offset(w / 2 + k * w * .2, h),
        grid,
      );
    }
    grid.shader = null;
    if (!animatedFloor) {
      for (var k = 1; k <= 10; k++) {
        final t = k / 10;
        final gy = horizon + depth * t * t;
        grid.color = neonPink.withValues(alpha: (.15 + .5 * t) * lines);
        canvas.drawLine(Offset(0, gy), Offset(w, gy), grid);
      }
    }

    // 10. Glowing horizon line.
    final glow = Rect.fromLTRB(0, horizon - s * .03, w, horizon + s * .03);
    canvas.drawRect(
      glow,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            neonPink.withValues(alpha: 0),
            neonPink.withValues(alpha: .45 * lines),
            neonPink.withValues(alpha: 0),
          ],
        ).createShader(glow),
    );
    canvas.drawLine(
      Offset(0, horizon),
      Offset(w, horizon),
      Paint()
        ..strokeWidth = math.max(1.0, s / 260)
        ..color = Color.lerp(neonPink, Colors.white, .45)!
            .withValues(alpha: .95 * lines),
    );

    // 11. Palms: a far pair (hazy) and a near pair (black, pink rim).
    _palm(canvas, Offset(w * 0.28, horizon + s * .005), s * .22, 0.08,
        color: const Color(0xFF3A0F5C), rim: null);
    _palm(canvas, Offset(w * 0.74, horizon + s * .005), s * .2, -0.06,
        color: const Color(0xFF3A0F5C), rim: null);
    _palm(canvas, Offset(w * 0.08, horizon + s * .03), s * .5, -0.2,
        color: silhouette, rim: neonPink);
    _palm(canvas, Offset(w * 0.19, horizon + s * .02), s * .3, 0.12,
        color: silhouette, rim: neonPink);
    _palm(canvas, Offset(w * 0.92, horizon + s * .03), s * .54, 0.22,
        color: silhouette, rim: neonPink, rimSide: -1);

    // 12. Scanlines and vignette.
    final scan = Paint()
      ..color = Colors.black.withValues(alpha: .07)
      ..strokeWidth = math.max(1.0, s / 500);
    final step = math.max(3.0, s / 160);
    for (var sy = 0.0; sy < h; sy += step) {
      canvas.drawLine(Offset(0, sy), Offset(w, sy), scan);
    }
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          radius: .85,
          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: .45)],
          stops: const [.62, 1],
        ).createShader(Offset.zero & size),
    );

    if (dim > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()..color = Colors.black.withValues(alpha: dim.clamp(0.0, 1.0)),
      );
    }
    // Extra shade over the bright band just above the horizon, the one
    // place light text and captions lose contrast.
    if (horizonVeil > 0) {
      final vb = Rect.fromLTRB(0, horizon - h * .22, w, horizon + h * .06);
      final veil = Colors.black.withValues(alpha: horizonVeil.clamp(0.0, 1.0));
      canvas.drawRect(
        vb,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [veil.withValues(alpha: 0), veil, veil.withValues(alpha: 0)],
            stops: const [0, .78, 1],
          ).createShader(vb),
      );
    }
  }

  /// A palm rooted at [base], [height] tall, trunk leaning by [lean]
  /// (fraction of height, + = right). [rim] adds a thin sunset-side edge.
  static void _palm(
    Canvas canvas,
    Offset base,
    double height,
    double lean, {
    required Color color,
    required Color? rim,
    double rimSide = 1,
  }) {
    final paint = Paint()
      ..color = color
      ..isAntiAlias = true;
    final top = base + Offset(lean * height, -height);
    final ctrl = base + Offset(lean * height * 0.15, -height * 0.55);
    final tw = height * 0.04;

    final trunk = Path()
      ..moveTo(base.dx - tw, base.dy)
      ..quadraticBezierTo(ctrl.dx - tw * .8, ctrl.dy, top.dx - tw * .4, top.dy)
      ..lineTo(top.dx + tw * .4, top.dy)
      ..quadraticBezierTo(ctrl.dx + tw * .8, ctrl.dy, base.dx + tw, base.dy)
      ..close();
    canvas.drawPath(trunk, paint);

    if (rim != null) {
      // Rim light on the trunk side facing the sun (the screen centre).
      final towardCentre = rimSide;
      final rimPath = Path()
        ..moveTo(base.dx + tw * towardCentre, base.dy)
        ..quadraticBezierTo(ctrl.dx + tw * .8 * towardCentre, ctrl.dy,
            top.dx + tw * .4 * towardCentre, top.dy);
      canvas.drawPath(
        rimPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, tw * .35)
          ..color = rim.withValues(alpha: .55),
      );
    }

    // Fronds: nine arching, drooping leaves.
    const angles = [-200.0, -172.0, -145.0, -118.0, -92.0, -66.0, -40.0, -14.0, 10.0];
    for (final deg in angles) {
      final a = deg * math.pi / 180;
      final len = height * (0.36 + 0.08 * math.cos(a * 2).abs());
      final dir = Offset(math.cos(a), math.sin(a));
      final tip = top + dir * len + Offset(0, len * 0.45);
      final mid = top + dir * (len * 0.55) - Offset(0, len * 0.16);
      final normal = Offset(-dir.dy, dir.dx) * (len * 0.085);
      final leaf = Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(mid.dx + normal.dx, mid.dy + normal.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(mid.dx - normal.dx * .4, mid.dy - normal.dy * .4,
            top.dx, top.dy)
        ..close();
      canvas.drawPath(leaf, paint);
    }
    canvas.drawCircle(top, tw * 1.6, paint);
  }
}
