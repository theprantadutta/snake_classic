import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/constants.dart';

enum TrailType { none, basic, glow, particles, lightning, rainbow, fire, ice, star, cosmic, neon, shadow, dragon }

class TrailSegment {
  final Offset position;
  final double intensity; // 0.0 to 1.0
  // Performance: Use monotonic double (seconds) instead of DateTime.
  // Previously, DateTime.now() was called per-segment per-frame (100+ calls/frame).
  final double createdAtSeconds;
  final double size;
  final Color color;

  TrailSegment({
    required this.position,
    required this.intensity,
    required this.size,
    required this.color,
    required this.createdAtSeconds,
  });

  double age(double currentTimeSeconds) => currentTimeSeconds - createdAtSeconds;

  bool isExpired(double maxAge, double currentTimeSeconds) =>
      age(currentTimeSeconds) > maxAge;
}

class SnakeTrailSystem extends StatefulWidget {
  final List<Position> snakeBody;
  final TrailType trailType;
  final GameTheme theme;
  final double cellWidth;
  final double cellHeight;
  final bool isPlaying;

  const SnakeTrailSystem({
    super.key,
    required this.snakeBody,
    required this.trailType,
    required this.theme,
    required this.cellWidth,
    required this.cellHeight,
    required this.isPlaying,
  });

  @override
  State<SnakeTrailSystem> createState() => _SnakeTrailSystemState();
}

class _SnakeTrailSystemState extends State<SnakeTrailSystem>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  final List<TrailSegment> _trailSegments = [];
  // Performance: Monotonic time source - avoids 100+ DateTime.now() calls per frame
  final Stopwatch _stopwatch = Stopwatch()..start();
  double get _currentTimeSeconds => _stopwatch.elapsedMilliseconds / 1000.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animationController.addListener(_updateTrail);
    if (widget.isPlaying && widget.trailType != TrailType.none) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant SnakeTrailSystem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final shouldRun = widget.isPlaying && widget.trailType != TrailType.none;
    final wasRunning = oldWidget.isPlaying && oldWidget.trailType != TrailType.none;

    if (shouldRun && !wasRunning) {
      _animationController.repeat();
    } else if (!shouldRun && wasRunning) {
      _animationController.stop();
      // Clear stale segments so they don't flash when play resumes
      _trailSegments.clear();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _updateTrail() {
    if (!widget.isPlaying || widget.trailType == TrailType.none) {
      return;
    }

    // Add new trail segments from snake body
    _addTrailSegments();

    // Remove expired segments
    _cleanupExpiredSegments();

    setState(() {});
  }

  void _addTrailSegments() {
    if (widget.snakeBody.isEmpty) return;

    // Add trail segments for each body part
    for (int i = 0; i < widget.snakeBody.length; i++) {
      final position = widget.snakeBody[i];
      final intensity = (widget.snakeBody.length - i) / widget.snakeBody.length;

      // Convert grid position to screen position
      final screenPosition = Offset(
        position.x * widget.cellWidth + widget.cellWidth / 2,
        position.y * widget.cellHeight + widget.cellHeight / 2,
      );

      // Only add if this position isn't already recent in our trail
      final shouldAdd =
          _trailSegments.isEmpty ||
          _trailSegments.last.position.dx != screenPosition.dx ||
          _trailSegments.last.position.dy != screenPosition.dy;

      if (shouldAdd) {
        _trailSegments.add(
          TrailSegment(
            position: screenPosition,
            intensity: intensity,
            size: _getTrailSize(i),
            color: _getTrailColor(intensity),
            createdAtSeconds: _currentTimeSeconds,
          ),
        );
      }
    }

    // Limit trail length
    const maxTrailSegments = 50;
    if (_trailSegments.length > maxTrailSegments) {
      _trailSegments.removeRange(0, _trailSegments.length - maxTrailSegments);
    }
  }

  void _cleanupExpiredSegments() {
    final maxAge = _getTrailMaxAge();
    final currentTime = _currentTimeSeconds;
    _trailSegments.removeWhere((segment) => segment.isExpired(maxAge, currentTime));
  }

  double _getTrailMaxAge() {
    switch (widget.trailType) {
      case TrailType.basic:
        return 0.5;
      case TrailType.glow:
      case TrailType.particles:
        return 0.8;
      case TrailType.lightning:
      case TrailType.fire:
        return 0.6;
      case TrailType.rainbow:
      case TrailType.ice:
      case TrailType.star:
      case TrailType.shadow:
        return 1.0;
      case TrailType.cosmic:
        return 1.2;
      case TrailType.neon:
        return 0.7;
      case TrailType.dragon:
        return 0.8;
      case TrailType.none:
        return 0.0;
    }
  }

  double _getTrailSize(int bodyIndex) {
    final baseSize = math.min(widget.cellWidth, widget.cellHeight) * 0.3;
    final sizeFactor = 1.0 - (bodyIndex / widget.snakeBody.length) * 0.5;

    switch (widget.trailType) {
      case TrailType.glow:
      case TrailType.fire:
      case TrailType.cosmic:
        return baseSize * sizeFactor * 1.5;
      case TrailType.particles:
      case TrailType.star:
        return baseSize * sizeFactor * 0.8;
      case TrailType.lightning:
      case TrailType.neon:
        return baseSize * sizeFactor * 0.6;
      case TrailType.shadow:
        return baseSize * sizeFactor * 1.4;
      case TrailType.dragon:
        return baseSize * sizeFactor * 1.6;
      case TrailType.basic:
      case TrailType.rainbow:
      case TrailType.ice:
      case TrailType.none:
        return baseSize * sizeFactor;
    }
  }

  Color _getTrailColor(double intensity) {
    final baseColor = widget.theme.snakeColor;

    switch (widget.trailType) {
      case TrailType.basic:
        return baseColor.withValues(alpha: intensity * 0.6);

      case TrailType.glow:
        return baseColor.withValues(alpha: intensity * 0.8);

      case TrailType.particles:
        return baseColor.withValues(alpha: intensity * 0.7);

      case TrailType.lightning:
        return Colors.white.withValues(alpha: intensity * 0.9);

      case TrailType.rainbow:
        final hue = (_animationController.value * 360 + intensity * 60) % 360;
        return HSVColor.fromAHSV(intensity * 0.8, hue, 1.0, 1.0).toColor();

      case TrailType.fire:
        final fireIntensity = intensity * 0.8;
        return Color.lerp(
          Colors.red,
          Colors.orange,
          math.sin(_animationController.value * math.pi * 2) * 0.5 + 0.5,
        )!.withValues(alpha: fireIntensity);

      case TrailType.ice:
        return Color.lerp(
          Colors.cyan,
          Colors.lightBlueAccent,
          intensity,
        )!.withValues(alpha: intensity * 0.7);

      case TrailType.star:
        final twinkle = math.sin(_animationController.value * math.pi * 8) * 0.3 + 0.7;
        return Color.lerp(
          Colors.white,
          const Color(0xFFFFD700),
          math.sin(_animationController.value * math.pi * 4) * 0.5 + 0.5,
        )!.withValues(alpha: intensity * twinkle);

      case TrailType.cosmic:
        return Color.lerp(
          const Color(0xFF4B0082),
          const Color(0xFFDA70D6),
          math.sin(_animationController.value * math.pi * 2) * 0.5 + 0.5,
        )!.withValues(alpha: intensity * 0.8);

      case TrailType.neon:
        final isEven = (intensity * 10).toInt() % 2 == 0;
        return (isEven ? const Color(0xFF39FF14) : const Color(0xFFFF1493))
            .withValues(alpha: intensity * 0.9);

      case TrailType.shadow:
        return Color.lerp(
          const Color(0xFF2F2F2F),
          Colors.black,
          intensity,
        )!.withValues(alpha: intensity * 0.8);

      case TrailType.dragon:
        final phase = (_animationController.value * 4 + intensity * 2) % 4;
        Color dragonColor;
        if (phase < 1) {
          dragonColor = const Color(0xFF8B0000);
        } else if (phase < 2) {
          dragonColor = Colors.red[800]!;
        } else if (phase < 3) {
          dragonColor = Colors.orange;
        } else {
          dragonColor = const Color(0xFFFFD700);
        }
        return dragonColor.withValues(alpha: intensity * 0.85);

      case TrailType.none:
        return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trailType == TrailType.none || _trailSegments.isEmpty) {
      return const SizedBox.shrink();
    }

    return RepaintBoundary(
      child: CustomPaint(
        painter: SnakeTrailPainter(
          segments: _trailSegments,
          trailType: widget.trailType,
          animationValue: _animationController.value,
          currentTimeSeconds: _currentTimeSeconds,
        ),
        size: Size.infinite,
      ),
    );
  }
}

class SnakeTrailPainter extends CustomPainter {
  final List<TrailSegment> segments;
  final TrailType trailType;
  final double animationValue;
  // Performance: Pre-computed time passed once per frame instead of
  // calling DateTime.now() per segment per trail type (100+ calls/frame).
  final double currentTimeSeconds;

  SnakeTrailPainter({
    required this.segments,
    required this.trailType,
    required this.animationValue,
    required this.currentTimeSeconds,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (segments.isEmpty) return;

    switch (trailType) {
      case TrailType.basic:
        _paintBasicTrail(canvas);
        break;
      case TrailType.glow:
        _paintGlowTrail(canvas);
        break;
      case TrailType.particles:
        _paintParticleTrail(canvas);
        break;
      case TrailType.lightning:
        _paintLightningTrail(canvas);
        break;
      case TrailType.rainbow:
        _paintRainbowTrail(canvas);
        break;
      case TrailType.fire:
        _paintFireTrail(canvas);
        break;
      case TrailType.ice:
        _paintIceTrail(canvas);
        break;
      case TrailType.star:
        _paintStarTrail(canvas);
        break;
      case TrailType.cosmic:
        _paintCosmicTrail(canvas);
        break;
      case TrailType.neon:
        _paintNeonTrail(canvas);
        break;
      case TrailType.shadow:
        _paintShadowTrail(canvas);
        break;
      case TrailType.dragon:
        _paintDragonTrail(canvas);
        break;
      case TrailType.none:
        break;
    }
  }

  void _paintBasicTrail(Canvas canvas) {
    if (segments.length < 2) return;

    final path = Path();
    path.moveTo(segments.first.position.dx, segments.first.position.dy);

    for (int i = 1; i < segments.length; i++) {
      path.lineTo(segments[i].position.dx, segments[i].position.dy);
    }

    for (int i = segments.length - 1; i >= 0; i--) {
      final segment = segments[i];
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 0.5).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = segment.color.withValues(alpha: segment.color.a * ageFactor)
        ..style = PaintingStyle.stroke
        ..strokeWidth = segment.size * ageFactor
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;

      if (i > 0) {
        canvas.drawLine(segments[i - 1].position, segment.position, paint);
      }
    }
  }

  void _paintGlowTrail(Canvas canvas) {
    for (final segment in segments) {
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 0.8).clamp(0.0, 1.0);

      // Draw multiple glow layers
      for (int layer = 3; layer > 0; layer--) {
        final layerSize = segment.size * layer * 0.8;
        final layerAlpha = (segment.color.a * ageFactor * 0.3) / layer;

        final paint = Paint()
          ..color = segment.color.withValues(alpha: layerAlpha)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, layerSize * 0.3)
          ..isAntiAlias = true;

        canvas.drawCircle(segment.position, layerSize, paint);
      }

      // Draw core
      final corePaint = Paint()
        ..color = segment.color.withValues(alpha: segment.color.a * ageFactor)
        ..isAntiAlias = true;

      canvas.drawCircle(segment.position, segment.size * 0.4, corePaint);
    }
  }

  void _paintParticleTrail(Canvas canvas) {
    final random = math.Random(42); // Fixed seed for consistent pattern

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 0.8).clamp(0.0, 1.0);

      // Draw multiple small particles around the segment
      for (int p = 0; p < 3; p++) {
        final angle = (i + p) * 0.5 + animationValue * math.pi * 2;
        final radius = segment.size * 0.8;
        final particlePos = Offset(
          segment.position.dx + math.cos(angle) * radius * random.nextDouble(),
          segment.position.dy + math.sin(angle) * radius * random.nextDouble(),
        );

        final paint = Paint()
          ..color = segment.color.withValues(
            alpha:
                segment.color.a *
                ageFactor *
                (0.5 + 0.5 * math.sin(animationValue * math.pi * 4)),
          )
          ..isAntiAlias = true;

        canvas.drawCircle(particlePos, segment.size * 0.3, paint);
      }
    }
  }

  void _paintLightningTrail(Canvas canvas) {
    if (segments.length < 2) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    // Draw jagged lightning path
    for (int i = 1; i < segments.length; i++) {
      final current = segments[i];
      final previous = segments[i - 1];
      final ageFactor = 1.0 - (current.age(currentTimeSeconds) / 0.6).clamp(0.0, 1.0);

      paint.color = Colors.white.withValues(alpha: ageFactor);

      // Add some randomness to create lightning effect
      final midPoint = Offset(
        (current.position.dx + previous.position.dx) / 2 +
            (math.sin(animationValue * math.pi * 8 + i) * 5),
        (current.position.dy + previous.position.dy) / 2 +
            (math.cos(animationValue * math.pi * 6 + i) * 5),
      );

      // Draw as path with jagged edges
      final path = Path()
        ..moveTo(previous.position.dx, previous.position.dy)
        ..lineTo(midPoint.dx, midPoint.dy)
        ..lineTo(current.position.dx, current.position.dy);

      canvas.drawPath(path, paint);

      // Add glow effect
      final glowPaint = Paint()
        ..color = Colors.cyan.withValues(alpha: ageFactor * 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
        ..isAntiAlias = true;

      canvas.drawPath(path, glowPaint);
    }
  }

  void _paintRainbowTrail(Canvas canvas) {
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 1.0).clamp(0.0, 1.0);

      // Create rainbow effect
      final hue = (animationValue * 360 + i * 10) % 360;
      final rainbowColor = HSVColor.fromAHSV(
        ageFactor * 0.8,
        hue,
        1.0,
        1.0,
      ).toColor();

      // Draw with glow
      final glowPaint = Paint()
        ..color = rainbowColor.withValues(alpha: rainbowColor.a * 0.6)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8.0)
        ..isAntiAlias = true;

      canvas.drawCircle(segment.position, segment.size * 1.5, glowPaint);

      final corePaint = Paint()
        ..color = rainbowColor
        ..isAntiAlias = true;

      canvas.drawCircle(segment.position, segment.size * 0.6, corePaint);
    }
  }

  void _paintFireTrail(Canvas canvas) {
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 0.6).clamp(0.0, 1.0);

      // Create flickering fire effect
      final flicker = 0.8 + 0.2 * math.sin(animationValue * math.pi * 8 + i);
      final fireSize = segment.size * flicker * ageFactor;

      // Draw fire layers (red, orange, yellow)
      final colors = [
        Colors.red.withValues(alpha: ageFactor * 0.8),
        Colors.orange.withValues(alpha: ageFactor * 0.6),
        Colors.yellow.withValues(alpha: ageFactor * 0.4),
      ];

      for (int layer = 0; layer < colors.length; layer++) {
        final layerSize = fireSize * (1.0 - layer * 0.3);
        final paint = Paint()
          ..color = colors[layer]
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, layerSize * 0.2)
          ..isAntiAlias = true;

        // Add some vertical offset for flame shape
        final flameOffset = Offset(
          segment.position.dx,
          segment.position.dy - layer * 2,
        );

        canvas.drawCircle(flameOffset, layerSize, paint);
      }
    }
  }

  void _paintIceTrail(Canvas canvas) {
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 1.0).clamp(0.0, 1.0);

      // Create crystalline ice effect
      final sparkle =
          0.7 + 0.3 * math.sin(animationValue * math.pi * 6 + i * 2);

      // Draw ice crystal base
      final basePaint = Paint()
        ..color = Colors.lightBlueAccent.withValues(alpha: ageFactor * 0.7)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
        ..isAntiAlias = true;

      canvas.drawCircle(segment.position, segment.size * sparkle, basePaint);

      // Draw bright center
      final centerPaint = Paint()
        ..color = Colors.white.withValues(alpha: ageFactor * sparkle)
        ..isAntiAlias = true;

      canvas.drawCircle(segment.position, segment.size * 0.4, centerPaint);

      // Draw ice crystal spikes
      final spikePaint = Paint()
        ..color = Colors.cyan.withValues(alpha: ageFactor * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..isAntiAlias = true;

      for (int spike = 0; spike < 4; spike++) {
        final angle = spike * math.pi / 2 + animationValue * math.pi;
        final spikeLength = segment.size * 0.8;
        final start = segment.position;
        final end = Offset(
          start.dx + math.cos(angle) * spikeLength,
          start.dy + math.sin(angle) * spikeLength,
        );

        canvas.drawLine(start, end, spikePaint);
      }
    }
  }

  void _paintStarTrail(Canvas canvas) {
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 1.0).clamp(0.0, 1.0);

      // Twinkle alpha
      final twinkle = 0.5 + 0.5 * math.sin(animationValue * math.pi * 8 + i * 2);
      final rotation = animationValue * math.pi * 2;

      // Draw gold glow halo
      final glowPaint = Paint()
        ..color = const Color(0xFFFFD700).withValues(alpha: ageFactor * twinkle * 0.4)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, segment.size * 0.5)
        ..isAntiAlias = true;
      canvas.drawCircle(segment.position, segment.size * 1.2, glowPaint);

      // Draw 5-pointed star path
      final starPath = _createStarPath(segment.position, segment.size * 0.6, segment.size * 0.3, rotation + i * 0.5);
      final starPaint = Paint()
        ..color = Colors.white.withValues(alpha: ageFactor * twinkle)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawPath(starPath, starPaint);
    }
  }

  Path _createStarPath(Offset center, double outerRadius, double innerRadius, double rotation) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final angle = rotation + (i * math.pi / 5) - math.pi / 2;
      final radius = i.isEven ? outerRadius : innerRadius;
      final point = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  void _paintCosmicTrail(Canvas canvas) {
    final random = math.Random(42);

    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 1.2).clamp(0.0, 1.0);

      // 3-4 sub-particles per segment in spiral distribution
      final particleCount = 3 + (i % 2);
      for (int p = 0; p < particleCount; p++) {
        final spiralAngle = animationValue * math.pi * 2 + i * 0.8 + p * (math.pi * 2 / particleCount);
        final driftRadius = segment.size * (1.0 + segment.age(currentTimeSeconds) * 0.5);
        final particlePos = Offset(
          segment.position.dx + math.cos(spiralAngle) * driftRadius * random.nextDouble(),
          segment.position.dy + math.sin(spiralAngle) * driftRadius * random.nextDouble(),
        );

        // Indigo -> Orchid color shift
        final color = Color.lerp(
          const Color(0xFF4B0082),
          const Color(0xFFDA70D6),
          math.sin(animationValue * math.pi * 2 + i * 0.3) * 0.5 + 0.5,
        )!.withValues(alpha: ageFactor * 0.7);

        final paint = Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
          ..isAntiAlias = true;

        canvas.drawCircle(particlePos, segment.size * 0.4, paint);
      }
    }
  }

  void _paintNeonTrail(Canvas canvas) {
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 0.7).clamp(0.0, 1.0);

      // Alternate lime green / hot pink per segment
      final color = i % 2 == 0
          ? const Color(0xFF39FF14)
          : const Color(0xFFFF1493);

      final halfSize = segment.size * 0.5;
      final rect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: segment.position, width: halfSize * 2, height: halfSize * 2),
        const Radius.circular(3.0),
      );

      // Hard neon fill — no blur
      final fillPaint = Paint()
        ..color = color.withValues(alpha: ageFactor * 0.9)
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;
      canvas.drawRRect(rect, fillPaint);

      // Thin outline for neon sign effect
      final outlinePaint = Paint()
        ..color = Colors.white.withValues(alpha: ageFactor * 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..isAntiAlias = true;
      canvas.drawRRect(rect, outlinePaint);
    }
  }

  void _paintShadowTrail(Canvas canvas) {
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 1.0).clamp(0.0, 1.0);

      // Slight downward drift for smoke effect
      final yOffset = segment.age(currentTimeSeconds) * 3.0;

      // 3 dark layers with increasing spread
      for (int layer = 0; layer < 3; layer++) {
        final spread = segment.size * (1.0 + layer * 0.4);
        final color = Color.lerp(
          const Color(0xFF2F2F2F),
          Colors.black,
          layer / 2.0,
        )!.withValues(alpha: ageFactor * (0.5 - layer * 0.1));

        final paint = Paint()
          ..color = color
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6.0)
          ..isAntiAlias = true;

        final pos = Offset(segment.position.dx, segment.position.dy + yOffset);
        canvas.drawCircle(pos, spread, paint);
      }
    }
  }

  void _paintDragonTrail(Canvas canvas) {
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor = 1.0 - (segment.age(currentTimeSeconds) / 0.8).clamp(0.0, 1.0);

      // Sinuous S-curve distortion (higher freq than fire)
      final sineOffset = math.sin(animationValue * math.pi * 12 + i) * segment.size * 0.5;
      final cosOffset = math.cos(animationValue * math.pi * 4 + i) * segment.size * 0.3;

      // 4 color layers: dark red -> crimson -> orange -> gold
      final colors = [
        const Color(0xFF8B0000).withValues(alpha: ageFactor * 0.8),
        Colors.red[800]!.withValues(alpha: ageFactor * 0.65),
        Colors.orange.withValues(alpha: ageFactor * 0.5),
        const Color(0xFFFFD700).withValues(alpha: ageFactor * 0.35),
      ];

      for (int layer = 0; layer < colors.length; layer++) {
        final layerSize = segment.size * (1.0 - layer * 0.2);
        final flameOffset = Offset(
          segment.position.dx + cosOffset * (1.0 - layer * 0.2),
          segment.position.dy - layer * 2.5 + sineOffset * (1.0 - layer * 0.15),
        );

        final paint = Paint()
          ..color = colors[layer]
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, layerSize * 0.25)
          ..isAntiAlias = true;

        canvas.drawCircle(flameOffset, layerSize, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant SnakeTrailPainter oldDelegate) {
    return segments.length != oldDelegate.segments.length ||
        animationValue != oldDelegate.animationValue ||
        trailType != oldDelegate.trailType;
  }
}
