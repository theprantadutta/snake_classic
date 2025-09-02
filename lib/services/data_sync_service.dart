import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SyncStatus { syncing, synced, offline, error }

class DataSyncService extends ChangeNotifier {
  static final DataSyncService _instance = DataSyncService._internal();
  factory DataSyncService() => _instance;
  DataSyncService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Connectivity _connectivity = Connectivity();
  
  SharedPreferences? _prefs;
  Timer? _syncTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  
  SyncStatus _syncStatus = SyncStatus.offline;
  bool _isOnline = false;
  String? _currentUserId;
  
  final Map<String, dynamic> _pendingSyncData = {};
  final List<String> _syncQueue = [];
  
  // Getters
  SyncStatus get syncStatus => _syncStatus;
  bool get isOnline => _isOnline;
  bool get hasPendingSync => _syncQueue.isNotEmpty;

  Future<void> initialize(String userId) async {
    _currentUserId = userId;
    _prefs = await SharedPreferences.getInstance();
    
    // Load pending sync data
    await _loadPendingSyncData();
    
    // Start connectivity monitoring
    _startConnectivityMonitoring();
    
    // Check initial connectivity
    final connectivityResult = await _connectivity.checkConnectivity();
    _updateConnectionStatus(connectivityResult);
    
    // Start periodic sync timer
    _startSyncTimer();
    
    if (kDebugMode) {
      print('DataSyncService initialized for user: $userId');
    }
  }

  void _startConnectivityMonitoring() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateConnectionStatus(result);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = !results.contains(ConnectivityResult.none) && results.isNotEmpty;
    
    if (_isOnline && !wasOnline) {
      // Just came online, sync pending data
      _performSync();
    }
    
    _updateSyncStatus();
  }

  void _updateSyncStatus() {
    if (!_isOnline) {
      _syncStatus = SyncStatus.offline;
    } else if (_syncQueue.isNotEmpty) {
      _syncStatus = SyncStatus.syncing;
    } else {
      _syncStatus = SyncStatus.synced;
    }
    notifyListeners();
  }

  void _startSyncTimer() {
    _syncTimer = Timer.periodic(const Duration(minutes: 2), (timer) {
      if (_isOnline && _syncQueue.isNotEmpty) {
        _performSync();
      }
    });
  }

  // Queue data for sync
  Future<void> queueSync(String dataType, Map<String, dynamic> data) async {
    if (_currentUserId == null) return;
    
    // Store data locally first
    _pendingSyncData[dataType] = {
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
      'userId': _currentUserId,
    };
    
    // Add to sync queue if not already present
    if (!_syncQueue.contains(dataType)) {
      _syncQueue.add(dataType);
    }
    
    // Save pending data to local storage
    await _savePendingSyncData();
    
    // Attempt immediate sync if online
    if (_isOnline) {
      _performSync();
    }
    
    _updateSyncStatus();
  }

  // Sync specific data type
  Future<bool> syncData(String dataType, Map<String, dynamic> data) async {
    if (_currentUserId == null || !_isOnline) return false;
    
    try {
      await _firestore
          .collection('users')
          .doc(_currentUserId)
          .set({dataType: data}, SetOptions(merge: true));
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Error syncing $dataType: $e');
      }
      return false;
    }
  }

  // Get data from Firestore
  Future<Map<String, dynamic>?> getData(String dataType) async {
    if (_currentUserId == null || !_isOnline) return null;
    
    try {
      final doc = await _firestore
          .collection('users')
          .doc(_currentUserId)
          .get();
      
      if (doc.exists) {
        final data = doc.data();
        return data?[dataType] as Map<String, dynamic>?;
      }
      
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting $dataType: $e');
      }
      return null;
    }
  }

  // Merge data with conflict resolution (most recent wins)
  Map<String, dynamic> mergeData(
    Map<String, dynamic> localData,
    Map<String, dynamic> cloudData,
  ) {
    final localTimestamp = DateTime.tryParse(localData['lastUpdated'] ?? '') ?? DateTime(2000);
    final cloudTimestamp = DateTime.tryParse(cloudData['lastUpdated'] ?? '') ?? DateTime(2000);
    
    // Most recent data wins
    if (localTimestamp.isAfter(cloudTimestamp)) {
      return localData;
    } else {
      return cloudData;
    }
  }

  // Perform actual sync
  Future<void> _performSync() async {
    if (!_isOnline || _currentUserId == null || _syncQueue.isEmpty) return;
    
    _syncStatus = SyncStatus.syncing;
    notifyListeners();
    
    final syncErrors = <String>[];
    final completedSyncs = <String>[];
    
    for (final dataType in List<String>.from(_syncQueue)) {
      final pendingData = _pendingSyncData[dataType];
      if (pendingData == null) continue;
      
      final success = await syncData(dataType, pendingData['data']);
      if (success) {
        completedSyncs.add(dataType);
        _pendingSyncData.remove(dataType);
      } else {
        syncErrors.add(dataType);
      }
    }
    
    // Remove completed syncs from queue
    _syncQueue.removeWhere((item) => completedSyncs.contains(item));
    
    // Update status
    if (syncErrors.isNotEmpty) {
      _syncStatus = SyncStatus.error;
      if (kDebugMode) {
        print('Sync errors for: ${syncErrors.join(', ')}');
      }
    } else {
      _syncStatus = SyncStatus.synced;
    }
    
    // Save updated pending data
    await _savePendingSyncData();
    notifyListeners();
  }

  // Force sync now
  Future<void> forceSyncNow() async {
    if (_isOnline && _syncQueue.isNotEmpty) {
      await _performSync();
    }
  }

  // Load pending sync data from local storage
  Future<void> _loadPendingSyncData() async {
    if (_prefs == null) return;
    
    final pendingDataJson = _prefs!.getString('pending_sync_data');
    final syncQueueJson = _prefs!.getString('sync_queue');
    
    if (pendingDataJson != null) {
      try {
        final data = jsonDecode(pendingDataJson) as Map<String, dynamic>;
        _pendingSyncData.addAll(data);
      } catch (e) {
        if (kDebugMode) {
          print('Error loading pending sync data: $e');
        }
      }
    }
    
    if (syncQueueJson != null) {
      try {
        final queue = List<String>.from(jsonDecode(syncQueueJson));
        _syncQueue.addAll(queue);
      } catch (e) {
        if (kDebugMode) {
          print('Error loading sync queue: $e');
        }
      }
    }
  }

  // Save pending sync data to local storage
  Future<void> _savePendingSyncData() async {
    if (_prefs == null) return;
    
    try {
      await _prefs!.setString('pending_sync_data', jsonEncode(_pendingSyncData));
      await _prefs!.setStringList('sync_queue', _syncQueue);
    } catch (e) {
      if (kDebugMode) {
        print('Error saving pending sync data: $e');
      }
    }
  }

  // Clear all pending sync data
  Future<void> clearPendingData() async {
    _pendingSyncData.clear();
    _syncQueue.clear();
    await _savePendingSyncData();
    _updateSyncStatus();
  }

  // Get sync info for UI display
  Map<String, dynamic> getSyncInfo() {
    return {
      'status': _syncStatus.name,
      'isOnline': _isOnline,
      'pendingItems': _syncQueue.length,
      'lastSync': DateTime.now().toIso8601String(), // This would be stored in real implementation
    };
  }

  @override
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}