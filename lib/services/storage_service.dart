import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/utils/constants.dart';

class StorageService {
  static StorageService? _instance;
  SharedPreferences? _prefs;

  StorageService._internal();

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  Future<void> _initPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<int> getHighScore() async {
    await _initPrefs();
    return _prefs?.getInt(GameConstants.highScoreKey) ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    await _initPrefs();
    await _prefs?.setInt(GameConstants.highScoreKey, score);
  }

  Future<GameTheme> getSelectedTheme() async {
    await _initPrefs();
    final themeIndex = _prefs?.getInt(GameConstants.selectedThemeKey) ?? 0;
    return GameTheme.values[themeIndex.clamp(0, GameTheme.values.length - 1)];
  }

  Future<void> saveSelectedTheme(GameTheme theme) async {
    await _initPrefs();
    await _prefs?.setInt(GameConstants.selectedThemeKey, theme.index);
  }

  Future<bool> isSoundEnabled() async {
    await _initPrefs();
    return _prefs?.getBool(GameConstants.soundEnabledKey) ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _initPrefs();
    await _prefs?.setBool(GameConstants.soundEnabledKey, enabled);
  }

  Future<BoardSize> getBoardSize() async {
    await _initPrefs();
    final boardSizeIndex = _prefs?.getInt(GameConstants.boardSizeKey) ?? 1;
    return GameConstants.availableBoardSizes[boardSizeIndex.clamp(0, GameConstants.availableBoardSizes.length - 1)];
  }

  Future<void> saveBoardSize(BoardSize boardSize) async {
    await _initPrefs();
    final index = GameConstants.availableBoardSizes.indexOf(boardSize);
    await _prefs?.setInt(GameConstants.boardSizeKey, index);
  }

  Future<Duration> getCrashFeedbackDuration() async {
    await _initPrefs();
    final durationSeconds = _prefs?.getInt(GameConstants.crashFeedbackDurationKey) ?? GameConstants.defaultCrashFeedbackDuration.inSeconds;
    return Duration(seconds: durationSeconds);
  }

  Future<void> saveCrashFeedbackDuration(Duration duration) async {
    await _initPrefs();
    await _prefs?.setInt(GameConstants.crashFeedbackDurationKey, duration.inSeconds);
  }

  Future<String?> getStatistics() async {
    await _initPrefs();
    return _prefs?.getString(GameConstants.statisticsKey);
  }

  Future<void> saveStatistics(String statisticsJson) async {
    await _initPrefs();
    await _prefs?.setString(GameConstants.statisticsKey, statisticsJson);
  }

  Future<String?> getAchievements() async {
    await _initPrefs();
    return _prefs?.getString('achievements');
  }

  Future<void> saveAchievements(String achievementsJson) async {
    await _initPrefs();
    await _prefs?.setString('achievements', achievementsJson);
  }

  Future<bool> isMusicEnabled() async {
    await _initPrefs();
    return _prefs?.getBool('music_enabled') ?? true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await _initPrefs();
    await _prefs?.setBool('music_enabled', enabled);
  }

  Future<bool> isTrailSystemEnabled() async {
    await _initPrefs();
    return _prefs?.getBool(GameConstants.trailSystemEnabledKey) ?? false; // Default to false
  }

  Future<void> setTrailSystemEnabled(bool enabled) async {
    await _initPrefs();
    await _prefs?.setBool(GameConstants.trailSystemEnabledKey, enabled);
  }

  // Replay storage methods
  Future<void> saveReplay(String replayId, String replayJson) async {
    await _initPrefs();
    await _prefs?.setString('replay_$replayId', replayJson);
    
    // Update replay keys list
    final keys = await getReplayKeys();
    if (!keys.contains(replayId)) {
      keys.add(replayId);
      await _prefs?.setStringList('replay_keys', keys);
    }
  }

  Future<String?> getReplay(String replayId) async {
    await _initPrefs();
    return _prefs?.getString('replay_$replayId');
  }

  Future<List<String>> getReplayKeys() async {
    await _initPrefs();
    return _prefs?.getStringList('replay_keys') ?? [];
  }

  Future<void> deleteReplay(String replayId) async {
    await _initPrefs();
    await _prefs?.remove('replay_$replayId');
    
    // Update replay keys list
    final keys = await getReplayKeys();
    keys.remove(replayId);
    await _prefs?.setStringList('replay_keys', keys);
  }

  Future<void> clearAllData() async {
    await _initPrefs();
    await _prefs?.clear();
  }
}