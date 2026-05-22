import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/providers/leaderboard_provider.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
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
    _tabController.addListener(_onTabChanged);
    // Calculate user rank once data is loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _calculateUserRank();
    });
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    final type = _tabController.index == 0 ? 'global' : 'weekly';
    getIt<AnalyticsFacade>().trackLeaderboardViewed(type);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
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

              // Subtitle explaining what the active tab ranks by — without
              // this, "Global vs Weekly" doesn't tell players whether the
              // metric is score / coins / XP / something else.
              AnimatedBuilder(
                animation: _tabController,
                builder: (context, _) => _buildSubtitle(theme),
              ),

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

  /// Themed loading state matching the other data screens — a centered
  /// spinner over a 'Loading…' label so users perceive the network fetch
  /// as work-in-progress rather than an empty/broken screen.
  Widget _buildLoadingState(GameTheme theme, String label) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.accentColor),
          ),
          const SizedBox(height: 16),
          Text(
            label,
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
        ],
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

  /// Tells the player exactly what metric the active tab is ranking on,
  /// so "Global vs Weekly" isn't ambiguous between high score / coins / XP.
  /// Mirrors what the backend handlers do: GetGlobalLeaderboardQueryHandler
  /// orders by aggregated max(Score.ScoreValue) lifetime; the weekly one
  /// scopes scores to `CreatedAt >= startOfWeek` (Sunday).
  Widget _buildSubtitle(GameTheme theme) {
    final isWeekly = _tabController.index == 1;
    final icon = isWeekly ? Icons.calendar_today : Icons.public;
    final text = isWeekly
        ? 'Ranked by your best single-game score this week (resets Sunday)'
        : 'Ranked by your highest single-game score ever';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Row(
        children: [
          Icon(icon, color: theme.accentColor.withValues(alpha: 0.75), size: 14),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
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
            onBackgroundImageError: authState.photoURL != null
                ? (e, s) {}
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
                  authState.publicLabel,
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
      return _buildLoadingState(theme, 'Loading global leaderboard...');
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
      return _buildLoadingState(theme, 'Loading weekly leaderboard...');
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
        // Beefier visual treatment for the signed-in player: gradient fill,
        // double-width glowing border, and a soft drop-shadow so the row
        // pops off the screen at a glance.
        gradient: isCurrentUser
            ? LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  theme.accentColor.withValues(alpha: 0.32),
                  theme.accentColor.withValues(alpha: 0.16),
                  theme.primaryColor.withValues(alpha: 0.18),
                ],
              )
            : null,
        color: isCurrentUser
            ? null
            : theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: theme.accentColor, width: 1.5)
            : Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
        boxShadow: isCurrentUser
            ? [
                BoxShadow(
                  color: theme.accentColor.withValues(alpha: 0.35),
                  blurRadius: 14,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
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
            onBackgroundImageError: player['photoURL'] != null
                ? (e, s) {}
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
                      // Prefer the stable username (now backfilled for
                      // every user post-Phase-1) over the display name,
                      // which can be null/missing for anonymous users
                      // and changes when the user updates their Google
                      // profile.
                      player['username'] ??
                          player['displayName'] ??
                          'Anonymous',
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
                          horizontal: 9,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.accentColor,
                              theme.accentColor.withValues(alpha: 0.75),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: theme.accentColor.withValues(alpha: 0.55),
                              blurRadius: 6,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person_pin,
                              color: theme.backgroundColor,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'YOU',
                              style: TextStyle(
                                color: theme.backgroundColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
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
