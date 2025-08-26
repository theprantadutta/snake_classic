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

  Future<bool> isMusicEnabled() async {
    await _initPrefs();
    return _prefs?.getBool(GameConstants.musicEnabledKey) ?? true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await _initPrefs();
    await _prefs?.setBool(GameConstants.musicEnabledKey, enabled);
  }

  Future<void> clearAllData() async {
    await _initPrefs();
    await _prefs?.clear();
  }
}