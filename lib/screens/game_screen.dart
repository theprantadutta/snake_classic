import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/screens/game_over_screen.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/game_board.dart';
import 'package:snake_classic/widgets/game_hud.dart';
import 'package:snake_classic/widgets/pause_overlay.dart';
import 'package:snake_classic/widgets/swipe_detector.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Start the game when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().startGame();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final gameProvider = context.read<GameProvider>();
    
    if (state == AppLifecycleState.paused || 
        state == AppLifecycleState.inactive) {
      if (gameProvider.isPlaying) {
        gameProvider.pauseGame();
      }
    }
  }

  void _handleSwipe(Direction direction) {
    context.read<GameProvider>().changeDirection(direction);
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
        case LogicalKeyboardKey.space:
          context.read<GameProvider>().togglePause();
          break;
      }
      
      if (direction != null) {
        _handleSwipe(direction);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, ThemeProvider>(
      builder: (context, gameProvider, themeProvider, child) {
        final gameState = gameProvider.gameState;
        final theme = themeProvider.currentTheme;

        // Navigate to game over screen when game ends
        if (gameState.status == GameStatus.gameOver) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const GameOverScreen(),
              ),
            );
          });
        }

        return KeyboardListener(
          focusNode: FocusNode()..requestFocus(),
          onKeyEvent: _handleKeyPress,
          child: Scaffold(
            backgroundColor: theme.backgroundColor,
            body: SafeArea(
              child: Stack(
                children: [
                  // Background gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: Alignment.center,
                        radius: 1.5,
                        colors: [
                          theme.backgroundColor,
                          theme.backgroundColor.withValues(alpha: 0.8),
                          Colors.black.withValues(alpha: 0.2),
                        ],
                      ),
                    ),
                  ),
                  
                  // Main game content
                  Column(
                    children: [
                      // HUD
                      GameHUD(
                        gameState: gameState,
                        theme: theme,
                        onPause: () => gameProvider.togglePause(),
                        onHome: () => Navigator.of(context).pop(),
                      ),
                      
                      // Game Board
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: SwipeDetector(
                              onSwipe: _handleSwipe,
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: GameBoard(
                                  gameState: gameState,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Game Info Footer
                      _buildGameInfo(gameState, theme),
                    ],
                  ),
                  
                  // Pause Overlay
                  if (gameState.status == GameStatus.paused)
                    PauseOverlay(
                      theme: theme,
                      onResume: () => gameProvider.resumeGame(),
                      onRestart: () {
                        gameProvider.startGame();
                      },
                      onHome: () => Navigator.of(context).pop(),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameInfo(GameState gameState, GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildInfoCard(
            'Length',
            '${gameState.snake.length}',
            Icons.straighten,
            theme,
          ),
          _buildInfoCard(
            'Level',
            '${gameState.level}',
            Icons.trending_up,
            theme,
          ),
          _buildInfoCard(
            'Speed',
            '${((400 - gameState.gameSpeed) / 3).round()}%',
            Icons.speed,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String label,
    String value,
    IconData icon,
    GameTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: theme.accentColor.withValues(alpha: 0.8),
            size: 16,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: theme.accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}