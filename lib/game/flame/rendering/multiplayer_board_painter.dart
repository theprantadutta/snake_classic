import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/constants.dart';

/// Player colors for multi-player games (matches backend)
const List<Color> multiplayerColors = [
  Color(0xFF4CAF50), // Green
  Color(0xFFF44336), // Red
  Color(0xFF2196F3), // Blue
  Color(0xFFFF9800), // Orange
  Color(0xFF9C27B0), // Purple
  Color(0xFF00BCD4), // Cyan
  Color(0xFFFFEB3B), // Yellow
  Color(0xFFE91E63), // Pink
];

/// Grid background painter. Public so the Flame multiplayer renderer can reuse
/// the exact drawing (see lib/game/flame/multiplayer_flame_game.dart).
class MultiplayerGridBackgroundPainter extends CustomPainter {
  final GameTheme theme;
  final int boardSize;

  MultiplayerGridBackgroundPainter(this.theme, this.boardSize);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / boardSize;
    final cellHeight = size.height / boardSize;

    final paint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.08)
      ..strokeWidth = 0.5;

    // Draw vertical lines
    for (int x = 0; x <= boardSize; x++) {
      canvas.drawLine(
        Offset(x * cellWidth, 0),
        Offset(x * cellWidth, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (int y = 0; y <= boardSize; y++) {
      canvas.drawLine(
        Offset(0, y * cellHeight),
        Offset(size.width, y * cellHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant MultiplayerGridBackgroundPainter oldDelegate) =>
      oldDelegate.theme != theme || oldDelegate.boardSize != boardSize;
}

/// Main painter for all game content - snakes, food, effects.
///
/// Renders the server-authoritative [MatchSnapshot] directly — both
/// snakes come from the same tick, no local player special-casing.
/// Smooth movement comes from lerping every segment between
/// [previousSnapshot] and [snapshot] by [moveProgress] (0..1 across the
/// server's tick_ms window, driven by the Flame game clock).
class MultiplayerBoardPainter extends CustomPainter {
  final MatchSnapshot snapshot;
  final MatchSnapshot? previousSnapshot;
  final String currentUserId;
  final GameTheme theme;
  final Animation<double> pulseAnimation;
  final double moveProgress;
  final int boardSize;

  MultiplayerBoardPainter({
    required this.snapshot,
    required this.previousSnapshot,
    required this.currentUserId,
    required this.theme,
    required this.pulseAnimation,
    required this.moveProgress,
    required this.boardSize,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / boardSize;
    final cellHeight = size.height / boardSize;

    // Draw food first (below snakes)
    _drawFood(canvas, cellWidth, cellHeight);

    // Draw all snakes from the snapshot, interpolated against the
    // previous tick for smooth movement.
    for (final player in snapshot.players) {
      if (player.body.isEmpty) continue;

      final isCurrentPlayer = player.userId == currentUserId;
      final color =
          multiplayerColors[player.playerIndex % multiplayerColors.length];
      final centers = _interpolatedCenters(
        player,
        previousSnapshot?.playerByIndex(player.playerIndex),
        cellWidth,
        cellHeight,
      );

      _drawSnake(
        canvas,
        centers,
        player.direction,
        player.alive,
        color,
        cellWidth,
        cellHeight,
        isCurrentPlayer: isCurrentPlayer,
        playerName: isCurrentPlayer ? 'You' : player.username,
      );
    }
  }

  /// Per-segment cell centers lerped between the previous and current
  /// tick. Segment i slides from its old cell to its new one (the body
  /// list shifts one cell forward per tick, so index-wise lerp is the
  /// slide). A brand-new tail segment (growth) and any teleport-sized
  /// jump (reconnect resync) snap to the current cell; dead snakes are
  /// frozen at their final cells.
  List<Offset> _interpolatedCenters(
    MatchPlayerState player,
    MatchPlayerState? previous,
    double cellWidth,
    double cellHeight,
  ) {
    Offset center(Position p) => Offset(
      p.x * cellWidth + cellWidth / 2,
      p.y * cellHeight + cellHeight / 2,
    );

    final body = player.body;
    final prevBody = previous?.body;
    final t = moveProgress.clamp(0.0, 1.0);
    if (!player.alive || prevBody == null || prevBody.isEmpty || t >= 1.0) {
      return body.map(center).toList();
    }

    return List<Offset>.generate(body.length, (i) {
      final to = body[i];
      final from = i < prevBody.length ? prevBody[i] : to;
      final jump = (to.x - from.x).abs() + (to.y - from.y).abs();
      if (jump == 0 || jump > 2) return center(to);
      return Offset.lerp(center(from), center(to), t)!;
    });
  }

  void _drawFood(Canvas canvas, double cellWidth, double cellHeight) {
    final foodPos = snapshot.food;
    final centerX = foodPos.x * cellWidth + cellWidth / 2;
    final centerY = foodPos.y * cellHeight + cellHeight / 2;
    final baseRadius = math.min(cellWidth, cellHeight) * 0.35;
    final radius = baseRadius * pulseAnimation.value;

    // Glow effect
    final glowPaint = Paint()
      ..color = theme.foodColor.withValues(alpha: 0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(Offset(centerX, centerY), radius * 1.5, glowPaint);

    // Main food circle with gradient
    final foodPaint = Paint()
      ..shader =
          RadialGradient(
            colors: [theme.foodColor, theme.foodColor.withValues(alpha: 0.8)],
          ).createShader(
            Rect.fromCircle(center: Offset(centerX, centerY), radius: radius),
          );
    canvas.drawCircle(Offset(centerX, centerY), radius, foodPaint);

    // Highlight
    final highlightPaint = Paint()..color = Colors.white.withValues(alpha: 0.6);
    canvas.drawCircle(
      Offset(centerX - radius * 0.3, centerY - radius * 0.3),
      radius * 0.2,
      highlightPaint,
    );
  }

  void _drawSnake(
    Canvas canvas,
    List<Offset> centers,
    Direction direction,
    bool isAlive,
    Color color,
    double cellWidth,
    double cellHeight, {
    required bool isCurrentPlayer,
    required String playerName,
  }) {
    if (centers.isEmpty) return;

    final isDead = !isAlive;
    final baseColor = isDead ? Colors.grey : color;

    // Draw body segments (from tail to head)
    for (int i = centers.length - 1; i >= 0; i--) {
      final segmentCenter = centers[i];
      final isHead = i == 0;

      // Calculate segment size (head is larger, tail tapers)
      double segmentSize;
      if (isHead) {
        segmentSize = math.min(cellWidth, cellHeight) * 0.45;
      } else {
        // Taper towards tail
        final taperFactor = 1.0 - (i / centers.length) * 0.3;
        segmentSize = math.min(cellWidth, cellHeight) * 0.38 * taperFactor;
      }

      // Gradient for 3D effect
      final segmentPaint = Paint()
        ..shader =
            RadialGradient(
              center: const Alignment(-0.3, -0.3),
              colors: [
                _lighten(baseColor, 0.3),
                baseColor,
                _darken(baseColor, 0.2),
              ],
              stops: const [0.0, 0.5, 1.0],
            ).createShader(
              Rect.fromCircle(center: segmentCenter, radius: segmentSize),
            );

      // Draw glow for current player's head
      if (isHead && isCurrentPlayer && !isDead) {
        final glowPaint = Paint()
          ..color = baseColor.withValues(alpha: 0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
        canvas.drawCircle(segmentCenter, segmentSize * 1.4, glowPaint);
      }

      // Draw segment with rounded corners
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: segmentCenter,
          width: segmentSize * 2,
          height: segmentSize * 2,
        ),
        Radius.circular(segmentSize * 0.4),
      );
      canvas.drawRRect(rect, segmentPaint);

      // Draw eyes on head
      if (isHead) {
        _drawEyes(
          canvas,
          segmentCenter,
          direction,
          segmentSize,
          baseColor,
          isDead,
        );
      }

      // Draw border for visibility
      final borderPaint = Paint()
        ..color = _darken(baseColor, 0.4).withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;
      canvas.drawRRect(rect, borderPaint);
    }

    // Draw player name label above head
    final head = centers.first;

    final textPainter = TextPainter(
      text: TextSpan(
        text: playerName,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.8),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        head.dx - textPainter.width / 2,
        head.dy - cellHeight / 2 - 8 - textPainter.height,
      ),
    );
  }

  void _drawEyes(
    Canvas canvas,
    Offset center,
    Direction direction,
    double headSize,
    Color snakeColor,
    bool isDead,
  ) {
    final eyeRadius = headSize * 0.2;
    final eyeOffset = headSize * 0.35;

    Offset leftEyePos;
    Offset rightEyePos;

    switch (direction) {
      case Direction.up:
        leftEyePos = Offset(center.dx - eyeOffset, center.dy - eyeOffset * 0.5);
        rightEyePos = Offset(
          center.dx + eyeOffset,
          center.dy - eyeOffset * 0.5,
        );
        break;
      case Direction.down:
        leftEyePos = Offset(center.dx - eyeOffset, center.dy + eyeOffset * 0.5);
        rightEyePos = Offset(
          center.dx + eyeOffset,
          center.dy + eyeOffset * 0.5,
        );
        break;
      case Direction.left:
        leftEyePos = Offset(center.dx - eyeOffset * 0.5, center.dy - eyeOffset);
        rightEyePos = Offset(
          center.dx - eyeOffset * 0.5,
          center.dy + eyeOffset,
        );
        break;
      case Direction.right:
        leftEyePos = Offset(center.dx + eyeOffset * 0.5, center.dy - eyeOffset);
        rightEyePos = Offset(
          center.dx + eyeOffset * 0.5,
          center.dy + eyeOffset,
        );
        break;
    }

    // Eye whites
    final eyeWhitePaint = Paint()..color = Colors.white;
    canvas.drawCircle(leftEyePos, eyeRadius, eyeWhitePaint);
    canvas.drawCircle(rightEyePos, eyeRadius, eyeWhitePaint);

    // Pupils (X for dead snake)
    if (isDead) {
      final xPaint = Paint()
        ..color = Colors.black
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke;

      // Draw X on each eye
      for (final eyePos in [leftEyePos, rightEyePos]) {
        canvas.drawLine(
          Offset(eyePos.dx - eyeRadius * 0.5, eyePos.dy - eyeRadius * 0.5),
          Offset(eyePos.dx + eyeRadius * 0.5, eyePos.dy + eyeRadius * 0.5),
          xPaint,
        );
        canvas.drawLine(
          Offset(eyePos.dx + eyeRadius * 0.5, eyePos.dy - eyeRadius * 0.5),
          Offset(eyePos.dx - eyeRadius * 0.5, eyePos.dy + eyeRadius * 0.5),
          xPaint,
        );
      }
    } else {
      final pupilPaint = Paint()..color = Colors.black;
      final pupilRadius = eyeRadius * 0.5;
      canvas.drawCircle(leftEyePos, pupilRadius, pupilPaint);
      canvas.drawCircle(rightEyePos, pupilRadius, pupilPaint);
    }
  }

  Color _lighten(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + amount).clamp(0.0, 1.0))
        .toColor();
  }

  Color _darken(Color color, double amount) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
        .toColor();
  }

  @override
  bool shouldRepaint(covariant MultiplayerBoardPainter oldDelegate) {
    return oldDelegate.snapshot != snapshot ||
        oldDelegate.previousSnapshot != previousSnapshot ||
        oldDelegate.moveProgress != moveProgress ||
        oldDelegate.theme != theme ||
        oldDelegate.currentUserId != currentUserId;
  }
}
