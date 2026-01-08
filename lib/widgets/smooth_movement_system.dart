import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/utils/constants.dart';

enum MovementCurve { linear, easeInOut, easeOut, bouncy, elastic }

class SmoothMovementController extends ChangeNotifier {
  final TickerProvider vsync;
  late AnimationController _controller;
  late Animation<double> _animation;

  MovementCurve _curve = MovementCurve.easeOut;
  Duration _moveDuration = const Duration(milliseconds: 150);

  // Interpolation state
  List<Position>? _previousPositions;
  List<Position>? _targetPositions;
  double _progress = 0.0;
  bool _isAnimating = false;

  SmoothMovementController({required this.vsync}) {
    _initializeController();
  }

  void _initializeController() {
    _controller = AnimationController(duration: _moveDuration, vsync: vsync);

    _updateAnimation();

    _controller.addListener(() {
      _progress = _animation.value;
      notifyListeners();
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _isAnimating = false;
        _previousPositions = null;
        notifyListeners();
      }
    });
  }

  void _updateAnimation() {
    Curve curve;
    switch (_curve) {
      case MovementCurve.linear:
        curve = Curves.linear;
        break;
      case MovementCurve.easeInOut:
        curve = Curves.easeInOut;
        break;
      case MovementCurve.easeOut:
        curve = Curves.easeOut;
        break;
      case MovementCurve.bouncy:
        curve = Curves.bounceOut;
        break;
      case MovementCurve.elastic:
        curve = Curves.elasticOut;
        break;
    }

    _animation = CurvedAnimation(parent: _controller, curve: curve);
  }

  void updateMovementSettings({MovementCurve? curve, Duration? duration}) {
    if (curve != null && curve != _curve) {
      _curve = curve;
      _updateAnimation();
    }

    if (duration != null && duration != _moveDuration) {
      _moveDuration = duration;
      _controller.duration = duration;
    }
  }

  void startMovement(List<Position> fromPositions, List<Position> toPositions) {
    if (_isAnimating) {
      _controller.stop();
    }

    _previousPositions = List.from(fromPositions);
    _targetPositions = List.from(toPositions);
    _isAnimating = true;

    _controller.reset();
    _controller.forward();
  }

  List<Offset> getInterpolatedPositions(double cellWidth, double cellHeight) {
    if (!_isAnimating ||
        _previousPositions == null ||
        _targetPositions == null) {
      // Return target positions if not animating
      return _targetPositions
              ?.map(
                (pos) => Offset(
                  pos.x * cellWidth + cellWidth / 2,
                  pos.y * cellHeight + cellHeight / 2,
                ),
              )
              .toList() ??
          [];
    }

    final interpolatedPositions = <Offset>[];
    final maxLength = math.max(
      _previousPositions!.length,
      _targetPositions!.length,
    );

    for (int i = 0; i < maxLength; i++) {
      late Position fromPos, toPos;

      // Handle cases where snake grows or shrinks
      if (i < _previousPositions!.length && i < _targetPositions!.length) {
        fromPos = _previousPositions![i];
        toPos = _targetPositions![i];
      } else if (i >= _previousPositions!.length) {
        // Snake grew - new segment appears at tail
        fromPos = _previousPositions!.last;
        toPos = _targetPositions![i];
      } else {
        // Snake shrunk - segment disappears (shouldn't normally happen)
        fromPos = _previousPositions![i];
        toPos = _previousPositions![i];
      }

      // Perform interpolation
      final lerpedX = fromPos.x + (toPos.x - fromPos.x) * _progress;
      final lerpedY = fromPos.y + (toPos.y - fromPos.y) * _progress;

      // Convert to screen coordinates
      final screenPos = Offset(
        lerpedX * cellWidth + cellWidth / 2,
        lerpedY * cellHeight + cellHeight / 2,
      );

      interpolatedPositions.add(screenPos);
    }

    return interpolatedPositions;
  }

  // Get interpolated position for a single segment (useful for head tracking)
  Offset? getInterpolatedHeadPosition(double cellWidth, double cellHeight) {
    if (_targetPositions == null || _targetPositions!.isEmpty) return null;

    if (!_isAnimating ||
        _previousPositions == null ||
        _previousPositions!.isEmpty) {
      final headPos = _targetPositions!.first;
      return Offset(
        headPos.x * cellWidth + cellWidth / 2,
        headPos.y * cellHeight + cellHeight / 2,
      );
    }

    final fromPos = _previousPositions!.first;
    final toPos = _targetPositions!.first;

    final lerpedX = fromPos.x + (toPos.x - fromPos.x) * _progress;
    final lerpedY = fromPos.y + (toPos.y - fromPos.y) * _progress;

    return Offset(
      lerpedX * cellWidth + cellWidth / 2,
      lerpedY * cellHeight + cellHeight / 2,
    );
  }

  double get progress => _progress;
  bool get isAnimating => _isAnimating;
  List<Position>? get previousPositions => _previousPositions;
  List<Position>? get targetPositions => _targetPositions;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// Smooth Food Animation
class SmoothFoodController extends ChangeNotifier {
  final TickerProvider vsync;
  late AnimationController _popController;
  late AnimationController _idleController;
  late Animation<double> _popAnimation;
  late Animation<double> _idleAnimation;

  bool _isVisible = false;
  Offset? _position;

  SmoothFoodController({required this.vsync}) {
    _popController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: vsync,
    );

    _idleController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: vsync,
    )..repeat();

    _popAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popController, curve: Curves.elasticOut),
    );

    _idleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _idleController, curve: Curves.easeInOut),
    );

    _popController.addListener(() => notifyListeners());
    _idleController.addListener(() => notifyListeners());
  }

  void showFood(Offset position) {
    _position = position;
    _isVisible = true;
    _popController.reset();
    _popController.forward();
    notifyListeners();
  }

  void hideFood() {
    _isVisible = false;
    _popController.reset();
    notifyListeners();
  }

  double get scale {
    if (!_isVisible) return 0.0;
    return _popAnimation.value * _idleAnimation.value;
  }

  Offset? get position => _position;
  bool get isVisible => _isVisible;

  @override
  void dispose() {
    _popController.dispose();
    _idleController.dispose();
    super.dispose();
  }
}

// Enhanced Snake Painter with Smooth Movement
class SmoothSnakePainter extends CustomPainter {
  final List<Offset> positions;
  final Color headColor;
  final Color bodyColor;
  final double headSize;
  final double bodySize;
  final bool showDirection;
  final String currentDirection;

  SmoothSnakePainter({
    required this.positions,
    required this.headColor,
    required this.bodyColor,
    required this.headSize,
    required this.bodySize,
    this.showDirection = true,
    this.currentDirection = 'right',
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (positions.isEmpty) return;

    // Draw body segments
    for (int i = 1; i < positions.length; i++) {
      _drawBodySegment(canvas, positions[i], i, positions.length);
    }

    // Draw head
    _drawHead(canvas, positions.first);
  }

  void _drawBodySegment(
    Canvas canvas,
    Offset position,
    int index,
    int totalLength,
  ) {
    final fadeFactor = (totalLength - index) / totalLength;
    final segmentSize = bodySize * (0.7 + 0.3 * fadeFactor);

    final paint = Paint()
      ..color = bodyColor.withValues(alpha: 0.6 + 0.4 * fadeFactor)
      ..isAntiAlias = true;

    // Draw shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3 * fadeFactor)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0)
      ..isAntiAlias = true;

    canvas.drawCircle(
      Offset(position.dx + 1, position.dy + 2),
      segmentSize,
      shadowPaint,
    );

    // Draw main body
    canvas.drawCircle(position, segmentSize, paint);

    // Draw highlight
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3 * fadeFactor)
      ..isAntiAlias = true;

    canvas.drawCircle(
      Offset(position.dx - segmentSize * 0.3, position.dy - segmentSize * 0.3),
      segmentSize * 0.3,
      highlightPaint,
    );
  }

  void _drawHead(Canvas canvas, Offset position) {
    // Draw head shadow
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3.0)
      ..isAntiAlias = true;

    canvas.drawCircle(
      Offset(position.dx + 2, position.dy + 3),
      headSize,
      shadowPaint,
    );

    // Draw head gradient
    final gradient = RadialGradient(
      colors: [headColor, headColor.withValues(alpha: 0.8)],
      stops: const [0.0, 1.0],
    );

    final headPaint = Paint()
      ..shader = gradient.createShader(
        Rect.fromCircle(center: position, radius: headSize),
      )
      ..isAntiAlias = true;

    canvas.drawCircle(position, headSize, headPaint);

    // Draw eyes
    _drawEyes(canvas, position);

    // Draw directional indicator
    if (showDirection) {
      _drawDirectionIndicator(canvas, position);
    }
  }

  void _drawEyes(Canvas canvas, Offset position) {
    final eyePaint = Paint()
      ..color = Colors.white
      ..isAntiAlias = true;

    final pupilPaint = Paint()
      ..color = Colors.black
      ..isAntiAlias = true;

    final eyeSize = headSize * 0.15;
    final eyeOffset = headSize * 0.4;

    // Determine eye positions based on direction
    Offset leftEye, rightEye;
    switch (currentDirection) {
      case 'up':
        leftEye = Offset(position.dx - eyeOffset, position.dy - eyeOffset);
        rightEye = Offset(position.dx + eyeOffset, position.dy - eyeOffset);
        break;
      case 'down':
        leftEye = Offset(position.dx - eyeOffset, position.dy + eyeOffset);
        rightEye = Offset(position.dx + eyeOffset, position.dy + eyeOffset);
        break;
      case 'left':
        leftEye = Offset(position.dx - eyeOffset, position.dy - eyeOffset);
        rightEye = Offset(position.dx - eyeOffset, position.dy + eyeOffset);
        break;
      case 'right':
      default:
        leftEye = Offset(position.dx + eyeOffset, position.dy - eyeOffset);
        rightEye = Offset(position.dx + eyeOffset, position.dy + eyeOffset);
        break;
    }

    // Draw eyes
    canvas.drawCircle(leftEye, eyeSize, eyePaint);
    canvas.drawCircle(rightEye, eyeSize, eyePaint);
    canvas.drawCircle(leftEye, eyeSize * 0.7, pupilPaint);
    canvas.drawCircle(rightEye, eyeSize * 0.7, pupilPaint);
  }

  void _drawDirectionIndicator(Canvas canvas, Offset position) {
    final indicatorPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.8)
      ..isAntiAlias = true;

    final path = Path();
    final indicatorSize = headSize * 0.3;

    switch (currentDirection) {
      case 'up':
        path.moveTo(position.dx, position.dy - headSize * 0.8);
        path.lineTo(position.dx - indicatorSize, position.dy - headSize * 0.4);
        path.lineTo(position.dx + indicatorSize, position.dy - headSize * 0.4);
        break;
      case 'down':
        path.moveTo(position.dx, position.dy + headSize * 0.8);
        path.lineTo(position.dx - indicatorSize, position.dy + headSize * 0.4);
        path.lineTo(position.dx + indicatorSize, position.dy + headSize * 0.4);
        break;
      case 'left':
        path.moveTo(position.dx - headSize * 0.8, position.dy);
        path.lineTo(position.dx - headSize * 0.4, position.dy - indicatorSize);
        path.lineTo(position.dx - headSize * 0.4, position.dy + indicatorSize);
        break;
      case 'right':
      default:
        path.moveTo(position.dx + headSize * 0.8, position.dy);
        path.lineTo(position.dx + headSize * 0.4, position.dy - indicatorSize);
        path.lineTo(position.dx + headSize * 0.4, position.dy + indicatorSize);
        break;
    }

    path.close();
    canvas.drawPath(path, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant SmoothSnakePainter oldDelegate) {
    return positions.length != oldDelegate.positions.length ||
        positions.any((pos) => !oldDelegate.positions.contains(pos)) ||
        currentDirection != oldDelegate.currentDirection;
  }
}

// Widget that combines smooth movement with trail effects
class SmoothGameRenderer extends StatefulWidget {
  final GameState gameState;
  final GameTheme theme;
  final double cellWidth;
  final double cellHeight;
  final SmoothMovementController movementController;

  const SmoothGameRenderer({
    super.key,
    required this.gameState,
    required this.theme,
    required this.cellWidth,
    required this.cellHeight,
    required this.movementController,
  });

  @override
  State<SmoothGameRenderer> createState() => _SmoothGameRendererState();
}

class _SmoothGameRendererState extends State<SmoothGameRenderer> {
  @override
  void initState() {
    super.initState();
    widget.movementController.addListener(_onMovementUpdate);
  }

  @override
  void dispose() {
    widget.movementController.removeListener(_onMovementUpdate);
    super.dispose();
  }

  void _onMovementUpdate() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final interpolatedPositions = widget.movementController
        .getInterpolatedPositions(widget.cellWidth, widget.cellHeight);

    return CustomPaint(
      painter: SmoothSnakePainter(
        positions: interpolatedPositions,
        headColor: widget.theme.snakeColor,
        bodyColor: widget.theme.snakeColor.withValues(alpha: 0.8),
        headSize: math.min(widget.cellWidth, widget.cellHeight) * 0.4,
        bodySize: math.min(widget.cellWidth, widget.cellHeight) * 0.35,
        currentDirection: widget.gameState.snake.currentDirection.name,
      ),
      size: Size.infinite,
    );
  }
}
