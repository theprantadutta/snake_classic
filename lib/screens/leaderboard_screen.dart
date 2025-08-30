import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/user_provider.dart';
import 'package:snake_classic/services/leaderboard_service.dart';
import 'package:snake_classic/utils/constants.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadUserRank();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserRank() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.isSignedIn) {
      final rank = await _leaderboardService.getUserRank(userProvider.user!.uid);
      if (mounted) {
        setState(() {
          _userRank = rank;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final theme = themeProvider.currentTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Leaderboards',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.primaryColor,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.accentColor,
          labelColor: theme.accentColor,
          unselectedLabelColor: theme.accentColor.withValues(alpha:0.6),
          tabs: const [
            Tab(text: 'Global'),
            Tab(text: 'Weekly'),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              theme.backgroundColor,
              theme.backgroundColor.withValues(alpha:0.8),
            ],
          ),
        ),
        child: Column(
          children: [
            // User Rank Card
            if (userProvider.isSignedIn && _userRank != null)
              _buildUserRankCard(userProvider, theme),
            
            // Leaderboard Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildGlobalLeaderboard(theme, userProvider),
                  _buildWeeklyLeaderboard(theme, userProvider),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserRankCard(UserProvider userProvider, GameTheme theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha:0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withValues(alpha:0.3),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundImage: userProvider.photoURL != null
                ? NetworkImage(userProvider.photoURL!)
                : null,
            backgroundColor: theme.primaryColor,
            child: userProvider.photoURL == null
                ? Icon(
                    Icons.person,
                    color: theme.backgroundColor,
                  )
                : null,
          ),
          const SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProvider.displayName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Score: ${userProvider.highScore}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha:0.8),
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
                  Icon(
                    Icons.leaderboard,
                    color: theme.accentColor,
                    size: 20,
                  ),
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
                  color: Colors.white.withValues(alpha:0.6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalLeaderboard(GameTheme theme, UserProvider userProvider) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _leaderboardService.getGlobalLeaderboardStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.primaryColor.withValues(alpha:0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load leaderboard',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final leaderboard = snapshot.data ?? [];
        
        if (leaderboard.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events_outlined,
                  size: 64,
                  color: theme.primaryColor.withValues(alpha:0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No scores yet',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Be the first to set a high score!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final player = leaderboard[index];
            final isCurrentUser = userProvider.isSignedIn && 
                                 player['uid'] == userProvider.user!.uid;
            
            return _buildLeaderboardItem(
              index + 1,
              player,
              theme,
              isCurrentUser,
            );
          },
        );
      },
    );
  }

  Widget _buildWeeklyLeaderboard(GameTheme theme, UserProvider userProvider) {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _leaderboardService.getWeeklyLeaderboardStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: theme.primaryColor.withValues(alpha:0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'Failed to load weekly leaderboard',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          );
        }

        final leaderboard = snapshot.data ?? [];
        
        if (leaderboard.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 64,
                  color: theme.primaryColor.withValues(alpha:0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No weekly scores yet',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Play this week to appear here!',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha:0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: leaderboard.length,
          itemBuilder: (context, index) {
            final player = leaderboard[index];
            final isCurrentUser = userProvider.isSignedIn && 
                                 player['uid'] == userProvider.user!.uid;
            
            return _buildLeaderboardItem(
              index + 1,
              player,
              theme,
              isCurrentUser,
            );
          },
        );
      },
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
          ? theme.accentColor.withValues(alpha:0.2)
          : theme.primaryColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser 
          ? Border.all(color: theme.accentColor.withValues(alpha:0.5))
          : Border.all(color: theme.primaryColor.withValues(alpha:0.2)),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: Row(
              children: [
                if (rankIcon != null) ...[
                  Icon(
                    rankIcon,
                    color: rankColor,
                    size: 20,
                  ),
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
          
          const SizedBox(width: 12),
          
          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundImage: player['photoURL'] != null
                ? NetworkImage(player['photoURL']!)
                : null,
            backgroundColor: theme.primaryColor,
            child: player['photoURL'] == null
                ? Icon(
                    Icons.person,
                    color: theme.backgroundColor,
                    size: 20,
                  )
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
                    ),
                    if (player['isAnonymous'] == true) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha:0.2),
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: theme.accentColor.withValues(alpha:0.2),
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
                    color: Colors.white.withValues(alpha:0.6),
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