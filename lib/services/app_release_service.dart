import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/app_release_policy.dart';
import 'package:snake_classic/utils/logger.dart';

/// Compares this build with the release policy the operator sets on the
/// dashboard (App Releases page, `GET /app-release/{platform}`).
///
/// * **iOS:** the whole update prompt. The App Store has no in-app update
///   API, so both the optional "newer build" notice and the forced floor
///   come from here.
/// * **Android (8.1.1+):** only the forced floor ("minimum supported
///   version"). Routine updates stay with Google Play's own flow in
///   [InAppUpdateService]; this exists so the owner can force everyone off a
///   broken build (owner, 2026-11-25, after 8.0.2 blanked banners). The
///   blocking dialog's Update button runs Play's immediate flow, falling back
///   to the Play listing.
///
/// One check per process, after the home screen is up rather than during
/// bootstrap; later calls share the same future, so Home's prompt queue can
/// wait for it. The snooze stamp is device-only state (this handset's last
/// refusal), so it lives in SharedPreferences, not Drift.
class AppReleaseService {
  static final AppReleaseService _instance = AppReleaseService._internal();
  factory AppReleaseService() => _instance;
  AppReleaseService._internal();

  @visibleForTesting
  AppReleaseService.forTesting();

  static const _kDeclinedAtMs = 'app_release_declined_ms';

  /// Used when the Android policy row has no store URL.
  static const playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.pranta.snakeclassic';

  Future<UpdatePrompt>? _sessionCheck;

  /// True once this session's check said the build is below the floor.
  bool get updateRequired => _updateRequired;
  bool _updateRequired = false;

  /// Where the update button should send the player. Null until a check has
  /// succeeded.
  String? storeUrl;

  /// The version the store is supposed to have, for display in the dialog.
  String? latestVersion;

  /// Decide what to show. Never throws: a failed check is a log line and
  /// [UpdatePrompt.none], never a blocked launch.
  Future<UpdatePrompt> check({
    @visibleForTesting ApiService? api,
    @visibleForTesting String? currentVersionOverride,
    @visibleForTesting String? platformOverride,
    @visibleForTesting bool force = false,
  }) {
    if (force) {
      return _runCheck(
        api: api,
        currentVersionOverride: currentVersionOverride,
        platform: platformOverride ?? _platform(),
      );
    }
    final platform = _platform();
    if (platform == null) return Future.value(UpdatePrompt.none);
    if (kDebugMode) {
      AppLogger.info('Skipping app-release check in debug mode');
      return Future.value(UpdatePrompt.none);
    }
    return _sessionCheck ??= _runCheck(platform: platform);
  }

  static String? _platform() {
    if (kIsWeb) return null;
    if (Platform.isIOS) return 'ios';
    if (Platform.isAndroid) return 'android';
    return null;
  }

  Future<UpdatePrompt> _runCheck({
    ApiService? api,
    String? currentVersionOverride,
    required String? platform,
  }) async {
    if (platform == null) return UpdatePrompt.none;
    try {
      final response = await (api ?? ApiService()).getAppRelease(platform);
      if (response == null) return UpdatePrompt.none;

      final enabled = response['enabled'] as bool? ?? false;
      final latest = response['latest_version'] as String?;
      final minimum = response['minimum_supported_version'] as String?;
      final url = response['store_url'] as String?;

      final current = currentVersionOverride ??
          (await PackageInfo.fromPlatform()).version;

      final prefs = await SharedPreferences.getInstance();
      final declinedMs = prefs.getInt(_kDeclinedAtMs);
      final sinceDeclined = declinedMs == null
          ? null
          : Duration(
              milliseconds: DateTime.now().millisecondsSinceEpoch - declinedMs,
            );

      var prompt = AppReleasePolicy.decide(
        enabled: enabled,
        currentVersion: current,
        latestVersion: latest,
        minimumSupportedVersion: minimum,
        sinceDeclined: sinceDeclined,
      );

      // Android: Play owns routine updates (InAppUpdateService). Only the
      // forced floor comes from here, or players would get two offers.
      final android = platform == 'android';
      if (android && prompt == UpdatePrompt.optional) {
        prompt = UpdatePrompt.none;
      }

      // Only publish the destination once there is something to show, so a
      // stale URL can never be used by a dialog that should not open.
      if (prompt != UpdatePrompt.none) {
        storeUrl = (url == null || url.trim().isEmpty)
            ? (android ? playStoreUrl : null)
            : url;
        latestVersion = latest;
      }
      _updateRequired = prompt == UpdatePrompt.required;

      AppLogger.info(
        'App release check ($platform): current=$current, latest=$latest, '
        'minimum=$minimum, prompt=${prompt.name}',
      );
      return prompt;
    } catch (e, stackTrace) {
      AppLogger.error('App release check failed', e, stackTrace);
      return UpdatePrompt.none;
    }
  }

  /// Remember that the player said "later", so the optional prompt is not
  /// repeated on the next launch.
  Future<void> recordDeclined() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        _kDeclinedAtMs,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (e) {
      // A snooze that fails to persist costs one extra prompt, which is not
      // worth surfacing to the player.
      AppLogger.error('Could not record update decline', e);
    }
  }
}
