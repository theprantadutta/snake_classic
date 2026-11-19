import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/design/scenes/theme_scene.dart';

/// Classic: the brand look, as a backlit LCD panel. The original deep green
/// and lime, with what makes a handheld screen feel physical: a soft
/// backlight bloom, the fine pixel "screen door" between LCD dots, a glass
/// sheen across the top corner and a bezel shadow around the edge. Menus
/// get a ghosted pixel snake curling in from the bottom corner.
///
/// Calm on purpose: Classic is the free default and must stay the green
/// everyone knows. No motion.
class ClassicThemeScene extends ThemeScene {
  const ClassicThemeScene();

  // Panel tones, all within a step of LB.board (0xFF0D2112).
  static const Color _panelTop = Color(0xFF10291A);
  static const Color _panelMid = Color(0xFF0D2213);
  static const Color _panelLow = Color(0xFF09190D);
  static const Color _backlight = Color(0xFFB8E83A);

  @override
  void paintBackdrop(Canvas canvas, Size size, {required bool menu}) {
    final w = size.width;
    final h = size.height;
    final s = math.min(w, h);
    final full = Offset.zero & size;

    // 1. Panel base.
    canvas.drawRect(
      full,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_panelTop, _panelMid, _panelLow],
          stops: [0, .55, 1],
        ).createShader(full),
    );

    // 2. Backlight bloom: an LCD is brightest where the lamp sits.
    final glowC = Offset(w * .5, menu ? h * .36 : h * .5);
    final glowR = math.max(w, h) * (menu ? .62 : .72);
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          colors: [
            _backlight.withValues(alpha: menu ? .085 : .11),
            _backlight.withValues(alpha: menu ? .035 : .05),
            _backlight.withValues(alpha: 0),
          ],
          stops: const [0, .45, 1],
        ).createShader(Rect.fromCircle(center: glowC, radius: glowR)),
    );

    // 3. Faint lit "pixels": the dot-matrix ghosting of an old panel, on
    // the LCD's own sub-grid (5 dots per board cell).
    final cell = _cellFor(size, menu);
    final pitch = cell / 5;
    final x0 = menu ? (w % cell) / 2 : 0.0;
    final rnd = math.Random(11);
    final dot = Paint();
    final dots = menu ? 260 : 180;
    for (var i = 0; i < dots; i++) {
      final cx = x0 + (rnd.nextDouble() * w / pitch).floor() * pitch;
      final cy = (rnd.nextDouble() * h / pitch).floor() * pitch;
      dot.color = LB.lime.withValues(alpha: .025 + rnd.nextDouble() * .035);
      canvas.drawRect(
          Rect.fromLTWH(cx + pitch * .15, cy + pitch * .15, pitch * .7, pitch * .7),
          dot);
    }

    // 4. The LCD screen door: dark hairlines between the dots.
    final door = Paint()
      ..color = Colors.black.withValues(alpha: menu ? .1 : .15)
      ..strokeWidth = math.max(.5, pitch * .22);
    for (var x = x0; x <= w; x += pitch) {
      canvas.drawLine(Offset(x, 0), Offset(x, h), door);
    }
    for (var y = 0.0; y <= h; y += pitch) {
      canvas.drawLine(Offset(0, y), Offset(w, y), door);
    }

    // 5. Ghosted pixel snake (menus): curls in from the bottom-right corner
    // on the real board grid, with a gold bite ahead of it.
    if (menu) _ghostSnake(canvas, size, cell, x0);

    // 6. Glass sheen: one broad soft band and one thin bright one, falling
    // diagonally across the top-left of the panel.
    canvas.drawRect(
      full,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: menu ? .035 : .045),
            Colors.white.withValues(alpha: menu ? .045 : .055),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: 0),
            Colors.white.withValues(alpha: menu ? .03 : .04),
            Colors.white.withValues(alpha: 0),
          ],
          stops: const [0, .12, .3, .36, .39, .43],
        ).createShader(Rect.fromLTWH(0, 0, s * 1.4, s * 1.4)),
    );

    // 7. Bezel: a dark inner shadow on every edge plus corner falloff, and
    // a faint lime lip just inside it.
    final edge = s * (menu ? .07 : .09);
    final shade = Colors.black.withValues(alpha: menu ? .34 : .45);
    final clear = Colors.black.withValues(alpha: 0);
    void strip(Rect r, Alignment from, Alignment to) => canvas.drawRect(
          r,
          Paint()
            ..shader = LinearGradient(begin: from, end: to, colors: [shade, clear])
                .createShader(r),
        );
    strip(Rect.fromLTWH(0, 0, w, edge), Alignment.topCenter, Alignment.bottomCenter);
    strip(Rect.fromLTWH(0, h - edge, w, edge), Alignment.bottomCenter,
        Alignment.topCenter);
    strip(Rect.fromLTWH(0, 0, edge, h), Alignment.centerLeft, Alignment.centerRight);
    strip(Rect.fromLTWH(w - edge, 0, edge, h), Alignment.centerRight,
        Alignment.centerLeft);
    canvas.drawRect(
      full,
      Paint()
        ..shader = RadialGradient(
          radius: .9,
          colors: [clear, Colors.black.withValues(alpha: menu ? .3 : .36)],
          stops: const [.6, 1],
        ).createShader(full),
    );
    if (!menu) {
      final lip = s * .012;
      canvas.drawRRect(
        RRect.fromRectAndRadius(full.deflate(lip), Radius.circular(s * .02)),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = math.max(1, s / 400)
          ..color = LB.lime.withValues(alpha: .1),
      );
    }
  }

  /// The grid cell the screen grid uses at [size] (LB.cell x uiScale for
  /// menus; one board cell is always 20 world units on the board).
  static double _cellFor(Size size, bool menu) {
    if (!menu) return LB.cell;
    final shortest = size.shortestSide;
    final scale = shortest >= 840 ? 1.35 : (shortest >= 600 ? 1.2 : 1.0);
    return LB.cell * scale;
  }

  static const List<(int, int)> _snakeCells = [
    // Head first, in cells counted back from the bottom-right corner.
    (6, 5), (5, 5), (4, 5), (3, 5), (3, 4), (3, 3), (4, 3), (5, 3), (6, 3),
    (7, 3), (7, 2), (7, 1), (6, 1), (5, 1), (4, 1), (3, 1), (2, 1), (1, 1),
    (0, 1), (-1, 1),
  ];

  void _ghostSnake(Canvas canvas, Size size, double cell, double x0) {
    final cols = ((size.width - x0) / cell).floor();
    final rows = (size.height / cell).floor();
    Rect at(int c, int r) {
      final col = cols - 1 - c;
      final row = rows - 2 - r;
      return Rect.fromLTWH(x0 + col * cell + LB.inset, row * cell + LB.inset,
          cell - LB.inset * 2, cell - LB.inset * 2);
    }

    final paint = Paint();
    final radius = Radius.circular(LB.snakeCellRadius * cell / LB.cell);
    final n = _snakeCells.length;
    for (var i = n - 1; i >= 0; i--) {
      final (c, r) = _snakeCells[i];
      final t = i / (n - 1);
      paint.color = (i == 0 ? LB.head : LB.lime)
          .withValues(alpha: i == 0 ? .16 : .12 - .085 * t);
      canvas.drawRRect(RRect.fromRectAndRadius(at(c, r), radius), paint);
    }
    // The bite it is heading for.
    paint.color = LB.gold.withValues(alpha: .14);
    canvas.drawRRect(
        RRect.fromRectAndRadius(at(9, 5).deflate(cell * .12), radius), paint);
  }

  @override
  Color get cardBase => const Color(0xC70A1B0E);

  @override
  Color get headerBand => const Color(0xFF0B1D10);

  @override
  Gradient get primaryGradient => const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFC6EE3C), LB.lime, Color(0xFF94C40C)],
        stops: [0, .5, 1],
      );

  @override
  SnakeStyle get snakeStyle => const SnakeStyle(
        bodyGradient: [LB.lime, Color(0xFF8FC20E)],
        shine: .14,
        tailFade: .35,
      );

  @override
  bool get busyBoard => false;
}
