import 'dart:math';

import 'package:flutter/material.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/utils/formatting.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';
import 'package:snake_classic/widgets/gradient_button.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  final StatisticsService _statisticsService = StatisticsService();
  late final AppDataCache _appCache;

  @override
  void initState() {
    super.initState();
    _appCache = getIt<AppDataCache>();
    // Trigger background refresh for fresh data (non-blocking)
    _appCache.refreshInBackground();
  }

  // Convenience getters using cached data - instant display!
  Map<String, dynamic> get _displayStats => _appCache.statistics ?? {};
  Map<String, dynamic> get _performanceTrends => _appCache.performanceTrends ?? {};
  Map<String, dynamic> get _playPatterns => _appCache.playPatterns ?? {};
  // Local-group readiness only. Every stat on this screen comes from Drift;
  // isFullyLoaded additionally requires the network group, which a first-run
  // preload skips, so gating on it left this screen spinning for the whole
  // session on data it already had.
  bool get _isLoading => !_appCache.isLocalDataLoaded;

  @override
  Widget build(BuildContext context) {
    // Subscribe to AppDataCache so a post-game refreshStatistics() call
    // rebuilds this screen with the updated high score / totals instead of
    // leaving the user staring at the snapshot captured at first paint.
    return ListenableBuilder(
      listenable: _appCache,
      builder: (context, _) => BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final theme = state.currentTheme;

        return Scaffold(
          bottomNavigationBar: const SnakeBannerAd(),
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
                            AppLocalizations.of(context)!.stLoading,
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
                            padding: EdgeInsets.symmetric(
                              horizontal: 16 + context.sideInset(),
                              vertical: 16,
                            ),
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
            icon: Icon(Icons.arrow_back, color: theme.accentColor, size: context.scaled(24)),
          ),

          const SizedBox(width: 8),

          Icon(Icons.analytics, color: theme.accentColor, size: context.scaled(28)),

          const SizedBox(width: 12),

          // Matches appScreenBar. This screen builds its own header row
          // rather than using a Scaffold appBar, so it cannot take the shared
          // widget — but it can wear the same title.
          // Expanded, not Flexible-beside-a-Spacer: both would be flex 1 and
          // split the free space evenly, which is what cut the title to
          // "STATI...". This takes the room and the refresh button keeps its
          // place at the end. FittedBox then shrinks rather than truncates,
          // the same way the shared app bar does.
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
              AppLocalizations.of(context)!.pfStatistics.toUpperCase(),
              overflow: TextOverflow.ellipsis,
              style: GameTypography.headlineSmall(color: theme.accentColor)
                  .copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: context.letterSpacing(2),
                shadows: [
                  Shadow(
                    blurRadius: 18,
                    color: theme.accentColor.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ),
            ),
          ),

          IconButton(
            onPressed: _refreshStatistics,
            icon: Icon(
              Icons.refresh,
              color: theme.accentColor.withValues(alpha: 0.7),
              size: context.scaled(24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceOverview(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return _buildStatSection(
      title: l10n.stPerformanceOverview,
      icon: Icons.trending_up,
      theme: theme,
      child: Column(
        children: [
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    l10n.pfHighScore,
                    '${_displayStats['highScore'] ?? 0}',
                    Icons.emoji_events,
                    Colors.amber,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    l10n.stTotalGames,
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
                    l10n.pfAverageScore,
                    context.formatInt(
                      (_displayStats['averageScore'] as num?) ?? 0,
                    ),
                    Icons.trending_up,
                    Colors.green,
                    theme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    l10n.stWinStreak,
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
    final l10n = AppLocalizations.of(context)!;
    return _buildStatSection(
      title: l10n.stGameActivity,
      icon: Icons.schedule,
      theme: theme,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.pfPlayTime,
                  _formatDuration(
                    l10n,
                    (_displayStats['totalPlayTime'] as num?)?.toInt() ?? 0,
                  ),
                  Icons.access_time,
                  Colors.blue,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.stLongestGame,
                  _formatDuration(
                    l10n,
                    (_displayStats['longestSurvival'] as num?)?.toInt() ?? 0,
                  ),
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
                  l10n.stHighestLevel,
                  '${_displayStats['highestLevel'] ?? 1}',
                  Icons.military_tech,
                  Colors.indigo,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.stPerfectGames,
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
    final l10n = AppLocalizations.of(context)!;
    final foodBreakdown =
        _displayStats['foodBreakdown'] as Map<String, int>? ?? {};
    final powerUpBreakdown =
        _displayStats['powerUpBreakdown'] as Map<String, int>? ?? {};

    return _buildStatSection(
      title: l10n.stFoodPowerUps,
      icon: Icons.restaurant,
      theme: theme,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.pfFoodConsumed,
                  '${_displayStats['totalFood'] ?? 0}',
                  Icons.apple,
                  Colors.red,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.stPowerUpsUsed,
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
                      l10n.stFavoriteFood,
                      '${_displayStats['favoriteFood'] ?? l10n.stNone}',
                      foodBreakdown,
                      theme,
                    ),
                  ),

                if (foodBreakdown.isNotEmpty && powerUpBreakdown.isNotEmpty)
                  const SizedBox(width: 12),

                if (powerUpBreakdown.isNotEmpty)
                  Expanded(
                    child: _buildBreakdownCard(
                      l10n.stFavoritePowerUp,
                      _displayStats['favoritePowerUp'] != null
                          ? localizedPowerUpStatName(
                              _displayStats['favoritePowerUp'].toString(),
                              l10n)
                          : l10n.stNone,
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
    final l10n = AppLocalizations.of(context)!;
    final recentScores =
        (_performanceTrends['recentScores'] as List<int>?) ?? [];
    final trend = _performanceTrends['trend'] as String? ?? 'stable';

    return _buildStatSection(
      title: l10n.stPerformanceTrends,
      icon: Icons.show_chart,
      theme: theme,
      child: Column(
        children: [
          // Enhanced Trend Overview Cards
          Row(
            children: [
              Expanded(
                child: _buildTrendCard(
                  l10n.stOverallTrend,
                  trend,
                  _getTrendIcon(trend),
                  _getTrendColor(trend),
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.stRecentAverage,
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
                  l10n.stBestRecent,
                  '${_performanceTrends['bestRecentScore'] ?? 0}',
                  Icons.star_outline,
                  Colors.amber,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.stConsistency,
                  _calculateConsistencyRating(recentScores, l10n),
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
              child: HudCorners(
                color: theme.accentColor,
                inset: 8,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        l10n.stProgressLastGames(recentScores.length),
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
                    height: context.scaled(80),
                    child: _buildEnhancedTrendChart(recentScores, theme, trend),
                  ),

                  const SizedBox(height: 8),

                  // Chart Legend
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildLegendItem(l10n.stScores, theme.accentColor, theme),
                      const SizedBox(width: 16),
                      _buildLegendItem(
                        l10n.stTrendLine,
                        _getTrendColor(trend),
                        theme,
                      ),
                    ],
                  ),
                ],
              )),
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
    final l10n = AppLocalizations.of(context)!;
    final dailyPlayTime =
        (_playPatterns['dailyPlayTime'] as Map<String, int>?) ?? {};

    return _buildStatSection(
      title: l10n.stPlayPatterns,
      icon: Icons.calendar_today,
      theme: theme,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  l10n.stWeeklyTime,
                  _formatDuration(
                    l10n,
                    (_playPatterns['totalWeeklyTime'] as num?)?.toInt() ?? 0,
                  ),
                  Icons.schedule,
                  Colors.green,
                  theme,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  l10n.stMostActiveDay,
                  _localizedMostActiveDay(l10n),
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
              child: HudCorners(
                color: theme.accentColor,
                inset: 8,
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.stDailyActivity,
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.8),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    height: context.scaled(60),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical, // or horizontal if needed
                      child: _buildDailyActivityChart(dailyPlayTime, theme),
                    ),
                  ),
                ],
              )),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAchievementProgress(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return _buildStatSection(
      title: l10n.stAchievementProgress,
      icon: Icons.emoji_events,
      theme: theme,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.accentColor.withValues(alpha: 0.2)),
        ),
        child: HudCorners(
          color: theme.accentColor,
          inset: 8,
          child: Row(
          children: [
            Container(
              width: context.scaled(60),
              height: context.scaled(60),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amber.withValues(alpha: 0.2),
                border: Border.all(color: Colors.amber, width: 3),
              ),
              child: Stack(
                children: [
                  Center(
                    child: CircularProgressIndicator(
                      // achievementProgress arrives as a RAW 0..1 fraction
                      // (double) from getDisplayStatistics — exactly what
                      // the indicator expects.
                      value:
                          ((_displayStats['achievementProgress'] as num?)
                                      ?.toDouble() ??
                                  0.0)
                              .clamp(0.0, 1.0),
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
                      size: context.scaled(24),
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
                    l10n.stAchievementProgress,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.accentColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    l10n.stPercentComplete(
                      context.formatPercent(
                        (_displayStats['achievementProgress'] as num?)
                                ?.toDouble() ??
                            0,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.accentColor.withValues(alpha: 0.8),
                    ),
                  ),

                  const SizedBox(height: 8),

                  GestureDetector(
                    onTap: () => context.push(AppRoutes.achievements),
                    child: Text(
                      l10n.stViewAllAchievements,
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
        )),
      ),
    );
  }

  Widget _buildActionButtons(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
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
                      onPressed: () => context.push(AppRoutes.achievements),
                      text: l10n.stViewAchievements,
                      primaryColor: Colors.amber,
                      secondaryColor: Colors.orange,
                      icon: Icons.emoji_events,
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: GradientButton(
                      onPressed: () => context.push(AppRoutes.replays),
                      text: l10n.stReplaysUpper,
                      primaryColor: theme.accentColor,
                      secondaryColor: theme.foodColor,
                      icon: Icons.video_library,
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: GradientButton(
                    onPressed: () => context.push(AppRoutes.achievements),
                    text: l10n.stViewAchievements,
                    primaryColor: Colors.amber,
                    secondaryColor: Colors.orange,
                    icon: Icons.emoji_events,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: GradientButton(
                    onPressed: () => context.push(AppRoutes.replays),
                    text: l10n.stReplaysUpper,
                    primaryColor: theme.accentColor,
                    secondaryColor: theme.foodColor,
                    icon: Icons.video_library,
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
            text: l10n.stResetStatistics,
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
      decoration: arcadeSurface(
        theme,
        borderRadius: BorderRadius.circular(20),
        borderColor: theme.accentColor.withValues(alpha: 0.28),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The shared eyebrow: emblem, tracked title, rule, terminator.
            // This was the same header hand-rolled, which is how the screen
            // ended up looking like a different product to the one next door.
            screenEyebrow(context, theme, title, icon: icon),

            const SizedBox(height: 4),

            child,
          ],
        ),
      ),
    ).gameZoomIn();
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
      child: HudCorners(
        color: theme.accentColor,
        inset: 8,
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: context.scaled(28)),

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
      )),
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
      child: HudCorners(
        color: theme.accentColor,
        inset: 8,
        child: Column(
        children: [
          Icon(icon, color: color, size: context.scaled(28)),

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
      )),
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
      child: HudCorners(
        color: theme.accentColor,
        inset: 8,
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
      )),
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
              AppFormats.weekdayShortFromEn(day, Localizations.localeOf(context)),
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

  /// Localized duration for the stats cards. The service returns raw
  /// seconds; the stDur* ARB keys carry the per-locale unit letters.
  String _formatDuration(AppLocalizations l10n, int seconds) {
    if (seconds < 60) {
      return l10n.stDurSeconds(seconds);
    } else if (seconds < 3600) {
      final m = seconds ~/ 60;
      final s = seconds % 60;
      return s == 0 ? l10n.stDurMinutes(m) : l10n.stDurMinSec(m, s);
    } else {
      final h = seconds ~/ 3600;
      final m = (seconds % 3600) ~/ 60;
      return m == 0 ? l10n.stDurHours(h) : l10n.stDurHourMin(h, m);
    }
  }

  /// The service keys mostActiveDay by English 'Sun'..'Sat' (or the literal
  /// 'None' when empty) — map to the locale's weekday abbreviation here.
  String _localizedMostActiveDay(AppLocalizations l10n) {
    final day = _playPatterns['mostActiveDay'] as String?;
    if (day == null || day == 'None') return l10n.stNone;
    return AppFormats.weekdayShortFromEn(day, Localizations.localeOf(context));
  }

  Future<void> _refreshStatistics() async {
    await _appCache.refreshStatistics();
    if (mounted) setState(() {});
  }

  void _showResetDialog() {
    final theme = context.read<ThemeCubit>().state.currentTheme;
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.accentColor.withValues(alpha: 0.3)),
        ),
        title: Text(
          l10n.stResetTitle,
          style: TextStyle(color: theme.accentColor),
        ),
        content: Text(
          l10n.stResetBody,
          style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              l10n.commonCancel,
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _statisticsService.resetStatistics();
              await _refreshStatistics();
            },
            child: Text(l10n.stReset, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  String _calculateConsistencyRating(List<int> scores, AppLocalizations l10n) {
    if (scores.length < 3) return l10n.stNA;

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final variance =
        scores
            .map((score) => (score - average) * (score - average))
            .reduce((a, b) => a + b) /
        scores.length;
    final standardDeviation = sqrt(variance);
    final coefficient = average > 0 ? standardDeviation / average : 0;

    if (coefficient < 0.3) return l10n.stExcellent;
    if (coefficient < 0.5) return l10n.stGood;
    if (coefficient < 0.7) return l10n.stFair;
    return l10n.stPoor;
  }

  Widget _buildEnhancedTrendChart(
    List<int> scores,
    GameTheme theme,
    String trend,
  ) {
    if (scores.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.stNoData));
    }

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
    final l10n = AppLocalizations.of(context)!;
    final insights = _generateInsights(scores, trend, l10n);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.primaryColor.withValues(alpha: 0.2)),
      ),
      child: HudCorners(
        color: theme.accentColor,
        inset: 8,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: theme.primaryColor,
                size: context.scaled(18),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.stInsights,
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
                    // Directional: in Arabic the Row reverses, so the gap
                    // between the bullet and its text has to follow.
                    margin: const EdgeInsetsDirectional.only(top: 6, end: 8),
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
      )),
    );
  }

  List<String> _generateInsights(
    List<int> scores,
    String trend,
    AppLocalizations l10n,
  ) {
    final insights = <String>[];

    if (scores.isEmpty) return [l10n.stInsightPlayMore];

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final recent = scores.length >= 3
        ? scores.sublist(scores.length - 3)
        : scores;
    final recentAvg = recent.reduce((a, b) => a + b) / recent.length;

    if (trend == 'improving') {
      insights.add(l10n.stInsightImproving);
      if (recentAvg > average * 1.2) {
        insights.add(l10n.stInsightAboveAverage);
      }
    } else if (trend == 'declining') {
      insights.add(l10n.stInsightDeclined);
      insights.add(l10n.stInsightPractice);
    } else {
      insights.add(l10n.stInsightStable);
    }

    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);
    if (maxScore > minScore * 3) {
      insights.add(l10n.stInsightPotential);
    }

    if (scores.length >= 5) {
      final lastFive = scores.sublist(scores.length - 5);
      if (lastFive.every((score) => score > average * 0.8)) {
        insights.add(l10n.stInsightSolid);
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
