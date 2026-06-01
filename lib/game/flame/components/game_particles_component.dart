import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:snake_classic/game/flame/snake_flame_game.dart';
import 'package:snake_classic/widgets/advanced_particle_system.dart'
    show ParticleConfig, ParticleData, ParticleType, ParticleBlendMode;

/// Flame-native explosion/collection particles.
///
/// Replaces the legacy `AdvancedParticleSystem` widget: the particle list, its
/// physics integration and rendering all live in this component, driven by the
/// game loop ([update]/[render]) instead of a Flutter `AnimationController`.
/// The proven [ParticleConfig] presets and [ParticleData] physics are reused;
/// emissions are triggered by [SnakeFlameGame]'s event detection via [emitAt].
///
/// Coordinates are world pixel-space (matching the board renderer), so a burst
/// at a cell maps to `cell * cellSize + cellSize / 2`.
class GameParticlesComponent extends Component
    with HasGameReference<SnakeFlameGame> {
  GameParticlesComponent() : super(priority: 2);

  final List<ParticleData> _particles = [];
  final math.Random _random = math.Random();

  /// Spawn a burst of [config]'s particles at [position] (world pixels).
  void emitAt(Offset position, ParticleConfig config) {
    for (var i = 0; i < config.count; i++) {
      final double angle;
      if (config.useRandomDirections) {
        angle = _random.nextDouble() * config.emissionAngleRange -
            (config.emissionAngleRange / 2);
      } else {
        angle = (i / config.count) * config.emissionAngleRange -
            (config.emissionAngleRange / 2);
      }
      final speed = config.minSpeed +
          _random.nextDouble() * (config.maxSpeed - config.minSpeed);
      final size = config.minSize +
          _random.nextDouble() * (config.maxSize - config.minSize);
      final color = config.colors[_random.nextInt(config.colors.length)];

      _particles.add(ParticleData(
        config: config,
        x: position.dx,
        y: position.dy,
        vx: math.cos(angle) * speed,
        vy: math.sin(angle) * speed,
        size: size,
        color: color,
        rotation: _random.nextDouble() * math.pi * 2,
        rotationSpeed: (_random.nextDouble() - 0.5) * 4.0,
      ));
    }
  }

  @override
  void update(double dt) {
    _particles.removeWhere((p) {
      p.update(dt);
      return p.isDead;
    });
  }

  @override
  void render(Canvas canvas) {
    for (final particle in _particles) {
      if (particle.life <= 0) continue;

      final paint = Paint()
        ..color = particle.color
        ..isAntiAlias = true;
      switch (particle.config.blendMode) {
        case ParticleBlendMode.additive:
          paint.blendMode = BlendMode.plus;
        case ParticleBlendMode.multiply:
          paint.blendMode = BlendMode.multiply;
        case ParticleBlendMode.screen:
          paint.blendMode = BlendMode.screen;
        case ParticleBlendMode.normal:
          paint.blendMode = BlendMode.srcOver;
      }

      if (particle.config.hasTrail && particle.trail.isNotEmpty) {
        _drawTrail(canvas, particle);
      }

      switch (particle.config.type) {
        case ParticleType.sparkle:
          _drawSparkle(canvas, particle, paint);
        case ParticleType.explosion:
        case ParticleType.food:
        case ParticleType.score:
        case ParticleType.powerUp:
        case ParticleType.trail:
        case ParticleType.smoke:
        case ParticleType.glow:
          _drawCircleParticle(canvas, particle, paint);
      }
    }
  }

  void _drawCircleParticle(Canvas canvas, ParticleData particle, Paint paint) {
    if (particle.config.type == ParticleType.powerUp ||
        particle.config.type == ParticleType.explosion) {
      final glowPaint = Paint()
        ..color = particle.color.withValues(alpha: particle.color.a * 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
        ..isAntiAlias = true;
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 1.5,
        glowPaint,
      );
    }

    canvas.drawCircle(Offset(particle.x, particle.y), particle.size, paint);

    if (particle.config.type == ParticleType.food ||
        particle.config.type == ParticleType.score) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.6 * particle.life)
        ..isAntiAlias = true;
      canvas.drawCircle(
        Offset(particle.x, particle.y),
        particle.size * 0.4,
        highlightPaint,
      );
    }
  }

  void _drawSparkle(Canvas canvas, ParticleData particle, Paint paint) {
    final center = Offset(particle.x, particle.y);
    final size = particle.size;
    final path = Path()
      ..moveTo(center.dx, center.dy - size)
      ..lineTo(center.dx, center.dy + size)
      ..moveTo(center.dx - size, center.dy)
      ..lineTo(center.dx + size, center.dy)
      ..moveTo(center.dx - size * 0.7, center.dy - size * 0.7)
      ..lineTo(center.dx + size * 0.7, center.dy + size * 0.7)
      ..moveTo(center.dx + size * 0.7, center.dy - size * 0.7)
      ..lineTo(center.dx - size * 0.7, center.dy + size * 0.7);
    paint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawPath(path, paint);
  }

  void _drawTrail(Canvas canvas, ParticleData particle) {
    if (particle.trail.length < 2) return;
    final path = Path()
      ..moveTo(particle.trail.first.dx, particle.trail.first.dy);
    for (var i = 1; i < particle.trail.length; i++) {
      path.lineTo(particle.trail[i].dx, particle.trail[i].dy);
    }
    final trailPaint = Paint()
      ..color = particle.color.withValues(alpha: particle.life * 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = particle.size * 0.5
      ..isAntiAlias = true;
    canvas.drawPath(path, trailPaint);
  }
}
