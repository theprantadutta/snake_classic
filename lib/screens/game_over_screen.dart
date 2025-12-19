import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/screens/game_screen.dart';
import 'package:snake_classic/services/achievement_service.dart';
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
  late AnimationController _achievementController;

  final AchievementService _achievementService = AchievementService();
  List<Achievement> _recentAchievements = [];
  List<Achievement> _progressAchievements = [];
  bool _achievementsLoaded = false;

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

    _achievementController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _explosionController.forward();

    // Start score animation after explosion
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _scoreController.forward();
      }
    });

    // Load achievements data
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    // Use cached achievements immediately - don't re-initialize (which makes slow API calls)
    // The achievement service is a singleton and should already have data from gameplay
    try {
      // Get recent unlocks from the service (already in memory)
      _recentAchievements = _achievementService.recentUnlocks;

      // Get some in-progress achievements to show progress
      _progressAchievements = _achievementService.achievements
          .where((a) => !a.isUnlocked && a.currentProgress > 0)
          .take(3)
          .toList();

      setState(() {
        _achievementsLoaded = true;
      });

      // Start achievement animation immediately if we have content to show
      if (_recentAchievements.isNotEmpty || _progressAchievements.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted) {
            _achievementController.forward();
          }
        });
      }
    } catch (e) {
      // Handle error gracefully
      setState(() {
        _achievementsLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _explosionController.dispose();
    _scoreController.dispose();
    _achievementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, ThemeProvider>(
      builder: (context, gameProvider, themeProvider, child) {
        final gameState = gameProvider.gameState;
        final theme = themeProvider.currentTheme;
        final isHighScore =
            gameState.score == gameState.highScore && gameState.score > 0;

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

                  // Main content - constrained to screen height
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SizedBox(
                        height: constraints.maxHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20.0,
                            vertical: 16.0,
                          ),
                          child: Column(
                            children: [
                              // Top section - Game Over title and badges
                              Column(
                                children: [
                                  // Game Over Title
                                  Text(
                                    'GAME OVER',
                                    style: TextStyle(
                                      fontSize: constraints.maxHeight < 600
                                          ? 36
                                          : 48,
                                      fontWeight: FontWeight.bold,
                                      color: theme.foodColor,
                                      letterSpacing: 4,
                                      shadows: [
                                        Shadow(
                                          offset: const Offset(2, 2),
                                          blurRadius: 4,
                                          color: Colors.black.withValues(
                                            alpha: 0.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ).animate().fadeIn().slideY(begin: -1),

                                  SizedBox(
                                    height: constraints.maxHeight < 600
                                        ? 16
                                        : 24,
                                  ),

                                  // High Score Badge
                                  if (isHighScore) ...[
                                    Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                constraints.maxHeight < 600
                                                ? 16
                                                : 20,
                                            vertical:
                                                constraints.maxHeight < 600
                                                ? 8
                                                : 12,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.amber,
                                                Colors.orange,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              25,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.amber.withValues(
                                                  alpha: 0.5,
                                                ),
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
                                              Text(
                                                'NEW HIGH SCORE!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      constraints.maxHeight <
                                                          600
                                                      ? 12
                                                      : 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .animate()
                                        .scale(delay: 500.ms)
                                        .shimmer(delay: 1000.ms),

                                    SizedBox(
                                      height: constraints.maxHeight < 600
                                          ? 16
                                          : 20,
                                    ),
                                  ],

                                  // Tournament Result Badge
                                  if (gameProvider.isTournamentMode &&
                                      gameProvider.tournamentMode != null) ...[
                                    Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal:
                                                constraints.maxHeight < 600
                                                ? 12
                                                : 16,
                                            vertical:
                                                constraints.maxHeight < 600
                                                ? 8
                                                : 10,
                                          ),
                                          decoration: BoxDecoration(
                                            gradient: const LinearGradient(
                                              colors: [
                                                Colors.purple,
                                                Colors.deepPurple,
                                              ],
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              20,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.purple.withValues(
                                                  alpha: 0.4,
                                                ),
                                                blurRadius: 8,
                                                spreadRadius: 1,
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                gameProvider
                                                    .tournamentMode!
                                                    .emoji,
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'TOURNAMENT SCORE SUBMITTED!',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize:
                                                      constraints.maxHeight <
                                                          600
                                                      ? 10
                                                      : 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                        .animate()
                                        .scale(delay: 700.ms)
                                        .shimmer(delay: 1200.ms),

                                    SizedBox(
                                      height: constraints.maxHeight < 600
                                          ? 12
                                          : 16,
                                    ),
                                  ],
                                ],
                              ),

                              // Score Display - always visible
                              _buildScoreCard(gameState, theme, constraints),

                              SizedBox(
                                height: constraints.maxHeight < 600 ? 8 : 12,
                              ),

                              // Dynamic content area - achievements or spacer
                              Expanded(
                                child: Column(
                                  children: [
                                    // Achievement Display - always visible if available
                                    if (_achievementsLoaded &&
                                        (_recentAchievements.isNotEmpty ||
                                            _progressAchievements.isNotEmpty))
                                      Flexible(
                                        child: _buildAchievementSection(
                                          theme,
                                          constraints,
                                        ),
                                      )
                                    else
                                      // Spacer when no achievements
                                      const Expanded(child: SizedBox()),
                                  ],
                                ),
                              ),

                              SizedBox(
                                height: constraints.maxHeight < 600 ? 8 : 12,
                              ),

                              // Bottom section - Action Buttons - always at bottom
                              Row(
                                children: [
                                  Expanded(
                                    child:
                                        GradientButton(
                                          onPressed: () async {
                                            gameProvider.resetGame();
                                            await Future.delayed(
                                              const Duration(milliseconds: 50),
                                            );
                                            gameProvider.startGame();

                                            if (context.mounted) {
                                              Navigator.of(
                                                context,
                                              ).pushReplacement(
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      const GameScreen(),
                                                ),
                                              );
                                            }
                                          },
                                          text: 'PLAY AGAIN',
                                          primaryColor: theme.accentColor,
                                          secondaryColor: theme.foodColor,
                                          icon: Icons.refresh,
                                        ).animate().slideX(
                                          begin: -1,
                                          delay: 1200.ms,
                                        ),
                                  ),

                                  const SizedBox(width: 12),

                                  Expanded(
                                    child:
                                        GradientButton(
                                          onPressed: () {
                                            gameProvider.backToMenu();
                                            Navigator.of(context).popUntil(
                                              (route) => route.isFirst,
                                            );
                                          },
                                          text: 'MENU',
                                          primaryColor: theme.snakeColor
                                              .withValues(alpha: 0.8),
                                          secondaryColor: theme.snakeColor
                                              .withValues(alpha: 0.6),
                                          icon: Icons.home,
                                          outlined: true,
                                        ).animate().slideX(
                                          begin: 1,
                                          delay: 1400.ms,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildScoreCard(
    GameState gameState,
    GameTheme theme,
    BoxConstraints constraints,
  ) {
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
                  final animatedScore =
                      (gameState.score * _scoreController.value).round();
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

  Widget _buildAchievementSection(GameTheme theme, BoxConstraints constraints) {
    return AnimatedBuilder(
      animation: _achievementController,
      builder: (context, child) {
        return Transform.scale(
          scale: 0.8 + (_achievementController.value * 0.2),
          child: Opacity(
            opacity: _achievementController.value,
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(constraints.maxHeight < 600 ? 12 : 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.accentColor.withValues(alpha: 0.08),
                    theme.foodColor.withValues(alpha: 0.05),
                    theme.backgroundColor.withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.accentColor.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Title
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'ACHIEVEMENTS',
                        style: TextStyle(
                          color: theme.accentColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: constraints.maxHeight < 600 ? 8 : 12),

                  // Achievement content - more compact
                  SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Recent Unlocks
                        if (_recentAchievements.isNotEmpty) ...[
                          Text(
                            'Recently Unlocked:',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: constraints.maxHeight < 600 ? 11 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight < 600 ? 4 : 6),
                          ..._recentAchievements
                              .take(constraints.maxHeight < 600 ? 1 : 2)
                              .map(
                                (achievement) => _buildAchievementItem(
                                  achievement,
                                  theme,
                                  constraints,
                                  isUnlocked: true,
                                ),
                              ),

                          if (_progressAchievements.isNotEmpty)
                            SizedBox(
                              height: constraints.maxHeight < 600 ? 8 : 12,
                            ),
                        ],

                        // Progress Achievements
                        if (_progressAchievements.isNotEmpty) ...[
                          Text(
                            'Progress Update:',
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: constraints.maxHeight < 600 ? 11 : 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight < 600 ? 4 : 6),
                          ..._progressAchievements
                              .take(constraints.maxHeight < 600 ? 1 : 2)
                              .map(
                                (achievement) => _buildAchievementItem(
                                  achievement,
                                  theme,
                                  constraints,
                                  isUnlocked: false,
                                ),
                              ),
                        ],
                      ],
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

  Widget _buildAchievementItem(
    Achievement achievement,
    GameTheme theme,
    BoxConstraints constraints, {
    required bool isUnlocked,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: constraints.maxHeight < 600 ? 4 : 6),
      padding: EdgeInsets.all(constraints.maxHeight < 600 ? 6 : 8),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.green.withValues(alpha: 0.1)
            : theme.backgroundColor.withValues(alpha: 0.4),
        border: Border.all(
          color: isUnlocked
              ? Colors.green.withValues(alpha: 0.4)
              : theme.accentColor.withValues(alpha: 0.3),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Achievement Icon with Rarity Color
          Container(
            padding: EdgeInsets.all(constraints.maxHeight < 600 ? 4 : 6),
            decoration: BoxDecoration(
              color: achievement.rarityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              achievement.icon,
              color: achievement.rarityColor,
              size: constraints.maxHeight < 600 ? 14 : 16,
            ),
          ),

          const SizedBox(width: 8),

          // Achievement Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        achievement.title,
                        style: TextStyle(
                          color: theme.accentColor,
                          fontSize: constraints.maxHeight < 600 ? 11 : 12,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isUnlocked)
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: constraints.maxHeight < 600 ? 14 : 16,
                      )
                    else
                      Text(
                        '${(achievement.progressPercentage * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: constraints.maxHeight < 600 ? 11 : 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),

                SizedBox(height: constraints.maxHeight < 600 ? 2 : 4),

                Text(
                  achievement.description,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: constraints.maxHeight < 600 ? 10 : 11,
                  ),
                  maxLines: constraints.maxHeight < 600 ? 1 : 2,
                  overflow: TextOverflow.ellipsis,
                ),

                if (!isUnlocked && constraints.maxHeight >= 600) ...[
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: achievement.progressPercentage,
                    backgroundColor: theme.backgroundColor.withValues(
                      alpha: 0.3,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                    minHeight: 2,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${achievement.currentProgress}/${achievement.targetValue}',
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.6),
                      fontSize: 9,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Points Display
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: constraints.maxHeight < 600 ? 6 : 8,
              vertical: constraints.maxHeight < 600 ? 2 : 4,
            ),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '+${achievement.points}',
              style: TextStyle(
                color: Colors.amber,
                fontSize: constraints.maxHeight < 600 ? 10 : 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
