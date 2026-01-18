import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/data/daos/settings_dao.dart';
import 'package:snake_classic/data/daos/game_dao.dart';
import 'package:snake_classic/data/daos/store_dao.dart';
import 'package:snake_classic/data/daos/sync_dao.dart';
import 'package:snake_classic/utils/constants.dart';

class StorageService {
  static StorageService? _instance;
  AppDatabase? _database;
  SettingsDao? _settingsDao;
  GameDao? _gameDao;
  StoreDao? _storeDao;
  SyncDao? _syncDao;

  StorageService._internal();

  factory StorageService() {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  /// Initialize the storage service with database
  Future<void> initialize(AppDatabase database) async {
    _database = database;
    _settingsDao = database.settingsDao;
    _gameDao = database.gameDao;
    _storeDao = database.storeDao;
    _syncDao = database.syncDao;

    // Initialize default data
    await _database!.initializeDefaults();
  }

  /// Check if initialized
  bool get isInitialized => _database != null;

  // ==================== High Score ====================

  Future<int> getHighScore() async {
    final settings = await _settingsDao?.getSettings();
    return settings?.highScore ?? 0;
  }

  Future<void> saveHighScore(int score) async {
    await _settingsDao?.updateHighScore(score);
  }

  // ==================== Theme ====================

  Future<GameTheme> getSelectedTheme() async {
    final settings = await _settingsDao?.getSettings();
    final themeIndex = settings?.themeIndex ?? 0;
    return GameTheme.values[themeIndex.clamp(0, GameTheme.values.length - 1)];
  }

  Future<void> saveSelectedTheme(GameTheme theme) async {
    await _settingsDao?.updateTheme(theme.index);
  }

  // ==================== Sound Settings ====================

  Future<bool> isSoundEnabled() async {
    final settings = await _settingsDao?.getSettings();
    return settings?.soundEnabled ?? true;
  }

  Future<void> setSoundEnabled(bool enabled) async {
    await _settingsDao?.updateSoundEnabled(enabled);
  }

  Future<bool> isMusicEnabled() async {
    final settings = await _settingsDao?.getSettings();
    return settings?.musicEnabled ?? true;
  }

  Future<void> setMusicEnabled(bool enabled) async {
    await _settingsDao?.updateMusicEnabled(enabled);
  }

  // ==================== Board Size ====================

  Future<BoardSize> getBoardSize() async {
    final settings = await _settingsDao?.getSettings();
    final boardSizeIndex = settings?.boardSizeIndex ?? 1;
    return GameConstants.availableBoardSizes[boardSizeIndex.clamp(
      0,
      GameConstants.availableBoardSizes.length - 1,
    )];
  }

  Future<void> saveBoardSize(BoardSize boardSize) async {
    final index = GameConstants.availableBoardSizes.indexOf(boardSize);
    await _settingsDao?.updateBoardSize(index >= 0 ? index : 1);
  }

  // ==================== Crash Feedback ====================

  Future<Duration> getCrashFeedbackDuration() async {
    final settings = await _settingsDao?.getSettings();
    final durationSeconds = settings?.crashFeedbackDurationSeconds ??
        GameConstants.defaultCrashFeedbackDuration.inSeconds;
    return Duration(seconds: durationSeconds);
  }

  Future<void> saveCrashFeedbackDuration(Duration duration) async {
    await _settingsDao?.updateCrashFeedbackDuration(duration.inSeconds);
  }

  // ==================== D-Pad Settings ====================

  Future<bool> isDPadEnabled() async {
    final settings = await _settingsDao?.getSettings();
    return settings?.dPadEnabled ?? false;
  }

  Future<void> setDPadEnabled(bool enabled) async {
    await _settingsDao?.updateDPadEnabled(enabled);
  }

  Future<DPadPosition> getDPadPosition() async {
    final settings = await _settingsDao?.getSettings();
    final positionIndex = settings?.dPadPositionIndex ?? 1;
    return DPadPosition.values[positionIndex.clamp(
      0,
      DPadPosition.values.length - 1,
    )];
  }

  Future<void> setDPadPosition(DPadPosition position) async {
    await _settingsDao?.updateDPadPosition(position.index);
  }

  // ==================== Trail System ====================

  Future<bool> isTrailSystemEnabled() async {
    final settings = await _settingsDao?.getSettings();
    return settings?.trailSystemEnabled ?? false;
  }

  Future<void> setTrailSystemEnabled(bool enabled) async {
    await _settingsDao?.updateTrailSystemEnabled(enabled);
  }

  // ==================== Screen Shake ====================

  Future<bool> isScreenShakeEnabled() async {
    final settings = await _settingsDao?.getSettings();
    return settings?.screenShakeEnabled ?? false;
  }

  Future<void> setScreenShakeEnabled(bool enabled) async {
    await _settingsDao?.updateScreenShakeEnabled(enabled);
  }

  // ==================== Statistics ====================

  Future<String?> getStatistics() async {
    return await _gameDao?.getStatisticsAsJson();
  }

  Future<void> saveStatistics(String statisticsJson) async {
    await _gameDao?.updateStatisticsFromJson(statisticsJson);
  }

  // ==================== Achievements ====================

  Future<String?> getAchievements() async {
    return await _gameDao?.getAchievementsAsJson();
  }

  Future<void> saveAchievements(String achievementsJson) async {
    await _gameDao?.loadAchievementsFromJson(achievementsJson);
  }

  // ==================== Replays ====================

  Future<void> saveReplay(String replayId, String replayJson) async {
    final data = json.decode(replayJson) as Map<String, dynamic>;
    await _gameDao?.saveReplay(ReplaysCompanion(
      id: Value(replayId),
      name: Value(data['name']),
      score: Value(data['score'] ?? 0),
      snakeLength: Value(data['snakeLength'] ?? 0),
      gameDurationSeconds: Value(data['gameDurationSeconds'] ?? 0),
      gameMode: Value(data['gameMode'] ?? 'classic'),
      boardSize: Value(data['boardSize'] ?? '20x20'),
      replayData: Value(json.encode(data['replayData'] ?? [])),
      isFavorite: Value(data['isFavorite'] ?? false),
    ));
  }

  Future<String?> getReplay(String replayId) async {
    final replay = await _gameDao?.getReplay(replayId);
    if (replay == null) return null;

    return json.encode({
      'id': replay.id,
      'name': replay.name,
      'score': replay.score,
      'snakeLength': replay.snakeLength,
      'gameDurationSeconds': replay.gameDurationSeconds,
      'gameMode': replay.gameMode,
      'boardSize': replay.boardSize,
      'replayData': json.decode(replay.replayData),
      'isFavorite': replay.isFavorite,
      'recordedAt': replay.recordedAt.toIso8601String(),
    });
  }

  Future<List<String>> getReplayKeys() async {
    return await _gameDao?.getReplayKeys() ?? [];
  }

  Future<void> deleteReplay(String replayId) async {
    await _gameDao?.deleteReplay(replayId);
  }

  // ==================== Premium ====================

  Future<bool> isPremiumActive() async {
    return await _storeDao?.isPremiumActive() ?? false;
  }

  Future<void> setPremiumActive(bool active) async {
    await _storeDao?.setPremiumActive(active);
  }

  Future<String?> getPremiumExpirationDate() async {
    return await _storeDao?.getPremiumExpirationDate();
  }

  Future<void> setPremiumExpirationDate(String? date) async {
    DateTime? expirationDate;
    if (date != null) {
      expirationDate = DateTime.tryParse(date);
    }
    await _storeDao?.setPremiumActive(
      expirationDate != null && DateTime.now().isBefore(expirationDate),
      expirationDate: expirationDate,
    );
  }

  // ==================== Selected Skin/Trail ====================

  Future<String?> getSelectedSkinId() async {
    final settings = await _settingsDao?.getSettings();
    return settings?.selectedSkinId;
  }

  Future<void> setSelectedSkinId(String? skinId) async {
    await _settingsDao?.updateSelectedSkin(skinId);
  }

  Future<String?> getSelectedTrailId() async {
    final settings = await _settingsDao?.getSettings();
    return settings?.selectedTrailId;
  }

  Future<void> setSelectedTrailId(String? trailId) async {
    await _settingsDao?.updateSelectedTrail(trailId);
  }

  // ==================== Unlocked Items ====================

  Future<List<String>> getUnlockedThemes() async {
    return await _storeDao?.getUnlockedThemes() ?? [];
  }

  Future<void> setUnlockedThemes(List<String> themes) async {
    await _storeDao?.setUnlockedThemes(themes);
  }

  Future<List<String>> getUnlockedSkins() async {
    return await _storeDao?.getUnlockedSkins() ?? [];
  }

  Future<void> setUnlockedSkins(List<String> skins) async {
    await _storeDao?.setUnlockedSkins(skins);
  }

  Future<List<String>> getUnlockedTrails() async {
    return await _storeDao?.getUnlockedTrails() ?? [];
  }

  Future<void> setUnlockedTrails(List<String> trails) async {
    await _storeDao?.setUnlockedTrails(trails);
  }

  Future<List<String>> getUnlockedPowerUps() async {
    return await _storeDao?.getUnlockedPowerUps() ?? [];
  }

  Future<void> setUnlockedPowerUps(List<String> powerUps) async {
    await _storeDao?.setUnlockedPowerUps(powerUps);
  }

  Future<List<String>> getUnlockedBoardSizes() async {
    return await _storeDao?.getUnlockedBoardSizes() ?? [];
  }

  Future<void> setUnlockedBoardSizes(List<String> boardSizes) async {
    await _storeDao?.setUnlockedBoardSizes(boardSizes);
  }

  Future<List<String>> getUnlockedGameModes() async {
    return await _storeDao?.getUnlockedGameModes() ?? [];
  }

  Future<void> setUnlockedGameModes(List<String> gameModes) async {
    await _storeDao?.setUnlockedGameModes(gameModes);
  }

  Future<List<String>> getUnlockedBundles() async {
    return await _storeDao?.getUnlockedBundles() ?? [];
  }

  Future<void> setUnlockedBundles(List<String> bundles) async {
    await _storeDao?.setUnlockedBundles(bundles);
  }

  // ==================== Coins ====================

  Future<int> getCoins() async {
    return await _storeDao?.getCoinBalance() ?? 0;
  }

  Future<void> setCoins(int coins) async {
    await _storeDao?.setCoinBalance(coins);
  }

  // ==================== Battle Pass ====================

  Future<String?> getBattlePassData() async {
    return await _storeDao?.getBattlePassData();
  }

  Future<void> setBattlePassData(String? data) async {
    await _storeDao?.setBattlePassData(data);
  }

  // ==================== Purchase History ====================

  Future<List<String>> getPurchaseHistory() async {
    return await _storeDao?.getPurchaseHistoryJson() ?? [];
  }

  Future<void> addPurchaseToHistory(String purchaseJson) async {
    await _storeDao?.addPurchaseFromJson(purchaseJson);
  }

  // ==================== Sync Queue ====================

  Future<List<Map<String, dynamic>>> getSyncQueue() async {
    return await _syncDao?.getSyncQueueAsMaps() ?? [];
  }

  Future<void> saveSyncQueue(List<Map<String, dynamic>> queue) async {
    await _syncDao?.saveSyncQueueFromMaps(queue);
  }

  Future<Map<String, dynamic>?> getSyncQueueMeta() async {
    // Sync metadata is now part of the sync queue items
    final pending = await _syncDao?.getPendingSyncCount() ?? 0;
    final failed = await _syncDao?.getFailedSyncCount() ?? 0;
    return {
      'pendingCount': pending,
      'failedCount': failed,
    };
  }

  Future<void> saveSyncQueueMeta(Map<String, dynamic> meta) async {
    // Metadata is managed automatically through sync queue
  }

  Future<void> clearSyncQueue() async {
    await _syncDao?.clearSyncQueue();
  }

  // ==================== Local Scores Queue ====================

  Future<List<Map<String, dynamic>>> getPendingLocalScores() async {
    final items = await _syncDao?.getSyncQueueAsMaps() ?? [];
    return items.where((item) => item['dataType'] == 'score').toList();
  }

  Future<void> addPendingLocalScore(Map<String, dynamic> score) async {
    final id = 'score_${DateTime.now().millisecondsSinceEpoch}';
    await _syncDao?.addToSyncQueue(
      id: id,
      dataType: 'score',
      data: score,
      priority: 1, // High priority
    );
  }

  Future<void> clearPendingLocalScores() async {
    final items = await _syncDao?.getSyncQueueAsMaps() ?? [];
    for (final item in items) {
      if (item['dataType'] == 'score') {
        await _syncDao?.removeSyncItem(item['id']);
      }
    }
  }

  Future<void> removePendingLocalScores(List<String> ids) async {
    for (final id in ids) {
      await _syncDao?.removeSyncItem(id);
    }
  }

  // ==================== Trial Data ====================

  Future<Map<String, dynamic>> getTrialData() async {
    return await _storeDao?.getTrialData() ?? {
      'isOnTrial': false,
      'trialStartDate': null,
      'trialEndDate': null,
    };
  }

  Future<void> setTrialData({
    required bool isOnTrial,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
  }) async {
    await _storeDao?.setTrialData(
      isOnTrial: isOnTrial,
      trialStartDate: trialStartDate,
      trialEndDate: trialEndDate,
    );
  }

  // ==================== Tournament Entries ====================

  Future<Map<String, int>> getTournamentEntries() async {
    return await _storeDao?.getTournamentEntries() ?? {
      'bronze': 0,
      'silver': 0,
      'gold': 0,
    };
  }

  Future<void> setTournamentEntries({
    required int bronze,
    required int silver,
    required int gold,
  }) async {
    await _storeDao?.setTournamentEntries(
      bronze: bronze,
      silver: silver,
      gold: gold,
    );
  }

  // ==================== Clear All Data ====================

  Future<void> clearAllData() async {
    await _database?.clearAllData();
  }

  // ==================== Watch Streams (Reactive) ====================

  /// Watch settings for reactive UI updates
  Stream<GameSetting?> watchSettings() {
    return _settingsDao?.watchSettings() ?? const Stream.empty();
  }

  /// Watch coin balance for reactive UI updates
  Stream<int> watchCoinBalance() {
    return _storeDao?.watchCoinBalance() ?? const Stream.empty();
  }

  /// Watch statistics for reactive UI updates
  Stream<Statistic?> watchStatistics() {
    return _gameDao?.watchStatistics() ?? const Stream.empty();
  }

  /// Watch achievements for reactive UI updates
  Stream<List<Achievement>> watchAchievements() {
    return _gameDao?.watchAchievements() ?? const Stream.empty();
  }

  /// Watch pending sync items
  Stream<List<SyncQueueData>> watchPendingSyncItems() {
    return _syncDao?.watchPendingSyncItems() ?? const Stream.empty();
  }
}
