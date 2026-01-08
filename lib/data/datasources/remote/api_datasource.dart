import 'package:snake_classic/services/api_service.dart';

/// Exception thrown when an API call fails
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() =>
      'ApiException: $message${statusCode != null ? ' (status: $statusCode)' : ''}';
}

/// Data source for remote API operations
/// Wraps ApiService and throws exceptions on failure for repository error handling
class ApiDataSource {
  final ApiService _apiService;

  ApiDataSource(this._apiService);

  // ==================== Authentication ====================

  /// Check if authenticated with backend
  bool get isAuthenticated => _apiService.isAuthenticated;

  /// Get current user ID from backend
  String? get currentUserId => _apiService.currentUserId;

  /// Authenticate with Firebase token
  Future<Map<String, dynamic>> authenticateWithFirebase(
    String firebaseIdToken,
  ) async {
    final result = await _apiService.authenticateWithFirebase(firebaseIdToken);
    if (result == null) {
      throw ApiException('Authentication failed');
    }
    return result;
  }

  /// Get current user info
  Future<Map<String, dynamic>> getCurrentUser() async {
    final result = await _apiService.getCurrentUser();
    if (result == null) {
      throw ApiException('Failed to get current user');
    }
    return result;
  }

  /// Logout from backend
  Future<bool> logout() async {
    return await _apiService.logout();
  }

  /// Clear stored token
  Future<void> clearToken() async {
    await _apiService.clearToken();
  }

  // ==================== Users ====================

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile(String userId) async {
    final result = await _apiService.getUserProfile(userId);
    if (result == null) {
      throw ApiException('Failed to get user profile');
    }
    return result;
  }

  /// Update current user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    final result = await _apiService.updateProfile(data);
    if (result == null) {
      throw ApiException('Failed to update profile');
    }
    return result;
  }

  /// Check username availability
  Future<Map<String, dynamic>> checkUsername(String username) async {
    final result = await _apiService.checkUsername(username);
    if (result == null) {
      throw ApiException('Failed to check username');
    }
    return result;
  }

  /// Set/update username
  Future<Map<String, dynamic>> setUsername(String username) async {
    final result = await _apiService.setUsername(username);
    if (result == null) {
      throw ApiException('Failed to set username');
    }
    return result;
  }

  /// Search users
  Future<List<Map<String, dynamic>>> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    final result = await _apiService.searchUsers(query, limit: limit);
    if (result == null) {
      throw ApiException('Failed to search users');
    }
    return result;
  }

  // ==================== Scores ====================

  /// Submit a score
  Future<Map<String, dynamic>> submitScore({
    required int score,
    int gameDuration = 0,
    int foodsEaten = 0,
    String gameMode = 'classic',
    String difficulty = 'normal',
    Map<String, dynamic>? gameData,
    DateTime? playedAt,
    String? idempotencyKey,
  }) async {
    final result = await _apiService.submitScore(
      score: score,
      gameDuration: gameDuration,
      foodsEaten: foodsEaten,
      gameMode: gameMode,
      difficulty: difficulty,
      gameData: gameData,
      playedAt: playedAt,
      idempotencyKey: idempotencyKey,
    );
    if (result == null) {
      throw ApiException('Failed to submit score');
    }
    return result;
  }

  /// Submit multiple scores in batch (for offline sync)
  Future<Map<String, dynamic>> submitScoresBatch(
    List<Map<String, dynamic>> scores,
  ) async {
    final result = await _apiService.submitScoresBatch(scores);
    if (result == null) {
      throw ApiException('Failed to submit scores batch');
    }
    return result;
  }

  /// Get user's scores
  Future<List<Map<String, dynamic>>> getUserScores({
    String? gameMode,
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await _apiService.getUserScores(
      gameMode: gameMode,
      limit: limit,
      offset: offset,
    );
    if (result == null) {
      throw ApiException('Failed to get user scores');
    }
    return result;
  }

  /// Get user's score stats
  Future<Map<String, dynamic>> getUserScoreStats() async {
    final result = await _apiService.getUserScoreStats();
    if (result == null) {
      throw ApiException('Failed to get score stats');
    }
    return result;
  }

  // ==================== Leaderboard ====================

  /// Get global leaderboard
  Future<Map<String, dynamic>> getGlobalLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    final result = await _apiService.getGlobalLeaderboard(
      gameMode: gameMode,
      difficulty: difficulty,
      page: page,
      pageSize: pageSize,
    );
    if (result == null) {
      throw ApiException('Failed to get global leaderboard');
    }
    return result;
  }

  /// Get weekly leaderboard
  Future<Map<String, dynamic>> getWeeklyLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    final result = await _apiService.getWeeklyLeaderboard(
      gameMode: gameMode,
      difficulty: difficulty,
      page: page,
      pageSize: pageSize,
    );
    if (result == null) {
      throw ApiException('Failed to get weekly leaderboard');
    }
    return result;
  }

  /// Get daily leaderboard
  Future<Map<String, dynamic>> getDailyLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    final result = await _apiService.getDailyLeaderboard(
      gameMode: gameMode,
      difficulty: difficulty,
      page: page,
      pageSize: pageSize,
    );
    if (result == null) {
      throw ApiException('Failed to get daily leaderboard');
    }
    return result;
  }

  /// Get friends leaderboard
  Future<Map<String, dynamic>> getFriendsLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    final result = await _apiService.getFriendsLeaderboard(
      gameMode: gameMode,
      difficulty: difficulty,
      page: page,
      pageSize: pageSize,
    );
    if (result == null) {
      throw ApiException('Failed to get friends leaderboard');
    }
    return result;
  }

  // ==================== Achievements ====================

  /// Get all achievements
  Future<List<Map<String, dynamic>>> getAllAchievements() async {
    final result = await _apiService.getAllAchievements();
    if (result == null) {
      throw ApiException('Failed to get achievements');
    }
    return result;
  }

  /// Get user's achievements
  Future<Map<String, dynamic>> getUserAchievements() async {
    final result = await _apiService.getUserAchievements();
    if (result == null) {
      throw ApiException('Failed to get user achievements');
    }
    return result;
  }

  /// Update achievement progress
  Future<Map<String, dynamic>> updateAchievementProgress({
    required String achievementId,
    int progressIncrement = 1,
  }) async {
    final result = await _apiService.updateAchievementProgress(
      achievementId: achievementId,
      progressIncrement: progressIncrement,
    );
    if (result == null) {
      throw ApiException('Failed to update achievement progress');
    }
    return result;
  }

  // ==================== Social ====================

  /// Get friends list
  Future<Map<String, dynamic>> getFriends() async {
    final result = await _apiService.getFriends();
    if (result == null) {
      throw ApiException('Failed to get friends');
    }
    return result;
  }

  /// Get pending friend requests
  Future<Map<String, dynamic>> getPendingRequests() async {
    final result = await _apiService.getPendingRequests();
    if (result == null) {
      throw ApiException('Failed to get pending requests');
    }
    return result;
  }

  /// Send friend request
  Future<Map<String, dynamic>> sendFriendRequest({
    String? username,
    String? userId,
  }) async {
    final result = await _apiService.sendFriendRequest(
      username: username,
      userId: userId,
    );
    if (result == null) {
      throw ApiException('Failed to send friend request');
    }
    return result;
  }

  /// Accept friend request
  Future<Map<String, dynamic>> acceptFriendRequest(String requestId) async {
    final result = await _apiService.acceptFriendRequest(requestId);
    if (result == null) {
      throw ApiException('Failed to accept friend request');
    }
    return result;
  }

  /// Reject friend request
  Future<Map<String, dynamic>> rejectFriendRequest(String requestId) async {
    final result = await _apiService.rejectFriendRequest(requestId);
    if (result == null) {
      throw ApiException('Failed to reject friend request');
    }
    return result;
  }

  /// Remove friend
  Future<Map<String, dynamic>> removeFriend(String friendId) async {
    final result = await _apiService.removeFriend(friendId);
    if (result == null) {
      throw ApiException('Failed to remove friend');
    }
    return result;
  }

  // ==================== Tournaments ====================

  /// List tournaments
  Future<Map<String, dynamic>> listTournaments({
    String? status,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await _apiService.listTournaments(
      status: status,
      type: type,
      limit: limit,
      offset: offset,
    );
    if (result == null) {
      throw ApiException('Failed to list tournaments');
    }
    return result;
  }

  /// Get tournament details
  Future<Map<String, dynamic>> getTournament(String tournamentId) async {
    final result = await _apiService.getTournament(tournamentId);
    if (result == null) {
      throw ApiException('Failed to get tournament');
    }
    return result;
  }

  /// Join tournament
  Future<Map<String, dynamic>> joinTournament(String tournamentId) async {
    final result = await _apiService.joinTournament(tournamentId);
    if (result == null) {
      throw ApiException('Failed to join tournament');
    }
    return result;
  }

  /// Submit tournament score
  Future<Map<String, dynamic>> submitTournamentScore({
    required String tournamentId,
    required int score,
    int gameDuration = 0,
    int foodsEaten = 0,
  }) async {
    final result = await _apiService.submitTournamentScore(
      tournamentId: tournamentId,
      score: score,
      gameDuration: gameDuration,
      foodsEaten: foodsEaten,
    );
    if (result == null) {
      throw ApiException('Failed to submit tournament score');
    }
    return result;
  }

  /// Get tournament leaderboard
  Future<Map<String, dynamic>> getTournamentLeaderboard(
    String tournamentId, {
    int limit = 50,
    int offset = 0,
  }) async {
    final result = await _apiService.getTournamentLeaderboard(
      tournamentId,
      limit: limit,
      offset: offset,
    );
    if (result == null) {
      throw ApiException('Failed to get tournament leaderboard');
    }
    return result;
  }

  // ==================== Multiplayer ====================

  /// Create multiplayer game
  Future<Map<String, dynamic>> createMultiplayerGame({
    String mode = 'classic',
    int maxPlayers = 4,
    int gridSize = 20,
    int speed = 100,
  }) async {
    final result = await _apiService.createMultiplayerGame(
      mode: mode,
      maxPlayers: maxPlayers,
      gridSize: gridSize,
      speed: speed,
    );
    if (result == null) {
      throw ApiException('Failed to create multiplayer game');
    }
    return result;
  }

  /// Join multiplayer game by code
  Future<Map<String, dynamic>> joinMultiplayerGame(String roomCode) async {
    final result = await _apiService.joinMultiplayerGame(roomCode);
    if (result == null) {
      throw ApiException('Failed to join multiplayer game');
    }
    return result;
  }

  /// Get current multiplayer game
  Future<Map<String, dynamic>> getCurrentMultiplayerGame() async {
    final result = await _apiService.getCurrentMultiplayerGame();
    if (result == null) {
      throw ApiException('Failed to get current game');
    }
    return result;
  }

  /// Get WebSocket URL for multiplayer
  String getMultiplayerWebSocketUrl(String gameId) {
    return _apiService.getMultiplayerWebSocketUrl(gameId);
  }

  // ==================== Purchases ====================

  /// Verify purchase
  Future<Map<String, dynamic>> verifyPurchase({
    required String platform,
    required String receiptData,
    required String productId,
    required String transactionId,
    String? purchaseToken,
    DateTime? purchaseTime,
  }) async {
    final result = await _apiService.verifyPurchase(
      platform: platform,
      receiptData: receiptData,
      productId: productId,
      transactionId: transactionId,
      purchaseToken: purchaseToken,
      purchaseTime: purchaseTime,
    );
    if (result == null) {
      throw ApiException('Failed to verify purchase');
    }
    return result;
  }

  /// Get premium content
  Future<Map<String, dynamic>> getPremiumContent() async {
    final result = await _apiService.getPremiumContent();
    if (result == null) {
      throw ApiException('Failed to get premium content');
    }
    return result;
  }

  // ==================== Battle Pass ====================

  /// Get current battle pass season
  Future<Map<String, dynamic>> getCurrentBattlePassSeason() async {
    final result = await _apiService.getCurrentBattlePassSeason();
    if (result == null) {
      throw ApiException('Failed to get battle pass season');
    }
    return result;
  }

  /// Get battle pass progress
  Future<Map<String, dynamic>> getBattlePassProgress() async {
    final result = await _apiService.getBattlePassProgress();
    if (result == null) {
      throw ApiException('Failed to get battle pass progress');
    }
    return result;
  }

  /// Add battle pass XP
  Future<Map<String, dynamic>> addBattlePassXP({
    required int xp,
    String source = 'gameplay',
  }) async {
    final result = await _apiService.addBattlePassXP(xp: xp, source: source);
    if (result == null) {
      throw ApiException('Failed to add battle pass XP');
    }
    return result;
  }

  /// Claim battle pass reward
  Future<Map<String, dynamic>> claimBattlePassReward({
    required int level,
    required String tier,
  }) async {
    final result = await _apiService.claimBattlePassReward(
      level: level,
      tier: tier,
    );
    if (result == null) {
      throw ApiException('Failed to claim battle pass reward');
    }
    return result;
  }

  // ==================== Notifications ====================

  /// Register FCM token
  Future<bool> registerFcmToken({
    required String fcmToken,
    String platform = 'flutter',
  }) async {
    return await _apiService.registerFcmToken(
      fcmToken: fcmToken,
      platform: platform,
    );
  }

  /// Subscribe to notification topic
  Future<bool> subscribeToTopic(String fcmToken, String topic) async {
    return await _apiService.subscribeToTopic(fcmToken, topic);
  }

  /// Unsubscribe from notification topic
  Future<bool> unsubscribeFromTopic(String fcmToken, String topic) async {
    return await _apiService.unsubscribeFromTopic(fcmToken, topic);
  }

  // ==================== Health Check ====================

  /// Check backend health
  Future<bool> checkHealth() async {
    return await _apiService.checkHealth();
  }
}
