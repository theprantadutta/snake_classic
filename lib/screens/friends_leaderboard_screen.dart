import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/models/user_profile.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/services/social_service.dart';
import 'package:snake_classic/utils/constants.dart';

class FriendsLeaderboardScreen extends StatefulWidget {
  const FriendsLeaderboardScreen({super.key});

  @override
  State<FriendsLeaderboardScreen> createState() =>
      _FriendsLeaderboardScreenState();
}

class _FriendsLeaderboardScreenState extends State<FriendsLeaderboardScreen>
    with SingleTickerProviderStateMixin {
  final SocialService _socialService = SocialService();
  final AppDataCache _appCache = AppDataCache();
  List<UserProfile> _leaderboard = [];
  bool _isLoading = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _initializeLeaderboard();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _initializeLeaderboard() {
    // Check cache first - use preloaded friends list sorted by high score
    if (_appCache.isFullyLoaded && _appCache.friendsList != null && _appCache.friendsList!.isNotEmpty) {
      // Sort friends by high score for leaderboard display
      final sortedFriends = List<UserProfile>.from(_appCache.friendsList!);
      sortedFriends.sort((a, b) => b.highScore.compareTo(a.highScore));

      setState(() {
        _leaderboard = sortedFriends;
        _isLoading = false;
      });
      _animationController.forward();

      // Refresh in background for latest data
      _refreshInBackground();
    } else {
      // No cache - load normally
      _loadLeaderboard();
    }
  }

  Future<void> _refreshInBackground() async {
    try {
      final leaderboard = await _socialService.getFriendsLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
        });
      }
    } catch (_) {
      // Ignore errors in background refresh
    }
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    try {
      final leaderboard = await _socialService.getFriendsLeaderboard();
      if (mounted) {
        setState(() {
          _leaderboard = leaderboard;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final theme = state.currentTheme;

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
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(theme),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingIndicator(theme)
                        : _buildLeaderboard(theme),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: Icon(
                  Icons.arrow_back,
                  color: theme.accentColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.leaderboard, color: theme.accentColor, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Friends Leaderboard',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: theme.accentColor,
                  ),
                ),
              ),
              IconButton(
                onPressed: _loadLeaderboard,
                icon: Icon(
                  Icons.refresh,
                  color: theme.accentColor.withValues(alpha: 0.7),
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.people,
                  size: 16,
                  color: theme.accentColor.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  'Compete with your friends',
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator(GameTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading leaderboard...',
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboard(GameTheme theme) {
    if (_leaderboard.isEmpty) {
      return _buildEmptyState(theme);
    }

    return Column(
      children: [
        // Top 3 podium
        if (_leaderboard.length >= 2) _buildPodium(theme),

        // Rest of the leaderboard
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: _leaderboard.length > 3 ? _leaderboard.length - 3 : 0,
            itemBuilder: (context, index) {
              final actualIndex = index + 3; // Skip top 3
              final user = _leaderboard[actualIndex];
              final rank = actualIndex + 1;

              return _buildLeaderboardCard(
                user: user,
                rank: rank,
                theme: theme,
                delay: (actualIndex * 100).ms,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPodium(GameTheme theme) {
    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd place
          if (_leaderboard.length >= 2)
            Expanded(
              child: _buildPodiumPlace(
                user: _leaderboard[1],
                rank: 2,
                height: 120,
                theme: theme,
                delay: 200.ms,
              ),
            ),

          // 1st place
          Expanded(
            child: _buildPodiumPlace(
              user: _leaderboard[0],
              rank: 1,
              height: 160,
              theme: theme,
              delay: 100.ms,
            ),
          ),

          // 3rd place
          if (_leaderboard.length >= 3)
            Expanded(
              child: _buildPodiumPlace(
                user: _leaderboard[2],
                rank: 3,
                height: 80,
                theme: theme,
                delay: 300.ms,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumPlace({
    required UserProfile user,
    required int rank,
    required double height,
    required GameTheme theme,
    required Duration delay,
  }) {
    final colors = {
      1: [Colors.amber, Colors.yellow],
      2: [Colors.grey.shade400, Colors.grey.shade300],
      3: [Colors.brown.shade400, Colors.brown.shade300],
    };

    final rankColors = colors[rank] ?? [Colors.grey, Colors.grey];

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // User avatar
        CircleAvatar(
          radius: rank == 1 ? 32 : 24,
          backgroundColor: theme.accentColor.withValues(alpha: 0.2),
          backgroundImage: user.photoUrl != null
              ? NetworkImage(user.photoUrl!)
              : null,
          child: user.photoUrl == null
              ? Text(
                  user.displayName.isNotEmpty
                      ? user.displayName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: rank == 1 ? 24 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ).animate().scale(delay: delay),

        const SizedBox(height: 8),

        // Rank crown/medal
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: rankColors[0],
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: rankColors[0].withValues(alpha: 0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            rank == 1 ? Icons.emoji_events : Icons.military_tech,
            color: Colors.white,
            size: rank == 1 ? 20 : 16,
          ),
        ).animate().scale(delay: delay + 100.ms),

        const SizedBox(height: 4),

        // User name
        Text(
          user.displayName,
          style: TextStyle(
            color: theme.accentColor,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ).animate().fadeIn(delay: delay + 200.ms),

        // Score
        Text(
          '${user.highScore}',
          style: TextStyle(
            color: rankColors[0],
            fontSize: rank == 1 ? 16 : 14,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: delay + 300.ms),

        const SizedBox(height: 8),

        // Podium base
        Container(
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: rankColors,
            ),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                color: rankColors[0].withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              '#$rank',
              style: TextStyle(
                color: Colors.white,
                fontSize: rank == 1 ? 24 : 18,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),
        ).animate().slideY(begin: 1, delay: delay),
      ],
    );
  }

  Widget _buildLeaderboardCard({
    required UserProfile user,
    required int rank,
    required GameTheme theme,
    required Duration delay,
  }) {
    return Card(
      color: theme.backgroundColor.withValues(alpha: 0.5),
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Rank number
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.3),
                ),
              ),
              child: Center(
                child: Text(
                  '#$rank',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // User avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: theme.accentColor.withValues(alpha: 0.2),
              backgroundImage: user.photoUrl != null
                  ? NetworkImage(user.photoUrl!)
                  : null,
              child: user.photoUrl == null
                  ? Text(
                      user.displayName.isNotEmpty
                          ? user.displayName[0].toUpperCase()
                          : 'U',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),

            const SizedBox(width: 16),

            // User info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          user.displayName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor,
                          ),
                        ),
                      ),
                      Text(
                        user.status.emoji,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.games,
                        size: 14,
                        color: theme.accentColor.withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${user.totalGamesPlayed} games',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.accentColor.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${user.highScore}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.accentColor,
                      ),
                    ),
                  ],
                ),
                Text(
                  'High Score',
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.accentColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(delay: delay).slideX(begin: 0.2);
  }

  Widget _buildEmptyState(GameTheme theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: theme.accentColor.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Friends Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add friends to see your private leaderboard!',
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => context.push(AppRoutes.friends),
            icon: const Icon(Icons.person_add),
            label: const Text('Add Friends'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.accentColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
