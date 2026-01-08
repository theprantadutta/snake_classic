import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/constants.dart';

enum TrailType { none, basic, glow, particles, lightning, rainbow, fire, ice }

class TrailSegment {
  final Offset position;
  final double intensity; // 0.0 to 1.0
  final DateTime createdAt;
  final double size;
  final Color color;

  TrailSegment({
    required this.position,
    required this.intensity,
    required this.size,
    required this.color,
  }) : createdAt = DateTime.now();

  double get age {
    return DateTime.now().difference(createdAt).inMilliseconds / 1000.0;
  }

  bool isExpired(double maxAge) => age > maxAge;
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

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
    _animationController.addListener(_updateTrail);
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
    _trailSegments.removeWhere((segment) => segment.isExpired(maxAge));
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
        return 1.0;
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
        return baseSize * sizeFactor * 1.5;
      case TrailType.particles:
        return baseSize * sizeFactor * 0.8;
      case TrailType.lightning:
        return baseSize * sizeFactor * 0.6;
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

  SnakeTrailPainter({
    required this.segments,
    required this.trailType,
    required this.animationValue,
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
      final ageFactor = 1.0 - (segment.age / 0.5).clamp(0.0, 1.0);

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
      final ageFactor = 1.0 - (segment.age / 0.8).clamp(0.0, 1.0);

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
      final ageFactor = 1.0 - (segment.age / 0.8).clamp(0.0, 1.0);

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
      final ageFactor = 1.0 - (current.age / 0.6).clamp(0.0, 1.0);

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
      final ageFactor = 1.0 - (segment.age / 1.0).clamp(0.0, 1.0);

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
      final ageFactor = 1.0 - (segment.age / 0.6).clamp(0.0, 1.0);

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
      final ageFactor = 1.0 - (segment.age / 1.0).clamp(0.0, 1.0);

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

  @override
  bool shouldRepaint(covariant SnakeTrailPainter oldDelegate) {
    return segments.length != oldDelegate.segments.length ||
        animationValue != oldDelegate.animationValue ||
        trailType != oldDelegate.trailType;
  }
}
