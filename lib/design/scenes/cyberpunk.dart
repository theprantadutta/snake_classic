import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

/// Cyberpunk: a rainy megacity at night. A smog-lit sky, three depths of
/// towers with lit window grids, holographic magenta / yellow / cyan sign
/// panels (blank blocks, never lettering), fog between the layers, rain,
/// a glitch band and a wet street throwing the signs' colour back up.
/// Generic architecture only: no landmarks, brands or text.
class CyberpunkThemeScene extends ThemeScene {
  const CyberpunkThemeScene();

  static const Color _magenta = Color(0xFFFF2E9A);
  static const Color _yellow = GameConstants.cyberpunkFood;
  static const Color _cyan = Color(0xFF22E4FF);
  static const Color _red = GameConstants.cyberpunkSnake;
  static const Color _purple = GameConstants.cyberpunkAccent;
  static const Color _night = Color(0xFF05010D);

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final full = Offset.zero & size;
    final rnd = math.Random(menu ? 23 : 29);
    final ground = h * (menu ? .86 : .9);
    // How high the city climbs, as a fraction of the height.
    final reach = h > w * 1.3 ? .8 : .72;

    // 1. Sky: deep night down to the smog glow over the city.
    final sky = Rect.fromLTWH(0, 0, w, ground);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _night,
            Color(0xFF12042A),
            Color(0xFF2E0A48),
            Color(0xFF6A1050),
            Color(0xFF9A1A4E),
          ],
          stops: [0, .3, .55, .82, 1],
        ).createShader(sky),
    );
    // Light pollution blooms.
    _bloom(canvas, Offset(w * .3, ground - h * .15), s * .9, _magenta, .26);
    _bloom(canvas, Offset(w * .55, ground - h * reach * .55), s * .7, _purple, .16);
    _bloom(canvas, Offset(w * .8, ground - h * .25), s * .6, _purple, .2);
    _bloom(canvas, Offset(w * .6, ground - h * .05), s * .5, _cyan, .1);

    // 2. Far towers: hazy, faint windows.
    _skyline(canvas, size, rnd,
        ground: ground,
        minH: h * reach * .35,
        maxH: h * reach * .75,
        minW: s * .04,
        maxW: s * .1,
        body: const Color(0xFF2A0C46),
        windowAlpha: .35,
        windowDensity: .3,
        signs: false);
    _fog(canvas, size, ground - h * reach * .3, h * .22, const Color(0xFF7A1E66), .35);

    // 3. Mid towers with lit windows and sign panels.
    _skyline(canvas, size, rnd,
        ground: ground,
        minH: h * reach * .25,
        maxH: h * reach * .6,
        minW: s * .07,
        maxW: s * .15,
        body: const Color(0xFF14062A),
        windowAlpha: .65,
        windowDensity: .32,
        signs: true);
    _fog(canvas, size, ground - h * .08, h * .14, const Color(0xFF5A1250), .45);

    // 4. Near towers framing the edges, up past the top.
    _nearTower(canvas, size, rnd, left: true, ground: ground);
    _nearTower(canvas, size, rnd, left: false, ground: ground);

    // Air traffic: short light trails high over the city.
    final trail = Paint()..strokeCap = StrokeCap.round;
    for (var i = 0; i < 9; i++) {
      final y = h * (.08 + rnd.nextDouble() * (reach * .5));
      final x = rnd.nextDouble() * w;
      final len = s * (.04 + rnd.nextDouble() * .08);
      final col = i.isEven ? const Color(0xFFFFE9C9) : _red;
      final tr = Rect.fromLTWH(x, y - 1, len, 2);
      trail
        ..strokeWidth = math.max(1.0, s * .0025)
        ..shader = LinearGradient(colors: [
          col.withValues(alpha: 0),
          col.withValues(alpha: .7),
        ]).createShader(tr);
      canvas.drawLine(Offset(x, y), Offset(x + len, y), trail);
      trail.shader = null;
      canvas.drawCircle(Offset(x + len, y), s * .003,
          Paint()..color = col.withValues(alpha: .9));
    }

    // 5. Big floating holo billboard in the sky.
    _billboard(
        canvas,
        Rect.fromCenter(
            // Phone menus: half off the right edge beside PLAY, so it
            // never crosses the score.
            center: menu
                ? (h > w * 1.3 ? Offset(w * .98, h * .42) : Offset(w * .6, h * .2))
                : Offset(w * .7, h * .14), // top-right: the ghost score is top-left
            width: s * (menu ? .34 : .24),
            height: s * (menu ? .18 : .13)),
        s,
        _magenta);

    // 6. Wet street with reflected light.
    final st = Rect.fromLTRB(0, ground, w, h);
    canvas.drawRect(
      st,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1C0630), _night],
        ).createShader(st),
    );
    const refl = [_magenta, _cyan, _yellow, _purple, _red];
    for (var i = 0; i < 22; i++) {
      final x = rnd.nextDouble() * w;
      final rw = s * (.004 + rnd.nextDouble() * .014);
      final r = Rect.fromLTWH(
          x, ground, rw, (h - ground) * (.4 + rnd.nextDouble() * .6));
      canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              refl[i % refl.length].withValues(alpha: .32),
              refl[i % refl.length].withValues(alpha: 0),
            ],
          ).createShader(r),
      );
    }
    // Ripples across the wet street.
    final ripple = Paint()..strokeWidth = math.max(1.0, s * .0015);
    for (var i = 0; i < 18; i++) {
      final y = ground + (h - ground) * rnd.nextDouble();
      final x = rnd.nextDouble() * w;
      final rl = s * (.03 + rnd.nextDouble() * .1);
      ripple.color = Colors.white.withValues(alpha: .04 + rnd.nextDouble() * .06);
      canvas.drawLine(Offset(x, y), Offset(x + rl, y), ripple);
    }
    canvas.drawLine(
        Offset(0, ground),
        Offset(w, ground),
        Paint()
          ..strokeWidth = math.max(1.0, s * .003)
          ..color = _magenta.withValues(alpha: .55));

    // 7. Rain.
    final rain = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeWidth = math.max(1.0, s * .0018);
    for (var i = 0; i < (menu ? 260 : 200); i++) {
      final x = rnd.nextDouble() * (w + h * .2);
      final y = rnd.nextDouble() * h;
      final len = s * (.02 + rnd.nextDouble() * .05);
      rain.color = Color.lerp(Colors.white, _cyan, rnd.nextDouble())!
          .withValues(alpha: .05 + rnd.nextDouble() * .14);
      canvas.drawLine(Offset(x, y), Offset(x - len * .18, y + len), rain);
    }

    // 8. Glitch band: offset RGB slices and tight scanlines.
    final gy = h * (menu ? .42 : .3);
    final gh = s * .05;
    for (var i = 0; i < 9; i++) {
      final y = gy + rnd.nextDouble() * gh;
      final sh = s * (.002 + rnd.nextDouble() * .007);
      final x = rnd.nextDouble() * w * .7;
      final sw = w * (.1 + rnd.nextDouble() * .4);
      final col = i.isEven ? _cyan : _magenta;
      canvas.drawRect(Rect.fromLTWH(x, y, sw, sh),
          Paint()..color = col.withValues(alpha: .12 + rnd.nextDouble() * .16));
      canvas.drawRect(Rect.fromLTWH(x + s * .008, y + sh, sw * .6, sh * .5),
          Paint()..color = Colors.white.withValues(alpha: .08));
    }
    final scan = Paint()
      ..color = Colors.black.withValues(alpha: .25)
      ..strokeWidth = math.max(1.0, s / 600);
    for (var y = gy - gh * .3; y < gy + gh * 1.3; y += math.max(2.0, s / 300)) {
      canvas.drawLine(Offset(0, y), Offset(w, y), scan);
    }

    // 9. Overall scanlines + vignette.
    final lines = Paint()
      ..color = Colors.black.withValues(alpha: .06)
      ..strokeWidth = math.max(1.0, s / 520);
    for (var y = 0.0; y < h; y += math.max(3.0, s / 170)) {
      canvas.drawLine(Offset(0, y), Offset(w, y), lines);
    }
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          radius: .9,
          colors: [Colors.black.withValues(alpha: 0), Colors.black.withValues(alpha: .55)],
          stops: const [.5, 1],
        ).createShader(full),
    );

    if (menu) {
      canvas.drawRect(full, Paint()..color = Colors.black.withValues(alpha: .24));
    } else {
      canvas.drawRect(
        full,
        Paint()
          ..shader = RadialGradient(
            radius: .62,
            colors: [
              _night.withValues(alpha: .78),
              _night.withValues(alpha: .5),
              _night.withValues(alpha: 0),
            ],
            stops: const [0, .55, 1],
          ).createShader(full),
      );
    }
  }

  // ---------------------------------------------------------------- motion

  @override
  bool get hasMotion => true;

  static final Paint _rain = Paint()..strokeCap = StrokeCap.round;

  /// Falling rain: 36 streaks on fixed lanes, no allocation.
  @override
  void paintMotion(Canvas canvas, Size size, double seconds) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    _rain.strokeWidth = math.max(1.0, s * .0022);
    for (var i = 0; i < 36; i++) {
      final lane = (i * .6180339887) % 1.0;
      final speed = .55 + ((i * .37) % 1.0) * .5; // screens per second
      final len = s * (.03 + ((i * .73) % 1.0) * .04);
      final t = (seconds * speed + lane * 7.3) % 1.0;
      final y = -len + t * (h + len * 2);
      final x = lane * (w + h * .2) - t * h * .18;
      _rain.color = (i % 3 == 0 ? _cyan : Colors.white)
          .withValues(alpha: .1 + ((i * .29) % 1.0) * .14);
      canvas.drawLine(Offset(x, y), Offset(x - len * .18, y + len), _rain);
    }
  }

  // ------------------------------------------------------------- pieces

  static void _bloom(Canvas canvas, Offset c, double r, Color col, double a) {
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          col.withValues(alpha: a),
          col.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: c, radius: r)),
    );
  }

  static void _fog(Canvas canvas, Size size, double y, double band, Color col,
      double a) {
    final r = Rect.fromLTWH(0, y - band / 2, size.width, band);
    canvas.drawRect(
      r,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [col.withValues(alpha: 0), col.withValues(alpha: a), col.withValues(alpha: 0)],
        ).createShader(r),
    );
  }

  static void _skyline(
    Canvas canvas,
    Size size,
    math.Random rnd, {
    required double ground,
    required double minH,
    required double maxH,
    required double minW,
    required double maxW,
    required Color body,
    required double windowAlpha,
    required double windowDensity,
    required bool signs,
  }) {
    final w = size.width;
    final s = math.min(w, size.height);
    final paint = Paint()..color = body;
    final win = Paint();
    const tints = [Color(0xFFFFD27A), _cyan, _magenta, Color(0xFFFFF1C2)];
    var x = -minW * rnd.nextDouble();
    while (x < w) {
      final bw = minW + rnd.nextDouble() * (maxW - minW);
      final bh = minH + rnd.nextDouble() * (maxH - minH);
      final b = Rect.fromLTWH(x, ground - bh, bw, bh);
      // Stepped crown on some towers.
      final crown = Path()..addRect(b);
      if (rnd.nextDouble() < .45) {
        crown.addRect(Rect.fromLTWH(
            b.left + bw * .2, b.top - bh * .06, bw * .6, bh * .06 + 1));
        if (rnd.nextDouble() < .6) {
          canvas.drawLine(
              Offset(b.center.dx, b.top - bh * .06),
              Offset(b.center.dx, b.top - bh * .16),
              Paint()
                ..strokeWidth = math.max(1.0, s * .002)
                ..color = body);
          canvas.drawCircle(Offset(b.center.dx, b.top - bh * .16), s * .004,
              Paint()..color = _red.withValues(alpha: .9));
          canvas.drawCircle(Offset(b.center.dx, b.top - bh * .16), s * .012,
              Paint()..color = _red.withValues(alpha: .18));
        }
      }
      canvas.drawPath(crown, paint);
      // Faint lit edge facing the smog.
      canvas.drawLine(
          b.topRight,
          b.bottomRight,
          Paint()
            ..strokeWidth = math.max(1.0, s * .0015)
            ..color = _magenta.withValues(alpha: windowAlpha * .35));
      // Window grid.
      final ww = math.max(1.0, s * (signs ? .006 : .004));
      final wh = ww * 1.3;
      final tint = tints[rnd.nextInt(tints.length)];
      for (var wy = b.top + wh * 2; wy < b.bottom - wh; wy += wh * 2.2) {
        for (var wx = b.left + ww * 1.2; wx < b.right - ww * 1.5; wx += ww * 2) {
          if (rnd.nextDouble() < windowDensity) {
            win.color = (rnd.nextDouble() < .8 ? tint : tints[rnd.nextInt(4)])
                .withValues(alpha: windowAlpha * (.4 + rnd.nextDouble() * .6));
            canvas.drawRect(Rect.fromLTWH(wx, wy, ww, wh), win);
          }
        }
      }
      if (signs && rnd.nextDouble() < .5) {
        final col = [_magenta, _yellow, _cyan][rnd.nextInt(3)];
        if (rnd.nextBool()) {
          // Vertical blade sign hanging off the tower.
          final sr = Rect.fromLTWH(
              rnd.nextBool() ? b.left - s * .012 : b.right - s * .008,
              b.top + bh * (.1 + rnd.nextDouble() * .3),
              s * .02,
              bh * (.18 + rnd.nextDouble() * .2));
          _bladeSign(canvas, sr, s, col);
        } else {
          final sr = Rect.fromLTWH(b.left + bw * .12,
              b.top + bh * (.08 + rnd.nextDouble() * .25), bw * .76, bw * .32);
          _panel(canvas, sr, s, col);
        }
      }
      x += bw + s * (rnd.nextDouble() * .012);
    }
  }

  static void _nearTower(Canvas canvas, Size size, math.Random rnd,
      {required bool left, required double ground}) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final tw = s * .11;
    final x0 = left ? 0.0 : w - tw;
    final innerX = left ? tw : w - tw;
    final outerX = left ? 0.0 : w;
    // Slanted crown: higher on the outer edge.
    final topOuter = h * .03;
    final topInner = topOuter + tw * .55;
    const ink = Color(0xFF07020F);
    final body = Path()
      ..moveTo(outerX, topOuter)
      ..lineTo(innerX, topInner)
      ..lineTo(innerX, ground + 1)
      ..lineTo(outerX, ground + 1)
      ..close();
    canvas.drawPath(body, Paint()..color = ink);
    // Spire.
    canvas.drawLine(
        Offset(left ? tw * .3 : w - tw * .3, topOuter + tw * .15),
        Offset(left ? tw * .3 : w - tw * .3, topOuter - s * .05),
        Paint()
          ..strokeWidth = math.max(1.0, s * .003)
          ..color = ink);
    canvas.drawCircle(Offset(left ? tw * .3 : w - tw * .3, topOuter - s * .05),
        s * .012, Paint()..color = _red.withValues(alpha: .25));
    canvas.drawCircle(Offset(left ? tw * .3 : w - tw * .3, topOuter - s * .05),
        s * .004, Paint()..color = _red);
    // Neon trim on the slant and the inner edge.
    _neonLine(canvas, Offset(outerX, topOuter), Offset(innerX, topInner), s,
        left ? _cyan : _magenta);
    _neonLine(canvas, Offset(innerX, topInner), Offset(innerX, ground), s,
        left ? _cyan : _magenta, alpha: .55);
    // Floor bands: thin lit strips every few storeys.
    final band = Paint();
    for (var y = topInner + s * .06; y < ground - s * .02; y += s * .07) {
      band.color = (left ? _cyan : _magenta).withValues(alpha: .08);
      canvas.drawRect(Rect.fromLTRB(x0, y, x0 + tw, y + s * .006), band);
    }
    // Dim office windows.
    final win = Paint();
    for (var wy = topInner + s * .02; wy < ground - s * .02; wy += s * .024) {
      for (var k = 0; k < 4; k++) {
        if (rnd.nextDouble() < .3) {
          final wx = x0 + tw * (.1 + k * .21);
          win.color = const Color(0xFFFFD27A)
              .withValues(alpha: .12 + rnd.nextDouble() * .25);
          canvas.drawRect(Rect.fromLTWH(wx, wy, tw * .12, s * .008), win);
        }
      }
    }
    // Holo blade sign jutting from the inner face, and a round one lower.
    final sx = left ? innerX + s * .01 : innerX - s * .04;
    _bladeSign(canvas, Rect.fromLTWH(sx, h * .14, s * .03, h * .16), s,
        left ? _yellow : _magenta);
    final c = Offset(left ? innerX + s * .055 : innerX - s * .055, h * .52);
    _bloomCircle(canvas, c, s * .035, left ? _magenta : _cyan, s);
  }

  static void _neonLine(Canvas canvas, Offset a, Offset b, double s, Color col,
      {double alpha = 1}) {
    final p = Paint()..strokeCap = StrokeCap.round;
    for (final (wd, al) in [(.018, .06), (.009, .16), (.004, .5)]) {
      p
        ..strokeWidth = math.max(1.0, s * wd)
        ..color = col.withValues(alpha: al * alpha);
      canvas.drawLine(a, b, p);
    }
    p
      ..strokeWidth = math.max(1.0, s * .0018)
      ..color = Color.lerp(col, Colors.white, .7)!.withValues(alpha: alpha);
    canvas.drawLine(a, b, p);
  }

  /// A tall sign: a glowing frame with stacked blank glyph blocks.
  static void _bladeSign(Canvas canvas, Rect r, double s, Color col) {
    canvas.drawRect(r.inflate(s * .03),
        Paint()
          ..shader = RadialGradient(colors: [
            col.withValues(alpha: .25),
            col.withValues(alpha: 0),
          ]).createShader(r.inflate(s * .03)));
    canvas.drawRect(r, Paint()..color = const Color(0xFF0A0214));
    canvas.drawRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1.0, s * .0025)
          ..color = col.withValues(alpha: .9));
    final n = math.max(2, (r.height / (r.width * 1.1)).floor());
    final cell = r.height / n;
    final block = Paint()..color = col.withValues(alpha: .85);
    final glow = Paint()..color = col.withValues(alpha: .2);
    for (var i = 0; i < n; i++) {
      final br = Rect.fromLTWH(r.left + r.width * .25, r.top + i * cell + cell * .22,
          r.width * .5, cell * .56);
      canvas.drawRect(br.inflate(s * .003), glow);
      canvas.drawRect(br, block);
    }
  }

  /// A wide blank holo panel: gradient fill, frame and inner bars.
  static void _panel(Canvas canvas, Rect r, double s, Color col) {
    canvas.drawRect(
        r.inflate(s * .02),
        Paint()
          ..shader = RadialGradient(colors: [
            col.withValues(alpha: .22),
            col.withValues(alpha: 0),
          ]).createShader(r.inflate(s * .02)));
    canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [col.withValues(alpha: .55), col.withValues(alpha: .2)],
          ).createShader(r));
    final bar = Paint()..color = Colors.white.withValues(alpha: .55);
    canvas.drawRect(
        Rect.fromLTWH(r.left + r.width * .12, r.top + r.height * .3,
            r.width * .5, r.height * .14),
        bar);
    canvas.drawRect(
        Rect.fromLTWH(r.left + r.width * .12, r.top + r.height * .58,
            r.width * .3, r.height * .1),
        bar..color = Colors.white.withValues(alpha: .35));
  }

  static void _bloomCircle(Canvas canvas, Offset c, double r, Color col, double s) {
    _bloom(canvas, c, r * 2.4, col, .25);
    final p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, s * .006)
      ..color = col.withValues(alpha: .35);
    canvas.drawCircle(c, r, p);
    p
      ..strokeWidth = math.max(1.0, s * .0025)
      ..color = Color.lerp(col, Colors.white, .5)!;
    canvas.drawCircle(c, r, p);
    canvas.drawArc(Rect.fromCircle(center: c, radius: r * .6), -.6, 3.6, false, p);
  }

  /// The floating billboard: a translucent hologram with scanlines and an
  /// abstract chevron mark (no text).
  static void _billboard(Canvas canvas, Rect r, double s, Color col) {
    _bloom(canvas, r.center, r.width * .9, col, .2);
    canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              col.withValues(alpha: .35),
              _purple.withValues(alpha: .18),
              _cyan.withValues(alpha: .22),
            ],
          ).createShader(r));
    final scan = Paint()
      ..color = Colors.black.withValues(alpha: .25)
      ..strokeWidth = math.max(1.0, s * .002);
    for (var y = r.top; y < r.bottom; y += s * .006) {
      canvas.drawLine(Offset(r.left, y), Offset(r.right, y), scan);
    }
    final frame = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.0, s * .003)
      ..color = Color.lerp(col, Colors.white, .4)!.withValues(alpha: .85);
    canvas.drawRect(r, frame);
    // Corner brackets.
    final b = s * .02;
    for (final c in [r.topLeft, r.topRight, r.bottomLeft, r.bottomRight]) {
      final sx = c.dx == r.left ? -1.0 : 1.0;
      final sy = c.dy == r.top ? -1.0 : 1.0;
      final o = c + Offset(sx * s * .008, sy * s * .008);
      canvas.drawPath(
          Path()
            ..moveTo(o.dx - sx * b, o.dy)
            ..lineTo(o.dx, o.dy)
            ..lineTo(o.dx, o.dy - sy * b),
          frame..color = _yellow.withValues(alpha: .8));
    }
    // Chevron mark + bars.
    final m = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = r.height * .09
      ..strokeJoin = StrokeJoin.miter
      ..color = _yellow.withValues(alpha: .85);
    final cx = r.left + r.width * .22;
    canvas.drawPath(
        Path()
          ..moveTo(cx - r.height * .15, r.top + r.height * .25)
          ..lineTo(cx + r.height * .1, r.center.dy)
          ..lineTo(cx - r.height * .15, r.bottom - r.height * .25),
        m);
    final bar = Paint()..color = Colors.white.withValues(alpha: .7);
    canvas.drawRect(
        Rect.fromLTWH(r.left + r.width * .4, r.top + r.height * .32,
            r.width * .45, r.height * .12),
        bar);
    canvas.drawRect(
        Rect.fromLTWH(r.left + r.width * .4, r.top + r.height * .56,
            r.width * .3, r.height * .08),
        bar..color = _cyan.withValues(alpha: .7));
  }

  @override
  Color get cardBase => const Color(0xC40A0318);

  @override
  Color get headerBand => const Color(0xFF0C0320);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFF2E6E), Color(0xFFFF2E9A), Color(0xFFC84DFF)],
        stops: [0.0, 0.55, 1.0],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [_red, _magenta, _purple],
        edge: Color(0xFFFF9EC4),
        shine: .22,
        tailFade: .28,
      );

  @override
  Color get foodRing => _yellow;
}
