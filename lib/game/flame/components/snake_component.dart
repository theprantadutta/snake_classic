import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';
import 'package:snake_classic/utils/direction.dart';

/// Draws the snake, interpolating each segment from its previous-tick cell to
/// its current cell using the game's [SnakeFlameGame.moveProgress]. This is the
/// Flame-native replacement for the legacy widget's `AnimationController`-driven
/// smooth movement.
///
/// Phase-2 skeleton: rounded rectangles + simple eyes. The 12 premium skin
/// signatures and per-theme styling are ported in Phase 3.
class SnakeComponent extends Component with HasGameReference<SnakeFlameGame> {
  SnakeComponent() : super(priority: 2);

  final Paint _bodyPaint = Paint();
  final Paint _headPaint = Paint();
  final Paint _eyePaint = Paint()..color = Colors.white;
  final Paint _pupilPaint = Paint()..color = Colors.black;

  @override
  void render(Canvas canvas) {
    final gs = game.gameState;
    if (gs == null) return;

    final body = gs.snake.body;
    final prev = game.previousGameState?.snake.body;
    final progress = game.moveProgress;
    final snakeColor = game.theme.snakeColor;

    // Draw tail-first so the head renders on top.
    for (var i = body.length - 1; i >= 0; i--) {
      final cur = body[i];
      var x = cur.x.toDouble();
      var y = cur.y.toDouble();

      if (prev != null && i < prev.length && progress < 1.0) {
        final from = prev[i];
        final dx = (cur.x - from.x).toDouble();
        final dy = (cur.y - from.y).toDouble();
        // Only interpolate single-cell moves; a larger delta is a wrap-around
        // teleport that would streak across the board if lerped.
        if (dx.abs() <= 1.001 && dy.abs() <= 1.001) {
          x = from.x + dx * progress;
          y = from.y + dy * progress;
        }
      }

      final isHead = i == 0;
      final paint = isHead ? _headPaint : _bodyPaint;
      paint.color =
          isHead ? snakeColor : snakeColor.withValues(alpha: 0.82);
      final inset = isHead ? 0.04 : 0.08;
      final rect = Rect.fromLTWH(x + inset, y + inset, 1 - inset * 2, 1 - inset * 2);
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(0.28)),
        paint,
      );

      if (isHead) _drawEyes(canvas, x, y, gs.snake.currentDirection);
    }
  }

  void _drawEyes(Canvas canvas, double x, double y, Direction dir) {
    // Place the two eyes toward the front of the head based on heading.
    final cx = x + 0.5;
    final cy = y + 0.5;
    const along = 0.22; // forward offset
    const apart = 0.2; // sideways separation
    late Offset e1, e2;
    switch (dir) {
      case Direction.up:
        e1 = Offset(cx - apart, cy - along);
        e2 = Offset(cx + apart, cy - along);
      case Direction.down:
        e1 = Offset(cx - apart, cy + along);
        e2 = Offset(cx + apart, cy + along);
      case Direction.left:
        e1 = Offset(cx - along, cy - apart);
        e2 = Offset(cx - along, cy + apart);
      case Direction.right:
        e1 = Offset(cx + along, cy - apart);
        e2 = Offset(cx + along, cy + apart);
    }
    canvas.drawCircle(e1, 0.1, _eyePaint);
    canvas.drawCircle(e2, 0.1, _eyePaint);
    canvas.drawCircle(e1, 0.045, _pupilPaint);
    canvas.drawCircle(e2, 0.045, _pupilPaint);
  }
}
