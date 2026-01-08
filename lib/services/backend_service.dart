import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

class BackendService {
  static final BackendService _instance = BackendService._internal();
  factory BackendService() => _instance;
  BackendService._internal();

  // Backend configuration
  static String get _baseUrl {
    final backendUrl =
        dotenv.env['NOTIFICATION_BACKEND_URL'] ?? 'http://127.0.0.1:8393';
    return '$backendUrl/api/v1';
  }

  static const Duration _timeout = Duration(seconds: 10);

  /// Send FCM token to backend for storage and management
  Future<bool> registerFcmToken({
    required String fcmToken,
    required String userId,
    String? username,
  }) async {
    try {
      AppLogger.network('Registering FCM token with backend');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/users/register-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fcm_token': fcmToken,
              'user_id': userId,
              'username': username,
              'platform': 'flutter',
              'registered_at': DateTime.now().toIso8601String(),
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network(
          'FCM token registered successfully: ${data['message']}',
        );
        return true;
      } else {
        AppLogger.error(
          'Failed to register FCM token: ${response.statusCode}',
          response.body,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error registering FCM token', e);
      return false;
    }
  }

  /// Subscribe user to notification topics
  Future<bool> subscribeToTopics({
    required String fcmToken,
    required List<String> topics,
  }) async {
    try {
      AppLogger.network('Subscribing to topics: ${topics.join(', ')}');

      bool allSucceeded = true;
      for (String topic in topics) {
        final response = await http
            .post(
              Uri.parse('$_baseUrl/notifications/topics/subscribe'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'fcm_token': fcmToken, 'topic': topic}),
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          AppLogger.network('Subscribed to topic: $topic');
        } else {
          AppLogger.error(
            'Failed to subscribe to topic $topic: ${response.statusCode}',
            response.body,
          );
          allSucceeded = false;
        }
      }

      return allSucceeded;
    } catch (e) {
      AppLogger.error('Error subscribing to topics', e);
      return false;
    }
  }

  /// Unsubscribe user from notification topics
  Future<bool> unsubscribeFromTopics({
    required String fcmToken,
    required List<String> topics,
  }) async {
    try {
      AppLogger.network('Unsubscribing from topics: ${topics.join(', ')}');

      bool allSucceeded = true;
      for (String topic in topics) {
        final response = await http
            .post(
              Uri.parse('$_baseUrl/notifications/topics/unsubscribe'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'fcm_token': fcmToken, 'topic': topic}),
            )
            .timeout(_timeout);

        if (response.statusCode == 200) {
          AppLogger.network('Unsubscribed from topic: $topic');
        } else {
          AppLogger.error(
            'Failed to unsubscribe from topic $topic: ${response.statusCode}',
            response.body,
          );
          allSucceeded = false;
        }
      }

      return allSucceeded;
    } catch (e) {
      AppLogger.error('Error unsubscribing from topics', e);
      return false;
    }
  }

  /// Send a test notification via backend
  Future<bool> sendTestNotification({
    required String fcmToken,
    String title = '🐍 Test Notification',
    String body = 'This is a test notification from Snake Classic!',
    String route = 'home',
  }) async {
    try {
      AppLogger.network('Sending test notification via backend');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/test/send-test-notification'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'fcm_token': fcmToken,
              'title': title,
              'body': body,
              'route': route,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('Test notification sent: ${data['message']}');
        return true;
      } else {
        AppLogger.error(
          'Failed to send test notification: ${response.statusCode}',
          response.body,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error sending test notification', e);
      return false;
    }
  }

  /// Send achievement notification via backend
  Future<bool> sendAchievementNotification({
    required String fcmToken,
    required String achievementName,
    required String achievementId,
  }) async {
    try {
      AppLogger.network('Sending achievement notification: $achievementName');

      final response = await http
          .post(
            Uri.parse(
              '$_baseUrl/notifications/game-templates/achievement-unlocked',
            ),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'achievement_name': achievementName,
              'achievement_id': achievementId,
              'fcm_token': fcmToken,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        AppLogger.network('Achievement notification sent successfully');
        return true;
      } else {
        AppLogger.error(
          'Failed to send achievement notification: ${response.statusCode}',
          response.body,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error sending achievement notification', e);
      return false;
    }
  }

  /// Send friend request notification via backend
  Future<bool> sendFriendRequestNotification({
    required String targetFcmToken,
    required String senderName,
    required String senderId,
  }) async {
    try {
      AppLogger.network(
        'Sending friend request notification from: $senderName',
      );

      final response = await http
          .post(
            Uri.parse('$_baseUrl/notifications/game-templates/friend-request'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'sender_name': senderName,
              'sender_id': senderId,
              'fcm_token': targetFcmToken,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        AppLogger.network('Friend request notification sent successfully');
        return true;
      } else {
        AppLogger.error(
          'Failed to send friend request notification: ${response.statusCode}',
          response.body,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error sending friend request notification', e);
      return false;
    }
  }

  /// Check backend health
  Future<bool> checkBackendHealth() async {
    try {
      AppLogger.network('Checking backend health');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/test/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('Backend health check: ${data['message']}');
        return true;
      } else {
        AppLogger.error(
          'Backend health check failed: ${response.statusCode}',
          response.body,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error checking backend health', e);
      return false;
    }
  }

  /// Get recommended topics based on user preferences
  List<String> getRecommendedTopics({
    bool tournamentsEnabled = true,
    bool socialEnabled = true,
    bool achievementsEnabled = true,
    bool dailyRemindersEnabled = true,
    bool specialEventsEnabled = true,
  }) {
    List<String> topics = [];

    if (tournamentsEnabled) {
      topics.addAll(['tournaments', 'tournament_reminders']);
    }

    if (socialEnabled) {
      topics.add('social_updates');
    }

    if (achievementsEnabled) {
      topics.add('achievements');
    }

    if (dailyRemindersEnabled) {
      topics.add('daily_challenge');
    }

    if (specialEventsEnabled) {
      topics.addAll(['special_events', 'leaderboard_updates']);
    }

    return topics;
  }

  /// Verify a purchase with the backend
  Future<Map<String, dynamic>?> verifyPurchase({
    required String platform,
    required String receiptData,
    required String productId,
    required String transactionId,
    required String userId,
    String? purchaseToken,
    Map<String, dynamic>? deviceInfo,
  }) async {
    try {
      AppLogger.network('Verifying purchase: $productId');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/purchases/verify'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'receipt': {
                'platform': platform,
                'receipt_data': receiptData,
                'product_id': productId,
                'transaction_id': transactionId,
                'purchase_token': purchaseToken,
                'user_id': userId,
                'purchase_time': DateTime.now().toIso8601String(),
              },
              'user_id': userId,
              'device_info': deviceInfo ?? {},
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('Purchase verification successful: ${data['valid']}');
        return data;
      } else {
        AppLogger.error(
          'Purchase verification failed: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error verifying purchase', e);
      return null;
    }
  }

  /// Restore user's purchases
  Future<Map<String, dynamic>?> restorePurchases({
    required String userId,
    required String platform,
    required List<Map<String, dynamic>> receipts,
  }) async {
    try {
      AppLogger.network('Restoring purchases for user: $userId');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/purchases/restore'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'platform': platform,
              'receipts': receipts,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network(
          'Purchase restoration completed: ${data['restored_count']} restored',
        );
        return data;
      } else {
        AppLogger.error(
          'Purchase restoration failed: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error restoring purchases', e);
      return null;
    }
  }

  /// Get user's premium content status
  Future<Map<String, dynamic>?> getUserPremiumContent({
    required String userId,
    bool includeExpired = false,
  }) async {
    try {
      AppLogger.network('Getting premium content for user: $userId');

      final response = await http
          .get(
            Uri.parse(
              '$_baseUrl/purchases/user/$userId/premium-content?include_expired=$includeExpired',
            ),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('Premium content retrieved successfully');
        return data;
      } else {
        AppLogger.error(
          'Failed to get premium content: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error getting premium content', e);
      return null;
    }
  }

  /// Sync user's premium status with backend
  Future<bool> syncPremiumStatus({required String userId}) async {
    try {
      AppLogger.network('Syncing premium status for user: $userId');

      final premiumData = await getUserPremiumContent(userId: userId);
      if (premiumData == null) {
        return false;
      }

      // The premium data will be handled by the PremiumProvider
      AppLogger.network('Premium status synced successfully');
      return true;
    } catch (e) {
      AppLogger.error('Error syncing premium status', e);
      return false;
    }
  }

  /// Report purchase analytics
  Future<bool> reportPurchaseAnalytics({
    required String userId,
    required String productId,
    required String
    eventType, // 'purchase_initiated', 'purchase_completed', 'purchase_failed'
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      AppLogger.network(
        'Reporting purchase analytics: $eventType for $productId',
      );

      final response = await http
          .post(
            Uri.parse('$_baseUrl/analytics/purchase'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'product_id': productId,
              'event_type': eventType,
              'timestamp': DateTime.now().toIso8601String(),
              'additional_data': additionalData ?? {},
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        AppLogger.network('Purchase analytics reported successfully');
        return true;
      } else {
        AppLogger.error(
          'Failed to report analytics: ${response.statusCode}',
          response.body,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error reporting purchase analytics', e);
      return false;
    }
  }

  /// Battle Pass endpoints

  /// Get current Battle Pass season information
  Future<Map<String, dynamic>?> getCurrentBattlePassSeason() async {
    try {
      AppLogger.network('Getting current Battle Pass season');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/battle-pass/current-season'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('Current Battle Pass season retrieved successfully');
        return data;
      } else {
        AppLogger.error(
          'Failed to get Battle Pass season: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error getting Battle Pass season', e);
      return null;
    }
  }

  /// Get user's Battle Pass progress
  Future<Map<String, dynamic>?> getUserBattlePassProgress({
    required String userId,
  }) async {
    try {
      AppLogger.network('Getting Battle Pass progress for user: $userId');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/battle-pass/user/$userId/progress'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('Battle Pass progress retrieved successfully');
        return data;
      } else {
        AppLogger.error(
          'Failed to get Battle Pass progress: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error getting Battle Pass progress', e);
      return null;
    }
  }

  /// Add XP to user's Battle Pass
  Future<Map<String, dynamic>?> addBattlePassXP({
    required String userId,
    required int xp,
    String source = 'gameplay',
    Map<String, dynamic>? metadata,
  }) async {
    try {
      AppLogger.network('Adding $xp XP to Battle Pass for user: $userId');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/battle-pass/user/$userId/add-xp'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'xp': xp,
              'source': source,
              'metadata': metadata ?? {},
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network(
          'Battle Pass XP added successfully: ${data['message']}',
        );
        return data;
      } else {
        AppLogger.error(
          'Failed to add Battle Pass XP: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error adding Battle Pass XP', e);
      return null;
    }
  }

  /// Claim Battle Pass reward
  Future<Map<String, dynamic>?> claimBattlePassReward({
    required String userId,
    required int level,
    required String tier,
    required String rewardId,
  }) async {
    try {
      AppLogger.network(
        'Claiming Battle Pass reward: $tier reward at level $level for user: $userId',
      );

      final response = await http
          .post(
            Uri.parse('$_baseUrl/battle-pass/user/$userId/claim-reward'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'user_id': userId,
              'level': level,
              'tier': tier,
              'reward_id': rewardId,
            }),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network(
          'Battle Pass reward claimed successfully: ${data['message']}',
        );
        return data;
      } else {
        AppLogger.error(
          'Failed to claim Battle Pass reward: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error claiming Battle Pass reward', e);
      return null;
    }
  }

  /// Purchase premium Battle Pass
  Future<bool> purchasePremiumBattlePass({required String userId}) async {
    try {
      AppLogger.network('Purchasing premium Battle Pass for user: $userId');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/battle-pass/user/$userId/purchase-premium'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network(
          'Premium Battle Pass purchased successfully: ${data['message']}',
        );
        return data['success'] ?? false;
      } else {
        AppLogger.error(
          'Failed to purchase premium Battle Pass: ${response.statusCode}',
          response.body,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error purchasing premium Battle Pass', e);
      return false;
    }
  }

  /// Get all Battle Pass levels and rewards
  Future<Map<String, dynamic>?> getBattlePassLevels() async {
    try {
      AppLogger.network('Getting Battle Pass levels and rewards');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/battle-pass/levels'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('Battle Pass levels retrieved successfully');
        return data;
      } else {
        AppLogger.error(
          'Failed to get Battle Pass levels: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error getting Battle Pass levels', e);
      return null;
    }
  }

  /// Get Battle Pass statistics
  Future<Map<String, dynamic>?> getBattlePassStats() async {
    try {
      AppLogger.network('Getting Battle Pass statistics');

      final response = await http
          .get(
            Uri.parse('$_baseUrl/battle-pass/stats'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('Battle Pass statistics retrieved successfully');
        return data;
      } else {
        AppLogger.error(
          'Failed to get Battle Pass statistics: ${response.statusCode}',
          response.body,
        );
        return null;
      }
    } catch (e) {
      AppLogger.error('Error getting Battle Pass statistics', e);
      return null;
    }
  }
}
