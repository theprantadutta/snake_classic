import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/telemetry/telemetry_session_tracker.dart';
import 'package:snake_classic/services/telemetry/telemetry_uploader.dart';
import 'package:snake_classic/utils/logger.dart';

/// Wires the design-metrics telemetry to the app's lifecycle and network.
///
/// Kept out of the widget tree on purpose: an [AppLifecycleListener] owned
/// here sees every foreground/background transition no matter which screen
/// is up, and nothing in the UI has to remember to forward them.
///
///   * start → close the previous process's open session, flush.
///   * `paused` → end the session (it may continue if the app returns within
///     30 minutes), flush, stop the periodic flush.
///   * `resumed` → continue or begin a session, restart the periodic flush.
///   * connectivity back → flush.
class TelemetryService {
  TelemetryService({
    required this.tracker,
    required this.uploader,
    this._connectivity,
  });

  final TelemetrySessionTracker tracker;
  final TelemetryUploader uploader;
  final ConnectivityService? _connectivity;

  AppLifecycleListener? _lifecycle;
  bool _hadLink = true;
  bool _started = false;

  /// Begin tracking. Call once, after the database is open. Never throws.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      await tracker.start();
      _lifecycle = AppLifecycleListener(onStateChange: _onLifecycle);
      final connectivity = _connectivity;
      if (connectivity != null) {
        _hadLink = connectivity.hasInternetAccess;
        connectivity.addListener(_onConnectivityChanged);
      }
      uploader.startPeriodic();
      unawaited(uploader.flush());
    } catch (e) {
      AppLogger.error('Telemetry: start failed', e);
    }
  }

  void _onLifecycle(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        tracker.foregrounded();
        uploader.startPeriodic();
      // `paused` is the one state that means the app actually went away —
      // `inactive` also fires for a pulled-down notification shade and on
      // the way back in (see the same reasoning in main.dart). `detached`
      // follows `paused`, so it is a no-op unless `paused` never came.
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        if (!tracker.isForeground) return;
        tracker.backgrounded();
        uploader.stopPeriodic();
        unawaited(uploader.flush());
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        break;
    }
  }

  void _onConnectivityChanged() {
    final hasLink = _connectivity?.hasInternetAccess ?? true;
    if (hasLink && !_hadLink) unawaited(uploader.flush());
    _hadLink = hasLink;
  }

  void dispose() {
    _lifecycle?.dispose();
    _lifecycle = null;
    _connectivity?.removeListener(_onConnectivityChanged);
    uploader.stopPeriodic();
    tracker.dispose();
  }
}
