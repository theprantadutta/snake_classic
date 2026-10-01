import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';

/// The "Cell S" logo mark: a snake curled into an S on a 7x7 board, head
/// and apple on the top row. Drawn, not bundled, so it is crisp at every size
/// and always matches the app icon's geometry.
class LBCellSMark extends StatelessWidget {
  const LBCellSMark({super.key, this.size = 46, this.framed = true});

  final double size;

  /// Draw the rounded green tile behind the board (the app-icon look).
  final bool framed;

  @override
  Widget build(BuildContext context) => Semantics(
        label: 'Snake Classic',
        image: true,
        child: CustomPaint(
          size: Size.square(size),
          painter: _CellSPainter(framed),
        ),
      );
}

class _CellSPainter extends CustomPainter {
  _CellSPainter(this.framed);

  final bool framed;

  // Body from tail to the cell behind the head, as (col, row) on the 7x7
  // board. Matches logo/app-icon-*.png.
  static const List<(int, int)> _body = [
    (1, 5), (2, 5), (3, 5), (4, 5), (5, 5), //
    (5, 4),
    (5, 3), (4, 3), (3, 3), (2, 3), (1, 3), //
    (1, 2),
    (1, 1), (2, 1), (3, 1), (4, 1),
  ];
  static const (int, int) _head = (5, 1);
  static const (int, int) _apple = (6, 1);

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width;
    if (framed) {
      final tile = RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(s * .24));
      canvas.drawRRect(
        tile,
        Paint()
          ..shader = const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1F5A1A), Color(0xFF0F380F)],
          ).createShader(Offset.zero & size),
      );
      canvas.drawRRect(
        tile.deflate(s * .006),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = s * .012
          ..color = const Color(0x553C8A1E),
      );
    }
    final pad = framed ? s * .12 : 0.0;
    final cell = (s - pad * 2) / 7;
    Rect at((int, int) p) => Rect.fromLTWH(pad + p.$1 * cell, pad + p.$2 * cell, cell, cell);

    final dim = Path();
    for (var r = 0; r < 7; r++) {
      for (var c = 0; c < 7; c++) {
        dim.addRRect(lbCellRect(pad + c * cell, pad + r * cell, cell));
      }
    }
    canvas.drawPath(dim, Paint()..color = const Color(0x1AAEDC10));

    for (var i = 0; i < _body.length; i++) {
      // Tail fades to a deeper green, like the reference art.
      final t = i / (_body.length - 1);
      final color = Color.lerp(const Color(0xFF6E9A12), LB.lime, t)!;
      final r = at(_body[i]);
      canvas.drawRRect(lbCellRect(r.left, r.top, cell), Paint()..color = color);
    }

    final h = at(_head);
    canvas.drawRRect(
      lbCellRect(h.left, h.top, cell).inflate(cell * .05),
      Paint()
        ..color = LB.head.withValues(alpha: .45)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * .35),
    );
    canvas.drawRRect(lbCellRect(h.left, h.top, cell), Paint()..color = LB.head);
    final eye = Paint()..color = const Color(0xFF0B1A0B);
    canvas.drawCircle(Offset(h.left + cell * .62, h.top + cell * .33), cell * .08, eye);
    canvas.drawCircle(Offset(h.left + cell * .62, h.top + cell * .67), cell * .08, eye);

    final a = at(_apple).center;
    canvas.drawCircle(
      a,
      cell * .34,
      Paint()
        ..color = LB.apple.withValues(alpha: .5)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * .25),
    );
    canvas.drawCircle(
      a,
      cell * .28,
      Paint()
        ..shader = const RadialGradient(
          center: Alignment(-.4, -.4),
          colors: [LB.appleHighlight, LB.apple],
        ).createShader(Rect.fromCircle(center: a, radius: cell * .28)),
    );
  }

  @override
  bool shouldRepaint(_CellSPainter old) => old.framed != framed;
}
