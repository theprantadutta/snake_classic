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
import 'package:snake_classic/screens/replays_screen.dart';
import 'package:snake_classic/screens/tournaments_screen.dart';
import 'package:snake_classic/screens/multiplayer_lobby_screen.dart';
import 'package:snake_classic/screens/friends_screen.dart';
import 'package:snake_classic/screens/statistics_screen.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/utils/constants.dart';
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = constraints.maxWidth;
                  final screenHeight = constraints.maxHeight;
                  final isSmallScreen = screenHeight < 700;

                  return Stack(
                    children: [
                      // Background pattern overlay
                      _buildBackgroundPattern(theme, constraints),

                      // Main content
                      Positioned.fill(
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: isSmallScreen ? 8 : 12,
                          ),
                          child: Column(
                            children: [
                              // Top navigation bar
                              _buildTopNavigation(
                                context,
                                userProvider,
                                theme,
                                isSmallScreen,
                              ),

                              SizedBox(height: isSmallScreen ? 16 : 24),

                              // Game title with logo
                              _buildGameTitle(theme, isSmallScreen),

                              SizedBox(height: isSmallScreen ? 20 : 28),

                              // Main play area with central button
                              Expanded(
                                child: _buildMainPlayArea(
                                  context,
                                  gameProvider,
                                  userProvider,
                                  theme,
                                  isSmallScreen,
                                  screenWidth,
                                  screenHeight,
                                ),
                              ),

                              // Bottom navigation grid
                              _buildBottomNavigation(
                                context,
                                themeProvider,
                                theme,
                                isSmallScreen,
                                screenWidth,
                              ),

                              SizedBox(height: isSmallScreen ? 8 : 12),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackgroundPattern(GameTheme theme, BoxConstraints constraints) {
    return Positioned.fill(
      child: CustomPaint(painter: _GameBackgroundPainter(theme)),
    );
  }

  Widget _buildTopNavigation(
    BuildContext context,
    UserProvider userProvider,
    GameTheme theme,
    bool isSmallScreen,
  ) {
    return Row(
      children: [
        // Theme switcher
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.palette,
              color: theme.accentColor,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
        ),

        SizedBox(width: isSmallScreen ? 8 : 12),

        // Credits button
        GestureDetector(
          onTap: () {
            _showCreditsDialog(context, theme);
          },
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            decoration: BoxDecoration(
              color: theme.foodColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(
                color: theme.foodColor.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Icon(
              Icons.info_outline,
              color: theme.foodColor,
              size: isSmallScreen ? 20 : 24,
            ),
          ),
        ),

        const Spacer(),

        // Settings and profile
        Row(
          children: [
            GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => InstructionsDialog(theme: theme),
                );
              },
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  color: theme.foodColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  border: Border.all(
                    color: theme.foodColor.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Icon(
                  Icons.help_outline,
                  color: theme.foodColor,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
            ),

            SizedBox(width: isSmallScreen ? 8 : 12),

            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withValues(alpha: 0.2),
                      Colors.orange.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: userProvider.isSignedIn && userProvider.photoURL != null
                    ? CircleAvatar(
                        radius: isSmallScreen ? 12 : 16,
                        backgroundImage: NetworkImage(userProvider.photoURL!),
                      )
                    : Icon(
                        Icons.account_circle,
                        color: Colors.amber,
                        size: isSmallScreen ? 20 : 24,
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGameTitle(GameTheme theme, bool isSmallScreen) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated logo
        SizedBox(
          width: isSmallScreen ? 50 : 60,
          height: isSmallScreen ? 50 : 60,
          child: AnimatedSnakeLogo(theme: theme, controller: _logoController),
        ),

        SizedBox(width: isSmallScreen ? 12 : 16),

        // Title text
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SNAKE',
              style: TextStyle(
                fontSize: isSmallScreen ? 32 : 40,
                fontWeight: FontWeight.w900,
                color: theme.accentColor,
                letterSpacing: 3,
                shadows: [
                  Shadow(
                    offset: const Offset(2, 2),
                    blurRadius: 8,
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.5),

            Text(
              'CLASSIC',
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                fontWeight: FontWeight.w300,
                color: theme.accentColor.withValues(alpha: 0.7),
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
          ],
        ),
      ],
    );
  }

  Widget _buildMainPlayArea(
    BuildContext context,
    GameProvider gameProvider,
    UserProvider userProvider,
    GameTheme theme,
    bool isSmallScreen,
    double screenWidth,
    double screenHeight,
  ) {
    final highScore = userProvider.isSignedIn
        ? (userProvider.highScore > gameProvider.gameState.highScore
              ? userProvider.highScore
              : gameProvider.gameState.highScore)
        : gameProvider.gameState.highScore;

    return Column(
      children: [
        // Stats cards row
        Row(
          children: [
            // High Score Card
            Expanded(
              child: _buildStatCard(
                icon: Icons.emoji_events,
                iconColor: Colors.amber,
                title: 'BEST SCORE',
                value: '$highScore',
                theme: theme,
                isSmallScreen: isSmallScreen,
                hasSync: userProvider.isSignedIn,
              ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.3),
            ),

            SizedBox(width: isSmallScreen ? 12 : 16),

            // Quick Stats Card
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _getQuickStats(),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? {};
                  return _buildStatCard(
                    icon: Icons.analytics,
                    iconColor: Colors.teal,
                    title: 'TOTAL GAMES',
                    value: '${stats['totalGames'] ?? 0}',
                    theme: theme,
                    isSmallScreen: isSmallScreen,
                  );
                },
              ).animate().fadeIn(delay: 650.ms).slideX(begin: 0.3),
            ),
          ],
        ),

        SizedBox(height: isSmallScreen ? 24 : 32),

        // Central Play Button
        _buildCentralPlayButton(context, theme, isSmallScreen, screenWidth)
            .animate()
            .fadeIn(delay: 700.ms)
            .scale(begin: const Offset(0.8, 0.8), duration: 600.ms)
            .then()
            .shimmer(
              duration: 2000.ms,
              color: theme.accentColor.withValues(alpha: 0.3),
            ),

        SizedBox(height: isSmallScreen ? 20 : 28),

        // Quick action hint
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 12 : 16,
            vertical: isSmallScreen ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 25),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            'Swipe to control • Tap to pause',
            style: TextStyle(
              fontSize: isSmallScreen ? 11 : 13,
              color: theme.accentColor.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.5,
            ),
          ),
        ).animate().fadeIn(delay: 800.ms),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required GameTheme theme,
    required bool isSmallScreen,
    bool hasSync = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withValues(alpha: 0.1),
            iconColor.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        border: Border.all(color: iconColor.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: 0.2),
            blurRadius: 12,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: isSmallScreen ? 20 : 24,
                ),
              ),
              const Spacer(),
              if (hasSync)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8,
                    vertical: isSmallScreen ? 3 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                  ),
                  child: Icon(
                    Icons.cloud_done,
                    color: Colors.green,
                    size: isSmallScreen ? 12 : 14,
                  ),
                ),
            ],
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w600,
              color: theme.accentColor.withValues(alpha: 0.7),
              letterSpacing: 1,
            ),
          ),

          SizedBox(height: isSmallScreen ? 4 : 6),

          Text(
            value,
            style: TextStyle(
              fontSize: isSmallScreen ? 24 : 28,
              fontWeight: FontWeight.w900,
              color: theme.accentColor,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCentralPlayButton(
    BuildContext context,
    GameTheme theme,
    bool isSmallScreen,
    double screenWidth,
  ) {
    final buttonSize = isSmallScreen ? 120.0 : 140.0;

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const GameScreen()));
      },
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            colors: [
              theme.accentColor,
              theme.foodColor,
              theme.accentColor.withValues(alpha: 0.8),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: theme.accentColor.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: theme.foodColor.withValues(alpha: 0.3),
              blurRadius: 40,
              spreadRadius: 0,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Container(
              width: buttonSize - 8,
              height: buttonSize - 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),

            // Centered content
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Play icon
                Icon(
                  Icons.play_arrow_rounded,
                  size: isSmallScreen ? 40 : 48,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      offset: const Offset(2, 2),
                      blurRadius: 8,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),

                SizedBox(height: isSmallScreen ? 4 : 6),

                // Text below icon
                Text(
                  'PLAY',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 13,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                    shadows: [
                      Shadow(
                        offset: const Offset(1, 1),
                        blurRadius: 4,
                        color: Colors.black.withValues(alpha: 0.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigation(
    BuildContext context,
    ThemeProvider themeProvider,
    GameTheme theme,
    bool isSmallScreen,
    double screenWidth,
  ) {
    final navigationItems = [
      _NavItem(Icons.leaderboard, 'BOARD', Colors.amber, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const LeaderboardScreen()),
        );
      }),
      _NavItem(Icons.group_work, 'MULTI', Colors.green, () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const MultiplayerLobbyScreen(),
          ),
        );
      }),
      _NavItem(Icons.emoji_events, 'EVENTS', Colors.purple, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const TournamentsScreen()),
        );
      }),
      _NavItem(Icons.people, 'FRIENDS', Colors.blue, () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const FriendsScreen()));
      }),
      _NavItem(Icons.analytics, 'STATS', Colors.teal, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const StatisticsScreen()),
        );
      }),
      _NavItem(Icons.movie, 'REPLAY', Colors.indigo, () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const ReplaysScreen()));
      }),
      _NavItem(Icons.military_tech, 'AWARDS', Colors.orange, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AchievementsScreen()),
        );
      }),
      _NavItem(Icons.palette, 'THEME', theme.snakeColor, () {
        themeProvider.cycleTheme();
      }),
    ];

    return Column(
      children: [
        // First row - 4 items
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: navigationItems.take(4).toList().asMap().entries.map((
            entry,
          ) {
            final index = entry.key;
            final item = entry.value;

            return _buildNavButton(
                  icon: item.icon,
                  label: item.label,
                  color: item.color,
                  onTap: item.onTap,
                  theme: theme,
                  isSmallScreen: isSmallScreen,
                )
                .animate()
                .fadeIn(delay: (900 + (index * 100)).ms)
                .slideY(begin: 0.5, duration: 400.ms);
          }).toList(),
        ),

        SizedBox(height: isSmallScreen ? 12 : 16),

        // Second row - 4 items
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: navigationItems
              .skip(4)
              .take(4)
              .toList()
              .asMap()
              .entries
              .map((entry) {
                final index = entry.key + 4; // Adjust index for animation delay
                final item = entry.value;

                return _buildNavButton(
                      icon: item.icon,
                      label: item.label,
                      color: item.color,
                      onTap: item.onTap,
                      theme: theme,
                      isSmallScreen: isSmallScreen,
                    )
                    .animate()
                    .fadeIn(delay: (900 + (index * 100)).ms)
                    .slideY(begin: 0.5, duration: 400.ms);
              })
              .toList(),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required GameTheme theme,
    required bool isSmallScreen,
  }) {
    final buttonSize = isSmallScreen ? 42.0 : 50.0;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: buttonSize,
            height: buttonSize,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 18),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 0,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: isSmallScreen ? 20 : 24),
          ),

          SizedBox(height: isSmallScreen ? 4 : 6),

          Text(
            label,
            style: TextStyle(
              fontSize: isSmallScreen ? 8 : 9,
              fontWeight: FontWeight.w600,
              color: theme.accentColor.withValues(alpha: 0.8),
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
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

  void _showCreditsDialog(BuildContext context, GameTheme theme) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: theme.backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: theme.accentColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          title: Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: Colors.amber,
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                'Snake Classic',
                style: TextStyle(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Version info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: theme.accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.code,
                        color: theme.accentColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Version 2.0.0',
                              style: TextStyle(
                                color: theme.accentColor,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Built with Flutter & Firebase',
                              style: TextStyle(
                                color: theme.accentColor.withValues(alpha: 0.7),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Development credits
                Text(
                  'Development',
                  style: TextStyle(
                    color: theme.foodColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildCreditItem(
                  icon: Icons.person,
                  title: 'Game Design & Development',
                  subtitle: 'Premium Snake Experience',
                  theme: theme,
                ),
                
                const SizedBox(height: 16),
                
                // Technology credits
                Text(
                  'Powered By',
                  style: TextStyle(
                    color: theme.foodColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildCreditItem(
                  icon: Icons.flutter_dash,
                  title: 'Flutter Framework',
                  subtitle: 'Cross-platform UI toolkit',
                  theme: theme,
                ),
                _buildCreditItem(
                  icon: Icons.cloud,
                  title: 'Firebase',
                  subtitle: 'Backend & Authentication',
                  theme: theme,
                ),
                _buildCreditItem(
                  icon: Icons.leaderboard,
                  title: 'Real-time Features',
                  subtitle: 'Multiplayer & Leaderboards',
                  theme: theme,
                ),
                
                const SizedBox(height: 16),
                
                // Special features highlight
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.amber.withValues(alpha: 0.1),
                        Colors.orange.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Premium Features',
                            style: TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• 6 Premium Visual Themes\n• Real-time Multiplayer\n• Tournament System\n• 16 Achievements\n• Advanced Statistics\n• Game Replay System',
                        style: TextStyle(
                          color: theme.accentColor.withValues(alpha: 0.8),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 12),
                
                // Footer
                Center(
                  child: Text(
                    'Thank you for playing! 🐍',
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                backgroundColor: theme.accentColor.withValues(alpha: 0.1),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.accentColor.withValues(alpha: 0.3),
                  ),
                ),
              ),
              child: Text(
                'Close',
                style: TextStyle(
                  color: theme.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCreditItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required GameTheme theme,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: theme.accentColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.accentColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.6),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Navigation item helper class
class _NavItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _NavItem(this.icon, this.label, this.color, this.onTap);
}

// Custom painter for game background
class _GameBackgroundPainter extends CustomPainter {
  final GameTheme theme;

  _GameBackgroundPainter(this.theme);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = theme.accentColor.withValues(alpha: 0.05);

    // Draw subtle grid pattern
    const gridSize = 30.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw decorative shapes
    final shapePaint = Paint()
      ..style = PaintingStyle.fill
      ..color = theme.foodColor.withValues(alpha: 0.02);

    canvas.drawCircle(
      Offset(size.width * 0.15, size.height * 0.25),
      50,
      shapePaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.85, size.height * 0.75),
      70,
      shapePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is! _GameBackgroundPainter || oldDelegate.theme != theme;
  }
}
