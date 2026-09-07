import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/update_policy.dart';
import 'package:snake_classic/utils/logger.dart';

/// In-app updates from the Play Store (Android only).
///
/// Runs ONE check per process, after the home screen is up rather than in
/// the start-up bootstrap, and picks the flow with [UpdatePolicy]: flexible
/// by default — Play downloads while the player plays, and the app offers a
/// restart through [updateReadyToInstall] — and the blocking immediate flow
/// only for releases published with a high update priority. A declined
/// flexible offer is snoozed rather than re-asked on the next launch.
///
/// Device-only state (the snooze stamp) lives in SharedPreferences: it is
/// about this handset's last refusal, nothing another device should see.
class InAppUpdateService {
  static final InAppUpdateService _instance = InAppUpdateService._internal();
  factory InAppUpdateService() => _instance;
  InAppUpdateService._internal();

  static const _kDeclinedAtMs = 'in_app_update_declined_ms';

  bool _checkedThisSession = false;
  AppUpdateInfo? _updateInfo;
  StreamSubscription<InstallStatus>? _installSub;

  /// True once a flexible update has finished downloading and only needs a
  /// restart to apply. The home screen strip and the pause menu button
  /// listen to this.
  final ValueNotifier<bool> updateReadyToInstall = ValueNotifier(false);

  /// Check once per session and start whichever flow the policy picks.
  /// Never throws; a failed check is a log line, never a blocked launch.
  Future<void> checkForUpdate() async {
    if (!Platform.isAndroid) return;
    if (kDebugMode) {
      AppLogger.info('Skipping in-app update check in debug mode');
      return;
    }
    if (_checkedThisSession) return;
    _checkedThisSession = true;

    try {
      final info = await InAppUpdate.checkForUpdate().timeout(
        const Duration(seconds: 5),
      );
      _updateInfo = info;

      // A download from a previous session that finished while we were
      // away: nothing to start, just offer the restart.
      if (info.installStatus == InstallStatus.downloaded) {
        updateReadyToInstall.value = true;
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      final declinedMs = prefs.getInt(_kDeclinedAtMs);
      final sinceDeclined = declinedMs == null
          ? null
          : Duration(
              milliseconds:
                  DateTime.now().millisecondsSinceEpoch - declinedMs,
            );

      final flow = UpdatePolicy.decide(
        updateAvailable:
            info.updateAvailability == UpdateAvailability.updateAvailable,
        priority: info.updatePriority,
        immediateAllowed: info.immediateUpdateAllowed,
        flexibleAllowed: info.flexibleUpdateAllowed,
        sinceDeclined: sinceDeclined,
      );
      AppLogger.info(
        'In-app update: available=${info.updateAvailability.name}, '
        'priority=${info.updatePriority}, flow=${flow.name}',
      );

      switch (flow) {
        case UpdateFlow.none:
          return;
        case UpdateFlow.immediate:
          await _runImmediate();
        case UpdateFlow.flexible:
          await _runFlexible(prefs);
      }
    } catch (e, stackTrace) {
      AppLogger.error('In-app update check failed', e, stackTrace);
    }
  }

  /// The blocking Play flow. Returns when the update installed (the app is
  /// restarted by Play) or the player backed out of it.
  Future<void> _runImmediate() async {
    try {
      final result = await InAppUpdate.performImmediateUpdate();
      AppLogger.info('Immediate update: ${result.name}');
    } catch (e, stackTrace) {
      AppLogger.error('Immediate update failed', e, stackTrace);
    }
  }

  /// Ask Play to download in the background. The player sees one small
  /// Play dialog; "No thanks" is remembered for [UpdatePolicy.snooze].
  Future<void> _runFlexible(SharedPreferences prefs) async {
    _installSub ??= InAppUpdate.installUpdateListener.listen(
      (status) {
        AppLogger.info('In-app update install status: ${status.name}');
        if (status == InstallStatus.downloaded) {
          updateReadyToInstall.value = true;
        } else if (status == InstallStatus.installed ||
            status == InstallStatus.failed ||
            status == InstallStatus.canceled) {
          updateReadyToInstall.value = false;
        }
      },
      onError: (Object e) =>
          AppLogger.error('In-app update status stream failed', e),
    );

    try {
      final result = await InAppUpdate.startFlexibleUpdate();
      AppLogger.info('Flexible update: ${result.name}');
      if (result == AppUpdateResult.userDeniedUpdate) {
        await prefs.setInt(
          _kDeclinedAtMs,
          DateTime.now().millisecondsSinceEpoch,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Flexible update failed to start', e, stackTrace);
    }
  }

  /// Apply a downloaded flexible update. Play restarts the app.
  Future<void> completeUpdate() async {
    try {
      await InAppUpdate.completeFlexibleUpdate();
    } catch (e, stackTrace) {
      AppLogger.error('Completing the update failed', e, stackTrace);
      updateReadyToInstall.value = false;
    }
  }

  /// Whether Play reported an update on the last check (for UI purposes).
  bool get isUpdateAvailable =>
      _updateInfo?.updateAvailability == UpdateAvailability.updateAvailable;
}
