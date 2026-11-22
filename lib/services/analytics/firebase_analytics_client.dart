import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:snake_classic/config/ui_design.dart';
import 'package:snake_classic/services/telemetry/install_identity.dart';

import 'analytics_client.dart';

/// Firebase Analytics implementation of [AnalyticsClient].
///
/// Uses Firebase's built-in methods where available (screen view, user ID,
/// user properties) and custom `logEvent` for everything else.
class FirebaseAnalyticsClient implements AnalyticsClient {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> setUserId(String? userId) {
    return _analytics.setUserId(id: userId);
  }

  @override
  Future<void> setUserProperties({String? authMethod, bool? isPremium}) async {
    if (authMethod != null) {
      await _analytics.setUserProperty(name: 'auth_method', value: authMethod);
    }
    if (isPremium != null) {
      await _analytics.setUserProperty(
        name: 'is_premium',
        value: isPremium.toString(),
      );
    }
  }

  @override
  Future<void> trackAppOpened() async {
    // Once per launch: which design and build this install is running, so
    // GA4 can split every report by design the way the telemetry dashboard
    // does. Set before the app_open event so it carries them.
    await _analytics.setUserProperty(name: 'ui_design', value: kUiDesign);
    final build = InstallIdentity.current?.build;
    if (build != null && build > 0) {
      await _analytics.setUserProperty(name: 'app_build', value: '$build');
    }
    await _analytics.logAppOpen();
  }

  @override
  Future<void> trackScreenView(String screenName) {
    return _analytics.logScreenView(screenName: screenName);
  }

  @override
  Future<void> trackSignInGoogle() {
    return _analytics.logLogin(loginMethod: 'google');
  }

  @override
  Future<void> trackSignInApple() {
    return _analytics.logLogin(loginMethod: 'apple');
  }

  @override
  Future<void> trackSignInAnonymous() {
    return _analytics.logLogin(loginMethod: 'anonymous');
  }

  @override
  Future<void> trackSignInEmail() {
    return _analytics.logLogin(loginMethod: 'email');
  }

  @override
  Future<void> trackSignOut() {
    return _analytics.logEvent(name: 'sign_out');
  }

  @override
  Future<void> trackUsernameSet() {
    return _analytics.logEvent(name: 'username_set');
  }

  @override
  Future<void> trackGameStarted({
    required int boardWidth,
    required int boardHeight,
    required String gameMode,
    required String controlScheme,
  }) {
    return _analytics.logEvent(
      name: 'game_started',
      parameters: {
        'board_width': boardWidth,
        'board_height': boardHeight,
        'game_mode': gameMode,
        // 'swipe' | 'dpad' | 'turn_buttons' — so control-scheme feel
        // complaints can be checked against how those players actually
        // fare, instead of argued about.
        'control_scheme': controlScheme,
      },
    );
  }

  @override
  Future<void> trackGamePaused() {
    return _analytics.logEvent(name: 'game_paused');
  }

  @override
  Future<void> trackGameResumed() {
    return _analytics.logEvent(name: 'game_resumed');
  }

  @override
  Future<void> trackGameOver({
    required int score,
    required int level,
    required int durationSeconds,
    required String cause,
    required int foodEaten,
    required int powerUpsCollected,
    required int maxCombo,
    required bool isNewHighScore,
    required int inputsAccepted,
    required int inputsRejected,
    String endTrigger = 'other',
    int runNumber = 0,
    String gameMode = '',
    bool onboarding = false,
  }) {
    return _analytics.logEvent(
      name: 'game_over',
      parameters: {
        'score': score,
        'level': level,
        'duration_seconds': durationSeconds,
        'cause': cause,
        'food_eaten': foodEaten,
        'power_ups_collected': powerUpsCollected,
        'max_combo': maxCombo,
        'is_new_high_score': isNewHighScore ? 1 : 0,
        'inputs_accepted': inputsAccepted,
        'inputs_rejected': inputsRejected,
        // What closed the continue window: timer | again | home | replay |
        // declined | background | new_run | no_offer | ... `background`
        // counts the runs that were lost before 7.6.2.
        'end_trigger': endTrigger,
        // Lifetime run number (1 = first ever), the mode, and whether this
        // was one of the first three (onboarding) games: the first-session
        // funnel and per-mode counts (retention plan 2026-11, section 5).
        if (runNumber > 0) 'run_number': runNumber,
        if (gameMode.isNotEmpty) 'game_mode': gameMode,
        'onboarding': onboarding ? 1 : 0,
      },
    );
  }

  @override
  Future<void> trackGameAbandoned({
    required String reason,
    required int score,
    required int durationSeconds,
    required int runNumber,
    required String gameMode,
  }) {
    return _analytics.logEvent(
      name: 'game_abandoned',
      parameters: {
        'reason': reason,
        'score': score,
        'duration_seconds': durationSeconds,
        'run_number': runNumber,
        'game_mode': gameMode,
      },
    );
  }

  @override
  Future<void> trackGameBackgrounded({
    required int score,
    required int durationSeconds,
    required int runNumber,
  }) {
    return _analytics.logEvent(
      name: 'game_backgrounded',
      parameters: {
        'score': score,
        'duration_seconds': durationSeconds,
        'run_number': runNumber,
      },
    );
  }

  @override
  Future<void> trackThemePromo({required String action}) {
    return _analytics.logEvent(
      name: 'theme_promo',
      parameters: {'promo_action': action, 'theme': 'miami_nights'},
    );
  }

  @override
  Future<void> trackPushOpened({
    required String type,
    required bool coldStart,
    required int ageMinutes,
  }) {
    return _analytics.logEvent(
      name: 'push_opened',
      parameters: {
        'push_type': type,
        'cold_start': coldStart ? 1 : 0,
        'age_minutes': ageMinutes,
      },
    );
  }

  @override
  Future<void> trackLevelUp(int level) {
    return _analytics.logLevelUp(level: level);
  }

  @override
  Future<void> trackPowerUpUsed(String powerUpType) {
    return _analytics.logEvent(
      name: 'power_up_used',
      parameters: {'power_up_type': powerUpType},
    );
  }

  @override
  Future<void> trackMultiplayerQueueJoined() {
    return _analytics.logEvent(name: 'multiplayer_queue_joined');
  }

  @override
  Future<void> trackMultiplayerGameStarted() {
    return _analytics.logEvent(name: 'multiplayer_game_started');
  }

  @override
  Future<void> trackMultiplayerGameEnded({
    required int score,
    required String result,
  }) {
    return _analytics.logEvent(
      name: 'multiplayer_game_ended',
      parameters: {'score': score, 'result': result},
    );
  }

  @override
  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) {
    return _analytics.logUnlockAchievement(id: achievementId);
  }

  @override
  Future<void> trackDailyChallengeCompleted(String challengeId) {
    return _analytics.logEvent(
      name: 'daily_challenge_completed',
      parameters: {'challenge_id': challengeId},
    );
  }

  @override
  Future<void> trackDailyChallengeRewardClaimed() {
    return _analytics.logEvent(name: 'daily_challenge_reward_claimed');
  }

  @override
  Future<void> trackBattlePassTierReached(int tier) {
    return _analytics.logEvent(
      name: 'battle_pass_tier_reached',
      parameters: {'tier': tier},
    );
  }

  @override
  Future<void> trackBattlePassRewardClaimed({
    required int tier,
    required String rewardType,
  }) {
    return _analytics.logEvent(
      name: 'battle_pass_reward_claimed',
      parameters: {'tier': tier, 'reward_type': rewardType},
    );
  }

  @override
  Future<void> trackStoreTabViewed(String tabName) {
    return _analytics.logEvent(
      name: 'store_tab_viewed',
      parameters: {'tab_name': tabName},
    );
  }

  @override
  Future<void> trackItemPurchased({
    required String itemId,
    required String itemType,
    required String price,
    double? value,
    String? currency,
  }) {
    return _analytics.logEvent(
      name: 'item_purchased',
      parameters: {
        'item_id': itemId,
        'item_type': itemType,
        'price': price,
        // Numeric twin of [price] so GA can sum it as the event value.
        'value': ?value,
        'currency': ?currency,
      },
    );
  }

  @override
  Future<void> trackPurchaseInitiated({
    required String productId,
    required String productType,
  }) {
    return _analytics.logEvent(
      name: 'purchase_initiated',
      parameters: {
        'product_id': productId,
        'product_type': productType,
      },
    );
  }

  @override
  Future<void> trackPurchaseCancelled({required String productId}) {
    return _analytics.logEvent(
      name: 'purchase_cancelled',
      parameters: {'product_id': productId},
    );
  }

  @override
  Future<void> trackPurchaseFailed({
    required String productId,
    String? errorCode,
  }) {
    return _analytics.logEvent(
      name: 'purchase_failed',
      parameters: {
        'product_id': productId,
        'error_code': ?errorCode,
      },
    );
  }

  @override
  Future<void> trackPremiumSubscriptionStarted() {
    return _analytics.logEvent(name: 'premium_subscription_started');
  }

  @override
  Future<void> trackCosmeticEquipped({
    required String cosmeticType,
    required String cosmeticId,
  }) {
    return _analytics.logEvent(
      name: 'cosmetic_equipped',
      parameters: {
        'cosmetic_type': cosmeticType,
        'cosmetic_id': cosmeticId,
      },
    );
  }

  @override
  Future<void> trackThemeSelected(String themeName) {
    return _analytics.logEvent(
      name: 'theme_selected',
      parameters: {'theme_name': themeName},
    );
  }

  @override
  Future<void> trackSettingChanged({
    required String settingName,
    required String value,
  }) {
    return _analytics.logEvent(
      name: 'setting_changed',
      parameters: {'setting_name': settingName, 'value': value},
    );
  }

  @override
  Future<void> trackLeaderboardViewed(String type) {
    return _analytics.logEvent(
      name: 'leaderboard_viewed',
      parameters: {'type': type},
    );
  }

  @override
  Future<void> trackFriendAdded() {
    return _analytics.logEvent(name: 'friend_added');
  }

  @override
  Future<void> trackFriendRemoved() {
    return _analytics.logEvent(name: 'friend_removed');
  }

  @override
  Future<void> trackTournamentEntered({
    required String tournamentId,
    required String tier,
  }) {
    return _analytics.logEvent(
      name: 'tournament_entered',
      parameters: {'tournament_id': tournamentId, 'tier': tier},
    );
  }

  @override
  Future<void> trackReplayViewed() {
    return _analytics.logEvent(name: 'replay_viewed');
  }

  @override
  Future<void> trackReplayShared() {
    return _analytics.logEvent(name: 'replay_shared');
  }

  @override
  Future<void> trackDailyBonusCollected() {
    return _analytics.logEvent(name: 'daily_bonus_collected');
  }

  @override
  Future<void> trackHomeTourStarted({required int version}) {
    return _analytics.logEvent(
      name: 'home_tour_started',
      parameters: {'version': version},
    );
  }

  @override
  Future<void> trackHomeTourFinished({required int version}) {
    return _analytics.logEvent(
      name: 'home_tour_finished',
      parameters: {'version': version},
    );
  }

  @override
  Future<void> trackHomeTourSkipped({required int version}) {
    return _analytics.logEvent(
      name: 'home_tour_skipped',
      parameters: {'version': version},
    );
  }

  @override
  Future<void> trackGameTutorialStarted({required String entryPoint}) {
    // logTutorialBegin has no parameters, and the entry point is the thing
    // worth knowing — a replay from Settings is a different intent from a
    // curious tap in the pause menu.
    return _analytics.logEvent(
      name: 'game_tutorial_started',
      parameters: {'entry_point': entryPoint},
    );
  }

  @override
  Future<void> trackGameTutorialFinished({required String entryPoint}) {
    return _analytics.logEvent(
      name: 'game_tutorial_finished',
      parameters: {'entry_point': entryPoint},
    );
  }

  @override
  Future<void> trackGameTutorialSkipped({required String entryPoint}) {
    return _analytics.logEvent(
      name: 'game_tutorial_skipped',
      parameters: {'entry_point': entryPoint},
    );
  }

  @override
  Future<void> trackHomeVersusCtaTapped({required String onboardingStage}) {
    return _analytics.logEvent(
      name: 'home_versus_cta_tapped',
      parameters: {'onboarding_stage': onboardingStage},
    );
  }

  @override
  Future<void> trackMultiplayerLobbyOpened({required String entryPoint}) {
    return _analytics.logEvent(
      name: 'multiplayer_lobby_opened',
      parameters: {'entry_point': entryPoint},
    );
  }

  // ==================== First-run funnel ====================

  @override
  Future<void> trackOnboardingStepShown(String step) {
    return _analytics.logEvent(
      name: 'onboarding_step_shown',
      parameters: {'step': step},
    );
  }

  @override
  Future<void> trackOnboardingStepCompleted(String step) {
    return _analytics.logEvent(
      name: 'onboarding_step_completed',
      parameters: {'step': step},
    );
  }

  @override
  Future<void> trackFirstGameStarted({required int secondsSinceInstall}) {
    return _analytics.logEvent(
      name: 'first_game_started',
      parameters: {'seconds_since_install': secondsSinceInstall},
    );
  }

  @override
  Future<void> trackScoreRejected({
    required int count,
    required String topReason,
  }) {
    return _analytics.logEvent(
      name: 'score_rejected',
      parameters: {
        'count': count,
        // Truncated: GA4 caps string parameter values at 100 characters and
        // silently drops the whole event if one is longer, which would make
        // this counter vanish exactly when a verbose new validator message
        // starts firing it.
        'top_reason': topReason.length > 90
            ? topReason.substring(0, 90)
            : topReason,
      },
    );
  }

  @override
  Future<void> trackReviewRequested(String trigger) {
    return _analytics.logEvent(
      name: 'review_requested',
      parameters: {'trigger': trigger},
    );
  }

  // ==================== Ads ====================
  // `ad_impression` is a Firebase-reserved automatic event name, so the
  // custom impression event is suffixed to avoid the collision.

  @override
  Future<void> trackAdImpression({required String format, String? placement}) {
    return _analytics.logEvent(
      name: 'ad_impression_custom',
      parameters: {'format': format, 'placement': ?placement},
    );
  }

  @override
  Future<void> trackRewardedCompleted(String placement) {
    return _analytics.logEvent(
      name: 'rewarded_ad_completed',
      parameters: {'placement': placement},
    );
  }

  @override
  Future<void> trackRewardedAbandoned(String placement) {
    return _analytics.logEvent(
      name: 'rewarded_ad_abandoned',
      parameters: {'placement': placement},
    );
  }

  @override
  Future<void> trackAdRevenue({
    required String format,
    required double valueMicros,
    required String currencyCode,
    required String precision,
  }) {
    return _analytics.logEvent(
      name: 'ad_revenue',
      parameters: {
        'format': format,
        'value_micros': valueMicros,
        'currency': currencyCode,
        'precision': precision,
      },
    );
  }

  @override
  Future<void> trackGameOverAd({required String outcome}) {
    return _analytics.logEvent(
      name: 'game_over_ad',
      parameters: {'outcome': outcome},
    );
  }

  @override
  Future<void> trackAdLoadStats({
    required String format,
    required int requests,
    required int filled,
    required int failed,
    required int refreshOk,
    required int refreshFailed,
    required String codes,
    String? lastError,
  }) {
    // Firebase caps string parameter values at 100 characters.
    String cap(String s) => s.length <= 100 ? s : s.substring(0, 100);
    return _analytics.logEvent(
      name: 'ad_load_stats',
      parameters: {
        'format': format,
        'requests': requests,
        'filled': filled,
        'failed': failed,
        'refresh_ok': refreshOk,
        'refresh_failed': refreshFailed,
        'codes': cap(codes),
        if (lastError != null) 'last_error': cap(lastError),
      },
    );
  }

  // ==================== Generic (retention analytics) ====================

  @override
  Future<void> trackEvent(String name, Map<String, Object> parameters) {
    // GA4 caps string parameter values at 100 characters.
    final safe = parameters.map(
      (k, v) => MapEntry(
        k,
        v is String && v.length > 100 ? v.substring(0, 100) : v,
      ),
    );
    return _analytics.logEvent(name: name, parameters: safe);
  }

  @override
  Future<void> setUserProperty(String name, String? value) =>
      _analytics.setUserProperty(name: name, value: value);
}
