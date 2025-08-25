import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../providers/game_provider.dart';
import '../widgets/game_board.dart';
import '../utils/direction.dart';
import '../utils/constants.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  int _previousScore = 0;
  Offset _lastFoodPosition = const Offset(10, 10);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _scoreAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    // Set up game over callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = Provider.of<GameProvider>(context, listen: false);
      gameProvider.setOnGameOver(() {
        Navigator.pushNamed(context, '/game-over');
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to trigger haptic feedback
  void _triggerHapticFeedback() async {
    try {
      await HapticFeedback.lightImpact();
    } catch (e) {
      // Haptic feedback not supported on this device
      debugPrint('Haptic feedback not supported: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (canPop, data) async {
        // Pause the game when user presses back button
        final gameProvider = Provider.of<GameProvider>(context, listen: false);
        if (gameProvider.gameState.status == GameStatus.playing) {
          gameProvider.pauseGame();
        }
        // return true;
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Provider.of<GameProvider>(
                  context,
                  listen: false,
                ).gameState.currentTheme.backgroundColor,
                Provider.of<GameProvider>(
                  context,
                  listen: false,
                ).gameState.currentTheme.gridColor,
              ],
            ),
          ),
          child: SafeArea(
            child: Consumer<GameProvider>(
              builder: (context, gameProvider, child) {
                // Check if food was consumed
                bool foodConsumed = false;
                if (gameProvider.food.position != _lastFoodPosition) {
                  foodConsumed = true;
                  _lastFoodPosition = gameProvider.food.position;
                }

                // Trigger animation when score increases
                if (gameProvider.gameState.score > _previousScore) {
                  _previousScore = gameProvider.gameState.score;
                  _animationController.forward().then((_) {
                    _animationController.reverse();
                  });
                }

                // Start game loop if game is playing
                if (gameProvider.gameState.status == GameStatus.playing) {
                  Future.delayed(
                    Duration(milliseconds: gameProvider.gameState.gameSpeed),
                    () {
                      if (mounted &&
                          gameProvider.gameState.status == GameStatus.playing) {
                        gameProvider.updateGame();
                      }
                    },
                  );
                }

                return LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: [
                        // Score and controls bar
                        _buildScoreAndControls(gameProvider, constraints),
                        const SizedBox(height: 10),

                        // Game board with swipe gestures
                        Expanded(
                          child: _buildGameBoard(gameProvider, foodConsumed),
                        ),

                        const SizedBox(height: 10),

                        // Directional buttons (if enabled)
                        if (gameProvider.gameState.controlType ==
                            ControlType.buttons)
                          _buildDirectionalButtons(gameProvider, constraints),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreAndControls(
    GameProvider gameProvider,
    BoxConstraints constraints,
  ) {
    final bool isLargeScreen = constraints.maxWidth > 600;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isLargeScreen ? 30 : 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Score display with animation
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SCORE',
                style: TextStyle(
                  fontSize: isLargeScreen ? 20 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 4),
              ScaleTransition(
                scale: _scoreAnimation,
                child: Text(
                  gameProvider.gameState.score.toString(),
                  style: TextStyle(
                    fontSize: isLargeScreen ? 32 : 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          // Control buttons
          Row(
            children: [
              // Pause/Resume button
              IconButton(
                icon: Icon(
                  gameProvider.gameState.status == GameStatus.playing
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: isLargeScreen ? 36 : 32,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (gameProvider.gameState.status == GameStatus.playing) {
                    gameProvider.pauseGame();
                  } else if (gameProvider.gameState.status ==
                      GameStatus.paused) {
                    gameProvider.resumeGame();
                  }
                  _triggerHapticFeedback();
                },
              ),

              const SizedBox(width: 10),

              // Restart button
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  size: isLargeScreen ? 36 : 32,
                  color: Colors.white,
                ),
                onPressed: () {
                  gameProvider.restartGame();
                  _triggerHapticFeedback();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameBoard(GameProvider gameProvider, bool foodConsumed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        // Swipe controls
        onPanUpdate: gameProvider.gameState.controlType == ControlType.swipe
            ? (details) {
                if (gameProvider.gameState.status != GameStatus.playing) return;

                // Detect swipe direction
                if (details.delta.dx.abs() > details.delta.dy.abs()) {
                  // Horizontal swipe
                  if (details.delta.dx > 0) {
                    gameProvider.updateDirection(Direction.right);
                  } else {
                    gameProvider.updateDirection(Direction.left);
                  }
                } else {
                  // Vertical swipe
                  if (details.delta.dy > 0) {
                    gameProvider.updateDirection(Direction.down);
                  } else {
                    gameProvider.updateDirection(Direction.up);
                  }
                }

                // Trigger haptic feedback on swipe
                _triggerHapticFeedback();
              }
            : null,
        child: GameBoard(
          snake: gameProvider.snake,
          food: gameProvider.food,
          gridSize: gameProvider.gridSize,
          theme: gameProvider.gameState.currentTheme,
          foodConsumed: foodConsumed,
        ),
      ),
    );
  }

  Widget _buildDirectionalButtons(
    GameProvider gameProvider,
    BoxConstraints constraints,
  ) {
    final bool isLargeScreen = constraints.maxWidth > 600;
    final double buttonSize = isLargeScreen ? 50 : 40;
    final double iconSize = isLargeScreen ? 45 : 40;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isLargeScreen ? 30 : 20,
        vertical: isLargeScreen ? 25 : 20,
      ),
      child: Column(
        children: [
          // Up button
          IconButton(
            icon: Icon(Icons.arrow_upward, size: iconSize, color: Colors.white),
            onPressed: () {
              gameProvider.updateDirection(Direction.up);
              _triggerHapticFeedback();
            },
            padding: EdgeInsets.all(buttonSize / 4),
            constraints: BoxConstraints.tight(Size(buttonSize, buttonSize)),
          ),

          const SizedBox(height: 10),

          // Left and Right buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  size: iconSize,
                  color: Colors.white,
                ),
                onPressed: () {
                  gameProvider.updateDirection(Direction.left);
                  _triggerHapticFeedback();
                },
                padding: EdgeInsets.all(buttonSize / 4),
                constraints: BoxConstraints.tight(Size(buttonSize, buttonSize)),
              ),
              SizedBox(width: isLargeScreen ? 70 : 60),
              IconButton(
                icon: Icon(
                  Icons.arrow_forward,
                  size: iconSize,
                  color: Colors.white,
                ),
                onPressed: () {
                  gameProvider.updateDirection(Direction.right);
                  _triggerHapticFeedback();
                },
                padding: EdgeInsets.all(buttonSize / 4),
                constraints: BoxConstraints.tight(Size(buttonSize, buttonSize)),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Down button
          IconButton(
            icon: Icon(
              Icons.arrow_downward,
              size: iconSize,
              color: Colors.white,
            ),
            onPressed: () {
              gameProvider.updateDirection(Direction.down);
              _triggerHapticFeedback();
            },
            padding: EdgeInsets.all(buttonSize / 4),
            constraints: BoxConstraints.tight(Size(buttonSize, buttonSize)),
          ),
        ],
      ),
    );
  }
}
