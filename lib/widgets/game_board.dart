import 'package:flutter/material.dart';
import '../models/snake.dart';
import '../models/food.dart';
import '../utils/constants.dart';

class GameBoard extends StatefulWidget {
  final Snake snake;
  final Food food;
  final int gridSize;
  final GameTheme theme;
  final bool foodConsumed; // Flag to trigger particle effect

  const GameBoard({
    super.key,
    required this.snake,
    required this.food,
    required this.gridSize,
    required this.theme,
    this.foodConsumed = false,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  late OverlayEntry _overlayEntry;
  bool _showParticles = false;

  @override
  void didUpdateWidget(covariant GameBoard oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Check if food was consumed
    if (oldWidget.food.position != widget.food.position) {
      _showParticleEffect();
    }
  }

  void _showParticleEffect() {
    // In a real implementation, we would show particles here
    // For now, we'll just simulate the effect with a simple animation
    setState(() {
      _showParticles = true;
    });
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showParticles = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: widget.theme.backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: widget.theme.gridColor, width: 2),
        ),
        child: Stack(
          children: [
            CustomPaint(
              painter: GameBoardPainter(
                snake: widget.snake,
                food: widget.food,
                gridSize: widget.gridSize,
                theme: widget.theme,
              ),
              size: const Size(double.infinity, double.infinity),
            ),
            if (_showParticles)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.0),
                    gradient: RadialGradient(
                      colors: [
                        widget.theme.foodColor.withValues(alpha: 0.5),
                        widget.theme.foodColor.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      center: Alignment(
                        (widget.food.position.dx / widget.gridSize) * 2 - 1,
                        (widget.food.position.dy / widget.gridSize) * 2 - 1,
                      ),
                      radius: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GameBoardPainter extends CustomPainter {
  final Snake snake;
  final Food food;
  final int gridSize;
  final GameTheme theme;

  GameBoardPainter({
    required this.snake,
    required this.food,
    required this.gridSize,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = size.width / gridSize;
    
    // Draw grid lines
    final Paint gridPaint = Paint()
      ..color = theme.gridColor
      ..strokeWidth = 0.5;

    for (int i = 0; i <= gridSize; i++) {
      // Vertical lines
      canvas.drawLine(
        Offset(i * cellSize, 0),
        Offset(i * cellSize, size.height),
        gridPaint,
      );
      
      // Horizontal lines
      canvas.drawLine(
        Offset(0, i * cellSize),
        Offset(size.width, i * cellSize),
        gridPaint,
      );
    }

    // Draw snake with gradient and animation effect
    for (int i = 0; i < snake.body.length; i++) {
      final Offset position = snake.body[i];
      
      // Create a gradient effect for the snake
      final Paint snakePaint = Paint()
        ..style = PaintingStyle.fill;
      
      // Head is brighter
      if (i == 0) {
        snakePaint.color = theme.snakeColor.withValues(alpha: 0.9);
      } else {
        // Body segments get progressively darker
        final double opacity = 0.9 - (i / snake.body.length) * 0.6;
        snakePaint.color = theme.snakeColor.withValues(alpha: opacity);
      }
      
      // Draw snake segment with rounded corners
      final Rect rect = Rect.fromLTWH(
        position.dx * cellSize + 1,
        position.dy * cellSize + 1,
        cellSize - 2,
        cellSize - 2,
      );
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(4)),
        snakePaint,
      );
      
      // Add eyes to the snake head
      if (i == 0) {
        final Paint eyePaint = Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill;
          
        // Draw two eyes
        canvas.drawCircle(
          Offset(
            position.dx * cellSize + cellSize * 0.3,
            position.dy * cellSize + cellSize * 0.3,
          ),
          cellSize * 0.15,
          eyePaint,
        );
        
        canvas.drawCircle(
          Offset(
            position.dx * cellSize + cellSize * 0.7,
            position.dy * cellSize + cellSize * 0.3,
          ),
          cellSize * 0.15,
          eyePaint,
        );
      }
    }

    // Draw food with shine effect
    final Paint foodPaint = Paint()
      ..color = theme.foodColor
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(
        food.position.dx * cellSize + cellSize / 2,
        food.position.dy * cellSize + cellSize / 2,
      ),
      cellSize / 2 - 2,
      foodPaint,
    );
    
    // Add shine effect to food
    final Paint shinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(
      Offset(
        food.position.dx * cellSize + cellSize / 3,
        food.position.dy * cellSize + cellSize / 3,
      ),
      cellSize / 6,
      shinePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // Only repaint if the snake or food has changed
    if (oldDelegate is GameBoardPainter) {
      return oldDelegate.snake.body != snake.body || 
             oldDelegate.food.position != food.position ||
             oldDelegate.theme != theme;
    }
    return true;
  }
}