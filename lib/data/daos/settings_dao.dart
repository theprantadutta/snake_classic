import 'package:drift/drift.dart';
import 'package:snake_classic/data/database/app_database.dart';

part 'settings_dao.g.dart';

@DriftAccessor(tables: [GameSettings])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  /// Watch settings changes for reactive UI
  Stream<GameSetting?> watchSettings() => select(gameSettings).watchSingleOrNull();

  /// Get current settings
  Future<GameSetting?> getSettings() => select(gameSettings).getSingleOrNull();

  /// Update theme index
  Future<void> updateTheme(int themeIndex) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      themeIndex: Value(themeIndex),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update sound enabled
  Future<void> updateSoundEnabled(bool enabled) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      soundEnabled: Value(enabled),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update music enabled
  Future<void> updateMusicEnabled(bool enabled) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      musicEnabled: Value(enabled),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update D-Pad enabled
  Future<void> updateDPadEnabled(bool enabled) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      dPadEnabled: Value(enabled),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update D-Pad position
  Future<void> updateDPadPosition(int positionIndex) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      dPadPositionIndex: Value(positionIndex),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update board size
  Future<void> updateBoardSize(int boardSizeIndex) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      boardSizeIndex: Value(boardSizeIndex),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update high score
  Future<void> updateHighScore(int score) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      highScore: Value(score),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update crash feedback duration
  Future<void> updateCrashFeedbackDuration(int seconds) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      crashFeedbackDurationSeconds: Value(seconds),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update trail system enabled
  Future<void> updateTrailSystemEnabled(bool enabled) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      trailSystemEnabled: Value(enabled),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update screen shake enabled
  Future<void> updateScreenShakeEnabled(bool enabled) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      screenShakeEnabled: Value(enabled),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update selected skin
  Future<void> updateSelectedSkin(String? skinId) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      selectedSkinId: Value(skinId),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Update selected trail
  Future<void> updateSelectedTrail(String? trailId) async {
    await (update(gameSettings)
          ..where((t) => t.id.equals(1)))
        .write(GameSettingsCompanion(
      selectedTrailId: Value(trailId),
      lastUpdated: Value(DateTime.now()),
    ));
  }

  /// Reset settings to defaults
  Future<void> resetSettings() async {
    await delete(gameSettings).go();
    await into(gameSettings).insert(GameSettingsCompanion.insert());
  }
}
