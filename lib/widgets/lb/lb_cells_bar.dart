import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';

/// Progress drawn as a row of [count] cells (DESIGN_SPEC §3). Used for
/// level, XP, loading, countdowns, the momentum bar and sliders.
///
/// [value] is 0–1; partially lit cells round down so a bar never claims
/// progress the player hasn't made. With no [cell] it stretches to the
/// available width.
class LBCellsBar extends StatelessWidget {
  const LBCellsBar({
    super.key,
    required this.count,
    required this.value,
    this.cell,
    this.color,
    this.offColor,
    this.colorAt,
    this.semanticsLabel,
  });

  final int count;
  final double value;

  /// dp per cell. Null = fill the width.
  final double? cell;
  final Color? color;
  final Color? offColor;

  /// Per-cell colour override for lit cells (gradients, sweeps).
  final Color Function(int index)? colorAt;
  final String? semanticsLabel;

  int get litCount => (value.clamp(0.0, 1.0) * count + 1e-6).floor();

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    Widget bar(double cellSize) => CustomPaint(
          size: Size(cellSize * count, cellSize),
          painter: _CellsBarPainter(
            count: count,
            lit: litCount,
            cell: cellSize,
            color: color ?? p.lime,
            off: offColor ?? p.cellOff,
            colorAt: colorAt,
          ),
        );
    final body = cell != null
        ? bar(cell!)
        : LayoutBuilder(
            builder: (context, c) => bar(c.maxWidth / count),
          );
    return Semantics(
      label: semanticsLabel,
      value: '${(value.clamp(0.0, 1.0) * 100).round()}%',
      child: ExcludeSemantics(child: body),
    );
  }
}

class _CellsBarPainter extends CustomPainter {
  _CellsBarPainter({
    required this.count,
    required this.lit,
    required this.cell,
    required this.color,
    required this.off,
    this.colorAt,
  });

  final int count;
  final int lit;
  final double cell;
  final Color color;
  final Color off;
  final Color Function(int index)? colorAt;

  @override
  void paint(Canvas canvas, Size size) {
    final offPath = Path();
    final litPath = Path();
    for (var i = 0; i < count; i++) {
      final r = lbCellRect(i * cell, 0, cell);
      if (i < lit) {
        if (colorAt != null) {
          canvas.drawRRect(r, Paint()..color = colorAt!(i));
        } else {
          litPath.addRRect(r);
        }
      } else {
        offPath.addRRect(r);
      }
    }
    canvas.drawPath(offPath, Paint()..color = off);
    canvas.drawPath(litPath, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CellsBarPainter old) =>
      old.count != count ||
      old.lit != lit ||
      old.cell != cell ||
      old.color != color ||
      old.off != off ||
      old.colorAt != colorAt;
}
