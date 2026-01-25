import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/providers/leaderboard_provider.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Calculate user rank once data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateUserRank();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateUserRank() {
    final authState = context.read<AuthCubit>().state;
    if (!authState.isSignedIn || authState.userId == null) return;
    ref.read(combinedLeaderboardProvider.notifier).calculateUserRankFor(authState.userId);
  }

  Future<void> _loadGlobalLeaderboard() async {
    await ref.read(combinedLeaderboardProvider.notifier).refresh();
    _calculateUserRank();
  }

  Future<void> _loadWeeklyLeaderboard() async {
    await ref.read(combinedLeaderboardProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the leaderboard state from Riverpod
    final leaderboardState = ref.watch(combinedLeaderboardProvider);
    final themeState = context.watch<ThemeCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final theme = themeState.currentTheme;

    // Update user rank when global leaderboard loads
    ref.listen<CombinedLeaderboardState>(combinedLeaderboardProvider, (prev, next) {
      if (prev?.isLoadingGlobal == true && next.isLoadingGlobal == false) {
        _calculateUserRank();
      }
    });

    return Scaffold(
      body: AppBackground(
        theme: theme,
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(theme),

              // Tab Bar
              _buildTabBar(theme),

              // User Rank Card
              if (authState.isSignedIn && leaderboardState.userRank != null)
                _buildUserRankCard(authState, theme, leaderboardState.userRank!),

              // Leaderboard Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGlobalLeaderboard(theme, authState, leaderboardState),
                    _buildWeeklyLeaderboard(theme, authState, leaderboardState),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: theme.accentColor, size: 24),
          ),
          const SizedBox(width: 8),
          Icon(Icons.leaderboard, color: theme.accentColor, size: 28),
          const SizedBox(width: 12),
          Text(
            'Leaderboards',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildTabBar(GameTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        indicatorColor: theme.accentColor,
        labelColor: theme.accentColor,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
        tabs: const [
          Tab(text: 'Global'),
          Tab(text: 'Weekly'),
        ],
      ),
    );
  }

  Widget _buildUserRankCard(AuthState authState, GameTheme theme, Map<String, dynamic> userRank) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: authState.photoURL != null
                ? NetworkImage(authState.photoURL!)
                : null,
            backgroundColor: theme.primaryColor,
            child: authState.photoURL == null
                ? Icon(Icons.person, color: theme.backgroundColor)
                : null,
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  authState.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Score: ${authState.highScore}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.leaderboard, color: theme.accentColor, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '#${userRank['rank']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                    ),
                  ),
                ],
              ),
              Text(
                'Top ${userRank['percentile']}%',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboard(GameTheme theme, AuthState authState, CombinedLeaderboardState leaderboardState) {
    if (leaderboardState.isLoadingGlobal) {
      return const Center(child: CircularProgressIndicator());
    }

    if (leaderboardState.globalError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              leaderboardState.globalError!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadGlobalLeaderboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (leaderboardState.globalEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events_outlined,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No scores yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to set a high score!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadGlobalLeaderboard,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaderboardState.globalEntries.length,
        itemBuilder: (context, index) {
          final player = leaderboardState.globalEntries[index];
          final isCurrentUser =
              authState.isSignedIn &&
              authState.userId != null &&
              player['uid'] == authState.userId;

          return _buildLeaderboardItem(index + 1, player, theme, isCurrentUser);
        },
      ),
    );
  }

  Widget _buildWeeklyLeaderboard(GameTheme theme, AuthState authState, CombinedLeaderboardState leaderboardState) {
    if (leaderboardState.isLoadingWeekly) {
      return const Center(child: CircularProgressIndicator());
    }

    if (leaderboardState.weeklyError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              leaderboardState.weeklyError!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadWeeklyLeaderboard,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (leaderboardState.weeklyEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No weekly scores yet',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Play this week to appear here!',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadWeeklyLeaderboard,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: leaderboardState.weeklyEntries.length,
        itemBuilder: (context, index) {
          final player = leaderboardState.weeklyEntries[index];
          final isCurrentUser =
              authState.isSignedIn &&
              authState.userId != null &&
              player['uid'] == authState.userId;

          return _buildLeaderboardItem(index + 1, player, theme, isCurrentUser);
        },
      ),
    );
  }

  Widget _buildLeaderboardItem(
    int rank,
    Map<String, dynamic> player,
    GameTheme theme,
    bool isCurrentUser,
  ) {
    Color rankColor = Colors.white;
    IconData? rankIcon;

    if (rank == 1) {
      rankColor = Colors.amber;
      rankIcon = Icons.emoji_events;
    } else if (rank == 2) {
      rankColor = Colors.grey[300]!;
      rankIcon = Icons.workspace_premium;
    } else if (rank == 3) {
      rankColor = Colors.brown[300]!;
      rankIcon = Icons.workspace_premium;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser
            ? theme.accentColor.withValues(alpha: 0.2)
            : theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser
            ? Border.all(color: theme.accentColor.withValues(alpha: 0.5))
            : Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Row(
              children: [
                if (rankIcon != null) ...[
                  Icon(rankIcon, color: rankColor, size: 20),
                ] else ...[
                  Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: player['photoURL'] != null
                ? NetworkImage(player['photoURL']!)
                : null,
            backgroundColor: theme.primaryColor,
            child: player['photoURL'] == null
                ? Icon(Icons.person, color: theme.backgroundColor, size: 20)
                : null,
          ),

          const SizedBox(width: 12),

          // Name and details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player['displayName'] ?? 'Anonymous',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCurrentUser ? theme.accentColor : Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (player['isAnonymous'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'GUEST',
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'YOU',
                          style: TextStyle(
                            color: theme.accentColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${player['totalGamesPlayed']} games played',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),

          // Score
          Text(
            '${player['highScore']}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isCurrentUser ? theme.accentColor : Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
