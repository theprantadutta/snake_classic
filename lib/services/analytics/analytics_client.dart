/// Abstract analytics interface.
///
/// All analytics tracking goes through this contract so we can swap
/// implementations (Firebase, console logger, Amplitude, etc.) without
/// touching feature code.
abstract class AnalyticsClient {
  // ==================== App Lifecycle ====================

  Future<void> setUserId(String? userId);
  Future<void> setUserProperties({String? authMethod, bool? isPremium});
  Future<void> trackAppOpened();

  // ==================== Screen Views ====================

  Future<void> trackScreenView(String screenName);

  // ==================== Auth ====================

  Future<void> trackSignInGoogle();
  Future<void> trackSignInApple();
  Future<void> trackSignInAnonymous();
  Future<void> trackSignInEmail();
  Future<void> trackSignOut();
  Future<void> trackUsernameSet();

  // ==================== Core Gameplay ====================

  Future<void> trackGameStarted({
    required int boardWidth,
    required int boardHeight,
    required String gameMode,
  });
  Future<void> trackGamePaused();
  Future<void> trackGameResumed();
  Future<void> trackGameOver({
    required int score,
    required int level,
    required int durationSeconds,
    required String cause,
    required int foodEaten,
    required int powerUpsCollected,
    required int maxCombo,
    required bool isNewHighScore,
  });
  Future<void> trackLevelUp(int level);
  Future<void> trackPowerUpUsed(String powerUpType);

  // ==================== Multiplayer ====================

  Future<void> trackMultiplayerQueueJoined();
  Future<void> trackMultiplayerGameStarted();
  Future<void> trackMultiplayerGameEnded({
    required int score,
    required String result,
  });

  // ==================== Progression ====================

  Future<void> trackAchievementUnlocked({
    required String achievementId,
    required String achievementName,
  });
  Future<void> trackDailyChallengeCompleted(String challengeId);
  Future<void> trackDailyChallengeRewardClaimed();
  Future<void> trackBattlePassTierReached(int tier);
  Future<void> trackBattlePassRewardClaimed({
    required int tier,
    required String rewardType,
  });

  // ==================== Monetization ====================

  Future<void> trackStoreTabViewed(String tabName);
  Future<void> trackItemPurchased({
    required String itemId,
    required String itemType,
    required String price,
  });

  /// User tapped a buy button — Google Play sheet is about to open.
  /// Fires before [trackItemPurchased] succeeds; gap between the two events
  /// is the IAP-sheet abandonment funnel stage.
  Future<void> trackPurchaseInitiated({
    required String productId,
    required String productType,
  });

  /// User cancelled the IAP sheet (Google Play returned `userCancelled`).
  Future<void> trackPurchaseCancelled({required String productId});

  /// IAP failed for a reason other than user cancellation (network, billing
  /// error, item unavailable, etc.). [errorCode] is the platform error code
  /// when available.
  Future<void> trackPurchaseFailed({
    required String productId,
    String? errorCode,
  });

  Future<void> trackPremiumSubscriptionStarted();
  Future<void> trackCosmeticEquipped({
    required String cosmeticType,
    required String cosmeticId,
  });
  Future<void> trackThemeSelected(String themeName);

  // ==================== Settings ====================

  Future<void> trackSettingChanged({
    required String settingName,
    required String value,
  });

  // ==================== Social ====================

  Future<void> trackLeaderboardViewed(String type);
  Future<void> trackFriendAdded();
  Future<void> trackFriendRemoved();
  Future<void> trackTournamentEntered({
    required String tournamentId,
    required String tier,
  });
  Future<void> trackReplayViewed();
  Future<void> trackReplayShared();

  // ==================== Engagement ====================

  Future<void> trackDailyBonusCollected();
  Future<void> trackWalkthroughStarted();
  Future<void> trackWalkthroughCompleted();

  // ==================== First-run funnel ====================
  //
  // The onboarding funnel is the single biggest lever on D1 retention, and
  // until these events existed we could only see its endpoints (`first_open`
  // and `game_started`) — never WHERE inside it people left. [step] is a
  // stable snake_case id (`legal`, `auth`, `username`, `home`), so a GA4
  // funnel over `onboarding_step_shown` → `onboarding_step_completed` shows
  // the drop between any two gates.

  /// A first-run gate was presented to the user.
  Future<void> trackOnboardingStepShown(String step);

  /// A first-run gate was cleared (accepted / signed in / dismissed).
  Future<void> trackOnboardingStepCompleted(String step);

  /// The player started their very first game on this install. [secondsSinceInstall]
  /// is wall-clock time from first launch to the first tick of gameplay — the
  /// metric to drive down. Fires at most once per install.
  Future<void> trackFirstGameStarted({required int secondsSinceInstall});

  /// Fires when ReviewService dispatches a `requestReview()` to the native
  /// platform. [trigger] is the human-readable name of the moment that
  /// caused the request (e.g. `newHighScore`). The platform does not report
  /// whether a dialog actually rendered, so this is the closest signal we
  /// have to "how often do we ask."
  Future<void> trackReviewRequested(String trigger);

  // ==================== Ads ====================

  /// An ad was actually shown: a full-screen ad presented, or a banner filled.
  /// [format] is one of `banner` / `interstitial` / `rewarded` / `app_open`;
  /// [placement] identifies the rewarded/interstitial spot when known
  /// (e.g. `revive`, `game_over`).
  Future<void> trackAdImpression({required String format, String? placement});

  /// User watched a rewarded ad to completion and the reward was granted.
  Future<void> trackRewardedCompleted(String placement);

  /// User opened a rewarded ad but dismissed it before earning the reward.
  Future<void> trackRewardedAbandoned(String placement);

  /// AdMob paid event (per-impression revenue). [valueMicros] is in
  /// micro-units of [currencyCode]; [precision] is the AdMob precision tier
  /// (`unknown` / `estimated` / `publisherProvided` / `precise`).
  Future<void> trackAdRevenue({
    required String format,
    required double valueMicros,
    required String currencyCode,
    required String precision,
  });
}
