import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/services/auth_service.dart';
import 'package:snake_classic/services/storage_service.dart';

class AchievementService extends ChangeNotifier {
  static final AchievementService _instance = AchievementService._internal();
  factory AchievementService() => _instance;
  AchievementService._internal();

  final AuthService _authService = AuthService();
  final StorageService _storageService = StorageService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Achievement> _achievements = [];
  final List<Achievement> _recentUnlocks = [];

  List<Achievement> get achievements => _achievements;
  List<Achievement> get recentUnlocks => _recentUnlocks;
  
  int get totalAchievementPoints => _achievements
      .where((a) => a.isUnlocked)
      .fold(0, (total, a) => total + a.points);

  double get completionPercentage => _achievements.isEmpty 
    ? 0.0 
    : _achievements.where((a) => a.isUnlocked).length / _achievements.length;

  Future<void> initialize() async {
    _achievements = Achievement.getDefaultAchievements();
    await _loadUserProgress();
    notifyListeners();
  }

  Future<void> _loadUserProgress() async {
    try {
      if (_authService.isSignedIn) {
        // Load from Firebase
        final doc = await _firestore
            .collection('achievements')
            .doc(_authService.currentUser!.uid)
            .get();

        if (doc.exists) {
          final data = doc.data()!;
          _updateAchievementsFromData(data);
        }
      } else {
        // Load from local storage for guest users
        final localData = await _storageService.getAchievements();
        if (localData != null && localData.isNotEmpty) {
          _updateAchievementsFromData(jsonDecode(localData));
        }
      }
    } catch (e) {
      if (kDebugMode) {
        // Error:Error loading achievement progress: $e');
      }
    }
  }

  void _updateAchievementsFromData(Map<String, dynamic> data) {
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      final savedData = data[achievement.id] as Map<String, dynamic>?;
      
      if (savedData != null) {
        _achievements[i] = achievement.copyWith(
          isUnlocked: savedData['isUnlocked'] ?? false,
          currentProgress: savedData['currentProgress'] ?? 0,
          unlockedAt: savedData['unlockedAt'] != null 
            ? DateTime.parse(savedData['unlockedAt'])
            : null,
        );
      }
    }
  }

  Future<void> _saveProgress() async {
    try {
      final progressData = <String, dynamic>{};
      
      for (final achievement in _achievements) {
        progressData[achievement.id] = {
          'isUnlocked': achievement.isUnlocked,
          'currentProgress': achievement.currentProgress,
          'unlockedAt': achievement.unlockedAt?.toIso8601String(),
        };
      }

      if (_authService.isSignedIn) {
        // Save to Firebase
        await _firestore
            .collection('achievements')
            .doc(_authService.currentUser!.uid)
            .set(progressData, SetOptions(merge: true));
      } else {
        // Save locally for guest users
        await _storageService.saveAchievements(jsonEncode(progressData));
      }
    } catch (e) {
      if (kDebugMode) {
        // Error:Error saving achievement progress: $e');
      }
    }
  }

  Future<List<Achievement>> checkScoreAchievements(int score) async {
    final newUnlocks = <Achievement>[];
    
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      
      if (achievement.type == AchievementType.score && !achievement.isUnlocked) {
        if (score >= achievement.targetValue) {
          _achievements[i] = achievement.copyWith(
            isUnlocked: true,
            currentProgress: achievement.targetValue,
            unlockedAt: DateTime.now(),
          );
          newUnlocks.add(_achievements[i]);
        } else {
          _achievements[i] = achievement.copyWith(
            currentProgress: score,
          );
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      await _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  Future<List<Achievement>> checkGamePlayedAchievements(int totalGames) async {
    final newUnlocks = <Achievement>[];
    
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      
      if (achievement.type == AchievementType.games && !achievement.isUnlocked) {
        if (totalGames >= achievement.targetValue) {
          _achievements[i] = achievement.copyWith(
            isUnlocked: true,
            currentProgress: achievement.targetValue,
            unlockedAt: DateTime.now(),
          );
          newUnlocks.add(_achievements[i]);
        } else {
          _achievements[i] = achievement.copyWith(
            currentProgress: totalGames,
          );
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      await _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  Future<List<Achievement>> checkSurvivalAchievements(int survivalTime) async {
    final newUnlocks = <Achievement>[];
    
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      
      if (achievement.type == AchievementType.survival && !achievement.isUnlocked) {
        if (survivalTime >= achievement.targetValue) {
          _achievements[i] = achievement.copyWith(
            isUnlocked: true,
            currentProgress: achievement.targetValue,
            unlockedAt: DateTime.now(),
          );
          newUnlocks.add(_achievements[i]);
        } else if (survivalTime > achievement.currentProgress) {
          _achievements[i] = achievement.copyWith(
            currentProgress: survivalTime,
          );
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      await _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  Future<List<Achievement>> checkSpecialAchievements({
    int? level,
    bool? hitWall,
    bool? hitSelf,
    Set<String>? foodTypesEaten,
    int? noWallGames,
  }) async {
    final newUnlocks = <Achievement>[];
    
    for (int i = 0; i < _achievements.length; i++) {
      final achievement = _achievements[i];
      
      if (achievement.type == AchievementType.special && !achievement.isUnlocked) {
        bool shouldUnlock = false;
        int newProgress = achievement.currentProgress;

        switch (achievement.id) {
          case 'speedster':
            if (level != null && level >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = achievement.targetValue;
            } else if (level != null) {
              newProgress = level;
            }
            break;

          case 'no_walls':
            if (noWallGames != null && noWallGames >= achievement.targetValue) {
              shouldUnlock = true;
              newProgress = achievement.targetValue;
            } else if (noWallGames != null) {
              newProgress = noWallGames;
            }
            break;

          case 'perfectionist':
            if (hitSelf == false && hitWall != true) {
              shouldUnlock = true;
              newProgress = 1;
            }
            break;

          case 'all_food_types':
            if (foodTypesEaten != null && foodTypesEaten.length >= 3) {
              shouldUnlock = true;
              newProgress = 1;
            }
            break;
        }

        if (shouldUnlock) {
          _achievements[i] = achievement.copyWith(
            isUnlocked: true,
            currentProgress: newProgress,
            unlockedAt: DateTime.now(),
          );
          newUnlocks.add(_achievements[i]);
        } else if (newProgress != achievement.currentProgress) {
          _achievements[i] = achievement.copyWith(
            currentProgress: newProgress,
          );
        }
      }
    }

    if (newUnlocks.isNotEmpty) {
      _recentUnlocks.addAll(newUnlocks);
      await _saveProgress();
      notifyListeners();
    }

    return newUnlocks;
  }

  void clearRecentUnlocks() {
    _recentUnlocks.clear();
    notifyListeners();
  }

  Achievement? getAchievementById(String id) {
    try {
      return _achievements.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Achievement> getAchievementsByType(AchievementType type) {
    return _achievements.where((a) => a.type == type).toList();
  }

  List<Achievement> getAchievementsByRarity(AchievementRarity rarity) {
    return _achievements.where((a) => a.rarity == rarity).toList();
  }

  List<Achievement> getUnlockedAchievements() {
    return _achievements.where((a) => a.isUnlocked).toList();
  }

  List<Achievement> getLockedAchievements() {
    return _achievements.where((a) => !a.isUnlocked).toList();
  }
}