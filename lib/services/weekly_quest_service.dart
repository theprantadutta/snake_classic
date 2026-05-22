import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/models/weekly_quest.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// Lightweight service for the weekly-quest feature. Modelled tightly on
/// [DailyChallengeService] but without the heavyweight Drift cache —
/// quests refresh once per session (or on demand) and reuse the existing
/// ApiService for all backend communication.
class WeeklyQuestService extends ChangeNotifier {
  static final WeeklyQuestService _instance = WeeklyQuestService._internal();
  factory WeeklyQuestService() => _instance;
  WeeklyQuestService._internal();

  final ApiService _apiService = ApiService();
  final ConnectivityService _connectivityService = ConnectivityService();

  List<WeeklyQuest> _quests = [];
  bool _isLoading = false;
  DateTime? _lastLoadedAt;

  List<WeeklyQuest> get quests => List.unmodifiable(_quests);
  bool get isLoading => _isLoading;
  int get completedCount => _quests.where((q) => q.isCompleted).length;
  int get claimableCount => _quests.where((q) => q.canClaim).length;
  bool get hasUnclaimedRewards => claimableCount > 0;

  Future<void> initialize() async {
    if (_quests.isNotEmpty) return; // already loaded
    await refresh();
  }

  Future<void> refresh() async {
    if (!_connectivityService.isOnline || !_apiService.isAuthenticated) return;
    if (_isLoading) return;
    _isLoading = true;
    notifyListeners();
    try {
      final list = await _apiService.getCurrentWeeklyQuests();
      if (list != null) {
        _quests = list
            .map((e) => WeeklyQuest.fromJson(e as Map<String, dynamic>))
            .toList();
        _lastLoadedAt = DateTime.now();
      }
    } catch (e) {
      AppLogger.error('Error refreshing weekly quests', e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Push a single progress increment. The backend evaluates against ALL
  /// active quests with a matching Type so we don't need per-quest tracking
  /// on the client. Fire-and-forget — failures are logged but not surfaced.
  Future<void> reportProgress({
    required WeeklyQuestType type,
    required int incrementBy,
    String? gameMode,
  }) async {
    if (!_connectivityService.isOnline || !_apiService.isAuthenticated) return;
    if (incrementBy <= 0) return;
    await _apiService.updateWeeklyQuestProgress(
      type: type.apiValue,
      incrementBy: incrementBy,
      gameMode: gameMode,
    );
  }

  /// Batched per-game progress push — one POST instead of N round-trips.
  Future<void> reportProgressBatch(
      List<({WeeklyQuestType type, int incrementBy, String? gameMode})> updates) async {
    if (updates.isEmpty) return;
    if (!_connectivityService.isOnline || !_apiService.isAuthenticated) return;
    await _apiService.batchUpdateWeeklyQuestProgress(
      updates
          .map((u) => {
                'type': u.type.apiValue,
                'incrementBy': u.incrementBy,
                if (u.gameMode != null) 'gameMode': u.gameMode,
              })
          .toList(),
    );
  }

  /// Claim a completed quest. Optimistic local update; server is the source
  /// of truth for the coin + BP XP grants.
  Future<bool> claimReward(String questId) async {
    final index = _quests.indexWhere((q) => q.id == questId);
    if (index < 0) return false;
    final quest = _quests[index];
    if (!quest.canClaim) return false;

    _quests[index] = quest.copyWith(claimedReward: true);
    notifyListeners();

    if (_connectivityService.isOnline && _apiService.isAuthenticated) {
      final result = await _apiService.claimWeeklyQuestReward(questId);
      if (result != null) {
        // Buffer + flush BP XP through the cubit so the local UI reflects
        // progress before the next backend refresh.
        if (GetIt.I.isRegistered<BattlePassCubit>()) {
          final cubit = GetIt.I<BattlePassCubit>();
          final xp = BattlePassXpSource.getXpForAction('weekly_challenge');
          if (xp > 0) {
            cubit.bufferXP(xp, source: 'weekly_challenge');
            cubit.flushXP();
          }
        }
        return true;
      }
      // Backend rejected — revert.
      _quests[index] = quest;
      notifyListeners();
      return false;
    }
    return true; // optimistic offline success; will reconcile on next refresh
  }

  /// Stale-marker for the screen to decide whether to silently refresh.
  bool get isStale {
    if (_lastLoadedAt == null) return true;
    return DateTime.now().difference(_lastLoadedAt!) > const Duration(hours: 6);
  }
}
