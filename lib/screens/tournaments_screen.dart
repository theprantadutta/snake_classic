import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/tournament_service.dart';
import 'package:snake_classic/screens/tournament_detail_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class TournamentsScreen extends StatefulWidget {
  const TournamentsScreen({super.key});

  @override
  State<TournamentsScreen> createState() => _TournamentsScreenState();
}

class _TournamentsScreenState extends State<TournamentsScreen>
    with SingleTickerProviderStateMixin {
  final TournamentService _tournamentService = TournamentService();
  final ConnectivityService _connectivityService = ConnectivityService();

  late TabController _tabController;
  List<Tournament> _activeTournaments = [];
  List<Tournament> _historyTournaments = [];
  Map<String, dynamic> _userStats = {};
  bool _isLoading = true;
  bool _isOffline = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _isOffline = !_connectivityService.isOnline;
    _connectivityService.addListener(_onConnectivityChanged);
    _loadData();
  }

  @override
  void dispose() {
    _connectivityService.removeListener(_onConnectivityChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onConnectivityChanged() {
    final wasOffline = _isOffline;
    setState(() {
      _isOffline = !_connectivityService.isOnline;
    });
    // Refresh data when coming back online
    if (wasOffline && !_isOffline) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _tournamentService.getActiveTournaments(),
        _tournamentService.getTournamentHistory(),
        _tournamentService.getUserTournamentStats(),
      ]);

      setState(() {
        _activeTournaments = results[0] as List<Tournament>;
        _historyTournaments = results[1] as List<Tournament>;
        _userStats = results[2] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;

        return Scaffold(
          body: AppBackground(
            theme: theme,
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(theme),
                  _buildTabBar(theme),
                  Expanded(
                    child: _isLoading
                        ? _buildLoadingIndicator(theme)
                        : TabBarView(
                            controller: _tabController,
                            children: [
                              _buildActiveTournaments(theme),
                              _buildTournamentHistory(theme),
                              _buildUserStats(theme),
                            ],
                          ),
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
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back, color: theme.accentColor, size: 24),
          ),
          const SizedBox(width: 8),
          Icon(Icons.emoji_events, color: theme.accentColor, size: 28),
          const SizedBox(width: 12),
          Text(
            'Tournaments',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _loadData,
            icon: Icon(
              Icons.refresh,
              color: theme.accentColor.withValues(alpha: 0.7),
              size: 24,
            ),
          ),
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
          Tab(text: 'Active'),
          Tab(text: 'History'),
          Tab(text: 'My Stats'),
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
            'Loading tournaments...',
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveTournaments(GameTheme theme) {
    if (_activeTournaments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.emoji_events,
        title: 'No Active Tournaments',
        subtitle: 'Check back later for new tournaments!',
        theme: theme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _activeTournaments.length,
      itemBuilder: (context, index) {
        final tournament = _activeTournaments[index];
        return _buildTournamentCard(
          tournament: tournament,
          theme: theme,
          onTap: () => _openTournamentDetail(tournament),
        ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2);
      },
    );
  }

  Widget _buildTournamentHistory(GameTheme theme) {
    if (_historyTournaments.isEmpty) {
      return _buildEmptyState(
        icon: Icons.history,
        title: 'No Tournament History',
        subtitle: 'Participate in tournaments to see your history!',
        theme: theme,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _historyTournaments.length,
      itemBuilder: (context, index) {
        final tournament = _historyTournaments[index];
        return _buildTournamentCard(
          tournament: tournament,
          theme: theme,
          showResults: true,
          onTap: () => _openTournamentDetail(tournament),
        ).animate().fadeIn(delay: (100 * index).ms).slideX(begin: 0.2);
      },
    );
  }

  Widget _buildUserStats(GameTheme theme) {
    if (_userStats.isEmpty) {
      return _buildEmptyState(
        icon: Icons.bar_chart,
        title: 'No Tournament Stats',
        subtitle: 'Join tournaments to track your progress!',
        theme: theme,
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatsOverview(theme),
          const SizedBox(height: 24),
          _buildStatsDetails(theme),
        ],
      ),
    );
  }

  Widget _buildTournamentCard({
    required Tournament tournament,
    required GameTheme theme,
    bool showResults = false,
    required VoidCallback onTap,
  }) {
    return Card(
      color: theme.backgroundColor.withValues(alpha: 0.5),
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getTournamentStatusColor(
            tournament.status,
          ).withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getTournamentTypeColor(
                        tournament.type,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      tournament.type.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tournament.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: theme.accentColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tournament.type.displayName,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getTournamentTypeColor(tournament.type),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTournamentStatusColor(
                        tournament.status,
                      ).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tournament.status.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        color: _getTournamentStatusColor(tournament.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Description
              Text(
                tournament.description,
                style: TextStyle(
                  fontSize: 14,
                  color: theme.accentColor.withValues(alpha: 0.8),
                ),
              ),

              const SizedBox(height: 12),

              // Game mode and time info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          tournament.gameMode.emoji,
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          tournament.gameMode.displayName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: theme.accentColor.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    tournament.timeRemainingFormatted,
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.accentColor.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Participation info
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: theme.accentColor.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${tournament.currentParticipants}/${tournament.maxParticipants} players',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.accentColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const Spacer(),
                  if (tournament.hasJoined) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Joined',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (tournament.userBestScore != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Best: ${tournament.userBestScore}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ],
              ),

              // Show rewards for active tournaments or results for history
              if (showResults && tournament.userReward != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.amber.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rank #${tournament.userRank} - ${tournament.userReward!.name}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            if (tournament.userReward!.coins > 0)
                              Text(
                                '+${tournament.userReward!.coins} coins',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.amber.withValues(alpha: 0.8),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (!showResults && tournament.rewards.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.card_giftcard,
                        color: theme.accentColor,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          '${tournament.rewards.length} reward${tournament.rewards.length > 1 ? 's' : ''} available',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.accentColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Text(
                        'View Details →',
                        style: TextStyle(
                          fontSize: 10,
                          color: theme.accentColor.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsOverview(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tournament Overview',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Tournaments',
                  '${_userStats['totalTournaments'] ?? 0}',
                  Icons.emoji_events,
                  Colors.blue,
                  theme,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Wins',
                  '${_userStats['wins'] ?? 0}',
                  Icons.emoji_events,
                  Colors.amber,
                  theme,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Top 3 Finishes',
                  '${_userStats['topThreeFinishes'] ?? 0}',
                  Icons.military_tech,
                  Colors.orange,
                  theme,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Best Score',
                  '${_userStats['bestScore'] ?? 0}',
                  Icons.star,
                  Colors.purple,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsDetails(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'Total Attempts',
            '${_userStats['totalAttempts'] ?? 0}',
            theme,
          ),
          _buildDetailRow('Win Rate', '${_userStats['winRate'] ?? 0}%', theme),
          _buildDetailRow(
            'Average Performance',
            'Top ${100 - (_userStats['winRate'] ?? 0)}%',
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    GameTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, GameTheme theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required GameTheme theme,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: theme.accentColor.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: theme.accentColor.withValues(alpha: 0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getTournamentStatusColor(TournamentStatus status) {
    switch (status) {
      case TournamentStatus.active:
        return Colors.green;
      case TournamentStatus.upcoming:
        return Colors.blue;
      case TournamentStatus.ended:
        return Colors.grey;
      case TournamentStatus.cancelled:
        return Colors.red;
    }
  }

  Color _getTournamentTypeColor(TournamentType type) {
    switch (type) {
      case TournamentType.daily:
        return Colors.blue;
      case TournamentType.weekly:
        return Colors.orange;
      case TournamentType.monthly:
        return Colors.purple;
      case TournamentType.special:
        return Colors.pink;
    }
  }

  void _openTournamentDetail(Tournament tournament) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TournamentDetailScreen(tournament: tournament),
      ),
    );
  }
}
