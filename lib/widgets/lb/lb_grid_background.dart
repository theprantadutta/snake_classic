import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/design/scenes/scenes.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';

/// The board every screen sits on (DESIGN_SPEC §3): the palette's board
/// colour with 1 dp grid lines every [LB.cell] (scaled on tablets).
///
/// The grid is painted once into its own layer, so a screen animating above
/// it never repaints the lines.
class LBGridBackground extends StatelessWidget {
  const LBGridBackground({super.key, required this.child, this.color});

  final Widget child;

  /// Board colour override (e.g. the gameplay board's deeper tone).
  final Color? color;

  /// Whether the board behind a screen is a painted theme scene rather
  /// than the flat palette board colour.
  static bool paintsScene(BuildContext context) =>
      ThemeScenes.ofPalette(context.lb) != null;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    final cell = LB.cell * context.uiScale;
    // Themes with a scene paint it behind the grid instead of the flat
    // board colour (screens that pass their own colour keep it).
    final sceneTheme = color == null ? ThemeScenes.themeOfPalette(p) : null;
    if (sceneTheme != null && ThemeScenes.of(sceneTheme) != null) {
      return CustomPaint(
        painter: _ScenePainter(sceneTheme),
        isComplex: true,
        willChange: false,
        child: CustomPaint(
          painter: _GridPainter(cell: cell, color: p.gridLine),
          isComplex: true,
          willChange: false,
          child: child,
        ),
      );
    }
    return ColoredBox(
      color: color ?? p.board,
      child: CustomPaint(
        painter: _GridPainter(cell: cell, color: p.gridLine),
        isComplex: true,
        willChange: false,
        child: child,
      ),
    );
  }
}

extension LBLayout on BuildContext {
  /// The grid cell size on this device ([LB.cell] × uiScale).
  double get lbCell => LB.cell * uiScale;

  /// Horizontal content padding that puts content edges on a grid line one
  /// cell in from the screen edge (DESIGN_SPEC §2), centred and capped on
  /// tablets via [sideInset].
  double get lbGutter {
    final cell = lbCell;
    final width = MediaQuery.sizeOf(this).width;
    final inset = sideInset();
    if (inset > 0) return inset + cell;
    return (width % cell) / 2 + cell;
  }
}

class _ScenePainter extends CustomPainter {
  const _ScenePainter(this.theme);

  final GameTheme theme;

  // The menu variant of the scene: calmer, since text sits on it.
  @override
  void paint(Canvas canvas, Size size) => ThemeScenes.paint(
      canvas, size, theme,
      menu: true, pixelRatio: ThemeScenes.devicePixelRatio);

  @override
  bool shouldRepaint(_ScenePainter old) => old.theme != theme;
}

class _GridPainter extends CustomPainter {
  _GridPainter({required this.cell, required this.color});

  final double cell;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;
    // Centre the grid horizontally so the lines line up with content that is
    // centred by sideInset() on tablets; on a 360 dp phone this is 0.
    final x0 = ((size.width % cell) / 2);
    for (var x = x0; x <= size.width; x += cell) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y <= size.height; y += cell) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.cell != cell || old.color != color;
}
