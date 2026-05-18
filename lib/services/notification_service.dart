import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';
import 'api_service.dart';
import 'backend_service.dart';
import 'data_sync_service.dart';
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
  static const String _channelDescription =
      'Notifications for Snake Classic game events';

  late FlutterLocalNotificationsPlugin _localNotifications;
  late FirebaseMessaging _firebaseMessaging;

  String? _fcmToken;
  bool _initialized = false;
  bool _backendIntegrationDone = false;

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
      await _initializeFirebaseMessaging().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          AppLogger.warning(
            'Firebase messaging init timed out — continuing without FCM',
          );
        },
      );
      await _loadNotificationPreferences();

      _initialized = true;
      AppLogger.success('Notification service initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize notification service', e);
      // Don't rethrow — notification failure shouldn't crash the app
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
      settings: initSettings,
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
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
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

    AppLogger.info(
      '🔔 Notification permission: ${settings.authorizationStatus}',
    );

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

      // Race fix: if the initial getToken() resolves AFTER
      // _initializeNotificationIntegration() has already run, the
      // backend integration call would have bailed with "no token" and
      // never retry. Treat the first-token arrival like a refresh so
      // _registerTokenWithBackend fires immediately (which queues via
      // DataSyncService if auth isn't ready yet — see Phase 2).
      // Anonymous + Google users both benefit.
      if (_fcmToken != null) {
        unawaited(_registerTokenWithBackend(_fcmToken!));
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
      RemoteMessage? initialMessage = await _firebaseMessaging
          .getInitialMessage();
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
      NavigationService().navigateFromNotification(route: route, params: data);
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
      AppLogger.info(
        '🔕 Notification blocked by user preferences: ${type.key}',
      );
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
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: details,
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

  Future<void> setNotificationEnabled(
    NotificationType type,
    bool enabled,
  ) async {
    _notificationPreferences[type] = enabled;
    AppLogger.info(
      '⚙️ ${type.key} notifications ${enabled ? 'enabled' : 'disabled'}',
    );

    // Save to preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_${type.key}', enabled);
    } catch (e) {
      AppLogger.error('Failed to save notification preference: $e');
    }

    // Side-effect: when the user toggles the Daily Reminder off, cancel
    // the pending OS-scheduled notification so they aren't pinged again
    // until they re-enable. The next scheduleSmartDailyReminder call
    // (on app launch or game end) will rebuild it if re-enabled.
    if (type == NotificationType.dailyReminder && !enabled) {
      await cancelDailyReminder();
    }
  }

  Map<NotificationType, bool> get notificationPreferences =>
      Map.from(_notificationPreferences);

  // Game-specific notification methods
  Future<void> showAchievementNotification(String achievementName) async {
    await _showLocalNotification(
      title: '🏆 Achievement Unlocked!',
      body: achievementName,
      type: NotificationType.achievement,
      payload: jsonEncode({
        'route': 'achievements',
        'achievement': achievementName,
      }),
    );
  }

  Future<void> showTournamentNotification(
    String title,
    String body, {
    String? tournamentId,
  }) async {
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

  Future<void> showSocialNotification(
    String title,
    String body, {
    String? userId,
  }) async {
    await _showLocalNotification(
      title: '👥 $title',
      body: body,
      type: NotificationType.social,
      payload: jsonEncode({'route': 'friends_screen', 'user_id': userId}),
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

  // Reserved notification ID for the recurring daily reminder so we can
  // cancel + reschedule on every app launch without piling up duplicates.
  static const int _dailyReminderNotificationId = 1001;

  /// Schedule (or refresh) the daily player reminder.
  ///
  /// Replaces the server-side cron that was supposed to fire once a day
  /// at each user's local 9 AM but was misbehaving and firing hourly.
  /// The OS-level scheduler is naturally timezone-aware (it uses the
  /// device clock) and fires even when the app is closed, so this is
  /// strictly simpler than the FCM round-trip.
  ///
  /// Behaviour:
  ///   * Cancels any previously-scheduled daily reminder.
  ///   * If the user has the Daily Reminder preference toggled off,
  ///     leaves them alone.
  ///   * Otherwise schedules a daily-repeating notification with content
  ///     personalized from local game state (current streak, today's
  ///     daily challenge availability, high score). Picked in priority
  ///     order, same logic the now-deleted backend job used.
  ///
  /// Should be called on app launch (after the local cache is hydrated)
  /// and after each game ends so the streak/state stays fresh.
  Future<void> scheduleSmartDailyReminder({
    required int currentWinStreak,
    required bool hasIncompleteDailyChallenge,
    required int highScore,
  }) async {
    // Always cancel first so a stale schedule from yesterday doesn't pile
    // on top of today's. Idempotent — no-op if there's nothing pending.
    await _localNotifications.cancel(id: _dailyReminderNotificationId);

    if (!(_notificationPreferences[NotificationType.dailyReminder] ?? true)) {
      AppLogger.info('🔕 Daily reminder disabled by user preference');
      return;
    }

    // Pick the most relevant message. Streak-at-risk wins because losing
    // a streak is the most urgent reason to come back.
    String title;
    String body;
    if (currentWinStreak >= 3) {
      title = '🔥 Your streak is on the line!';
      body =
          "You're on a $currentWinStreak-day streak. One game keeps it alive.";
    } else if (hasIncompleteDailyChallenge) {
      title = '🎯 Today\'s challenge is waiting';
      body = 'Complete it before midnight to claim your rewards.';
    } else if (highScore > 0) {
      title = 'Can you beat your best?';
      body = 'Your high score is $highScore. One round, one chance.';
    } else {
      title = '🐍 Snake Classic';
      body = 'Pick up where you left off.';
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
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

    try {
      // RepeatInterval.daily fires the same notification ~24 hours after
      // each schedule call. Calling this on every app launch effectively
      // shifts the fire time toward the user's typical play window — a
      // reasonable approximation of "when they'd want to be reminded"
      // without needing the timezone package's TZDateTime plumbing.
      //
      // inexactAllowWhileIdle skips the Android 12+ SCHEDULE_EXACT_ALARM
      // permission requirement (a daily reminder doesn't need
      // second-precision firing).
      await _localNotifications.periodicallyShow(
        id: _dailyReminderNotificationId,
        title: title,
        body: body,
        repeatInterval: RepeatInterval.daily,
        notificationDetails: details,
        payload: jsonEncode({'route': 'home', 'source': 'daily_reminder'}),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      AppLogger.info('⏰ Daily reminder scheduled: $title');
    } catch (e) {
      AppLogger.error('Failed to schedule daily reminder', e);
    }
  }

  /// Cancel any pending daily reminder. Called from the settings UI when
  /// the user toggles the Daily Reminder preference off, so they aren't
  /// pinged again until they re-enable + the next schedule call.
  Future<void> cancelDailyReminder() async {
    await _localNotifications.cancel(id: _dailyReminderNotificationId);
    AppLogger.info('🔕 Daily reminder cancelled');
  }

  // Legacy entry point kept for callers that still hand in a TimeOfDay;
  // routes through the smart scheduler with neutral content. New code
  // should call scheduleSmartDailyReminder directly.
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    await scheduleSmartDailyReminder(
      currentWinStreak: 0,
      hasIncompleteDailyChallenge: false,
      highScore: 0,
    );
  }

  Future<void> cancelScheduledNotification(int id) async {
    await _localNotifications.cancel(id: id);
  }

  Future<void> cancelAllScheduledNotifications() async {
    await _localNotifications.cancelAll();
  }

  // Backend integration methods
  /// Register the FCM token with the backend. Returns true on confirmed
  /// success, false on failure. When auth isn't ready yet (common during
  /// first-launch race with FirebaseAuth) the call is queued via
  /// DataSyncService so it retries automatically when auth + connectivity
  /// catch up. Previously this method silently dropped the call.
  Future<bool> _registerTokenWithBackend(String token) async {
    final tzOffsetMinutes = DateTime.now().timeZoneOffset.inMinutes;

    try {
      final apiService = ApiService();

      if (!apiService.isAuthenticated) {
        AppLogger.warning(
          'Auth not ready — queueing FCM token registration for later',
        );
        await DataSyncService().queueSync(
          'fcm_token_register',
          {
            'fcmToken': token,
            'platform': 'flutter',
            'timezoneOffsetMinutes': tzOffsetMinutes,
          },
          priority: SyncPriority.high,
        );
        return false;
      }

      final success = await apiService.registerFcmToken(
        fcmToken: token,
        platform: 'flutter',
        timezoneOffsetMinutes: tzOffsetMinutes,
      );

      if (success) {
        AppLogger.network('FCM token registered with backend successfully');
        await _syncTopicSubscriptions(token);
        return true;
      } else {
        AppLogger.error(
          'Failed to register FCM token with backend — queueing for retry',
        );
        await DataSyncService().queueSync(
          'fcm_token_register',
          {
            'fcmToken': token,
            'platform': 'flutter',
            'timezoneOffsetMinutes': tzOffsetMinutes,
          },
          priority: SyncPriority.high,
        );
        return false;
      }
    } catch (e) {
      AppLogger.error('Error registering token with backend', e);
      return false;
    }
  }

  Future<void> _syncTopicSubscriptions(String token) async {
    try {
      AppLogger.network('Syncing topic subscriptions with backend');

      // Get recommended topics based on user preferences
      // ignore: deprecated_member_use
      final topics = BackendService().getRecommendedTopics(
        tournamentsEnabled:
            _notificationPreferences[NotificationType.tournament] ?? true,
        socialEnabled:
            _notificationPreferences[NotificationType.social] ?? true,
        achievementsEnabled:
            _notificationPreferences[NotificationType.achievement] ?? true,
        dailyRemindersEnabled:
            _notificationPreferences[NotificationType.dailyReminder] ?? true,
        specialEventsEnabled:
            _notificationPreferences[NotificationType.specialEvent] ?? true,
      );

      // Use batch endpoint to subscribe to all topics in a single API call
      final apiService = ApiService();
      final success = await apiService.batchSubscribeToTopics(token, topics);

      if (success) {
        AppLogger.network(
          'Topic subscriptions synced (batch): ${topics.join(', ')}',
        );
      } else {
        AppLogger.warning('Batch topic subscription failed, trying individually');
        // Fallback to individual subscriptions
        for (final topic in topics) {
          await apiService.subscribeToTopic(token, topic);
        }
      }
    } catch (e) {
      AppLogger.error('Error syncing topic subscriptions', e);
    }
  }

  /// Initialize backend integration after user authentication.
  ///
  /// Idempotent — safe to call multiple times. The `_backendIntegrationDone`
  /// latch only flips to true on **confirmed** registration success. Earlier
  /// versions flipped it unconditionally after the call, which permanently
  /// blocked retries when the first attempt failed (auth not ready, offline,
  /// 5xx, etc.) — the symptom the user described as "offline functionality
  /// silently killing notifications."
  Future<void> initializeBackendIntegration() async {
    try {
      if (_backendIntegrationDone) {
        AppLogger.info('Backend integration already completed, skipping');
        return;
      }

      if (_fcmToken == null) {
        AppLogger.warning(
          'Cannot initialize backend integration: No FCM token available',
        );
        return;
      }

      AppLogger.info('🔗 Initializing backend integration');

      if (kDebugMode) {
        debugPrint('');
        debugPrint('🔗 ======== BACKEND INTEGRATION ========');
        debugPrint('📱 FCM Token being registered with backend:');
        debugPrint(_fcmToken!);
        debugPrint('🔗 =====================================');
        debugPrint('');
      }

      // Register token with backend. _registerTokenWithBackend now queues
      // on auth-not-ready / failure, so we don't need to gate on
      // ApiService.isAuthenticated here.
      final success = await _registerTokenWithBackend(_fcmToken!);

      // CRITICAL: only set the latch on real success. A failed attempt
      // gets retried via the DataSyncService queue OR on the next
      // initializeBackendIntegration() call.
      if (success) {
        _backendIntegrationDone = true;
        AppLogger.info('✅ Backend integration initialized');
      } else {
        AppLogger.warning(
          '⚠️ Backend integration deferred (queued for retry)',
        );
      }
    } catch (e) {
      AppLogger.error('Failed to initialize backend integration', e);
    }
  }

  /// Reset the integration latch so a subsequent login / re-init can
  /// re-register the token. Call from auth flow on logout.
  void resetBackendIntegration() {
    _backendIntegrationDone = false;
  }

  /// Send achievement notification via backend
  Future<void> triggerAchievementNotification(
    String achievementName,
    String achievementId,
  ) async {
    if (_fcmToken == null) {
      AppLogger.warning('Cannot send achievement notification: No FCM token');
      return;
    }

    try {
      // ignore: deprecated_member_use
      await BackendService().sendAchievementNotification(
        fcmToken: _fcmToken!,
        achievementName: achievementName,
        achievementId: achievementId,
      );

      AppLogger.info(
        '🏆 Achievement notification sent via backend: $achievementName',
      );
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
      // ignore: deprecated_member_use
      await BackendService().sendFriendRequestNotification(
        targetFcmToken: targetFcmToken,
        senderName: senderName,
        senderId: senderId,
      );

      AppLogger.info('👥 Friend request notification sent via backend');
    } catch (e) {
      AppLogger.error(
        'Failed to send friend request notification via backend',
        e,
      );
    }
  }

  /// Send test notification via backend
  Future<void> sendTestNotificationViaBackend() async {
    if (_fcmToken == null) {
      AppLogger.warning('Cannot send test notification: No FCM token');
      return;
    }

    try {
      // ignore: deprecated_member_use
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
  Future<void> updateNotificationEnabled(
    NotificationType type,
    bool enabled,
  ) async {
    _notificationPreferences[type] = enabled;
    AppLogger.info(
      '⚙️ ${type.key} notifications ${enabled ? 'enabled' : 'disabled'}',
    );

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
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  AppLogger.info('📨 Background message received: ${message.messageId}');

  // Handle background message
  // Note: Limited functionality in background mode
}
