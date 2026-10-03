import 'dart:async';

import 'package:snake_classic/services/analytics/analytics_client.dart';
import 'package:snake_classic/services/telemetry/design_feedback.dart';
import 'package:snake_classic/services/telemetry/telemetry_session_tracker.dart';

/// Feeds the design-metrics session counters from the analytics events the
/// app already emits.
///
/// Registered on the [AnalyticsFacade] next to the Firebase / logger client,
/// in debug and release alike, so not one gameplay, ad or purchase call site
/// had to change — and so this module cherry-picks onto the classic branch,
/// whose facade emits the same events, without touching its UI.
///
/// Event → counter map (the rest of the interface is a deliberate no-op):
///   * game_started → runs_started, runs_again
///   * game_paused / game_resumed → excluded from run_ms and the again gap
///   * game_over → runs_finished, best_score, total_score, run_ms, plus the
///     install's finished-run count for the feedback question
///   * multiplayer_game_ended → multiplayer_matches (fires for both players;
///     the "started" event fires for the host only)
///   * ad impression → ad_impressions_* by format
///   * rewarded completed / abandoned → rewarded_*
///   * ad revenue → ad_revenue_micros
///   * purchase initiated → purchases_started
///   * item purchased → purchases_completed
///   * screen view `store` → store_views
///
/// Every handler applies its change synchronously (see
/// [TelemetrySessionTracker] for why) and never throws.
class TelemetryAnalyticsClient implements AnalyticsClient {
  TelemetryAnalyticsClient({
    required this._tracker,
    required this._feedbackStore,
  });

  /// The store's GoRoute name — what AnalyticsRouteObserver reports as the
  /// screen view. Nothing is pushed on top of the store, so each view is one
  /// visit.
  static const String storeScreenName = 'store';

  final TelemetrySessionTracker _tracker;
  final DesignFeedbackStore _feedbackStore;

  // ==================== Counted ====================

  @override
  Future<void> trackScreenView(String screenName) async {
    if (screenName == storeScreenName) _tracker.storeViewed();
  }

  @override
  Future<void> trackGameStarted({
    required int boardWidth,
    required int boardHeight,
    required String gameMode,
    required String controlScheme,
  }) async =>
      _tracker.runStarted();

  @override
  Future<void> trackGamePaused() async => _tracker.runPaused();

  @override
  Future<void> trackGameResumed() async => _tracker.runResumed();

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
  }) async {
    _tracker.runFinished(score: score, durationSeconds: durationSeconds);
    unawaited(_feedbackStore.recordFinishedRun());
  }

  @override
  Future<void> trackMultiplayerGameEnded({
    required int score,
    required String result,
  }) async =>
      _tracker.multiplayerMatchEnded();

  @override
  Future<void> trackAdImpression({
    required String format,
    String? placement,
  }) async =>
      _tracker.adImpression(format);

  @override
  Future<void> trackRewardedCompleted(String placement) async =>
      _tracker.rewardedCompleted();

  @override
  Future<void> trackRewardedAbandoned(String placement) async =>
      _tracker.rewardedAbandoned();

  @override
  Future<void> trackAdRevenue({
    required String format,
    required double valueMicros,
    required String currencyCode,
    required String precision,
  }) async =>
      _tracker.adRevenue(valueMicros);

  @override
  Future<void> trackPurchaseInitiated({
    required String productId,
    required String productType,
  }) async =>
      _tracker.purchaseStarted();

  @override
  Future<void> trackItemPurchased({
    required String itemId,
    required String itemType,
    required String price,
  }) async =>
      _tracker.purchaseCompleted();

  // ==================== Not counted ====================

  @override
  Future<void> setUserId(String? userId) async {}

  @override
  Future<void> setUserProperties({String? authMethod, bool? isPremium}) async {}

  @override
  Future<void> trackAppOpened() async {}

  @override
  Future<void> trackSignInGoogle() async {}

  @override
  Future<void> trackSignInApple() async {}

  @override
  Future<void> trackSignInAnonymous() async {}

  @override
  Future<void> trackSignInEmail() async {}

  @override
  Future<void> trackSignOut() async {}

  @override
  Future<void> trackUsernameSet() async {}

  @override
  Future<void> trackLevelUp(int level) async {}

  @override
  Future<void> trackPowerUpUsed(String powerUpType) async {}

  @override
  Future<void> trackMultiplayerQueueJoined() async {}

  @override
  Future<void> trackMultiplayerGameStarted() async {}

  @override
  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  }) async {}

  @override
  Future<void> trackDailyChallengeCompleted(String challengeId) async {}

  @override
  Future<void> trackDailyChallengeRewardClaimed() async {}

  @override
  Future<void> trackBattlePassTierReached(int tier) async {}

  @override
  Future<void> trackBattlePassRewardClaimed({
    required int tier,
    required String rewardType,
  }) async {}

  @override
  Future<void> trackStoreTabViewed(String tabName) async {}

  @override
  Future<void> trackPurchaseCancelled({required String productId}) async {}

  @override
  Future<void> trackPurchaseFailed({
    required String productId,
    String? errorCode,
  }) async {}

  @override
  Future<void> trackPremiumSubscriptionStarted() async {}

  @override
  Future<void> trackCosmeticEquipped({
    required String cosmeticType,
    required String cosmeticId,
  }) async {}

  @override
  Future<void> trackThemeSelected(String themeName) async {}

  @override
  Future<void> trackSettingChanged({
    required String settingName,
    required String value,
  }) async {}

  @override
  Future<void> trackLeaderboardViewed(String type) async {}

  @override
  Future<void> trackFriendAdded() async {}

  @override
  Future<void> trackFriendRemoved() async {}

  @override
  Future<void> trackTournamentEntered({
    required String tournamentId,
    required String tier,
  }) async {}

  @override
  Future<void> trackReplayViewed() async {}

  @override
  Future<void> trackReplayShared() async {}

  @override
  Future<void> trackDailyBonusCollected() async {}

  @override
  Future<void> trackHomeTourStarted({required int version}) async {}

  @override
  Future<void> trackHomeTourFinished({required int version}) async {}

  @override
  Future<void> trackHomeTourSkipped({required int version}) async {}

  @override
  Future<void> trackGameTutorialStarted({required String entryPoint}) async {}

  @override
  Future<void> trackGameTutorialFinished({required String entryPoint}) async {}

  @override
  Future<void> trackGameTutorialSkipped({required String entryPoint}) async {}

  @override
  Future<void> trackHomeVersusCtaTapped({
    required String onboardingStage,
  }) async {}

  @override
  Future<void> trackMultiplayerLobbyOpened({required String entryPoint}) async {}

  @override
  Future<void> trackOnboardingStepShown(String step) async {}

  @override
  Future<void> trackOnboardingStepCompleted(String step) async {}

  @override
  Future<void> trackFirstGameStarted({required int secondsSinceInstall}) async {}

  @override
  Future<void> trackReviewRequested(String trigger) async {}

  @override
  Future<void> trackScoreRejected({
    required int count,
    required String topReason,
  }) async {}
}
