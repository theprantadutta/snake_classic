import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';

/// Draws the board background fill and the grid lines. Lives at the bottom of
/// the render order so the snake and entities draw on top.
///
/// All coordinates are in **cell units** (the game's fixed-resolution camera
/// maps one cell to one world unit), so a 1x1 rect is exactly one grid cell.
class BoardComponent extends Component with HasGameReference<SnakeFlameGame> {
  BoardComponent() : super(priority: 0);

  final Paint _fillPaint = Paint();
  final Paint _gridPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.02;

  @override
  void render(Canvas canvas) {
    final theme = game.theme;
    final w = game.boardWidth.toDouble();
    final h = game.boardHeight.toDouble();

    _fillPaint.color = theme.backgroundColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), _fillPaint);

    _gridPaint.color = theme.accentColor.withValues(alpha: 0.08);
    for (var x = 0; x <= game.boardWidth; x++) {
      canvas.drawLine(Offset(x.toDouble(), 0), Offset(x.toDouble(), h), _gridPaint);
    }
    for (var y = 0; y <= game.boardHeight; y++) {
      canvas.drawLine(Offset(0, y.toDouble()), Offset(w, y.toDouble()), _gridPaint);
    }
  }
}
