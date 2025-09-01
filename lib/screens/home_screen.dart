import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/screens/game_screen.dart';
import 'package:snake_classic/screens/settings_screen.dart';
import 'package:snake_classic/screens/profile_screen.dart';
import 'package:snake_classic/screens/leaderboard_screen.dart';
import 'package:snake_classic/screens/achievements_screen.dart';
import 'package:snake_classic/screens/statistics_screen.dart';
import 'package:snake_classic/screens/replays_screen.dart';
import 'package:snake_classic/screens/friends_screen.dart';
import 'package:snake_classic/screens/friends_leaderboard_screen.dart';
import 'package:snake_classic/services/statistics_service.dart';
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
    return Consumer3<GameProvider, ThemeProvider, UserProvider>(
      builder: (context, gameProvider, themeProvider, userProvider, child) {
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
                  final screenHeight = constraints.maxHeight;
                  final isSmallScreen = screenHeight < 700;
                  
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth * 0.08,
                      vertical: isSmallScreen ? 8 : 12,
                    ),
                    child: Column(
                      children: [
                        // Profile Button in top-right - Reduced height
                        SizedBox(
                          height: isSmallScreen ? 40 : 48,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const ProfileScreen(),
                                    ),
                                  );
                                },
                                icon: userProvider.isSignedIn && userProvider.photoURL != null
                                  ? CircleAvatar(
                                      radius: 16,
                                      backgroundImage: NetworkImage(userProvider.photoURL!),
                                    )
                                  : Icon(
                                      Icons.account_circle,
                                      size: 28,
                                      color: theme.accentColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Logo and Title - Compact
                        RepaintBoundary(
                          child: _buildHeader(theme, isSmallScreen),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        // High Score Display
                        RepaintBoundary(
                          child: _buildHighScoreCard(gameProvider, userProvider, theme, isSmallScreen),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 12 : 16),
                        
                        // Statistics Summary
                        RepaintBoundary(
                          child: _buildStatisticsSummary(theme, isSmallScreen),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 16 : 20),
                        
                        // Main Menu Buttons - Flexible
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildMenuButtons(context, gameProvider, themeProvider, theme, isSmallScreen),
                            ],
                          ),
                        ),
                        
                        // Footer - Compact
                        RepaintBoundary(
                          child: _buildFooter(theme, isSmallScreen),
                        ),
                        
                        SizedBox(height: isSmallScreen ? 4 : 8),
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

  Widget _buildHeader(GameTheme theme, bool isSmallScreen) {
    return Column(
      children: [
        // Animated Snake Logo - Smaller
        SizedBox(
          height: isSmallScreen ? 60 : 80,
          child: AnimatedSnakeLogo(
            theme: theme,
            controller: _logoController,
          ),
        ),
        
        SizedBox(height: isSmallScreen ? 8 : 12),
        
        // Game Title - Smaller
        Text(
          'SNAKE',
          style: TextStyle(
            fontSize: isSmallScreen ? 36 : 42,
            fontWeight: FontWeight.bold,
            color: theme.accentColor,
            letterSpacing: isSmallScreen ? 6 : 8,
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
            fontSize: isSmallScreen ? 12 : 14,
            fontWeight: FontWeight.w300,
            color: theme.accentColor.withValues(alpha: 0.8),
            letterSpacing: 2,
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
      ],
    );
  }

  Widget _buildHighScoreCard(GameProvider gameProvider, UserProvider userProvider, GameTheme theme, bool isSmallScreen) {
    final highScore = userProvider.isSignedIn ? 
      (userProvider.highScore > gameProvider.gameState.highScore ? userProvider.highScore : gameProvider.gameState.highScore) :
      gameProvider.gameState.highScore;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.accentColor.withValues(alpha: 0.15),
            theme.foodColor.withValues(alpha: 0.1),
          ],
        ),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            ),
            child: Icon(
              Icons.emoji_events,
              color: Colors.amber,
              size: isSmallScreen ? 24 : 28,
            ),
          ),
          SizedBox(width: isSmallScreen ? 12 : 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BEST SCORE',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w600,
                    color: theme.accentColor.withValues(alpha: 0.8),
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Text(
                  '$highScore',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 24 : 28,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          if (userProvider.isSignedIn)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 8 : 10, 
                vertical: isSmallScreen ? 4 : 6
              ),
              decoration: BoxDecoration(
                color: theme.foodColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                border: Border.all(
                  color: theme.foodColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.cloud_done,
                    color: theme.foodColor,
                    size: isSmallScreen ? 14 : 16,
                  ),
                  SizedBox(width: isSmallScreen ? 4 : 6),
                  Text(
                    'SYNCED',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 10 : 11,
                      fontWeight: FontWeight.w600,
                      color: theme.foodColor,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms).scale(begin: const Offset(0.95, 0.95), duration: 500.ms);
  }

  Widget _buildStatisticsSummary(GameTheme theme, bool isSmallScreen) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getQuickStats(),
      builder: (context, snapshot) {
        final stats = snapshot.data ?? {};
        
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.teal.withValues(alpha: 0.15),
                Colors.teal.withValues(alpha: 0.1),
              ],
            ),
            border: Border.all(
              color: Colors.teal.withValues(alpha: 0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 18),
            boxShadow: [
              BoxShadow(
                color: Colors.teal.withValues(alpha: 0.2),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Colors.teal,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              
              SizedBox(width: isSmallScreen ? 10 : 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GAME STATS',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 10 : 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.teal.withValues(alpha: 0.8),
                        letterSpacing: 1.2,
                      ),
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${stats['totalGames'] ?? 0} Games',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 12 : 14,
                              fontWeight: FontWeight.bold,
                              color: theme.accentColor,
                            ),
                          ),
                        ),
                        Text(
                          '${stats['totalPlayTime'] ?? 0}h Played',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StatisticsScreen(),
                    ),
                  );
                },
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8, 
                    vertical: isSmallScreen ? 3 : 4
                  ),
                  decoration: BoxDecoration(
                    color: Colors.teal.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                    border: Border.all(
                      color: Colors.teal.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'VIEW',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 9 : 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 3 : 4),
                      Icon(
                        Icons.arrow_forward,
                        color: Colors.teal,
                        size: isSmallScreen ? 12 : 14,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).animate().fadeIn(delay: 450.ms).scale(begin: const Offset(0.95, 0.95), duration: 500.ms);
  }

  Future<Map<String, dynamic>> _getQuickStats() async {
    try {
      final statisticsService = StatisticsService();
      await statisticsService.initialize();
      return statisticsService.getDisplayStatistics();
    } catch (e) {
      return {};
    }
  }

  Widget _buildMenuButtons(
    BuildContext context,
    GameProvider gameProvider,
    ThemeProvider themeProvider,
    GameTheme theme,
    bool isSmallScreen,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Main Play Button - Responsive
        GradientButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const GameScreen(),
              ),
            );
          },
          text: 'PLAY NOW',
          primaryColor: theme.accentColor,
          secondaryColor: theme.foodColor,
          icon: Icons.play_arrow_rounded,
          width: isSmallScreen ? 200 : 240,
        ).animate().fadeIn(delay: 500.ms).scale(begin: const Offset(0.9, 0.9), duration: 400.ms),
        
        SizedBox(height: isSmallScreen ? 16 : 20),
        
        // Quick Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.help_outline,
              label: 'HOW TO\nPLAY',
              color: theme.foodColor,
              isSmallScreen: isSmallScreen,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => InstructionsDialog(theme: theme),
                );
              },
            ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.3, duration: 300.ms),
            
            _buildQuickActionButton(
              context,
              icon: Icons.leaderboard,
              label: 'LEADER\nBOARD',
              color: Colors.amber,
              isSmallScreen: isSmallScreen,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LeaderboardScreen(),
                  ),
                );
              },
            ).animate().fadeIn(delay: 650.ms).slideY(begin: 0.3, duration: 300.ms),
            
            _buildQuickActionButton(
              context,
              icon: Icons.emoji_events,
              label: 'ACHIEVE\nMENTS',
              color: Colors.purple,
              isSmallScreen: isSmallScreen,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AchievementsScreen(),
                  ),
                );
              },
            ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.3, duration: 300.ms),
          ],
        ),
        
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Secondary Actions Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.people,
              label: 'FRIENDS',
              color: Colors.blue,
              isSmallScreen: isSmallScreen,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FriendsScreen(),
                  ),
                );
              },
            ).animate().fadeIn(delay: 750.ms).slideY(begin: 0.3, duration: 300.ms),
            
            _buildQuickActionButton(
              context,
              icon: Icons.analytics,
              label: 'STATISTICS',
              color: Colors.teal,
              isSmallScreen: isSmallScreen,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                );
              },
            ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.3, duration: 300.ms),
            
            _buildQuickActionButton(
              context,
              icon: Icons.settings,
              label: 'SETTINGS',
              color: theme.accentColor,
              isSmallScreen: isSmallScreen,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ).animate().fadeIn(delay: 850.ms).slideY(begin: 0.3, duration: 300.ms),
          ],
        ),
        
        SizedBox(height: isSmallScreen ? 12 : 16),
        
        // Third Actions Row - Replays, Theme, Friends Leaderboard
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildQuickActionButton(
              context,
              icon: Icons.leaderboard,
              label: 'FRIENDS\nLEADER',
              color: Colors.orange,
              isSmallScreen: isSmallScreen,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const FriendsLeaderboardScreen(),
                  ),
                );
              },
            ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.3, duration: 300.ms),
            
            _buildQuickActionButton(
              context,
              icon: Icons.movie,
              label: 'REPLAYS',
              color: Colors.indigo,
              isSmallScreen: isSmallScreen,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ReplaysScreen(),
                  ),
                );
              },
            ).animate().fadeIn(delay: 950.ms).slideY(begin: 0.3, duration: 300.ms),
            
            _buildQuickActionButton(
              context,
              icon: Icons.palette,
              label: theme.name.toUpperCase().replaceAll(' ', '\n'),
              color: theme.snakeColor,
              isSmallScreen: isSmallScreen,
              onTap: () {
                themeProvider.cycleTheme();
              },
            ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3, duration: 300.ms),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    final buttonSize = isSmallScreen ? 75.0 : 90.0;
    final iconSize = isSmallScreen ? 20.0 : 24.0;
    final fontSize = isSmallScreen ? 8.0 : 9.0;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: iconSize,
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: color,
                letterSpacing: 0.5,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(GameTheme theme, bool isSmallScreen) {
    return Column(
      children: [
        Container(
          height: 1,
          width: isSmallScreen ? 80 : 100,
          color: theme.accentColor.withValues(alpha: 0.3),
        ).animate().fadeIn(delay: 1000.ms).scaleX(duration: 400.ms),
        
        SizedBox(height: isSmallScreen ? 8 : 12),
        
        Text(
          'Swipe to control • Tap to pause',
          style: TextStyle(
            fontSize: isSmallScreen ? 10 : 12,
            color: theme.accentColor.withValues(alpha: 0.6),
            letterSpacing: 1,
          ),
        ).animate().fadeIn(delay: 1100.ms, duration: 400.ms),
      ],
    );
  }
}