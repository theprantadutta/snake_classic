import 'analytics_client.dart';

/// Retention analytics added for the November 2026 retention plan
/// (docs/RETENTION_PLAN_2026-11.md, section 5). Every event and user property
/// here is documented in CLAUDE.md, "Retention analytics (8.1)".
///
/// They ride on the generic [AnalyticsClient.trackEvent], so they reach GA4
/// (and the debug logger) without a method per client.
extension RetentionEvents on AnalyticsClient {
  /// The player's first steering input of a run. Only logged for onboarding
  /// runs (the first three games), where it tells whether the controls hint
  /// works. [secondsSinceRunStart] is from the snake starting to move.
  Future<void> trackFirstInput({
    required int runNumber,
    required double secondsSinceRunStart,
    required String controlScheme,
  }) =>
      trackEvent('first_input', {
        'run_number': runNumber,
        'seconds_since_run_start':
            double.parse(secondsSinceRunStart.toStringAsFixed(1)),
        'control_scheme': controlScheme,
      });

  /// How an in-game revive offer ended: `ad`, `coins`, `free` (Pro),
  /// `declined`, `timeout` or `backgrounded`.
  Future<void> trackReviveOffer({
    required String outcome,
    required int runNumber,
  }) =>
      trackEvent('revive_offer', {
        'outcome': outcome,
        'run_number': runNumber,
      });

  /// The game-over "next goals" panel was shown. [goals] lists what it
  /// contained, comma-separated: `daily`, `season`, `tomorrow`, `quest`.
  Future<void> trackNextGoalShown({required String goals}) =>
      trackEvent('next_goal_shown', {'goals': goals});

  /// A goal in the game-over panel was tapped: `daily`, `season`,
  /// `tomorrow` or `quest`.
  Future<void> trackNextGoalTapped({required String goal}) =>
      trackEvent('next_goal_tapped', {'goal': goal});

  /// The daily login bonus was claimed. [surface] is `popup` or `home`.
  /// Sent alongside the older `daily_bonus_collected`, which has no params.
  Future<void> trackDailyBonusClaimed({
    required int day,
    required int streak,
    required bool doubled,
    required String surface,
  }) =>
      trackEvent('daily_bonus_claimed', {
        'day': day,
        'streak': streak,
        'doubled': doubled ? 1 : 0,
        'surface': surface,
      });

  /// A login streak ended (the player missed a day). [previousStreak] is
  /// how long it was.
  Future<void> trackStreakBroken({required int previousStreak}) =>
      trackEvent('streak_broken', {'previous_streak': previousStreak});

  /// A weekly quest reached its target.
  Future<void> trackWeeklyQuestCompleted({required String questId}) =>
      trackEvent('weekly_quest_completed', {'quest_id': questId});

  /// A weekly quest's reward was claimed.
  Future<void> trackWeeklyQuestClaimed({required String questId}) =>
      trackEvent('weekly_quest_claimed', {'quest_id': questId});

  /// Notification permission funnel. [stage]: `soft_shown`,
  /// `soft_accepted`, `soft_declined`, `os_granted`, `os_denied`.
  /// [placement]: where it was asked (`first_best`, `home_queue`, ...).
  Future<void> trackNotificationPermission({
    required String stage,
    required String placement,
  }) =>
      trackEvent('notification_permission', {
        'stage': stage,
        'placement': placement,
      });

  /// What happened to the local day-1 reminder: `scheduled`,
  /// `skipped_no_permission`, `skipped_pref`, `failed`.
  Future<void> trackDayOneReminder({required String result}) =>
      trackEvent('day1_reminder', {'result': result});

  /// The "More games" screen (cross-promotion of the owner's other games).
  /// [stage]: `opened` (the screen was opened; [source] = `menu` or
  /// `settings`), `shown` (a game's card was built, i.e. scrolled near,
  /// once per visit), `tapped`, `open_failed` (no store app could open the
  /// link). [game]: the promoted game's id, e.g. `cosmo_strike`.
  Future<void> trackMoreGames({
    required String stage,
    String? game,
    String? source,
  }) =>
      trackEvent('more_games', {
        'stage': stage,
        'game': ?game,
        'source': ?source,
      });

  /// Play in-app update funnel (Android). [stage]: `offered` (our dialog
  /// shown), `accepted` ("Update now"), `snoozed` ("Later"), `urgent`
  /// (priority release, blocking flow unasked), `flexible_fallback`,
  /// `immediate_result` ([result]: `success` / `userDeniedUpdate` /
  /// `failed` / `error`), `auto_completed` ([result]: `home`, a finished
  /// download installed at launch).
  Future<void> trackAppUpdate({required String stage, String? result}) =>
      trackEvent('app_update', {
        'stage': stage,
        'result': ?result,
      });

  // ---- User properties ----

  /// `1` once the first three games have been started.
  Future<void> setOnboardingDone(bool done) =>
      setUserProperty('onboarding_done', done ? '1' : '0');

  /// `granted`, `denied` or `undecided`.
  Future<void> setNotificationPermission(String state) =>
      setUserProperty('notif_permission', state);

  /// ISO week of the install, e.g. `2026-W48`, so every GA4 report can be
  /// split by install cohort.
  Future<void> setInstallWeek(DateTime installedAt) =>
      setUserProperty('install_week', isoWeekLabel(installedAt));

  /// A skin / trail / theme bought with coins (server-charged). [price] is
  /// the coins actually charged.
  Future<void> trackCosmeticBoughtWithCoins({
    required String cosmeticType,
    required String cosmeticId,
    required int price,
  }) =>
      trackEvent('cosmetic_bought_with_coins', {
        'cosmetic_type': cosmeticType,
        'cosmetic_id': cosmeticId,
        'price': price,
      });
}

/// ISO-8601 week label (`2026-W48`) for [date] in local time.
String isoWeekLabel(DateTime date) {
  // UTC dates so DST never shifts the day arithmetic.
  final d = DateTime.utc(date.year, date.month, date.day);
  // The Thursday of this ISO week (Monday = 1) decides the ISO year.
  final thursday = d.add(Duration(days: DateTime.thursday - d.weekday));
  final dayOfYear = thursday.difference(DateTime.utc(thursday.year)).inDays;
  final week = dayOfYear ~/ 7 + 1;
  return '${thursday.year}-W${week.toString().padLeft(2, '0')}';
}
