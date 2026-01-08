import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';

/// Reusable background widget that provides consistent app-wide background styling
class AppBackground extends StatelessWidget {
  final Widget child;
  final GameTheme theme;
  final bool showPattern;

  const AppBackground({
    super.key,
    required this.child,
    required this.theme,
    this.showPattern = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            theme.accentColor.withValues(alpha: 0.15),
            theme.backgroundColor,
            theme.backgroundColor.withValues(alpha: 0.9),
            Colors.black.withValues(alpha: 0.1),
          ],
          stops: const [0.0, 0.4, 0.8, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern overlay
          if (showPattern)
            Positioned.fill(
              child: CustomPaint(painter: _AppBackgroundPainter(theme)),
            ),

          // Child content
          child,
        ],
      ),
    );
  }
}

/// Background painter that creates the subtle pattern overlay
class _AppBackgroundPainter extends CustomPainter {
  final GameTheme theme;

  _AppBackgroundPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = theme.accentColor.withValues(alpha: 0.05);

    // Draw subtle grid pattern
    const gridSize = 30.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw decorative shapes
    final shapePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = theme.foodColor.withValues(alpha: 0.02);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.25),
      50,
      shapePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      70,
      shapePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _AppBackgroundPainter || oldDelegate.theme != theme;
  }
}

/// Animated version of the background for screens that need dynamic effects
class AnimatedAppBackground extends StatefulWidget {
  final Widget child;
  final GameTheme theme;
  final bool showPattern;

  const AnimatedAppBackground({
    super.key,
    required this.child,
    required this.theme,
    this.showPattern = true,
  });

  @override
  State<AnimatedAppBackground> createState() => _AnimatedAppBackgroundState();
}

class _AnimatedAppBackgroundState extends State<AnimatedAppBackground>
    with TickerProviderStateMixin {
  late AnimationController _backgroundController;
  late Animation<double> _backgroundAnimation;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    _backgroundAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _backgroundController, curve: Curves.linear),
    );
    _backgroundController.repeat();
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.topRight,
          radius: 1.5,
          colors: [
            widget.theme.accentColor.withValues(alpha: 0.15),
            widget.theme.backgroundColor,
            widget.theme.backgroundColor.withValues(alpha: 0.9),
            Colors.black.withValues(alpha: 0.1),
          ],
          stops: const [0.0, 0.4, 0.8, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Animated background pattern
          if (widget.showPattern)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _backgroundAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: _AnimatedAppBackgroundPainter(
                      widget.theme,
                      _backgroundAnimation.value,
                    ),
                  );
                },
              ),
            ),

          // Child content
          widget.child,
        ],
      ),
    );
  }
}

/// Animated background painter with floating elements
class _AnimatedAppBackgroundPainter extends CustomPainter {
  final GameTheme theme;
  final double animationValue;

  _AnimatedAppBackgroundPainter(this.theme, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Base grid pattern
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = theme.accentColor.withValues(alpha: 0.05);

    const gridSize = 30.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Static decorative shapes
    final shapePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = theme.foodColor.withValues(alpha: 0.02);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.25),
      50,
      shapePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      70,
      shapePaint,
    );

    // Animated floating elements
    final floatingPaint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.03)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 8; i++) {
      final progress = (animationValue + i * 0.15) % 1.0;
      final x = (i * 67 + progress * 30) % size.width;
      final y = (i * 89 + math.sin(progress * math.pi * 2) * 40) % size.height;

      final opacity = (math.sin(progress * math.pi * 2) + 1) * 0.5;
      floatingPaint.color = theme.accentColor.withValues(alpha: 0.02 * opacity);

      final rect = Rect.fromCenter(center: Offset(x, y), width: 6, height: 6);

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(1)),
        floatingPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
