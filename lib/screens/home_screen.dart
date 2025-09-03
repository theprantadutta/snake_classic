import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:talker_flutter/talker_flutter.dart';
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
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/widgets/animated_snake_logo.dart';
import 'package:snake_classic/widgets/instructions_dialog.dart';
import 'package:snake_classic/widgets/theme_transition_system.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Reduced duration
      vsync: this,
    );

    // Initialize theme transitions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ThemeProvider>().initializeTransitions(this);
    });

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

        return ThemeTransitionWidget(
          controller:
              themeProvider.transitionController ??
              ThemeTransitionController(vsync: this),
          currentTheme: theme,
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
            floatingActionButton: kDebugMode
                ? FloatingActionButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TalkerScreen(talker: AppLogger.instance),
                        ),
                      );
                    },
                    backgroundColor: theme.accentColor.withValues(alpha: 0.1),
                    foregroundColor: theme.accentColor,
                    mini: true,
                    child: const Icon(Icons.bug_report),
                  )
                : null,
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
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Use the logo with text for a cleaner look
        SizedBox(
          width: isSmallScreen ? 120 : 150,
          height: isSmallScreen ? 80 : 100,
          child: AnimatedSnakeLogo(
            theme: theme, 
            controller: _logoController,
            size: isSmallScreen ? 120 : 150,
            useTextLogo: true, // Use logo with text for home screen
          ),
        ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),
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
        // Enhanced Stats cards row
        Row(
          children: [
            // High Score Card with enhancements
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _getQuickStats(),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? {};
                  final previousBest = stats['previousBest'] ?? 0;
                  String? trend;
                  if (highScore > previousBest && previousBest > 0) {
                    final improvement = highScore - previousBest;
                    trend = '+$improvement';
                  }
                  
                  return _buildStatCard(
                    icon: Icons.emoji_events,
                    iconColor: Colors.amber,
                    title: 'BEST SCORE',
                    value: '$highScore',
                    subtitle: highScore > 0 ? 'Personal Record' : 'Start Playing!',
                    trend: trend,
                    theme: theme,
                    isSmallScreen: isSmallScreen,
                    hasSync: userProvider.isSignedIn,
                    isPulsing: highScore > (stats['previousBest'] ?? 0),
                  );
                },
              ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.3),
            ),

            SizedBox(width: isSmallScreen ? 12 : 16),

            // Enhanced Statistics Card
            Expanded(
              child: FutureBuilder<Map<String, dynamic>>(
                future: _getQuickStats(),
                builder: (context, snapshot) {
                  final stats = snapshot.data ?? {};
                  final totalGames = stats['totalGames'] ?? 0;
                  final avgScore = stats['averageScore'] ?? 0.0;
                  final winRate = stats['winRate'] ?? 0.0;
                  
                  return _buildStatCard(
                    icon: totalGames > 10 
                      ? Icons.trending_up 
                      : totalGames > 0 
                        ? Icons.analytics 
                        : Icons.rocket_launch,
                    iconColor: totalGames > 50 
                      ? Colors.purple 
                      : totalGames > 10 
                        ? Colors.blue 
                        : Colors.teal,
                    title: totalGames > 0 ? 'GAMES PLAYED' : 'READY TO PLAY',
                    value: totalGames > 0 ? '$totalGames' : '🎮',
                    subtitle: totalGames > 0 
                      ? avgScore > 0 
                        ? 'Avg: ${avgScore.toInt()}'
                        : 'Keep playing!'
                      : 'Start your journey',
                    trend: winRate > 0.5 ? '🔥 Hot' : null,
                    theme: theme,
                    isSmallScreen: isSmallScreen,
                    isPulsing: totalGames == 0, // Pulse for new players
                  );
                },
              ).animate().fadeIn(delay: 650.ms).slideX(begin: 0.3),
            ),
          ],
        ),

        // Additional stats row (if user has played games)
        FutureBuilder<Map<String, dynamic>>(
          future: _getQuickStats(),
          builder: (context, snapshot) {
            final stats = snapshot.data ?? {};
            final totalGames = stats['totalGames'] ?? 0;
            
            if (totalGames < 5) return const SizedBox.shrink();
            
            return Column(
              children: [
                SizedBox(height: isSmallScreen ? 16 : 20),
                Row(
                  children: [
                    // Achievement Progress Card
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.workspace_premium,
                        iconColor: Colors.deepPurple,
                        title: 'ACHIEVEMENTS',
                        value: '${stats['unlockedAchievements'] ?? 0}',
                        subtitle: '${stats['totalAchievements'] ?? 0} available',
                        theme: theme,
                        isSmallScreen: isSmallScreen,
                      ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),
                    ),

                    SizedBox(width: isSmallScreen ? 12 : 16),

                    // Streak Card
                    Expanded(
                      child: _buildStatCard(
                        icon: Icons.local_fire_department,
                        iconColor: Colors.orange,
                        title: 'CURRENT STREAK',
                        value: '${stats['currentStreak'] ?? 0}',
                        subtitle: stats['currentStreak'] ?? 0 > 0 ? 'games' : 'Play to start',
                        trend: (stats['currentStreak'] ?? 0) > 5 ? '🔥' : null,
                        theme: theme,
                        isSmallScreen: isSmallScreen,
                        isPulsing: (stats['currentStreak'] ?? 0) >= 10,
                      ).animate().fadeIn(delay: 850.ms).slideY(begin: 0.2),
                    ),
                  ],
                ),
              ],
            );
          },
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
    String? subtitle,
    String? trend,
    bool isPulsing = false,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            iconColor.withValues(alpha: isPulsing ? 0.15 : 0.1),
            iconColor.withValues(alpha: isPulsing ? 0.08 : 0.05),
            theme.backgroundColor.withValues(alpha: 0.02),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 20 : 24),
        border: Border.all(
          color: iconColor.withValues(alpha: isPulsing ? 0.4 : 0.3), 
          width: isPulsing ? 1.5 : 1
        ),
        boxShadow: [
          BoxShadow(
            color: iconColor.withValues(alpha: isPulsing ? 0.3 : 0.2),
            blurRadius: isPulsing ? 16 : 12,
            spreadRadius: isPulsing ? 2 : 0,
            offset: const Offset(0, 4),
          ),
          if (isPulsing) // Additional inner glow for pulsing cards
            BoxShadow(
              color: iconColor.withValues(alpha: 0.1),
              blurRadius: 6,
              spreadRadius: -2,
              offset: const Offset(0, -2),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Enhanced icon container with animations
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 2000),
                tween: Tween(begin: 0.0, end: 1.0),
                builder: (context, value, child) {
                  return Transform.rotate(
                    angle: isPulsing ? value * 0.1 : 0, // Subtle rotation for pulsing cards
                    child: Container(
                      padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            iconColor.withValues(alpha: 0.3),
                            iconColor.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 14),
                        boxShadow: [
                          BoxShadow(
                            color: iconColor.withValues(alpha: 0.2),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        color: iconColor,
                        size: isSmallScreen ? 20 : 24,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              // Enhanced status indicators
              Row(
                children: [
                  if (trend != null)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 4 : 6,
                        vertical: isSmallScreen ? 2 : 3,
                      ),
                      decoration: BoxDecoration(
                        color: trend.startsWith('+') 
                          ? Colors.green.withValues(alpha: 0.2)
                          : trend.startsWith('-')
                            ? Colors.red.withValues(alpha: 0.2)
                            : Colors.orange.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                      ),
                      child: Text(
                        trend,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 8 : 10,
                          fontWeight: FontWeight.w700,
                          color: trend.startsWith('+') 
                            ? Colors.green.shade700
                            : trend.startsWith('-')
                              ? Colors.red.shade700
                              : Colors.orange.shade700,
                        ),
                      ),
                    ),
                  if (trend != null) SizedBox(width: isSmallScreen ? 4 : 6),
                  if (hasSync)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: isSmallScreen ? 6 : 8,
                        vertical: isSmallScreen ? 3 : 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withValues(alpha: 0.25),
                            Colors.green.withValues(alpha: 0.15),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_done,
                            color: Colors.green.shade600,
                            size: isSmallScreen ? 10 : 12,
                          ),
                          SizedBox(width: 2),
                          Text(
                            'SYNCED',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 7 : 8,
                              fontWeight: FontWeight.w600,
                              color: Colors.green.shade700,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          SizedBox(height: isSmallScreen ? 12 : 16),

          // Enhanced title with better typography
          Text(
            title,
            style: TextStyle(
              fontSize: isSmallScreen ? 10 : 12,
              fontWeight: FontWeight.w700,
              color: theme.accentColor.withValues(alpha: 0.8),
              letterSpacing: 1.2,
              height: 1.1,
            ),
          ),

          SizedBox(height: isSmallScreen ? 6 : 8),

          // Enhanced value display with shimmer effect
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 1000),
                  tween: Tween(begin: 0.0, end: double.tryParse(value) ?? 0.0),
                  builder: (context, animatedValue, child) {
                    final displayValue = value.contains(RegExp(r'^\d+$')) 
                      ? animatedValue.toInt().toString()
                      : value;
                    return Text(
                      displayValue,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 26 : 30,
                        fontWeight: FontWeight.w900,
                        color: theme.accentColor,
                        height: 0.9,
                        shadows: isPulsing ? [
                          Shadow(
                            color: iconColor.withValues(alpha: 0.3),
                            blurRadius: 2,
                          ),
                        ] : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          // Optional subtitle
          if (subtitle != null) ...[
            SizedBox(height: isSmallScreen ? 2 : 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: isSmallScreen ? 8 : 10,
                fontWeight: FontWeight.w500,
                color: theme.accentColor.withValues(alpha: 0.5),
                letterSpacing: 0.5,
              ),
            ),
          ],
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
              Icon(Icons.emoji_events, color: Colors.amber, size: 28),
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
          content: SizedBox(
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
                      Icon(Icons.code, color: theme.accentColor, size: 20),
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
                          Icon(Icons.stars, color: Colors.amber, size: 20),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
            child: Icon(icon, color: theme.accentColor, size: 16),
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
