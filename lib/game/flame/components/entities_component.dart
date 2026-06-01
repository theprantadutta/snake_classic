import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/power_up.dart';

/// Draws the food (primary + MultiFood extras) and the on-board power-up.
/// Renders above the board, below the snake.
///
/// Phase-2 skeleton visuals: simple coloured circles. The bespoke per-theme
/// food art (apple/bonus/star) and animated power-up icons are ported in
/// Phase 3.
class EntitiesComponent extends Component
    with HasGameReference<SnakeFlameGame> {
  EntitiesComponent() : super(priority: 1);

  final Paint _paint = Paint();

  @override
  void render(Canvas canvas) {
    final gs = game.gameState;
    if (gs == null) return;

    final primary = gs.food;
    if (primary != null) _drawFood(canvas, primary);
    for (final extra in gs.foods) {
      _drawFood(canvas, extra);
    }

    final powerUp = gs.powerUp;
    if (powerUp != null) _drawPowerUp(canvas, powerUp);
  }

  void _drawFood(Canvas canvas, Food food) {
    final center = Offset(food.position.x + 0.5, food.position.y + 0.5);
    final radius = switch (food.type) {
      FoodType.normal => 0.36,
      FoodType.bonus => 0.42,
      FoodType.special => 0.46,
    };
    final color = switch (food.type) {
      FoodType.normal => game.theme.foodColor,
      FoodType.bonus => Colors.orangeAccent,
      FoodType.special => Colors.amberAccent,
    };
    _paint.color = color;
    canvas.drawCircle(center, radius, _paint);
  }

  void _drawPowerUp(Canvas canvas, PowerUp powerUp) {
    final center = Offset(powerUp.position.x + 0.5, powerUp.position.y + 0.5);
    _paint.color = powerUp.type.color.withValues(alpha: 0.85);
    canvas.drawCircle(center, 0.45, _paint);
    _paint.color = Colors.white.withValues(alpha: 0.9);
    canvas.drawCircle(center, 0.18, _paint);
  }
}
