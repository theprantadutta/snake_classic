import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/screens/achievements_screen.dart';
import 'package:snake_classic/screens/friends_screen.dart';
import 'package:snake_classic/screens/game_screen.dart';
import 'package:snake_classic/screens/leaderboard_screen.dart';
import 'package:snake_classic/screens/multiplayer_lobby_screen.dart';
import 'package:snake_classic/screens/profile_screen.dart';
import 'package:snake_classic/screens/replays_screen.dart';
import 'package:snake_classic/screens/settings_screen.dart';
import 'package:snake_classic/screens/statistics_screen.dart';
import 'package:snake_classic/screens/tournaments_screen.dart';
import 'package:snake_classic/screens/store_screen.dart';
import 'package:snake_classic/screens/premium_benefits_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/screens/instructions_screen.dart';
import 'package:snake_classic/widgets/theme_transition_system.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:talker_flutter/talker_flutter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
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
            body: AppBackground(
              theme: theme,
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final screenWidth = constraints.maxWidth;
                    final screenHeight = constraints.maxHeight;

                    // Improved screen size detection for better responsiveness
                    final isVerySmallScreen = screenHeight < 650;
                    final isSmallScreen = screenHeight < 750;
                    final isMediumScreen =
                        screenHeight >= 750 && screenHeight < 900;
                    final isTallScreen = screenHeight >= 900;

                    // Dynamic spacing based on screen height
                    final topSpacing = isVerySmallScreen
                        ? 8.0
                        : isSmallScreen
                        ? 12.0
                        : isMediumScreen
                        ? 16.0
                        : 20.0;
                    final sectionSpacing = isVerySmallScreen
                        ? 16.0
                        : isSmallScreen
                        ? 20.0
                        : isMediumScreen
                        ? 28.0
                        : 36.0;
                    final bottomSpacing = isVerySmallScreen
                        ? 8.0
                        : isSmallScreen
                        ? 12.0
                        : isMediumScreen
                        ? 16.0
                        : 20.0;

                    return Padding(
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
                                  isVerySmallScreen,
                                ),

                                SizedBox(height: topSpacing),

                                // Game title with logo - fixed size
                                _buildGameTitle(theme, screenHeight),

                                SizedBox(height: sectionSpacing * 0.5),

                                // Main play area with central button
                                _buildMainPlayArea(
                                  context,
                                  gameProvider,
                                  userProvider,
                                  theme,
                                  screenHeight,
                                  screenWidth,
                                  screenHeight,
                                ),

                                const Spacer(), // Push bottom navigation to bottom

                                // Bottom navigation grid - fixed at bottom
                                _buildBottomNavigation(
                                  context,
                                  themeProvider,
                                  theme,
                                  screenHeight,
                                  screenWidth,
                                ),

                                SizedBox(height: bottomSpacing),
                              ],
                            ),
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
                          builder: (context) =>
                              TalkerScreen(talker: AppLogger.instance),
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

  Widget _buildActionButton({
    required BuildContext context,
    required GameTheme theme,
    required bool isSmallScreen,
    required IconData icon,
    required String label,
    required List<Color> colors,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isSmallScreen ? 50 : 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colors.first.withValues(alpha: 0.15),
              colors.last.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 14 : 16),
          border: Border.all(
            color: colors.first.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: colors.first.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: colors.first,
              size: isSmallScreen ? 16 : 20,
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              label,
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 13,
                fontWeight: FontWeight.w700,
                color: colors.first,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const InstructionsScreen(),
                  ),
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

  Widget _buildGameTitle(GameTheme theme, double screenHeight) {
    // Simplified logo sizing
    final logoSize = screenHeight < 650 ? 120.0 : screenHeight < 750 ? 140.0 : 160.0;
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Simplified logo container
          Container(
            width: logoSize,
            height: logoSize * 0.6, // Maintain aspect ratio
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.1),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/snake_classic_logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to text if image fails
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.accentColor, theme.foodColor],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.games,
                          size: logoSize * 0.3,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'SNAKE\nCLASSIC',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: logoSize * 0.08,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainPlayArea(
    BuildContext context,
    GameProvider gameProvider,
    UserProvider userProvider,
    GameTheme theme,
    double screenHeight,
    double screenWidth,
    double actualScreenHeight,
  ) {
    // Dynamic sizing based on screen height
    final isVerySmallScreen = screenHeight < 650;
    final isSmallScreen = screenHeight < 750;
    final isMediumScreen = screenHeight >= 750 && screenHeight < 900;
    // Note: isTallScreen handled in main build method
    final highScore = userProvider.isSignedIn
        ? (userProvider.highScore > gameProvider.gameState.highScore
              ? userProvider.highScore
              : gameProvider.gameState.highScore)
        : gameProvider.gameState.highScore;

    return Container(
      padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 16 : 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Best Score Card as full width
          _buildCompactScoreCard(
            highScore: highScore,
            trend: null,
            theme: theme,
            isSmallScreen: isVerySmallScreen || isSmallScreen,
            hasSync: userProvider.isSignedIn,
            isPulsing: false,
          ),

          SizedBox(height: isSmallScreen ? 16 : 20),

          // Store and Premium buttons row
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  context: context,
                  theme: theme,
                  isSmallScreen: isVerySmallScreen || isSmallScreen,
                  icon: Icons.star,
                  label: 'PREMIUM',
                  colors: [Colors.purple, Colors.blue],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const PremiumBenefitsScreen()),
                  ),
                ),
              ),
              SizedBox(width: isSmallScreen ? 12 : 16),
              Expanded(
                child: _buildActionButton(
                  context: context,
                  theme: theme,
                  isSmallScreen: isVerySmallScreen || isSmallScreen,
                  icon: Icons.store,
                  label: 'STORE',
                  colors: [Colors.orange, Colors.amber],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const StoreScreen()),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: isSmallScreen ? 24 : 32),

          // Central Play Button
          _buildCentralPlayButton(context, theme, screenHeight, screenWidth),

          SizedBox(height: isSmallScreen ? 16 : 20),

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
          ),
        ],
      ),
    );
  }


  Widget _buildCentralPlayButton(
    BuildContext context,
    GameTheme theme,
    double screenHeight,
    double screenWidth,
  ) {
    // Dynamic sizing based on screen height - slightly larger to balance with bigger logo
    final isSmallScreen = screenHeight < 750;
    final buttonSize = screenHeight < 650
        ? 110.0
        : screenHeight < 750
        ? 130.0
        : screenHeight < 900
        ? 150.0
        : 170.0;

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
    double screenHeight,
    double screenWidth,
  ) {
    // Dynamic sizing based on screen height
    final isVerySmallScreen = screenHeight < 650;
    final isSmallScreen = screenHeight < 750;
    // Note: isMediumScreen not needed in bottom navigation
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
                  isSmallScreen: isVerySmallScreen || isSmallScreen,
                )
                .animate()
                .fadeIn(delay: (900 + (index * 100)).ms)
                .slideY(begin: 0.5, duration: 400.ms);
          }).toList(),
        ),

        SizedBox(
          height: isVerySmallScreen
              ? 8
              : isSmallScreen
              ? 12
              : 16,
        ),

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
                      isSmallScreen: isVerySmallScreen || isSmallScreen,
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

  Widget _buildCompactScoreCard({
    required int highScore,
    String? trend,
    required GameTheme theme,
    required bool isSmallScreen,
    bool hasSync = false,
    bool isPulsing = false,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const StatisticsScreen()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withValues(alpha: isPulsing ? 0.2 : 0.15),
              Colors.amber.withValues(alpha: isPulsing ? 0.1 : 0.08),
              theme.backgroundColor.withValues(alpha: 0.02),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
          border: Border.all(
            color: Colors.amber.withValues(alpha: isPulsing ? 0.4 : 0.3),
            width: isPulsing ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: isPulsing ? 0.3 : 0.2),
              blurRadius: isPulsing ? 16 : 12,
              spreadRadius: isPulsing ? 2 : 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.amber,
                  size: isSmallScreen ? 18 : 22,
                ),
                const Spacer(),
                if (trend != null)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 4 : 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      trend,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 8 : 9,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                if (hasSync) ...[
                  if (trend != null) const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      Icons.cloud_done,
                      color: Colors.green.shade600,
                      size: isSmallScreen ? 8 : 10,
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: isSmallScreen ? 4 : 6),
            Text(
              'BEST SCORE',
              style: TextStyle(
                fontSize: isSmallScreen ? 9 : 10,
                fontWeight: FontWeight.w700,
                color: theme.accentColor.withValues(alpha: 0.7),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '$highScore',
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.w900,
                color: Colors.amber,
                height: 1.0,
              ),
            ),
          ],
        ),
      ),
    );
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

