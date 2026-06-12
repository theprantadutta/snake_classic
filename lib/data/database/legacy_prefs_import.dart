import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';

/// One-time SharedPreferences → Drift import for settings that used to live
/// outside the synced GameSettings row:
///
/// - theme (`selected_theme`) + trail (`trail_system_enabled`) — previously
///   owned by the now-removed PreferencesService, so the Drift columns the
///   sync engine pushes were never written and shipped stale defaults.
/// - the five `notification_<key>` category opt-ins — previously
///   device-only, now synced so the backend can gate per-category pushes.
///
/// Runs once per install, guarded by [_sentinelKey]. Only keys that EXIST in
/// SharedPreferences are imported (a fresh install or post-restore device has
/// none), so a backend snapshot restore is never clobbered. The whole import
/// is a single DAO write → one transaction, one sync_outbox row, and a fresh
/// updatedAt that correctly wins last-write-wins against the stale defaults
/// any earlier app version pushed to the backend.
Future<void> runLegacyPrefsImport(AppDatabase database) async {
  const sentinelKey = 'legacy_prefs_imported_v12';

  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(sentinelKey) ?? false) return;

    const notificationKeys = [
      'daily_reminder',
      'tournament',
      'achievement',
      'social',
      'special_event',
    ];

    var patch = const GameSettingsCompanion();
    final imported = <String>[];
    final consumedPrefKeys = <String>[];

    final themeIndex = prefs.getInt(GameConstants.selectedThemeKey);
    if (themeIndex != null) {
      patch = patch.copyWith(
        themeIndex: Value(
          themeIndex.clamp(0, GameTheme.values.length - 1),
        ),
      );
      imported.add('theme=$themeIndex');
      consumedPrefKeys.add(GameConstants.selectedThemeKey);
    }

    final trailEnabled = prefs.getBool(GameConstants.trailSystemEnabledKey);
    if (trailEnabled != null) {
      patch = patch.copyWith(trailSystemEnabled: Value(trailEnabled));
      imported.add('trail=$trailEnabled');
      consumedPrefKeys.add(GameConstants.trailSystemEnabledKey);
    }

    for (final key in notificationKeys) {
      final prefKey = 'notification_$key';
      final enabled = prefs.getBool(prefKey);
      if (enabled == null) continue;
      patch = patch.copyWith(
        notifyDailyReminder:
            key == 'daily_reminder' ? Value(enabled) : patch.notifyDailyReminder,
        notifyTournament:
            key == 'tournament' ? Value(enabled) : patch.notifyTournament,
        notifyAchievement:
            key == 'achievement' ? Value(enabled) : patch.notifyAchievement,
        notifySocial: key == 'social' ? Value(enabled) : patch.notifySocial,
        notifySpecialEvent:
            key == 'special_event' ? Value(enabled) : patch.notifySpecialEvent,
      );
      imported.add('$prefKey=$enabled');
      consumedPrefKeys.add(prefKey);
    }

    if (imported.isNotEmpty) {
      await database.settingsDao.applyLegacyPrefsImport(patch);
      for (final key in consumedPrefKeys) {
        await prefs.remove(key);
      }
      AppLogger.info(
        'Legacy prefs imported into Drift settings: ${imported.join(', ')}',
      );
    }

    await prefs.setBool(sentinelKey, true);
  } catch (e) {
    // Non-fatal: defaults apply and the import retries next launch
    // (sentinel only set on success).
    AppLogger.error('Legacy prefs import failed', e);
  }
}
