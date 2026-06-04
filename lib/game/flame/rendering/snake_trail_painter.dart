import 'dart:math' as math;
import 'package:flutter/material.dart';

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
    // Modernized: 4 halo layers with proper falloff (outer wider/dimmer,
    // inner tighter/brighter), capped by a bright white-tinted core for
    // a "lit from within" look. The previous version had thin halos and
    // a low-saturation core; this reads as actual luminance.
    for (final segment in segments) {
      final ageFactor =
          1.0 - (segment.age(currentTimeSeconds) / 0.8).clamp(0.0, 1.0);

      // Outer-to-inner halo layers: wider radius + softer alpha at outer,
      // tighter radius + stronger alpha inward.
      const layerCount = 4;
      for (int layer = layerCount; layer > 0; layer--) {
        final ringFrac = layer / layerCount; // 1.0 outer → 0.25 inner
        final layerSize = segment.size * (0.6 + ringFrac * 1.6);
        final layerAlpha = segment.color.a * ageFactor *
            (0.18 + (1 - ringFrac) * 0.42); // brighter inside
        final paint = Paint()
          ..color = segment.color.withValues(alpha: layerAlpha)
          ..maskFilter = MaskFilter.blur(
              BlurStyle.normal, layerSize * (0.20 + ringFrac * 0.30))
          ..isAntiAlias = true;
        canvas.drawCircle(segment.position, layerSize, paint);
      }

      // Bright inner core — slightly white-mixed to give the
      // signature "incandescent" pop instead of pure-color flatness.
      final core = Color.lerp(segment.color, Colors.white, 0.35)!
          .withValues(alpha: ageFactor * 0.95);
      canvas.drawCircle(
        segment.position,
        segment.size * 0.32,
        Paint()
          ..color = core
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6)
          ..isAntiAlias = true,
      );
    }
  }

  void _paintParticleTrail(Canvas canvas) {
    // Modernized: particles drift OUTWARD as they age (instead of orbiting
    // a static radius), size shrinks with age, brightness falls off with
    // distance. The previous version had particles glued to the segment;
    // this gives a real "leaving a sparkle trail" feel.
    final random = math.Random(42);
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final age = segment.age(currentTimeSeconds);
      final ageFactor = 1.0 - (age / 0.8).clamp(0.0, 1.0);

      // 4 particles per segment with deterministic angular offsets so
      // each segment has its own spawn pattern.
      for (int p = 0; p < 4; p++) {
        final baseAngle = (i + p) * (math.pi * 2 / 5) +
            animationValue * math.pi * 1.4;
        // Drift radius scales with the segment's age — particles
        // expand away from the snake as they fade.
        final drift = segment.size * (0.4 + age * 6.0) *
            (0.6 + random.nextDouble() * 0.5);
        final px = segment.position.dx + math.cos(baseAngle) * drift;
        final py = segment.position.dy + math.sin(baseAngle) * drift;
        final particleSize = segment.size * (0.35 - age * 0.6).clamp(0.05, 0.4);

        // Bright white-tinted spark on a colored halo for sparkle pop.
        final hot = Color.lerp(segment.color, Colors.white, 0.55)!
            .withValues(alpha: ageFactor * 0.95);
        canvas.drawCircle(
          Offset(px, py),
          particleSize * 1.6,
          Paint()
            ..color = segment.color.withValues(alpha: ageFactor * 0.45)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5)
            ..isAntiAlias = true,
        );
        canvas.drawCircle(
          Offset(px, py),
          particleSize,
          Paint()..color = hot..isAntiAlias = true,
        );
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
    // Modernized: 3-layer rainbow halo, color shifts faster across the
    // body so the user sees a moving prism, plus a bright white core
    // on each segment so the trail reads as an energetic flowing arc.
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor =
          1.0 - (segment.age(currentTimeSeconds) / 1.0).clamp(0.0, 1.0);

      final hue = (animationValue * 540 + i * 22) % 360;
      final rainbowColor =
          HSVColor.fromAHSV(ageFactor, hue, 1.0, 1.0).toColor();

      // Outer wide halo — soft saturated bloom.
      canvas.drawCircle(
        segment.position,
        segment.size * 2.0,
        Paint()
          ..color = rainbowColor.withValues(alpha: ageFactor * 0.30)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
      );
      // Mid halo — punchier.
      canvas.drawCircle(
        segment.position,
        segment.size * 1.2,
        Paint()
          ..color = rainbowColor.withValues(alpha: ageFactor * 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Hard color body.
      canvas.drawCircle(
        segment.position,
        segment.size * 0.7,
        Paint()..color = rainbowColor..isAntiAlias = true,
      );
      // Bright white core — gives every segment a sparkle highlight.
      canvas.drawCircle(
        segment.position,
        segment.size * 0.28,
        Paint()
          ..color = Colors.white.withValues(alpha: ageFactor * 0.95)
          ..isAntiAlias = true,
      );
    }
  }

  void _paintFireTrail(Canvas canvas) {
    // Modernized: 4-layer flame (deep red → orange → gold → white-hot
    // tip) with stronger flicker, PLUS independent ember sparks that
    // drift upward from each segment with their own lifecycle. The
    // upward drift comes from the segment's age, so the older the
    // segment the higher its embers — gives the trail a true rising-
    // heat feel instead of a static-positioned flame stack.
    final emberRng = math.Random(99);
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final age = segment.age(currentTimeSeconds);
      final ageFactor = 1.0 - (age / 0.6).clamp(0.0, 1.0);
      final flicker =
          0.85 + 0.15 * math.sin(animationValue * math.pi * 12 + i * 1.7);
      final fireSize = segment.size * flicker * ageFactor;

      // Flame layers — innermost is brightest, outermost is most
      // saturated red. Each layer offsets slightly upward for the
      // teardrop flame shape.
      final layers = <(Color, double)>[
        (const Color(0xFFB00000).withValues(alpha: ageFactor * 0.85), 1.10),
        (const Color(0xFFFF6A00).withValues(alpha: ageFactor * 0.78), 0.85),
        (const Color(0xFFFFB400).withValues(alpha: ageFactor * 0.70), 0.60),
        (const Color(0xFFFFF1B0).withValues(alpha: ageFactor * 0.90), 0.32),
      ];
      for (var layer = 0; layer < layers.length; layer++) {
        final (color, sizeMul) = layers[layer];
        final layerSize = fireSize * sizeMul;
        final paint = Paint()
          ..color = color
          ..maskFilter = MaskFilter.blur(
              BlurStyle.normal, math.max(0.8, layerSize * 0.22))
          ..isAntiAlias = true;
        canvas.drawCircle(
          Offset(segment.position.dx, segment.position.dy - layer * 2.5),
          layerSize,
          paint,
        );
      }

      // Rising ember sparks — drift upward with age, scatter
      // horizontally. Older segments emit higher embers; newest
      // segments emit none yet (so the snake head looks clean).
      if (age > 0.05) {
        for (var s = 0; s < 2; s++) {
          final emberAge = (age * 1.3 + s * 0.18).clamp(0.0, 1.0);
          final emberFade = (1.0 - emberAge).clamp(0.0, 1.0);
          final wobble =
              math.sin(animationValue * math.pi * 6 + i * 2 + s) * 3.0;
          final dx = segment.position.dx +
              wobble +
              (emberRng.nextDouble() - 0.5) * 4;
          final dy = segment.position.dy - emberAge * 22 - 4;
          canvas.drawCircle(
            Offset(dx, dy),
            (1.4 - emberAge * 0.7).clamp(0.4, 1.4),
            Paint()
              ..color = Color.lerp(
                      const Color(0xFFFFD86A),
                      const Color(0xFFFF4500),
                      emberAge)!
                  .withValues(alpha: emberFade * 0.85)
              ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5)
              ..isAntiAlias = true,
          );
        }
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
    // Modernized: each segment now has a colored outer halo + a hard
    // bright core. Color smoothly lerps along the snake (lime→pink)
    // instead of hard-alternating, and the halo size pulses with the
    // animation. Reads as a neon-sign "buzz" instead of a stiff
    // checker pattern.
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final ageFactor =
          1.0 - (segment.age(currentTimeSeconds) / 0.7).clamp(0.0, 1.0);

      // Smooth color lerp using a sine-shifted t per segment so the
      // gradient flows along the snake instead of strict alternation.
      final t = (math.sin(i * 0.45 + animationValue * math.pi * 2) + 1) * 0.5;
      final color = Color.lerp(
          const Color(0xFF39FF14), const Color(0xFFFF1493), t)!;

      final pulse =
          0.85 + 0.15 * math.sin(animationValue * math.pi * 6 + i * 0.7);

      // Wide colored halo — the buzz.
      canvas.drawCircle(
        segment.position,
        segment.size * 1.6 * pulse,
        Paint()
          ..color = color.withValues(alpha: ageFactor * 0.55)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
      // Tight saturated body — the tube.
      canvas.drawCircle(
        segment.position,
        segment.size * 0.55,
        Paint()
          ..color = color.withValues(alpha: ageFactor * 0.95)
          ..isAntiAlias = true,
      );
      // White-hot inner filament.
      canvas.drawCircle(
        segment.position,
        segment.size * 0.22,
        Paint()
          ..color = Colors.white.withValues(alpha: ageFactor * 0.95)
          ..isAntiAlias = true,
      );
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
