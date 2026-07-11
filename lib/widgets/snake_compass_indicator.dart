import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

/// The gesture chrome: a circular puck holding a miniature snake that swims
/// in place, turns to face the last accepted swipe, and dashes with a comet
/// trail in that direction's color when the swipe lands. Four cardinal ticks
/// on the puck edge light up for the active heading.
///
/// Self-animating (its own low-cost repeating controller drives the swim
/// cycle) and isolated — it never triggers game-screen rebuilds.
class SnakeCompassIndicator extends StatefulWidget {
  const SnakeCompassIndicator({
    super.key,
    required this.theme,
    required this.directionGetter,
    required this.swipeAnimation,
    required this.activeColorFor,
    required this.size,
  });

  final GameTheme theme;

  /// Read live on every animation frame (the parent doesn't rebuild on
  /// swipes, so a plain value would go stale).
  final Direction? Function() directionGetter;
  final Animation<double> swipeAnimation;
  final Color Function(Direction) activeColorFor;
  final double size;

  @override
  State<SnakeCompassIndicator> createState() => _SnakeCompassIndicatorState();
}

class _SnakeCompassIndicatorState extends State<SnakeCompassIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _swimController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _swimController.dispose();
    super.dispose();
  }

  double _headingTurns(Direction? d) => switch (d) {
        null || Direction.up => 0.0,
        Direction.right => 0.25,
        Direction.down => 0.5,
        Direction.left => 0.75,
      };

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    return Semantics(
      label: 'Swipe direction indicator',
      child: AnimatedBuilder(
        animation:
            Listenable.merge([_swimController, widget.swipeAnimation]),
        builder: (context, _) {
          final direction = widget.directionGetter();
          final swipeT = widget.swipeAnimation.value;
          final isActive = direction != null && swipeT > 0.01;
          final activeColor = direction != null
              ? widget.activeColorFor(direction)
              : widget.theme.accentColor;

          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Puck + cardinal ticks (static — do not rotate with the
                // snake, they are the compass rose).
                CustomPaint(
                  painter: _CompassPuckPainter(
                    theme: widget.theme,
                    direction: direction,
                    activeColor: activeColor,
                    glow: isActive ? swipeT : 0.0,
                  ),
                ),
                // The snake, drawn heading "up" and rotated to the real
                // heading. 200ms turn matches the old arrow's feel.
                AnimatedRotation(
                  turns: _headingTurns(direction),
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: CustomPaint(
                    painter: _MiniSnakePainter(
                      snakeColor: widget.theme.snakeColor,
                      trailColor: activeColor,
                      swimPhase: _swimController.value,
                      dash: isActive ? swipeT : 0.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CompassPuckPainter extends CustomPainter {
  _CompassPuckPainter({
    required this.theme,
    required this.direction,
    required this.activeColor,
    required this.glow,
  });

  final GameTheme theme;
  final Direction? direction;
  final Color activeColor;
  final double glow; // 0..1 swipe pulse

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // Puck body.
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()..color = theme.backgroundColor.withValues(alpha: 0.9),
    );

    // Outer glow while a swipe pulse is live.
    if (glow > 0.02) {
      canvas.drawCircle(
        center,
        radius - 1,
        Paint()
          ..color = activeColor.withValues(alpha: 0.35 * glow)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3,
      );
    }

    // Border.
    canvas.drawCircle(
      center,
      radius - 1,
      Paint()
        ..color = activeColor.withValues(alpha: 0.3 + 0.5 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Cardinal ticks; the active heading's tick is lit.
    final tickDirections = <Direction, double>{
      Direction.up: -math.pi / 2,
      Direction.right: 0,
      Direction.down: math.pi / 2,
      Direction.left: math.pi,
    };
    for (final entry in tickDirections.entries) {
      final isActiveTick = entry.key == direction;
      final tickPaint = Paint()
        ..color = isActiveTick
            ? activeColor.withValues(alpha: 0.5 + 0.5 * glow)
            : theme.accentColor.withValues(alpha: 0.25)
        ..strokeWidth = isActiveTick ? 2.5 : 1.5
        ..strokeCap = StrokeCap.round;
      final dir = Offset(math.cos(entry.value), math.sin(entry.value));
      canvas.drawLine(
        center + dir * (radius - (isActiveTick ? 6.5 : 5.0)),
        center + dir * (radius - 2.5),
        tickPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPuckPainter old) =>
      old.theme != theme ||
      old.direction != direction ||
      old.activeColor != activeColor ||
      old.glow != glow;
}

class _MiniSnakePainter extends CustomPainter {
  _MiniSnakePainter({
    required this.snakeColor,
    required this.trailColor,
    required this.swimPhase, // 0..1 repeating swim cycle
    required this.dash, // 0..1 swipe pulse (forward+reverse)
  });

  final Color snakeColor;
  final Color trailColor;
  final double swimPhase;
  final double dash;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final center = size.center(Offset.zero);
    final bodyLength = s * 0.5;
    // Dash: the snake lunges toward the heading during the swipe pulse.
    final lunge = Offset(0, -s * 0.09 * dash);

    // Sample the spine head→tail. Head at the top (the widget rotates this
    // painter to the real heading). Tail sways more than the neck.
    const samples = 9;
    final spine = List<Offset>.generate(samples, (i) {
      final t = i / (samples - 1); // 0 head → 1 tail
      final y = center.dy - bodyLength / 2 + t * bodyLength;
      final sway = s *
          0.075 *
          (0.35 + 0.65 * t) *
          math.sin(t * math.pi * 2.2 - swimPhase * 2 * math.pi);
      return Offset(center.dx + sway, y) + lunge;
    });

    // Comet trail behind the head while a swipe pulse is live.
    if (dash > 0.02) {
      final head = spine.first;
      final tailEnd = Offset(head.dx, head.dy + s * 0.42);
      final trailPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            trailColor.withValues(alpha: 0.75 * dash),
            trailColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromPoints(head, tailEnd))
        ..strokeWidth = s * 0.14
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(head, tailEnd, trailPaint);
    }

    // Body: single tapering stroke would need per-segment widths, so draw
    // tail→head with shrinking width for a natural taper.
    for (var i = spine.length - 1; i > 0; i--) {
      final t = i / (spine.length - 1);
      final segPaint = Paint()
        ..color = snakeColor.withValues(alpha: 0.55 + 0.45 * (1 - t))
        ..strokeWidth = s * (0.15 - 0.06 * t)
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawLine(spine[i], spine[i - 1], segPaint);
    }

    // Head: a slightly larger dot with two eyes.
    final head = spine.first;
    canvas.drawCircle(
      head,
      s * 0.095,
      Paint()
        ..color = snakeColor
        ..isAntiAlias = true,
    );
    final eyePaint = Paint()..color = Colors.black.withValues(alpha: 0.75);
    canvas.drawCircle(head.translate(-s * 0.035, -s * 0.03), s * 0.022,
        eyePaint);
    canvas.drawCircle(
        head.translate(s * 0.035, -s * 0.03), s * 0.022, eyePaint);
  }

  @override
  bool shouldRepaint(covariant _MiniSnakePainter old) =>
      old.snakeColor != snakeColor ||
      old.trailColor != trailColor ||
      old.swimPhase != swimPhase ||
      old.dash != dash;
}
