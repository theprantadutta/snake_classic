import 'dart:math';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/app_data_cache.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/profile/lb_profile_parts.dart';

/// Statistics on the Living Board: the same numbers as before, in blocks and
/// cells. Everything comes from Drift via [AppDataCache]; pull down to
/// refresh, or reset from the bottom.
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

  int _stat(String key, [int fallback = 0]) => (_displayStats[key] as num?)?.toInt() ?? fallback;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // Subscribe to AppDataCache so a post-game refreshStatistics() call
    // rebuilds this screen with the updated high score / totals instead of
    // leaving the user staring at the snapshot captured at first paint.
    return ListenableBuilder(
      listenable: _appCache,
      builder: (context, _) {
        if (_isLoading) {
          return LBScaffold(
            title: l10n.lbStats,
            subtitle: l10n.lbStatsSubtitle,
            body: LBLoadingCells(label: l10n.stLoading),
          );
        }
        final g = context.lbGutter;
        final cell = context.lbCell;
        return LBScaffold(
          title: l10n.lbStats,
          subtitle: l10n.lbStatsSubtitle,
          body: RefreshIndicator(
            onRefresh: _refreshStatistics,
            color: context.lb.lime,
            backgroundColor: context.lb.deep,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(g, cell * .9, g, cell * 1.5),
              children: [
                ..._performanceOverview(l10n),
                SizedBox(height: cell),
                ..._gameActivity(l10n),
                SizedBox(height: cell),
                ..._consumption(l10n),
                SizedBox(height: cell),
                ..._trendsSection(l10n),
                SizedBox(height: cell),
                ..._playPatternsSection(l10n),
                SizedBox(height: cell),
                ..._achievementProgress(l10n),
                SizedBox(height: cell),
                ..._actions(l10n),
              ],
            ),
          ),
        );
      },
    );
  }

  List<Widget> _performanceOverview(AppLocalizations l10n) => [
        LBSectionLabel(l10n.stPerformanceOverview),
        LBTwoColumns(
          children: [
            LBStatTile(
              label: l10n.lbStatBest,
              value: context.formatInt(_stat('highScore')),
              valueColor: LB.gold,
            ),
            LBStatTile(label: l10n.stTotalGames, value: context.formatInt(_stat('totalGames'))),
            LBStatTile(
              label: l10n.lbStatAverage,
              value: context.formatInt((_displayStats['averageScore'] as num?) ?? 0),
            ),
            LBStatTile(label: l10n.stWinStreak, value: context.formatInt(_stat('winStreak'))),
          ],
        ),
      ];

  List<Widget> _gameActivity(AppLocalizations l10n) => [
        LBSectionLabel(l10n.stGameActivity),
        LBTwoColumns(
          children: [
            LBStatTile(label: l10n.lbStatPlayTime, value: lbDuration(l10n, _stat('totalPlayTime'))),
            LBStatTile(label: l10n.stLongestGame, value: lbDuration(l10n, _stat('longestSurvival'))),
            LBStatTile(label: l10n.stHighestLevel, value: context.formatInt(_stat('highestLevel', 1))),
            LBStatTile(label: l10n.stPerfectGames, value: context.formatInt(_stat('perfectGames'))),
          ],
        ),
      ];

  List<Widget> _consumption(AppLocalizations l10n) {
    final foodBreakdown = _displayStats['foodBreakdown'] as Map<String, int>? ?? {};
    final powerUpBreakdown = _displayStats['powerUpBreakdown'] as Map<String, int>? ?? {};
    return [
      LBSectionLabel(l10n.stFoodPowerUps),
      LBTwoColumns(
        children: [
          LBStatTile(label: l10n.lbStatFood, value: context.formatInt(_stat('totalFood'))),
          LBStatTile(label: l10n.stPowerUpsUsed, value: context.formatInt(_stat('totalPowerUps'))),
          if (foodBreakdown.isNotEmpty)
            _BreakdownBlock(
              title: l10n.stFavoriteFood,
              favorite: '${_displayStats['favoriteFood'] ?? l10n.stNone}',
              breakdown: foodBreakdown,
            ),
          if (powerUpBreakdown.isNotEmpty)
            _BreakdownBlock(
              title: l10n.stFavoritePowerUp,
              favorite: _displayStats['favoritePowerUp'] != null
                  ? localizedPowerUpStatName(_displayStats['favoritePowerUp'].toString(), l10n)
                  : l10n.stNone,
              breakdown: powerUpBreakdown,
              nameOf: (k) => localizedPowerUpStatName(k, l10n),
            ),
        ],
      ),
    ];
  }

  List<Widget> _trendsSection(AppLocalizations l10n) {
    final p = context.lb;
    final recentScores = (_performanceTrends['recentScores'] as List<int>?) ?? [];
    final trend = _performanceTrends['trend'] as String? ?? 'stable';
    final trendLabel = _trendLabel(l10n, trend);
    final trendColor = _trendColor(trend);

    return [
      LBSectionLabel(l10n.stPerformanceTrends),
      LBTwoColumns(
        children: [
          LBStatTile(label: l10n.stOverallTrend, value: trendLabel, valueColor: trendColor),
          LBStatTile(
            label: l10n.stRecentAverage,
            value: context.formatInt((_performanceTrends['averageRecentScore'] as num?) ?? 0),
          ),
          LBStatTile(
            label: l10n.stBestRecent,
            value: context.formatInt((_performanceTrends['bestRecentScore'] as num?) ?? 0),
            valueColor: LB.gold,
          ),
          LBStatTile(label: l10n.stConsistency, value: _calculateConsistencyRating(recentScores, l10n)),
        ],
      ),
      if (recentScores.isNotEmpty) ...[
        LBBlock(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LBSectionLabel(
                l10n.stProgressLastGames(recentScores.length),
                trailing: trendLabel,
              ),
              const SizedBox(height: 8),
              LBCellColumns(
                values: recentScores,
                rows: 6,
                // The latest game in the head colour, so "now" reads first.
                colorAt: (i) => i == recentScores.length - 1 ? p.head : p.lime.withValues(alpha: .75),
              ),
            ],
          ),
        ),
        LBBlock(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LBSectionLabel(l10n.stInsights),
              for (final insight in _generateInsights(recentScores, trend, l10n))
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.only(top: 5, end: 10),
                        child: SizedBox.square(
                          dimension: 6,
                          child: CustomPaint(painter: _CellDot(p.lime)),
                        ),
                      ),
                      Expanded(
                        child: Text(insight, style: LBText.body(p, color: p.ink.withValues(alpha: .8), size: 11.5)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    ];
  }

  List<Widget> _playPatternsSection(AppLocalizations l10n) {
    final p = context.lb;
    final dailyPlayTime = (_playPatterns['dailyPlayTime'] as Map<String, int>?) ?? {};
    final locale = Localizations.localeOf(context);
    return [
      LBSectionLabel(l10n.stPlayPatterns),
      LBTwoColumns(
        children: [
          LBStatTile(
            label: l10n.stWeeklyTime,
            value: lbDuration(l10n, (_playPatterns['totalWeeklyTime'] as num?)?.toInt() ?? 0),
          ),
          LBStatTile(label: l10n.stMostActiveDay, value: _localizedMostActiveDay(l10n)),
        ],
      ),
      if (dailyPlayTime.isNotEmpty)
        LBBlock(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LBSectionLabel(l10n.stDailyActivity),
              const SizedBox(height: 8),
              LBCellColumns(
                values: dailyPlayTime.values.toList(),
                rows: 5,
                labels: [
                  for (final day in dailyPlayTime.keys) AppFormats.weekdayShortFromEn(day, locale),
                ],
                colorAt: (_) => p.lime,
              ),
            ],
          ),
        ),
    ];
  }

  List<Widget> _achievementProgress(AppLocalizations l10n) {
    final p = context.lb;
    // achievementProgress arrives as a RAW 0..1 fraction (double) from
    // getDisplayStatistics.
    final progress = ((_displayStats['achievementProgress'] as num?)?.toDouble() ?? 0.0).clamp(0.0, 1.0);
    final pct = l10n.stPercentComplete(context.formatPercent(progress));
    return [
      LBSectionLabel(l10n.stAchievementProgress),
      LBBlock(
        kind: LBBlockKind.gold,
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        semanticLabel: '${l10n.stAchievementProgress}, $pct',
        onTap: () => context.push(AppRoutes.achievements),
        child: ExcludeSemantics(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const LBPixelIcon(LBIcon.trophy, cell: 3.4, color: LB.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(pct.toUpperCase(), style: LBText.button(p, color: LB.gold, size: 12.5)),
                  ),
                  LBPixelIcon(LBIcon.next, cell: 2, color: LB.gold.withValues(alpha: .8)),
                ],
              ),
              const SizedBox(height: 12),
              LBCellsBar(count: 16, value: progress, color: LB.gold, offColor: LB.goldFill),
            ],
          ),
        ),
      ),
    ];
  }

  List<Widget> _actions(AppLocalizations l10n) {
    return [
      LBTwoColumns(
        children: [
          LBLinkBlock(
            icon: LBIcon.trophy,
            label: l10n.lbTrophies,
            onTap: () => context.push(AppRoutes.achievements),
          ),
          LBLinkBlock(
            icon: LBIcon.film,
            label: l10n.lbReplays,
            onTap: () => context.push(AppRoutes.replays),
          ),
        ],
      ),
      LBRow(
        title: l10n.stResetStatistics,
        kind: LBBlockKind.danger,
        leading: const LBPixelIcon(LBIcon.skull, cell: 3, color: LB.bonk),
        trailing: LBPixelIcon(LBIcon.next, cell: 2, color: LB.bonk.withValues(alpha: .7)),
        onTap: _showResetDialog,
      ),
    ];
  }

  String _trendLabel(AppLocalizations l10n, String trend) => switch (trend) {
        'improving' => l10n.lbTrendUp,
        'declining' => l10n.lbTrendDown,
        _ => l10n.lbTrendFlat,
      };

  Color _trendColor(String trend) => switch (trend) {
        'improving' => context.lb.lime,
        'declining' => LB.bonk,
        _ => context.lb.inkMuted,
      };

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

  Future<void> _showResetDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showLBDialog<bool>(
      context: context,
      title: l10n.stResetTitle,
      titleColor: LB.bonk,
      body: l10n.stResetBody,
      primaryLabel: l10n.stReset,
      primaryKind: LBBlockKind.danger,
      onPrimary: () => Navigator.of(context, rootNavigator: true).pop(true),
      secondaryLabel: l10n.commonCancel,
      onSecondary: () => Navigator.of(context, rootNavigator: true).pop(false),
    );
    if (confirmed != true) return;
    await _statisticsService.resetStatistics();
    await _refreshStatistics();
  }

  String _calculateConsistencyRating(List<int> scores, AppLocalizations l10n) {
    if (scores.length < 3) return l10n.stNA;

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final variance =
        scores.map((score) => (score - average) * (score - average)).reduce((a, b) => a + b) /
            scores.length;
    final standardDeviation = sqrt(variance);
    final coefficient = average > 0 ? standardDeviation / average : 0;

    if (coefficient < 0.3) return l10n.stExcellent;
    if (coefficient < 0.5) return l10n.stGood;
    if (coefficient < 0.7) return l10n.stFair;
    return l10n.stPoor;
  }

  List<String> _generateInsights(
    List<int> scores,
    String trend,
    AppLocalizations l10n,
  ) {
    final insights = <String>[];

    if (scores.isEmpty) return [l10n.stInsightPlayMore];

    final average = scores.reduce((a, b) => a + b) / scores.length;
    final recent = scores.length >= 3 ? scores.sublist(scores.length - 3) : scores;
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

/// Favourite food / power-up with its top three counts.
class _BreakdownBlock extends StatelessWidget {
  const _BreakdownBlock({
    required this.title,
    required this.favorite,
    required this.breakdown,
    this.nameOf,
  });

  final String title;
  final String favorite;
  final Map<String, int> breakdown;
  final String Function(String key)? nameOf;

  @override
  Widget build(BuildContext context) {
    final p = context.lb;
    return LBBlock(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), maxLines: 1, overflow: TextOverflow.ellipsis, style: LBText.label(p)),
          const SizedBox(height: 6),
          Text(
            favorite,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: LBText.value(p, size: 15),
          ),
          const SizedBox(height: 6),
          for (final entry in breakdown.entries.take(3))
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 1.5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      nameOf?.call(entry.key) ?? entry.key,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: LBText.body(p, size: 10.5),
                    ),
                  ),
                  Text(
                    context.formatInt(entry.value),
                    style: LBText.body(p, color: p.ink, size: 10.5).copyWith(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CellDot extends CustomPainter {
  _CellDot(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRRect(lbCellRect(0, 0, size.width), Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CellDot old) => old.color != color;
}
