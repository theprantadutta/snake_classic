import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/providers/multiplayer_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/screens/multiplayer_lobby_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/swipe_detector.dart';

class MultiplayerGameScreen extends StatefulWidget {
  const MultiplayerGameScreen({super.key});

  @override
  State<MultiplayerGameScreen> createState() => _MultiplayerGameScreenState();
}

class _MultiplayerGameScreenState extends State<MultiplayerGameScreen> 
    with WidgetsBindingObserver, TickerProviderStateMixin {
  
  Timer? _gameTimer;
  late AnimationController _countdownController;
  late AnimationController _pulseController;
  
  // Game state
  List<Position> _mySnake = [];
  Direction _currentDirection = Direction.right;
  Direction _nextDirection = Direction.right;
  int _myScore = 0;
  PlayerStatus _myStatus = PlayerStatus.playing;
  
  // Game settings
  int _boardSize = 20;
  int _gameSpeed = 200;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _countdownController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseController.repeat();
    
    _initializeGame();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _gameTimer?.cancel();
    _countdownController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _pauseGame();
    }
  }

  void _initializeGame() {
    final multiplayerProvider = context.read<MultiplayerProvider>();
    final game = multiplayerProvider.currentGame;
    
    if (game != null) {
      _boardSize = game.gameSettings['boardSize'] ?? 20;
      _gameSpeed = game.gameSettings['initialSpeed'] ?? 200;
      
      // Get current user's snake
      final currentUser = context.read<UserProvider>().user;
      if (currentUser != null) {
        final myPlayer = game.getPlayer(currentUser.uid);
        if (myPlayer != null) {
          _mySnake = List.from(myPlayer.snake);
          _currentDirection = myPlayer.currentDirection;
          _nextDirection = myPlayer.currentDirection;
          _myScore = myPlayer.score;
          _myStatus = myPlayer.status;
        }
      }
      
      _startGameLoop();
    }
  }

  void _startGameLoop() {
    _gameTimer = Timer.periodic(Duration(milliseconds: _gameSpeed), (timer) {
      if (_myStatus == PlayerStatus.playing) {
        _updateGame();
      }
    });
  }

  void _updateGame() {
    if (_mySnake.isEmpty) return;

    // Update direction
    _currentDirection = _nextDirection;
    
    // Calculate new head position
    final head = _mySnake.first;
    Position newHead;

    switch (_currentDirection) {
      case Direction.up:
        newHead = Position(head.x, head.y - 1);
        break;
      case Direction.down:
        newHead = Position(head.x, head.y + 1);
        break;
      case Direction.left:
        newHead = Position(head.x - 1, head.y);
        break;
      case Direction.right:
        newHead = Position(head.x + 1, head.y);
        break;
    }

    // Check wall collision
    if (newHead.x < 0 || newHead.x >= _boardSize || 
        newHead.y < 0 || newHead.y >= _boardSize) {
      _handleCrash();
      return;
    }

    // Check self collision
    if (_mySnake.contains(newHead)) {
      _handleCrash();
      return;
    }

    // Check collision with other players
    final multiplayerProvider = context.read<MultiplayerProvider>();
    final game = multiplayerProvider.currentGame;
    if (game != null) {
      for (final player in game.players) {
        if (player.userId != context.read<UserProvider>().user?.uid) {
          if (player.snake.contains(newHead)) {
            _handleCrash();
            return;
          }
        }
      }
    }

    // Move snake
    _mySnake.insert(0, newHead);

    // Check food collision
    bool ateFood = false;
    if (game?.foodPosition == newHead) {
      ateFood = true;
      _myScore += 10;
    } else if (game?.bonusFoodPosition == newHead) {
      ateFood = true;
      _myScore += 25;
    } else if (game?.specialFoodPosition == newHead) {
      ateFood = true;
      _myScore += 50;
    }

    if (!ateFood) {
      _mySnake.removeLast();
    }

    // Update multiplayer state
    _updateMultiplayerState();
    
    setState(() {});
  }

  void _updateMultiplayerState() {
    final multiplayerProvider = context.read<MultiplayerProvider>();
    multiplayerProvider.updateGameState(
      snake: _mySnake,
      score: _myScore,
      status: _myStatus,
    );
  }

  void _handleCrash() {
    _myStatus = PlayerStatus.crashed;
    _gameTimer?.cancel();
    _updateMultiplayerState();
    
    // Show crash feedback
    _showCrashDialog();
  }

  void _showCrashDialog() {
    final theme = context.read<ThemeProvider>().currentTheme;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning,
              color: Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Game Over!',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You crashed!',
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Your Score',
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$_myScore',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MultiplayerLobbyScreen(),
                ),
              );
            },
            child: Text(
              'Leave Game',
              style: TextStyle(color: theme.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  void _pauseGame() {
    _gameTimer?.cancel();
  }


  void _handleSwipe(Direction direction) {
    // Prevent 180-degree turns
    if (_currentDirection == Direction.up && direction == Direction.down) return;
    if (_currentDirection == Direction.down && direction == Direction.up) return;
    if (_currentDirection == Direction.left && direction == Direction.right) return;
    if (_currentDirection == Direction.right && direction == Direction.left) return;

    _nextDirection = direction;
    
    // Send direction change to other players
    context.read<MultiplayerProvider>().changeDirection(direction);
  }

  void _handleKeyPress(KeyEvent event) {
    if (event is KeyDownEvent) {
      Direction? direction;
      
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
        case LogicalKeyboardKey.keyW:
          direction = Direction.up;
          break;
        case LogicalKeyboardKey.arrowDown:
        case LogicalKeyboardKey.keyS:
          direction = Direction.down;
          break;
        case LogicalKeyboardKey.arrowLeft:
        case LogicalKeyboardKey.keyA:
          direction = Direction.left;
          break;
        case LogicalKeyboardKey.arrowRight:
        case LogicalKeyboardKey.keyD:
          direction = Direction.right;
          break;
        case LogicalKeyboardKey.escape:
          _showExitDialog();
          break;
      }

      if (direction != null) {
        _handleSwipe(direction);
      }
    }
  }

  void _showExitDialog() {
    final theme = context.read<ThemeProvider>().currentTheme;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Leave Game?',
          style: TextStyle(
            color: theme.accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to leave the multiplayer game?',
          style: TextStyle(color: theme.accentColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<MultiplayerProvider>().leaveGame();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const MultiplayerLobbyScreen(),
                ),
              );
            },
            child: Text(
              'Leave',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<MultiplayerProvider, ThemeProvider, UserProvider>(
      builder: (context, multiplayerProvider, themeProvider, userProvider, child) {
        final theme = themeProvider.currentTheme;
        final game = multiplayerProvider.currentGame;

        if (game == null || !multiplayerProvider.isGameActive) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
              ),
            ),
          );
        }

        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: _handleKeyPress,
          child: Scaffold(
            body: Container(
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
              child: SafeArea(
                child: SwipeDetector(
                  onSwipe: _handleSwipe,
                  showFeedback: false,
                  child: Column(
                    children: [
                      // Game HUD
                      _buildMultiplayerHUD(theme, game, userProvider),
                      
                      // Game Board
                      Expanded(
                        child: _buildGameBoard(theme, game, userProvider),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMultiplayerHUD(GameTheme theme, MultiplayerGame game, UserProvider userProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Back button
          IconButton(
            onPressed: _showExitDialog,
            icon: Icon(
              Icons.arrow_back,
              color: theme.accentColor,
              size: 24,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Current player info
          Expanded(
            child: _buildPlayerInfo(theme, game, userProvider.user?.uid ?? '', true),
          ),
          
          const SizedBox(width: 16),
          
          // VS indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'VS',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Opponent info
          Expanded(
            child: _buildOpponentInfo(theme, game, userProvider.user?.uid ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerInfo(GameTheme theme, MultiplayerGame game, String userId, bool isCurrentUser) {
    final player = game.getPlayer(userId);
    if (player == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? theme.accentColor.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser 
              ? theme.accentColor.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: player.photoUrl != null 
                    ? NetworkImage(player.photoUrl!)
                    : null,
                backgroundColor: theme.accentColor.withValues(alpha: 0.2),
                child: player.photoUrl == null 
                    ? Icon(
                        Icons.person,
                        color: theme.accentColor,
                        size: 16,
                      )
                    : null,
              ),
              
              const SizedBox(width: 8),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.displayName,
                      style: TextStyle(
                        color: theme.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: _getPlayerStatusColor(player.status),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _getPlayerStatusText(player.status),
                          style: TextStyle(
                            color: theme.accentColor.withValues(alpha: 0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Score: ${isCurrentUser ? _myScore : player.score}',
            style: TextStyle(
              color: theme.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpponentInfo(GameTheme theme, MultiplayerGame game, String currentUserId) {
    final opponent = game.players
        .where((p) => p.userId != currentUserId)
        .toList()
        .firstOrNull;
        
    if (opponent == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.grey.withValues(alpha: 0.3),
              child: Icon(
                Icons.person_add,
                color: Colors.grey,
                size: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Waiting...',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return _buildPlayerInfo(theme, game, opponent.userId, false);
  }

  Widget _buildGameBoard(GameTheme theme, MultiplayerGame game, UserProvider userProvider) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final boardDimension = math.min(constraints.maxWidth, constraints.maxHeight) - 32;

        return Container(
          margin: const EdgeInsets.all(16),
          child: Center(
            child: Container(
              width: boardDimension,
              height: boardDimension,
              decoration: BoxDecoration(
                color: theme.backgroundColor.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: CustomPaint(
                painter: _MultiplayerGameBoardPainter(
                  theme: theme,
                  boardSize: _boardSize,
                  mySnake: _mySnake,
                  opponentSnakes: _getOpponentSnakes(game, userProvider.user?.uid ?? ''),
                  foodPosition: game.foodPosition,
                  bonusFoodPosition: game.bonusFoodPosition,
                  specialFoodPosition: game.specialFoodPosition,
                ),
                size: Size(boardDimension, boardDimension),
              ),
            ),
          ),
        );
      },
    );
  }

  List<List<Position>> _getOpponentSnakes(MultiplayerGame game, String currentUserId) {
    return game.players
        .where((player) => player.userId != currentUserId && player.isAlive)
        .map((player) => player.snake)
        .toList();
  }

  Color _getPlayerStatusColor(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.waiting:
        return Colors.orange;
      case PlayerStatus.ready:
        return Colors.green;
      case PlayerStatus.playing:
        return Colors.blue;
      case PlayerStatus.crashed:
        return Colors.red;
      case PlayerStatus.disconnected:
        return Colors.grey;
    }
  }

  String _getPlayerStatusText(PlayerStatus status) {
    switch (status) {
      case PlayerStatus.waiting:
        return 'Waiting';
      case PlayerStatus.ready:
        return 'Ready';
      case PlayerStatus.playing:
        return 'Playing';
      case PlayerStatus.crashed:
        return 'Crashed';
      case PlayerStatus.disconnected:
        return 'Disconnected';
    }
  }
}

class _MultiplayerGameBoardPainter extends CustomPainter {
  final GameTheme theme;
  final int boardSize;
  final List<Position> mySnake;
  final List<List<Position>> opponentSnakes;
  final Position? foodPosition;
  final Position? bonusFoodPosition;
  final Position? specialFoodPosition;

  _MultiplayerGameBoardPainter({
    required this.theme,
    required this.boardSize,
    required this.mySnake,
    required this.opponentSnakes,
    this.foodPosition,
    this.bonusFoodPosition,
    this.specialFoodPosition,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / boardSize;
    
    // Draw grid
    final gridPaint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.1)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= boardSize; i++) {
      final offset = i * cellSize;
      canvas.drawLine(
        Offset(offset, 0),
        Offset(offset, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, offset),
        Offset(size.width, offset),
        gridPaint,
      );
    }

    // Draw food
    if (foodPosition != null) {
      _drawFood(canvas, foodPosition!, cellSize, theme.foodColor);
    }
    
    if (bonusFoodPosition != null) {
      _drawBonusFood(canvas, bonusFoodPosition!, cellSize);
    }
    
    if (specialFoodPosition != null) {
      _drawSpecialFood(canvas, specialFoodPosition!, cellSize);
    }

    // Draw my snake
    _drawSnake(canvas, mySnake, cellSize, theme.snakeColor, theme.accentColor);

    // Draw opponent snakes
    final opponentColors = [Colors.red, Colors.purple, Colors.orange];
    for (int i = 0; i < opponentSnakes.length; i++) {
      final color = opponentColors[i % opponentColors.length];
      _drawSnake(canvas, opponentSnakes[i], cellSize, color, color.withValues(alpha: 0.7));
    }
  }

  void _drawSnake(Canvas canvas, List<Position> snake, double cellSize, Color bodyColor, Color headColor) {
    if (snake.isEmpty) return;

    final paint = Paint()..color = bodyColor;
    final headPaint = Paint()..color = headColor;

    // Draw body
    for (int i = 1; i < snake.length; i++) {
      final pos = snake[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            pos.x * cellSize + 1,
            pos.y * cellSize + 1,
            cellSize - 2,
            cellSize - 2,
          ),
          Radius.circular(cellSize * 0.2),
        ),
        paint,
      );
    }

    // Draw head
    if (snake.isNotEmpty) {
      final head = snake.first;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            head.x * cellSize + 1,
            head.y * cellSize + 1,
            cellSize - 2,
            cellSize - 2,
          ),
          Radius.circular(cellSize * 0.3),
        ),
        headPaint,
      );
    }
  }

  void _drawFood(Canvas canvas, Position pos, double cellSize, Color color) {
    final paint = Paint()..color = color;
    canvas.drawCircle(
      Offset(
        pos.x * cellSize + cellSize / 2,
        pos.y * cellSize + cellSize / 2,
      ),
      cellSize * 0.3,
      paint,
    );
  }

  void _drawBonusFood(Canvas canvas, Position pos, double cellSize) {
    final paint = Paint()
      ..color = Colors.amber
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(
        pos.x * cellSize + cellSize / 2,
        pos.y * cellSize + cellSize / 2,
      ),
      cellSize * 0.35,
      paint,
    );
  }

  void _drawSpecialFood(Canvas canvas, Position pos, double cellSize) {
    final paint = Paint()
      ..color = Colors.purple
      ..style = PaintingStyle.fill;
    
    // Draw star shape
    final center = Offset(
      pos.x * cellSize + cellSize / 2,
      pos.y * cellSize + cellSize / 2,
    );
    
    final path = Path();
    final radius = cellSize * 0.4;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * math.pi * 2) / 8;
      final r = (i % 2 == 0) ? radius : radius * 0.5;
      final x = center.dx + math.cos(angle) * r;
      final y = center.dy + math.sin(angle) * r;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _MultiplayerGameBoardPainter ||
        oldDelegate.mySnake != mySnake ||
        oldDelegate.opponentSnakes != opponentSnakes ||
        oldDelegate.foodPosition != foodPosition ||
        oldDelegate.bonusFoodPosition != bonusFoodPosition ||
        oldDelegate.specialFoodPosition != specialFoodPosition;
  }
}