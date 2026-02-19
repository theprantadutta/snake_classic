import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// API Service with JWT authentication for backend communication
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // Token storage keys
  static const String _tokenKey = 'jwt_access_token';
  static const String _userIdKey = 'backend_user_id';

  // Cached token
  String? _accessToken;
  String? _userId;

  // Callback for unauthorized responses
  VoidCallback? onUnauthorized;

  // Backend configuration
  static String get baseUrl {
    final String backendUrl;
    if (kDebugMode) {
      backendUrl = dotenv.env['API_BACKEND_URL'] ?? 'http://192.168.0.141:8393';
    } else {
      backendUrl = 'https://snakeclassic.pranta.dev';
    }
    return '$backendUrl/api/v1';
  }

  static const Duration _timeout = Duration(seconds: 15);

  /// Initialize the API service - load stored token
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_tokenKey);
      _userId = prefs.getString(_userIdKey);
      if (_accessToken != null) {
        AppLogger.network('Loaded stored JWT token');
      }
    } catch (e) {
      AppLogger.error('Error loading stored token', e);
    }
  }

  /// Check if user is authenticated with backend
  bool get isAuthenticated => _accessToken != null;

  /// Get current user ID from backend
  String? get currentUserId => _userId;

  /// Get stored access token
  String? get accessToken => _accessToken;

  /// Check if the JWT token is expired or about to expire (within 5 minutes).
  /// Returns true if the token should be refreshed.
  bool get isTokenExpiredOrExpiring {
    if (_accessToken == null) return true;
    try {
      // JWT format: header.payload.signature
      final parts = _accessToken!.split('.');
      if (parts.length != 3) return true;

      // Decode the payload (base64url)
      String payload = parts[1];
      // Add padding if needed
      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }
      final decoded = utf8.decode(base64Url.decode(payload));
      final claims = jsonDecode(decoded) as Map<String, dynamic>;

      final exp = claims['exp'] as int?;
      if (exp == null) return true;

      final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      // Consider expired if within 5 minutes of expiry
      return DateTime.now().isAfter(
        expiry.subtract(const Duration(minutes: 5)),
      );
    } catch (e) {
      // If we can't decode the token, treat as expired
      return true;
    }
  }

  /// Store JWT token
  Future<void> _storeToken(String token, String userId) async {
    _accessToken = token;
    _userId = userId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_userIdKey, userId);
    } catch (e) {
      AppLogger.error('Error storing token', e);
    }
  }

  /// Clear stored token
  Future<void> clearToken() async {
    _accessToken = null;
    _userId = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userIdKey);
    } catch (e) {
      AppLogger.error('Error clearing token', e);
    }
  }

  /// Get authorization headers
  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

  /// Handle response - check for auth errors.
  /// On 401, clears the token and invokes the [onUnauthorized] callback.
  /// Callers that want automatic retry should use [_authenticatedRequest].
  Map<String, dynamic>? _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      AppLogger.error('Unauthorized - token may be expired');
      clearToken();
      onUnauthorized?.call();
      return null;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return {};
      final decoded = jsonDecode(response.body);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return {'data': decoded};
    }

    AppLogger.error(
      'API error: ${response.statusCode} from ${response.request?.url}',
      response.body,
    );
    return null;
  }

  // ==================== Authentication ====================

  /// Authenticate with Firebase token
  Future<Map<String, dynamic>?> authenticateWithFirebase(
    String firebaseIdToken,
  ) async {
    try {
      AppLogger.network('Authenticating with backend using Firebase token');

      final response = await http
          .post(
            Uri.parse('$baseUrl/auth/firebase'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'firebase_token': firebaseIdToken}),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['access_token'] as String?;
        final userId = data['user_id'] as String?;

        if (token != null && userId != null) {
          await _storeToken(token, userId);
          AppLogger.success('Backend authentication successful');
          return data;
        }
      }

      AppLogger.error(
        'Backend authentication failed: ${response.statusCode}',
        response.body,
      );
      return null;
    } catch (e) {
      AppLogger.error('Error authenticating with backend', e);
      return null;
    }
  }

  /// Get current user info
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/auth/me'), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting current user', e);
      return null;
    }
  }

  /// Logout from backend
  Future<bool> logout() async {
    try {
      await http
          .post(Uri.parse('$baseUrl/auth/logout'), headers: _authHeaders)
          .timeout(_timeout);

      await clearToken();
      return true;
    } catch (e) {
      AppLogger.error('Error logging out', e);
      await clearToken();
      return false;
    }
  }

  // ==================== Users ====================

  /// Get user profile
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/users/$userId'), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting user profile', e);
      return null;
    }
  }

  /// Update current user profile
  Future<Map<String, dynamic>?> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/users/me'),
            headers: _authHeaders,
            body: jsonEncode(data),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error updating profile', e);
      return null;
    }
  }

  /// Check username availability
  Future<Map<String, dynamic>?> checkUsername(String username) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/username/check'),
            headers: _authHeaders,
            body: jsonEncode({'username': username}),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error checking username', e);
      return null;
    }
  }

  /// Suggest available usernames based on desired username (server-side)
  Future<List<String>?> suggestUsernames(
    String desiredUsername, {
    int count = 5,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/username/suggest'),
            headers: _authHeaders,
            body: jsonEncode({
              'desired_username': desiredUsername,
              'count': count,
            }),
          )
          .timeout(_timeout);

      final result = _handleResponse(response);
      if (result != null && result['suggestions'] != null) {
        return List<String>.from(result['suggestions']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error suggesting usernames', e);
      return null;
    }
  }

  /// Set/update username
  Future<Map<String, dynamic>?> setUsername(String username) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/users/username'),
            headers: _authHeaders,
            body: jsonEncode({'username': username}),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error setting username', e);
      return null;
    }
  }

  /// Search users
  Future<List<Map<String, dynamic>>?> searchUsers(
    String query, {
    int limit = 20,
  }) async {
    try {
      final encodedQuery = Uri.encodeQueryComponent(query);
      final response = await http
          .get(
            Uri.parse('$baseUrl/users/search?query=$encodedQuery&limit=$limit'),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      final data = _handleResponse(response);
      if (data != null && data['users'] != null) {
        return List<Map<String, dynamic>>.from(data['users']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error searching users', e);
      return null;
    }
  }

  /// Reset user statistics (scores, achievements, daily challenges)
  Future<Map<String, dynamic>?> resetUserStatistics() async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/me/reset-statistics'),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error resetting statistics', e);
      return null;
    }
  }

  // ==================== Scores ====================

  /// Submit a score
  Future<Map<String, dynamic>?> submitScore({
    required int score,
    int gameDuration = 0,
    int foodsEaten = 0,
    String gameMode = 'classic',
    String difficulty = 'normal',
    Map<String, dynamic>? gameData,
    DateTime? playedAt,
    String? idempotencyKey,
  }) async {
    try {
      final body = <String, dynamic>{
        'score': score,
        'game_duration_seconds': gameDuration,
        'foods_eaten': foodsEaten,
        'game_mode': gameMode,
        'difficulty': difficulty,
        'game_data': gameData,
      };

      // Add offline-first fields if provided
      if (playedAt != null) {
        body['played_at'] = playedAt.toUtc().toIso8601String();
      }
      if (idempotencyKey != null) {
        body['idempotency_key'] = idempotencyKey;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/scores'),
            headers: _authHeaders,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error submitting score', e);
      return null;
    }
  }

  /// Submit multiple scores in batch (for offline sync)
  Future<Map<String, dynamic>?> submitScoresBatch(
    List<Map<String, dynamic>> scores,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/scores/batch'),
            headers: _authHeaders,
            body: jsonEncode({'scores': scores}),
          )
          .timeout(const Duration(seconds: 30)); // Longer timeout for batch

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error submitting scores batch', e);
      return null;
    }
  }

  /// Get user's scores
  Future<List<Map<String, dynamic>>?> getUserScores({
    String? gameMode,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      String url = '$baseUrl/scores/me?limit=$limit&offset=$offset';
      if (gameMode != null) url += '&game_mode=$gameMode';

      final response = await http
          .get(Uri.parse(url), headers: _authHeaders)
          .timeout(_timeout);

      final data = _handleResponse(response);
      if (data != null && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting user scores', e);
      return null;
    }
  }

  /// Get user's score stats
  Future<Map<String, dynamic>?> getUserScoreStats() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/scores/me/stats'), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting score stats', e);
      return null;
    }
  }

  // ==================== Leaderboard ====================

  /// Get global leaderboard
  Future<Map<String, dynamic>?> getGlobalLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/leaderboard/global?game_mode=$gameMode&difficulty=$difficulty&page=$page&page_size=$pageSize',
            ),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting global leaderboard', e);
      return null;
    }
  }

  /// Get weekly leaderboard
  Future<Map<String, dynamic>?> getWeeklyLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/leaderboard/weekly?game_mode=$gameMode&difficulty=$difficulty&page=$page&page_size=$pageSize',
            ),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting weekly leaderboard', e);
      return null;
    }
  }

  /// Get daily leaderboard
  Future<Map<String, dynamic>?> getDailyLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/leaderboard/daily?game_mode=$gameMode&difficulty=$difficulty&page=$page&page_size=$pageSize',
            ),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting daily leaderboard', e);
      return null;
    }
  }

  /// Get friends leaderboard
  Future<Map<String, dynamic>?> getFriendsLeaderboard({
    String gameMode = 'classic',
    String difficulty = 'normal',
    int page = 1,
    int pageSize = 50,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/leaderboard/friends?game_mode=$gameMode&difficulty=$difficulty&page=$page&page_size=$pageSize',
            ),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting friends leaderboard', e);
      return null;
    }
  }

  // ==================== Achievements ====================

  /// Get all achievements
  Future<List<Map<String, dynamic>>?> getAllAchievements() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/achievements'), headers: _authHeaders)
          .timeout(_timeout);

      final data = _handleResponse(response);
      if (data != null && data['data'] is List) {
        return List<Map<String, dynamic>>.from(data['data']);
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting achievements', e);
      return null;
    }
  }

  /// Get user's achievements
  Future<Map<String, dynamic>?> getUserAchievements() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/achievements/me'), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting user achievements', e);
      return null;
    }
  }

  /// Update achievement progress
  Future<Map<String, dynamic>?> updateAchievementProgress({
    required String achievementId,
    int progressIncrement = 1,
  }) async {
    // Validate: API requires progress_increment >= 1
    if (progressIncrement < 1) {
      AppLogger.warning(
        'Skipping achievement update: progressIncrement must be >= 1, got $progressIncrement',
      );
      return null;
    }

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/achievements/progress'),
            headers: _authHeaders,
            body: jsonEncode({
              'achievement_id': achievementId,
              'progress_increment': progressIncrement,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error updating achievement progress', e);
      return null;
    }
  }

  /// Batch update achievement progress (single HTTP call for multiple achievements)
  Future<bool> batchUpdateAchievementProgress(
    List<Map<String, dynamic>> updates,
  ) async {
    if (updates.isEmpty) return true;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/achievements/progress/batch'),
            headers: _authHeaders,
            body: jsonEncode({
              'achievements': updates
                  .map(
                    (u) => {
                      'achievement_id': u['achievementId'],
                      'progress_increment': u['progressIncrement'],
                    },
                  )
                  .toList(),
            }),
          )
          .timeout(_timeout);

      final result = _handleResponse(response);
      return result != null;
    } catch (e) {
      AppLogger.error('Error batch updating achievement progress', e);
      return false;
    }
  }

  /// Batch update daily challenge progress (single HTTP call for multiple challenge types)
  Future<Map<String, dynamic>?> batchUpdateChallengeProgress(
    List<Map<String, dynamic>> updates,
  ) async {
    if (updates.isEmpty) return null;

    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/dailychallenges/progress/batch'),
            headers: _authHeaders,
            body: jsonEncode({'updates': updates}),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error batch updating challenge progress', e);
      return null;
    }
  }

  // ==================== Social ====================

  /// Get friends list
  Future<Map<String, dynamic>?> getFriends() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/social/friends'), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting friends', e);
      return null;
    }
  }

  /// Get pending friend requests
  Future<Map<String, dynamic>?> getPendingRequests() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/social/requests'), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting pending requests', e);
      return null;
    }
  }

  /// Send friend request
  Future<Map<String, dynamic>?> sendFriendRequest({
    String? username,
    String? userId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/social/friends/request'),
            headers: _authHeaders,
            body: jsonEncode({
              'friend_username': username,
              'friend_user_id': userId,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error sending friend request', e);
      return null;
    }
  }

  /// Accept friend request
  Future<Map<String, dynamic>?> acceptFriendRequest(String requestId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/social/friends/accept/$requestId'),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error accepting friend request', e);
      return null;
    }
  }

  /// Reject friend request
  Future<Map<String, dynamic>?> rejectFriendRequest(String requestId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/social/friends/reject/$requestId'),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error rejecting friend request', e);
      return null;
    }
  }

  /// Remove friend
  Future<Map<String, dynamic>?> removeFriend(String friendId) async {
    try {
      final response = await http
          .delete(
            Uri.parse('$baseUrl/social/friends/$friendId'),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error removing friend', e);
      return null;
    }
  }

  // ==================== Tournaments ====================

  /// List tournaments
  Future<Map<String, dynamic>?> listTournaments({
    String? status,
    String? type,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      String url = '$baseUrl/tournaments?limit=$limit&offset=$offset';
      if (status != null) url += '&status=$status';
      if (type != null) url += '&type=$type';

      final response = await http
          .get(Uri.parse(url), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error listing tournaments', e);
      return null;
    }
  }

  /// Get tournament details
  Future<Map<String, dynamic>?> getTournament(String tournamentId) async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/tournaments/$tournamentId'),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting tournament', e);
      return null;
    }
  }

  /// Join tournament
  Future<Map<String, dynamic>?> joinTournament(
    String tournamentId, {
    String? entryTier,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (entryTier != null) {
        body['entry_tier'] = entryTier;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/tournaments/$tournamentId/join'),
            headers: _authHeaders,
            body: body.isNotEmpty ? jsonEncode(body) : null,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error joining tournament', e);
      return null;
    }
  }

  /// Submit tournament score
  Future<Map<String, dynamic>?> submitTournamentScore({
    required String tournamentId,
    required int score,
    int gameDuration = 0,
    int foodsEaten = 0,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/tournaments/$tournamentId/score'),
            headers: _authHeaders,
            body: jsonEncode({
              'score': score,
              'game_duration_seconds': gameDuration,
              'foods_eaten': foodsEaten,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error submitting tournament score', e);
      return null;
    }
  }

  /// Get tournament leaderboard
  Future<Map<String, dynamic>?> getTournamentLeaderboard(
    String tournamentId, {
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await http
          .get(
            Uri.parse(
              '$baseUrl/tournaments/$tournamentId/leaderboard?limit=$limit&offset=$offset',
            ),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting tournament leaderboard', e);
      return null;
    }
  }

  // ==================== Multiplayer ====================

  /// Create multiplayer game
  Future<Map<String, dynamic>?> createMultiplayerGame({
    String mode = 'classic',
    int maxPlayers = 4,
    int gridSize = 20,
    int speed = 100,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/multiplayer/create'),
            headers: _authHeaders,
            body: jsonEncode({
              'mode': mode,
              'max_players': maxPlayers,
              'grid_size': gridSize,
              'speed': speed,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error creating multiplayer game', e);
      return null;
    }
  }

  /// Join multiplayer game by code
  Future<Map<String, dynamic>?> joinMultiplayerGame(String roomCode) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/multiplayer/join'),
            headers: _authHeaders,
            body: jsonEncode({'room_code': roomCode}),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error joining multiplayer game', e);
      return null;
    }
  }

  /// Get current multiplayer game
  Future<Map<String, dynamic>?> getCurrentMultiplayerGame() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/multiplayer/current'), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting current game', e);
      return null;
    }
  }

  /// Get available multiplayer games (public, waiting for players)
  Future<List<dynamic>?> getAvailableGames() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/multiplayer/available'),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      // Route through _handleResponse for proper 401/error handling
      final data = _handleResponse(response);
      if (data != null && data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting available games', e);
      return null;
    }
  }

  /// Get SignalR Hub URL for multiplayer
  String getSignalRHubUrl() {
    final hubUrl = baseUrl.replaceFirst('/api/v1', '');
    return '$hubUrl/hubs/game';
  }

  /// Get WebSocket URL for multiplayer (deprecated, use SignalR)
  @Deprecated('Use getSignalRHubUrl() instead')
  String getMultiplayerWebSocketUrl(String gameId) {
    final wsUrl = baseUrl
        .replaceFirst('http', 'ws')
        .replaceFirst('/api/v1', '');
    return '$wsUrl/api/v1/multiplayer/ws/$gameId?token=$_accessToken';
  }

  // ==================== Purchases ====================

  /// Verify purchase
  Future<Map<String, dynamic>?> verifyPurchase({
    required String platform,
    required String receiptData,
    required String productId,
    required String transactionId,
    String? purchaseToken,
    DateTime? purchaseTime,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/purchases/verify'),
            headers: _authHeaders,
            body: jsonEncode({
              'receipt': {
                'platform': platform,
                'receipt_data': receiptData,
                'product_id': productId,
                'transaction_id': transactionId,
                'purchase_token': purchaseToken,
                'purchase_time': (purchaseTime ?? DateTime.now())
                    .toIso8601String(),
              },
              'device_info': {},
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error verifying purchase', e);
      return null;
    }
  }

  /// Batch verify multiple purchases in a single call
  Future<Map<String, dynamic>?> batchVerifyPurchases(
    List<Map<String, dynamic>> purchases,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/purchases/verify-batch'),
            headers: _authHeaders,
            body: jsonEncode({'purchases': purchases}),
          )
          .timeout(const Duration(seconds: 30));

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error batch verifying purchases', e);
      return null;
    }
  }

  /// Get premium content
  Future<Map<String, dynamic>?> getPremiumContent() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/purchases/premium-content'),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting premium content', e);
      return null;
    }
  }

  // ==================== Battle Pass ====================

  /// Get current battle pass season
  Future<Map<String, dynamic>?> getCurrentBattlePassSeason() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/BattlePass/current-season'),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting battle pass season', e);
      return null;
    }
  }

  /// Get battle pass progress
  Future<Map<String, dynamic>?> getBattlePassProgress() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/BattlePass/progress'), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting battle pass progress', e);
      return null;
    }
  }

  /// Add battle pass XP
  Future<Map<String, dynamic>?> addBattlePassXP({
    required int xp,
    String source = 'gameplay',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/BattlePass/add-xp'),
            headers: _authHeaders,
            body: jsonEncode({'xp': xp, 'source': source}),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error adding battle pass XP', e);
      return null;
    }
  }

  /// Claim battle pass reward
  Future<Map<String, dynamic>?> claimBattlePassReward({
    required int level,
    required String tier,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/BattlePass/claim-reward'),
            headers: _authHeaders,
            body: jsonEncode({'level': level, 'tier': tier}),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error claiming battle pass reward', e);
      return null;
    }
  }

  // ==================== Daily Bonus ====================

  /// Get daily bonus status
  Future<Map<String, dynamic>?> getDailyBonusStatus() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/DailyBonus/status'), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting daily bonus status', e);
      return null;
    }
  }

  /// Claim daily bonus
  /// Returns success response, or {alreadyClaimed: true} if already claimed today
  Future<Map<String, dynamic>?> claimDailyBonus() async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/DailyBonus/claim'),
            headers: _authHeaders,
            body: jsonEncode({}),
          )
          .timeout(_timeout);

      // Handle 400 "already claimed" as success (idempotent operation)
      if (response.statusCode == 400) {
        try {
          final body = jsonDecode(response.body);
          final errorMsg = (body['error'] ?? body['message'] ?? '')
              .toString()
              .toLowerCase();
          if (errorMsg.contains('already claimed') ||
              errorMsg.contains('already collected')) {
            // Not an error - just means the bonus was already claimed
            // Return success with a flag so sync service knows not to retry
            AppLogger.network(
              'Daily bonus already claimed today (treating as success)',
            );
            return {'success': true, 'alreadyClaimed': true};
          }
        } catch (_) {
          // If we can't parse the body, fall through to normal error handling
        }
      }

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error claiming daily bonus', e);
      return null;
    }
  }

  // ==================== Daily Challenges ====================

  /// Get today's daily challenges with user progress
  Future<Map<String, dynamic>?> getDailyChallenges() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/dailychallenges'), headers: _authHeaders)
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error getting daily challenges', e);
      return null;
    }
  }

  /// Update progress for daily challenges (called after each game)
  Future<Map<String, dynamic>?> updateChallengeProgress({
    required String type,
    required int value,
    String? gameMode,
  }) async {
    try {
      final body = <String, dynamic>{'type': type, 'value': value};
      if (gameMode != null) {
        body['gameMode'] = gameMode;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/dailychallenges/progress'),
            headers: _authHeaders,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error updating challenge progress', e);
      return null;
    }
  }

  /// Claim reward for a completed challenge
  Future<Map<String, dynamic>?> claimChallengeReward(String challengeId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/dailychallenges/claim/$challengeId'),
            headers: _authHeaders,
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error claiming challenge reward', e);
      return null;
    }
  }

  /// Batch claim rewards for multiple completed challenges in a single call
  Future<Map<String, dynamic>?> batchClaimChallengeRewards(
    List<String> challengeIds,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/dailychallenges/claim-batch'),
            headers: _authHeaders,
            body: jsonEncode({'challenge_ids': challengeIds}),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error batch claiming challenge rewards', e);
      return null;
    }
  }

  // ==================== Notifications ====================

  /// Register FCM token
  Future<bool> registerFcmToken({
    required String fcmToken,
    String platform = 'flutter',
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/users/register-token'),
            headers: _authHeaders,
            body: jsonEncode({'fcm_token': fcmToken, 'platform': platform}),
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error registering FCM token', e);
      return false;
    }
  }

  /// Subscribe to notification topic
  Future<bool> subscribeToTopic(String fcmToken, String topic) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/notifications/topics/subscribe'),
            headers: _authHeaders,
            body: jsonEncode({'fcm_token': fcmToken, 'topic': topic}),
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error subscribing to topic', e);
      return false;
    }
  }

  /// Batch subscribe to multiple notification topics in a single call
  Future<bool> batchSubscribeToTopics(
    String fcmToken,
    List<String> topics,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/notifications/topics/subscribe-batch'),
            headers: _authHeaders,
            body: jsonEncode({'fcm_token': fcmToken, 'topics': topics}),
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error batch subscribing to topics', e);
      return false;
    }
  }

  /// Unsubscribe from notification topic
  Future<bool> unsubscribeFromTopic(String fcmToken, String topic) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/notifications/topics/unsubscribe'),
            headers: _authHeaders,
            body: jsonEncode({'fcm_token': fcmToken, 'topic': topic}),
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error unsubscribing from topic', e);
      return false;
    }
  }

  // ==================== Health Check ====================

  /// Check backend health
  Future<bool> checkHealth() async {
    try {
      final healthUrl = baseUrl.replaceFirst('/api/v1', '/health/status');
      final response = await http
          .get(
            Uri.parse(healthUrl),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error checking backend health', e);
      return false;
    }
  }
}
