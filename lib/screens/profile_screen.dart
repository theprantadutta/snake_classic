import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AppDataCache _appCache;

  @override
  void initState() {
    super.initState();
    _appCache = getIt<AppDataCache>();
    // Trigger background refresh for fresh data (non-blocking)
    _appCache.refreshInBackground();
  }

  // Convenience getters using cached data
  Map<String, dynamic> get _displayStats => _appCache.statistics ?? {};
  List<Achievement> get _recentAchievements => _appCache.recentAchievements ?? [];
  // Data is already loaded - no loading state needed
  bool get _isLoading => !_appCache.isFullyLoaded;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    final themeState = context.watch<ThemeCubit>().state;
    final theme = themeState.currentTheme;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
            color: theme.primaryColor,
            shadows: [
              Shadow(
                offset: const Offset(0, 2),
                blurRadius: 4,
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back_rounded, color: theme.primaryColor),
            onPressed: () => context.pop(),
          ),
        ),
      ),
      body: AnimatedAppBackground(
        theme: theme,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: authState.isSignedIn
                ? _buildProfileContent(context, authState, themeState)
                : _buildSignInContent(context, authState, themeState),
          ),
        ),
      ),
    );
  }

  Widget _buildSignInContent(
    BuildContext context,
    AuthState authState,
    ThemeState themeState,
  ) {
    final theme = themeState.currentTheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Enhanced profile icon with glow
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                theme.accentColor.withValues(alpha: 0.3),
                theme.accentColor.withValues(alpha: 0.1),
                Colors.transparent,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: theme.accentColor.withValues(alpha: 0.3),
                blurRadius: 30,
                spreadRadius: 10,
              ),
            ],
          ),
          child: Icon(
            Icons.person_outline_rounded,
            size: 80,
            color: theme.primaryColor,
          ),
        ),
        const SizedBox(height: 40),

        // Enhanced welcome text
        Container(
          padding: const EdgeInsets.all(24),
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: theme.backgroundColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.accentColor.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              Text(
                'Join Snake Classic',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                  shadows: [
                    Shadow(
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                      color: Colors.black.withValues(alpha: 0.3),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                'Track high scores • Unlock achievements\nCompete globally • Save your progress',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withValues(alpha: 0.9),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),

        // Enhanced buttons with loading state
        if (authState.isLoading)
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircularProgressIndicator(
                  color: theme.accentColor,
                  strokeWidth: 3,
                ),
                const SizedBox(height: 16),
                Text(
                  'Signing in...',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          )
        else ...[
          _buildEnhancedButton(
            context,
            'Sign in with Google',
            Icons.login_rounded,
            theme.accentColor,
            theme.primaryColor,
            () async {
              final authCubit = context.read<AuthCubit>();
              final success = await authCubit.signInWithGoogle();
              if (success && context.mounted) {
                _showStyledSnackBar(
                  context,
                  'Welcome to Snake Classic! 🎉',
                  Colors.green,
                  theme,
                );
              } else if (context.mounted) {
                _showStyledSnackBar(
                  context,
                  'Sign in failed. Please try again.',
                  Colors.red,
                  theme,
                );
              }
            },
          ),
          const SizedBox(height: 16),

          _buildEnhancedButton(
            context,
            'Continue as Guest',
            Icons.person_rounded,
            theme.primaryColor,
            theme.accentColor,
            () async {
              final authCubit = context.read<AuthCubit>();
              await authCubit.signInAnonymously();
              if (context.mounted) {
                _showStyledSnackBar(
                  context,
                  'Playing as guest 👤',
                  Colors.blue,
                  theme,
                );
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    AuthState authState,
    ThemeState themeState,
  ) {
    final theme = themeState.currentTheme;

    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Enhanced Profile Header
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.accentColor.withValues(alpha: 0.15),
                  theme.backgroundColor.withValues(alpha: 0.8),
                  theme.backgroundColor.withValues(alpha: 0.9),
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.2),
                  blurRadius: 30,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Column(
              children: [
                // Enhanced avatar with glow effect
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: theme.accentColor.withValues(alpha: 0.4),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: theme.primaryColor,
                    child: CircleAvatar(
                      radius: 56,
                      backgroundImage: authState.photoURL != null
                          ? NetworkImage(authState.photoURL!)
                          : null,
                      backgroundColor: theme.backgroundColor,
                      child: authState.photoURL == null
                          ? Icon(
                              Icons.person_rounded,
                              size: 60,
                              color: theme.primaryColor,
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Enhanced name with gradient text effect
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [theme.primaryColor, theme.accentColor],
                  ).createShader(bounds),
                  child: Text(
                    authState.displayName,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                // Account status badge
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: authState.isAnonymous
                          ? [Colors.orange, Colors.deepOrange]
                          : [Colors.green, Colors.teal],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color:
                            (authState.isAnonymous
                                    ? Colors.orange
                                    : Colors.green)
                                .withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        authState.isAnonymous
                            ? Icons.person
                            : Icons.verified_user,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        authState.isAnonymous
                            ? 'Guest Player'
                            : 'Verified Account',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Quick Actions Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    'Statistics',
                    Icons.analytics_rounded,
                    theme.accentColor,
                    () => _navigateToStatistics(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    'Friends',
                    Icons.people_rounded,
                    Colors.blue,
                    () => _navigateToFriends(context),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    'Achievements',
                    Icons.emoji_events_rounded,
                    Colors.amber,
                    () => _navigateToAchievements(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Enhanced Stats Section
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.backgroundColor.withValues(alpha: 0.8),
                  theme.backgroundColor.withValues(alpha: 0.6),
                  theme.accentColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.bar_chart_rounded,
                            color: theme.accentColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Statistics',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    if (!_isLoading)
                      GestureDetector(
                        onTap: () => _navigateToStatistics(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [theme.accentColor, theme.primaryColor],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: theme.accentColor.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),

                if (_isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'High Score',
                          _displayStats['highScore']?.toString() ?? '0',
                          Icons.emoji_events,
                          themeState,
                          isCompact: true,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Games Played',
                          _displayStats['totalGames']?.toString() ?? '0',
                          Icons.games,
                          themeState,
                          isCompact: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Play Time',
                          '${_displayStats['totalPlayTime']}h',
                          Icons.access_time,
                          themeState,
                          isCompact: true,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Average Score',
                          _displayStats['averageScore']?.toString() ?? '0',
                          Icons.trending_up,
                          themeState,
                          isCompact: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Food Consumed',
                          _displayStats['totalFood']?.toString() ?? '0',
                          Icons.fastfood,
                          themeState,
                          isCompact: true,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Power-ups',
                          _displayStats['totalPowerUps']?.toString() ?? '0',
                          Icons.flash_on,
                          themeState,
                          isCompact: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recent Achievements Section
          if (_recentAchievements.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.backgroundColor.withValues(alpha: 0.8),
                    theme.backgroundColor.withValues(alpha: 0.6),
                    Colors.amber.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.amber.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.emoji_events_rounded,
                              color: Colors.amber,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Achievements',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => _navigateToAchievements(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.amber, Colors.orange],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.amber.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Achievement cards
                  ...(_recentAchievements
                      .map(
                        (achievement) =>
                            _buildAchievementCard(achievement, theme),
                      )
                      .toList()),
                ],
              ),
            ),

          if (_recentAchievements.isNotEmpty) const SizedBox(height: 24),

          // Google Sign-In Upgrade Section (for guest users only)
          if (authState.isAnonymous && !authState.isGoogleUser)
            Container(
              padding: const EdgeInsets.all(24),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.blue.withValues(alpha: 0.15),
                    Colors.blue.withValues(alpha: 0.1),
                    theme.backgroundColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.blue.withValues(alpha: 0.4),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          FontAwesomeIcons.google,
                          color: Colors.blue,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Upgrade to Google Account',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Save your progress and sync across devices',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Benefits list
                  Row(
                    children: [
                      Expanded(
                        child: _buildUpgradeBenefit(
                          Icons.cloud_sync,
                          'Sync Progress',
                          'across devices',
                        ),
                      ),
                      Expanded(
                        child: _buildUpgradeBenefit(
                          Icons.leaderboard,
                          'Global Leaderboards',
                          'compete worldwide',
                        ),
                      ),
                      Expanded(
                        child: _buildUpgradeBenefit(
                          Icons.people,
                          'Friends & Social',
                          'connect with others',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Upgrade button
                  _buildEnhancedButton(
                    context,
                    'Sign in with Google',
                    FontAwesomeIcons.google,
                    Colors.blue,
                    Colors.blue.shade700,
                    () => _handleGoogleUpgrade(context, theme),
                  ),
                ],
              ),
            ),

          if (authState.isAnonymous && !authState.isGoogleUser)
            const SizedBox(height: 24),

          // Recent Replays Section
          Container(
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  theme.backgroundColor.withValues(alpha: 0.8),
                  theme.backgroundColor.withValues(alpha: 0.6),
                  Colors.purple.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.purple.withValues(alpha: 0.3),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.purple.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.movie_rounded,
                            color: Colors.purple,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Replays',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () => _navigateToReplays(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Colors.purple, Colors.deepPurple],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Builder(
                  builder: (context) {
                    final replayKeys = _appCache.replayKeys ?? [];
                    if (replayKeys.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No replays yet. Play some games!',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      );
                    }

                    return Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.purple.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.video_library_rounded,
                            color: Colors.purple.withValues(alpha: 0.8),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${replayKeys.length} replays saved',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Enhanced Sign Out Section
          if (!authState.isLoading)
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.red.withValues(alpha: 0.1),
                    Colors.red.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  const Text(
                    'Account Management',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildEnhancedButton(
                    context,
                    'Sign Out',
                    Icons.logout_rounded,
                    Colors.red,
                    Colors.red.shade700,
                    () => _showSignOutDialog(context, theme),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    ThemeState themeState, {
    bool isCompact = false,
  }) {
    if (isCompact) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          children: [
            Icon(icon, color: themeState.currentTheme.primaryColor, size: 20),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: themeState.currentTheme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedButton(
    BuildContext context,
    String text,
    IconData icon,
    Color primaryColor,
    Color secondaryColor,
    VoidCallback onPressed,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.8), color.withValues(alpha: 0.6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onPressed,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 28),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getRarityColor(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return Colors.grey;
      case AchievementRarity.rare:
        return Colors.blue;
      case AchievementRarity.epic:
        return Colors.purple;
      case AchievementRarity.legendary:
        return Colors.amber;
    }
  }

  String _getRarityDisplayName(AchievementRarity rarity) {
    switch (rarity) {
      case AchievementRarity.common:
        return 'Common';
      case AchievementRarity.rare:
        return 'Rare';
      case AchievementRarity.epic:
        return 'Epic';
      case AchievementRarity.legendary:
        return 'Legendary';
    }
  }

  Widget _buildAchievementCard(Achievement achievement, GameTheme theme) {
    final rarityColor = _getRarityColor(achievement.rarity);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            rarityColor.withValues(alpha: 0.2),
            rarityColor.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: rarityColor.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(achievement.icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: rarityColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getRarityDisplayName(achievement.rarity),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToStatistics(BuildContext context) {
    context.push(AppRoutes.statistics);
  }

  void _navigateToFriends(BuildContext context) {
    context.push(AppRoutes.friends);
  }

  void _navigateToAchievements(BuildContext context) {
    context.push(AppRoutes.achievements);
  }

  void _navigateToReplays(BuildContext context) {
    context.push(AppRoutes.replays);
  }

  void _showStyledSnackBar(
    BuildContext context,
    String message,
    Color color,
    GameTheme theme,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildUpgradeBenefit(IconData icon, String title, String subtitle) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue, size: 24),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withValues(alpha: 0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _handleGoogleUpgrade(
    BuildContext context,
    GameTheme theme,
  ) async {
    try {
      final authCubit = context.read<AuthCubit>();
      final success = await authCubit.signInWithGoogle();

      if (success && context.mounted) {
        _showStyledSnackBar(
          context,
          'Successfully upgraded to Google account! 🎉',
          Colors.green,
          theme,
        );
      } else if (context.mounted) {
        _showStyledSnackBar(
          context,
          'Failed to upgrade account. Please try again.',
          Colors.red,
          theme,
        );
      }
    } catch (e) {
      if (context.mounted) {
        _showStyledSnackBar(
          context,
          'An error occurred during account upgrade.',
          Colors.red,
          theme,
        );
      }
    }
  }

  void _showSignOutDialog(BuildContext context, GameTheme theme) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
        ),
        title: Text(
          'Sign Out',
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Are you sure you want to sign out?\n\nYour progress will be saved if you\'re signed in with Google.',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () async {
              Navigator.of(dialogContext).pop();
              final authCubit = context.read<AuthCubit>();
              await authCubit.signOut();
              if (context.mounted) {
                _showStyledSnackBar(
                  context,
                  'Signed out successfully 👋',
                  Colors.blue,
                  theme,
                );
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
