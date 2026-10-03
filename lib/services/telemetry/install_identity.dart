import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/config/ui_design.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// Who this install is, for the design-metrics telemetry: the install id
/// plus the build facts every request and every telemetry row carries.
///
/// **The install id lives in SharedPreferences, deliberately.** It is the
/// unit of analysis on the dashboard and must describe THIS install, not the
/// account: guests have no account at all and are exactly who the funnel
/// loses. CLAUDE.md's storage rule puts device-only state that never travels
/// in SharedPreferences, and it is where the one other per-install fact
/// already lives — FirstRunService's install stamp, which is what
/// `installed_at` is read from. Keeping the two side by side means they share
/// a lifetime: a reinstall resets both, nothing else does.
///
/// It is never synced, and logout never touches it: `clearAllData()` wipes
/// Drift tables, `ApiService.clearToken()` removes only the JWT keys.
class InstallIdentity {
  InstallIdentity({
    required this.installId,
    required this.appVersion,
    required this.build,
    required this.platform,
    this.design = kUiDesign,
  });

  /// Stand-in for code that runs before [load] — which the bootstrap does
  /// not allow, but which must not crash if it ever happens. Never uploaded:
  /// the uploader sends nothing until [current] is set.
  factory InstallIdentity.unloaded() => InstallIdentity(
        installId: '',
        appVersion: '0.0.0',
        build: 0,
        platform: platformName,
      );

  static const String installIdKey = 'telemetry_install_id';

  /// The identity loaded by [load]; null until then. Read synchronously by
  /// ApiService's header builder, which must work on requests issued before
  /// (or without) it — see [clientHeaders].
  static InstallIdentity? current;

  final String installId;
  final String appVersion;
  final int build;
  final String platform;
  final String design;

  /// The contract's platform names: `android` / `ios`, and the plain target
  /// name anywhere else (desktop and test runs).
  static String get platformName => switch (defaultTargetPlatform) {
        TargetPlatform.android => 'android',
        TargetPlatform.iOS => 'ios',
        final other => other.name.toLowerCase(),
      };

  /// Read (or mint, on the very first launch) the install id and the build
  /// facts, and publish them as [current]. Safe to call more than once.
  ///
  /// Never throws: a storage or plugin failure leaves a usable identity
  /// (a fresh id held in memory for this process, version `0.0.0`) rather
  /// than taking start-up down over telemetry.
  static Future<InstallIdentity> load({
    SharedPreferences? prefs,
    Future<PackageInfo> Function()? packageInfo,
  }) async {
    final existing = current;
    if (existing != null) return existing;

    String installId;
    try {
      final store = prefs ?? await SharedPreferences.getInstance();
      final stored = store.getString(installIdKey);
      if (stored != null && Uuid.isValidUUID(fromString: stored)) {
        installId = stored;
      } else {
        installId = const Uuid().v4();
        await store.setString(installIdKey, installId);
        AppLogger.lifecycle('InstallIdentity: new install id minted');
      }
    } catch (e) {
      AppLogger.error('InstallIdentity: install id unavailable', e);
      installId = const Uuid().v4();
    }

    var version = '0.0.0';
    var build = 0;
    try {
      final info = await (packageInfo ?? PackageInfo.fromPlatform)();
      version = info.version;
      build = int.tryParse(info.buildNumber) ?? 0;
    } catch (e) {
      AppLogger.error('InstallIdentity: package info unavailable', e);
    }

    return current = InstallIdentity(
      installId: installId,
      appVersion: version,
      build: build,
      platform: platformName,
    );
  }

  /// The headers the contract puts on EVERY API request, authenticated or
  /// not. Before [load] has run only the two compile-time facts are known,
  /// and the server treats every one of these as optional.
  static Map<String, String> get clientHeaders {
    final id = current;
    return {
      if (id != null) 'X-Install-Id': id.installId,
      if (id != null) 'X-App-Version': id.appVersion,
      if (id != null) 'X-App-Build': '${id.build}',
      'X-Platform': id?.platform ?? platformName,
      'X-UI-Design': id?.design ?? kUiDesign,
    };
  }

  @visibleForTesting
  static void resetForTest() => current = null;
}
