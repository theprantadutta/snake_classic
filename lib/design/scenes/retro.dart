import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

/// Retro: an 80s arcade cabinet screen. A plum-black night of square pixel
/// stars, a marquee horizon of stacked neon speed stripes (yellow, orange,
/// hot pink, magenta), stepped pixel mountains with a lit orange crest, a
/// receding field of pixel dots for a floor, then the CRT itself: phosphor
/// bloom, heavy scanlines, a faint RGB aperture grille and a rounded tube
/// vignette. No sun and no palms (that is Miami Nights' look).
///
/// On the board the horizon sinks to the bottom edge so the play area is
/// dark sky; stars twinkle and a CRT roll bar drifts down (a few rects).
class RetroThemeScene extends ThemeScene {
  const RetroThemeScene();

  static const Color _skyTop = Color(0xFF07040F);
  static const Color _skyMid = Color(0xFF140820);
  static const Color _skyLow = Color(0xFF3A0B2C);
  static const Color _yellow = Color(0xFFFFE23D);
  static const Color _orange = GameConstants.retroSnake;
  static const Color _pink = GameConstants.retroAccent;
  static const Color _magenta = Color(0xFFC21CFF);
  static const Color _ink = Color(0xFF0A0410);
  static const Color _ridge = Color(0xFF2C0D3E);

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final full = Offset.zero & size;
    final horizon = h * (menu ? .7 : .86);
    final px = math.max(1.0, s / (menu ? 150 : 190)); // one "pixel"
    final rnd = math.Random(80);

    // 1. Night sky, plum to a warm maroon at the horizon.
    final sky = Rect.fromLTWH(0, 0, w, horizon);
    canvas.drawRect(
      sky,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_skyTop, _skyMid, _skyLow],
          stops: [0, .6, 1],
        ).createShader(sky),
    );

    // 2. Square pixel stars on the pixel lattice, plus pixel crosses.
    final star = Paint();
    for (var i = 0; i < (menu ? 120 : 70); i++) {
      final x = (rnd.nextDouble() * w / px).floor() * px;
      final y = (math.pow(rnd.nextDouble(), 1.3) * horizon * .85 / px).floor() * px;
      final tint = rnd.nextDouble();
      star.color = (tint < .7 ? Colors.white : (tint < .85 ? _yellow : _pink))
          .withValues(alpha: .3 + rnd.nextDouble() * .5);
      final sz = rnd.nextDouble() < .8 ? px : px * 2;
      canvas.drawRect(Rect.fromLTWH(x, y, sz, sz), star);
    }
    for (var i = 0; i < (menu ? 9 : 5); i++) {
      final x = (rnd.nextDouble() * w / px).floor() * px;
      final y = (rnd.nextDouble() * horizon * .6 / px).floor() * px;
      _pixelCross(canvas, Offset(x, y), px,
          i.isEven ? Colors.white : _yellow, .85);
    }

    // 3. Phosphor bloom rising off the horizon.
    final bloom = Rect.fromLTRB(0, horizon - h * .32, w, horizon + h * .04);
    canvas.drawRect(
      bloom,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _pink.withValues(alpha: 0),
            _pink.withValues(alpha: .12),
            _orange.withValues(alpha: .3),
          ],
          stops: const [0, .65, 1],
        ).createShader(bloom),
    );
    canvas.drawCircle(
      Offset(w / 2, horizon),
      s * .7,
      Paint()
        ..shader = RadialGradient(colors: [
          _orange.withValues(alpha: .28),
          _pink.withValues(alpha: .1),
          _pink.withValues(alpha: 0),
        ], stops: const [0, .45, 1])
            .createShader(Rect.fromCircle(center: Offset(w / 2, horizon), radius: s * .7)),
    );

    // 4. Marquee: stacked neon speed stripes above the horizon, thinning
    // and spreading upward like a cabinet's side art.
    const stripeColors = [_yellow, _orange, _orange, _pink, _pink, _magenta];
    var sy = horizon;
    final sk = menu ? 1.0 : .7;
    for (var i = 0; i < stripeColors.length; i++) {
      final th = px * (3.2 - i * .45);
      sy -= th + px * (1 + i * .9);
      final r = Rect.fromLTWH(0, sy, w, th);
      canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(colors: [
            stripeColors[i].withValues(alpha: 0),
            stripeColors[i].withValues(alpha: (.75 - i * .1) * sk),
            stripeColors[i].withValues(alpha: (.85 - i * .1) * sk),
            stripeColors[i].withValues(alpha: (.75 - i * .1) * sk),
            stripeColors[i].withValues(alpha: 0),
          ], stops: const [0, .2, .5, .8, 1])
              .createShader(r),
      );
    }

    // 5. Stepped pixel mountains: a far violet range and a near black one
    // whose crest pixels are lit orange.
    _steppedRange(canvas, w, horizon, px, rnd,
        height: s * (menu ? .16 : .1),
        step: px * 2,
        color: _ridge,
        crest: _magenta.withValues(alpha: .55));
    _steppedRange(canvas, w, horizon, px, rnd,
        height: s * (menu ? .09 : .06),
        step: px * 2,
        color: _ink,
        crest: _orange.withValues(alpha: .9));

    // 6. Floor: near-black with receding rows of pixel dots.
    final floor = Rect.fromLTRB(0, horizon, w, h);
    canvas.drawRect(
      floor,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A0616), _skyTop],
        ).createShader(floor),
    );
    final depth = h - horizon;
    final dot = Paint();
    // The marquee's reflection: the stripes again, mirrored, short and
    // fading into the floor.
    var ry = horizon + px * 2;
    for (var i = 0; i < 4; i++) {
      final th = math.max(1.0, px * (1.6 - i * .3));
      final r = Rect.fromLTWH(0, ry, w, th);
      canvas.drawRect(
        r,
        Paint()
          ..shader = LinearGradient(colors: [
            stripeColors[i].withValues(alpha: 0),
            stripeColors[i].withValues(alpha: (.32 - i * .07) * sk),
            stripeColors[i].withValues(alpha: 0),
          ]).createShader(r),
      );
      ry += th + px * (2 + i * 1.6);
    }
    const rowsN = 15;
    for (var k = 1; k <= rowsN; k++) {
      final t = k / rowsN;
      final y = horizon + depth * t * t;
      final d = math.max(1.0, px * (.6 + t * t * 2.2));
      final spread = w * (.035 + t * t * .16); // rays converge on the centre
      dot.color = Color.lerp(_pink, _orange, t)!.withValues(alpha: .22 + .6 * t);
      final n = (w / 2 / spread).ceil() + 1;
      for (var j = -n; j <= n; j++) {
        canvas.drawRect(
            Rect.fromCenter(center: Offset(w / 2 + j * spread, y), width: d, height: d),
            dot);
      }
    }

    // 7. The horizon line: a white-hot core with orange either side.
    canvas.drawRect(
      Rect.fromLTWH(0, horizon - px * .5, w, px),
      Paint()..color = Color.lerp(_yellow, Colors.white, .4)!,
    );
    canvas.drawRect(
      Rect.fromLTWH(0, horizon + px * .5, w, px),
      Paint()..color = _orange.withValues(alpha: .7),
    );

    // 8. Calm the play area: a dark veil over the sky (stronger on menus,
    // where text sits; centred on the board).
    if (menu) {
      final veil = Rect.fromLTWH(0, 0, w, horizon);
      canvas.drawRect(
        veil,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withValues(alpha: .35),
              Colors.black.withValues(alpha: .3),
              Colors.black.withValues(alpha: 0),
            ],
            stops: const [0, .7, 1],
          ).createShader(veil),
      );
    } else {
      canvas.drawRect(
        full,
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, -.15),
            radius: .6,
            colors: [
              _skyTop.withValues(alpha: .55),
              _skyTop.withValues(alpha: 0),
            ],
          ).createShader(full),
      );
    }

    // 9. CRT: aperture grille (menus only: the board replays its picture
    // every frame, so it skips ~190 near-invisible lines), scanlines, tube
    // vignette, glass glint.
    if (menu) {
      final grille = Paint()..strokeWidth = math.max(.5, px * .3);
      const rgb = [Color(0xFFFF2040), Color(0xFF20FF60), Color(0xFF3060FF)];
      var gi = 0;
      for (var x = 0.0; x < w; x += px) {
        grille.color = rgb[gi++ % 3].withValues(alpha: .022);
        canvas.drawLine(Offset(x, 0), Offset(x, h), grille);
      }
    }
    final scan = Paint()
      ..color = Colors.black.withValues(alpha: menu ? .2 : .24)
      ..strokeWidth = math.max(.6, px * .45);
    for (var y = 0.0; y < h; y += px) {
      canvas.drawLine(Offset(0, y), Offset(w, y), scan);
    }
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          radius: .78,
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: .25),
            Colors.black.withValues(alpha: .7),
          ],
          stops: const [.55, .82, 1],
        ).createShader(full),
    );
    // Curved glass glint, top-left.
    final glint = Rect.fromLTWH(-w * .2, -h * .1, w * .9, h * .5);
    canvas.drawOval(
      glint,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: .045),
          Colors.white.withValues(alpha: 0),
        ]).createShader(glint),
    );
    // The tube's rounded edge: a thin dark rim with a pink inner glow.
    final rim = s * (menu ? .035 : .014);
    final tube = RRect.fromRectAndRadius(
        full.deflate(rim * .3), Radius.circular(s * (menu ? .08 : .04)));
    canvas.drawRRect(
      tube,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = rim
        ..color = Colors.black.withValues(alpha: .55),
    );
    canvas.drawRRect(
      tube.deflate(rim * .5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1, s / 500)
        ..color = _pink.withValues(alpha: menu ? .18 : .28),
    );
  }

  static void _pixelCross(Canvas c, Offset p, double px, Color color, double a) {
    final paint = Paint()..color = color.withValues(alpha: a);
    c.drawRect(Rect.fromLTWH(p.dx, p.dy, px, px), paint);
    paint.color = color.withValues(alpha: a * .55);
    c
      ..drawRect(Rect.fromLTWH(p.dx - px, p.dy, px, px), paint)
      ..drawRect(Rect.fromLTWH(p.dx + px, p.dy, px, px), paint)
      ..drawRect(Rect.fromLTWH(p.dx, p.dy - px, px, px), paint)
      ..drawRect(Rect.fromLTWH(p.dx, p.dy + px, px, px), paint);
    paint.color = color.withValues(alpha: a * .22);
    c
      ..drawRect(Rect.fromLTWH(p.dx - px * 2, p.dy, px, px), paint)
      ..drawRect(Rect.fromLTWH(p.dx + px * 2, p.dy, px, px), paint)
      ..drawRect(Rect.fromLTWH(p.dx, p.dy - px * 2, px, px), paint)
      ..drawRect(Rect.fromLTWH(p.dx, p.dy + px * 2, px, px), paint);
  }

  /// A blocky mountain range: a few overlapping peaks, quantised into
  /// columns [step] wide and heights of whole pixels, each column's top
  /// pixel lit with [crest].
  static void _steppedRange(Canvas canvas, double w, double horizon, double px,
      math.Random rnd,
      {required double height,
      required double step,
      required Color color,
      required Color crest}) {
    final peaks = <(double, double, double)>[]; // x, height, half-width
    for (var x = -w * .1; x < w * 1.1; x += w * (.16 + rnd.nextDouble() * .16)) {
      peaks.add((x, height * (.45 + rnd.nextDouble() * .55),
          w * (.1 + rnd.nextDouble() * .12)));
    }
    final body = Paint()..color = color;
    final lit = Paint()..color = crest;
    for (var x = 0.0; x < w; x += step) {
      final cx = x + step / 2;
      var level = 0.0;
      for (final (px0, ph, hw) in peaks) {
        level = math.max(level, ph * (1 - (cx - px0).abs() / hw));
      }
      final rows = (level / px).floor();
      if (rows <= 0) continue;
      final top = horizon - rows * px;
      canvas.drawRect(Rect.fromLTRB(x, top, x + step, horizon), body);
      canvas.drawRect(Rect.fromLTWH(x, top, step, px), lit);
    }
  }

  @override
  bool get hasMotion => true;

  static final Paint _twinkle = Paint();
  static final Paint _roll = Paint();

  /// Sixteen twinkling pixel stars and a CRT roll bar (19 rects).
  @override
  void paintMotion(Canvas canvas, Size size, double seconds) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final px = math.max(1.0, s / 190);
    for (var i = 0; i < 16; i++) {
      // Fixed spots from a cheap hash; brightness pulses on its own phase.
      final x = ((i * 0.3819 + .11) % 1.0) * w;
      final y = ((i * 0.6180 + .07) % 1.0) * h * .7;
      final a = math.max(0.0, math.sin(seconds * (1.1 + (i % 4) * .35) + i * 2.1));
      _twinkle.color = (i % 3 == 0 ? _yellow : Colors.white)
          .withValues(alpha: .7 * a * a);
      canvas.drawRect(
          Rect.fromLTWH((x / px).floor() * px, (y / px).floor() * px, px, px),
          _twinkle);
    }
    // Roll bar: a faint lighter band sliding down the tube every 9 s.
    final band = h * .08;
    final y = ((seconds / 9) % 1.0) * (h + band * 3) - band * 1.5;
    _roll.color = Colors.white.withValues(alpha: .012);
    canvas.drawRect(Rect.fromLTWH(0, y - band, w, band * 3), _roll);
    _roll.color = Colors.white.withValues(alpha: .018);
    canvas.drawRect(Rect.fromLTWH(0, y, w, band), _roll);
    _roll.color = Colors.white.withValues(alpha: .02);
    canvas.drawRect(Rect.fromLTWH(0, y + band * .35, w, band * .3), _roll);
  }

  @override
  Color get cardBase => const Color(0xC70D0512);

  @override
  Color get headerBand => const Color(0xFF120614);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFFFC23D), GameConstants.retroSnake, Color(0xFFFF2E6A)],
        stops: [0, .5, 1],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [
          Color(0xFFFF8A1F),
          GameConstants.retroSnake,
          Color(0xFFFF3D5A),
        ],
        edge: Color(0xFFFFD23F),
        shine: .18,
        tailFade: .22,
      );
}
