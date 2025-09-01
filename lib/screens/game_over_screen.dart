import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/screens/game_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/gradient_button.dart';
import 'package:snake_classic/widgets/particle_effect.dart';

class GameOverScreen extends StatefulWidget {
  const GameOverScreen({super.key});

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  late AnimationController _explosionController;
  late AnimationController _scoreController;
  
  @override
  void initState() {
    super.initState();
    
    _explosionController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _scoreController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _explosionController.forward();
    
    // Start score animation after explosion
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _scoreController.forward();
      }
    });
  }

  @override
  void dispose() {
    _explosionController.dispose();
    _scoreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, ThemeProvider>(
      builder: (context, gameProvider, themeProvider, child) {
        final gameState = gameProvider.gameState;
        final theme = themeProvider.currentTheme;
        final isHighScore = gameState.score == gameState.highScore && gameState.score > 0;

        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  theme.backgroundColor,
                  theme.backgroundColor.withValues(alpha: 0.8),
                  Colors.black.withValues(alpha: 0.9),
                ],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  // Particle effects
                  if (isHighScore)
                    ParticleEffect(
                      controller: _explosionController,
                      color: Colors.amber,
                    ),
                  
                  // Main content
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Game Over Title
                          Text(
                            'GAME OVER',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: theme.foodColor,
                              letterSpacing: 4,
                              shadows: [
                                Shadow(
                                  offset: const Offset(2, 2),
                                  blurRadius: 4,
                                  color: Colors.black.withValues(alpha: 0.5),
                                ),
                              ],
                            ),
                          ).animate().fadeIn().slideY(begin: -1),
                          
                          const SizedBox(height: 32),
                          
                          // High Score Badge
                          if (isHighScore) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.amber, Colors.orange],
                                ),
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.amber.withValues(alpha: 0.5),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.emoji_events,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'NEW HIGH SCORE!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().scale(delay: 500.ms).shimmer(delay: 1000.ms),
                            
                            const SizedBox(height: 24),
                          ],
                          
                          // Tournament Result Badge
                          if (gameProvider.isTournamentMode && gameProvider.tournamentMode != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Colors.purple, Colors.deepPurple],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.purple.withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    gameProvider.tournamentMode!.emoji,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(width: 8),
                                  const Text(
                                    'TOURNAMENT SCORE SUBMITTED!',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ).animate().scale(delay: 700.ms).shimmer(delay: 1200.ms),
                            
                            const SizedBox(height: 20),
                          ],
                          
                          // Score Display
                          _buildScoreCard(gameState, theme),
                          
                          const SizedBox(height: 48),
                          
                          // Action Buttons
                          Column(
                            children: [
                              GradientButton(
                                onPressed: () async {
                                  // Properly reset the game state first
                                  gameProvider.resetGame();
                                  
                                  // Small delay to ensure state is updated
                                  await Future.delayed(const Duration(milliseconds: 50));
                                  
                                  // Start a fresh game
                                  gameProvider.startGame();
                                  
                                  // Navigate to game screen
                                  if (context.mounted) {
                                    Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(
                                        builder: (context) => const GameScreen(),
                                      ),
                                    );
                                  }
                                },
                                text: 'PLAY AGAIN',
                                primaryColor: theme.accentColor,
                                secondaryColor: theme.foodColor,
                                icon: Icons.refresh,
                                width: 250,
                              ).animate().slideX(begin: -1, delay: 1200.ms),
                              
                              const SizedBox(height: 16),
                              
                              GradientButton(
                                onPressed: () {
                                  gameProvider.backToMenu();
                                  Navigator.of(context).popUntil((route) => route.isFirst);
                                },
                                text: 'MAIN MENU',
                                primaryColor: theme.snakeColor.withValues(alpha: 0.8),
                                secondaryColor: theme.snakeColor.withValues(alpha: 0.6),
                                icon: Icons.home,
                                width: 250,
                                outlined: true,
                              ).animate().slideX(begin: 1, delay: 1400.ms),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard(GameState gameState, GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        children: [
          // Final Score
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Final Score:',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.8),
                  fontSize: 18,
                ),
              ),
              AnimatedBuilder(
                animation: _scoreController,
                builder: (context, child) {
                  final animatedScore = (gameState.score * _scoreController.value).round();
                  return Text(
                    '$animatedScore',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Game Stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStat('Length', '${gameState.snake.length}', theme),
              _buildStat('Level', '${gameState.level}', theme),
              _buildStat('High Score', '${gameState.highScore}', theme),
            ],
          ),
        ],
      ),
    ).animate().scale(delay: 800.ms);
  }

  Widget _buildStat(String label, String value, theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: theme.accentColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.6),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}