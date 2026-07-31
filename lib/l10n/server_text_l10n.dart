import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/models/weekly_quest.dart';
import 'package:snake_classic/utils/constants.dart';

/// Render-time localization for backend-generated display text.
///
/// Daily challenges, weekly quests, and tournaments are created server-side
/// from FIXED template catalogs (DailyChallengeJobService / WeeklyQuestJob-
/// Service / TournamentManagementJobService). The English text stays in
/// Drift and in the sync mirror — the operator dashboard reads it — so we
/// translate only at render, keyed on the exact English template strings.
/// Anything unrecognized (a template the server added after this build)
/// falls through to the server text verbatim.
extension DailyChallengeL10n on DailyChallenge {
  String localizedTitle(AppLocalizations l10n) => switch (title) {
        'Beginner Score' => l10n.dcTitleScoreEasy,
        'Skilled Player' => l10n.dcTitleScoreMedium,
        'Score Master' => l10n.dcTitleScoreHard,
        'Hungry Snake' => l10n.dcTitleFoodEasy,
        'Feast Mode' => l10n.dcTitleFoodMedium,
        'Insatiable' => l10n.dcTitleFoodHard,
        'Survivor' => l10n.dcTitleSurvivalEasy,
        'Endurance' => l10n.dcTitleSurvivalMedium,
        'Immortal' => l10n.dcTitleSurvivalHard,
        'Casual Player' => l10n.dcTitleGamesEasy,
        'Dedicated' => l10n.dcTitleGamesMedium,
        'Snake Addict' => l10n.dcTitleGamesHard,
        'Classic Lover' => l10n.dcTitleModeEasy,
        'Zen Master' => l10n.dcTitleModeMedium,
        'Speed Demon' => l10n.dcTitleModeHard,
        _ => title,
      };

  String localizedDescription(AppLocalizations l10n) => switch (title) {
        'Beginner Score' ||
        'Skilled Player' ||
        'Score Master' =>
          l10n.dcDescScore(targetValue),
        'Hungry Snake' ||
        'Feast Mode' ||
        'Insatiable' =>
          l10n.dcDescFood(targetValue),
        'Survivor' ||
        'Endurance' ||
        'Immortal' =>
          l10n.dcDescSurvival(targetValue),
        'Casual Player' ||
        'Dedicated' ||
        'Snake Addict' =>
          l10n.dcDescGames(targetValue),
        'Classic Lover' ||
        'Zen Master' ||
        'Speed Demon' =>
          l10n.dcDescMode(targetValue, _modeName(l10n)),
        _ => description,
      };

  String _modeName(AppLocalizations l10n) => switch (requiredGameMode) {
        'classic' => GameMode.classic.localizedName(l10n),
        'zen' => GameMode.zen.localizedName(l10n),
        'speed' => GameMode.speedChallenge.localizedName(l10n),
        _ => requiredGameMode ?? '',
      };
}

extension WeeklyQuestL10n on WeeklyQuest {
  String localizedTitle(AppLocalizations l10n) => switch (title) {
        'Weekly Warmup' => l10n.wqTitleScoreEasy,
        'Sharper Reflexes' => l10n.wqTitleScoreMedium,
        'Score Champion' => l10n.wqTitleScoreHard,
        'Weekly Snacker' => l10n.wqTitleFoodEasy,
        'Voracious' => l10n.wqTitleFoodMedium,
        'Bottomless' => l10n.wqTitleFoodHard,
        'Five-a-Week' => l10n.wqTitleGamesEasy,
        'Routine Hatched' => l10n.wqTitleGamesMedium,
        'Marathon Hatcher' => l10n.wqTitleGamesHard,
        'Two-Minute Slither' => l10n.wqTitleSurvivalEasy,
        'Five-Minute Slither' => l10n.wqTitleSurvivalMedium,
        'Ten-Minute Slither' => l10n.wqTitleSurvivalHard,
        'Tournament Regular' => l10n.wqTitleTournament,
        'Daily Doer' => l10n.wqTitleDailyEasy,
        'Daily Adept' => l10n.wqTitleDailyMedium,
        _ => title,
      };

  String localizedDescription(AppLocalizations l10n) => switch (title) {
        'Weekly Warmup' ||
        'Sharper Reflexes' ||
        'Score Champion' =>
          l10n.wqDescScore(targetValue),
        'Weekly Snacker' ||
        'Voracious' ||
        'Bottomless' =>
          l10n.wqDescFood(targetValue),
        'Five-a-Week' ||
        'Routine Hatched' ||
        'Marathon Hatcher' =>
          l10n.wqDescGames(targetValue),
        'Two-Minute Slither' ||
        'Five-Minute Slither' ||
        'Ten-Minute Slither' =>
          l10n.wqDescSurvival(targetValue),
        'Tournament Regular' => l10n.wqDescTournament(targetValue),
        'Daily Doer' || 'Daily Adept' => l10n.wqDescDaily(targetValue),
        _ => description,
      };
}

/// ISO-8601 week number, matching the backend's ISOWeek.GetWeekOfYear used
/// to compose "Weekly Championship - Week {n}".
int _isoWeekNumber(DateTime date) {
  final thursday = date.add(Duration(days: 4 - date.weekday));
  final firstDayOfYear = DateTime(thursday.year, 1, 1);
  return (thursday.difference(firstDayOfYear).inDays ~/ 7) + 1;
}

extension TournamentL10n on Tournament {
  /// 'daily' | 'weekly' | 'monthly' | null. Prefers the server slug
  /// ("daily-2026-07-30"); older cached rows fall back to matching the
  /// English name the job composed. A genuine future special event with an
  /// authored name matches neither and keeps its server text.
  String? get _templateKind {
    final slug = tournamentId;
    if (slug != null) {
      if (slug.startsWith('daily-')) return 'daily';
      if (slug.startsWith('weekly-')) return 'weekly';
      if (slug.startsWith('monthly-')) return 'monthly';
      return null;
    }
    if (name.startsWith('Daily Challenge - ')) return 'daily';
    if (name.startsWith('Weekly Championship - ')) return 'weekly';
    if (name.startsWith('Monthly Grand Prix - ')) return 'monthly';
    return null;
  }

  String localizedName(AppLocalizations l10n, Locale locale) {
    final tag = locale.toLanguageTag();
    return switch (_templateKind) {
      'daily' => l10n.tnNameDaily(DateFormat.MMMMd(tag).format(startDate)),
      'weekly' => l10n.tnNameWeekly(_isoWeekNumber(startDate)),
      'monthly' => l10n.tnNameMonthly(DateFormat.yMMMM(tag).format(startDate)),
      _ => name,
    };
  }

  String localizedDescription(AppLocalizations l10n) =>
      switch (_templateKind) {
        'daily' => l10n.tnDescDaily,
        'weekly' => l10n.tnDescWeekly,
        'monthly' => l10n.tnDescMonthly,
        _ => description,
      };
}

/// The client synthesizes reward rows as 'Rank {k}' / 'Coin reward for
/// rank {k}' in Tournament.fromJson — localize them by shape.
final RegExp _rankNamePattern = RegExp(r'^Rank (\d+)$');
final RegExp _rankDescPattern = RegExp(r'^Coin reward for rank (\d+)$');

String localizedTournamentRewardName(String name, AppLocalizations l10n) {
  final m = _rankNamePattern.firstMatch(name);
  return m != null ? l10n.tnRewardRank(m.group(1)!) : name;
}

String localizedTournamentRewardDescription(
    String description, AppLocalizations l10n) {
  final m = _rankDescPattern.firstMatch(description);
  return m != null ? l10n.tnRewardCoinDesc(m.group(1)!) : description;
}
