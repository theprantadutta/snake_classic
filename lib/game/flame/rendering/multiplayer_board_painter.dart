import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snake_classic/design/lb_tokens.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/constants.dart';

/// Player colors for multi-player games (matches backend).
///
/// No longer drawn: the Living Board paints you in the palette lime and every
/// rival in [LB.rival] (render 19). Kept for anything that still keys a
/// colour off `playerIndex`.
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

/// The Living Board playfield (DESIGN_SPEC §5): the palette's board colour
/// and a hairline on every play cell, exactly as the single-player board
/// draws it (see LegacyBoardComponent). Public so the Flame multiplayer
/// renderer can reuse it (see lib/game/flame/multiplayer_flame_game.dart).
class MultiplayerGridBackgroundPainter extends CustomPainter {
  final GameTheme theme;
  final int boardSize;

  /// Grid stroke width in WORLD units. The world is `boardSize * cellSize`
  /// units and the fixed-resolution camera fits it to the viewport, so a
  /// hard-coded width renders thicker the larger the screen.
  final double lineWidth;

  MultiplayerGridBackgroundPainter(
    this.theme,
    this.boardSize, {
    this.lineWidth = 0.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final palette = LBPalette.of(theme);
    canvas.drawRect(Offset.zero & size, Paint()..color = palette.board);

    final cellWidth = size.width / boardSize;
    final cellHeight = size.height / boardSize;
    final paint = Paint()
      ..color = palette.lime.withValues(alpha: .09)
      ..strokeWidth = lineWidth;

    for (int x = 0; x <= boardSize; x++) {
      canvas.drawLine(
        Offset(x * cellWidth, 0),
        Offset(x * cellWidth, size.height),
        paint,
      );
    }
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
      oldDelegate.theme != theme ||
      oldDelegate.boardSize != boardSize ||
      oldDelegate.lineWidth != lineWidth;
}

/// Main painter for all game content - snakes, food, name tags.
///
/// Renders the server-authoritative [MatchSnapshot] directly — both
/// snakes come from the same tick, no local player special-casing beyond
/// colour. Smooth movement comes from lerping every segment between
/// [previousSnapshot] and [snapshot] by [moveProgress] (0..1 across the
/// server's tick_ms window, driven by the Flame game clock).
///
/// Living Board look (render 19): every snake is a run of `cell − 2`
/// rounded squares with opacity ramping 100% → 45% toward the tail and a
/// glowing head with two eyes looking where it is going. You are the
/// palette lime; rivals are [LB.rival] with an [LB.rivalHead] head. A
/// crashed snake fades and its head turns red with a cross, as in
/// single-player. Food sits in the gold reward glow.
class MultiplayerBoardPainter extends CustomPainter {
  final MatchSnapshot snapshot;
  final MatchSnapshot? previousSnapshot;
  final String currentUserId;
  final GameTheme theme;
  final Animation<double> pulseAnimation;
  final double moveProgress;
  final int boardSize;

  /// Localized label drawn above the local player's snake. The painter has
  /// no BuildContext, so the widget layer threads the translation in.
  final String youLabel;

  MultiplayerBoardPainter({
    required this.snapshot,
    required this.previousSnapshot,
    required this.currentUserId,
    required this.theme,
    required this.pulseAnimation,
    required this.moveProgress,
    required this.boardSize,
    this.youLabel = 'You',
  }) : super(repaint: pulseAnimation);

  static const Color _rivalInk = Color(0xFF2A0705);

  @override
  void paint(Canvas canvas, Size size) {
    final palette = LBPalette.of(theme);
    final cellWidth = size.width / boardSize;
    final cellHeight = size.height / boardSize;

    // Draw food first (below snakes)
    _drawFood(canvas, cellWidth, cellHeight);

    // Rivals first, you last: where the snakes overlap at a collision your
    // own head is the one that stays readable.
    final ordered = [
      ...snapshot.players.where((p) => p.userId != currentUserId),
      ...snapshot.players.where((p) => p.userId == currentUserId),
    ];

    final drawn = <(MatchPlayerState, List<Offset>)>[];
    for (final player in ordered) {
      if (player.body.isEmpty) continue;
      drawn.add((
        player,
        _interpolatedCenters(
          player,
          previousSnapshot?.playerByIndex(player.playerIndex),
          cellWidth,
          cellHeight,
        ),
      ));
    }

    for (final (player, centers) in drawn) {
      _drawSnake(
        canvas,
        centers,
        player.direction,
        player.alive,
        palette,
        cellWidth,
        cellHeight,
        isCurrentPlayer: player.userId == currentUserId,
      );
    }

    // Name tags last, placed where no snake is: a tag painted over a body
    // hides the very cells the player is reading.
    final occupied = <Rect>[
      for (final (_, centers) in drawn)
        for (final c in centers)
          Rect.fromCenter(center: c, width: cellWidth, height: cellHeight),
    ];
    for (final (player, centers) in drawn) {
      final isCurrentPlayer = player.userId == currentUserId;
      _drawNameTag(
        canvas,
        centers.first,
        isCurrentPlayer ? youLabel : player.username,
        isCurrentPlayer ? palette.lime : LB.rival,
        cellWidth,
        cellHeight,
        occupied,
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
    final c = Offset(
      foodPos.x * cellWidth + cellWidth / 2,
      foodPos.y * cellHeight + cellHeight / 2,
    );
    final cell = math.min(cellWidth, cellHeight);
    // A gentle breath, a third of the legacy pulse's swing.
    final breath = 1 + (pulseAnimation.value - 1) * .35;

    // Living Board: food sits in a soft gold glow, so a reward always reads
    // as gold on every theme.
    canvas.drawCircle(
      c,
      cell * .5,
      Paint()
        ..color = LB.foodGlow.withValues(alpha: .35)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * .3),
    );

    final radius = cell * .32 * breath;
    canvas.drawCircle(
      c,
      radius,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-.35, -.35),
          colors: [LB.appleHighlight, LB.apple, Color.lerp(LB.apple, Colors.black, .25)!],
          stops: const [0.0, .45, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: radius)),
    );
  }

  void _drawSnake(
    Canvas canvas,
    List<Offset> centers,
    Direction direction,
    bool isAlive,
    LBPalette palette,
    double cellWidth,
    double cellHeight, {
    required bool isCurrentPlayer,
  }) {
    if (centers.isEmpty) return;
    final cell = math.min(cellWidth, cellHeight);
    final n = centers.length;

    // cell − 2 at the 20-unit reference cell, same as the single-player
    // Living Board snake.
    final side = cell * .9;
    Rect rectAt(Offset c) => Rect.fromCenter(center: c, width: side, height: side);

    var bodyColor = isCurrentPlayer ? palette.lime : LB.rival;
    var headColor = isCurrentPlayer ? palette.head : LB.rivalHead;
    if (!isAlive) {
      // A crashed snake fades into the board; its head says why it stopped.
      bodyColor = Color.lerp(bodyColor, palette.board, .55)!;
      headColor = LB.bonk;
    }

    final bodyPaint = Paint();
    final bodyRadius = Radius.circular(cell * .15);
    for (var i = n - 1; i >= 1; i--) {
      final t = n <= 1 ? 0.0 : i / (n - 1);
      bodyPaint.color = bodyColor.withValues(alpha: 1 - .55 * t);
      canvas.drawRRect(RRect.fromRectAndRadius(rectAt(centers[i]), bodyRadius), bodyPaint);
    }

    final head = rectAt(centers.first);
    if (isAlive) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(head.inflate(cell * .12), Radius.circular(cell * .3)),
        Paint()
          ..color = headColor.withValues(alpha: .45)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, cell * .3),
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(head, Radius.circular(cell * .25)),
      Paint()..color = headColor,
    );

    if (!isAlive) {
      final c = head.center;
      final r = head.width * .2;
      final x = Paint()
        ..color = _rivalInk
        ..strokeWidth = head.width * .12
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(c + Offset(-r, -r), c + Offset(r, r), x);
      canvas.drawLine(c + Offset(r, -r), c + Offset(-r, r), x);
    } else {
      final ink = Paint()..color = isCurrentPlayer ? palette.onLime : _rivalInk;
      final eyeR = head.width * .085;
      final f = head.width * .2;
      final sp = head.width * .19;
      final c = head.center;
      final (Offset a, Offset b) = switch (direction) {
        Direction.right => (c + Offset(f, -sp), c + Offset(f, sp)),
        Direction.left => (c + Offset(-f, -sp), c + Offset(-f, sp)),
        Direction.up => (c + Offset(-sp, -f), c + Offset(sp, -f)),
        Direction.down => (c + Offset(-sp, f), c + Offset(sp, f)),
      };
      canvas.drawCircle(a, eyeR, ink);
      canvas.drawCircle(b, eyeR, ink);
    }

  }

  /// The snake's name: small uppercase mono in the snake's colour, no
  /// shadow (render 19). Tried above the head, then below, then beside it,
  /// and placed at the first spot no snake covers.
  void _drawNameTag(
    Canvas canvas,
    Offset head,
    String name,
    Color color,
    double cellWidth,
    double cellHeight,
    List<Rect> occupied,
  ) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: name.toUpperCase(),
        style: TextStyle(
          fontFamily: LB.font,
          fontFamilyFallback: LB.fontFallback,
          color: color.withValues(alpha: .7),
          fontSize: cellWidth * .5,
          fontWeight: FontWeight.w800,
          letterSpacing: cellWidth * .08,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '…',
    );
    // Cap the label at ~7 cells so long usernames ellipsize instead of
    // spilling across the board.
    textPainter.layout(maxWidth: cellWidth * 7);

    final board = cellWidth * boardSize;
    final w = textPainter.width;
    final h = textPainter.height;
    final gap = cellHeight * .3;

    // Clamped inside the board so edge/corner snakes keep readable labels.
    Offset clampIn(Offset o) => Offset(
          o.dx.clamp(2.0, math.max(2.0, board - w - 2.0)).toDouble(),
          o.dy.clamp(2.0, math.max(2.0, board - h - 2.0)).toDouble(),
        );

    final candidates = [
      Offset(head.dx - w / 2, head.dy - cellHeight / 2 - gap - h),
      Offset(head.dx - w / 2, head.dy + cellHeight / 2 + gap),
      Offset(head.dx + cellWidth / 2 + gap, head.dy - h / 2),
      Offset(head.dx - cellWidth / 2 - gap - w, head.dy - h / 2),
    ].map(clampIn).toList();

    var at = candidates.first;
    for (final c in candidates) {
      final r = (c & Size(w, h)).deflate(1);
      if (!occupied.any(r.overlaps)) {
        at = c;
        break;
      }
    }
    textPainter.paint(canvas, at);
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
