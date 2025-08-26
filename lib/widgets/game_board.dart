import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';

class GameBoard extends StatefulWidget {
  final GameState gameState;
  final double cellSize;
  
  const GameBoard({
    super.key,
    required this.gameState,
    this.cellSize = GameConstants.cellSize,
  });

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Container(
          decoration: BoxDecoration(
            color: theme.backgroundColor,
            border: Border.all(
              color: theme.accentColor,
              width: GameConstants.borderWidth,
            ),
            borderRadius: BorderRadius.circular(GameConstants.borderRadius),
            boxShadow: [
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.3),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AspectRatio(
            aspectRatio: widget.gameState.boardWidth / widget.gameState.boardHeight,
            child: CustomPaint(
              painter: GameBoardPainter(
                gameState: widget.gameState,
                theme: theme,
                pulseAnimation: _pulseAnimation,
              ),
              size: Size.infinite,
            ),
          ),
        );
      },
    );
  }
}

class GameBoardPainter extends CustomPainter {
  final GameState gameState;
  final GameTheme theme;
  final Animation<double> pulseAnimation;
  
  GameBoardPainter({
    required this.gameState,
    required this.theme,
    required this.pulseAnimation,
  }) : super(repaint: pulseAnimation);

  @override
  void paint(Canvas canvas, Size size) {
    final cellWidth = size.width / gameState.boardWidth;
    final cellHeight = size.height / gameState.boardHeight;
    
    _drawGrid(canvas, size, cellWidth, cellHeight);
    _drawSnake(canvas, cellWidth, cellHeight);
    _drawFood(canvas, cellWidth, cellHeight);
  }

  void _drawGrid(Canvas canvas, Size size, double cellWidth, double cellHeight) {
    if (theme == GameTheme.neon) {
      final gridPaint = Paint()
        ..color = theme.accentColor.withValues(alpha: 0.1)
        ..strokeWidth = 0.5;

      // Draw vertical lines
      for (int i = 0; i <= gameState.boardWidth; i++) {
        final x = i * cellWidth;
        canvas.drawLine(
          Offset(x, 0),
          Offset(x, size.height),
          gridPaint,
        );
      }

      // Draw horizontal lines
      for (int i = 0; i <= gameState.boardHeight; i++) {
        final y = i * cellHeight;
        canvas.drawLine(
          Offset(0, y),
          Offset(size.width, y),
          gridPaint,
        );
      }
    }
  }

  void _drawSnake(Canvas canvas, double cellWidth, double cellHeight) {
    final snake = gameState.snake;
    
    for (int i = 0; i < snake.body.length; i++) {
      final position = snake.body[i];
      final rect = Rect.fromLTWH(
        position.x * cellWidth + 1,
        position.y * cellHeight + 1,
        cellWidth - 2,
        cellHeight - 2,
      );

      final isHead = i == 0;
      final isTail = i == snake.body.length - 1;
      
      Paint paint = Paint();
      
      if (isHead) {
        // Snake head with gradient and glow
        paint.shader = RadialGradient(
          colors: [
            theme.snakeColor,
            theme.snakeColor.withValues(alpha: 0.7),
          ],
        ).createShader(rect);
        
        if (theme == GameTheme.neon) {
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
        }
      } else {
        // Snake body
        final opacity = isTail ? 0.6 : 0.8;
        paint.color = theme.snakeColor.withValues(alpha: opacity);
        
        if (theme == GameTheme.neon) {
          paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
        }
      }

      // Draw rounded rectangles for smooth appearance
      final radius = theme == GameTheme.classic 
          ? const Radius.circular(2) 
          : const Radius.circular(4);
      
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, radius),
        paint,
      );

      // Draw snake head details
      if (isHead) {
        _drawSnakeHead(canvas, rect, snake.currentDirection);
      }
    }
  }

  void _drawSnakeHead(Canvas canvas, Rect rect, Direction direction) {
    final eyePaint = Paint()..color = Colors.white;
    final pupilPaint = Paint()..color = Colors.black;
    
    final eyeRadius = rect.width * 0.1;
    final pupilRadius = eyeRadius * 0.5;
    
    Offset leftEye, rightEye;
    
    switch (direction) {
      case Direction.up:
        leftEye = Offset(rect.center.dx - rect.width * 0.2, rect.top + rect.height * 0.3);
        rightEye = Offset(rect.center.dx + rect.width * 0.2, rect.top + rect.height * 0.3);
        break;
      case Direction.down:
        leftEye = Offset(rect.center.dx - rect.width * 0.2, rect.bottom - rect.height * 0.3);
        rightEye = Offset(rect.center.dx + rect.width * 0.2, rect.bottom - rect.height * 0.3);
        break;
      case Direction.left:
        leftEye = Offset(rect.left + rect.width * 0.3, rect.center.dy - rect.height * 0.2);
        rightEye = Offset(rect.left + rect.width * 0.3, rect.center.dy + rect.height * 0.2);
        break;
      case Direction.right:
        leftEye = Offset(rect.right - rect.width * 0.3, rect.center.dy - rect.height * 0.2);
        rightEye = Offset(rect.right - rect.width * 0.3, rect.center.dy + rect.height * 0.2);
        break;
    }
    
    // Draw eyes
    canvas.drawCircle(leftEye, eyeRadius, eyePaint);
    canvas.drawCircle(rightEye, eyeRadius, eyePaint);
    canvas.drawCircle(leftEye, pupilRadius, pupilPaint);
    canvas.drawCircle(rightEye, pupilRadius, pupilPaint);
  }

  void _drawFood(Canvas canvas, double cellWidth, double cellHeight) {
    final food = gameState.food;
    if (food == null) return;

    final rect = Rect.fromLTWH(
      food.position.x * cellWidth + 2,
      food.position.y * cellHeight + 2,
      cellWidth - 4,
      cellHeight - 4,
    );

    Paint paint = Paint();
    
    switch (food.type) {
      case FoodType.normal:
        paint.color = theme.foodColor;
        break;
      case FoodType.bonus:
        paint.shader = LinearGradient(
          colors: [theme.foodColor, Colors.orange],
        ).createShader(rect);
        break;
      case FoodType.special:
        final scale = pulseAnimation.value;
        final scaledRect = Rect.fromCenter(
          center: rect.center,
          width: rect.width * scale,
          height: rect.height * scale,
        );
        paint.shader = RadialGradient(
          colors: [const Color(0xFFFFD700), theme.foodColor, Colors.purple],
        ).createShader(scaledRect);
        
        canvas.drawCircle(scaledRect.center, scaledRect.width / 2, paint);
        return;
    }

    if (theme == GameTheme.neon) {
      paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
    }

    // Draw food as circle for better visual appeal
    canvas.drawCircle(rect.center, rect.width / 2, paint);
    
    // Add highlight for bonus food
    if (food.type == FoodType.bonus) {
      final highlightPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1);
      canvas.drawCircle(rect.center, rect.width / 3, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant GameBoardPainter oldDelegate) {
    return oldDelegate.gameState != gameState || 
           oldDelegate.theme != theme;
  }
}