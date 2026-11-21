import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

/// Space: deep space. A layered nebula (purple, magenta, blue and teal
/// clouds cut by dark dust lanes), a dense starfield with a few bright
/// stars wearing diffraction spikes, a distant spiral smudge, a ringed gas
/// giant and a small cratered moon. On the board, a dozen stars twinkle
/// and a shooting star drifts across now and then.
class SpaceThemeScene extends ThemeScene {
  const SpaceThemeScene();

  static const Color _void = Color(0xFF030411);
  static const Color _purple = Color(0xFF7B3FE4);
  static const Color _magenta = Color(0xFFD13FB0);
  static const Color _blue = Color(0xFF3A5BFF);
  static const Color _teal = Color(0xFF1FC8C8);

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final full = Offset.zero & size;
    final rnd = math.Random(menu ? 41 : 43);
    final tall = h > w * 1.3;

    // 1. Base.
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_void, Color(0xFF070A24), Color(0xFF0A0620), _void],
          stops: [0, .4, .7, 1],
        ).createShader(full),
    );

    // 2. Nebula along a diagonal band.
    final a = Offset(w * -.05, h * (tall ? .22 : .1));
    final b = Offset(w * 1.05, h * (tall ? .7 : .95));
    _nebula(canvas, size, a, b, rnd, s);

    // 3. Starfield, denser inside the band.
    final star = Paint();
    final n = (w * h / (s * s) * (menu ? 520 : 460)).round();
    for (var i = 0; i < n; i++) {
      var p = Offset(rnd.nextDouble() * w, rnd.nextDouble() * h);
      if (i.isEven) {
        // Pull half of them toward the band.
        final t = rnd.nextDouble();
        final onBand = Offset.lerp(a, b, t)!;
        final spread = s * .22 * (rnd.nextDouble() - .5) * 2;
        p = onBand + Offset(-spread * .6, spread);
      }
      final m = rnd.nextDouble();
      final r = s * (.0007 + m * m * m * .0028);
      final tint = rnd.nextDouble();
      final col = tint < .15
          ? const Color(0xFFFFD9B0)
          : tint < .4
              ? const Color(0xFFBFD4FF)
              : Colors.white;
      star.color = col.withValues(alpha: .25 + rnd.nextDouble() * .65);
      canvas.drawCircle(p, r, star);
    }

    // 4. Distant galaxy smudge.
    _galaxy(canvas, Offset(w * (tall ? .78 : .3), h * (tall ? .1 : .2)), s * .09,
        -.5);

    // 5. Bright stars with spikes.
    final brights = <(double, double, double)>[
      (.18, .14, 1),
      (.62, .41, .7),
      (.86, .62, .8),
      (.3, .78, .6),
      (.08, .5, .5),
      (.5, .08, .55),
    ];
    for (final (fx, fy, k) in brights) {
      _brightStar(canvas, Offset(fx * w, fy * h), s * .05 * k,
          fx > .5 ? const Color(0xFFCFE0FF) : const Color(0xFFFFE8D0));
    }

    // 6. Ringed planet and moon.
    if (menu) {
      if (tall) {
        _planet(canvas, Offset(w * .74, h * .86), s * .3, s);
        _moon(canvas, Offset(w * .2, h * .64), s * .06);
      } else {
        _planet(canvas, Offset(w * .84, h * .74), s * .26, s);
        _moon(canvas, Offset(w * .12, h * .3), s * .06);
      }
    } else {
      _planet(canvas, Offset(w * .8, h * .84), s * .2, s);
      _moon(canvas, Offset(w * .13, h * .12), s * .055);
    }

    // 7. Vignette, then calm or clear the centre.
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          radius: .95,
          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: .5)],
          stops: const [.55, 1],
        ).createShader(full),
    );
    if (menu) {
      canvas.drawRect(full, Paint()..color = Colors.black.withValues(alpha: .2));
    } else {
      canvas.drawRect(
        full,
        Paint()
          ..shader = RadialGradient(
            radius: .6,
            colors: [
              _void.withValues(alpha: .62),
              _void.withValues(alpha: .35),
              _void.withValues(alpha: 0),
            ],
            stops: const [0, .55, 1],
          ).createShader(full),
      );
    }
  }

  // ---------------------------------------------------------------- motion

  @override
  bool get hasMotion => true;

  static final Paint _mp = Paint()..strokeCap = StrokeCap.round;

  /// Twinkling stars on fixed spots plus an occasional shooting star.
  @override
  void paintMotion(Canvas canvas, Size size, double seconds) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    for (var i = 0; i < 14; i++) {
      // Spots along the edges, away from the play centre.
      final fx = (i * .6180339887 + .07) % 1.0;
      final fy = (i * .3819660113 + .13) % 1.0;
      final edgeX = (fx - .5).abs() > .3;
      final x = (edgeX ? fx : (fx < .5 ? fx * .4 : .6 + fx * .4)) * w;
      final y = fy * h;
      final tw = .5 + .5 * math.sin(seconds * (1.3 + (i % 5) * .35) + i * 2.1);
      final r = s * (.0025 + .003 * tw);
      _mp
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFDDE6FF).withValues(alpha: .12 * tw);
      canvas.drawCircle(Offset(x, y), r * 3.2, _mp);
      _mp.color = Colors.white.withValues(alpha: .35 + .55 * tw);
      canvas.drawCircle(Offset(x, y), r * .6, _mp);
      if (tw > .8) {
        _mp
          ..strokeWidth = math.max(1.0, s * .0012)
          ..color = Colors.white.withValues(alpha: (tw - .8) * 2.5);
        final l = r * 3.5;
        canvas.drawLine(Offset(x - l, y), Offset(x + l, y), _mp);
        canvas.drawLine(Offset(x, y - l), Offset(x, y + l), _mp);
      }
    }
    // Shooting star: crosses the top-left in 1.2 s every 8 s.
    const period = 8.0;
    final t = (seconds % period) / 1.2;
    if (t < 1) {
      final start = Offset(w * .05, h * .02);
      final dir = Offset(w * .55, h * .28);
      final head = start + dir * t;
      final fade = math.sin(t * math.pi);
      for (var k = 0; k < 6; k++) {
        final f = k / 6;
        final p0 = head - dir * (.05 * k);
        final p1 = head - dir * (.05 * (k + 1));
        _mp
          ..strokeWidth = math.max(1.0, s * .004 * (1 - f))
          ..color = const Color(0xFFE6F0FF).withValues(alpha: .8 * fade * (1 - f));
        canvas.drawLine(p0, p1, _mp);
      }
      _mp
        ..style = PaintingStyle.fill
        ..color = Colors.white.withValues(alpha: fade);
      canvas.drawCircle(head, s * .003, _mp);
    }
  }

  // ------------------------------------------------------------- pieces

  static void _blob(Canvas canvas, Offset c, double r, Color col, double a) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          col.withValues(alpha: a),
          col.withValues(alpha: a * .4),
          col.withValues(alpha: 0),
        ], stops: const [0, .45, 1])
            .createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  static void _nebula(Canvas canvas, Size size, Offset a, Offset b,
      math.Random rnd, double s) {
    final dir = b - a;
    final normal = Offset(-dir.dy, dir.dx) / dir.distance;
    // Broad soft body.
    for (var i = 0; i < 9; i++) {
      final t = i / 8;
      final c = Offset.lerp(a, b, t)! + normal * (math.sin(t * 5.0) * s * .12);
      _blob(canvas, c, s * (.45 + rnd.nextDouble() * .25),
          Color.lerp(_purple, _blue, rnd.nextDouble())!, .26);
    }
    // Coloured clumps.
    const cols = [_purple, _magenta, _blue, _teal, _magenta, _purple];
    for (var i = 0; i < 46; i++) {
      final t = rnd.nextDouble();
      final off = (rnd.nextDouble() - .5) * s * .5;
      final c = Offset.lerp(a, b, t)! + normal * (off + math.sin(t * 5.0) * s * .12);
      final col = cols[(t * 5 + rnd.nextDouble() * 1.5).floor() % cols.length];
      _blob(canvas, c, s * (.06 + rnd.nextDouble() * .2), col,
          .16 + rnd.nextDouble() * .2);
    }
    // Hot cores.
    for (var i = 0; i < 5; i++) {
      final t = .15 + rnd.nextDouble() * .7;
      final c = Offset.lerp(a, b, t)! + normal * (math.sin(t * 5.0) * s * .12);
      _blob(canvas, c, s * (.05 + rnd.nextDouble() * .06),
          Color.lerp(_magenta, Colors.white, .45)!, .32);
    }
    // Wispy filaments: blurred strokes (recorded once).
    final wisp = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, s * .012);
    for (var i = 0; i < 7; i++) {
      final t0 = rnd.nextDouble() * .8;
      final p0 = Offset.lerp(a, b, t0)! + normal * ((rnd.nextDouble() - .5) * s * .4);
      final p1 = p0 + dir * (.12 + rnd.nextDouble() * .15);
      final ctrl = Offset.lerp(p0, p1, .5)! + normal * ((rnd.nextDouble() - .5) * s * .3);
      wisp
        ..strokeWidth = s * (.008 + rnd.nextDouble() * .02)
        ..color = (i.isEven ? _teal : const Color(0xFFE07BE0))
            .withValues(alpha: .18 + rnd.nextDouble() * .12);
      canvas.drawPath(
          Path()
            ..moveTo(p0.dx, p0.dy)
            ..quadraticBezierTo(ctrl.dx, ctrl.dy, p1.dx, p1.dy),
          wisp);
    }
    // Dark dust lanes cut through it.
    for (var i = 0; i < 14; i++) {
      final t = rnd.nextDouble();
      final c = Offset.lerp(a, b, t)! +
          normal * ((rnd.nextDouble() - .3) * s * .2 + math.sin(t * 5.0) * s * .12);
      _blob(canvas, c, s * (.05 + rnd.nextDouble() * .12), _void, .55);
    }
  }

  static void _galaxy(Canvas canvas, Offset c, double r, double rot) {
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(rot);
    canvas.scale(1, .38);
    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawCircle(
        Offset.zero,
        r,
        Paint()
          ..shader = RadialGradient(colors: [
            const Color(0xFFFFF0E0).withValues(alpha: .7),
            const Color(0xFFB9A0FF).withValues(alpha: .28),
            _blue.withValues(alpha: .08),
            _blue.withValues(alpha: 0),
          ], stops: const [0, .18, .55, 1])
              .createShader(rect));
    // Two faint arms.
    final arm = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r * .1
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFCDB8FF).withValues(alpha: .14);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r * .55), 0, 2.4,
        false, arm);
    canvas.drawArc(Rect.fromCircle(center: Offset.zero, radius: r * .55),
        math.pi, 2.4, false, arm);
    canvas.restore();
  }

  static void _brightStar(Canvas canvas, Offset c, double r, Color col) {
    _blob(canvas, c, r, col, .35);
    final spike = Paint()..strokeCap = StrokeCap.round;
    for (var k = 0; k < 2; k++) {
      final len = r * (k == 0 ? 1.9 : 1.2);
      final ang = k == 0 ? 0.0 : math.pi / 4;
      final d = Offset(math.cos(ang), math.sin(ang)) * len;
      final e = Offset(-d.dy, d.dx);
      for (final v in [d, e]) {
        spike
          ..strokeWidth = math.max(1.0, r * (k == 0 ? .05 : .03))
          ..shader = RadialGradient(colors: [
            Colors.white.withValues(alpha: k == 0 ? .9 : .4),
            col.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: c, radius: len));
        canvas.drawLine(c - v, c + v, spike);
      }
    }
    canvas.drawCircle(c, r * .09, Paint()..color = Colors.white);
  }

  static void _planet(Canvas canvas, Offset c, double r, double s) {
    const tilt = -.32;
    final ringR = r * 2.05;
    void ring({required bool front}) {
      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(tilt);
      canvas.scale(1, .26);
      // Back half = upper half of the ellipse in local space.
      canvas.clipRect(front
          ? Rect.fromLTRB(-ringR * 1.2, 0, ringR * 1.2, ringR * 1.2)
          : Rect.fromLTRB(-ringR * 1.2, -ringR * 1.2, ringR * 1.2, 0));
      const bands = [
        (1.32, .12, Color(0xFFB8A6D9), .35),
        (1.5, .14, Color(0xFFE0C9F0), .5),
        (1.68, .06, Color(0xFF8E7FB8), .3),
        (1.83, .1, Color(0xFFD9C2E8), .42),
        (1.97, .05, Color(0xFFA48FD0), .25),
      ];
      for (final (rr, wd, col, al) in bands) {
        canvas.drawCircle(
            Offset.zero,
            r * rr,
            Paint()
              ..style = PaintingStyle.stroke
              ..strokeWidth = r * wd
              ..color = col.withValues(alpha: al * (front ? 1 : .7)));
      }
      canvas.restore();
    }

    // Atmosphere glow.
    _blob(canvas, c, r * 1.5, _purple, .25);
    ring(front: false);

    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    // Base sphere lit from the upper left.
    canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF6D4BC9), Color(0xFF8A57C8), Color(0xFF4A3A9E), Color(0xFF2B2A72)],
          ).createShader(rect));
    // Cloud bands, tilted with the ring.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(tilt);
    // Smooth banding: one gradient with many soft stops.
    final rnd = math.Random(3);
    const bandCols = [
      Color(0xFFE7C3F7),
      Color(0xFF6B4AC4),
      Color(0xFFF3D6EC),
      Color(0xFF8C63D6),
      Color(0xFF4B5BD8),
      Color(0xFFC79BEA),
    ];
    final cols = <Color>[];
    final stops = <double>[];
    for (var i = 0; i <= 16; i++) {
      stops.add(i / 16);
      cols.add(bandCols[rnd.nextInt(bandCols.length)]
          .withValues(alpha: .25 + rnd.nextDouble() * .35));
    }
    final band = Rect.fromLTRB(-r * 1.2, -r, r * 1.2, r);
    canvas.drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: cols,
            stops: stops,
          ).createShader(band));
    // A storm spot.
    canvas.drawOval(
        Rect.fromCenter(center: Offset(-r * .25, r * .32), width: r * .32, height: r * .13),
        Paint()..color = const Color(0xFFF6C9E8).withValues(alpha: .45));
    canvas.restore();
    // Terminator: dark side to the lower right.
    canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-.5, -.55),
            radius: .8,
            colors: [
              Colors.white.withValues(alpha: .16),
              Colors.transparent,
              Colors.black.withValues(alpha: .55),
              Colors.black.withValues(alpha: .9),
            ],
            stops: const [0, .3, .7, 1],
          ).createShader(rect));
    canvas.restore();
    // Rim light.
    canvas.drawArc(
        rect.deflate(r * .01),
        math.pi * .85,
        math.pi * .8,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * .025
          ..color = const Color(0xFFE6D3FF).withValues(alpha: .55));
    ring(front: true);
  }

  static void _moon(Canvas canvas, Offset c, double r) {
    _blob(canvas, c, r * 1.8, const Color(0xFF9FB6FF), .12);
    final rect = Rect.fromCircle(center: c, radius: r);
    canvas.save();
    canvas.clipPath(Path()..addOval(rect));
    canvas.drawRect(
        rect,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD9DEEA), Color(0xFF9AA3BC), Color(0xFF5E6684)],
          ).createShader(rect));
    final rnd = math.Random(9);
    for (var i = 0; i < 9; i++) {
      final p = c + Offset((rnd.nextDouble() - .5) * r * 1.6, (rnd.nextDouble() - .5) * r * 1.6);
      final cr = r * (.08 + rnd.nextDouble() * .18);
      canvas.drawCircle(p, cr, Paint()..color = const Color(0xFF4E5570).withValues(alpha: .35));
      canvas.drawArc(Rect.fromCircle(center: p, radius: cr), .2, 2.6, false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = cr * .25
            ..color = Colors.white.withValues(alpha: .18));
    }
    canvas.drawRect(
        rect,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-.5, -.5),
            radius: 1.3,
            colors: [Colors.transparent, Colors.black.withValues(alpha: .8)],
            stops: const [.45, 1],
          ).createShader(rect));
    canvas.restore();
  }

  @override
  Color get cardBase => const Color(0xC4050719);

  @override
  Color get headerBand => const Color(0xFF070A20);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFD08CFF), Color(0xFF9A6BFF), Color(0xFF5C8CFF)],
        stops: [0.0, 0.5, 1.0],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [GameConstants.spaceSnake, Color(0xFF8E63FF), GameConstants.spaceAccent],
        edge: Color(0xFFF0E2FF),
        shine: .24,
        tailFade: .3,
      );
}
