import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// HTTP gateway to the backend. After the offline-first refactor this
/// is a narrow surface: only auth (Firebase ↔ JWT exchange, profile,
/// username) and purchase/premium (IAP receipt verification, premium
/// content, equipped cosmetics). Everything else — leaderboards,
/// tournaments, social, scores, achievements, daily challenges, weekly
/// quests, daily bonus, multiplayer, power-ups, battle pass — has been
/// removed from the network surface and now lives in Drift.
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String _tokenKey = 'jwt_access_token';
  static const String _userIdKey = 'backend_user_id';

  String? _accessToken;
  String? _userId;

  VoidCallback? onUnauthorized;

  static const String _prodFallbackUrl = 'https://snakeclassic.pranta.dev';

  static String get baseUrl {
    final String backendUrl;
    if (kDebugMode) {
      if (dotenv.env['DEV_API_BACKEND_URL'] == null) {
        throw Exception('DEV_API_BACKEND_URL not set in .env');
      }
      backendUrl = dotenv.env['DEV_API_BACKEND_URL']!;
    } else {
      backendUrl = dotenv.env['PROD_API_BACKEND_URL'] ?? _prodFallbackUrl;
    }
    return '$backendUrl/api/v1';
  }

  static const Duration _timeout = Duration(seconds: 15);

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _accessToken = prefs.getString(_tokenKey);
      _userId = prefs.getString(_userIdKey);
      if (_accessToken != null) {
        if (isTokenExpiredOrExpiring) {
          AppLogger.network('Stored JWT is expired — clearing on init');
          await clearToken();
        } else {
          AppLogger.network('Loaded stored JWT token');
        }
      }
    } catch (e) {
      AppLogger.error('Error loading stored token', e);
    }
  }

  /// True when a usable JWT is in memory. Strict: also requires the
  /// JWT to not be expired/expiring, so callers don't fire requests
  /// that are about to eat a 401.
  bool get isAuthenticated =>
      _accessToken != null && !isTokenExpiredOrExpiring;

  String? get currentUserId => _userId;

  String? get accessToken => _accessToken;

  bool get isTokenExpiredOrExpiring {
    if (_accessToken == null) return true;
    try {
      final parts = _accessToken!.split('.');
      if (parts.length != 3) return true;

      String payload = parts[1];
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
      return DateTime.now().isAfter(
        expiry.subtract(const Duration(minutes: 5)),
      );
    } catch (e) {
      return true;
    }
  }

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

  Map<String, String> get _authHeaders => {
    'Content-Type': 'application/json',
    if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
  };

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

  // ==================== Purchases ====================

  Future<Map<String, dynamic>?> verifyPurchase({
    required String platform,
    required String receiptData,
    required String productId,
    required String transactionId,
    String? purchaseToken,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/purchases/verify'),
            headers: _authHeaders,
            body: jsonEncode({
              'purchase_data': {
                'product_id': productId,
                'transaction_id': transactionId,
                'receipt_data': receiptData,
                'purchase_token': purchaseToken,
              },
              'platform': platform,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error verifying purchase', e);
      return null;
    }
  }

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

  /// Persist the user's equipped cosmetic IDs so they survive reinstall
  /// and device-switch. Backend uses JsonNamingPolicy.SnakeCaseLower —
  /// keys must be snake_case or they bind to null silently.
  Future<Map<String, dynamic>?> setEquippedCosmetics({
    String? skinId,
    String? trailId,
    String? themeId,
  }) async {
    try {
      final response = await http
          .put(
            Uri.parse('$baseUrl/purchases/equipped-cosmetics'),
            headers: _authHeaders,
            body: jsonEncode({
              'skin_id': ?skinId,
              'trail_id': ?trailId,
              'theme_id': ?themeId,
            }),
          )
          .timeout(_timeout);

      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error setting equipped cosmetics', e);
      return null;
    }
  }

  // ==================== Sync ====================
  //
  // These endpoints back the SyncEngine's outbox drain. The handlers
  // are batch-aware on the backend side — singletons (settings,
  // statistics, coin_balance, premium_status) take the payload
  // directly; lists (achievements, coin_transactions, unlocked_items,
  // battle_pass, daily_challenge_claims) wrap the array in
  // `{"items": [...]}` to match `SyncBatchRequest<T>`.

  Future<Map<String, dynamic>?> syncSettings(Map<String, dynamic> payload) async {
    return _postSync('settings', payload);
  }

  Future<Map<String, dynamic>?> syncStatistics(Map<String, dynamic> payload) async {
    return _postSync('statistics', payload);
  }

  Future<Map<String, dynamic>?> syncCoinBalance(Map<String, dynamic> payload) async {
    return _postSync('coins/balance', payload);
  }

  Future<Map<String, dynamic>?> syncPremiumStatus(Map<String, dynamic> payload) async {
    return _postSync('premium-status', payload);
  }

  Future<Map<String, dynamic>?> syncAchievements(
    List<Map<String, dynamic>> items,
  ) async {
    return _postSync('achievements', {'items': items});
  }

  Future<Map<String, dynamic>?> syncCoinTransactions(
    List<Map<String, dynamic>> items,
  ) async {
    return _postSync('coins/transactions', {'items': items});
  }

  Future<Map<String, dynamic>?> syncUnlockedItems(
    List<Map<String, dynamic>> items,
  ) async {
    return _postSync('unlocked-items', {'items': items});
  }

  Future<Map<String, dynamic>?> syncBattlePass(
    List<Map<String, dynamic>> items,
  ) async {
    return _postSync('battle-pass', {'items': items});
  }

  Future<Map<String, dynamic>?> syncDailyChallengeClaims(
    List<Map<String, dynamic>> items,
  ) async {
    return _postSync('daily-challenge-claims', {'items': items});
  }

  /// First-sign-in pull. Returns the cloud snapshot, or null when the
  /// user has no synced data yet (SyncEngine treats null as "fresh
  /// user, push local"). Network / 5xx errors also return null so
  /// the engine retries later.
  Future<Map<String, dynamic>?> pullSyncSnapshot() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/sync/pull'), headers: _authHeaders)
          .timeout(_timeout);

      final body = _handleResponse(response);
      if (body == null) return null;
      // Backend wraps a null payload in `{"data": null}` for 200 OK;
      // unwrap that so the SyncEngine sees the same shape regardless.
      if (body.containsKey('data') && body['data'] == null) return null;
      return body;
    } catch (e) {
      AppLogger.error('Error pulling sync snapshot', e);
      return null;
    }
  }

  /// Shared POST helper for every /sync/* endpoint. Returns the parsed
  /// response body on 2xx, null on every kind of failure (network,
  /// timeout, 401, 4xx, 5xx). SyncEngine treats null as "soft failure
  /// — leave the outbox rows pending and retry on the next drain."
  Future<Map<String, dynamic>?> _postSync(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/sync/$path'),
            headers: _authHeaders,
            body: jsonEncode(body),
          )
          .timeout(_timeout);
      return _handleResponse(response);
    } catch (e) {
      AppLogger.error('Error POST /sync/$path', e);
      return null;
    }
  }

  // ==================== Notifications ====================

  /// Register FCM token. Forwards the device's UTC offset so the
  /// backend can land daily notifications at each user's local 9 AM.
  Future<bool> registerFcmToken({
    required String fcmToken,
    String platform = 'flutter',
    int? timezoneOffsetMinutes,
  }) async {
    try {
      final body = <String, dynamic>{
        'fcm_token': fcmToken,
        'platform': platform,
      };
      if (timezoneOffsetMinutes != null) {
        body['time_zone_offset_minutes'] = timezoneOffsetMinutes;
      }

      final response = await http
          .post(
            Uri.parse('$baseUrl/users/register-token'),
            headers: _authHeaders,
            body: jsonEncode(body),
          )
          .timeout(_timeout);

      return response.statusCode == 200;
    } catch (e) {
      AppLogger.error('Error registering FCM token', e);
      return false;
    }
  }
}
