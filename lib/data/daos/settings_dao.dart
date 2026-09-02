import 'package:drift/drift.dart';
import 'package:snake_classic/data/database/app_database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [GameSettings, DevicePreferences])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  /// Watch settings changes for reactive UI
  Stream<GameSetting?> watchSettings() => select(gameSettings).watchSingleOrNull();

  /// Get current settings
  Future<GameSetting?> getSettings() => select(gameSettings).getSingleOrNull();

  /// Apply a partial update to the singleton settings row inside a
  /// transaction, bump both timestamps, and enqueue an outbox row so
  /// the SyncEngine knows the user's preferences need to round-trip
  /// to the backend.
  Future<void> _writeSettings(GameSettingsCompanion patch) async {
    final now = DateTime.now();
    await transaction(() async {
      await (update(gameSettings)..where((t) => t.id.equals(1))).write(
        patch.copyWith(
          lastUpdated: Value(now),
          updatedAt: Value(now),
        ),
      );
      await attachedDatabase.enqueueSyncOutbox(
        dataType: SyncDataType.settings,
        entityKey: 'settings:1',
      );
    });
  }

  /// Update theme index
  Future<void> updateTheme(int themeIndex) =>
      _writeSettings(GameSettingsCompanion(themeIndex: Value(themeIndex)));

  /// Update sound enabled
  Future<void> updateSoundEnabled(bool enabled) =>
      _writeSettings(GameSettingsCompanion(soundEnabled: Value(enabled)));

  /// Update music enabled
  Future<void> updateMusicEnabled(bool enabled) =>
      _writeSettings(GameSettingsCompanion(musicEnabled: Value(enabled)));

  /// Update D-Pad enabled
  Future<void> updateDPadEnabled(bool enabled) =>
      _writeSettings(GameSettingsCompanion(dPadEnabled: Value(enabled)));

  /// Update D-Pad position
  Future<void> updateDPadPosition(int positionIndex) =>
      _writeSettings(
          GameSettingsCompanion(dPadPositionIndex: Value(positionIndex)));

  /// Update board size
  Future<void> updateBoardSize(int boardSizeIndex) =>
      _writeSettings(GameSettingsCompanion(boardSizeIndex: Value(boardSizeIndex)));

  /// Update difficulty (starting-speed preset)
  Future<void> updateDifficulty(int difficultyIndex) =>
      _writeSettings(
          GameSettingsCompanion(difficultyIndex: Value(difficultyIndex)));

  /// Update high score
  Future<void> updateHighScore(int score) =>
      _writeSettings(GameSettingsCompanion(highScore: Value(score)));

  /// Update crash feedback duration
  Future<void> updateCrashFeedbackDuration(int seconds) =>
      _writeSettings(
          GameSettingsCompanion(crashFeedbackDurationSeconds: Value(seconds)));

  /// Update trail system enabled
  Future<void> updateTrailSystemEnabled(bool enabled) =>
      _writeSettings(
          GameSettingsCompanion(trailSystemEnabled: Value(enabled)));

  /// Update screen shake enabled
  Future<void> updateScreenShakeEnabled(bool enabled) =>
      _writeSettings(
          GameSettingsCompanion(screenShakeEnabled: Value(enabled)));

  /// Update haptics (vibration) enabled
  Future<void> updateHapticsEnabled(bool enabled) =>
      _writeSettings(GameSettingsCompanion(hapticsEnabled: Value(enabled)));

  /// Update one or more per-category notification opt-ins. Null = leave
  /// unchanged. Single transaction + single outbox row regardless of how
  /// many categories change.
  Future<void> updateNotificationPrefs({
    bool? dailyReminder,
    bool? tournament,
    bool? achievement,
    bool? social,
    bool? specialEvent,
  }) =>
      _writeSettings(GameSettingsCompanion(
        notifyDailyReminder:
            dailyReminder == null ? const Value.absent() : Value(dailyReminder),
        notifyTournament:
            tournament == null ? const Value.absent() : Value(tournament),
        notifyAchievement:
            achievement == null ? const Value.absent() : Value(achievement),
        notifySocial: social == null ? const Value.absent() : Value(social),
        notifySpecialEvent:
            specialEvent == null ? const Value.absent() : Value(specialEvent),
      ));

  /// One-time SharedPreferences→Drift import (theme, trail, notification
  /// opt-ins — see legacy_prefs_import.dart). Routed through [_writeSettings]
  /// so the whole import is one transaction with one sync_outbox row and a
  /// fresh updatedAt, which correctly wins LWW over any stale backend row.
  Future<void> applyLegacyPrefsImport(GameSettingsCompanion patch) =>
      _writeSettings(patch);

  /// Update the app language override. Null = follow the device locale.
  Future<void> updateLocaleCode(String? localeCode) =>
      _writeSettings(GameSettingsCompanion(localeCode: Value(localeCode)));

  /// Update selected skin
  Future<void> updateSelectedSkin(String? skinId) =>
      _writeSettings(GameSettingsCompanion(selectedSkinId: Value(skinId)));

  /// Update selected trail
  Future<void> updateSelectedTrail(String? trailId) =>
      _writeSettings(GameSettingsCompanion(selectedTrailId: Value(trailId)));

  /// Cloud-snapshot apply path. Writes the singleton settings row
  /// without enqueueing an outbox marker so a first-sign-in restore
  /// doesn't echo the data back as a push. Skips the timestamp bump
  /// — the patch carries the cloud's UpdatedAt verbatim.
  Future<void> applySettingsSnapshot(GameSettingsCompanion patch) async {
    await into(gameSettings).insertOnConflictUpdate(
      patch.copyWith(id: const Value(1)),
    );
  }

  // ==================== Device preferences ====================
  //
  // Deliberately NOT routed through [_writeSettings]: these describe the
  // handset, not the account, so they must never enqueue a sync outbox row.
  // See [DevicePreferences] for why.

  /// Watch the device-local preferences row.
  Stream<DevicePreference?> watchDevicePreferences() =>
      select(devicePreferences).watchSingleOrNull();

  /// Read the device-local preferences row. Null only in the window before
  /// [AppDatabase.initializeDefaults] has seeded it.
  Future<DevicePreference?> getDevicePreferences() =>
      select(devicePreferences).getSingleOrNull();

  /// Whether this device opts into its display's highest refresh rate.
  /// Defaults to true when the row has not been seeded yet.
  Future<bool> isHighRefreshRateEnabled() async {
    final prefs = await getDevicePreferences();
    return prefs?.highRefreshRateEnabled ?? true;
  }

  /// Persist the high-refresh-rate choice for this device only.
  ///
  /// Upserts rather than updates: a device whose v21 migration ran but whose
  /// `initializeDefaults` seed has not yet landed would otherwise silently
  /// write zero rows and lose the user's tap.
  Future<void> updateHighRefreshRateEnabled(bool enabled) async {
    await into(devicePreferences).insertOnConflictUpdate(
      DevicePreferencesCompanion(
        id: const Value(1),
        highRefreshRateEnabled: Value(enabled),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Whether this device renders the snake cell-by-cell. Default off.
  Future<bool> isSnapMovementEnabled() async {
    final prefs = await getDevicePreferences();
    return prefs?.snapMovementEnabled ?? false;
  }

  /// Persist snap movement for this device only. Upsert, for the same
  /// reason as [updateHighRefreshRateEnabled].
  Future<void> updateSnapMovementEnabled(bool enabled) async {
    await into(devicePreferences).insertOnConflictUpdate(
      DevicePreferencesCompanion(
        id: const Value(1),
        snapMovementEnabled: Value(enabled),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// The on-screen control layout index for this device. Default 0.
  Future<int> getControlLayoutIndex() async {
    final prefs = await getDevicePreferences();
    return prefs?.controlLayoutIndex ?? 0;
  }

  /// Persist the on-screen control layout for this device only.
  Future<void> updateControlLayoutIndex(int index) async {
    await into(devicePreferences).insertOnConflictUpdate(
      DevicePreferencesCompanion(
        id: const Value(1),
        controlLayoutIndex: Value(index),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Reset settings to defaults. Outbox row queues a fresh sync so
  /// the backend picks up the reset.
  ///
  /// Leaves [devicePreferences] untouched — resetting your game settings is
  /// not a statement about your screen's refresh rate.
  Future<void> resetSettings() async {
    await transaction(() async {
      await delete(gameSettings).go();
      // EXPLICIT id 1. `id` is PRIMARY KEY AUTOINCREMENT, so SQLite hands a
      // fresh id after the delete above rather than reusing 1 — and every
      // read/write in this DAO targets `id = 1`. Without this, resetting your
      // settings quietly made every later settings change a no-op.
      await into(gameSettings)
          .insert(GameSettingsCompanion.insert(id: const Value(1)));
      await attachedDatabase.enqueueSyncOutbox(
        dataType: SyncDataType.settings,
        entityKey: 'settings:1',
      );
    });
  }
}
