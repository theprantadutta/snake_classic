package com.pranta.snakeclassic

import android.os.Bundle
import androidx.core.view.WindowCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.WindowInsetsControllerCompat
import io.flutter.embedding.android.FlutterActivity

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
    }
}
