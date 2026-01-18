import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/data/daos/sync_dao.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';

enum SyncStatus { idle, syncing, synced, offline, error }

enum SyncPriority {
  critical, // Purchases, premium status - sync immediately
  high, // Scores, achievements - sync soon
  normal, // Statistics, preferences - sync when convenient
  low, // Profile updates, non-essential - sync eventually
}

/// Represents an item in the sync queue
class SyncQueueItem {
  final String id;
  final String dataType;
  final Map<String, dynamic> data;
  final SyncPriority priority;
  final DateTime queuedAt;
  int retryCount;
  String? lastError;
  SyncItemStatus status;

  SyncQueueItem({
    required this.id,
    required this.dataType,
    required this.data,
    required this.priority,
    required this.queuedAt,
    this.retryCount = 0,
    this.lastError,
    this.status = SyncItemStatus.pending,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'dataType': dataType,
        'data': data,
        'priority': priority.index,
        'queuedAt': queuedAt.toIso8601String(),
        'retryCount': retryCount,
        'lastError': lastError,
        'status': status.index,
      };

  factory SyncQueueItem.fromJson(Map<String, dynamic> json) => SyncQueueItem(
        id: json['id'],
        dataType: json['dataType'],
        data: Map<String, dynamic>.from(json['data']),
        priority: SyncPriority.values[json['priority'] ?? 2],
        queuedAt: DateTime.parse(json['queuedAt']),
        retryCount: json['retryCount'] ?? 0,
        lastError: json['lastError'],
        status: SyncItemStatus.values[json['status'] ?? 0],
      );

  factory SyncQueueItem.fromDriftData(SyncQueueData data, Map<String, dynamic> parsedData) =>
      SyncQueueItem(
        id: data.id,
        dataType: data.dataType,
        data: parsedData,
        priority: SyncPriority.values[data.priority.clamp(0, 3)],
        queuedAt: data.queuedAt,
        retryCount: data.retryCount,
        lastError: data.lastError,
        status: SyncItemStatus.values[data.status.clamp(0, 3)],
      );
}

enum SyncItemStatus { pending, syncing, failed, completed }

/// Sync state exposed to UI
class SyncState {
  final int pendingCount;
  final int failedCount;
  final bool isSyncing;
  final DateTime? lastSyncTime;
  final DateTime? lastSuccessTime;
  final List<SyncQueueItem> pendingItems;

  SyncState({
    this.pendingCount = 0,
    this.failedCount = 0,
    this.isSyncing = false,
    this.lastSyncTime,
    this.lastSuccessTime,
    this.pendingItems = const [],
  });

  bool get hasPending => pendingCount > 0;
  bool get hasFailures => failedCount > 0;
}

class DataSyncService extends ChangeNotifier {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();

  SyncDao? _syncDao;
  Timer? _syncTimer;
  Timer? _retryTimer;
  StreamSubscription<bool>? _connectivitySubscription;

  SyncStatus _syncStatus = SyncStatus.offline;
  String? _currentUserId;
  DateTime? _lastSyncTime;
  DateTime? _lastSuccessTime;
  bool _isSyncing = false;
  bool _isInitialized = false;

  final List<SyncQueueItem> _syncQueue = [];
  static const int _maxRetries = 5;
  static const Duration _syncInterval = Duration(minutes: 2);

  // Stream controller for sync state changes
  final StreamController<SyncState> _syncStateController =
      StreamController<SyncState>.broadcast();
  Stream<SyncState> get syncStateStream => _syncStateController.stream;

  // Getters
  SyncStatus get syncStatus => _syncStatus;
  bool get isOnline => _connectivityService.isOnline;
  bool get hasPendingSync =>
      _syncQueue.any((item) => item.status == SyncItemStatus.pending);
  int get pendingCount => _syncQueue
      .where(
        (item) =>
            item.status == SyncItemStatus.pending ||
            item.status == SyncItemStatus.failed,
      )
      .length;
  int get failedCount =>
      _syncQueue.where((item) => item.status == SyncItemStatus.failed).length;

  SyncState get currentSyncState => SyncState(
        pendingCount: pendingCount,
        failedCount: failedCount,
        isSyncing: _isSyncing,
        lastSyncTime: _lastSyncTime,
        lastSuccessTime: _lastSuccessTime,
        pendingItems: List.unmodifiable(_syncQueue),
      );

  /// Initialize with database
  Future<void> initializeWithDatabase(AppDatabase database, String userId) async {
    _syncDao = database.syncDao;
    await initialize(userId);
  }

  Future<void> initialize(String userId) async {
    // Prevent re-initialization
    if (_isInitialized && _currentUserId == userId) {
      if (kDebugMode) {
        print('DataSyncService already initialized for user: $userId');
      }
      return;
    }

    _currentUserId = userId;

    // Initialize connectivity service (safe to call multiple times)
    await _connectivityService.initialize();

    // Load pending sync data from Drift
    await _loadSyncQueue();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.onlineStatusStream.listen((
      isOnline,
    ) {
      if (isOnline) {
        // Just came online, attempt sync
        _performSync();
      }
      _updateSyncStatus();
    });

    // Start periodic sync timer
    _startSyncTimer();

    // Initial sync if online
    if (_connectivityService.isOnline) {
      _performSync();
    }

    _updateSyncStatus();

    _isInitialized = true;

    if (kDebugMode) {
      print('DataSyncService initialized for user: $userId');
      print('Pending sync items: ${_syncQueue.length}');
    }
  }

  void _updateSyncStatus() {
    if (!_connectivityService.isOnline) {
      _syncStatus = SyncStatus.offline;
    } else if (_isSyncing) {
      _syncStatus = SyncStatus.syncing;
    } else if (failedCount > 0) {
      _syncStatus = SyncStatus.error;
    } else if (pendingCount > 0) {
      _syncStatus = SyncStatus.idle;
    } else {
      _syncStatus = SyncStatus.synced;
    }

    _emitSyncState();
    notifyListeners();
  }

  void _emitSyncState() {
    _syncStateController.add(currentSyncState);
  }

  void _startSyncTimer() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (timer) {
      if (_connectivityService.isOnline && hasPendingSync) {
        _performSync();
      }
    });
  }

  /// Calculate retry delay with exponential backoff
  /// Delays: 1s, 2s, 4s, 8s, 16s (max)
  Duration _getRetryDelay(int retryCount) {
    final seconds = min(pow(2, retryCount).toInt(), 16);
    return Duration(seconds: seconds);
  }

  /// Generate a unique idempotency key for offline score submissions
  String _generateIdempotencyKey() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = Random().nextInt(999999).toString().padLeft(6, '0');
    return '${timestamp}_$randomPart';
  }

  /// Queue data for sync with priority
  Future<void> queueSync(
    String dataType,
    Map<String, dynamic> data, {
    SyncPriority priority = SyncPriority.normal,
  }) async {
    if (_currentUserId == null) return;

    final id = '${dataType}_${DateTime.now().millisecondsSinceEpoch}';

    // For scores, add idempotency key and played_at timestamp
    final enrichedData = <String, dynamic>{...data, 'userId': _currentUserId};

    if (dataType == 'score') {
      // Generate idempotency key if not already present
      enrichedData['idempotencyKey'] ??= _generateIdempotencyKey();
      // Capture the actual play time for offline games
      enrichedData['playedAt'] ??= DateTime.now().toIso8601String();
    }

    final item = SyncQueueItem(
      id: id,
      dataType: dataType,
      data: enrichedData,
      priority: priority,
      queuedAt: DateTime.now(),
    );

    _syncQueue.add(item);

    // Sort by priority (critical first)
    _syncQueue.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    // Save queue to Drift database
    await _saveSyncQueue();

    if (kDebugMode) {
      print('Queued sync item: $dataType (priority: ${priority.name})');
    }

    // Attempt immediate sync for critical/high priority if online
    if (_connectivityService.isOnline &&
        (priority == SyncPriority.critical || priority == SyncPriority.high)) {
      _performSync();
    }

    _updateSyncStatus();
  }

  /// Sync specific data type via backend API
  Future<bool> _syncItem(SyncQueueItem item) async {
    if (_currentUserId == null || !_connectivityService.isOnline) return false;
    if (!_apiService.isAuthenticated) return false;

    try {
      switch (item.dataType) {
        case 'profile':
          final result = await _apiService.updateProfile(item.data);
          return result != null;

        case 'score':
          // Parse playedAt timestamp if present
          DateTime? playedAt;
          if (item.data['playedAt'] != null) {
            playedAt = DateTime.tryParse(item.data['playedAt']);
          }

          final result = await _apiService.submitScore(
            score: item.data['score'] ?? 0,
            gameDuration: item.data['gameDuration'] ?? 0,
            foodsEaten: item.data['foodsEaten'] ?? 0,
            gameMode: item.data['gameMode'] ?? 'classic',
            difficulty: item.data['difficulty'] ?? 'normal',
            playedAt: playedAt,
            idempotencyKey: item.data['idempotencyKey'],
          );
          return result != null;

        case 'preferences':
          final result = await _apiService.updateProfile({
            'preferences': item.data,
          });
          return result != null;

        case 'statistics':
          final result = await _apiService.updateProfile({
            'statistics': item.data,
          });
          return result != null;

        case 'achievements':
          // Achievements are synced individually
          return true;

        case 'daily_bonus_claim':
          // Sync daily bonus claim with backend
          final result = await _apiService.claimDailyBonus();
          return result != null && result['success'] == true;

        case 'tournament_score':
          // Submit tournament score to backend
          final tournamentResult = await _apiService.submitTournamentScore(
            tournamentId: item.data['tournamentId'],
            score: item.data['score'] ?? 0,
            gameDuration: item.data['gameDuration'] ?? 0,
            foodsEaten: item.data['foodsEaten'] ?? 0,
          );
          return tournamentResult != null &&
              tournamentResult['success'] == true;

        case 'battle_pass_claim':
          // Claim battle pass reward on backend
          final claimResult = await _apiService.claimBattlePassReward(
            level: item.data['level'] ?? 0,
            tier: item.data['tier'] ?? 'free',
          );
          return claimResult != null && claimResult['success'] == true;

        case 'friend_request_send':
          // Send friend request
          final sendResult = await _apiService.sendFriendRequest(
            userId: item.data['userId'],
          );
          return sendResult != null && sendResult['success'] == true;

        case 'friend_request_accept':
          // Accept friend request
          final acceptResult = await _apiService.acceptFriendRequest(
            item.data['requestId'],
          );
          return acceptResult != null && acceptResult['success'] == true;

        case 'friend_request_reject':
          // Reject friend request
          final rejectResult = await _apiService.rejectFriendRequest(
            item.data['requestId'],
          );
          return rejectResult != null && rejectResult['success'] == true;

        case 'friend_remove':
          // Remove friend
          final removeResult = await _apiService.removeFriend(
            item.data['friendId'],
          );
          return removeResult != null && removeResult['success'] == true;

        default:
          // Generic profile update
          final result = await _apiService.updateProfile({
            item.dataType: item.data,
          });
          return result != null;
      }
    } catch (e) {
      item.lastError = e.toString();
      if (kDebugMode) {
        print('Error syncing ${item.dataType}: $e');
      }
      return false;
    }
  }

  /// Sync multiple scores in batch
  Future<List<String>> _syncScoresBatch(List<SyncQueueItem> scoreItems) async {
    if (scoreItems.isEmpty) return [];

    // Prepare batch payload
    final scores = scoreItems.map((item) {
      DateTime? playedAt;
      if (item.data['playedAt'] != null) {
        playedAt = DateTime.tryParse(item.data['playedAt']);
      }

      return {
        'score': item.data['score'] ?? 0,
        'game_duration_seconds': item.data['gameDuration'] ?? 0,
        'foods_eaten': item.data['foodsEaten'] ?? 0,
        'game_mode': item.data['gameMode'] ?? 'classic',
        'difficulty': item.data['difficulty'] ?? 'normal',
        if (playedAt != null) 'played_at': playedAt.toUtc().toIso8601String(),
        if (item.data['idempotencyKey'] != null)
          'idempotency_key': item.data['idempotencyKey'],
      };
    }).toList();

    final result = await _apiService.submitScoresBatch(scores);

    if (result == null) return [];

    // Process batch results
    final completedIds = <String>[];
    final results = result['results'] as List<dynamic>?;

    if (results != null) {
      for (int i = 0; i < results.length && i < scoreItems.length; i++) {
        final scoreResult = results[i] as Map<String, dynamic>;
        final item = scoreItems[i];

        if (scoreResult['success'] == true) {
          item.status = SyncItemStatus.completed;
          completedIds.add(item.id);

          if (kDebugMode) {
            final wasDup = scoreResult['was_duplicate'] == true;
            print(
              'Batch synced score: ${item.data['score']} ${wasDup ? '(duplicate)' : ''}',
            );
          }
        } else {
          item.lastError = scoreResult['error'] ?? 'Unknown error';
        }
      }
    }

    return completedIds;
  }

  /// Perform sync with retry logic
  Future<void> _performSync() async {
    if (!_connectivityService.isOnline || _currentUserId == null) return;
    if (!_apiService.isAuthenticated) return;
    if (_isSyncing) return; // Prevent concurrent syncs

    final pendingItems = _syncQueue
        .where(
          (item) =>
              item.status == SyncItemStatus.pending ||
              (item.status == SyncItemStatus.failed &&
                  item.retryCount < _maxRetries),
        )
        .toList();

    if (pendingItems.isEmpty) return;

    _isSyncing = true;
    _lastSyncTime = DateTime.now();
    _updateSyncStatus();

    if (kDebugMode) {
      print('Starting sync of ${pendingItems.length} items...');
    }

    final completedIds = <String>[];
    final retryItems = <SyncQueueItem>[];

    // Separate score items for batch processing
    final scoreItems =
        pendingItems.where((item) => item.dataType == 'score').toList();
    final otherItems =
        pendingItems.where((item) => item.dataType != 'score').toList();

    // Batch sync scores if there are multiple
    if (scoreItems.length >= 2) {
      for (final item in scoreItems) {
        item.status = SyncItemStatus.syncing;
      }
      _emitSyncState();

      final batchCompleted = await _syncScoresBatch(scoreItems);
      completedIds.addAll(batchCompleted);

      // Handle failures
      for (final item in scoreItems) {
        if (!batchCompleted.contains(item.id)) {
          item.retryCount++;
          if (item.retryCount >= _maxRetries) {
            item.status = SyncItemStatus.failed;
          } else {
            item.status = SyncItemStatus.pending;
            retryItems.add(item);
          }
        }
      }
    } else {
      // Single score, add to otherItems for individual processing
      otherItems.addAll(scoreItems);
    }

    // Process non-score items individually
    for (final item in otherItems) {
      item.status = SyncItemStatus.syncing;
      _emitSyncState();

      final success = await _syncItem(item);

      if (success) {
        item.status = SyncItemStatus.completed;
        completedIds.add(item.id);
        if (kDebugMode) {
          print('Synced: ${item.dataType}');
        }
      } else {
        item.retryCount++;
        if (item.retryCount >= _maxRetries) {
          item.status = SyncItemStatus.failed;
          if (kDebugMode) {
            print(
              'Failed permanently: ${item.dataType} (max retries exceeded)',
            );
          }
        } else {
          item.status = SyncItemStatus.pending;
          retryItems.add(item);
          if (kDebugMode) {
            print(
              'Will retry: ${item.dataType} (attempt ${item.retryCount}/$_maxRetries)',
            );
          }
        }
      }
    }

    // Remove completed items
    _syncQueue.removeWhere((item) => completedIds.contains(item.id));

    // Also remove from Drift database
    for (final id in completedIds) {
      await _syncDao?.removeSyncItem(id);
    }

    // Schedule retries with exponential backoff
    if (retryItems.isNotEmpty) {
      _scheduleRetry(retryItems);
    }

    _isSyncing = false;

    if (completedIds.isNotEmpty) {
      _lastSuccessTime = DateTime.now();
    }

    // Save updated queue to Drift
    await _saveSyncQueue();
    _updateSyncStatus();

    if (kDebugMode) {
      print(
        'Sync complete. Completed: ${completedIds.length}, Pending retries: ${retryItems.length}',
      );
    }
  }

  /// Schedule retry for failed items
  void _scheduleRetry(List<SyncQueueItem> items) {
    if (items.isEmpty) return;

    // Use the shortest retry delay among items
    final minRetryCount = items.map((i) => i.retryCount).reduce(min);
    final delay = _getRetryDelay(minRetryCount);

    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (_connectivityService.isOnline) {
        _performSync();
      }
    });

    if (kDebugMode) {
      print('Scheduled retry in ${delay.inSeconds}s for ${items.length} items');
    }
  }

  /// Force sync now
  Future<void> forceSyncNow() async {
    if (_connectivityService.isOnline) {
      // Reset retry counts for failed items to allow retry
      for (final item in _syncQueue) {
        if (item.status == SyncItemStatus.failed &&
            item.retryCount >= _maxRetries) {
          item.retryCount = 0;
          item.status = SyncItemStatus.pending;
        }
      }
      await _performSync();
    }
  }

  /// Get data from backend API
  Future<Map<String, dynamic>?> getData(String dataType) async {
    if (_currentUserId == null || !_connectivityService.isOnline) return null;
    if (!_apiService.isAuthenticated) return null;

    try {
      final profile = await _apiService.getCurrentUser();
      if (profile != null) {
        return profile[dataType] as Map<String, dynamic>?;
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting $dataType: $e');
      }
      return null;
    }
  }

  /// Merge data with conflict resolution (most recent wins)
  Map<String, dynamic> mergeData(
    Map<String, dynamic> localData,
    Map<String, dynamic> cloudData,
  ) {
    final localTimestamp =
        DateTime.tryParse(localData['lastUpdated'] ?? '') ?? DateTime(2000);
    final cloudTimestamp =
        DateTime.tryParse(cloudData['lastUpdated'] ?? '') ?? DateTime(2000);

    if (localTimestamp.isAfter(cloudTimestamp)) {
      return localData;
    } else {
      return cloudData;
    }
  }

  /// Load sync queue from Drift database
  Future<void> _loadSyncQueue() async {
    if (_syncDao == null) return;

    try {
      final items = await _syncDao!.getSyncQueueAsMaps();
      _syncQueue.clear();

      for (final item in items) {
        _syncQueue.add(SyncQueueItem.fromJson(item));
      }

      // Sort by priority
      _syncQueue.sort((a, b) => a.priority.index.compareTo(b.priority.index));

      if (kDebugMode) {
        print('Loaded ${_syncQueue.length} sync queue items from Drift');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading sync queue: $e');
      }
    }
  }

  /// Save sync queue to Drift database
  Future<void> _saveSyncQueue() async {
    if (_syncDao == null) return;

    try {
      final queueMaps = _syncQueue.map((item) => item.toJson()).toList();
      await _syncDao!.saveSyncQueueFromMaps(queueMaps);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving sync queue: $e');
      }
    }
  }

  /// Clear all pending sync data
  Future<void> clearPendingData() async {
    _syncQueue.clear();
    await _syncDao?.clearSyncQueue();
    _updateSyncStatus();
  }

  /// Remove completed and old failed items
  Future<void> cleanupQueue() async {
    _syncQueue.removeWhere(
      (item) =>
          item.status == SyncItemStatus.completed ||
          (item.status == SyncItemStatus.failed &&
              item.queuedAt.isBefore(
                DateTime.now().subtract(const Duration(days: 7)),
              )),
    );
    await _saveSyncQueue();
    _updateSyncStatus();
  }

  /// Get sync info for UI display
  Map<String, dynamic> getSyncInfo() {
    return {
      'status': _syncStatus.name,
      'isOnline': _connectivityService.isOnline,
      'pendingItems': pendingCount,
      'failedItems': failedCount,
      'isSyncing': _isSyncing,
      'lastSync': _lastSyncTime?.toIso8601String(),
      'lastSuccess': _lastSuccessTime?.toIso8601String(),
    };
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _retryTimer?.cancel();
    _connectivitySubscription?.cancel();
    _syncStateController.close();
    super.dispose();
  }
}
