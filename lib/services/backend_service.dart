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
    final backendUrl = dotenv.env['NOTIFICATION_BACKEND_URL'] ?? 'http://127.0.0.1:8000';
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

      final response = await http.post(
        Uri.parse('$_baseUrl/users/register-token'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
          'user_id': userId,
          'username': username,
          'platform': 'flutter',
          'registered_at': DateTime.now().toIso8601String(),
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('FCM token registered successfully: ${data['message']}');
        return true;
      } else {
        AppLogger.error('Failed to register FCM token: ${response.statusCode}', response.body);
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
        final response = await http.post(
          Uri.parse('$_baseUrl/notifications/topics/subscribe'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'fcm_token': fcmToken,
            'topic': topic,
          }),
        ).timeout(_timeout);

        if (response.statusCode == 200) {
          AppLogger.network('Subscribed to topic: $topic');
        } else {
          AppLogger.error('Failed to subscribe to topic $topic: ${response.statusCode}', response.body);
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
        final response = await http.post(
          Uri.parse('$_baseUrl/notifications/topics/unsubscribe'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'fcm_token': fcmToken,
            'topic': topic,
          }),
        ).timeout(_timeout);

        if (response.statusCode == 200) {
          AppLogger.network('Unsubscribed from topic: $topic');
        } else {
          AppLogger.error('Failed to unsubscribe from topic $topic: ${response.statusCode}', response.body);
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

      final response = await http.post(
        Uri.parse('$_baseUrl/test/send-test-notification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'fcm_token': fcmToken,
          'title': title,
          'body': body,
          'route': route,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('Test notification sent: ${data['message']}');
        return true;
      } else {
        AppLogger.error('Failed to send test notification: ${response.statusCode}', response.body);
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

      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/game-templates/achievement-unlocked'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'achievement_name': achievementName,
          'achievement_id': achievementId,
          'fcm_token': fcmToken,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        AppLogger.network('Achievement notification sent successfully');
        return true;
      } else {
        AppLogger.error('Failed to send achievement notification: ${response.statusCode}', response.body);
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
      AppLogger.network('Sending friend request notification from: $senderName');

      final response = await http.post(
        Uri.parse('$_baseUrl/notifications/game-templates/friend-request'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'sender_name': senderName,
          'sender_id': senderId,
          'fcm_token': targetFcmToken,
        }),
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        AppLogger.network('Friend request notification sent successfully');
        return true;
      } else {
        AppLogger.error('Failed to send friend request notification: ${response.statusCode}', response.body);
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

      final response = await http.get(
        Uri.parse('$_baseUrl/test/health'),
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        AppLogger.network('Backend health check: ${data['message']}');
        return true;
      } else {
        AppLogger.error('Backend health check failed: ${response.statusCode}', response.body);
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
}