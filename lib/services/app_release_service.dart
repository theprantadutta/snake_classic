import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/app_release_policy.dart';
import 'package:snake_classic/utils/logger.dart';

/// Tells an iOS build that a newer one is on the App Store.
///
/// Android does not come through here. Google Play has a real in-app update
/// API and [InAppUpdateService] uses it: Play knows what it published, can
/// download in the background, and can install without leaving the app.
/// None of that exists on iOS, where the best available answer is a dialog
/// and a link out to the store — so the version to compare against has to
/// come from our own backend, which is what this fetches.
///
/// One check per process, after the home screen is up rather than during
/// bootstrap, matching the Android service. The snooze stamp is device-only
/// state (this handset's last refusal), so it lives in SharedPreferences,
/// not Drift.
class AppReleaseService {
  static final AppReleaseService _instance = AppReleaseService._internal();
  factory AppReleaseService() => _instance;
  AppReleaseService._internal();

  @visibleForTesting
  AppReleaseService.forTesting();

  static const _kDeclinedAtMs = 'app_release_declined_ms';

  bool _checkedThisSession = false;

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
    @visibleForTesting bool force = false,
  }) async {
    if (!force) {
      if (!Platform.isIOS) return UpdatePrompt.none;
      if (kDebugMode) {
        AppLogger.info('Skipping app-release check in debug mode');
        return UpdatePrompt.none;
      }
      if (_checkedThisSession) return UpdatePrompt.none;
      _checkedThisSession = true;
    }

    try {
      final response = await (api ?? ApiService()).getAppRelease('ios');
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

      final prompt = AppReleasePolicy.decide(
        enabled: enabled,
        currentVersion: current,
        latestVersion: latest,
        minimumSupportedVersion: minimum,
        sinceDeclined: sinceDeclined,
      );

      // Only publish the destination once there is something to show, so a
      // stale URL can never be used by a dialog that should not open.
      if (prompt != UpdatePrompt.none) {
        storeUrl = url;
        latestVersion = latest;
      }

      AppLogger.info(
        'App release check: current=$current, latest=$latest, '
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
