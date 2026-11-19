import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

/// Crystal: an amethyst geode cave. Faceted crystal clusters (amethyst,
/// ice and rose quartz) grow from the floor and hang from the ceiling,
/// each prism shaded facet by facet with lit ridges and glowing tips.
/// Pale light falls in from above and splits into a faint prism fan; dust
/// glitters in the beams. The board keeps the clusters in its corners and
/// twinkles a few tips.
class CrystalThemeScene extends ThemeScene {
  const CrystalThemeScene();

  static const Color _deep = Color(0xFF07020F);
  static const Color _rock = Color(0xFF0B0418);

  // (dark, mid, light) facet tones per crystal family.
  static const _amethyst = (Color(0xFF2A0B52), Color(0xFF7234C2), Color(0xFFC9A2FF));
  static const _ice = (Color(0xFF15305E), Color(0xFF4F9BE0), Color(0xFFD2F2FF));
  static const _rose = (Color(0xFF4A0A3C), Color(0xFFC23C8F), Color(0xFFFFB3DD));

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final full = Offset.zero & size;
    final rnd = math.Random(menu ? 61 : 67);
    final tall = h > w * 1.3;

    // 1. Cave depth: violet glow in the middle, near black at the walls.
    canvas.drawRect(
      full,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(0, -.1),
          radius: 1.0,
          colors: [Color(0xFF3E1470), Color(0xFF240A48), Color(0xFF12052A), _deep],
          stops: [0, .35, .7, 1],
        ).createShader(full),
    );
    // Coloured spill from the clusters.
    _glow(canvas, Offset(0, h), s * .9, const Color(0xFF8A3CFF), .3);
    _glow(canvas, Offset(w, h), s * .8, const Color(0xFFFF4D9E), .2);
    _glow(canvas, Offset(w, 0), s * .6, const Color(0xFF5AB8FF), .18);
    _glow(canvas, Offset(0, 0), s * .5, const Color(0xFF9A5CFF), .16);

    // 2. Light falling in from above.
    _rays(canvas, size, Offset(w * .38, -h * .05), s, rnd, menu ? .7 : .55);

    // 3. Cave rock along the floor and ceiling.
    _rockEdge(canvas, size, rnd, top: false, depth: s * (tall ? .14 : .12));
    _rockEdge(canvas, size, rnd, top: true, depth: s * .08);

    // 4. Crystal clusters.
    final tips = <Offset>[];
    if (menu) {
      final k = tall ? 1.0 : .8;
      _cluster(canvas, Offset(w * .02, h + s * .02), s * .62 * k, .5, 9, rnd,
          _amethyst, tips);
      _cluster(canvas, Offset(w * 1.0, h + s * .03), s * .55 * k, -.55, 8, rnd,
          _rose, tips, mix: _amethyst);
      _cluster(canvas, Offset(w * .5, h + s * .06), s * .26 * k, 0, 5, rnd,
          _ice, tips, mix: _amethyst);
      _cluster(canvas, Offset(w * .95, -s * .02), s * .34 * k, math.pi + .4, 6,
          rnd, _ice, tips);
      _cluster(canvas, Offset(w * .1, -s * .02), s * .24 * k, math.pi - .4, 5,
          rnd, _amethyst, tips, mix: _ice);
      if (tall) {
        _cluster(canvas, Offset(-s * .03, h * .5), s * .2, 1.25, 4, rnd, _amethyst,
            tips, mix: _rose);
        _cluster(canvas, Offset(w + s * .03, h * .38), s * .18, -1.25, 4, rnd, _ice,
            tips);
        _cluster(canvas, Offset(-s * .03, h * .24), s * .15, 1.6, 3, rnd, _ice,
            tips, mix: _amethyst);
        _cluster(canvas, Offset(w + s * .03, h * .64), s * .2, -1.4, 4, rnd,
            _amethyst, tips, mix: _rose);
      }
    } else {
      _cluster(canvas, Offset(-s * .02, h + s * .02), s * .36, .7, 8, rnd,
          _amethyst, tips);
      _cluster(canvas, Offset(w + s * .02, h + s * .02), s * .32, -.7, 7, rnd,
          _rose, tips, mix: _amethyst);
      _cluster(canvas, Offset(w + s * .02, -s * .02), s * .3, math.pi + .7, 6,
          rnd, _ice, tips);
      _cluster(canvas, Offset(-s * .02, -s * .02), s * .24, math.pi - .7, 5,
          rnd, _amethyst, tips, mix: _ice);
    }

    // 5. Glints on the tips, glitter in the air.
    for (var i = 0; i < tips.length; i++) {
      if (i % 2 == 0) _sparkle(canvas, tips[i], s * (.012 + rnd.nextDouble() * .014), .9);
    }
    final mote = Paint();
    for (var i = 0; i < (menu ? 70 : 45); i++) {
      final p = Offset(rnd.nextDouble() * w, rnd.nextDouble() * h);
      final r = s * (.001 + rnd.nextDouble() * .003);
      mote.color = [Colors.white, const Color(0xFFD9C4FF), const Color(0xFFBDEBFF)][i % 3]
          .withValues(alpha: .25 + rnd.nextDouble() * .5);
      canvas.drawCircle(p, r, mote);
      if (i % 9 == 0) _sparkle(canvas, p, s * .01, .6);
    }

    // 6. Vignette, then calm or clear the centre.
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          radius: .95,
          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: .45)],
          stops: const [.6, 1],
        ).createShader(full),
    );
    if (menu) {
      canvas.drawRect(full, Paint()..color = Colors.black.withValues(alpha: .16));
    } else {
      canvas.drawRect(
        full,
        Paint()
          ..shader = RadialGradient(
            radius: .58,
            colors: [
              _deep.withValues(alpha: .62),
              _deep.withValues(alpha: .35),
              _deep.withValues(alpha: 0),
            ],
            stops: const [0, .55, 1],
          ).createShader(full),
      );
    }
  }

  // ---------------------------------------------------------------- motion

  @override
  bool get hasMotion => true;

  static final Paint _mp = Paint();

  // Fractional spots near the corner clusters.
  static const List<(double, double)> _glints = [
    (.08, .8), (.2, .9), (.14, .7), (.3, .95),
    (.9, .82), (.8, .92), (.86, .7),
    (.9, .14), (.8, .06), (.1, .1), (.18, .05),
  ];

  /// A few four-point glints swell and fade on the crystals.
  @override
  void paintMotion(Canvas canvas, Size size, double seconds) {
    final s = math.min(size.width, size.height);
    for (var i = 0; i < _glints.length; i++) {
      final (fx, fy) = _glints[i];
      final ph = (seconds * .45 + i * .37) % 1.0;
      if (ph > .35) continue;
      final k = math.sin(ph / .35 * math.pi);
      final c = Offset(fx * size.width, fy * size.height);
      final r = s * .022 * k;
      _mp.color = Colors.white.withValues(alpha: .18 * k);
      canvas.drawCircle(c, r * .7, _mp);
      _mp.color = Colors.white.withValues(alpha: .95 * k);
      // Four-point star from two thin diamonds; no Path allocation.
      canvas.drawRect(Rect.fromCenter(center: c, width: r * 2, height: r * .1), _mp);
      canvas.drawRect(Rect.fromCenter(center: c, width: r * .1, height: r * 2), _mp);
      canvas.drawCircle(c, r * .14, _mp);
    }
  }

  // ------------------------------------------------------------- pieces

  static void _glow(Canvas canvas, Offset c, double r, Color col, double a) {
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

  static void _rays(Canvas canvas, Size size, Offset src, double s,
      math.Random rnd, double a) {
    final h = size.height;
    for (var i = 0; i < 6; i++) {
      final ang = math.pi / 2 + (-.35 + i * .14) + (rnd.nextDouble() - .5) * .06;
      final len = h * 1.1;
      final spread = .025 + rnd.nextDouble() * .04;
      final p1 = src + Offset(math.cos(ang - spread), math.sin(ang - spread)) * len;
      final p2 = src + Offset(math.cos(ang + spread), math.sin(ang + spread)) * len;
      final path = Path()
        ..moveTo(src.dx, src.dy)
        ..lineTo(p1.dx, p1.dy)
        ..lineTo(p2.dx, p2.dy)
        ..close();
      final bounds = path.getBounds();
      canvas.drawPath(
          path,
          Paint()
            ..shader = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFEBDDFF).withValues(alpha: (.1 + rnd.nextDouble() * .06) * a),
                const Color(0xFFB98CFF).withValues(alpha: .04 * a),
                const Color(0xFFB98CFF).withValues(alpha: 0),
              ],
              stops: const [0, .5, 1],
            ).createShader(bounds));
    }
    // Prism fan: the light split into a faint spectrum.
    const spectrum = [
      Color(0xFFFF5A7A),
      Color(0xFFFFB35A),
      Color(0xFFFFF27A),
      Color(0xFF6CFFB0),
      Color(0xFF5AC8FF),
      Color(0xFF9A7BFF),
    ];
    final o = Offset(size.width * .62, h * .16);
    for (var i = 0; i < spectrum.length; i++) {
      final a0 = .35 + i * .055;
      final len = s * .9;
      final path = Path()
        ..moveTo(o.dx, o.dy)
        ..lineTo(o.dx + math.cos(a0) * len, o.dy + math.sin(a0) * len)
        ..lineTo(o.dx + math.cos(a0 + .05) * len, o.dy + math.sin(a0 + .05) * len)
        ..close();
      canvas.drawPath(
          path,
          Paint()
            ..shader = RadialGradient(colors: [
              spectrum[i].withValues(alpha: .16 * a),
              spectrum[i].withValues(alpha: 0),
            ]).createShader(Rect.fromCircle(center: o, radius: len)));
    }
    _glow(canvas, o, s * .05, Colors.white, .35 * a);
  }

  static void _rockEdge(Canvas canvas, Size size, math.Random rnd,
      {required bool top, required double depth}) {
    final w = size.width;
    final h = size.height;
    final edgeY = top ? 0.0 : h;
    final dir = top ? 1.0 : -1.0;
    final path = Path()..moveTo(0, edgeY);
    var x = 0.0;
    final pts = <Offset>[];
    while (x <= w + depth) {
      final y = edgeY + dir * depth * (.25 + rnd.nextDouble() * .75);
      pts.add(Offset(x, y));
      path.lineTo(x, y);
      x += depth * (.4 + rnd.nextDouble() * .8);
    }
    path
      ..lineTo(w + depth, edgeY)
      ..close();
    final b = Rect.fromLTRB(0, top ? 0 : h - depth, w, top ? depth : h);
    canvas.drawPath(
        path,
        Paint()
          ..shader = LinearGradient(
            begin: top ? Alignment.bottomCenter : Alignment.topCenter,
            end: top ? Alignment.topCenter : Alignment.bottomCenter,
            colors: const [Color(0xFF1E0B36), _rock],
          ).createShader(b));
    final rim = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (final p in pts.skip(1)) {
      rim.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
        rim,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, depth * .03)
          ..color = const Color(0xFF8E5CD6).withValues(alpha: .16));
  }

  /// A fan of [n] crystals rooted near [base], pointing along [angle]
  /// (0 = straight up, radians clockwise).
  static void _cluster(
    Canvas canvas,
    Offset base,
    double size,
    double angle,
    int n,
    math.Random rnd,
    (Color, Color, Color) tones,
    List<Offset> tips, {
    (Color, Color, Color)? mix,
  }) {
    _glow(canvas, base, size * 1.1, tones.$2, .22);
    // Back to front: small ones behind, the big one in front.
    final order = List<int>.generate(n, (i) => i)..shuffle(rnd);
    for (final i in order) {
      final t = n == 1 ? .5 : i / (n - 1);
      final a = angle + (t - .5) * 1.1 + (rnd.nextDouble() - .5) * .2;
      final central = 1 - (t - .5).abs() * 1.4;
      final len = size * (.35 + central * .55 + rnd.nextDouble() * .15);
      final wd = len * (.2 + rnd.nextDouble() * .08);
      final root = base +
          Offset((rnd.nextDouble() - .5) * size * .35,
              (rnd.nextDouble() - .5) * size * .12);
      final fam = (mix != null && rnd.nextDouble() < .35) ? mix : tones;
      final tip = _crystal(canvas, root, a, len, wd, fam);
      tips.add(tip);
    }
  }

  /// One hexagonal prism seen from the side. Returns the tip position.
  static Offset _crystal(Canvas canvas, Offset root, double angle, double len,
      double wd, (Color, Color, Color) tones) {
    final (dark, mid, light) = tones;
    final tip = wd * .95;
    final x0 = -wd / 2, x1 = -wd * .14, x2 = wd * .24, x3 = wd / 2;
    final yo = -len, yi = -len - tip * .28;
    final tp = Offset(wd * .03, -len - tip);

    canvas.save();
    canvas.translate(root.dx, root.dy);
    canvas.rotate(angle);

    final body = Rect.fromLTRB(x0, -len - tip, x3, 0);
    Paint facet(Color bottom, Color top) => Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [bottom.withValues(alpha: .95), top.withValues(alpha: .92)],
      ).createShader(body);

    Path quad(Offset a, Offset b, Offset c, Offset d) => Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..lineTo(d.dx, d.dy)
      ..close();
    Path tri(Offset a, Offset b, Offset c) => Path()
      ..moveTo(a.dx, a.dy)
      ..lineTo(b.dx, b.dy)
      ..lineTo(c.dx, c.dy)
      ..close();

    // Soft glow around the prism.
    canvas.drawRect(
        body.inflate(wd * .6),
        Paint()
          ..shader = RadialGradient(colors: [
            mid.withValues(alpha: .22),
            mid.withValues(alpha: 0),
          ]).createShader(body.inflate(wd * .6)));

    // Lit side (left), face (centre), shadow side (right).
    canvas.drawPath(quad(Offset(x0, 0), Offset(x1, 0), Offset(x1, yi), Offset(x0, yo)),
        facet(Color.lerp(dark, mid, .5)!, light));
    canvas.drawPath(quad(Offset(x1, 0), Offset(x2, 0), Offset(x2, yi), Offset(x1, yi)),
        facet(dark, Color.lerp(mid, light, .45)!));
    canvas.drawPath(quad(Offset(x2, 0), Offset(x3, 0), Offset(x3, yo), Offset(x2, yi)),
        facet(Color.lerp(dark, Colors.black, .4)!, Color.lerp(dark, mid, .6)!));
    // Tip facets.
    canvas.drawPath(tri(Offset(x0, yo), Offset(x1, yi), tp),
        Paint()..color = Color.lerp(light, Colors.white, .35)!.withValues(alpha: .95));
    canvas.drawPath(tri(Offset(x1, yi), Offset(x2, yi), tp),
        Paint()..color = Color.lerp(mid, light, .7)!.withValues(alpha: .95));
    canvas.drawPath(tri(Offset(x2, yi), Offset(x3, yo), tp),
        Paint()..color = Color.lerp(dark, mid, .7)!.withValues(alpha: .95));

    // Inner refraction streak on the face.
    final streak = Rect.fromLTRB(x1 + (x2 - x1) * .3, -len * .85, x1 + (x2 - x1) * .45, -len * .1);
    canvas.drawRect(
        streak,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white.withValues(alpha: .35), Colors.white.withValues(alpha: 0)],
          ).createShader(streak));

    // Light caught inside, just under the tip.
    final core = Offset(x1 + (x2 - x1) * .5, -len * .9);
    canvas.drawCircle(
        core,
        wd * .7,
        Paint()
          ..shader = RadialGradient(colors: [
            Color.lerp(light, Colors.white, .5)!.withValues(alpha: .4),
            light.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: core, radius: wd * .7)));

    // Ridges and outline.
    final ridge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(.8, wd * .025)
      ..strokeJoin = StrokeJoin.round;
    ridge.color = Colors.white.withValues(alpha: .55);
    canvas.drawPath(
        Path()
          ..moveTo(x1, 0)
          ..lineTo(x1, yi)
          ..lineTo(tp.dx, tp.dy),
        ridge);
    ridge.color = Colors.white.withValues(alpha: .22);
    canvas.drawPath(
        Path()
          ..moveTo(x2, 0)
          ..lineTo(x2, yi)
          ..lineTo(tp.dx, tp.dy)
          ..moveTo(x0, yo)
          ..lineTo(x1, yi)
          ..lineTo(x2, yi)
          ..lineTo(x3, yo),
        ridge);
    ridge.color = Color.lerp(dark, Colors.black, .5)!.withValues(alpha: .7);
    canvas.drawPath(
        Path()
          ..moveTo(x0, 0)
          ..lineTo(x0, yo)
          ..lineTo(tp.dx, tp.dy)
          ..lineTo(x3, yo)
          ..lineTo(x3, 0),
        ridge);
    canvas.restore();

    // Tip position in canvas space.
    final ca = math.cos(angle), sa = math.sin(angle);
    return root + Offset(tp.dx * ca - tp.dy * sa, tp.dx * sa + tp.dy * ca);
  }

  static void _sparkle(Canvas canvas, Offset c, double r, double a) {
    _glow(canvas, c, r * 1.6, Colors.white, .3 * a);
    final p = Path()
      ..moveTo(c.dx, c.dy - r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx + r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy + r)
      ..quadraticBezierTo(c.dx, c.dy, c.dx - r, c.dy)
      ..quadraticBezierTo(c.dx, c.dy, c.dx, c.dy - r)
      ..close();
    canvas.drawPath(p, Paint()..color = Colors.white.withValues(alpha: a));
  }

  @override
  Color get cardBase => const Color(0xC40C0420);

  @override
  Color get headerBand => const Color(0xFF12052A);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE6FBFF), Color(0xFFB0E0F0), Color(0xFFC9A2FF)],
        stops: [0.0, 0.5, 1.0],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [
          Color(0xFFE2FAFF),
          GameConstants.crystalSnake,
          Color(0xFFA9B4FF),
        ],
        edge: Colors.white,
        shine: .3,
        tailFade: .28,
      );

  @override
  Color get foodRing => GameConstants.crystalFood;
}
