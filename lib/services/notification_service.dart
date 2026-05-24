import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Timezone data + types — transitive dep via flutter_local_notifications, no
// pubspec entry needed. We only ever use tz.UTC for relative scheduling so
// we deliberately skip setLocalLocation (which would require resolving the
// device's IANA zone name and pulling in flutter_timezone on iOS).
import 'package:timezone/data/latest_10y.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import '../utils/logger.dart';
import 'api_service.dart';
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
  bool _timezonesInitialized = false;

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

    // Create notification channel for Android, then explicitly request
    // POST_NOTIFICATIONS at runtime via flutter_local_notifications.
    //
    // Why not rely on firebase_messaging.requestPermission for this?
    // Per the FlutterFire team's tracking issue, FCM's requestPermission
    // does NOT reliably trigger the Android 13+ system dialog — on a
    // newly-installed device targeting API 33+ the user is silently in
    // a "denied" state and every subsequent notification is dropped
    // without any error log. Going through the local-notifications
    // plugin's own request is the documented Android path and is
    // idempotent (returns immediately if already granted/denied).
    if (defaultTargetPlatform == TargetPlatform.android) {
      const channel = AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );

      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      await androidPlugin?.createNotificationChannel(channel);

      final granted = await androidPlugin?.requestNotificationsPermission();
      AppLogger.info(
        '🔔 Android notifications permission requested. Granted: $granted',
      );
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

  // Reserved ID for the debug-only "schedule test notification" feature
  // surfaced in Settings → TEST NOTIFICATIONS. Single ID so re-scheduling
  // overwrites the pending one — at most one pending test at a time.
  static const int _scheduledTestNotificationId = 1002;

  /// Lazily initialize the IANA timezone DB (the `timezone` package's
  /// dataset). zonedSchedule needs a tz.Location, which requires this
  /// init. Idempotent — safe to call repeatedly. We use the 10-year
  /// dataset rather than the full one (~100KB instead of ~600KB) since
  /// nothing in this app schedules beyond a decade out.
  void _ensureTimezonesInitialized() {
    if (_timezonesInitialized) return;
    tz_data.initializeTimeZones();
    _timezonesInitialized = true;
  }

  /// Schedule a one-shot test notification to fire at [fireAt] (a wall-
  /// clock local time on the device). Backed by `zonedSchedule` so the
  /// OS scheduler owns the trigger — fires even when the app is killed.
  ///
  /// Debug-only feature; called by the Settings test panel. Single
  /// reserved ID means a subsequent call overwrites any pending test
  /// notification (at most one in flight).
  ///
  /// Android schedule mode is inexactAllowWhileIdle so we don't require
  /// the SCHEDULE_EXACT_ALARM permission (which this app intentionally
  /// strips from the manifest for Play Store policy reasons). The
  /// trade-off: Doze mode can delay delivery by up to ~15 minutes.
  Future<void> scheduleTestNotificationAt(DateTime fireAt) async {
    _ensureTimezonesInitialized();

    // Convert wall-clock DateTime to UTC TZDateTime. The notification
    // fires at the same absolute instant regardless of which Location
    // we use — tz.UTC is always available without setLocalLocation.
    final fireAtUtc = tz.TZDateTime.from(fireAt.toUtc(), tz.UTC);

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

    final delay = fireAt.difference(DateTime.now());
    final delaySummary = delay.inSeconds < 60
        ? '${delay.inSeconds}s'
        : delay.inMinutes < 60
            ? '${delay.inMinutes}m'
            : '${delay.inHours}h ${delay.inMinutes % 60}m';

    await _localNotifications.zonedSchedule(
      id: _scheduledTestNotificationId,
      title: '⏰ Scheduled test fired',
      body:
          'Your scheduled test notification arrived (was queued $delaySummary ahead).',
      scheduledDate: fireAtUtc,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: jsonEncode({'route': 'home', 'source': 'test_schedule'}),
    );

    AppLogger.info('⏰ Test notification scheduled for $fireAt ($delaySummary ahead)');
  }

  /// Cancel a pending scheduled test notification. No-op if nothing
  /// pending under the reserved ID.
  Future<void> cancelScheduledTestNotification() async {
    await _localNotifications.cancel(id: _scheduledTestNotificationId);
    AppLogger.info('🔕 Scheduled test notification cancelled');
  }

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

    _ensureTimezonesInitialized();

    final message = _pickDailyReminderMessage(
      currentWinStreak: currentWinStreak,
      hasIncompleteDailyChallenge: hasIncompleteDailyChallenge,
      highScore: highScore,
    );

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

    // Pin the daily reminder to a fixed time-of-day (20:00 local — mobile
    // gaming's prime evening window). If "now" is already past today's
    // 20:00, schedule the first fire for tomorrow at 20:00; otherwise
    // schedule for today at 20:00. After the first fire,
    // matchDateTimeComponents.time tells the OS to repeat at the SAME
    // TIME-OF-DAY every subsequent day — no drift, no daily setup needed.
    //
    // Why a FIXED anchor rather than "now + 23h"?
    // This method is called on every app launch AND after every game end
    // (see UnifiedUserService._initializeNotificationIntegration and
    // GameCubit's post-game flow). With a relative "now + 23h" anchor,
    // each call cancels the pending schedule and pushes the next fire
    // another 23 hours into the future — so an actively-engaged player
    // never actually sees the notification, because tomorrow's fire keeps
    // getting bumped to the day after every time they open the app.
    // A fixed time-of-day makes cancel-and-reschedule idempotent: the new
    // schedule lands on the same 20:00 anchor regardless of when the user
    // re-opens the app.
    //
    // Why migrate from periodicallyShow(RepeatInterval.daily)?
    // periodicallyShow maps to AlarmManager.setInexactRepeating which on
    // modern Android (8+) is documented to drift over time and is
    // unreliable on some OEMs. zonedSchedule + matchDateTimeComponents
    // uses setAndAllowWhileIdle and re-schedules each fire, which is the
    // documented recommended pattern for reliable daily notifications.
    //
    // inexactAllowWhileIdle keeps us off the SCHEDULE_EXACT_ALARM Play
    // policy gate (manifest intentionally strips it).
    const reminderHourLocal = 20; // 8 PM
    final now = DateTime.now();
    var firstFireLocal = DateTime(
      now.year,
      now.month,
      now.day,
      reminderHourLocal,
    );
    if (!firstFireLocal.isAfter(now)) {
      firstFireLocal = firstFireLocal.add(const Duration(days: 1));
    }
    final firstFireTz = tz.TZDateTime.from(firstFireLocal.toUtc(), tz.UTC);

    try {
      await _localNotifications.zonedSchedule(
        id: _dailyReminderNotificationId,
        title: message.title,
        body: message.body,
        scheduledDate: firstFireTz,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: jsonEncode({'route': 'home', 'source': 'daily_reminder'}),
        matchDateTimeComponents: DateTimeComponents.time,
      );
      AppLogger.info(
        '⏰ Daily reminder scheduled: ${message.title} (first fire '
        '$firstFireLocal, then daily at same time-of-day)',
      );
    } catch (e) {
      AppLogger.error('Failed to schedule daily reminder', e);
    }
  }

  /// Pick the daily-reminder message variant from local game state.
  /// Streak-at-risk wins because losing a streak is the most urgent
  /// reason to come back; falls through to challenge → high-score →
  /// generic in priority order. Extracted so the debug preview button
  /// can call the same logic with the user's current state.
  ({String title, String body}) _pickDailyReminderMessage({
    required int currentWinStreak,
    required bool hasIncompleteDailyChallenge,
    required int highScore,
  }) {
    if (currentWinStreak >= 3) {
      return (
        title: '🔥 Your streak is on the line!',
        body:
            "You're on a $currentWinStreak-day streak. One game keeps it alive.",
      );
    } else if (hasIncompleteDailyChallenge) {
      return (
        title: '🎯 Today\'s challenge is waiting',
        body: 'Complete it before midnight to claim your rewards.',
      );
    } else if (highScore > 0) {
      return (
        title: 'Can you beat your best?',
        body: 'Your high score is $highScore. One round, one chance.',
      );
    } else {
      return (title: '🐍 Snake Classic', body: 'Pick up where you left off.');
    }
  }

  /// Fire the daily-reminder content NOW with the message it would
  /// have at the next scheduled fire. Debug-only — used by the Settings
  /// test panel to preview the exact notification a user will see
  /// without waiting 23 hours.
  Future<void> previewDailyReminder({
    required int currentWinStreak,
    required bool hasIncompleteDailyChallenge,
    required int highScore,
  }) async {
    final message = _pickDailyReminderMessage(
      currentWinStreak: currentWinStreak,
      hasIncompleteDailyChallenge: hasIncompleteDailyChallenge,
      highScore: highScore,
    );
    AppLogger.info('🧪 Previewing daily reminder: ${message.title}');
    await _showLocalNotification(
      title: message.title,
      body: message.body,
      type: NotificationType.dailyReminder,
      payload: jsonEncode({
        'route': 'home',
        'source': 'daily_reminder_preview',
      }),
    );
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

  /// Fire an achievement notification locally. Pre-refactor this went
  /// through the backend; post-refactor every notification is fired by
  /// the device itself.
  Future<void> triggerAchievementNotification(
    String achievementName,
    String achievementId,
  ) async {
    await showAchievementNotification(achievementName);
  }

  /// No-op in the offline-first build — friends/social features are
  /// disabled. Kept so existing call sites compile until the social
  /// code is cleaned up.
  Future<void> triggerFriendRequestNotification({
    required String targetUserId,
    required String targetFcmToken,
    required String senderName,
    required String senderId,
  }) async {}

  /// Fire a local test notification. The backend test endpoint was
  /// removed in the offline-first refactor; this is now identical to
  /// [sendTestLocalNotification] from the user's perspective.
  Future<void> sendTestNotificationViaBackend() async {
    await sendTestLocalNotification();
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

    // No backend topic sync in the offline-first build — preferences
    // are device-local and only gate which local notifications fire.
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

  /// Fire a local notification immediately for end-to-end testing of the
  /// permission + channel + display pipeline. Used by the "Send Local
  /// Test" button on the settings screen. If this is invisible, the
  /// problem is local (permission denied, OS blocked the channel, or
  /// notifications disabled in system settings) — no FCM / backend
  /// involvement at all.
  Future<void> sendTestLocalNotification() async {
    AppLogger.info('🧪 Firing test local notification');
    await _showLocalNotification(
      title: '🐍 Snake Classic Test',
      body: 'If you see this, local notifications work end-to-end.',
      payload: jsonEncode({'route': 'home', 'source': 'test'}),
    );
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
