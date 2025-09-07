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

  // Premium features persistence
  Future<bool> isPremiumActive() async {
    await _initPrefs();
    return _prefs?.getBool('premium_active') ?? false;
  }

  Future<void> setPremiumActive(bool active) async {
    await _initPrefs();
    await _prefs?.setBool('premium_active', active);
  }

  Future<String?> getPremiumExpirationDate() async {
    await _initPrefs();
    return _prefs?.getString('premium_expiration');
  }

  Future<void> setPremiumExpirationDate(String? date) async {
    await _initPrefs();
    if (date != null) {
      await _prefs?.setString('premium_expiration', date);
    } else {
      await _prefs?.remove('premium_expiration');
    }
  }

  Future<String?> getSelectedSkinId() async {
    await _initPrefs();
    return _prefs?.getString('selected_skin_id');
  }

  Future<void> setSelectedSkinId(String? skinId) async {
    await _initPrefs();
    if (skinId != null) {
      await _prefs?.setString('selected_skin_id', skinId);
    } else {
      await _prefs?.remove('selected_skin_id');
    }
  }

  Future<String?> getSelectedTrailId() async {
    await _initPrefs();
    return _prefs?.getString('selected_trail_id');
  }

  Future<void> setSelectedTrailId(String? trailId) async {
    await _initPrefs();
    if (trailId != null) {
      await _prefs?.setString('selected_trail_id', trailId);
    } else {
      await _prefs?.remove('selected_trail_id');
    }
  }

  Future<List<String>> getUnlockedThemes() async {
    await _initPrefs();
    return _prefs?.getStringList('unlocked_themes') ?? [];
  }

  Future<void> setUnlockedThemes(List<String> themes) async {
    await _initPrefs();
    await _prefs?.setStringList('unlocked_themes', themes);
  }

  Future<List<String>> getUnlockedSkins() async {
    await _initPrefs();
    return _prefs?.getStringList('unlocked_skins') ?? [];
  }

  Future<void> setUnlockedSkins(List<String> skins) async {
    await _initPrefs();
    await _prefs?.setStringList('unlocked_skins', skins);
  }

  Future<List<String>> getUnlockedTrails() async {
    await _initPrefs();
    return _prefs?.getStringList('unlocked_trails') ?? [];
  }

  Future<void> setUnlockedTrails(List<String> trails) async {
    await _initPrefs();
    await _prefs?.setStringList('unlocked_trails', trails);
  }

  Future<List<String>> getUnlockedPowerUps() async {
    await _initPrefs();
    return _prefs?.getStringList('unlocked_powerups') ?? [];
  }

  Future<void> setUnlockedPowerUps(List<String> powerUps) async {
    await _initPrefs();
    await _prefs?.setStringList('unlocked_powerups', powerUps);
  }

  Future<List<String>> getUnlockedBoardSizes() async {
    await _initPrefs();
    return _prefs?.getStringList('unlocked_board_sizes') ?? [];
  }

  Future<void> setUnlockedBoardSizes(List<String> boardSizes) async {
    await _initPrefs();
    await _prefs?.setStringList('unlocked_board_sizes', boardSizes);
  }

  Future<List<String>> getUnlockedGameModes() async {
    await _initPrefs();
    return _prefs?.getStringList('unlocked_game_modes') ?? [];
  }

  Future<void> setUnlockedGameModes(List<String> gameModes) async {
    await _initPrefs();
    await _prefs?.setStringList('unlocked_game_modes', gameModes);
  }

  Future<int> getCoins() async {
    await _initPrefs();
    return _prefs?.getInt('coins') ?? 0;
  }

  Future<void> setCoins(int coins) async {
    await _initPrefs();
    await _prefs?.setInt('coins', coins);
  }

  Future<String?> getBattlePassData() async {
    await _initPrefs();
    return _prefs?.getString('battle_pass_data');
  }

  Future<void> setBattlePassData(String? data) async {
    await _initPrefs();
    if (data != null) {
      await _prefs?.setString('battle_pass_data', data);
    } else {
      await _prefs?.remove('battle_pass_data');
    }
  }

  Future<List<String>> getPurchaseHistory() async {
    await _initPrefs();
    return _prefs?.getStringList('purchase_history') ?? [];
  }

  Future<void> addPurchaseToHistory(String purchaseJson) async {
    await _initPrefs();
    final history = await getPurchaseHistory();
    history.add(purchaseJson);
    await _prefs?.setStringList('purchase_history', history);
  }

  Future<void> clearAllData() async {
    await _initPrefs();
    await _prefs?.clear();
  }
}