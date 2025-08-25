import 'dart:math';
import 'package:flutter/material.dart';

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;
  double opacity;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
    this.opacity = 1.0,
  });
}

class ParticleSystem extends StatefulWidget {
  final Offset position;
  final Color color;
  final int particleCount;
  final Duration duration;

  const ParticleSystem({
    super.key,
    required this.position,
    required this.color,
    this.particleCount = 15,
    this.duration = const Duration(milliseconds: 1000),
  });

  @override
  State<ParticleSystem> createState() => _ParticleSystemState();
}

class _ParticleSystemState extends State<ParticleSystem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late List<Particle> _particles;
  late Random _random;

  @override
  void initState() {
    super.initState();
    _random = Random();
    _initializeParticles();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _controller.forward();
    _controller.addListener(() {
      setState(() {
        _updateParticles();
      });
    });
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Navigator.of(context).removeRouteBelow(ModalRoute.of(context)!);
      }
    });
  }

  void _initializeParticles() {
    _particles = List.generate(widget.particleCount, (index) {
      // Random velocity
      final double angle = _random.nextDouble() * 2 * pi;
      final double speed = 50 + _random.nextDouble() * 100;
      final Offset velocity = Offset(
        cos(angle) * speed,
        sin(angle) * speed,
      );

      // Random size
      final double size = 2 + _random.nextDouble() * 6;

      return Particle(
        position: widget.position,
        velocity: velocity,
        size: size,
        color: widget.color,
      );
    });
  }

  void _updateParticles() {
    for (int i = 0; i < _particles.length; i++) {
      final Particle particle = _particles[i];
      
      // Update position based on velocity
      particle.position = Offset(
        particle.position.dx + particle.velocity.dx * 0.016, // Assuming 60fps
        particle.position.dy + particle.velocity.dy * 0.016,
      );
      
      // Apply gravity
      particle.velocity = Offset(
        particle.velocity.dx * 0.98,
        particle.velocity.dy + 100 * 0.016,
      );
      
      // Fade out over time
      particle.opacity = 1.0 - _controller.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Positioned(
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
        child: CustomPaint(
          painter: ParticlePainter(_particles),
          child: Container(),
        ),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    for (final particle in particles) {
      final Paint paint = Paint()
        ..color = particle.color.withValues(alpha: particle.opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        particle.position,
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}