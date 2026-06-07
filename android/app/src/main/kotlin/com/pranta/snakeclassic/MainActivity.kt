package com.pranta.snakeclassic

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Two things happen here, both required for Android 15+ (SDK 35)
    // compliance and to match the original "status bar hidden, nav bar
    // visible" look the app shipped with:
    //
    //   1. setDecorFitsSystemWindows(window, false) — explicit edge-to-edge
    //      opt-in. Flutter 3.27+ does this internally when targetSdk >= 35
    //      but Play Console's bytecode scanner only sees this class, so we
    //      call it explicitly to clear "Edge-to-edge may not display for
    //      all users" warnings.
    //
    //   2. WindowInsetsController.hide(statusBars()) — the modern, non-
    //      deprecated way to hide ONLY the status bar app-wide. Pre-Android
    //      15 we used SystemUiMode.manual with [SystemUiOverlay.bottom] in
    //      Dart, but that path routes through setStatusBarColor() which is
    //      what triggers Play Console's "deprecated APIs for edge-to-edge"
    //      warning. WindowInsetsController is the Android-native
    //      replacement and doesn't trigger any deprecation flags.
    //
    //      BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE lets users swipe down
    //      from the top to peek at notifications momentarily, then the
    //      bar auto-hides — same pattern most games use.
    //
    // See flutter/flutter#183372 for the deprecated-API thread that
    // motivated this.
    //
    // We use WindowCompat.setDecorFitsSystemWindows(window, false) rather
    // than androidx.activity.enableEdgeToEdge() because the latter is an
    // extension on ComponentActivity — FlutterActivity inherits from plain
    // Activity, so the extension doesn't apply.
    override fun onCreate(savedInstanceState: Bundle?) {
        WindowCompat.setDecorFitsSystemWindows(window, false)
        super.onCreate(savedInstanceState)

        val controller = WindowInsetsControllerCompat(window, window.decorView)
        controller.hide(WindowInsetsCompat.Type.statusBars())
        controller.systemBarsBehavior =
            WindowInsetsControllerCompat.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE

        createNotificationChannel()
    }

    // Deep link straight to THIS app's system notification settings.
    // Needed by the in-app permission primer: once POST_NOTIFICATIONS has
    // been permanently denied, Android never re-shows the OS prompt — the
    // settings page is the only way a user can turn notifications back on.
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "snake_classic/notification_settings"
        ).setMethodCallHandler { call, result ->
            if (call.method == "open") {
                val intent = Intent(Settings.ACTION_APP_NOTIFICATION_SETTINGS).apply {
                    putExtra(Settings.EXTRA_APP_PACKAGE, packageName)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                startActivity(intent)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }

    // https://github.com/firebase/flutterfire/issues/1327#issuecomment-623399564
    // Create the high-importance notification channel NATIVELY, on every
    // launch, before any Dart code runs. The Dart side
    // (NotificationService._initializeLocalNotifications) also creates this
    // channel — but only once the user reaches the home screen and init
    // completes. Until then a fresh install (or cleared-data / new device)
    // has NO channel, and an FCM push that targets
    // "snake_classic_notifications" on Android 8+ is silently dropped or
    // demoted by the system. Creating it here guarantees the channel exists
    // from the first millisecond of app life. createNotificationChannel is
    // idempotent (same id → no-op), so the later Dart creation is harmless.
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = getString(R.string.default_notification_channel_id)
            val name = getString(R.string.default_notification_channel_name)
            val descriptionText = getString(R.string.default_notification_channel_desc)
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(channelId, name, importance).apply {
                description = descriptionText
                enableVibration(true)
            }
            val notificationManager: NotificationManager =
                getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
