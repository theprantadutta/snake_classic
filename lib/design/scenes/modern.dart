import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';
import 'package:snake_classic/utils/constants.dart';

/// Modern: a premium contemporary wallpaper. Deep navy with an aurora mesh
/// (soft cyan, violet, rose and teal light pooled at the edges), a silk
/// ribbon of fine lines sweeping across, frosted glass panes catching a top
/// edge of light, and a few concentric hairline rings. The board keeps the
/// light at its corners so the centre stays dark and the cyan snake and
/// coral food pop; a handful of bokeh motes drift up through it.
class ModernThemeScene extends ThemeScene {
  const ModernThemeScene();

  static const Color _navyTop = Color(0xFF0A1027);
  static const Color _navyMid = Color(0xFF0E1633);
  static const Color _navyLow = Color(0xFF080D21);
  static const Color _cyan = Color(0xFF3FC8FF);
  static const Color _violet = Color(0xFF7A5CFF);
  static const Color _rose = Color(0xFFFF5F8F);
  static const Color _teal = Color(0xFF2FE0C2);

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final big = math.max(w, h);
    final full = Offset.zero & size;

    // 1. Navy base.
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_navyTop, _navyMid, _navyLow],
          stops: [0, .5, 1],
        ).createShader(full),
    );

    // 2. Aurora mesh: elliptical radial pools of light.
    final k = menu ? 1.0 : .85;
    if (menu) {
      _blob(canvas, Offset(w * .05, h * .08), big * .6, .55, -.5, _cyan, .55 * k);
      _blob(canvas, Offset(w * 1.02, h * .36), big * .55, .6, .4, _violet, .6 * k);
      _blob(canvas, Offset(w * .0, h * .74), big * .45, .55, .3, _rose, .4 * k);
      _blob(canvas, Offset(w * 1.0, h * 1.0), big * .5, .6, -.3, _teal, .36 * k);
      _blob(canvas, Offset(w * .45, h * .55), big * .32, .5, .2, _violet, .16);
    } else {
      _blob(canvas, Offset(0, 0), s * .9, .7, -.6, _cyan, .55);
      _blob(canvas, Offset(w, h * .2), s * .75, .65, .5, _violet, .55);
      _blob(canvas, Offset(w * .1, h), s * .75, .6, .4, _rose, .38);
      _blob(canvas, Offset(w, h), s * .8, .6, -.4, _teal, .34);
    }

    // 3. Concentric hairline rings around the cyan pool.
    final ringC = menu ? Offset(w * .86, h * .17) : Offset(w * .9, h * .12);
    final ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(.6, s / 600);
    for (var i = 1; i <= 6; i++) {
      ring.color = Colors.white.withValues(alpha: .07 - i * .008);
      canvas.drawCircle(ringC, s * (.09 + i * .075), ring);
    }

    // 4. Glass panes: frosted rounded slabs, lit along the top edge.
    if (menu) {
      _glass(canvas, Rect.fromLTWH(w - s * .5, h * .02, s * .62, s * .8), -.26, s);
      _glass(canvas, Rect.fromLTWH(w - s * .38, h - s * .5, s * .6, s * .5), .2, s);
    } else {
      _glass(canvas, Rect.fromLTWH(w * .68, -s * .12, s * .5, s * .42), -.3, s);
      _glass(canvas, Rect.fromLTWH(-s * .14, h * .74, s * .46, s * .4), .22, s);
    }

    // 5. Silk ribbon: fine parallel curves, cyan to violet, sweeping across
    // (kept to the lower third on the board, away from the play centre).
    final ribbonRect = full;
    final silk = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(.6, s / 520)
      ..shader = LinearGradient(colors: [
        _cyan.withValues(alpha: 0),
        _cyan.withValues(alpha: .5),
        _violet.withValues(alpha: .45),
        _rose.withValues(alpha: 0),
      ], stops: const [0, .3, .7, 1])
          .createShader(ribbonRect);
    final base = menu ? h * .8 : h * .84;
    final amp = menu ? h * .06 : h * .08;
    for (var i = 0; i < 14; i++) {
      final o = i * s * .011;
      final path = Path()
        ..moveTo(-w * .05, base + amp * .9 + o)
        ..cubicTo(w * .3, base - amp * 1.4 + o * 1.6, w * .62, base + amp * 1.3 - o,
            w * 1.05, base - amp * .8 + o * .5);
      canvas.drawPath(path, silk);
    }

    // 6. A sprinkle of tiny stars/motes so the navy has depth.
    final rnd = math.Random(23);
    final mote = Paint();
    for (var i = 0; i < (menu ? 46 : 26); i++) {
      final p = Offset(rnd.nextDouble() * w, rnd.nextDouble() * h);
      mote.color = (rnd.nextBool() ? Colors.white : _cyan)
          .withValues(alpha: .12 + rnd.nextDouble() * .25);
      canvas.drawCircle(p, s * (.0015 + rnd.nextDouble() * .0025), mote);
    }

    // 7. Board: a dark well in the centre so the play area stays clean.
    if (!menu) {
      canvas.drawRect(
        full,
        Paint()
          ..shader = RadialGradient(
            radius: .62,
            colors: [
              _navyLow.withValues(alpha: .72),
              _navyLow.withValues(alpha: .35),
              _navyLow.withValues(alpha: 0),
            ],
            stops: const [0, .6, 1],
          ).createShader(full),
      );
    }

    // 8. Soft vignette, plus an extra veil on menus so text reads.
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          radius: .95,
          colors: [
            Colors.black.withValues(alpha: 0),
            Colors.black.withValues(alpha: .38),
          ],
          stops: const [.55, 1],
        ).createShader(full),
    );
    if (menu) {
      canvas.drawRect(full, Paint()..color = _navyLow.withValues(alpha: .1));
    }
  }

  /// An elliptical pool of [color] light ([squash] = minor/major axis).
  static void _blob(Canvas canvas, Offset c, double r, double squash,
      double angle, Color color, double alpha) {
    canvas
      ..save()
      ..translate(c.dx, c.dy)
      ..rotate(angle)
      ..scale(1, squash);
    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          color.withValues(alpha: alpha),
          color.withValues(alpha: alpha * .45),
          color.withValues(alpha: alpha * .12),
          color.withValues(alpha: 0),
        ], stops: const [0, .35, .7, 1])
            .createShader(rect),
    );
    canvas.restore();
  }

  /// A frosted glass slab rotated by [angle] about its centre.
  static void _glass(Canvas canvas, Rect r, double angle, double s) {
    canvas
      ..save()
      ..translate(r.center.dx, r.center.dy)
      ..rotate(angle);
    final local = Rect.fromCenter(center: Offset.zero, width: r.width, height: r.height);
    final rr = RRect.fromRectAndRadius(local, Radius.circular(s * .06));
    canvas.drawRRect(
      rr,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: .075),
            Colors.white.withValues(alpha: .02),
            Colors.white.withValues(alpha: .005),
          ],
          stops: const [0, .5, 1],
        ).createShader(local),
    );
    canvas.drawRRect(
      rr.deflate(.5),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(.8, s / 450)
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withValues(alpha: .28),
            Colors.white.withValues(alpha: .06),
            Colors.white.withValues(alpha: .02),
          ],
          stops: const [0, .35, 1],
        ).createShader(local),
    );
    canvas.restore();
  }

  @override
  bool get hasMotion => true;

  static final Paint _motePaint = Paint();

  /// Fourteen bokeh motes rising slowly, each with a soft halo ring.
  @override
  void paintMotion(Canvas canvas, Size size, double seconds) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    for (var i = 0; i < 14; i++) {
      final speed = .012 + (i % 5) * .004; // fraction of height per second
      final y = h * (1.1 - ((seconds * speed + i * .173) % 1.0) * 1.2);
      final x = w * ((i * .618 + .07) % 1.0) +
          math.sin(seconds * .4 + i) * s * .02;
      final pulse = .5 + .5 * math.sin(seconds * .9 + i * 1.7);
      final r = s * (.004 + (i % 3) * .003);
      final color = i.isEven ? _cyan : _violet;
      _motePaint.color = color.withValues(alpha: .06 + .06 * pulse);
      canvas.drawCircle(Offset(x, y), r * 3, _motePaint);
      _motePaint.color = color.withValues(alpha: .25 + .3 * pulse);
      canvas.drawCircle(Offset(x, y), r, _motePaint);
    }
  }

  @override
  Color get cardBase => const Color(0xC20A1028);

  @override
  Color get headerBand => const Color(0xFF0B1230);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF5FE0FF), GameConstants.modernSnake, Color(0xFF8C7CFF)],
        stops: [0, .45, 1],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [GameConstants.modernSnake, Color(0xFF6F8CFF), _violet],
        shine: .2,
        tailFade: .3,
      );

  @override
  bool get busyBoard => false;
}
