import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/game_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/screens/achievements_screen.dart';
import 'package:snake_classic/screens/battle_pass_screen.dart';
import 'package:snake_classic/screens/cosmetics_screen.dart';
import 'package:snake_classic/screens/friends_screen.dart';
import 'package:snake_classic/screens/game_screen.dart';
import 'package:snake_classic/screens/instructions_screen.dart';
import 'package:snake_classic/screens/leaderboard_screen.dart';
import 'package:snake_classic/screens/multiplayer_lobby_screen.dart';
import 'package:snake_classic/screens/premium_benefits_screen.dart';
import 'package:snake_classic/screens/profile_screen.dart';
import 'package:snake_classic/screens/settings_screen.dart';
import 'package:snake_classic/screens/statistics_screen.dart';
import 'package:snake_classic/screens/store_screen.dart';
import 'package:snake_classic/screens/theme_selector_screen.dart';
import 'package:snake_classic/screens/tournaments_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/theme_transition_system.dart';
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

                    // Enhanced screen size detection with more granular breakpoints
                    final isVerySmallScreen =
                        screenHeight < 600 || screenWidth < 350;

                    // Use a simple Column with proper constraints for better stability
                    return Column(
                      children: [
                        // Top navigation bar - fixed height
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: isVerySmallScreen ? 4 : 8,
                          ),
                          child: _buildTopNavigation(
                            context,
                            userProvider,
                            theme,
                            isVerySmallScreen,
                          ),
                        ),

                        // Game title with logo - flexible sizing
                        _buildGameTitle(theme, screenHeight),

                        // Main content area - scrollable if needed
                        Expanded(
                          child: screenHeight < 600
                              ? SingleChildScrollView(
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: (screenHeight * 0.6).clamp(
                                          300,
                                          500,
                                        ),
                                        child: _buildMainPlayArea(
                                          context,
                                          gameProvider,
                                          userProvider,
                                          theme,
                                          screenHeight,
                                          screenWidth,
                                          screenHeight,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: screenWidth * 0.04,
                                        ),
                                        child: _buildBottomNavigation(
                                          context,
                                          themeProvider,
                                          theme,
                                          screenHeight,
                                          screenWidth,
                                        ),
                                      ),
                                      SizedBox(
                                        height: isVerySmallScreen ? 8 : 12,
                                      ),
                                    ],
                                  ),
                                )
                              : Column(
                                  children: [
                                    // Main play area - takes available space
                                    Expanded(
                                      child: _buildMainPlayArea(
                                        context,
                                        gameProvider,
                                        userProvider,
                                        theme,
                                        screenHeight,
                                        screenWidth,
                                        screenHeight,
                                      ),
                                    ),

                                    // Bottom navigation grid - fixed at bottom
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: screenWidth * 0.04,
                                        vertical: isVerySmallScreen ? 8 : 12,
                                      ),
                                      child: _buildBottomNavigation(
                                        context,
                                        themeProvider,
                                        theme,
                                        screenHeight,
                                        screenWidth,
                                      ),
                                    ),
                                  ],
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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive logo size based on available space and screen dimensions
        final maxWidth =
            constraints.maxWidth * 0.6; // Max 60% of available width
        final maxHeight = screenHeight * 0.15; // Max 15% of screen height
        final logoSize =
            (screenHeight < 650
                    ? 120.0
                    : screenHeight < 750
                    ? 150.0
                    : 180.0)
                .clamp(80.0, maxWidth.clamp(100.0, 200.0));

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: screenHeight < 650 ? 8 : 12,
            horizontal: 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Simplified logo container
              Container(
                width: logoSize,
                height: (logoSize * 0.6).clamp(60.0, maxHeight),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: theme.accentColor.withValues(alpha: 0.1),
                      blurRadius: 15,
                      spreadRadius: 3,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
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
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.games,
                              size: (logoSize * 0.25).clamp(20.0, 40.0),
                              color: Colors.white,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'SNAKE\nCLASSIC',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: (logoSize * 0.06).clamp(8.0, 16.0),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
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
      },
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
    final isSmallScreen = screenHeight < 750;
    final highScore = userProvider.isSignedIn
        ? (userProvider.highScore > gameProvider.gameState.highScore
              ? userProvider.highScore
              : gameProvider.gameState.highScore)
        : gameProvider.gameState.highScore;

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        final spacing = (availableHeight * 0.02).clamp(8.0, 16.0);

        // Ensure minimum height constraints
        if (availableHeight < 200) {
          return const SizedBox(
            height: 200,
            child: Center(child: CircularProgressIndicator()),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(
            vertical: (availableHeight * 0.02).clamp(8.0, 20.0),
            horizontal: 16,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Compact stats row with score and quick actions
              Flexible(
                flex: 3,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: availableHeight > 0
                        ? availableHeight * 0.25
                        : 120,
                    minHeight: 80,
                  ),
                  child: _buildCompactStatsRow(
                    context: context,
                    highScore: highScore,
                    theme: theme,
                    screenWidth: screenWidth,
                    isSmallScreen: isSmallScreen,
                    hasSync: userProvider.isSignedIn,
                  ),
                ),
              ),

              SizedBox(height: spacing),

              // Hero Play Button - Main focal point
              Flexible(
                flex: 5,
                child: Container(
                  constraints: BoxConstraints(
                    maxHeight: availableHeight > 0
                        ? availableHeight * 0.4
                        : 200,
                    maxWidth: availableWidth * 0.8,
                  ),
                  child: _buildHeroPlayButton(
                    context,
                    theme,
                    screenHeight,
                    screenWidth,
                  ),
                ),
              ),

              SizedBox(height: spacing),

              // Action buttons row - Store and Premium
              Container(
                constraints: BoxConstraints(maxHeight: 80, minHeight: 56),
                child: _buildActionButtonsRow(
                  context: context,
                  theme: theme,
                  screenWidth: screenWidth,
                  isSmallScreen: isSmallScreen,
                ),
              ),

              SizedBox(height: spacing * 0.5),

              // Game hint
              _buildGameHint(theme, isSmallScreen),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeroPlayButton(
    BuildContext context,
    GameTheme theme,
    double screenHeight,
    double screenWidth,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use constraints to determine button size - make it much bigger
        final maxSize = constraints.maxHeight > 0
            ? constraints.maxHeight * 0.95
            : 200.0;
        final buttonSize = screenHeight < 650
            ? (maxSize > 160 ? 160.0 : maxSize)
            : screenHeight < 750
            ? (maxSize > 200 ? 200.0 : maxSize)
            : (maxSize > 240 ? 240.0 : maxSize);

        final isSmallButton = buttonSize < 120;

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
                stops: const [0.0, 0.6, 1.0],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.4),
                  blurRadius: isSmallButton ? 20 : 30,
                  spreadRadius: isSmallButton ? 3 : 5,
                  offset: const Offset(0, 6),
                ),
                BoxShadow(
                  color: theme.foodColor.withValues(alpha: 0.3),
                  blurRadius: isSmallButton ? 30 : 50,
                  spreadRadius: 0,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Animated pulse ring
                Container(
                  width: buttonSize - (isSmallButton ? 8 : 10),
                  height: buttonSize - (isSmallButton ? 8 : 10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.4),
                      width: isSmallButton ? 2 : 3,
                    ),
                  ),
                ),
                // Inner content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.play_arrow_rounded,
                      size: isSmallButton
                          ? 60
                          : buttonSize < 180
                          ? 80
                          : buttonSize < 220
                          ? 100
                          : 120,
                      color: Colors.white,
                      shadows: [
                        Shadow(
                          offset: const Offset(0, 3),
                          blurRadius: 12,
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallButton ? 5 : 7),
                    Text(
                      'PLAY',
                      style: TextStyle(
                        fontSize: isSmallButton
                            ? 14
                            : buttonSize < 180
                            ? 18
                            : buttonSize < 220
                            ? 22
                            : 26,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 2,
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                            color: Colors.black.withValues(alpha: 0.4),
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
      },
    );
  }

  Widget _buildCompactStatsRow({
    required BuildContext context,
    required int highScore,
    required GameTheme theme,
    required double screenWidth,
    required bool isSmallScreen,
    required bool hasSync,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Row(
          children: [
            // Best Score - compact version
            Expanded(
              flex: 2,
              child: GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const StatisticsScreen(),
                  ),
                ),
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: 80,
                    maxHeight: constraints.maxHeight,
                  ),
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.amber.withValues(alpha: 0.15),
                        Colors.orange.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(
                      isSmallScreen ? 16 : 20,
                    ),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: Colors.amber,
                            size: isSmallScreen ? 16 : 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'BEST',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 10 : 11,
                                fontWeight: FontWeight.w700,
                                color: theme.accentColor.withValues(alpha: 0.8),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          if (hasSync)
                            Icon(
                              Icons.cloud_done,
                              color: Colors.green,
                              size: isSmallScreen ? 12 : 14,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '$highScore',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 20 : 24,
                            fontWeight: FontWeight.w900,
                            color: Colors.amber,
                            height: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SizedBox(width: isSmallScreen ? 8 : 12),

            // Quick stats
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _buildQuickStatCard(
                      icon: Icons.analytics,
                      label: 'STATS',
                      theme: theme,
                      isSmallScreen: isSmallScreen,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const StatisticsScreen(),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Expanded(
                    child: _buildQuickStatCard(
                      icon: Icons.leaderboard,
                      label: 'RANKS',
                      theme: theme,
                      isSmallScreen: isSmallScreen,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const LeaderboardScreen(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickStatCard({
    required IconData icon,
    required String label,
    required GameTheme theme,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: isSmallScreen ? 32 : 36),
        padding: EdgeInsets.symmetric(
          horizontal: isSmallScreen ? 8 : 12,
          vertical: isSmallScreen ? 6 : 8,
        ),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: theme.accentColor, size: isSmallScreen ? 14 : 16),
            const SizedBox(width: 4),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 9 : 10,
                    fontWeight: FontWeight.w700,
                    color: theme.accentColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtonsRow({
    required BuildContext context,
    required GameTheme theme,
    required double screenWidth,
    required bool isSmallScreen,
  }) {
    return Row(
      children: [
        Expanded(
          child: _buildModernActionButton(
            context: context,
            theme: theme,
            icon: Icons.diamond,
            label: 'PREMIUM',
            gradient: [Colors.purple.shade400, Colors.indigo.shade400],
            isSmallScreen: isSmallScreen,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const PremiumBenefitsScreen(),
              ),
            ),
          ),
        ),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: _buildModernActionButton(
            context: context,
            theme: theme,
            icon: Icons.store,
            label: 'STORE',
            gradient: [Colors.orange.shade400, Colors.amber.shade400],
            isSmallScreen: isSmallScreen,
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const StoreScreen()),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButton({
    required BuildContext context,
    required GameTheme theme,
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final buttonHeight = constraints.maxHeight > 0
            ? (constraints.maxHeight * 0.85).clamp(48.0, 72.0)
            : (isSmallScreen ? 48.0 : 60.0);

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: buttonHeight,
            constraints: BoxConstraints(
              minWidth: 120,
              maxWidth: constraints.maxWidth,
            ),
            padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gradient[0].withValues(alpha: 0.2),
                  gradient[1].withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 20),
              border: Border.all(
                color: gradient[0].withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: gradient[0].withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    (buttonHeight < 56 ? 6 : 8).toDouble(),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: gradient),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: gradient[0].withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: (buttonHeight < 56 ? 16 : 20).toDouble(),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      style: TextStyle(
                        fontSize: (buttonHeight < 56 ? 12 : 14).toDouble(),
                        fontWeight: FontWeight.w800,
                        color: gradient[0],
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildGameHint(GameTheme theme, bool isSmallScreen) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmallScreen ? 16 : 20,
        vertical: isSmallScreen ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 22),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.swipe,
            color: theme.accentColor.withValues(alpha: 0.7),
            size: isSmallScreen ? 16 : 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Swipe to move • Tap to pause',
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
              color: theme.accentColor.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
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
      _NavItem(Icons.timeline, 'BATTLE', Colors.deepPurple, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const BattlePassScreen()),
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
      _NavItem(Icons.palette, 'COSMETICS', Colors.indigo, () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => const CosmeticsScreen()));
      }),
      _NavItem(Icons.military_tech, 'AWARDS', Colors.orange, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AchievementsScreen()),
        );
      }),
      _NavItem(Icons.palette, 'THEME', theme.snakeColor, () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ThemeSelectorScreen()),
        );
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
                  screenHeight: screenHeight,
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
                      screenHeight: screenHeight,
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
    required double screenHeight,
  }) {
    final buttonSize = _getResponsiveNavButtonSize(screenHeight);
    final iconSize = screenHeight < 600
        ? 18.0
        : screenHeight < 700
        ? 20.0
        : 24.0;

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
            child: Icon(icon, color: color, size: iconSize),
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

  double _getResponsiveNavButtonSize(double screenHeight) {
    if (screenHeight < 600) return 38.0;
    if (screenHeight < 700) return 44.0;
    if (screenHeight < 850) return 50.0;
    return 56.0;
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
