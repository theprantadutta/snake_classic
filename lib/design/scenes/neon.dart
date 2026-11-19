import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

/// Neon: electric tube signage on a dark brick wall. Glowing tube shapes
/// (a ring, a triangle, a wavy snake, bolts and chevrons) throw coloured
/// light on the wall; a perspective grid floor with a hot horizon and wet
/// reflections sits below them on menus. The board gets a double neon
/// frame, circuit traces and small signs in the corners, with a clean dark
/// centre. Generic shapes only: no lettering, logos or brands.
class NeonThemeScene extends ThemeScene {
  const NeonThemeScene();

  static const Color _cyan = GameConstants.neonSnake;
  static const Color _pink = GameConstants.neonFood;
  static const Color _lime = GameConstants.neonGlow;
  static const Color _violet = Color(0xFF8A3CFF);
  static const Color _wall = Color(0xFF07050C);

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) {
    if (menu) {
      _paintMenu(canvas, size);
    } else {
      _paintBoard(canvas, size);
    }
  }

  // ---------------------------------------------------------------- menu

  void _paintMenu(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final tall = h > w * 1.3;
    final horizon = h * (tall ? .74 : .7);
    final rnd = math.Random(11);

    _wallBase(canvas, Rect.fromLTWH(0, 0, w, horizon), s, rnd);

    // Sign positions as fractions of the size; the phone spreads them
    // down the whole wall so no band is left dead.
    // Signs hug the edges (half off-screen on phones) so the score and
    // title band in the middle stays clean (owner review, 2026-11-19).
    final ringF = tall ? const Offset(.99, .37) : const Offset(.95, .3);
    final triF = tall ? const Offset(.01, .45) : const Offset(.04, .4);
    final boltF = tall ? const Offset(.93, .56) : const Offset(.9, .62);
    final chevF = tall ? const Offset(.08, .62) : const Offset(.06, .66);
    final snakeY = h * (tall ? .42 : .55);
    final gemF = tall ? const Offset(.86, .68) : const Offset(.92, .48);
    Offset at(Offset f) => Offset(f.dx * w, f.dy * h);

    // Light spill from the signs onto the wall.
    _wash(canvas, at(ringF), s * .75, _cyan, .24);
    _wash(canvas, at(triF), s * .65, _pink, .24);
    _wash(canvas, Offset(w * .5, snakeY), s * .6, _lime, .1);
    _wash(canvas, at(gemF), s * .5, _violet, .2);

    final u = s * (tall ? 1 : .8);
    const sa = .6; // menu signs glow at 60%: ambience, not content
    final ringC = at(ringF);
    _tube(canvas, Path()..addOval(Rect.fromCircle(center: ringC, radius: u * .15)),
        _cyan, u * .011, a: sa);
    _tube(
        canvas,
        Path()
          ..addArc(Rect.fromCircle(center: ringC, radius: u * .095), -2.6, 3.6),
        _pink,
        u * .008, a: sa);
    final triC = at(triF);
    _tube(canvas, _triangle(triC, u * .14, -.12), _pink, u * .011, a: sa);
    _tube(canvas, _bolt(at(boltF), u * .09), _lime, u * .009, a: sa);
    _tube(canvas, _chevrons(at(chevF), u * .035, 3), _cyan, u * .007, a: sa);
    // A diamond with an inner diamond.
    final gc = at(gemF);
    _tube(canvas, _diamond(gc, u * .1), _violet, u * .009, a: sa);
    _tube(canvas, _diamond(gc, u * .05), _cyan, u * .006, a: sa);
        _tube(canvas, _plus(Offset(w * (tall ? .9 : .95), h * (tall ? .3 : .28)), u * .025), _pink,
        u * .006, a: sa);
    _tube(canvas, _plus(Offset(w * .55, h * (tall ? .66 : .63)), u * .02), _lime,
        u * .005, a: sa);
    // The neon snake: a wavy tube with an eye.
    final snake = _wave(Offset(w * .26, snakeY), w * .46, u * .035, 2.5);
    _tube(canvas, snake, _lime, u * .012, a: sa);
    _tube(canvas, Path()..addOval(Rect.fromCircle(
        center: Offset(w * .72 + u * .035, snakeY), radius: u * .013)),
        _lime, u * .006, a: sa);
    _sparkles(canvas, size, rnd, 40, horizon);

    // Floor.
    _floor(canvas, size, horizon, s, menu: true);
    // Wet reflections of the signs on the floor.
    _streak(canvas, Offset(ringC.dx, horizon), w * .12, (h - horizon) * .8, _cyan, .22);
    _streak(canvas, Offset(triC.dx, horizon), w * .1, (h - horizon) * .7, _pink, .2);
    _streak(canvas, Offset(w * .52, horizon), w * .2, (h - horizon) * .5, _lime, .08);

    _scanlines(canvas, size, s, .05);
    _vignette(canvas, size, .55);
    // Calm the whole thing so menu text reads.
    canvas.drawRect(Offset.zero & size,
        Paint()..color = Colors.black.withValues(alpha: .2));
  }

  // --------------------------------------------------------------- board

  void _paintBoard(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final rnd = math.Random(5);
    final full = Offset.zero & size;

    _wallBase(canvas, full, s, rnd);
    _wash(canvas, Offset(0, 0), s * .8, _cyan, .22);
    _wash(canvas, Offset(w, h), s * .8, _pink, .22);
    _wash(canvas, Offset(w, 0), s * .5, _violet, .14);
    _wash(canvas, Offset(0, h), s * .5, _lime, .08);

    // Perspective floor glimpse along the bottom edge.
    _floor(canvas, size, h * .82, s, menu: false);

    // Circuit traces from the corners.
    final trace = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, s * .003)
      ..strokeJoin = StrokeJoin.round;
    final node = Paint();
    void circuit(Offset o, double sx, double sy, Color col) {
      for (var i = 0; i < 4; i++) {
        final a = s * (.05 + i * .035);
        final len = s * (.1 + rnd.nextDouble() * .16);
        final p = Path()
          ..moveTo(o.dx + sx * a, o.dy)
          ..lineTo(o.dx + sx * a, o.dy + sy * len * .5)
          ..lineTo(o.dx + sx * (a + len * .3), o.dy + sy * (len * .8))
          ..lineTo(o.dx + sx * (a + len * .3), o.dy + sy * len);
        trace.color = col.withValues(alpha: .1);
        trace.strokeWidth = math.max(1.0, s * .009);
        canvas.drawPath(p, trace);
        trace.color = col.withValues(alpha: .5);
        trace.strokeWidth = math.max(1.0, s * .0025);
        canvas.drawPath(p, trace);
        final end = Offset(o.dx + sx * (a + len * .3), o.dy + sy * len);
        node.color = col.withValues(alpha: .25);
        canvas.drawCircle(end, s * .012, node);
        node.color = Color.lerp(col, Colors.white, .5)!.withValues(alpha: .9);
        canvas.drawCircle(end, s * .0045, node);
        // Mirror run along the other axis.
        final q = Path()
          ..moveTo(o.dx, o.dy + sy * a)
          ..lineTo(o.dx + sx * len * .5, o.dy + sy * a)
          ..lineTo(o.dx + sx * len * .8, o.dy + sy * (a + len * .3))
          ..lineTo(o.dx + sx * len, o.dy + sy * (a + len * .3));
        trace.color = col.withValues(alpha: .1);
        trace.strokeWidth = math.max(1.0, s * .009);
        canvas.drawPath(q, trace);
        trace.color = col.withValues(alpha: .45);
        trace.strokeWidth = math.max(1.0, s * .0025);
        canvas.drawPath(q, trace);
        final qe = Offset(o.dx + sx * len, o.dy + sy * (a + len * .3));
        node.color = col.withValues(alpha: .25);
        canvas.drawCircle(qe, s * .012, node);
        node.color = Color.lerp(col, Colors.white, .5)!.withValues(alpha: .9);
        canvas.drawCircle(qe, s * .0045, node);
      }
    }

    circuit(Offset.zero, 1, 1, _cyan);
    circuit(Offset(w, h), -1, -1, _pink);
    circuit(Offset(w, 0), -1, 1, _violet);
    circuit(Offset(0, h), 1, -1, _lime);

    // Small corner signs.
    _tube(canvas, Path()..addOval(Rect.fromCircle(
        center: Offset(w * .86, h * .14), radius: s * .06)),
        _cyan, s * .007, a: .8);
    _tube(canvas, _triangle(Offset(w * .14, h * .86), s * .065, .2), _pink,
        s * .007, a: .8);
    _tube(canvas, _bolt(Offset(w * .13, h * .13), s * .055), _lime, s * .006,
        a: .75);
    _tube(canvas, _chevrons(Offset(w * .8, h * .87), s * .022, 3), _pink,
        s * .005, a: .75);

    // Clean, dark centre so the snake and food pop.
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          radius: .62,
          colors: [
            Colors.black.withValues(alpha: .62),
            Colors.black.withValues(alpha: .4),
            Colors.black.withValues(alpha: 0),
          ],
          stops: const [0, .6, 1],
        ).createShader(full),
    );

    // Double neon tube frame.
    final inset = s * .022;
    final frame = RRect.fromRectAndRadius(full.deflate(inset), Radius.circular(s * .04));
    _tube(canvas, Path()..addRRect(frame), _cyan, s * .006, a: .85);
    _tube(
        canvas,
        Path()
          ..addRRect(RRect.fromRectAndRadius(
              full.deflate(inset + s * .018), Radius.circular(s * .028))),
        _pink,
        s * .0035,
        a: .55);
    _scanlines(canvas, size, s, .04);
  }

  // ---------------------------------------------------------------- motion

  @override
  bool get hasMotion => true;

  static final Paint _motionPaint = Paint();

  /// Two light pulses chase each other round the frame tube.
  @override
  void paintMotion(Canvas canvas, Size size, double seconds) {
    final s = math.min(size.width, size.height);
    final inset = s * .022;
    final r = (Offset.zero & size).deflate(inset);
    final per = 2 * (r.width + r.height);
    for (var k = 0; k < 2; k++) {
      final base = ((seconds / 9 + k * .5) % 1.0) * per;
      final col = k == 0 ? _cyan : _pink;
      for (var j = 0; j < 7; j++) {
        final d = (base - j * s * .012) % per;
        final p = _perimeterPoint(r, d);
        final f = 1 - j / 7;
        _motionPaint.color = col.withValues(alpha: .18 * f);
        canvas.drawCircle(p, s * .02 * f + s * .006, _motionPaint);
        _motionPaint.color = Colors.white.withValues(alpha: .85 * f * f);
        canvas.drawCircle(p, s * .005 * f + s * .002, _motionPaint);
      }
    }
  }

  static Offset _perimeterPoint(Rect r, double d) {
    if (d < r.width) return Offset(r.left + d, r.top);
    d -= r.width;
    if (d < r.height) return Offset(r.right, r.top + d);
    d -= r.height;
    if (d < r.width) return Offset(r.right - d, r.bottom);
    d -= r.width;
    return Offset(r.left, r.bottom - d);
  }

  // ------------------------------------------------------------- pieces

  static void _wallBase(Canvas canvas, Rect r, double s, math.Random rnd) {
    canvas.drawRect(
      r,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF040308), _wall, Color(0xFF0B0614)],
        ).createShader(r),
    );
    // Faint brick courses.
    final bh = s * .035;
    final bw = bh * 2.6;
    final mortar = Paint()
      ..color = Colors.black.withValues(alpha: .55)
      ..strokeWidth = math.max(1.0, s * .002);
    final brick = Paint();
    var row = 0;
    for (var y = r.top; y < r.bottom; y += bh, row++) {
      final off = row.isEven ? 0.0 : bw / 2;
      for (var x = r.left - off; x < r.right; x += bw) {
        brick.color = Colors.white.withValues(alpha: .012 + rnd.nextDouble() * .018);
        canvas.drawRect(Rect.fromLTWH(x, y, bw, bh), brick);
        canvas.drawLine(Offset(x, y), Offset(x, math.min(y + bh, r.bottom)), mortar);
      }
      canvas.drawLine(Offset(r.left, y), Offset(r.right, y), mortar);
    }
  }

  static void _wash(Canvas canvas, Offset c, double r, Color col, double a) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          col.withValues(alpha: a),
          col.withValues(alpha: a * .35),
          col.withValues(alpha: 0),
        ], stops: const [0, .45, 1])
            .createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  /// A glowing neon tube: wide faint halo strokes, the coloured tube, then
  /// a hot near-white core.
  static void _tube(Canvas canvas, Path p, Color col, double wd,
      {double a = 1}) {
    final pt = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    const halo = [(9.0, .035), (6.0, .06), (3.8, .11), (2.3, .22), (1.5, .45)];
    for (final (m, al) in halo) {
      pt
        ..strokeWidth = wd * m
        ..color = col.withValues(alpha: al * a);
      canvas.drawPath(p, pt);
    }
    pt
      ..strokeWidth = wd
      ..color = col.withValues(alpha: a);
    canvas.drawPath(p, pt);
    pt
      ..strokeWidth = wd * .38
      ..color = Color.lerp(col, Colors.white, .75)!.withValues(alpha: .95 * a);
    canvas.drawPath(p, pt);
  }

  static Path _triangle(Offset c, double r, double rot) {
    final p = Path();
    for (var i = 0; i < 3; i++) {
      final a = rot - math.pi / 2 + i * 2 * math.pi / 3;
      final q = c + Offset(math.cos(a), math.sin(a)) * r;
      i == 0 ? p.moveTo(q.dx, q.dy) : p.lineTo(q.dx, q.dy);
    }
    return p..close();
  }

  static Path _bolt(Offset c, double r) => Path()
    ..moveTo(c.dx + r * .25, c.dy - r)
    ..lineTo(c.dx - r * .35, c.dy + r * .1)
    ..lineTo(c.dx + r * .1, c.dy + r * .1)
    ..lineTo(c.dx - r * .25, c.dy + r)
    ..lineTo(c.dx + r * .4, c.dy - r * .2)
    ..lineTo(c.dx - r * .05, c.dy - r * .2)
    ..close();

  static Path _chevrons(Offset o, double r, int n) {
    final p = Path();
    for (var i = 0; i < n; i++) {
      final x = o.dx + i * r * 1.3;
      p
        ..moveTo(x, o.dy - r)
        ..lineTo(x + r * .8, o.dy)
        ..lineTo(x, o.dy + r);
    }
    return p;
  }

  static Path _diamond(Offset c, double r) => Path()
    ..moveTo(c.dx, c.dy - r)
    ..lineTo(c.dx + r * .75, c.dy)
    ..lineTo(c.dx, c.dy + r)
    ..lineTo(c.dx - r * .75, c.dy)
    ..close();

  static Path _plus(Offset c, double r) => Path()
    ..moveTo(c.dx - r, c.dy)
    ..lineTo(c.dx + r, c.dy)
    ..moveTo(c.dx, c.dy - r)
    ..lineTo(c.dx, c.dy + r);

  static Path _wave(Offset start, double len, double amp, double turns) {
    final p = Path()..moveTo(start.dx, start.dy);
    const steps = 60;
    for (var i = 1; i <= steps; i++) {
      final t = i / steps;
      // Tapers in from the tail so it reads as a body, not a sine.
      final env = math.min(1.0, t * 2.2);
      p.lineTo(start.dx + len * t,
          start.dy + math.sin(t * turns * 2 * math.pi) * amp * env);
    }
    return p;
  }

  static void _sparkles(
      Canvas canvas, Size size, math.Random rnd, int n, double maxY) {
    final s = math.min(size.width, size.height);
    final p = Paint();
    const tints = [_cyan, _pink, _lime, Colors.white];
    for (var i = 0; i < n; i++) {
      final c = Offset(rnd.nextDouble() * size.width, rnd.nextDouble() * maxY);
      final col = tints[rnd.nextInt(tints.length)];
      p.color = col.withValues(alpha: .15);
      canvas.drawCircle(c, s * .008, p);
      p.color = col.withValues(alpha: .7);
      canvas.drawCircle(c, s * .0022, p);
    }
  }

  static void _floor(Canvas canvas, Size size, double horizon, double s,
      {required bool menu}) {
    final w = size.width;
    final h = size.height;
    final fr = Rect.fromLTRB(0, horizon, w, h);
    canvas.drawRect(
      fr,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0726), Color(0xFF050208)],
        ).createShader(fr),
    );
    final depth = h - horizon;
    final grid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, s * .0028);
    grid.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [_cyan.withValues(alpha: .05), _cyan.withValues(alpha: .5)],
    ).createShader(fr);
    for (var k = -16; k <= 16; k++) {
      canvas.drawLine(Offset(w / 2 + k * w * .03, horizon),
          Offset(w / 2 + k * w * .19, h), grid);
    }
    grid.shader = null;
    for (var k = 1; k <= 11; k++) {
      final t = k / 11;
      final gy = horizon + depth * t * t;
      grid
        ..strokeWidth = math.max(1.0, s * .006)
        ..color = _pink.withValues(alpha: (.04 + .12 * t));
      canvas.drawLine(Offset(0, gy), Offset(w, gy), grid);
      grid
        ..strokeWidth = math.max(1.0, s * .0025)
        ..color = _pink.withValues(alpha: (.12 + .45 * t));
      canvas.drawLine(Offset(0, gy), Offset(w, gy), grid);
    }
    // Hot horizon.
    final g = Rect.fromLTRB(0, horizon - s * .06, w, horizon + s * .05);
    canvas.drawRect(
      g,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _violet.withValues(alpha: 0),
            _pink.withValues(alpha: menu ? .4 : .3),
            _pink.withValues(alpha: 0),
          ],
        ).createShader(g),
    );
    canvas.drawLine(
      Offset(0, horizon),
      Offset(w, horizon),
      Paint()
        ..strokeWidth = math.max(1.0, s * .004)
        ..color = Color.lerp(_pink, Colors.white, .5)!.withValues(alpha: .9),
    );
  }

  static void _streak(Canvas canvas, Offset top, double width, double len,
      Color col, double a) {
    final r = Rect.fromLTWH(top.dx - width / 2, top.dy, width, len);
    canvas.drawRect(
      r,
      Paint()
        ..shader = RadialGradient(
          center: Alignment.topCenter,
          radius: 1,
          colors: [col.withValues(alpha: a), col.withValues(alpha: 0)],
        ).createShader(r),
    );
  }

  static void _scanlines(Canvas canvas, Size size, double s, double a) {
    final p = Paint()
      ..color = Colors.black.withValues(alpha: a)
      ..strokeWidth = math.max(1.0, s / 500);
    final step = math.max(3.0, s / 170);
    for (var y = 0.0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  static void _vignette(Canvas canvas, Size size, double a) {
    final r = Offset.zero & size;
    canvas.drawRect(
      r,
      Paint()
        ..shader = RadialGradient(
          radius: .9,
          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: a)],
          stops: const [.55, 1],
        ).createShader(r),
    );
  }

  @override
  Color get cardBase => const Color(0xC4050309);

  @override
  Color get headerBand => const Color(0xFF07050D);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF00FFFF), Color(0xFF4FA8FF), Color(0xFFFF4FC8)],
        stops: [0.0, 0.55, 1.0],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [_cyan, Color(0xFF2E9BFF), _violet],
        edge: Color(0xFFCFFFFF),
        shine: .28,
        tailFade: .3,
      );

  @override
  Color get foodRing => _pink;
}
