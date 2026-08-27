import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// The level gauge, as a snake crawling toward an apple.
///
/// A progress bar in a snake game had no business being a plain bar. This is
/// the same information — how far through the current level you are — drawn as
/// the thing the player is already looking at: a chain of grid cells with a
/// head on the front, an apple parked at the far end, and the gap between them
/// closing as the score climbs.
///
/// It reads at a glance in peripheral vision (cells are coarse, so you see
/// "about two thirds" without focusing) and it rewards a closer look: the head
/// has eyes, and it bobs when it is nearly there. The cell grid deliberately
/// echoes the board, so level progress looks like tiles travelled.
///
/// Motion is gated to the last 20% of a level. The strip is static for most of
/// a run so it costs nothing, and when it does move it means "you are about to
/// level up" — the one moment the movement earns its frame.
class LevelProgressRail extends StatefulWidget {
  const LevelProgressRail({
    super.key,
    required this.value,
    required this.snakeColor,
    required this.foodColor,
    required this.trackColor,
    required this.height,
  });

  /// 0..1 through the current level.
  final double value;

  /// The body colour — the player's own snake, so the rail is *their* run.
  final Color snakeColor;

  /// The apple waiting at the finish.
  final Color foodColor;

  /// Track border and glow colour.
  final Color trackColor;

  final double height;

  /// Past this the rail warms to amber, the head bobs, the apple pulses.
  static const double nearThreshold = 0.8;

  @override
  State<LevelProgressRail> createState() => _LevelProgressRailState();
}

class _LevelProgressRailState extends State<LevelProgressRail>
    with SingleTickerProviderStateMixin {
  late final AnimationController _idle;

  bool get _isNear => widget.value >= LevelProgressRail.nearThreshold;

  @override
  void initState() {
    super.initState();
    _idle = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _sync();
  }

  @override
  void didUpdateWidget(LevelProgressRail oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  /// Only spin the ticker inside the level-up approach. Everywhere else this
  /// widget is a static repaint that fires when the score changes.
  void _sync() {
    if (_isNear && !_idle.isAnimating) {
      _idle.repeat();
    } else if (!_isNear && _idle.isAnimating) {
      _idle.stop();
      _idle.reset();
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mirror = Directionality.of(context) == TextDirection.rtl;

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: AnimatedBuilder(
        animation: _idle,
        builder: (context, _) {
          return CustomPaint(
            painter: _RailPainter(
              value: widget.value.clamp(0.0, 1.0),
              snakeColor: widget.snakeColor,
              foodColor: widget.foodColor,
              trackColor: widget.trackColor,
              // Phase is only read when near, so a stopped ticker sitting at 0
              // is a perfectly still snake rather than a frozen mid-bob one.
              phase: _isNear ? _idle.value : 0.0,
              isNear: _isNear,
              mirror: mirror,
            ),
          );
        },
      ),
    );
  }
}

class _RailPainter extends CustomPainter {
  _RailPainter({
    required this.value,
    required this.snakeColor,
    required this.foodColor,
    required this.trackColor,
    required this.phase,
    required this.isNear,
    required this.mirror,
  });

  final double value;
  final Color snakeColor;
  final Color foodColor;
  final Color trackColor;
  final double phase;
  final bool isNear;
  final bool mirror;

  static const Color _amber = Color(0xFFFFC107);
  static const Color _black = Color(0xFF000000);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    canvas.save();
    if (mirror) {
      // Arabic reads right to left, and so should the crawl. Mirroring the
      // canvas keeps one set of geometry instead of two.
      canvas.translate(size.width, 0);
      canvas.scale(-1, 1);
    }

    final h = size.height;

    // --- the track ---
    final track = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(h / 2),
    );
    canvas.drawRRect(track, Paint()..color = _black.withValues(alpha: 0.34));
    canvas.drawRRect(
      track.deflate(0.4),
      Paint()
        ..color = trackColor.withValues(alpha: isNear ? 0.42 : 0.26)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // --- the apple, parked at the finish ---
    final pulse = isNear
        ? 1.0 + math.sin(phase * math.pi * 2).abs() * 0.16
        : 1.0;
    final appleR = (h * 0.40) * pulse;
    final appleCx = size.width - h * 0.5;
    final appleCy = h / 2;
    canvas.drawCircle(
      Offset(appleCx, appleCy),
      appleR * 2.0,
      Paint()
        ..color = foodColor.withValues(alpha: isNear ? 0.30 : 0.16)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    canvas.drawCircle(Offset(appleCx, appleCy), appleR, Paint()..color = foodColor);

    // --- the body ---
    // Everything left of the apple is the snake's lane. Cells are sized a
    // touch wider than tall so they read as segments rather than dots, and the
    // count is clamped so a narrow rail does not turn to mush and a wide one
    // does not become a barcode.
    final lane = appleCx - h * 0.55;
    if (lane <= 0) {
      canvas.restore();
      return;
    }
    final cells = (lane / (h * 1.15)).round().clamp(6, 30);
    final pitch = lane / cells;
    final cellW = pitch * 0.78;
    final cellH = h * 0.62;
    final top = (h - cellH) / 2;

    // Nearly all the way to amber, not most of the way: a 0.75 lerp from a
    // green or cyan snake lands on olive, which reads as "dull" rather than
    // "about to level up". The player's colour still tints it.
    final body = isNear ? Color.lerp(snakeColor, _amber, 0.9)! : snakeColor;

    final filled = value * cells;
    final full = filled.floor();
    final frac = filled - full;

    // Tail-to-head alpha ramp gives the chain a direction, so which end is
    // moving is obvious even in a still screenshot.
    for (var i = 0; i < full && i < cells; i++) {
      final t = cells <= 1 ? 1.0 : i / (cells - 1);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(i * pitch, top, cellW, cellH),
          Radius.circular(cellH * 0.35),
        ),
        Paint()..color = body.withValues(alpha: 0.55 + 0.45 * t),
      );
    }

    // --- the head ---
    // Drawn even at zero progress: a snake waiting at the start line is a
    // better empty state than an empty bar. It never shrinks below a third of
    // a cell, so it stays a head rather than becoming a sliver.
    final headIndex = math.min(full, cells - 1);
    final grow = full >= cells ? 1.0 : math.max(0.34, frac);
    final bob = isNear ? math.sin(phase * math.pi * 2) * (h * 0.10) : 0.0;
    final headW = cellW * grow;
    final headRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(headIndex * pitch, top + bob, headW, cellH),
      Radius.circular(cellH * 0.42),
    );
    canvas.drawRRect(
      headRect,
      Paint()
        ..color = body.withValues(alpha: 0.45)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );
    canvas.drawRRect(headRect, Paint()..color = body);

    // Eyes, once the head is wide enough to hold them. Two dots at about a
    // pixel are not information — they are the reason someone looks twice at a
    // progress bar.
    final eyeR = h * 0.085;
    if (headW > eyeR * 5 && cellH > 3) {
      final eyeX = headIndex * pitch + headW - eyeR * 1.9;
      final eyePaint = Paint()..color = _black.withValues(alpha: 0.72);
      canvas.drawCircle(Offset(eyeX, top + bob + cellH * 0.30), eyeR, eyePaint);
      canvas.drawCircle(Offset(eyeX, top + bob + cellH * 0.70), eyeR, eyePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_RailPainter old) =>
      old.value != value ||
      old.phase != phase ||
      old.isNear != isNear ||
      old.mirror != mirror ||
      old.snakeColor != snakeColor ||
      old.foodColor != foodColor ||
      old.trackColor != trackColor;
}
