import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

/// Ocean: a deep reef seen from below the surface. A shimmering surface,
/// soft god rays fanning down, a layered blue-teal depth gradient, a far
/// reef ridge, a school of distant fish, coral heads and swaying kelp
/// along the seabed, rising bubbles and drifting marine snow.
///
/// Generic underwater imagery only (no characters, brands or landmarks).
/// Everything soft is a gradient, never a blur, so replaying the cached
/// picture stays cheap. [paintMotion] adds a handful of rising bubbles.
class OceanThemeScene extends ThemeScene {
  const OceanThemeScene();

  // Water, surface to abyss.
  static const Color _surface = Color(0xFF2391B0);
  static const Color _shallow = Color(0xFF0F6185);
  static const Color _mid = Color(0xFF07405F);
  static const Color _deep = Color(0xFF042845);
  static const Color _abyss = Color(0xFF010E1E);

  static const Color _light = Color(0xFFC6F6FF);
  static const Color _haze = Color(0xFF145C78);
  static const Color _farReef = Color(0xFF0A3A55);
  static const Color _midReef = Color(0xFF062B42);
  static const Color _ink = Color(0xFF02121E);
  static const Color _rim = Color(0xFF62E6E0);
  static const Color _warmRim = Color(0xFFFF9A7A);

  /// Seabed top as a fraction of the shorter side, from the bottom.
  static double _bed(Size size, bool menu) =>
      math.min(size.width, size.height) * (menu ? .26 : .22);

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final rnd = math.Random(23);
    final full = Offset.zero & size;
    final light = menu ? .9 : 1.0;

    // 1. Depth gradient.
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_surface, _shallow, _mid, _deep, _abyss],
          stops: [0, .16, .4, .7, 1],
        ).createShader(full),
    );

    // 2. Sun glow through the surface, off-centre.
    final sun = Offset(w * .36, -s * .12);
    canvas.drawCircle(
      sun,
      s * 1.1,
      Paint()
        ..shader = RadialGradient(colors: [
          _light.withValues(alpha: .42 * light),
          _light.withValues(alpha: .12 * light),
          _light.withValues(alpha: 0),
        ], stops: const [0, .35, 1])
            .createShader(Rect.fromCircle(center: sun, radius: s * 1.1)),
    );

    // 3. The surface seen from below: wobbling bright ripple lines.
    _surfaceRipples(canvas, w, s, rnd, light);

    // 4. God rays from the sun spot.
    _godRays(canvas, size, sun, rnd, light);

    // 5. Marine snow.
    final snow = Paint();
    for (var i = 0; i < 110; i++) {
      final p = Offset(rnd.nextDouble() * w, rnd.nextDouble() * h);
      snow.color = _light.withValues(alpha: (.06 + rnd.nextDouble() * .22) * light);
      canvas.drawCircle(p, s * (.0012 + rnd.nextDouble() * .0022), snow);
    }

    // 6. Distant fish: a school high up and two big shapes in the haze.
    _school(canvas, Offset(w * .74, h * .2), s, rnd,
        _haze.withValues(alpha: .85), 14);
    _school(canvas, Offset(w * .2, h * .34), s * .7, rnd,
        _haze.withValues(alpha: .55), 9);
    _fish(canvas, Offset(w * .14, h * .14), s * .09, 1,
        Paint()..color = _haze.withValues(alpha: .45));
    _fish(canvas, Offset(w * .9, h * .46), s * .07, -1,
        Paint()..color = _haze.withValues(alpha: .35));

    final bedH = _bed(size, menu);
    final bedTop = h - bedH;

    // 7. Far rock stacks, far reef ridge with hazy kelp.
    final stack = menu ? .62 : .4;
    _pillar(canvas, Offset(w * .07, bedTop), s * stack, s * .1, rnd,
        const Color(0xFF155C7C));
    _pillar(canvas, Offset(w * .94, bedTop), s * stack * .8, s * .08, rnd,
        const Color(0xFF155C7C));
    _pillar(canvas, Offset(w * .82, bedTop), s * stack * .45, s * .06, rnd,
        const Color(0xFF104C68));
    for (var i = 0; i < 9; i++) {
      final x = rnd.nextDouble() * w;
      _kelp(canvas,
          base: Offset(x, bedTop + s * .02),
          height: s * (.16 + rnd.nextDouble() * .2),
          width: s * .012,
          sway: s * .03,
          phase: rnd.nextDouble() * 6,
          color: _farReef.withValues(alpha: .8),
          rim: null,
          rnd: rnd);
    }
    _ridge(canvas, w, bedTop - s * .04, s * .07, s, rnd,
        Paint()..color = _farReef);

    // 8. Light pool where the rays reach the bed.
    final pool = Rect.fromCenter(
        center: Offset(w * .45, bedTop + bedH * .25),
        width: w * 1.1,
        height: bedH * 1.2);
    canvas.drawOval(
      pool,
      Paint()
        ..shader = RadialGradient(colors: [
          _light.withValues(alpha: .16 * light),
          _light.withValues(alpha: 0),
        ]).createShader(pool),
    );

    // Caustics: a loose net of light on the sand under the rays.
    final caustic = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, s * .003);
    for (var i = 0; i < 70; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final r = math.sqrt(rnd.nextDouble());
      final c = pool.center +
          Offset(math.cos(a) * pool.width * .42 * r,
              bedH * .35 + math.sin(a) * bedH * .3 * r);
      final l = s * (.015 + rnd.nextDouble() * .025);
      final ang = rnd.nextDouble() * math.pi;
      final d = Offset(math.cos(ang), math.sin(ang) * .35) * l;
      caustic.color = _light.withValues(alpha: (.05 + .08 * (1 - r)) * light);
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - d.dx, c.dy - d.dy)
          ..quadraticBezierTo(c.dx + d.dy, c.dy - d.dx * .4, c.dx + d.dx, c.dy + d.dy),
        caustic,
      );
    }

    // Mid kelp: a hazier row between the far reef and the near forest.
    for (final x in const [.05, .19, .31, .7, .83, .97]) {
      _kelp(canvas,
          base: Offset(w * x, bedTop + s * .06),
          height: s * (menu ? .42 : .3) * (.7 + rnd.nextDouble() * .5),
          width: s * .018,
          sway: s * .04,
          phase: x * 11,
          color: const Color(0xFF0A3449),
          rim: null,
          rnd: rnd);
    }

    // 9. Mid reef: coral heads in muted colour.
    _ridge(canvas, w, bedTop + s * .03, s * .05, s, rnd,
        Paint()..color = _midReef);
    const corals = [
      Color(0xFF5A2E52),
      Color(0xFF7A3F45),
      Color(0xFF285E66),
      Color(0xFF6B4A2E),
    ];
    for (var i = 0; i < 7; i++) {
      final x = w * (.05 + i * .15 + rnd.nextDouble() * .06);
      final base = Offset(x, bedTop + s * (.05 + rnd.nextDouble() * .03));
      final col = Color.lerp(corals[i % corals.length], _midReef, .35)!;
      switch (i % 3) {
        case 0:
          _branchCoral(canvas, base, s * (.07 + rnd.nextDouble() * .05), rnd,
              Paint()
                ..color = col
                ..strokeCap = StrokeCap.round
                ..style = PaintingStyle.stroke);
        case 1:
          _brainCoral(canvas, base, s * (.05 + rnd.nextDouble() * .03), col, light);
        default:
          _seaFan(canvas, base, s * (.09 + rnd.nextDouble() * .05), rnd, col);
      }
    }

    // 10. Seabed sand.
    final bed = Path()..moveTo(0, bedTop + s * .08);
    for (var x = 0.0; x <= w + 1; x += w / 24) {
      bed.lineTo(x, bedTop + s * .08 + math.sin(x / w * 7 + 1) * s * .012);
    }
    bed
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    final bedRect = Rect.fromLTRB(0, bedTop, w, h);
    canvas.drawPath(
      bed,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E4C5E), Color(0xFF062534), _abyss],
          stops: [0, .45, 1],
        ).createShader(bedRect),
    );
    final ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, s * .0025);
    for (var i = 0; i < 16; i++) {
      final y = bedTop + s * .1 + rnd.nextDouble() * (bedH - s * .1);
      final x0 = rnd.nextDouble() * w;
      final len = w * (.08 + rnd.nextDouble() * .14);
      ripple.color = _light.withValues(alpha: .05 + rnd.nextDouble() * .05);
      canvas.drawPath(
        Path()
          ..moveTo(x0, y)
          ..quadraticBezierTo(x0 + len / 2, y - s * .008, x0 + len, y),
        ripple,
      );
    }

    // 11. Near kelp forest on the sides, short tufts in the middle.
    final kelpInk = _ink.withValues(alpha: .97);
    final sides = [
      (.02, .62), (.09, .78), (.16, .5), (.24, .36),
      (.78, .4), (.86, .7), (.93, .84), (.99, .56),
    ];
    for (final k in sides) {
      _kelp(canvas,
          base: Offset(w * k.$1, h + s * .02),
          height: s * k.$2 * (menu ? (h > w ? .95 : .6) : .7),
          width: s * .026,
          sway: s * .05,
          phase: k.$1 * 17,
          color: kelpInk,
          rim: _rim.withValues(alpha: .32 * light + .08),
          rnd: rnd);
    }
    for (var i = 0; i < 6; i++) {
      final x = w * (.3 + i * .08 + rnd.nextDouble() * .03);
      _grass(canvas, Offset(x, h + s * .005), s * (.07 + rnd.nextDouble() * .05),
          s, rnd, kelpInk, _rim.withValues(alpha: .18 * light + .05));
    }

    // 12. Near coral silhouettes at the corners with a warm rim.
    _rock(canvas, Offset(-s * .04, h), s * .3, s * .15, rnd);
    _rock(canvas, Offset(w + s * .04, h), s * .34, s * .17, rnd);
    _branchCoral(canvas, Offset(w * .1, h - s * .07), s * .16, rnd,
        Paint()
          ..color = _ink
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
        rim: _warmRim.withValues(alpha: .22 * light + .06));
    _branchCoral(canvas, Offset(w * .9, h - s * .08), s * .14, rnd,
        Paint()
          ..color = _ink
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
        rim: _warmRim.withValues(alpha: .22 * light + .06));

    // 13. Static bubble trails rising from the reef.
    for (final col in [w * .2, w * .82, w * .12]) {
      var y = bedTop - s * .02;
      var x = col;
      for (var i = 0; i < 9; i++) {
        final r = s * (.004 + rnd.nextDouble() * .008);
        _bubble(canvas, Offset(x, y), r, .55 * light + .15);
        y -= s * (.03 + rnd.nextDouble() * .05);
        x += math.sin(i * 1.3) * s * .012;
      }
    }

    // 14. Depth vignette, then keep the board centre calm.
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
          center: Offset(w / 2, h * .5), width: w * .95, height: h * .8);
      canvas.drawOval(
        c,
        Paint()
          ..shader = RadialGradient(colors: [
            _abyss.withValues(alpha: .42),
            _abyss.withValues(alpha: 0),
          ]).createShader(c),
      );
    }
    canvas.drawRect(
      full,
      Paint()..color = Colors.black.withValues(alpha: menu ? .22 : .12),
    );
  }

  static void _surfaceRipples(
      Canvas canvas, double w, double s, math.Random rnd, double light) {
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 14; i++) {
      final y0 = s * (.004 + i * .009 + rnd.nextDouble() * .006);
      final f = 6 + rnd.nextDouble() * 10;
      final ph = rnd.nextDouble() * 6;
      final amp = s * (.003 + rnd.nextDouble() * .004);
      final path = Path()..moveTo(0, y0);
      for (var x = 0.0; x <= w; x += w / 60) {
        path.lineTo(x, y0 + math.sin(x / w * f + ph) * amp);
      }
      p
        ..strokeWidth = s * (.002 + rnd.nextDouble() * .003) * (1 - i / 16)
        ..color = _light.withValues(alpha: (.28 - i * .017) * light);
      canvas.drawPath(path, p);
    }
  }

  /// Soft shafts of light: each ray is sliced along its length, every
  /// slice filled with a transparent-bright-transparent gradient across
  /// its width, so the edges are soft without any blur. Slices abut
  /// without antialiasing, so there are no seams.
  static void _godRays(
      Canvas canvas, Size size, Offset src, math.Random rnd, double light) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    const slices = 18;
    final paint = Paint()..isAntiAlias = false;
    for (var r = 0; r < 10; r++) {
      final a = (-.5 + r / 9) * .75 + (rnd.nextDouble() - .5) * .08;
      final dir = Offset(math.sin(a), math.cos(a));
      final nrm = Offset(math.cos(a), -math.sin(a));
      final len = h * (.6 + rnd.nextDouble() * .35);
      final w0 = s * (.02 + rnd.nextDouble() * .05);
      final w1 = w0 * (2.4 + rnd.nextDouble() * 1.6);
      final peak = (.1 + rnd.nextDouble() * .12) * light;
      for (var i = 0; i < slices; i++) {
        final t0 = i / slices;
        final t1 = (i + 1) / slices;
        final tm = (t0 + t1) / 2;
        final p0 = src + dir * (len * t0);
        final p1 = src + dir * (len * t1);
        final pm = src + dir * (len * tm);
        final hw0 = (w0 + (w1 - w0) * t0) / 2;
        final hw1 = (w0 + (w1 - w0) * t1) / 2;
        final hwm = (w0 + (w1 - w0) * tm) / 2;
        final alpha = peak * math.pow(1 - tm, 1.6);
        final c = _light.withValues(alpha: alpha.toDouble());
        paint.shader = ui.Gradient.linear(
          pm - nrm * hwm,
          pm + nrm * hwm,
          [c.withValues(alpha: 0), c, c.withValues(alpha: 0)],
          const [0, .5, 1],
        );
        final quad = Path()
          ..moveTo((p0 - nrm * hw0).dx, (p0 - nrm * hw0).dy)
          ..lineTo((p0 + nrm * hw0).dx, (p0 + nrm * hw0).dy)
          ..lineTo((p1 + nrm * hw1).dx, (p1 + nrm * hw1).dy)
          ..lineTo((p1 - nrm * hw1).dx, (p1 - nrm * hw1).dy)
          ..close();
        canvas.drawPath(quad, paint);
      }
    }
  }

  static void _ridge(Canvas canvas, double w, double y, double amp, double s,
      math.Random rnd, Paint paint) {
    final path = Path()..moveTo(0, y + amp);
    var x = 0.0;
    var py = y;
    while (x < w) {
      final nx = x + s * (.06 + rnd.nextDouble() * .1);
      final ny = y + amp * (rnd.nextDouble() - .2);
      path.quadraticBezierTo((x + nx) / 2, math.min(py, ny) - amp * .6, nx, ny);
      x = nx;
      py = ny;
    }
    path
      ..lineTo(w, y + amp * 6)
      ..lineTo(0, y + amp * 6)
      ..close();
    canvas.drawPath(path, paint);
  }

  static void _fish(
      Canvas canvas, Offset c, double len, double dir, Paint paint) {
    final l = len / 2;
    final hgt = len * .22;
    final path = Path()
      ..moveTo(c.dx + l * dir, c.dy)
      ..quadraticBezierTo(c.dx + l * .2 * dir, c.dy - hgt * 1.2,
          c.dx - l * .6 * dir, c.dy - hgt * .1)
      ..lineTo(c.dx - l * dir, c.dy - hgt * .9)
      ..lineTo(c.dx - l * .85 * dir, c.dy)
      ..lineTo(c.dx - l * dir, c.dy + hgt * .9)
      ..lineTo(c.dx - l * .6 * dir, c.dy + hgt * .1)
      ..quadraticBezierTo(
          c.dx + l * .2 * dir, c.dy + hgt * 1.2, c.dx + l * dir, c.dy)
      ..close();
    canvas.drawPath(path, paint);
  }

  static void _school(Canvas canvas, Offset c, double s, math.Random rnd,
      Color color, int n) {
    final paint = Paint()..color = color;
    for (var i = 0; i < n; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final r = math.sqrt(rnd.nextDouble());
      final p = c + Offset(math.cos(a) * s * .14 * r, math.sin(a) * s * .05 * r);
      _fish(canvas, p, s * (.022 + rnd.nextDouble() * .012), -1, paint);
    }
  }

  /// Giant kelp: a thin swaying stipe with long drooping leaf blades and
  /// little gas bladders at their bases.
  static void _kelp(
    Canvas canvas, {
    required Offset base,
    required double height,
    required double width,
    required double sway,
    required double phase,
    required Color color,
    required Color? rim,
    required math.Random rnd,
  }) {
    const n = 22;
    final spine = <Offset>[];
    for (var i = 0; i <= n; i++) {
      final t = i / n;
      spine.add(Offset(
          base.dx + math.sin(t * math.pi * 1.3 + phase) * sway * t,
          base.dy - height * t));
    }
    final stipe = Path()..moveTo(spine.first.dx, spine.first.dy);
    for (var i = 1; i < n; i++) {
      final m = (spine[i] + spine[i + 1]) / 2;
      stipe.quadraticBezierTo(spine[i].dx, spine[i].dy, m.dx, m.dy);
    }
    final paint = Paint()..color = color;
    canvas.drawPath(
      stipe,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = width * .32
        ..color = color,
    );

    final blades = Path();
    final bladders = Path();
    final rimPath = Path();
    for (var i = 3; i <= n; i += 3) {
      final p = spine[i];
      final t = i / n;
      final side = (i ~/ 3).isEven ? 1.0 : -1.0;
      final bl = width * (5.5 + rnd.nextDouble() * 3) * (1 - t * .35);
      final bw = width * (.6 + rnd.nextDouble() * .3) * (1 - t * .25);
      final ang = side * (.35 + rnd.nextDouble() * .35);
      final dir = Offset(math.sin(ang), -math.cos(ang));
      final nrm = Offset(-dir.dy, dir.dx);
      final tip = p + dir * bl + Offset(side * bl * .3, bl * .22);
      final mid = p + dir * (bl * .5);
      final a = mid + nrm * bw;
      final b = mid - nrm * bw * .7;
      blades
        ..moveTo(p.dx, p.dy)
        ..quadraticBezierTo(a.dx, a.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(b.dx, b.dy, p.dx, p.dy)
        ..close();
      final bp = p + dir * (width * .45);
      bladders.addOval(Rect.fromCircle(center: bp, radius: width * .3));
      // Lit edge: the upper (surface-facing) side of each blade.
      final up = (a.dy < b.dy) ? a : b;
      rimPath
        ..moveTo(p.dx, p.dy)
        ..quadraticBezierTo(up.dx, up.dy, tip.dx, tip.dy);
    }
    // Crown blade at the top, pointing up.
    final top = spine.last;
    final crown = top + Offset(sway * .2, -width * 4);
    blades
      ..moveTo(top.dx, top.dy)
      ..quadraticBezierTo(top.dx + width, top.dy - width * 2, crown.dx, crown.dy)
      ..quadraticBezierTo(top.dx - width, top.dy - width * 2, top.dx, top.dy)
      ..close();
    canvas.drawPath(blades, paint);
    canvas.drawPath(bladders, paint);
    if (rim != null) {
      canvas.drawPath(
        rimPath,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, width * .1)
          ..color = rim,
      );
    }
  }

  /// A tuft of seagrass ribbons from one root.
  static void _grass(Canvas canvas, Offset base, double height, double s,
      math.Random rnd, Color color, Color? rim) {
    final paint = Paint()..color = color;
    final rp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, s * .0015)
      ..color = rim ?? Colors.transparent;
    for (var i = 0; i < 7; i++) {
      final lean = (i - 3) * .18 + (rnd.nextDouble() - .5) * .2;
      final hh = height * (.55 + rnd.nextDouble() * .45);
      final bw = s * (.006 + rnd.nextDouble() * .004);
      final tip = base + Offset(lean * hh + hh * .15 * math.sin(i * 2.1), -hh);
      final ctrl = base + Offset(lean * hh * .2, -hh * .6);
      final path = Path()
        ..moveTo(base.dx - bw, base.dy)
        ..quadraticBezierTo(ctrl.dx - bw, ctrl.dy, tip.dx, tip.dy)
        ..quadraticBezierTo(ctrl.dx + bw, ctrl.dy, base.dx + bw, base.dy)
        ..close();
      canvas.drawPath(path, paint);
      if (rim != null) {
        canvas.drawPath(
            Path()
              ..moveTo(base.dx + bw, base.dy - hh * .3)
              ..quadraticBezierTo(ctrl.dx + bw, ctrl.dy, tip.dx, tip.dy),
            rp);
      }
    }
  }

  /// A tall hazy rock stack rising from the far reef.
  static void _pillar(Canvas canvas, Offset base, double height, double width,
      math.Random rnd, Color color) {
    final path = Path()..moveTo(base.dx - width, base.dy);
    const n = 9;
    for (var i = 1; i <= n; i++) {
      final t = i / n;
      final wob = (rnd.nextDouble() - .5) * width * .35;
      path.lineTo(base.dx - width * (1 - t * .45) + wob, base.dy - height * t);
    }
    path.quadraticBezierTo(base.dx, base.dy - height * 1.06,
        base.dx + width * .55, base.dy - height);
    for (var i = n - 1; i >= 0; i--) {
      final t = i / n;
      final wob = (rnd.nextDouble() - .5) * width * .35;
      path.lineTo(base.dx + width * (1 - t * .45) + wob, base.dy - height * t);
    }
    path.close();
    final r = Rect.fromLTRB(base.dx - width, base.dy - height, base.dx + width,
        base.dy);
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color.withValues(alpha: .25), color],
        ).createShader(r),
    );
  }

  static void _branchCoral(
      Canvas canvas, Offset base, double size, math.Random rnd, Paint paint,
      {Color? rim}) {
    void branch(Offset p, double a, double len, double wdt, int depth) {
      final end = p + Offset(math.sin(a), -math.cos(a)) * len;
      paint.strokeWidth = wdt;
      canvas.drawLine(p, end, paint);
      if (rim != null && depth <= 1) {
        canvas.drawLine(
            p + Offset(wdt * .3, 0),
            end + Offset(wdt * .3, 0),
            Paint()
              ..color = rim
              ..strokeCap = StrokeCap.round
              ..strokeWidth = math.max(1.0, wdt * .18));
      }
      if (depth == 0) {
        canvas.drawCircle(end, wdt * .7, Paint()..color = paint.color);
        return;
      }
      final k = 2 + (rnd.nextDouble() < .4 ? 1 : 0);
      for (var i = 0; i < k; i++) {
        final na = a + (i - (k - 1) / 2) * (.5 + rnd.nextDouble() * .3);
        branch(end, na, len * (.62 + rnd.nextDouble() * .18), wdt * .72,
            depth - 1);
      }
    }

    for (var i = 0; i < 3; i++) {
      branch(base, (i - 1) * .5 + (rnd.nextDouble() - .5) * .2, size * .5,
          size * .14, 2);
    }
  }

  static void _brainCoral(
      Canvas canvas, Offset base, double r, Color color, double light) {
    final rect = Rect.fromCenter(center: base, width: r * 2.4, height: r * 2);
    canvas.drawArc(rect, math.pi, math.pi, true, Paint()..color = color);
    final groove = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, r * .05)
      ..color = Colors.black.withValues(alpha: .25);
    for (var i = 1; i < 4; i++) {
      canvas.drawArc(rect.deflate(r * .22 * i), math.pi, math.pi, false, groove);
    }
    canvas.drawArc(
      rect,
      math.pi * 1.15,
      math.pi * .55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, r * .06)
        ..color = _light.withValues(alpha: .18 * light),
    );
  }

  static void _seaFan(
      Canvas canvas, Offset base, double size, math.Random rnd, Color color) {
    final fan = Path()..moveTo(base.dx, base.dy);
    fan.cubicTo(base.dx - size * .9, base.dy - size * .5,
        base.dx - size * .55, base.dy - size * 1.15, base.dx, base.dy - size);
    fan.cubicTo(base.dx + size * .55, base.dy - size * 1.15,
        base.dx + size * .9, base.dy - size * .5, base.dx, base.dy);
    canvas.drawPath(fan, Paint()..color = color.withValues(alpha: .55));
    final ribs = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, size * .025)
      ..color = color;
    for (var i = 0; i < 9; i++) {
      final a = -1.15 + i * (2.3 / 8);
      final end = base + Offset(math.sin(a), -math.cos(a)) * size * .98;
      canvas.drawPath(
        Path()
          ..moveTo(base.dx, base.dy)
          ..quadraticBezierTo(base.dx + (end.dx - base.dx) * .3,
              base.dy - size * .5, end.dx, end.dy),
        ribs,
      );
    }
    canvas.drawPath(fan, ribs);
  }

  static void _rock(Canvas canvas, Offset c, double rw, double rh,
      math.Random rnd) {
    final path = Path()..moveTo(c.dx - rw, c.dy);
    path.cubicTo(c.dx - rw * .9, c.dy - rh * 1.1, c.dx + rw * .5,
        c.dy - rh * 1.3, c.dx + rw, c.dy);
    path.close();
    canvas.drawPath(path, Paint()..color = _ink);
  }

  static void _bubble(Canvas canvas, Offset c, double r, double alpha) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, r * .22)
        ..color = _light.withValues(alpha: alpha),
    );
    canvas.drawCircle(c, r, Paint()..color = _light.withValues(alpha: alpha * .12));
    canvas.drawCircle(c + Offset(-r * .35, -r * .35), r * .25,
        Paint()..color = Colors.white.withValues(alpha: alpha));
  }

  // Motion: a dozen bubbles rising up the board, wobbling as they go.
  static final Paint _mRing = Paint()..style = PaintingStyle.stroke;
  static final Paint _mDot = Paint();

  @override
  bool get hasMotion => true;

  @override
  void paintMotion(Canvas canvas, Size size, double seconds) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    _mRing.strokeWidth = math.max(1.0, s * .0022);
    for (var i = 0; i < 12; i++) {
      // Fixed per-bubble constants from the index (no Random per frame).
      final lane = ((i * 0.618034) % 1.0);
      final speed = .05 + (i * 0.37 % 1.0) * .05; // screens per second
      final t = (seconds * speed + i * .29) % 1.0;
      // Bubbles keep to the side thirds so the board centre stays clear.
      final lx = lane < .5 ? lane * .6 : .7 + (lane - .5) * .6;
      final x = w * lx + math.sin(seconds * 1.6 + i) * s * .012;
      final y = h * (1.05 - t * 1.15);
      final r = s * (.0045 + (i % 4) * .0018) * (1 + t * .4);
      final fade = t < .1 ? t / .1 : (t > .85 ? (1 - t) / .15 : 1.0);
      _mRing.color = _light.withValues(alpha: .4 * fade);
      canvas.drawCircle(Offset(x, y), r, _mRing);
      _mDot.color = Colors.white.withValues(alpha: .5 * fade);
      canvas.drawCircle(Offset(x - r * .35, y - r * .35), r * .26, _mDot);
    }
  }

  @override
  Color get cardBase => const Color(0xC4021A2C);

  @override
  Color get headerBand => const Color(0xFF031B2E);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6CF2DC), GameConstants.oceanSnake, Color(0xFF1C9BC4)],
        stops: [0, .55, 1],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [
          GameConstants.oceanSnake,
          Color(0xFF1EB5AE),
          Color(0xFF1784A6),
        ],
        edge: Color(0xFFB6FFF4),
        shine: .2,
        tailFade: .3,
      );

  @override
  Color get foodRing => const Color(0xFFFFC2A8);
}
