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
    required String controlScheme,
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
    required int inputsAccepted,
    required int inputsRejected,
    String endTrigger = 'other',
  });
  /// A single-player run left before it ended: [reason] is `quit` (exit to
  /// menu) or `restart` (pause-menu restart). [runNumber] is lifetime, so
  /// 1 = the player's first game ever.
  Future<void> trackGameAbandoned({
    required String reason,
    required int score,
    required int durationSeconds,
    required int runNumber,
    required String gameMode,
  });
  /// The app left the foreground during a single-player run (once per run).
  /// Runs that never reach game_over or game_abandoned and carry this event
  /// were most likely closed from the background.
  Future<void> trackGameBackgrounded({
    required int score,
    required int durationSeconds,
    required int runNumber,
  });
  /// A push was tapped. [type] is the payload's `type` (daily_challenge,
  /// streak_at_risk, high_score_nudge, win_back, challenge_announcement, ...)
  /// so open rate can be read per push type against the server's
  /// notification_histories counts; GA's automatic notification_open has no
  /// type. [ageMinutes] is from the payload's `sent_at`, -1 when absent.
  Future<void> trackPushOpened({
    required String type,
    required bool coldStart,
    required int ageMinutes,
  });
  /// One-time event theme announcement: action is shown / accepted /
  /// dismissed.
  Future<void> trackThemePromo({required String action});
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
    double? value,
    String? currency,
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
  /// The short Home coach-mark tour. Finished and skipped are separate
  /// events on purpose: the old code recorded "completed" for both, which is
  /// the one distinction the tour's length was being judged on.
  ///
  /// [version] is the tour's content version, so a re-cut tour's numbers are
  /// not silently compared against the old one's.
  Future<void> trackHomeTourStarted({required int version});
  Future<void> trackHomeTourFinished({required int version});
  Future<void> trackHomeTourSkipped({required int version});

  /// The optional in-game tutorial. [entryPoint] is `pause` or
  /// `settings_replay` — two deliberate, differently-motivated openings that
  /// were previously indistinguishable.
  Future<void> trackGameTutorialStarted({required String entryPoint});
  Future<void> trackGameTutorialFinished({required String entryPoint});
  Future<void> trackGameTutorialSkipped({required String entryPoint});

  /// The Home Versus call to action. [onboardingStage] is `onboarding` or
  /// `established` — whether the player is still inside the first-run window.
  Future<void> trackHomeVersusCtaTapped({required String onboardingStage});

  /// The multiplayer lobby was opened. [entryPoint] is `home_versus` or
  /// `nav_tile`, which is the whole point of adding the CTA: knowing whether
  /// it is what brought people here.
  Future<void> trackMultiplayerLobbyOpened({required String entryPoint});

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

  /// The backend permanently refused [count] queued score(s), which have been
  /// moved to the local dead-letter store.
  ///
  /// This should be rare, and a cluster of it means something systemic — a
  /// validator change, a client/server version skew, a bad release. Without a
  /// counter the only trace is a table on the player's own device, which
  /// nobody will ever think to look at. [topReason] carries the most common
  /// explanation so the event is actionable on its own.
  Future<void> trackScoreRejected({
    required int count,
    required String topReason,
  });

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

  /// One session's ad load outcomes for [format], sent on backgrounding by
  /// `AdLoadStats`. [codes] is `code:count` pairs, most frequent first
  /// (`3` no fill, `2` network, `1` invalid request, `0` internal);
  /// [refreshOk] / [refreshFailed] are banner auto-refreshes of an ad
  /// already on screen; [lastError] is the most recent failure message.
  /// What the game-over ad slot did on one game over, or the rule that kept
  /// it empty. [outcome] is one of GameOverAdReason (game_over_ad_gate.dart).
  Future<void> trackGameOverAd({required String outcome});

  Future<void> trackAdLoadStats({
    required String format,
    required int requests,
    required int filled,
    required int failed,
    required int refreshOk,
    required int refreshFailed,
    required String codes,
    String? lastError,
  });

  // ==================== Daily-bonus items & cosmetic trials ====================
  // (retention-cosmetics, 2026-11)

  /// A daily login bonus item was actually granted. [item] is
  /// `speed_boost`, `xp_boost` or `theme_day`; [day] is the bonus day (1-7).
  Future<void> trackDailyBonusItemGranted({
    required String item,
    required int day,
  });

  /// "Watch 2 ads, wear it for a day". [stage] is `ad_1_done`, `unlocked`
  /// or `expired`; [cosmeticType] is `theme`, `skin` or `trail`.
  Future<void> trackCosmeticTrial({
    required String stage,
    required String cosmeticType,
    required String cosmeticId,
  });

  /// The daily-bonus 2x Season XP boost. [stage] is `activated` or `expired`.
  Future<void> trackXpBoost({required String stage});
}
