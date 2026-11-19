import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

/// Desert: dusk over a sea of dunes. A deep blue-to-amber sky with the
/// first stars and a thin crescent, a big low sun melting into heat haze,
/// far mesas in violet haze, four ranks of sharp-crested dunes rim-lit by
/// the sun with shadowed slip faces and wind ripples, saguaro-style cacti,
/// boulders, and a few birds heading home.
///
/// Generic desert imagery only (no palms or neon: that is Miami Nights).
/// Soft light is gradients, never blur.
class DesertThemeScene extends ThemeScene {
  const DesertThemeScene();

  static const Color _night = Color(0xFF0A1030);
  static const Color _indigo = Color(0xFF1D1B48);
  static const Color _violet = Color(0xFF452856);
  static const Color _rose = Color(0xFF94404F);
  static const Color _ember = Color(0xFFD7693A);
  static const Color _gold = Color(0xFFF6B65E);
  static const Color _sunCore = Color(0xFFFFEBAE);
  static const Color _sunMid = Color(0xFFFFC266);
  static const Color _sunLow = Color(0xFFFF7E45);
  static const Color _rimGold = Color(0xFFFFCB80);

  /// Dune ranks, far to near: crest colour, foot colour.
  static const List<(Color, Color)> _dunes = [
    (Color(0xFFA0584F), Color(0xFF6E3747)),
    (Color(0xFF7C3E3E), Color(0xFF4C2335)),
    (Color(0xFF632F33), Color(0xFF361827)),
    (Color(0xFF4A2329), Color(0xFF26101A)),
  ];

  static double _horizon(Size size, bool menu) =>
      size.height * (menu ? .64 : .7);

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final rnd = math.Random(5);
    final full = Offset.zero & size;
    final hz = _horizon(size, menu);
    final light = menu ? .7 : 1.0;
    final f = hz / h; // horizon as a fraction, for gradient stops

    // 1. Sky: deep night above, the warm band hugging the horizon.
    canvas.drawRect(
      full,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_night, _indigo, _violet, _rose, _ember, _gold, _gold],
          stops: [0, f * .38, f * .66, f * .84, f * .95, f, 1],
        ).createShader(full),
    );

    // 2. Stars, fading out as the sky warms.
    final star = Paint();
    for (var i = 0; i < 110; i++) {
      final y = math.pow(rnd.nextDouble(), 1.4) * hz * .7;
      final fade = 1 - y / (hz * .7);
      star.color = Colors.white
          .withValues(alpha: (.15 + rnd.nextDouble() * .65) * fade * light);
      canvas.drawCircle(Offset(rnd.nextDouble() * w, y.toDouble()),
          s * (.0008 + rnd.nextDouble() * .002), star);
    }

    // 3. A thin crescent moon high on the left.
    final mc = Offset(w * .2, menu ? math.max(hz * .26, s * .3) : hz * .16);
    final mr = s * .035;
    canvas.drawCircle(
      mc,
      mr * 5,
      Paint()
        ..shader = RadialGradient(colors: [
          const Color(0xFFE9E6FF).withValues(alpha: .14 * light),
          const Color(0xFFE9E6FF).withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: mc, radius: mr * 5)),
    );
    final crescent = Path.combine(
      PathOperation.difference,
      Path()..addOval(Rect.fromCircle(center: mc, radius: mr)),
      Path()
        ..addOval(Rect.fromCircle(
            center: mc + Offset(mr * .45, -mr * .25), radius: mr * .92)),
    );
    canvas.drawPath(crescent, Paint()..color = const Color(0xFFFFF6DA));

    // 4. The sun: wide glow, then a smooth disc sinking into the horizon.
    final sr = s * (menu ? .17 : .12);
    final sc = Offset(w * (menu ? .66 : .74), hz - sr * .25);
    for (final (rad, a, col) in [
      (s * 1.0, .28, _ember),
      (sr * 2.6, .4, _sunMid),
      (sr * 1.35, .55, _sunCore),
    ]) {
      canvas.drawCircle(
        sc,
        rad,
        Paint()
          ..shader = RadialGradient(colors: [
            col.withValues(alpha: a * light),
            col.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: sc, radius: rad)),
      );
    }
    final sunRect = Rect.fromCircle(center: sc, radius: sr);
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, w, hz));
    canvas.drawCircle(
      sc,
      sr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _sunCore,
            _sunMid,
            _sunLow,
          ],
          stops: const [0, .5, 1],
        ).createShader(sunRect),
    );
    canvas.restore();

    // 5. Heat haze: thin sky-coloured slices across the sun's lower half
    // and soft bright bands along the horizon.
    final haze = Paint();
    for (var i = 0; i < 6; i++) {
      final y = sc.dy + sr * (.1 + i * .14);
      if (y > hz) break;
      final hgt = math.max(1.0, sr * (.02 + i * .012));
      final r = Rect.fromLTWH(sc.dx - sr * 1.2, y, sr * 2.4, hgt);
      haze.shader = ui.Gradient.linear(r.centerLeft, r.centerRight, [
        _ember.withValues(alpha: 0),
        Color.lerp(_ember, _gold, .4)!.withValues(alpha: .75),
        _ember.withValues(alpha: 0),
      ], const [0, .5, 1]);
      canvas.drawRect(r, haze);
    }
    for (var i = 0; i < 5; i++) {
      final y = hz - s * (.005 + i * .014);
      final r = Rect.fromLTWH(0, y - s * .004, w, s * .008);
      final wob = rnd.nextDouble();
      haze.shader = ui.Gradient.linear(r.centerLeft, r.centerRight, [
        _sunCore.withValues(alpha: 0),
        _sunCore.withValues(alpha: (.12 - i * .02) * light),
        _sunCore.withValues(alpha: 0),
      ], [0, .45 + wob * .3, 1]);
      canvas.drawRect(r, haze);
    }

    // 6. Birds heading home across the warm sky.
    final bird = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, s * .0028)
      ..color = const Color(0xFF2A1426).withValues(alpha: .8);
    for (var i = 0; i < 5; i++) {
      final b = Offset(w * (.38 + i * .045 + rnd.nextDouble() * .02),
          hz * (.62 + rnd.nextDouble() * .1) - i * s * .01);
      final span = s * (.012 + rnd.nextDouble() * .008);
      canvas.drawPath(
        Path()
          ..moveTo(b.dx - span, b.dy - span * .3)
          ..quadraticBezierTo(b.dx - span * .4, b.dy - span * .55, b.dx, b.dy)
          ..quadraticBezierTo(
              b.dx + span * .4, b.dy - span * .55, b.dx + span, b.dy - span * .3),
        bird,
      );
    }

    // 7. Far mesas in violet haze, the nearer butte darker.
    _mesas(canvas, w, hz, s, rnd, menu);

    // 8. Dune ranks.
    // Ranks spread over the whole land below the horizon, so tall phones
    // get big foreground dunes instead of a dead band.
    final land = h - hz;
    const ranks = [.0, .13, .32, .58];
    for (var k = 0; k < 4; k++) {
      final base = hz + land * ranks[k];
      final amp = math.min(land * (.1 + k * .075), s * (.05 + k * .06));
      final dunes = <(double, double, double)>[]; // centre, width, height
      var x = -s * .3 + rnd.nextDouble() * s * .2;
      while (x < w + s * .3) {
        final wid = s * (.22 + rnd.nextDouble() * .25) * (1 + k * .35);
        dunes.add((x, wid, amp * (.5 + rnd.nextDouble() * .7)));
        x += wid * (.9 + rnd.nextDouble() * .5);
      }
      // Near ranks dip in the middle so the board centre stays clear.
      final dip = menu ? 0.0 : (k >= 2 ? .45 : 0.0);
      _duneRank(canvas, size, base, dunes, _dunes[k], sc.dx, k, light, dip,
          rnd);
      if (k == 1 || k == 2) {
        // Cacti standing on this rank's crest.
        for (var i = 0; i < (k == 1 ? 3 : 2); i++) {
          final cx = k == 1
              ? w * (.08 + i * .36 + rnd.nextDouble() * .08)
              : w * (i == 0 ? .1 : .86);
          final cy = _crestY(cx, base, dunes, w, dip) + s * .004;
          _cactus(canvas, Offset(cx, cy), s * (k == 1 ? .07 : .15), rnd,
              _dunes[k].$2, sc.dx, light);
        }
      }
    }

    // 9. Foreground boulders in the corners.
    final bs = menu ? 1.3 : 1.0;
    _boulder(canvas, Offset(-s * .02, h + s * .01), s * .22 * bs, s * .1 * bs,
        sc.dx, light);
    _boulder(canvas, Offset(w + s * .03, h + s * .01), s * .26 * bs,
        s * .12 * bs, sc.dx, light);
    // Scattered pebbles and dry tufts on the foreground sand.
    final pebble = Paint()..color = const Color(0xFF1A0A10);
    final tuft = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, s * .0025)
      ..color = const Color(0xFF1A0A10);
    for (var i = 0; i < 14; i++) {
      final p = Offset(rnd.nextDouble() * w, hz + land * (.72 + rnd.nextDouble() * .26));
      if (!menu && (p.dx - w / 2).abs() < w * .2) continue;
      if (i.isEven) {
        canvas.drawOval(
            Rect.fromCenter(center: p, width: s * .018, height: s * .008), pebble);
      } else {
        for (var j = -2; j <= 2; j++) {
          canvas.drawLine(p, p + Offset(j * s * .006, -s * (.02 - j.abs() * .004)),
              tuft);
        }
      }
    }

    // 10. Vignette, a calm board centre, then the menu veil.
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          radius: .9,
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: .5),
          ],
          stops: const [.55, 1],
        ).createShader(full),
    );
    if (!menu) {
      final c = Rect.fromCenter(
          center: Offset(w / 2, h * .48), width: w * .95, height: h * .75);
      canvas.drawOval(
        c,
        Paint()
          ..shader = RadialGradient(colors: [
            _night.withValues(alpha: .45),
            _night.withValues(alpha: 0),
          ]).createShader(c),
      );
    }
    canvas.drawRect(
      full,
      Paint()..color = Colors.black.withValues(alpha: menu ? .32 : .1),
    );
  }

  /// Height of one dune profile: a sharp crest with a steep slip face on
  /// the left (away from the sun) and a long rounded windward slope.
  static double _bump(double u) {
    if (u < -1 || u > 1.8) return 0;
    if (u <= 0) return (1 + u) * (1 + u);
    final v = u / 1.8;
    return 1 - v * v * (3 - 2 * v);
  }

  static double _crestY(double x, double base,
      List<(double, double, double)> dunes, double w, double dip) {
    var m = 0.0;
    for (final d in dunes) {
      m = math.max(m, d.$3 * _bump((x - d.$1) / d.$2 * 2.2));
    }
    final mid = 1 - ((x - w / 2).abs() / (w * .32)).clamp(0.0, 1.0);
    return base - m * (1 - dip * mid);
  }

  static void _duneRank(
    Canvas canvas,
    Size size,
    double base,
    List<(double, double, double)> dunes,
    (Color, Color) colors,
    double sunX,
    int k,
    double light,
    double dip,
    math.Random rnd,
  ) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final step = w / 140;
    final crest = <Offset>[];
    for (var x = 0.0; x <= w + step; x += step) {
      crest.add(Offset(x, _crestY(x, base, dunes, w, dip)));
    }
    final body = Path()..moveTo(0, h);
    for (final p in crest) {
      body.lineTo(p.dx, p.dy);
    }
    body
      ..lineTo(w, h)
      ..close();
    final top = base - s * .2;
    canvas.drawPath(
      body,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [colors.$1, colors.$2],
        ).createShader(Rect.fromLTRB(0, top, w, h)),
    );

    // Sun-facing warmth: the right slopes catch a little sunset light.
    canvas.drawPath(
      body,
      Paint()
        ..shader = ui.Gradient.radial(
          Offset(sunX, base - s * .05),
          w * .7,
          [
            _ember.withValues(alpha: (.22 - k * .04) * light),
            _ember.withValues(alpha: 0),
          ],
        ),
    );

    // Slip-face shadows left of each crest.
    final shade = Paint()..color = const Color(0xFF12060E).withValues(alpha: .28 + k * .05);
    for (final d in dunes) {
      final px = d.$1;
      if (px < -s * .2 || px > w + s * .2) continue;
      final py = _crestY(px, base, dunes, w, dip);
      if (base - py < s * .01) continue;
      final left = px - d.$2 / 2.2;
      final path = Path()..moveTo(px, py);
      for (var x = px; x >= left; x -= step) {
        path.lineTo(x, _crestY(x, base, dunes, w, dip));
      }
      // Back to the crest under the slope: a crescent of shade.
      path.quadraticBezierTo(px - d.$2 * .08, py + (base - py) * .95, px, py);
      path.close();
      canvas.drawPath(path, shade);
    }

    // Rim light along the crest, brightest near the sun.
    final rim = Path()..moveTo(crest.first.dx, crest.first.dy);
    for (final p in crest.skip(1)) {
      rim.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      rim,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, s * (.003 + k * .0012))
        ..shader = ui.Gradient.linear(
          Offset(sunX - w * .75, 0),
          Offset(sunX + w * .75, 0),
          [
            _rimGold.withValues(alpha: .08 * light),
            _rimGold.withValues(alpha: (.85 - k * .15) * light),
            _rimGold.withValues(alpha: .08 * light),
          ],
          const [0, .5, 1],
        ),
    );

    // Wind ripples on the nearer ranks.
    if (k >= 1) {
      final ripple = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, s * .0018)
        ..color = _rimGold.withValues(alpha: (.06 + k * .015) * light);
      for (var i = 0; i < 10 + k * 6; i++) {
        final x0 = rnd.nextDouble() * w;
        final y0 = _crestY(x0, base, dunes, w, dip) +
            s * (.012 + rnd.nextDouble() * .1 * (k + 1) * .5);
        if (y0 > h) continue;
        final len = s * (.05 + rnd.nextDouble() * .1);
        canvas.drawPath(
          Path()
            ..moveTo(x0, y0)
            ..quadraticBezierTo(x0 + len * .5, y0 - s * .006, x0 + len, y0 + s * .002),
          ripple,
        );
      }
    }
  }

  static void _mesas(
      Canvas canvas, double w, double hz, double s, math.Random rnd, bool menu) {
    void mesa(double x0, double x1, double top, Color color, Color? rim) {
      final hgt = hz - top;
      final path = Path()..moveTo(x0 - hgt * .5, hz);
      // Talus slope, cliff, flat top with a notch, cliff, talus.
      path
        ..lineTo(x0 - hgt * .2, hz - hgt * .35)
        ..lineTo(x0, hz - hgt * .62)
        ..lineTo(x0 + hgt * .05, top);
      var x = x0 + hgt * .05;
      while (x < x1 - hgt * .05) {
        final nx = math.min(x1 - hgt * .05, x + s * (.02 + rnd.nextDouble() * .04));
        path.lineTo(nx, top + (rnd.nextDouble() - .5) * hgt * .06);
        x = nx;
      }
      path
        ..lineTo(x1 - hgt * .05, top)
        ..lineTo(x1, hz - hgt * .6)
        ..lineTo(x1 + hgt * .25, hz - hgt * .3)
        ..lineTo(x1 + hgt * .6, hz)
        ..close();
      canvas.drawPath(path, Paint()..color = color);
      if (rim != null) {
        canvas.drawPath(
          Path()
            ..moveTo(x1 - hgt * .05, top)
            ..lineTo(x1, hz - hgt * .6)
            ..lineTo(x1 + hgt * .25, hz - hgt * .3),
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = math.max(1.0, s * .0025)
            ..color = rim,
        );
      }
    }

    mesa(w * .02, w * .2, hz - s * .085, const Color(0xFF7A4560), null);
    mesa(w * .82, w * .98, hz - s * .06, const Color(0xFF7A4560), null);
    mesa(w * .3, w * .38, hz - s * .05, const Color(0xFF8A4D62), null);
    mesa(w * .1, w * .27, hz - s * .12, const Color(0xFF5A2E48),
        _rimGold.withValues(alpha: .45));
  }

  /// A saguaro-style cactus: a column with up-turned arms.
  static void _cactus(Canvas canvas, Offset base, double height,
      math.Random rnd, Color color, double sunX, double light) {
    final cw = height * .14;
    final paint = Paint()..color = color;
    final trunk = RRect.fromRectAndCorners(
      Rect.fromLTWH(base.dx - cw / 2, base.dy - height, cw, height),
      topLeft: Radius.circular(cw / 2),
      topRight: Radius.circular(cw / 2),
    );
    canvas.drawRRect(trunk, paint);
    final aw = cw * .78;
    final rimSide = sunX > base.dx ? 1.0 : -1.0;
    final rim = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, cw * .12)
      ..strokeCap = StrokeCap.round
      ..color = _rimGold.withValues(alpha: .55 * light + .1);
    for (final side in const [-1.0, 1.0]) {
      if (side > 0 && rnd.nextDouble() < .25) continue;
      final y = base.dy - height * (.35 + rnd.nextDouble() * .25);
      final out = cw * (.9 + rnd.nextDouble() * .5);
      final up = height * (.2 + rnd.nextDouble() * .18);
      final ax = base.dx + side * (cw / 2 + out);
      final arm = Path()
        ..moveTo(base.dx, y)
        ..lineTo(ax - side * aw / 2, y)
        ..arcToPoint(Offset(ax + side * aw / 2, y - aw / 2),
            radius: Radius.circular(aw), clockwise: side < 0)
        ..lineTo(ax + side * aw / 2, y - up)
        ..arcToPoint(Offset(ax - side * aw / 2, y - up),
            radius: Radius.circular(aw / 2), clockwise: side < 0)
        ..lineTo(ax - side * aw / 2, y - aw * .8)
        ..lineTo(base.dx, y - aw * .8)
        ..close();
      canvas.drawPath(arm, paint);
      if (side == rimSide) {
        canvas.drawLine(Offset(ax + side * aw / 2, y - aw * .4),
            Offset(ax + side * aw / 2, y - up), rim);
      }
    }
    canvas.drawLine(
        Offset(base.dx + rimSide * cw * .42, base.dy - height * .05),
        Offset(base.dx + rimSide * cw * .42, base.dy - height + cw * .5),
        rim);
  }

  static void _boulder(Canvas canvas, Offset c, double rw, double rh,
      double sunX, double light) {
    final path = Path()
      ..moveTo(c.dx - rw, c.dy)
      ..cubicTo(c.dx - rw * .95, c.dy - rh * .9, c.dx - rw * .3, c.dy - rh * 1.25,
          c.dx + rw * .2, c.dy - rh * 1.05)
      ..cubicTo(c.dx + rw * .7, c.dy - rh * .9, c.dx + rw, c.dy - rh * .4,
          c.dx + rw, c.dy)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF12070C));
    final rimPath = Path()
      ..moveTo(c.dx - rw * .3, c.dy - rh * 1.15)
      ..cubicTo(c.dx + rw * .1, c.dy - rh * 1.1, c.dx + rw * .7, c.dy - rh * .9,
          c.dx + rw * .9, c.dy - rh * .45);
    canvas.drawPath(
      rimPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, rh * .03)
        ..color = _rimGold.withValues(alpha: .3 * light + .05),
    );
  }

  @override
  Color get cardBase => const Color(0xC81A0D1A);

  @override
  Color get headerBand => const Color(0xFF1A0E1C);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFD98A), GameConstants.desertSnake, Color(0xFFDB7A3C)],
        stops: [0, .55, 1],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [
          GameConstants.desertSnake,
          Color(0xFFDD9440),
          Color(0xFFBF7234),
        ],
        edge: Color(0xFFFFEBB8),
        shine: .22,
        tailFade: .26,
      );

  @override
  Color get foodRing => const Color(0xFFB9FFF7);
}
