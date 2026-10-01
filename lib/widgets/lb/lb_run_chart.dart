import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';
import 'package:snake_classic/widgets/lb/lb_grid_background.dart';

/// "Your run, uncoiled" (Living Board screen 08): one column per food, its
/// height the points that bite scored, gold on top when it was a bonus or a
/// combo bite, and a red × cell where the run ended. Columns grow left →
/// right with a 40 ms stagger.
///
/// Long runs are bucketed so the chart always fits the width: each column
/// then stands for several consecutive bites (their points summed).
class LBRunChart extends StatefulWidget {
  const LBRunChart({super.key, required this.bites, this.crashed = true, this.rows = 9});

  final List<RunBite> bites;
  final bool crashed;
  final int rows;

  @override
  State<LBRunChart> createState() => _LBRunChartState();
}

class _LBRunChartState extends State<LBRunChart> with SingleTickerProviderStateMixin {
  late final AnimationController _grow;

  @override
  void initState() {
    super.initState();
    final columns = math.max(1, widget.bites.length);
    _grow = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300 + 40 * math.min(columns, 30)),
    )..forward();
  }

  @override
  void dispose() {
    _grow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LayoutBuilder(
      builder: (context, c) {
        final maxCols = math.max(1, (c.maxWidth / 14).floor() - 2);
        final columns = _bucket(widget.bites, maxCols);
        final slots = columns.length + (widget.crashed ? 2 : 0);
        final cell = math.min(context.lbCell, c.maxWidth / math.max(slots, 1));
        // Decorative: the stats line above it carries the same facts as text.
        return ExcludeSemantics(
          child: SizedBox(
            height: cell * widget.rows,
            width: c.maxWidth,
            child: AnimatedBuilder(
              animation: _grow,
              builder: (context, _) => CustomPaint(
                painter: _ChartPainter(
                  columns: columns,
                  rows: widget.rows,
                  cell: cell,
                  crashed: widget.crashed,
                  progress: _grow.value,
                  lime: p.lime,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static List<RunBite> _bucket(List<RunBite> bites, int maxCols) {
    if (bites.length <= maxCols) return bites;
    final per = (bites.length / maxCols).ceil();
    final out = <RunBite>[];
    for (var i = 0; i < bites.length; i += per) {
      final chunk = bites.sublist(i, math.min(i + per, bites.length));
      out.add(RunBite(
        points: chunk.fold(0, (s, b) => s + b.points),
        bonus: chunk.any((b) => b.bonus),
      ));
    }
    return out;
  }
}

class _ChartPainter extends CustomPainter {
  _ChartPainter({
    required this.columns,
    required this.rows,
    required this.cell,
    required this.crashed,
    required this.progress,
    required this.lime,
  });

  final List<RunBite> columns;
  final int rows;
  final double cell;
  final bool crashed;
  final double progress;
  final Color lime;

  @override
  void paint(Canvas canvas, Size size) {
    final n = columns.length;
    final maxPoints = columns.fold<int>(1, (m, b) => math.max(m, b.points));
    final bottom = size.height;
    final paint = Paint();
    final total = n + (crashed ? 1 : 0);

    for (var i = 0; i < n; i++) {
      // Each column starts growing a little after the one before it.
      final t = ((progress * total) - i).clamp(0.0, 1.0);
      if (t <= 0) break;
      final b = columns[i];
      final h = math.max(1, (b.points / maxPoints * rows).round());
      final shown = math.max(1, (h * t).ceil());
      for (var r = 0; r < shown; r++) {
        final top = r == shown - 1;
        final Color color;
        if (top && b.bonus && shown == h) {
          color = LB.gold;
        } else {
          // Brighter toward the top of each column, dimmer for older bites.
          final lift = r / math.max(1, h - 1);
          color = Color.lerp(lime.withValues(alpha: .45), lime, .35 + .45 * lift + .2 * (i / math.max(1, n - 1)))!;
        }
        paint.color = color;
        canvas.drawRRect(lbCellRect(i * cell, bottom - (r + 1) * cell, cell), paint);
      }
    }

    if (crashed && progress >= n / math.max(total, 1)) {
      final x = size.width - cell;
      final rect = lbCellRect(x, bottom - cell, cell);
      canvas.drawRRect(rect, Paint()..color = LB.bonk);
      final c = rect.center;
      final r = cell * .18;
      final cross = Paint()
        ..color = const Color(0xFF2A0705)
        ..strokeWidth = cell * .1
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(c + Offset(-r, -r), c + Offset(r, r), cross);
      canvas.drawLine(c + Offset(r, -r), c + Offset(-r, r), cross);
    }
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.progress != progress || old.columns != columns || old.cell != cell || old.lime != lime;
}
