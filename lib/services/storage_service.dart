import 'dart:convert';
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
    return GameConstants.availableBoardSizes[boardSizeIndex.clamp(
      0,
      GameConstants.availableBoardSizes.length - 1,
    )];
  }

  Future<void> saveBoardSize(BoardSize boardSize) async {
    await _initPrefs();
    final index = GameConstants.availableBoardSizes.indexOf(boardSize);
    await _prefs?.setInt(GameConstants.boardSizeKey, index);
  }

  Future<Duration> getCrashFeedbackDuration() async {
    await _initPrefs();
    final durationSeconds =
        _prefs?.getInt(GameConstants.crashFeedbackDurationKey) ??
        GameConstants.defaultCrashFeedbackDuration.inSeconds;
    return Duration(seconds: durationSeconds);
  }

  Future<void> saveCrashFeedbackDuration(Duration duration) async {
    await _initPrefs();
    await _prefs?.setInt(
      GameConstants.crashFeedbackDurationKey,
      duration.inSeconds,
    );
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
    return _prefs?.getBool(GameConstants.trailSystemEnabledKey) ??
        false; // Default to false
  }

  Future<void> setTrailSystemEnabled(bool enabled) async {
    await _initPrefs();
    await _prefs?.setBool(GameConstants.trailSystemEnabledKey, enabled);
  }

  // D-Pad controls preference
  Future<bool> isDPadEnabled() async {
    await _initPrefs();
    return _prefs?.getBool('dpad_enabled') ?? false; // Default to false
  }

  Future<void> setDPadEnabled(bool enabled) async {
    await _initPrefs();
    await _prefs?.setBool('dpad_enabled', enabled);
  }

  // D-Pad position preference
  Future<DPadPosition> getDPadPosition() async {
    await _initPrefs();
    final positionIndex =
        _prefs?.getInt('dpad_position') ?? 1; // Default to center (1)
    return DPadPosition.values[positionIndex.clamp(
      0,
      DPadPosition.values.length - 1,
    )];
  }

  Future<void> setDPadPosition(DPadPosition position) async {
    await _initPrefs();
    await _prefs?.setInt('dpad_position', position.index);
  }

  // Screen shake preference
  Future<bool> isScreenShakeEnabled() async {
    await _initPrefs();
    return _prefs?.getBool('screen_shake_enabled') ?? false; // Default to false
  }

  Future<void> setScreenShakeEnabled(bool enabled) async {
    await _initPrefs();
    await _prefs?.setBool('screen_shake_enabled', enabled);
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

  // Sync queue persistence methods
  static const String _syncQueueKey = 'sync_queue';
  static const String _syncQueueMetaKey = 'sync_queue_meta';

  /// Get the persisted sync queue
  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    await _initPrefs();
    final queueJson = _prefs?.getString(_syncQueueKey);
    if (queueJson == null) return [];

    try {
      final List<dynamic> decoded = json.decode(queueJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Save the sync queue for persistence
  Future<void> saveSyncQueue(List<Map<String, dynamic>> queue) async {
    await _initPrefs();
    await _prefs?.setString(_syncQueueKey, json.encode(queue));
  }

  /// Get sync queue metadata (last sync time, stats)
  Future<Map<String, dynamic>?> getSyncQueueMeta() async {
    await _initPrefs();
    final metaJson = _prefs?.getString(_syncQueueMetaKey);
    if (metaJson == null) return null;

    try {
      return json.decode(metaJson) as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }

  /// Save sync queue metadata
  Future<void> saveSyncQueueMeta(Map<String, dynamic> meta) async {
    await _initPrefs();
    await _prefs?.setString(_syncQueueMetaKey, json.encode(meta));
  }

  /// Clear the sync queue
  Future<void> clearSyncQueue() async {
    await _initPrefs();
    await _prefs?.remove(_syncQueueKey);
    await _prefs?.remove(_syncQueueMetaKey);
  }

  // Local score queue for offline games
  static const String _localScoresKey = 'local_scores_pending';

  /// Get pending local scores that need to be synced
  Future<List<Map<String, dynamic>>> getPendingLocalScores() async {
    await _initPrefs();
    final scoresJson = _prefs?.getString(_localScoresKey);
    if (scoresJson == null) return [];

    try {
      final List<dynamic> decoded = json.decode(scoresJson);
      return decoded.cast<Map<String, dynamic>>();
    } catch (e) {
      return [];
    }
  }

  /// Add a local score to pending sync queue
  Future<void> addPendingLocalScore(Map<String, dynamic> score) async {
    await _initPrefs();
    final scores = await getPendingLocalScores();
    scores.add(score);
    await _prefs?.setString(_localScoresKey, json.encode(scores));
  }

  /// Clear pending local scores after successful sync
  Future<void> clearPendingLocalScores() async {
    await _initPrefs();
    await _prefs?.remove(_localScoresKey);
  }

  /// Remove specific local scores by IDs
  Future<void> removePendingLocalScores(List<String> ids) async {
    await _initPrefs();
    final scores = await getPendingLocalScores();
    scores.removeWhere((score) => ids.contains(score['id']));
    await _prefs?.setString(_localScoresKey, json.encode(scores));
  }

  // Unlocked bundles
  Future<List<String>> getUnlockedBundles() async {
    await _initPrefs();
    return _prefs?.getStringList('unlocked_bundles') ?? [];
  }

  Future<void> setUnlockedBundles(List<String> bundles) async {
    await _initPrefs();
    await _prefs?.setStringList('unlocked_bundles', bundles);
  }

  // Trial data
  Future<Map<String, dynamic>> getTrialData() async {
    await _initPrefs();
    final isOnTrial = _prefs?.getBool('trial_is_on') ?? false;
    final trialStartStr = _prefs?.getString('trial_start_date');
    final trialEndStr = _prefs?.getString('trial_end_date');

    return {
      'isOnTrial': isOnTrial,
      'trialStartDate': trialStartStr,
      'trialEndDate': trialEndStr,
    };
  }

  Future<void> setTrialData({
    required bool isOnTrial,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
  }) async {
    await _initPrefs();
    await _prefs?.setBool('trial_is_on', isOnTrial);
    if (trialStartDate != null) {
      await _prefs?.setString(
        'trial_start_date',
        trialStartDate.toIso8601String(),
      );
    }
    if (trialEndDate != null) {
      await _prefs?.setString('trial_end_date', trialEndDate.toIso8601String());
    }
  }

  // Tournament entries
  Future<Map<String, int>> getTournamentEntries() async {
    await _initPrefs();
    return {
      'bronze': _prefs?.getInt('tournament_entries_bronze') ?? 0,
      'silver': _prefs?.getInt('tournament_entries_silver') ?? 0,
      'gold': _prefs?.getInt('tournament_entries_gold') ?? 0,
    };
  }

  Future<void> setTournamentEntries({
    required int bronze,
    required int silver,
    required int gold,
  }) async {
    await _initPrefs();
    await _prefs?.setInt('tournament_entries_bronze', bronze);
    await _prefs?.setInt('tournament_entries_silver', silver);
    await _prefs?.setInt('tournament_entries_gold', gold);
  }
}
