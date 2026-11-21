import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

/// Forest: an enchanted pine forest at night. A starry sky, a big pale
/// moon with a halo, five rows of pines receding into blue-green mist with
/// fog drifting between them, an overhanging bough, fern fronds and a
/// cluster of glowing mushrooms in the foreground, and fireflies.
///
/// Generic woodland imagery only. Soft light is gradients, never blur, so
/// replaying the cached picture stays cheap. [paintMotion] adds a few
/// drifting, pulsing fireflies.
class ForestThemeScene extends ThemeScene {
  const ForestThemeScene();

  static const Color _skyTop = Color(0xFF03070F);
  static const Color _skyMid = Color(0xFF0A1824);
  static const Color _skyLow = Color(0xFF173A44);
  static const Color _moon = Color(0xFFF4F6E6);
  static const Color _moonGlow = Color(0xFFCFE6F0);
  static const Color _fog = Color(0xFF8DBFC0);
  static const Color _ink = Color(0xFF020807);
  static const Color _firefly = Color(0xFFF6E46A);
  static const Color _fireCore = Color(0xFFFFFBD6);
  static const Color _glowShroom = Color(0xFF62F2D2);

  /// Pine rows, far to near: colour and height (fraction of the short side).
  static const List<Color> _rows = [
    Color(0xFF2A5560),
    Color(0xFF1B3F49),
    Color(0xFF102C34),
    Color(0xFF081A1F),
    Color(0xFF030C0E),
  ];

  // On phone menus the moon sits at the left edge beside the PLAY block:
  // the score and coin counter fill the top band (owner review 2026-11-19).
  static Offset _moonAt(Size size, bool menu) => menu &&
          size.height > size.width * 1.3
      ? Offset(size.width * .07, size.height * .43)
      : Offset(
          size.width * .74,
          menu
              ? math.max(size.height * .13, math.min(size.width, size.height) * .3)
              : size.height * .17);

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final rnd = math.Random(41);
    final full = Offset.zero & size;
    final light = menu ? .65 : 1.0;
    // Where the forest floor starts (rows step down toward it).
    // Tall phones give the forest more of the height, not just the width.
    final zone = menu ? math.max(s * .46, h * .3) : s * .37;
    final unit = menu ? math.max(s * .13, h * .07) : s * .13;
    final floorY = h - s * .06;
    double rowBase(int k) => floorY - zone * (1 - k / 4);

    // 1. Sky.
    canvas.drawRect(
      full,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: const [_skyTop, _skyMid, _skyLow, _skyLow],
          stops: [0, .35, (rowBase(0) / h).clamp(.5, .95), 1],
        ).createShader(full),
    );

    // 2. Stars, thinning toward the treeline.
    final star = Paint();
    for (var i = 0; i < 120; i++) {
      final y = math.pow(rnd.nextDouble(), 1.5) * rowBase(0) * .85;
      star.color = Colors.white.withValues(alpha: (.2 + rnd.nextDouble() * .6) * light);
      canvas.drawCircle(Offset(rnd.nextDouble() * w, y.toDouble()),
          s * (.0008 + rnd.nextDouble() * .0022), star);
    }

    // 3. Moon: wide halo, inner glow, disc with soft maria.
    final mc = _moonAt(size, menu);
    final mr = s * .075;
    for (final (rad, a) in [(s * .7, .13), (s * .28, .22), (mr * 1.6, .35)]) {
      canvas.drawCircle(
        mc,
        rad,
        Paint()
          ..shader = RadialGradient(colors: [
            _moonGlow.withValues(alpha: a * light),
            _moonGlow.withValues(alpha: 0),
          ]).createShader(Rect.fromCircle(center: mc, radius: rad)),
      );
    }
    final disc = Rect.fromCircle(center: mc, radius: mr);
    canvas.drawCircle(
      mc,
      mr,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.3, -.3),
          colors: [_moon, const Color(0xFFDDE3CF)],
        ).createShader(disc),
    );
    final maria = Paint()..color = const Color(0xFFB9C2AE).withValues(alpha: .28);
    for (final m in const [
      (Offset(-.32, -.12), .3),
      (Offset(-.05, -.3), .18),
      (Offset(.28, .22), .24),
      (Offset(.38, -.25), .1),
      (Offset(-.1, .42), .14),
    ]) {
      canvas.drawCircle(mc + m.$1 * mr, mr * m.$2, maria);
    }

    // 4. Thin clouds drifting across the moon.
    for (var i = 0; i < 5; i++) {
      final cy = mc.dy + s * (-.08 + i * .045 + rnd.nextDouble() * .02);
      final cw = s * (.35 + rnd.nextDouble() * .45);
      final cx = mc.dx + s * (rnd.nextDouble() - .6) * .4;
      final r = Rect.fromCenter(
          center: Offset(cx, cy), width: cw, height: s * (.025 + rnd.nextDouble() * .025));
      canvas.drawOval(
        r,
        Paint()
          ..shader = RadialGradient(colors: [
            _moonGlow.withValues(alpha: .16 * light),
            _moonGlow.withValues(alpha: .05 * light),
            _moonGlow.withValues(alpha: 0),
          ], stops: const [0, .5, 1])
              .createShader(r),
      );
    }

    // 5. Pine rows with fog between them.
    for (var k = 0; k < 5; k++) {
      final base = rowBase(k);
      final scale = .55 + k * .28;
      final paint = Paint()
        ..color = menu ? _rows[k] : Color.lerp(_rows[k], _skyTop, .22)!;
      var x = -s * .05 - rnd.nextDouble() * s * .05;
      while (x < w + s * .05) {
        final th = unit * (1 + rnd.nextDouble() * .8) * scale;
        // Near rows leave the middle open so the board centre stays calm.
        final mid = (x - w / 2).abs() < w * (.12 + k * .05);
        if (!(k >= 3 && mid)) {
          _pine(canvas, Offset(x, base + s * .01 * rnd.nextDouble()), th,
              th * (.34 + rnd.nextDouble() * .08), rnd, paint);
        }
        x += th * (.2 + rnd.nextDouble() * .22) * (k >= 3 ? 1.5 : 1);
      }
      // Ground under the row.
      canvas.drawRect(Rect.fromLTRB(0, base, w, h), paint);
      // Moonlight catching the mist above the row.
      final fogA = ((.2 - k * .03) * light + .04) * (menu ? 1 : .8);
      final band = Rect.fromLTRB(0, base - s * (.1 + k * .02), w, base + s * .05);
      canvas.drawRect(
        band,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _fog.withValues(alpha: 0),
              _fog.withValues(alpha: fogA),
              _fog.withValues(alpha: 0),
            ],
            stops: const [0, .7, 1],
          ).createShader(band),
      );
      // A brighter patch of mist under the moon.
      final patch = Rect.fromCenter(
          center: Offset(mc.dx, base - s * .03), width: w * .9, height: s * .14);
      canvas.drawOval(
        patch,
        Paint()
          ..shader = RadialGradient(colors: [
            _fog.withValues(alpha: fogA * .8),
            _fog.withValues(alpha: 0),
          ]).createShader(patch),
      );
    }

    // 6. Fireflies scattered between the trees.
    for (var i = 0; i < 46; i++) {
      final y = rowBase(0) - s * .15 + rnd.nextDouble() * (h - rowBase(0) + s * .1);
      final x = rnd.nextDouble() * w;
      if (!menu && (Offset(x, y) - Offset(w / 2, h / 2)).distance < s * .28) {
        continue;
      }
      _fireflyGlow(canvas, Offset(x, y), s * (.006 + rnd.nextDouble() * .008),
          (.45 + rnd.nextDouble() * .55) * (menu ? .75 : 1));
    }

    // 7. Foreground: ferns and glowing mushrooms in the corners.
    final fern = Paint()..color = _ink;
    final fernRim = const Color(0xFF9FD8C8).withValues(alpha: .16 * light + .04);
    for (final f in [
      (Offset(-s * .02, h + s * .02), -.25, .42),
      (Offset(s * .06, h + s * .03), .25, .34),
      (Offset(s * .02, h + s * .02), .65, .3),
      (Offset(w + s * .02, h + s * .02), .3, .44),
      (Offset(w - s * .07, h + s * .03), -.25, .32),
      (Offset(w - s * .02, h + s * .02), -.7, .28),
    ]) {
      _fernFrond(canvas, f.$1, f.$2, s * f.$3 * (menu ? 1.25 : .95), fern, fernRim,
          rnd);
    }
    _mushrooms(canvas, Offset(w * .2, h - s * .02), s, rnd, light);
    _mushrooms(canvas, Offset(w * .86, h - s * .015), s * .8, rnd, light);

    // 8. Overhanging bough across the top-left corner.
    _bough(canvas, Offset(-s * .03, s * (menu ? .2 : .06)), s * .55, .22, s,
        rnd, light);

    // 9. Vignette, a calm board centre, then the menu veil.
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
          center: Offset(w / 2, h * .52), width: w * .95, height: h * .8);
      canvas.drawOval(
        c,
        Paint()
          ..shader = RadialGradient(colors: [
            _skyTop.withValues(alpha: .55),
            _skyTop.withValues(alpha: 0),
          ]).createShader(c),
      );
    }
    canvas.drawRect(
      full,
      Paint()..color = Colors.black.withValues(alpha: menu ? .3 : .12),
    );
  }

  /// A layered pine: drooping tiers of branches around a thin trunk.
  static void _pine(Canvas canvas, Offset base, double height, double width,
      math.Random rnd, Paint paint) {
    final tiers = 7 + rnd.nextInt(4);
    final top = base.dy - height;
    final trunkH = height * .08;
    final crownH = height - trunkH;
    final left = <Offset>[];
    final right = <Offset>[];
    for (var i = 1; i <= tiers; i++) {
      final t = i / tiers;
      final y = top + crownH * t;
      final half = width / 2 * math.pow(t, .85) * (.85 + rnd.nextDouble() * .3);
      final droop = crownH / tiers * .35;
      final notch = half * (.55 + rnd.nextDouble() * .15);
      left
        ..add(Offset(base.dx - half, y + droop))
        ..add(Offset(base.dx - notch, y - crownH / tiers * .05));
      final halfR = width / 2 * math.pow(t, .85) * (.85 + rnd.nextDouble() * .3);
      right
        ..add(Offset(base.dx + halfR, y + droop))
        ..add(Offset(base.dx + halfR * (.55 + rnd.nextDouble() * .15),
            y - crownH / tiers * .05));
    }
    final path = Path()..moveTo(base.dx, top - height * .02);
    for (final p in left) {
      path.lineTo(p.dx, p.dy);
    }
    final tw = width * .06;
    path
      ..lineTo(base.dx - tw, base.dy - trunkH)
      ..lineTo(base.dx - tw, base.dy + height * .02)
      ..lineTo(base.dx + tw, base.dy + height * .02)
      ..lineTo(base.dx + tw, base.dy - trunkH);
    for (final p in right.reversed) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  static void _fireflyGlow(Canvas canvas, Offset c, double r, double a) {
    canvas.drawCircle(
      c,
      r * 4,
      Paint()
        ..shader = RadialGradient(colors: [
          _firefly.withValues(alpha: .55 * a),
          _firefly.withValues(alpha: .12 * a),
          _firefly.withValues(alpha: 0),
        ], stops: const [0, .35, 1])
            .createShader(Rect.fromCircle(center: c, radius: r * 4)),
    );
    canvas.drawCircle(c, r * .45, Paint()..color = _fireCore.withValues(alpha: a));
  }

  /// A fern frond rising from [base], leaning by [lean] radians.
  static void _fernFrond(Canvas canvas, Offset base, double lean, double len,
      Paint paint, Color rim, math.Random rnd) {
    const n = 11;
    final dir0 = Offset(math.sin(lean), -math.cos(lean));
    // The frond arches over toward its lean.
    final ctrl = base + dir0 * (len * .6);
    final tip = base + dir0 * len + Offset(math.sin(lean) * len * .35, len * .12);
    Offset at(double t) {
      final a = base * ((1 - t) * (1 - t));
      final b = ctrl * (2 * (1 - t) * t);
      final c = tip * (t * t);
      return a + b + c;
    }

    final spine = Path()..moveTo(base.dx, base.dy);
    spine.quadraticBezierTo(ctrl.dx, ctrl.dy, tip.dx, tip.dy);
    canvas.drawPath(
      spine,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = len * .016
        ..color = paint.color,
    );
    final leaves = Path();
    final rimPath = Path();
    for (var i = 2; i < n; i++) {
      final t = i / n;
      final p = at(t);
      final q = at(math.min(1, t + .02));
      final d = q - p;
      final dl = d.distance == 0 ? const Offset(0, -1) : d / d.distance;
      final nrm = Offset(-dl.dy, dl.dx);
      final ll = len * .14 * math.sin(math.pi * (.15 + t * .85)) + len * .02;
      for (final side in const [-1.0, 1.0]) {
        final out = p + nrm * (ll * side) + dl * (ll * .45);
        final c1 = p + nrm * (ll * .5 * side) + dl * (ll * .45);
        leaves
          ..moveTo(p.dx, p.dy)
          ..quadraticBezierTo(c1.dx, c1.dy, out.dx, out.dy)
          ..quadraticBezierTo(
              p.dx + nrm.dx * ll * .55 * side + dl.dx * ll * 1.0,
              p.dy + nrm.dy * ll * .55 * side + dl.dy * ll * 1.0,
              p.dx + dl.dx * ll * .35,
              p.dy + dl.dy * ll * .35)
          ..close();
        if (side < 0) {
          rimPath
            ..moveTo(p.dx, p.dy)
            ..quadraticBezierTo(c1.dx, c1.dy, out.dx, out.dy);
        }
      }
    }
    canvas.drawPath(leaves, paint);
    canvas.drawPath(
      rimPath,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, len * .004)
        ..color = rim,
    );
  }

  static void _mushrooms(
      Canvas canvas, Offset base, double s, math.Random rnd, double light) {
    // Shared ground glow under the cluster.
    final glow = Rect.fromCenter(center: base, width: s * .26, height: s * .1);
    canvas.drawOval(
      glow,
      Paint()
        ..shader = RadialGradient(colors: [
          _glowShroom.withValues(alpha: .3 * light + .05),
          _glowShroom.withValues(alpha: 0),
        ]).createShader(glow),
    );
    for (var i = 0; i < 4; i++) {
      final x = base.dx + (i - 1.5) * s * .028 + rnd.nextDouble() * s * .01;
      final hgt = s * (.02 + rnd.nextDouble() * .025);
      final cap = s * (.012 + rnd.nextDouble() * .01);
      final stem = Rect.fromLTWH(x - cap * .22, base.dy - hgt, cap * .44, hgt);
      canvas.drawRRect(RRect.fromRectAndRadius(stem, Radius.circular(cap * .2)),
          Paint()..color = const Color(0xFF9FD9C8).withValues(alpha: .55));
      final capRect = Rect.fromCenter(
          center: Offset(x, base.dy - hgt), width: cap * 2.2, height: cap * 1.6);
      canvas.drawArc(
        capRect,
        math.pi,
        math.pi,
        true,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, -.2),
            colors: [const Color(0xFFCFFFF2), _glowShroom],
          ).createShader(capRect),
      );
      canvas.drawCircle(
        Offset(x, base.dy - hgt),
        cap * 2.6,
        Paint()
          ..shader = RadialGradient(colors: [
            _glowShroom.withValues(alpha: .22 * light + .04),
            _glowShroom.withValues(alpha: 0),
          ]).createShader(
              Rect.fromCircle(center: Offset(x, base.dy - hgt), radius: cap * 2.6)),
      );
    }
  }

  /// A pine bough reaching in from the left edge: a main branch with
  /// side twigs, each wearing tufts of needles.
  static void _bough(Canvas canvas, Offset start, double len, double droop,
      double s, math.Random rnd, double light) {
    final ink = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..color = _ink;
    final rim = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, s * .0014)
      ..color = _moonGlow.withValues(alpha: .16 * light + .04);

    void tuft(Offset p, double a, double size) {
      // Needles fanning forward along the twig direction, drooping a bit.
      for (var i = 0; i < 9; i++) {
        final na = a + (i - 4) * .2 + (rnd.nextDouble() - .5) * .1;
        final nl = size * (.6 + rnd.nextDouble() * .5);
        final tip = p + Offset(math.cos(na), math.sin(na) + .35) * nl;
        ink.strokeWidth = s * .0032;
        canvas.drawLine(p, tip, ink);
        if (i < 3) canvas.drawLine(p, tip, rim);
      }
    }

    void twig(Offset from, double a, double l, double wdt, int depth) {
      final to = from + Offset(math.cos(a), math.sin(a)) * l;
      final mid = (from + to) / 2 + Offset(0, -l * .06);
      ink.strokeWidth = wdt;
      canvas.drawPath(
        Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(mid.dx, mid.dy, to.dx, to.dy),
        ink,
      );
      final steps = (l / (s * .022)).floor().clamp(2, 30);
      for (var i = 1; i <= steps; i++) {
        final t = i / steps;
        final p = Offset.lerp(from, to, t)! + Offset(0, -l * .06 * 4 * t * (1 - t));
        tuft(p, a, s * (.045 - .015 * t) * (depth == 0 ? .8 : 1));
      }
      if (depth == 0) return;
      for (var i = 1; i <= 4; i++) {
        final t = i / 5;
        final p = Offset.lerp(from, to, t)!;
        final side = i.isEven ? -1.0 : 1.0;
        twig(p, a + side * (.55 + rnd.nextDouble() * .25), l * (.35 - t * .12),
            wdt * .5, depth - 1);
      }
    }

    twig(start, math.atan2(droop, 1), len, s * .012, 1);
  }

  // Motion: ten fireflies wandering the board's edges, pulsing.
  static final Paint _mHalo = Paint();
  static final Paint _mCore = Paint();

  @override
  bool get hasMotion => true;

  @override
  void paintMotion(Canvas canvas, Size size, double seconds) {
    if (size.isEmpty) return;
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    for (var i = 0; i < 10; i++) {
      final fx = (i * .618034) % 1.0;
      final fy = (i * .414214 + .3) % 1.0;
      // Lanes along the left/right thirds and the lower band.
      final lx = fx < .5 ? fx * .5 : .75 + (fx - .5) * .5;
      final x = w * lx + math.sin(seconds * (.21 + i * .017) + i * 1.7) * s * .07;
      final y = h * (.3 + fy * .65) +
          math.cos(seconds * (.17 + i * .013) + i) * s * .05;
      final pulse = .5 + .5 * math.sin(seconds * (1.3 + i * .11) + i * 2.3);
      final a = pulse * pulse;
      final r = s * .0035;
      final c = Offset(x, y);
      _mHalo.color = _firefly.withValues(alpha: .07 * a);
      canvas.drawCircle(c, r * 6, _mHalo);
      _mHalo.color = _firefly.withValues(alpha: .18 * a);
      canvas.drawCircle(c, r * 2.6, _mHalo);
      _mCore.color = _fireCore.withValues(alpha: .95 * a);
      canvas.drawCircle(c, r, _mCore);
    }
  }

  @override
  Color get cardBase => const Color(0xC4041110);

  @override
  Color get headerBand => const Color(0xFF06120F);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF6CF5A6), GameConstants.forestSnake, Color(0xFF1C9A62)],
        stops: [0, .55, 1],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [
          GameConstants.forestSnake,
          Color(0xFF25B865),
          Color(0xFF178F57),
        ],
        edge: Color(0xFFD4FFB0),
        shine: .2,
        tailFade: .28,
      );
}
