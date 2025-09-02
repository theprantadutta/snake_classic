import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();
  Map<String, dynamic> _displayStats = {};
  Map<String, dynamic> _performanceTrends = {};
  Map<String, dynamic> _playPatterns = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);

    try {
      await _statisticsService.initialize();
      _displayStats = _statisticsService.getDisplayStatistics();
      _performanceTrends = _statisticsService.getPerformanceTrends();
      _playPatterns = _statisticsService.getPlayPatterns();
    } catch (e) {
      // Handle error
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        final theme = themeProvider.currentTheme;

        return Scaffold(
          body: AppBackground(
            theme: theme,
            child: SafeArea(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              theme.accentColor,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loading Statistics...',
                            style: TextStyle(
                              color: theme.accentColor.withValues(alpha: 0.8),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Header
                        _buildHeader(theme),

                        // Statistics Content
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                // Performance Overview
                                _buildPerformanceOverview(theme),

                                const SizedBox(height: 24),

                                // Game Activity
                                _buildGameActivity(theme),

                                const SizedBox(height: 24),

                                // Food & Power-ups
                                _buildConsumptionStats(theme),

                                const SizedBox(height: 24),

                                // Performance Trends
                                _buildPerformanceTrends(theme),

                                const SizedBox(height: 24),

                                // Play Patterns
                                _buildPlayPatterns(theme),

                                const SizedBox(height: 24),

                                // Achievement Progress
                                _buildAchievementProgress(theme),

                                const SizedBox(height: 32),

                                // Action Buttons
                                _buildActionButtons(theme),

                                const SizedBox(height: 24),
                              ],
                            ),
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

          Icon(Icons.analytics, color: theme.accentColor, size: 28),

          const SizedBox(width: 12),

          Text(
            'Statistics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),

          const Spacer(),

          IconButton(
            onPressed: _refreshStatistics,
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

  Widget _buildPerformanceOverview(GameTheme theme) {
    return _buildStatSection(
      title: 'Performance Overview',
      icon: Icons.trending_up,
      theme: theme,
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'High Score',
                    '${_displayStats['highScore'] ?? 0}',
                    Icons.emoji_events,
                    Colors.amber,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Total Games',
                    '${_displayStats['totalGames'] ?? 0}',
                    Icons.games,
                    theme.accentColor,
                    theme,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'Average Score',
                    '${_displayStats['averageScore'] ?? 0}',
                    Icons.trending_up,
                    Colors.green,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'Win Streak',
                    '${_displayStats['winStreak'] ?? 0}',
                    Icons.local_fire_department,
                    Colors.orange,
                    theme,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameActivity(GameTheme theme) {
    return _buildStatSection(
      title: 'Game Activity',
      icon: Icons.schedule,
      theme: theme,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Play Time',
                  '${_displayStats['totalPlayTime'] ?? 0}h',
                  Icons.access_time,
                  Colors.blue,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Longest Game',
                  '${_displayStats['longestSurvival'] ?? '0s'}',
                  Icons.timer,
                  Colors.purple,
                  theme,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Highest Level',
                  '${_displayStats['highestLevel'] ?? 1}',
                  Icons.military_tech,
                  Colors.indigo,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Perfect Games',
                  '${_displayStats['perfectGames'] ?? 0}',
                  Icons.star,
                  Colors.pink,
                  theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsumptionStats(GameTheme theme) {
    final foodBreakdown =
        _displayStats['foodBreakdown'] as Map<String, int>? ?? {};
    final powerUpBreakdown =
        _displayStats['powerUpBreakdown'] as Map<String, int>? ?? {};

    return _buildStatSection(
      title: 'Food & Power-ups',
      icon: Icons.restaurant,
      theme: theme,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Food Consumed',
                  '${_displayStats['totalFood'] ?? 0}',
                  Icons.apple,
                  Colors.red,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Power-ups Used',
                  '${_displayStats['totalPowerUps'] ?? 0}',
                  Icons.flash_on,
                  Colors.yellow,
                  theme,
                ),
              ),
            ],
          ),

          if (foodBreakdown.isNotEmpty || powerUpBreakdown.isNotEmpty) ...[
            const SizedBox(height: 16),

            Row(
              children: [
                if (foodBreakdown.isNotEmpty)
                  Expanded(
                    child: _buildBreakdownCard(
                      'Favorite Food',
                      '${_displayStats['favoriteFood'] ?? 'None'}',
                      foodBreakdown,
                      theme,
                    ),
                  ),

                if (foodBreakdown.isNotEmpty && powerUpBreakdown.isNotEmpty)
                  const SizedBox(width: 12),

                if (powerUpBreakdown.isNotEmpty)
                  Expanded(
                    child: _buildBreakdownCard(
                      'Favorite Power-up',
                      '${_displayStats['favoritePowerUp'] ?? 'None'}',
                      powerUpBreakdown,
                      theme,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPerformanceTrends(GameTheme theme) {
    final recentScores =
        (_performanceTrends['recentScores'] as List<int>?) ?? [];
    final trend = _performanceTrends['trend'] as String? ?? 'stable';

    return _buildStatSection(
      title: 'Performance Trends',
      icon: Icons.show_chart,
      theme: theme,
      child: Column(
        children: [
          // Enhanced Trend Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildTrendCard(
                  'Overall Trend',
                  trend,
                  _getTrendIcon(trend),
                  _getTrendColor(trend),
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Recent Average',
                  '${_performanceTrends['averageRecentScore'] ?? 0}',
                  Icons.analytics,
                  Colors.cyan,
                  theme,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Performance Statistics Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Best Recent',
                  '${_performanceTrends['bestRecentScore'] ?? 0}',
                  Icons.star_outline,
                  Colors.amber,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Consistency',
                  _calculateConsistencyRating(recentScores),
                  Icons.equalizer,
                  Colors.purple,
                  theme,
                ),
              ),
            ],
          ),

          if (recentScores.isNotEmpty) ...[
            const SizedBox(height: 16),

            // Enhanced Chart Container
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Progress (Last ${recentScores.length} Games)',
                        style: TextStyle(
                          color: theme.accentColor.withValues(alpha: 0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getTrendColor(trend).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          trend.toUpperCase(),
                          style: TextStyle(
                            color: _getTrendColor(trend),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Enhanced Chart with Trend Line
                  SizedBox(
                    height: 80,
                    child: _buildEnhancedTrendChart(recentScores, theme, trend),
                  ),

                  const SizedBox(height: 8),

                  // Chart Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem('Scores', theme.accentColor, theme),
                      const SizedBox(width: 16),
                      _buildLegendItem(
                        'Trend Line',
                        _getTrendColor(trend),
                        theme,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Performance Insights
            _buildPerformanceInsights(recentScores, trend, theme),
          ],
        ],
      ),
    );
  }

  Widget _buildPlayPatterns(GameTheme theme) {
    final dailyPlayTime =
        (_playPatterns['dailyPlayTime'] as Map<String, int>?) ?? {};

    return _buildStatSection(
      title: 'Play Patterns (Last 7 Days)',
      icon: Icons.calendar_today,
      theme: theme,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Weekly Time',
                  _formatPlayTime(_playPatterns['totalWeeklyTime'] ?? 0),
                  Icons.schedule,
                  Colors.green,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Most Active Day',
                  '${_playPatterns['mostActiveDay'] ?? 'None'}',
                  Icons.star,
                  Colors.orange,
                  theme,
                ),
              ),
            ],
          ),

          if (dailyPlayTime.isNotEmpty) ...[
            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.2),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daily Activity',
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: 60,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical, // or horizontal if needed
                      child: _buildDailyActivityChart(dailyPlayTime, theme),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementProgress(GameTheme theme) {
    return _buildStatSection(
      title: 'Achievement Progress',
      icon: Icons.emoji_events,
      theme: theme,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withValues(alpha: 0.2),
                border: Border.all(color: Colors.amber, width: 3),
              ),
              child: Stack(
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      value:
                          double.tryParse(
                            _displayStats['achievementProgress']
                                    ?.toString()
                                    .replaceAll('%', '') ??
                                '0',
                          ) ??
                          0 / 100,
                      strokeWidth: 4,
                      backgroundColor: Colors.amber.withValues(alpha: 0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.amber,
                      ),
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.military_tech,
                      color: Colors.amber,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Achievement Progress',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${_displayStats['achievementProgress'] ?? '0%'} Complete',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.accentColor.withValues(alpha: 0.8),
                    ),
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed('/achievements');
                    },
                    child: Text(
                      'View All Achievements →',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.amber,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(GameTheme theme) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 400) {
              return Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/achievements'),
                      text: 'VIEW ACHIEVEMENTS',
                      primaryColor: Colors.amber,
                      secondaryColor: Colors.orange,
                      icon: Icons.emoji_events,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      onPressed: () =>
                          Navigator.of(context).pushNamed('/leaderboard'),
                      text: 'LEADERBOARD',
                      primaryColor: theme.accentColor,
                      secondaryColor: theme.foodColor,
                      icon: Icons.leaderboard,
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: GradientButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/achievements'),
                    text: 'VIEW ACHIEVEMENTS',
                    primaryColor: Colors.amber,
                    secondaryColor: Colors.orange,
                    icon: Icons.emoji_events,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: GradientButton(
                    onPressed: () =>
                        Navigator.of(context).pushNamed('/leaderboard'),
                    text: 'LEADERBOARD',
                    primaryColor: theme.accentColor,
                    secondaryColor: theme.foodColor,
                    icon: Icons.leaderboard,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 16),

        SizedBox(
          width: double.infinity,
          child: GradientButton(
            onPressed: _showResetDialog,
            text: 'RESET STATISTICS',
            primaryColor: Colors.red.shade400,
            secondaryColor: Colors.red.shade600,
            icon: Icons.refresh,
          ),
        ),
      ],
    );
  }

  Widget _buildStatSection({
    required String title,
    required IconData icon,
    required GameTheme theme,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.accentColor, size: 24),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            child,
          ],
        ),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2);
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
    GameTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 8),

          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: theme.accentColor,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 4),

          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: theme.accentColor.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTrendCard(
    String label,
    String trend,
    IconData icon,
    Color color,
    GameTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 8),

          Text(
            trend.toUpperCase(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: theme.accentColor.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownCard(
    String title,
    String favorite,
    Map<String, int> breakdown,
    GameTheme theme,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: theme.accentColor.withValues(alpha: 0.8),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            favorite,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),

          const SizedBox(height: 8),

          ...breakdown.entries
              .take(3)
              .map(
                (entry) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.accentColor.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '${entry.value}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: theme.accentColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildDailyActivityChart(Map<String, int> dailyData, GameTheme theme) {
    final maxTime = dailyData.values.isNotEmpty
        ? dailyData.values.reduce((a, b) => a > b ? a : b)
        : 0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: dailyData.entries.map((entry) {
        final day = entry.key;
        final time = entry.value;
        final height = maxTime > 0 ? (time / maxTime) * 40 : 8.0;

        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: 20,
              height: height + 8,
              decoration: BoxDecoration(
                color: time > 0
                    ? theme.accentColor.withValues(alpha: 0.7)
                    : theme.accentColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              day,
              style: TextStyle(
                fontSize: 10,
                color: theme.accentColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'improving':
        return Colors.green;
      case 'declining':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatPlayTime(int seconds) {
    if (seconds < 60) {
      return '${seconds}s';
    } else if (seconds < 3600) {
      return '${(seconds / 60).round()}m';
    } else {
      return '${(seconds / 3600).round()}h';
    }
  }

  Future<void> _refreshStatistics() async {
    await _loadStatistics();
  }

  void _showResetDialog() {
    final theme = context.read<ThemeProvider>().currentTheme;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
        ),
        title: Text(
          'Reset Statistics?',
          style: TextStyle(color: theme.accentColor),
        ),
        content: Text(
          'This will permanently delete all your game statistics. This action cannot be undone.',
          style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _statisticsService.resetStatistics();
              await _loadStatistics();
            },
            child: const Text('Reset', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _calculateConsistencyRating(List<int> scores) {
    if (scores.length < 3) return 'N/A';

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final variance =
        scores
            .map((score) => (score - average) * (score - average))
            .reduce((a, b) => a + b) /
        scores.length;
    final standardDeviation = sqrt(variance);
    final coefficient = average > 0 ? standardDeviation / average : 0;

    if (coefficient < 0.3) return 'Excellent';
    if (coefficient < 0.5) return 'Good';
    if (coefficient < 0.7) return 'Fair';
    return 'Poor';
  }

  Widget _buildEnhancedTrendChart(
    List<int> scores,
    GameTheme theme,
    String trend,
  ) {
    if (scores.isEmpty) return const Center(child: Text('No data'));

    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);

    return CustomPaint(
      painter: TrendChartPainter(
        scores: scores,
        maxScore: maxScore,
        minScore: minScore,
        barColor: theme.accentColor,
        trendColor: _getTrendColor(trend),
        trend: trend,
      ),
      child: Container(),
    );
  }

  Widget _buildLegendItem(String label, Color color, GameTheme theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceInsights(
    List<int> scores,
    String trend,
    GameTheme theme,
  ) {
    final insights = _generateInsights(scores, trend);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.primaryColor,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Performance Insights',
                style: TextStyle(
                  color: theme.primaryColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...insights.map(
            (insight) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 4,
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    decoration: BoxDecoration(
                      color: theme.primaryColor.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      insight,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _generateInsights(List<int> scores, String trend) {
    final insights = <String>[];

    if (scores.isEmpty) return ['Play more games to get performance insights!'];

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final recent = scores.length >= 3
        ? scores.sublist(scores.length - 3)
        : scores;
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;

    if (trend == 'improving') {
      insights.add('Great job! Your performance is on an upward trend.');
      if (recentAvg > average * 1.2) {
        insights.add('Your recent games are significantly above your average.');
      }
    } else if (trend == 'declining') {
      insights.add(
        'Your performance has declined recently. Consider practicing more.',
      );
      insights.add(
        'Try focusing on avoiding collisions and planning your moves ahead.',
      );
    } else {
      insights.add(
        'Your performance is stable. Challenge yourself to improve!',
      );
    }

    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    if (maxScore > minScore * 3) {
      insights.add('You have potential for high scores - work on consistency.');
    }

    if (scores.length >= 5) {
      final lastFive = scores.sublist(scores.length - 5);
      if (lastFive.every((score) => score > average * 0.8)) {
        insights.add(
          'You\'re maintaining solid performance across recent games.',
        );
      }
    }

    return insights;
  }
}

class TrendChartPainter extends CustomPainter {
  final List<int> scores;
  final int maxScore;
  final int minScore;
  final Color barColor;
  final Color trendColor;
  final String trend;

  TrendChartPainter({
    required this.scores,
    required this.maxScore,
    required this.minScore,
    required this.barColor,
    required this.trendColor,
    required this.trend,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (scores.isEmpty) return;

    final barPaint = Paint()
      ..color = barColor.withValues(alpha: 0.6)
      ..style = PaintingStyle.fill;

    final trendPaint = Paint()
      ..color = trendColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final barWidth = size.width / scores.length;
    final range = maxScore > minScore ? maxScore - minScore : 1;

    // Draw bars
    for (int i = 0; i < scores.length; i++) {
      final score = scores[i];
      final normalizedHeight =
          ((score - minScore) / range) * (size.height - 10) + 5;
      final barHeight = normalizedHeight;

      final rect = Rect.fromLTWH(
        i * barWidth + barWidth * 0.1,
        size.height - barHeight,
        barWidth * 0.8,
        barHeight,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(2)),
        barPaint,
      );
    }

    // Draw trend line
    if (scores.length > 1) {
      final path = Path();
      for (int i = 0; i < scores.length; i++) {
        final score = scores[i];
        final x = i * barWidth + barWidth * 0.5;
        final normalizedHeight =
            ((score - minScore) / range) * (size.height - 10) + 5;
        final y = size.height - normalizedHeight;

        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, trendPaint);

      // Draw trend line points
      final pointPaint = Paint()
        ..color = trendColor
        ..style = PaintingStyle.fill;

      for (int i = 0; i < scores.length; i++) {
        final score = scores[i];
        final x = i * barWidth + barWidth * 0.5;
        final normalizedHeight =
            ((score - minScore) / range) * (size.height - 10) + 5;
        final y = size.height - normalizedHeight;

        canvas.drawCircle(Offset(x, y), 3, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
