import 'dart:math' as math;
import 'package:flutter/material.dart';

class ParticleEffect extends StatefulWidget {
  final AnimationController controller;
  final Color color;
  final int particleCount;

  const ParticleEffect({
    super.key,
    required this.controller,
    required this.color,
    this.particleCount = 20,
  });

  @override
  State<ParticleEffect> createState() => _ParticleEffectState();
}

class _ParticleEffectState extends State<ParticleEffect> {
  late List<Particle> particles;

  @override
  void initState() {
    super.initState();
    _initializeParticles();
  }

  void _initializeParticles() {
    final random = math.Random();
    particles = List.generate(widget.particleCount, (index) {
      return Particle(
        startX: random.nextDouble(),
        startY: random.nextDouble(),
        velocityX: (random.nextDouble() - 0.5) * 2,
        velocityY: (random.nextDouble() - 0.5) * 2,
        size: random.nextDouble() * 4 + 2,
        color: widget.color.withValues(alpha: random.nextDouble()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(
            particles: particles,
            animationValue: widget.controller.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  final double startX;
  final double startY;
  final double velocityX;
  final double velocityY;
  final double size;
  final Color color;

  Particle({
    required this.startX,
    required this.startY,
    required this.velocityX,
    required this.velocityY,
    required this.size,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter({required this.particles, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final progress = animationValue;
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      if (opacity <= 0) continue;

      final x =
          particle.startX * size.width +
          particle.velocityX * size.width * progress;
      final y =
          particle.startY * size.height +
          particle.velocityY * size.height * progress;

      final paint = Paint()
        ..color = particle.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        particle.size * (1.0 - progress * 0.5),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
