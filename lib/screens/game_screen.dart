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
import 'package:snake_classic/widgets/crash_feedback_overlay.dart';

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
    
    // Start the game when screen loads (only if not already playing)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameProvider = context.read<GameProvider>();
      if (gameProvider.gameState.status == GameStatus.menu) {
        gameProvider.startGame();
      }
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
              child: SwipeDetector(
                onSwipe: _handleSwipe,
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
                        
                        // Game Instructions
                        _buildGameInstructions(theme),
                        
                        // Game Board
                        Expanded(
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                left: 16.0,
                                right: 16.0,
                                bottom: 50.0, // Space for gesture indicator
                              ),
                              child: AspectRatio(
                                aspectRatio: 1.0,
                                child: GameBoard(
                                  gameState: gameState,
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
                    
                    // Crash Feedback Overlay
                    if (gameState.status == GameStatus.crashed && gameState.crashReason != null)
                      CrashFeedbackOverlay(
                        crashReason: gameState.crashReason!,
                        theme: theme,
                        onSkip: () => gameProvider.skipCrashFeedback(),
                        duration: gameProvider.crashFeedbackDuration,
                      ),
                  ],
                ),
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
  
  Widget _buildGameInstructions(GameTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Instructions in a responsive row
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 320;
              
              if (isNarrow) {
                // Stack instructions vertically on very narrow screens
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInstruction('📱 Swipe', 'to move', theme),
                        _buildInstruction('🍎 Apple', '10 pts', theme),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildInstruction('✨ Bonus', '25 pts', theme),
                        _buildInstruction('⭐ Star', '50 pts', theme),
                      ],
                    ),
                  ],
                );
              } else {
                // Normal horizontal layout
                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildInstruction('📱 Swipe', 'to move', theme),
                    _buildInstruction('🍎 Apple', '10 pts', theme),
                    _buildInstruction('✨ Bonus', '25 pts', theme),
                    _buildInstruction('⭐ Star', '50 pts', theme),
                  ],
                );
              }
            },
          ),
          const SizedBox(height: 6),
          Text(
            'Avoid walls and yourself • Speed increases with level',
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.7),
              fontSize: 10,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  Widget _buildInstruction(String icon, String text, GameTheme theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          text,
          style: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.8),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}