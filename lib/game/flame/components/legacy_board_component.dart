import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/widgets/lb/lb_cell_text.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';
import 'package:snake_classic/models/snake.dart';
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
  final Paint _gridPaint = Paint()..style = PaintingStyle.stroke;
  final Paint _ghostPaint = Paint();

  // Ghost score reveal (DESIGN_SPEC §5): the digits re-light cell by cell
  // over 220 ms whenever the score changes.
  int _ghostScore = -1;
  int _ghostChangedMs = 0;
  TextPainter? _ghostLabel;
  String? _ghostLabelKey;

  @override
  void render(Canvas canvas) {
    final gs = game.gameState;
    if (gs == null) return;

    final size = Size(game.worldWidth, game.worldHeight);

    // Living Board board: the palette's board colour and a hairline grid
    // on the real play cells. The old ambient wash and per-theme
    // decorations are gone — themes re-skin through LBPalette instead.
    final palette = LBPalette.of(game.theme);
    _bgPaint.color = palette.board;
    canvas.drawRect(Offset.zero & size, _bgPaint);

    // World-to-screen scale for the fixed-resolution camera: the world is
    // `board * cellSize` units and gets fitted into the viewport, so anything
    // that should measure a fixed number of SCREEN pixels (hairlines) has to
    // be divided by this. Uses the fit (min) axis to match how
    // CameraComponent.withFixedResolution letterboxes. Guarded against a
    // zero/degenerate viewport during the first frames.
    final scale = game.size.x <= 0 || game.size.y <= 0
        ? 1.0
        : math.min(game.size.x / size.width, game.size.y / size.height);
    // Clamped to a proportional band so dense boards keep a hairline and
    // small boards on tablets don't get a heavy line.
    final hairline = scale <= 0 ? 1.0 : (1.0 / scale).clamp(0.5, 1.5);
    _drawGrid(canvas, size, palette, hairline);
    _drawGhostScore(canvas, size, palette, gs.score, scale);

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

    // Death disintegration: render a tail-truncated copy of the fatal
    // snake so segments visibly vanish tail-to-head (the game emits a
    // dust poof per removed cell). Render-only — the real state keeps the
    // full body for the revive path. The painter tolerates the current
    // body being shorter than previousGameState's (it bounds-checks per
    // index), so only the current snake needs truncating.
    var renderGs = gs;
    final keep = game.deathKeepCount;
    if (keep < gs.snake.length) {
      renderGs = gs.copyWith(
        snake: Snake(
          body: List.of(gs.snake.body.take(keep)),
          currentDirection: gs.snake.currentDirection,
        ),
      );
    }

    OptimizedGameBoardPainter(
      gameState: renderGs,
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
      sprites: game.boardSprites,
      crashElapsedSeconds: game.crashElapsedOrNull,
    ).paint(canvas, size);

    // Death flash: the body blinks white in the beat between the crash
    // lunge and the disintegration. Drawn over the committed body cells;
    // the head is spared — it can sit mid-cell after a wall lunge, and
    // leaving it unflashed keeps "you" readable through the blink.
    final flash = game.deathFlashAlpha;
    if (flash > 0) {
      final cw = game.worldWidth / game.boardWidth;
      final ch = game.worldHeight / game.boardHeight;
      final flashPaint = Paint()
        ..color = Colors.white.withValues(alpha: flash.clamp(0.0, 1.0));
      for (final seg in renderGs.snake.body.skip(1)) {
        final rect = Rect.fromLTWH(
          seg.x * cw + cw * 0.08,
          seg.y * ch + ch * 0.08,
          cw * 0.84,
          ch * 0.84,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(cw * 0.25)),
          flashPaint,
        );
      }
    }
  }

  /// Triangle wave in [0.9, 1.1] over a 2s period, matching the legacy pulse
  /// controller (1s tween, repeat-reverse).
  void _drawGrid(Canvas canvas, Size size, LBPalette palette, double width) {
    _gridPaint
      ..color = palette.lime.withValues(alpha: .09)
      ..strokeWidth = width;
    final cw = size.width / game.boardWidth;
    final ch = size.height / game.boardHeight;
    for (var x = 0; x <= game.boardWidth; x++) {
      canvas.drawLine(Offset(x * cw, 0), Offset(x * cw, size.height), _gridPaint);
    }
    for (var y = 0; y <= game.boardHeight; y++) {
      canvas.drawLine(Offset(0, y * ch), Offset(size.width, y * ch), _gridPaint);
    }
  }

  /// The score in the cell font, faint, behind the snake (DESIGN_SPEC §5).
  /// One glyph cell is one board cell, enlarged on dense boards so the
  /// digits stay readable, and shrunk if the number would not fit.
  void _drawGhostScore(Canvas canvas, Size size, LBPalette palette, int score, double scale) {
    final layout = LBCellLayout.of('$score');
    if (layout == null) return;
    final ms = DateTime.now().millisecondsSinceEpoch;
    if (score != _ghostScore) {
      // The first frame of a run shows the score at once.
      _ghostChangedMs = _ghostScore < 0 ? ms - LB.reveal.inMilliseconds : ms;
      _ghostScore = score;
    }
    final cw = size.width / game.boardWidth;
    final screenCell = cw * (scale <= 0 ? 1 : scale);
    var g = cw * math.max(1, (16 / screenCell).ceil());
    final maxW = size.width - cw * 4;
    if (layout.columns * g > maxW) g = maxW / layout.columns;
    final ox = cw * 3;
    final oy = cw * 4;

    final progress = ((ms - _ghostChangedMs) / LB.reveal.inMilliseconds).clamp(0.0, 1.0);
    final litCols = layout.columns * progress;
    final lit = Path();
    final dim = Path();
    for (final (c, r) in layout.lit) {
      (c < litCols ? lit : dim).addRRect(lbCellRect(ox + c * g, oy + r * g, g));
    }
    _ghostPaint.color = palette.lime.withValues(alpha: .12);
    canvas.drawPath(lit, _ghostPaint);
    _ghostPaint.color = palette.lime.withValues(alpha: .05);
    canvas.drawPath(dim, _ghostPaint);

    final label = game.ghostScoreLabel;
    final key = '$label|${g.toStringAsFixed(1)}|${palette.lime.toARGB32()}';
    if (_ghostLabelKey != key) {
      _ghostLabelKey = key;
      _ghostLabel = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontFamily: LB.font,
            fontFamilyFallback: LB.fontFallback,
            fontSize: g * .55,
            fontWeight: FontWeight.w800,
            letterSpacing: g * .22,
            color: palette.lime.withValues(alpha: .28),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
    }
    _ghostLabel!.paint(canvas, Offset(ox, oy - _ghostLabel!.height - g * .15));
  }

  double _pulse(int ms) {
    final p = (ms % 2000) / 2000.0;
    return 0.9 + 0.2 * (1 - (2 * p - 1).abs());
  }
}
