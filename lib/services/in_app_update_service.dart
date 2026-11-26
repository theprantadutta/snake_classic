import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/analytics/retention_events.dart';
import 'package:snake_classic/services/update_policy.dart';
import 'package:snake_classic/utils/logger.dart';

/// In-app updates from the Play Store (Android only).
///
/// Runs ONE check per process, after the home screen is up rather than in
/// the start-up bootstrap, and picks the flow with [UpdatePolicy]:
///
/// * **offer** (routine release, since 8.1): [checkForUpdate] returns
///   [UpdateFlow.offer] and Home shows our "Update now / Later" dialog
///   (`showPlayUpdateOfferDialog`). "Update now" calls [acceptOffer], which
///   runs Play's blocking flow: download with progress, the game can't be
///   touched, and Play installs and restarts the app itself. The flexible
///   flow it replaced needed the player to tap Restart after the download,
///   and most never did (owner, 2026-11-23).
/// * **immediate** (urgent release, priority >= 4): the blocking flow
///   straight away.
/// * **flexible**: fallback when Play won't run the blocking flow.
///
/// A download that already finished (an older build's flexible flow, or the
/// fallback) is installed at the next launch on Home, before a game starts.
/// Deliberately NOT when the app goes to the background: a rewarded ad or a
/// paused mid-run game also backgrounds the app, and the install kills the
/// process.
///
/// Analytics: `play_update` (`stage`, optional `result`), see
/// [RetentionEvents.trackAppUpdate].
///
/// Device-only state (the snooze stamp) lives in SharedPreferences: it is
/// about this handset's last refusal, nothing another device should see.
class InAppUpdateService {
  static final InAppUpdateService _instance = InAppUpdateService._internal();
  factory InAppUpdateService() => _instance;
  InAppUpdateService._internal();

  static const _kDeclinedAtMs = 'in_app_update_declined_ms';

  AppUpdateInfo? _updateInfo;
  StreamSubscription<InstallStatus>? _installSub;

  /// True once a flexible update has finished downloading and only needs a
  /// restart to apply. The home screen strip and the pause menu button
  /// listen to this (fallback path only, plus the moment before the
  /// automatic install at launch).
  final ValueNotifier<bool> updateReadyToInstall = ValueNotifier(false);

  AnalyticsFacade? get _analytics =>
      getIt.isRegistered<AnalyticsFacade>() ? getIt<AnalyticsFacade>() : null;

  void _log(String stage, {String? result}) =>
      unawaited(_analytics?.trackAppUpdate(stage: stage, result: result));

  /// Check once per session. Runs the flows that need no UI from us
  /// (immediate, flexible, installing a finished download) and resolves to
  /// [UpdateFlow.offer] when Home should show the offer dialog. Later calls
  /// get the same future, so Home's post-frame kick-off and its prompt
  /// queue share one check. Never throws; a failed check is a log line and
  /// [UpdateFlow.none].
  Future<UpdateFlow> checkForUpdate() => _check ??= _runCheck();
  Future<UpdateFlow>? _check;

  /// True from an offer until the player answers it, so a re-created Home
  /// doesn't ask twice in one session.
  bool get offerPending => _offerPending;
  bool _offerPending = false;

  Future<UpdateFlow> _runCheck() async {
    if (!Platform.isAndroid) return UpdateFlow.none;
    if (kDebugMode) {
      AppLogger.info('Skipping in-app update check in debug mode');
      return UpdateFlow.none;
    }

    try {
      final info = await InAppUpdate.checkForUpdate().timeout(
        const Duration(seconds: 5),
      );
      _updateInfo = info;

      // A download from a previous session that finished while we were
      // away. We are on Home at launch, before any game: install it now
      // (Play restarts into the new version) instead of waiting for a
      // Restart tap that rarely comes.
      if (info.installStatus == InstallStatus.downloaded) {
        updateReadyToInstall.value = true;
        _log('auto_completed', result: 'home');
        await completeUpdate();
        return UpdateFlow.none;
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
          return UpdateFlow.none;
        case UpdateFlow.offer:
          _offerPending = true;
          return UpdateFlow.offer;
        case UpdateFlow.immediate:
          _log('urgent');
          await _runImmediate(prefs);
          return UpdateFlow.none;
        case UpdateFlow.flexible:
          _log('flexible_fallback');
          await _runFlexible(prefs);
          return UpdateFlow.none;
      }
    } catch (e, stackTrace) {
      AppLogger.error('In-app update check failed', e, stackTrace);
      return UpdateFlow.none;
    }
  }

  /// "Update now" on the offer dialog: Play's blocking flow.
  Future<void> acceptOffer() async {
    _offerPending = false;
    _log('accepted');
    final prefs = await SharedPreferences.getInstance();
    await _runImmediate(prefs);
  }

  /// "Later" on the offer dialog.
  Future<void> snoozeOffer() async {
    _offerPending = false;
    _log('snoozed');
    final prefs = await SharedPreferences.getInstance();
    await _recordDeclined(prefs);
  }

  Future<void> _recordDeclined(SharedPreferences prefs) => prefs.setInt(
    _kDeclinedAtMs,
    DateTime.now().millisecondsSinceEpoch,
  );

  /// The blocking Play flow. On success Play installs and restarts the app,
  /// so this usually never returns; it does when the player backs out of
  /// Play's screen (snoozed like "Later") or it fails.
  Future<void> _runImmediate(SharedPreferences prefs) async {
    try {
      final result = await InAppUpdate.performImmediateUpdate();
      AppLogger.info('Immediate update: ${result.name}');
      _log('immediate_result', result: result.name);
      if (result == AppUpdateResult.userDeniedUpdate) {
        await _recordDeclined(prefs);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Immediate update failed', e, stackTrace);
      _log('immediate_result', result: 'error');
    }
  }

  /// Fallback: ask Play to download in the background. The player sees one
  /// small Play dialog; "No thanks" is remembered for [UpdatePolicy.snooze].
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
        await _recordDeclined(prefs);
      }
    } catch (e, stackTrace) {
      AppLogger.error('Flexible update failed to start', e, stackTrace);
    }
  }

  /// The dashboard declared this build below the minimum supported version
  /// (the blocking dialog from [AppReleaseService]). Runs Play's blocking
  /// flow regardless of snoozes or priority. Returns false when Play can't
  /// run it (no update visible to this device yet, flow not allowed, or an
  /// error), so the caller can open the Play listing instead; true when
  /// Play's screen ran, whether or not the player went through with it.
  Future<bool> runRequiredUpdate() async {
    if (!Platform.isAndroid) return false;
    try {
      final info = await InAppUpdate.checkForUpdate().timeout(
        const Duration(seconds: 5),
      );
      _updateInfo = info;
      if (info.installStatus == InstallStatus.downloaded) {
        _log('required', result: 'downloaded');
        await completeUpdate();
        return true;
      }
      if (info.updateAvailability != UpdateAvailability.updateAvailable ||
          !info.immediateUpdateAllowed) {
        _log('required', result: 'unavailable');
        return false;
      }
      _log('required');
      final result = await InAppUpdate.performImmediateUpdate();
      AppLogger.info('Required update: ${result.name}');
      _log('immediate_result', result: result.name);
      return result != AppUpdateResult.inAppUpdateFailed;
    } catch (e, stackTrace) {
      AppLogger.error('Required update failed', e, stackTrace);
      _log('required', result: 'error');
      return false;
    }
  }

  /// Our dialog is on screen (logged here, not at decision time, so
  /// `offered` counts players who actually saw it).
  void markOfferShown() => _log('offered');

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
