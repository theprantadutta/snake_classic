import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/game/flame/rendering/game_board_painter.dart';

/// Renders the gameplay board by driving the shared `CustomPainter`s
/// ([GameBoardBackgroundPainter] + [OptimizedGameBoardPainter]) inside Flame's
/// render pass, in the world's pixel-space coordinates.
///
/// Historical note: these painters predate the Flame migration (they powered
/// the old `game_board.dart` widget, deleted long ago). Reusing them kept
/// pixel-for-pixel parity across every theme, skin and crash effect while the
/// loop, camera and components moved to Flame. They are now simply where the
/// board rendering lives — there is no other renderer.
///
/// Note: the snake trail system and explosion particles are layered separately
/// (Phase 3b) — this component covers the board, snake, food, power-ups,
/// backgrounds, wall warnings, visited-trail overlay and crash indicators.
class LegacyBoardComponent extends Component
    with HasGameReference<SnakeFlameGame> {
  LegacyBoardComponent() : super(priority: 0);

  final Paint _bgPaint = Paint();

  @override
  void render(Canvas canvas) {
    final gs = game.gameState;
    if (gs == null) return;

    final size = Size(game.worldWidth, game.worldHeight);

    // Base fill (stand-in for the legacy Container's background colour) under
    // the theme background flourishes.
    _bgPaint.color = game.theme.backgroundColor;
    canvas.drawRect(Offset.zero & size, _bgPaint);
    GameBoardBackgroundPainter(game.theme).paint(canvas, size);

    // Head intent shimmer — fade over a ~140ms window from the accept stamp
    // (identical to the legacy widget's computation).
    Direction? shimmerDir;
    var shimmerAge = 1.0;
    final stamp = game.cubitState.lastAcceptedInputAt;
    if (stamp != null) {
      final ageMs = DateTime.now().difference(stamp).inMilliseconds;
      if (ageMs <= 140) {
        shimmerDir = game.cubitState.lastAcceptedDirection;
        shimmerAge = (ageMs / 140).clamp(0.0, 1.0);
      }
    }

    final ms = DateTime.now().millisecondsSinceEpoch;

    OptimizedGameBoardPainter(
      gameState: gs,
      theme: game.theme,
      // The painter only reads pulseAnimation.value; feed a synthesized pulse
      // in the legacy [0.9, 1.1] range so breathing/glow animate identically.
      pulseAnimation: AlwaysStoppedAnimation<double>(_pulse(ms)),
      moveProgress: game.moveProgress,
      previousGameState: game.previousGameState,
      premiumState: game.premiumState,
      animationTimeMs: ms,
      recentInputDirection: shimmerDir,
      recentInputShimmerAge: shimmerAge,
    ).paint(canvas, size);
  }

  /// Triangle wave in [0.9, 1.1] over a 2s period, matching the legacy pulse
  /// controller (1s tween, repeat-reverse).
  double _pulse(int ms) {
    final p = (ms % 2000) / 2000.0;
    return 0.9 + 0.2 * (1 - (2 * p - 1).abs());
  }
}
