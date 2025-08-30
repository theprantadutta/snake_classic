import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/screens/game_screen.dart';
import 'package:snake_classic/screens/settings_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/gradient_button.dart';
import 'package:snake_classic/widgets/animated_snake_logo.dart';
import 'package:snake_classic/widgets/instructions_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Reduced duration
      vsync: this,
    );

    // Start logo animation with a slight delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        _logoController.forward();
      }
    });
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<GameProvider, ThemeProvider>(
      builder: (context, gameProvider, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.backgroundColor,
                  theme.backgroundColor.withValues(alpha: 0.8),
                  theme.accentColor.withValues(alpha: 0.1),
                ],
                stops: const [
                  0.0,
                  0.7,
                  1.0,
                ],
              ),
            ),
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.06,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),
                        
                        // Logo and Title
                        RepaintBoundary(
                          child: _buildHeader(theme),
                        ),
                        
                        const Spacer(flex: 2),
                        
                        // High Score Display
                        RepaintBoundary(
                          child: _buildHighScoreCard(gameProvider, theme),
                        ),
                        
                        const SizedBox(height: 32),
                        
                        // Main Menu Buttons
                        _buildMenuButtons(context, gameProvider, themeProvider, theme),
                        
                        const Spacer(flex: 3),
                        
                        // Footer
                        RepaintBoundary(
                          child: _buildFooter(theme),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(GameTheme theme) {
    return Column(
      children: [
        // Animated Snake Logo
        AnimatedSnakeLogo(
          theme: theme,
          controller: _logoController,
        ),
        
        const SizedBox(height: 24),
        
        // Game Title
        Text(
          'SNAKE',
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: theme.accentColor,
            letterSpacing: 8,
            shadows: [
              Shadow(
                offset: const Offset(2, 2),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.3),
        
        Text(
          'CLASSIC',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: theme.accentColor.withValues(alpha: 0.8),
            letterSpacing: 3,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildHighScoreCard(GameProvider gameProvider, GameTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.5)),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 24,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'HIGH SCORE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: theme.accentColor.withValues(alpha: 0.8),
                  letterSpacing: 1,
                ),
              ),
              Text(
                '${gameProvider.gameState.highScore}',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.accentColor,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.9, 0.9), duration: 400.ms);
  }

  Widget _buildMenuButtons(
    BuildContext context,
    GameProvider gameProvider,
    ThemeProvider themeProvider,
    GameTheme theme,
  ) {
    return Column(
      children: [
        // Play Button
        GradientButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GameScreen(),
              ),
            );
          },
          text: 'PLAY',
          primaryColor: theme.accentColor,
          secondaryColor: theme.foodColor,
          icon: Icons.play_arrow_rounded,
          width: 200,
        ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.5, duration: 300.ms),
        
        const SizedBox(height: 16),
        
        // How to Play Button
        GradientButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => InstructionsDialog(theme: theme),
            );
          },
          text: 'HOW TO PLAY',
          primaryColor: theme.foodColor.withValues(alpha: 0.8),
          secondaryColor: theme.foodColor.withValues(alpha: 0.6),
          icon: Icons.help_outline,
          width: 200,
          outlined: true,
        ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.5, duration: 300.ms),
        
        const SizedBox(height: 16),
        
        // Settings Button
        GradientButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const SettingsScreen(),
              ),
            );
          },
          text: 'SETTINGS',
          primaryColor: theme.accentColor.withValues(alpha: 0.8),
          secondaryColor: theme.accentColor.withValues(alpha: 0.6),
          icon: Icons.settings,
          width: 200,
          outlined: true,
        ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.5, duration: 300.ms),
        
        const SizedBox(height: 16),
        
        // Theme Toggle Button
        GradientButton(
          onPressed: () {
            themeProvider.cycleTheme();
          },
          text: theme.name.toUpperCase(),
          primaryColor: theme.snakeColor.withValues(alpha: 0.8),
          secondaryColor: theme.snakeColor.withValues(alpha: 0.6),
          icon: Icons.palette,
          width: 200,
          outlined: true,
        ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.5, duration: 300.ms),
      ],
    );
  }

  Widget _buildFooter(GameTheme theme) {
    return Column(
      children: [
        Container(
          height: 1,
          width: 100,
          color: theme.accentColor.withValues(alpha: 0.3),
        ).animate().fadeIn(delay: 900.ms).scaleX(duration: 400.ms),
        
        const SizedBox(height: 16),
        
        Text(
          'Swipe to control • Tap to pause',
          style: TextStyle(
            fontSize: 12,
            color: theme.accentColor.withValues(alpha: 0.6),
            letterSpacing: 1,
          ),
        ).animate().fadeIn(delay: 1000.ms, duration: 400.ms),
      ],
    );
  }
}