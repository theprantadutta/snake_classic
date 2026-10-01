import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_glyphs.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';

/// The 36 icons in the kit's 5x5 set. Typed so a typo is a compile error.
enum LBIcon {
  apple,
  back,
  bolt,
  buzz,
  calendar,
  chart,
  check,
  coin,
  copy,
  crown,
  eye,
  film,
  flame,
  friends,
  gear,
  gift,
  grid,
  heart,
  hourglass,
  invite,
  lock,
  music,
  next,
  pause,
  play,
  plus,
  shield,
  skull,
  sound,
  star,
  swords,
  target,
  trophy,
  tv,
  user,
  x,
}

/// A 5x5 pixel icon (DESIGN_SPEC §3). Replaces Material icons app-wide.
/// [cell] is the dp size of one pixel: 3 inline, 4–6 in buttons.
class LBPixelIcon extends StatelessWidget {
  const LBPixelIcon(
    this.icon, {
    super.key,
    this.cell = 3,
    this.color,
    this.accent,
    this.semanticLabel,
  });

  final LBIcon icon;
  final double cell;
  final Color? color;

  /// Colour for the icon's 'o' pixels; falls back to [color].
  final Color? accent;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final c = color ?? DefaultTextStyle.of(context).style.color ?? context.lb.lime;
    final paint = CustomPaint(
      size: Size.square(cell * 5),
      painter: _PixelIconPainter(icon, cell, c, accent ?? c),
    );
    if (semanticLabel == null) return ExcludeSemantics(child: paint);
    return Semantics(label: semanticLabel, image: true, child: paint);
  }
}

class _PixelIconPainter extends CustomPainter {
  _PixelIconPainter(this.icon, this.cell, this.color, this.accent);

  final LBIcon icon;
  final double cell;
  final Color color;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final rows = lbPixelIconData[icon.name]!;
    final primary = Path();
    final second = Path();
    for (var r = 0; r < rows.length; r++) {
      for (var c = 0; c < rows[r].length; c++) {
        final ch = rows[r][c];
        if (ch == '.') continue;
        (ch == 'o' ? second : primary).addRRect(lbCellRect(c * cell, r * cell, cell));
      }
    }
    canvas.drawPath(primary, Paint()..color = color);
    canvas.drawPath(second, Paint()..color = accent);
  }

  @override
  bool shouldRepaint(_PixelIconPainter old) =>
      old.icon != icon || old.cell != cell || old.color != color || old.accent != accent;
}
