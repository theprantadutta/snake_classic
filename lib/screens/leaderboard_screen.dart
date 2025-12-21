import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/services/leaderboard_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final LeaderboardService _leaderboardService = LeaderboardService();
  Map<String, dynamic>? _userRank;

  // Leaderboard data
  List<Map<String, dynamic>> _globalLeaderboard = [];
  List<Map<String, dynamic>> _weeklyLeaderboard = [];
  bool _isLoadingGlobal = true;
  bool _isLoadingWeekly = true;
  String? _globalError;
  String? _weeklyError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    // Load both leaderboards in parallel first
    await Future.wait([
      _loadGlobalLeaderboard(),
      _loadWeeklyLeaderboard(),
    ]);
    // Then calculate user rank from already loaded data (no extra API call)
    _calculateUserRank();
  }

  void _calculateUserRank() {
    final authState = context.read<AuthCubit>().state;
    if (!authState.isSignedIn || authState.userId == null) return;
    if (_globalLeaderboard.isEmpty) return;

    final userId = authState.userId!;
    for (int i = 0; i < _globalLeaderboard.length; i++) {
      if (_globalLeaderboard[i]['uid'] == userId) {
        if (mounted) {
          setState(() {
            _userRank = {
              'rank': i + 1,
              'totalPlayers': _globalLeaderboard.length,
              'userScore': _globalLeaderboard[i]['highScore'] ?? 0,
              'percentile': ((_globalLeaderboard.length - i) / _globalLeaderboard.length * 100).round(),
            };
          });
        }
        return;
      }
    }
  }

  Future<void> _loadGlobalLeaderboard() async {
    if (!mounted) return;
    setState(() {
      _isLoadingGlobal = true;
      _globalError = null;
    });

    try {
      final data = await _leaderboardService.getGlobalLeaderboard();
      if (mounted) {
        setState(() {
          _globalLeaderboard = data;
          _isLoadingGlobal = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _globalError = 'Failed to load leaderboard';
          _isLoadingGlobal = false;
        });
      }
    }
  }

  Future<void> _loadWeeklyLeaderboard() async {
    if (!mounted) return;
    setState(() {
      _isLoadingWeekly = true;
      _weeklyError = null;
    });

    try {
      final data = await _leaderboardService.getWeeklyLeaderboard();
      if (mounted) {
        setState(() {
          _weeklyLeaderboard = data;
          _isLoadingWeekly = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _weeklyError = 'Failed to load weekly leaderboard';
          _isLoadingWeekly = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ThemeCubit>().state;
    final authState = context.watch<AuthCubit>().state;
    final theme = themeState.currentTheme;

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
              if (authState.isSignedIn && _userRank != null)
                _buildUserRankCard(authState, theme),

              // Leaderboard Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildGlobalLeaderboard(theme, authState),
                    _buildWeeklyLeaderboard(theme, authState),
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
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              color: theme.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.leaderboard,
            color: theme.accentColor,
            size: 28,
          ),
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

  Widget _buildUserRankCard(AuthState authState, GameTheme theme) {
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
                    '#${_userRank!['rank']}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                    ),
                  ),
                ],
              ),
              Text(
                'Top ${_userRank!['percentile']}%',
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

  Widget _buildGlobalLeaderboard(GameTheme theme, AuthState authState) {
    if (_isLoadingGlobal) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_globalError != null) {
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
              _globalError!,
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

    if (_globalLeaderboard.isEmpty) {
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
        itemCount: _globalLeaderboard.length,
        itemBuilder: (context, index) {
          final player = _globalLeaderboard[index];
          final isCurrentUser =
              authState.isSignedIn &&
              authState.userId != null &&
              player['uid'] == authState.userId;

          return _buildLeaderboardItem(
            index + 1,
            player,
            theme,
            isCurrentUser,
          );
        },
      ),
    );
  }

  Widget _buildWeeklyLeaderboard(GameTheme theme, AuthState authState) {
    if (_isLoadingWeekly) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_weeklyError != null) {
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
              _weeklyError!,
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

    if (_weeklyLeaderboard.isEmpty) {
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
        itemCount: _weeklyLeaderboard.length,
        itemBuilder: (context, index) {
          final player = _weeklyLeaderboard[index];
          final isCurrentUser =
              authState.isSignedIn &&
              authState.userId != null &&
              player['uid'] == authState.userId;

          return _buildLeaderboardItem(
            index + 1,
            player,
            theme,
            isCurrentUser,
          );
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
