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
  Future<void> trackSignInAnonymous();
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
  Future<void> trackPremiumSubscriptionStarted();
  Future<void> trackPremiumTrialStarted();
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
}
