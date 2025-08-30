import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';

class AnimatedSnakeLogo extends StatefulWidget {
  final GameTheme theme;
  final AnimationController controller;
  final double size;

  const AnimatedSnakeLogo({
    super.key,
    required this.theme,
    required this.controller,
    this.size = 120,
  });

  @override
  State<AnimatedSnakeLogo> createState() => _AnimatedSnakeLogoState();
}

class _AnimatedSnakeLogoState extends State<AnimatedSnakeLogo>
    with SingleTickerProviderStateMixin {
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05, // Reduced for smoother animation
    ).animate(CurvedAnimation(
      parent: widget.controller,
      curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
    ));
  }


  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: widget.controller,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value * _pulseAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.theme.accentColor.withValues(alpha: 0.1),
                    widget.theme.backgroundColor.withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: widget.theme.accentColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: SnakeLogoPainter(
                    theme: widget.theme,
                    animationValue: widget.controller.value,
                  ),
                  size: Size(widget.size, widget.size),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class SnakeLogoPainter extends CustomPainter {
  final GameTheme theme;
  final double animationValue;

  SnakeLogoPainter({
    required this.theme,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.3;
    
    // Draw animated snake in a spiral pattern
    _drawSnakeSpiral(canvas, center, radius);
    
    // Draw food/apple in center
    _drawFood(canvas, center);
  }

  void _drawSnakeSpiral(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = theme.snakeColor
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final path = Path();
    const segments = 20;
    final animatedSegments = (segments * animationValue).round();
    
    for (int i = 0; i < animatedSegments; i++) {
      final t = i / segments;
      final angle = t * 4 * math.pi; // Two full spirals
      final currentRadius = radius * (1 - t * 0.6); // Spiral inward
      
      final x = center.dx + currentRadius * math.cos(angle);
      final y = center.dy + currentRadius * math.sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
    
    // Draw snake head if animation is far enough
    if (animationValue > 0.8) {
      final headT = animatedSegments / segments;
      final headAngle = headT * 4 * math.pi;
      final headRadius = radius * (1 - headT * 0.6);
      
      final headX = center.dx + headRadius * math.cos(headAngle);
      final headY = center.dy + headRadius * math.sin(headAngle);
      
      // Draw head circle
      final headPaint = Paint()
        ..color = theme.snakeColor
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(headX, headY), 6, headPaint);
      
      // Draw eyes
      final eyePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(headX - 2, headY - 2), 1.5, eyePaint);
      canvas.drawCircle(Offset(headX + 2, headY - 2), 1.5, eyePaint);
    }
  }

  void _drawFood(Canvas canvas, Offset center) {
    if (animationValue > 0.5) {
      final foodPaint = Paint()
        ..color = theme.foodColor
        ..style = PaintingStyle.fill;
      
      final foodRadius = 4 * (animationValue - 0.5) * 2; // Scale in after snake
      canvas.drawCircle(center, foodRadius, foodPaint);
      
      // Add shine effect
      if (animationValue > 0.7) {
        final shinePaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.6)
          ..style = PaintingStyle.fill;
        
        canvas.drawCircle(
          Offset(center.dx - 1, center.dy - 1),
          foodRadius * 0.3,
          shinePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SnakeLogoPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
           oldDelegate.theme != theme;
  }
}