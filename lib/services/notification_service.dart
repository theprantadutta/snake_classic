import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'backend_service.dart';
import 'unified_user_service.dart';
import 'navigation_service.dart';

enum NotificationType {
  tournament('tournament', 'Tournament Update'),
  social('social', 'Social Notification'), 
  achievement('achievement', 'Achievement Unlocked'),
  dailyReminder('daily_reminder', 'Daily Challenge'),
  specialEvent('special_event', 'Special Event');

  const NotificationType(this.key, this.displayName);
  final String key;
  final String displayName;
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static const String _channelId = 'snake_classic_notifications';
  static const String _channelName = 'Snake Classic Notifications';
  static const String _channelDescription = 'Notifications for Snake Classic game events';

  late FlutterLocalNotificationsPlugin _localNotifications;
  late FirebaseMessaging _firebaseMessaging;
  
  String? _fcmToken;
  bool _initialized = false;
  
  // Notification preferences - stored in SharedPreferences via PreferencesService
  final Map<NotificationType, bool> _notificationPreferences = {
    NotificationType.tournament: true,
    NotificationType.social: true,
    NotificationType.achievement: true,
    NotificationType.dailyReminder: true,
    NotificationType.specialEvent: true,
  };

  String? get fcmToken => _fcmToken;
  bool get initialized => _initialized;

  Future<void> initialize() async {
    try {
      AppLogger.info('🔔 Initializing notification service');
      
      _firebaseMessaging = FirebaseMessaging.instance;
      _localNotifications = FlutterLocalNotificationsPlugin();
      
      await _initializeLocalNotifications();
      await _initializeFirebaseMessaging();
      await _loadNotificationPreferences();
      
      _initialized = true;
      AppLogger.success('Notification service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize notification service', e);
      rethrow;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    // Android initialization settings
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // iOS initialization settings
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channel for Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      await _localNotifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _initializeFirebaseMessaging() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    AppLogger.info('🔔 Notification permission: ${settings.authorizationStatus}');

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      
      // Get FCM token
      _fcmToken = await _firebaseMessaging.getToken();
      AppLogger.info('🎫 FCM Token: $_fcmToken');
      
      // Development-only: Print FCM token for Firebase Console testing
      if (kDebugMode && _fcmToken != null) {
        debugPrint('');
        debugPrint('🔥 ============ FIREBASE TESTING ============');
        debugPrint('📱 FCM Token for Firebase Console:');
        debugPrint(_fcmToken!);
        debugPrint('🧪 Copy this token to Firebase Console > Cloud Messaging');
        debugPrint('🔥 =========================================');
        debugPrint('');
      }

      // Subscribe to token refresh
      _firebaseMessaging.onTokenRefresh.listen((token) {
        _fcmToken = token;
        AppLogger.info('🔄 FCM Token refreshed: $token');
        
        // Development-only: Print refreshed token
        if (kDebugMode) {
          debugPrint('');
          debugPrint('🔄 ========= FCM TOKEN REFRESHED =========');
          debugPrint('📱 New FCM Token: $token');
          debugPrint('🔄 ===================================');
          debugPrint('');
        }
        
        _onTokenRefresh(token);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background message taps
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle initial message when app is opened from terminated state
      RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }
    }
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    AppLogger.info('📨 Received foreground message: ${message.messageId}');
    
    // Show local notification for foreground messages
    await _showLocalNotification(
      title: message.notification?.title ?? 'Snake Classic',
      body: message.notification?.body ?? 'You have a new notification',
      payload: jsonEncode(message.data),
    );
  }

  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    AppLogger.info('👆 App opened from notification: ${message.messageId}');
    
    // Handle deep linking based on notification data
    final data = message.data;
    if (data.containsKey('route')) {
      _navigateToScreen(data['route'], data);
    }
  }

  void _onTokenRefresh(String token) {
    // Send updated token to backend
    _registerTokenWithBackend(token);
  }

  void _onNotificationTapped(NotificationResponse response) {
    AppLogger.info('👆 Local notification tapped: ${response.id}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        if (data['route'] != null) {
          _navigateToScreen(data['route'], data);
        }
      } catch (e) {
        AppLogger.error('Error parsing notification payload', e);
      }
    }
  }

  void _navigateToScreen(String route, Map<String, dynamic> data) {
    AppLogger.info('🧭 Navigating to: $route with data: $data');
    
    try {
      // Use the navigation service to handle deep linking
      NavigationService().navigateFromNotification(
        route: route,
        params: data,
      );
    } catch (e) {
      AppLogger.error('Navigation failed', e);
      // Fallback to home screen
      NavigationService().navigateToHome();
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    NotificationType? type,
  }) async {
    // Check if notifications are enabled for this type
    if (type != null && !(_notificationPreferences[type] ?? true)) {
      AppLogger.info('🔕 Notification blocked by user preferences: ${type.key}');
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'Snake Classic',
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  // Topic subscription methods
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      AppLogger.info('📢 Subscribed to topic: $topic');
    } catch (e) {
      AppLogger.error('Failed to subscribe to topic $topic', e);
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      AppLogger.info('🔕 Unsubscribed from topic: $topic');
    } catch (e) {
      AppLogger.error('Failed to unsubscribe from topic $topic', e);
    }
  }

  // Notification preference methods
  bool isNotificationEnabled(NotificationType type) {
    return _notificationPreferences[type] ?? true;
  }

  Future<void> setNotificationEnabled(NotificationType type, bool enabled) async {
    _notificationPreferences[type] = enabled;
    AppLogger.info('⚙️ ${type.key} notifications ${enabled ? 'enabled' : 'disabled'}');
    
    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_${type.key}', enabled);
    } catch (e) {
      AppLogger.error('Failed to save notification preference: $e');
    }
  }

  Map<NotificationType, bool> get notificationPreferences => Map.from(_notificationPreferences);

  // Game-specific notification methods
  Future<void> showAchievementNotification(String achievementName) async {
    await _showLocalNotification(
      title: '🏆 Achievement Unlocked!',
      body: achievementName,
      type: NotificationType.achievement,
      payload: jsonEncode({'route': 'achievements', 'achievement': achievementName}),
    );
  }

  Future<void> showTournamentNotification(String title, String body, {String? tournamentId}) async {
    await _showLocalNotification(
      title: '🏆 $title',
      body: body,
      type: NotificationType.tournament,
      payload: jsonEncode({
        'route': 'tournament_detail',
        'tournament_id': tournamentId,
      }),
    );
  }

  Future<void> showSocialNotification(String title, String body, {String? userId}) async {
    await _showLocalNotification(
      title: '👥 $title',
      body: body,
      type: NotificationType.social,
      payload: jsonEncode({
        'route': 'friends_screen',
        'user_id': userId,
      }),
    );
  }

  Future<void> showDailyReminderNotification() async {
    await _showLocalNotification(
      title: '🐍 Time to play Snake Classic!',
      body: 'Complete your daily challenge and climb the leaderboard!',
      type: NotificationType.dailyReminder,
      payload: jsonEncode({'route': 'home'}),
    );
  }

  // Scheduled notifications
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // Schedule daily reminder at specified time
    // This uses flutter_local_notifications scheduling
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    await _localNotifications.periodicallyShow(
      0, // notification id
      '🐍 Daily Challenge Available!',
      'Complete your daily challenge and compete with friends!',
      RepeatInterval.daily,
      details,
      payload: jsonEncode({'route': 'home'}),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );

    AppLogger.info('⏰ Daily reminder scheduled');
  }

  Future<void> cancelScheduledNotification(int id) async {
    await _localNotifications.cancel(id);
  }

  Future<void> cancelAllScheduledNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Backend integration methods
  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final userService = UnifiedUserService();
      final user = userService.currentUser;
      
      if (user != null) {
        final success = await BackendService().registerFcmToken(
          fcmToken: token,
          userId: user.uid,
          username: user.displayName.isNotEmpty ? user.displayName : user.uid,
        );
        
        if (success) {
          AppLogger.network('FCM token registered with backend successfully');
          await _syncTopicSubscriptions(token);
        } else {
          AppLogger.error('Failed to register FCM token with backend');
        }
      }
    } catch (e) {
      AppLogger.error('Error registering token with backend', e);
    }
  }

  Future<void> _syncTopicSubscriptions(String token) async {
    try {
      AppLogger.network('Syncing topic subscriptions with backend');
      
        // Get recommended topics based on user preferences
      final topics = BackendService().getRecommendedTopics(
        tournamentsEnabled: _notificationPreferences[NotificationType.tournament] ?? true,
        socialEnabled: _notificationPreferences[NotificationType.social] ?? true,
        achievementsEnabled: _notificationPreferences[NotificationType.achievement] ?? true,
        dailyRemindersEnabled: _notificationPreferences[NotificationType.dailyReminder] ?? true,
        specialEventsEnabled: _notificationPreferences[NotificationType.specialEvent] ?? true,
      );
      
      await BackendService().subscribeToTopics(
        fcmToken: token,
        topics: topics,
      );
      
      AppLogger.network('Topic subscriptions synced: ${topics.join(', ')}');
    } catch (e) {
      AppLogger.error('Error syncing topic subscriptions', e);
    }
  }

  /// Initialize backend integration after user authentication
  Future<void> initializeBackendIntegration() async {
    try {
      if (_fcmToken == null) {
        AppLogger.warning('Cannot initialize backend integration: No FCM token available');
        return;
      }

      AppLogger.info('🔗 Initializing backend integration');
      
      // Development-only: Print token for backend testing
      if (kDebugMode) {
        debugPrint('');
        debugPrint('🔗 ======== BACKEND INTEGRATION ========');
        debugPrint('📱 FCM Token being registered with backend:');
        debugPrint(_fcmToken!);
        debugPrint('🧪 This token will be sent to the notification backend');
        debugPrint('🔗 =====================================');
        debugPrint('');
      }
      
      // Check backend health
      final isHealthy = await BackendService().checkBackendHealth();
      if (!isHealthy) {
        AppLogger.warning('Backend health check failed - notifications may not work properly');
        return;
      }

      // Register token with backend
      await _registerTokenWithBackend(_fcmToken!);
      
      AppLogger.info('✅ Backend integration initialized');
    } catch (e) {
      AppLogger.error('Failed to initialize backend integration', e);
    }
  }

  /// Send achievement notification via backend
  Future<void> triggerAchievementNotification(String achievementName, String achievementId) async {
    if (_fcmToken == null) {
      AppLogger.warning('Cannot send achievement notification: No FCM token');
      return;
    }

    try {
      await BackendService().sendAchievementNotification(
        fcmToken: _fcmToken!,
        achievementName: achievementName,
        achievementId: achievementId,
      );
      
      AppLogger.info('🏆 Achievement notification sent via backend: $achievementName');
    } catch (e) {
      AppLogger.error('Failed to send achievement notification via backend', e);
      // Fallback to local notification
      await showAchievementNotification(achievementName);
    }
  }

  /// Send friend request notification via backend
  Future<void> triggerFriendRequestNotification({
    required String targetUserId,
    required String targetFcmToken,
    required String senderName,
    required String senderId,
  }) async {
    try {
      await BackendService().sendFriendRequestNotification(
        targetFcmToken: targetFcmToken,
        senderName: senderName,
        senderId: senderId,
      );
      
      AppLogger.info('👥 Friend request notification sent via backend');
    } catch (e) {
      AppLogger.error('Failed to send friend request notification via backend', e);
    }
  }

  /// Send test notification via backend
  Future<void> sendTestNotificationViaBackend() async {
    if (_fcmToken == null) {
      AppLogger.warning('Cannot send test notification: No FCM token');
      return;
    }

    try {
      final success = await BackendService().sendTestNotification(
        fcmToken: _fcmToken!,
        title: '🐍 Backend Test',
        body: 'This notification was sent from the Snake Classic backend!',
        route: 'home',
      );
      
      if (success) {
        AppLogger.info('✅ Test notification sent via backend');
      } else {
        AppLogger.error('❌ Backend test notification failed');
      }
    } catch (e) {
      AppLogger.error('Error sending test notification via backend', e);
    }
  }

  /// Update notification preferences and sync with backend
  Future<void> updateNotificationEnabled(NotificationType type, bool enabled) async {
    _notificationPreferences[type] = enabled;
    AppLogger.info('⚙️ ${type.key} notifications ${enabled ? 'enabled' : 'disabled'}');
    
    // Save to preferences using shared preferences directly
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notification_${type.key}', enabled);
    
    // Sync with backend if token is available
    if (_fcmToken != null) {
      await _syncTopicSubscriptions(_fcmToken!);
    }
  }

  /// Load notification preferences from storage
  Future<void> _loadNotificationPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      for (final type in NotificationType.values) {
        final key = 'notification_${type.key}';
        final enabled = prefs.getBool(key) ?? true;
        _notificationPreferences[type] = enabled;
      }
      
      AppLogger.info('📱 Notification preferences loaded');
    } catch (e) {
      AppLogger.error('Error loading notification preferences', e);
    }
  }

  /// Development-only method to print FCM token for Firebase Console testing
  void printFcmTokenForTesting() {
    if (kDebugMode && _fcmToken != null) {
      debugPrint('');
      debugPrint('🔥 ============ FIREBASE TESTING ============');
      debugPrint('📱 Current FCM Token:');
      debugPrint(_fcmToken!);
      debugPrint('🧪 Steps to test:');
      debugPrint('  1. Copy the token above');
      debugPrint('  2. Go to Firebase Console > Cloud Messaging');
      debugPrint('  3. Create a new notification');
      debugPrint('  4. Paste token in "Send test message" field');
      debugPrint('🔥 =========================================');
      debugPrint('');
    } else if (kDebugMode) {
      debugPrint('⚠️ FCM Token not available for testing');
    }
  }

  // Cleanup
  void dispose() {
    // Clean up resources if needed
    AppLogger.info('🧹 Notification service disposed');
  }
}

// Background message handler - must be top-level function
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('📨 Background message received: ${message.messageId}');
  
  // Handle background message
  // Note: Limited functionality in background mode
}