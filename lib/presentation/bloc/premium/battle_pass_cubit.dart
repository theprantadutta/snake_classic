import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/utils/logger.dart';

import 'battle_pass_state.dart';

export 'battle_pass_state.dart';

/// Cubit for managing battle pass progression
class BattlePassCubit extends Cubit<BattlePassState> {
  final StorageService _storageService;
  final DataSyncService _dataSyncService = DataSyncService();
  final ApiService _apiService = ApiService();

  BattlePassCubit({required StorageService storageService})
    : _storageService = storageService,
      super(BattlePassState.initial());

  /// Initialize battle pass state — always load local first (instant), then background refresh
  Future<void> initialize() async {
    if (state.status == BattlePassStatus.ready) return;

    emit(state.copyWith(status: BattlePassStatus.loading));

    try {
      // Always load local first — instant
      await _loadFromLocalStorage();

      AppLogger.info(
        'BattlePassCubit initialized from local storage. Active: ${state.isActive}, Tier: ${state.currentTier}',
      );

      // Then refresh from backend silently (don't block)
      if (_apiService.isAuthenticated) {
        _refreshFromBackendSilently();
      }
    } catch (e) {
      AppLogger.error('Error initializing BattlePassCubit', e);
      emit(
        state.copyWith(
          status: BattlePassStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _refreshFromBackendSilently() {
    _loadFromBackend().catchError((e) {
      AppLogger.error('Background battle pass refresh failed', e);
      return false;
    });
  }

  /// Load battle pass data from backend
  Future<bool> _loadFromBackend() async {
    try {
      // Fetch season and progress in parallel
      final results = await Future.wait([
        _apiService.getCurrentBattlePassSeason(),
        _apiService.getBattlePassProgress(),
      ]);
      final seasonData = results[0];
      if (seasonData == null) {
        return false;
      }

      final progressData = results[1];
      if (progressData == null) {
        // Season exists but user has no progress yet - start fresh
        final endDate = DateTime.tryParse(
          seasonData['end_date'] ?? seasonData['endDate'] ?? '',
        );
        emit(
          state.copyWith(
            status: BattlePassStatus.ready,
            isActive: false,
            currentTier: 0,
            currentXP: 0,
            xpForNextTier: 100,
            expiryDate: endDate,
            seasonName: seasonData['name'] ?? 'Season 1',
          ),
        );
        await _saveState();
        return true;
      }

      // Parse progress data
      final hasPremium = progressData['has_premium'] ?? false;
      final currentLevel = progressData['current_level'] ?? 0;
      final currentXp = progressData['current_xp'] ?? 0;
      final xpToNextLevel = progressData['xp_to_next_level'] ?? 100;
      final claimedFree = (progressData['claimed_free_rewards'] as List<dynamic>?)
              ?.map((e) => e as int)
              .toSet() ??
          {};
      final claimedPremium =
          (progressData['claimed_premium_rewards'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toSet() ??
              {};

      final endDate = DateTime.tryParse(
        seasonData['end_date'] ?? seasonData['endDate'] ?? '',
      );

      emit(
        state.copyWith(
          status: BattlePassStatus.ready,
          isActive: hasPremium,
          currentTier: currentLevel,
          currentXP: currentXp,
          xpForNextTier: xpToNextLevel,
          expiryDate: endDate,
          claimedFreeTiers: claimedFree,
          claimedPremiumTiers: claimedPremium,
          seasonName: progressData['season_name'] ?? 'Season 1',
        ),
      );
      await _saveState();
      return true;
    } catch (e) {
      AppLogger.error('Error loading battle pass from backend', e);
      return false;
    }
  }

  /// Load from local storage (offline fallback)
  Future<void> _loadFromLocalStorage() async {
    final battlePassData = await _storageService.getBattlePassData();

    if (battlePassData != null) {
      final data = json.decode(battlePassData);
      emit(
        state.copyWith(
          status: BattlePassStatus.ready,
          isActive: data['is_active'] ?? false,
          currentTier: data['current_tier'] ?? 0,
          currentXP: data['current_xp'] ?? 0,
          xpForNextTier: data['xp_for_next_tier'] ?? 100,
          expiryDate: data['expiry_date'] != null
              ? DateTime.tryParse(data['expiry_date'])
              : null,
          claimedFreeTiers:
              (data['claimed_free_tiers'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toSet() ??
              {},
          claimedPremiumTiers:
              (data['claimed_premium_tiers'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toSet() ??
              {},
          seasonName: data['season_name'] ?? 'Season 1',
        ),
      );
    } else {
      emit(state.copyWith(status: BattlePassStatus.ready));
    }
  }

  /// Refresh data from backend (silent — no loading state)
  Future<void> refresh() async {
    if (_apiService.isAuthenticated) {
      await _loadFromBackend();
    } else {
      await _loadFromLocalStorage();
    }
  }

  Future<void> _saveState() async {
    final data = {
      'is_active': state.isActive,
      'current_tier': state.currentTier,
      'current_xp': state.currentXP,
      'xp_for_next_tier': state.xpForNextTier,
      'expiry_date': state.expiryDate?.toIso8601String(),
      'claimed_free_tiers': state.claimedFreeTiers.toList(),
      'claimed_premium_tiers': state.claimedPremiumTiers.toList(),
      'season_name': state.seasonName,
    };
    await _storageService.setBattlePassData(json.encode(data));
  }

  /// Activate battle pass (after purchase)
  Future<void> activate({Duration duration = const Duration(days: 90)}) async {
    final expiryDate = DateTime.now().add(duration);
    emit(state.copyWith(isActive: true, expiryDate: expiryDate));
    await _saveState();
    AppLogger.info(
      'Battle pass activated until ${expiryDate.toIso8601String()}',
    );
  }

  /// Add XP to battle pass (syncs with backend if online)
  Future<void> addXP(int xp, {String source = 'gameplay'}) async {
    if (state.currentTier >= BattlePassState.maxTier) return;

    // Try to sync with backend first
    if (_apiService.isAuthenticated) {
      final result = await _apiService.addBattlePassXP(xp: xp, source: source);
      if (result != null) {
        // Check if no active season - this is not an error, just skip
        final noActiveSeason = result['noActiveSeason'] == true ||
            result['no_active_season'] == true;
        if (noActiveSeason) {
          AppLogger.info('No active battle pass season - XP not added');
          return;
        }

        // Update state from backend response
        final newLevel = result['newLevel'] ??
            result['current_level'] ??
            state.currentTier;
        final newXp = result['newXp'] ?? result['current_xp'] ?? state.currentXP;
        final xpToNext = result['xpToNextLevel'] ??
            result['xp_to_next_level'] ??
            state.xpForNextTier;

        emit(
          state.copyWith(
            currentXP: newXp,
            currentTier: newLevel,
            xpForNextTier: xpToNext,
          ),
        );
        await _saveState();
        AppLogger.info(
          'Added $xp XP via backend. New tier: $newLevel, XP: $newXp/$xpToNext',
        );
        return;
      }
    }

    // Fallback to local calculation
    var newXP = state.currentXP + xp;
    var newTier = state.currentTier;
    var xpForNext = state.xpForNextTier;

    // Level up logic
    while (newXP >= xpForNext && newTier < BattlePassState.maxTier) {
      newXP -= xpForNext;
      newTier++;
      xpForNext = state.xpRequiredForTier(newTier);
    }

    emit(
      state.copyWith(
        currentXP: newXP,
        currentTier: newTier,
        xpForNextTier: xpForNext,
      ),
    );
    await _saveState();

    // Queue for background sync if offline
    _dataSyncService.queueSync('battle_pass_xp', {
      'xp': xp,
      'source': source,
      'added_at': DateTime.now().toIso8601String(),
    }, priority: SyncPriority.normal);

    AppLogger.info(
      'Added $xp XP locally. New tier: $newTier, XP: $newXP/$xpForNext',
    );
  }

  /// Claim free tier reward (offline-first: updates locally, syncs with backend)
  Future<bool> claimFreeReward(int tier) async {
    if (tier > state.currentTier) return false;
    if (state.claimedFreeTiers.contains(tier)) return false;

    // Update local state immediately
    final updatedClaimed = {...state.claimedFreeTiers, tier};
    emit(state.copyWith(claimedFreeTiers: updatedClaimed));
    await _saveState();

    // Try to sync with backend
    if (_apiService.isAuthenticated) {
      final result = await _apiService.claimBattlePassReward(
        level: tier,
        tier: 'free',
      );
      if (result != null) {
        AppLogger.info('Claimed free reward for tier $tier via backend');
        return true;
      }
    }

    // Queue for background sync if offline
    _dataSyncService.queueSync('battle_pass_claim', {
      'level': tier,
      'tier': 'free',
      'claimed_at': DateTime.now().toIso8601String(),
    }, priority: SyncPriority.high);

    AppLogger.info('Claimed free reward for tier $tier (queued for sync)');
    return true;
  }

  /// Claim premium tier reward (offline-first: updates locally, syncs with backend)
  Future<bool> claimPremiumReward(int tier) async {
    if (!state.isValid) return false;
    if (tier > state.currentTier) return false;
    if (state.claimedPremiumTiers.contains(tier)) return false;

    // Update local state immediately
    final updatedClaimed = {...state.claimedPremiumTiers, tier};
    emit(state.copyWith(claimedPremiumTiers: updatedClaimed));
    await _saveState();

    // Try to sync with backend
    if (_apiService.isAuthenticated) {
      final result = await _apiService.claimBattlePassReward(
        level: tier,
        tier: 'premium',
      );
      if (result != null) {
        AppLogger.info('Claimed premium reward for tier $tier via backend');
        return true;
      }
    }

    // Queue for background sync if offline
    _dataSyncService.queueSync('battle_pass_claim', {
      'level': tier,
      'tier': 'premium',
      'claimed_at': DateTime.now().toIso8601String(),
    }, priority: SyncPriority.high);

    AppLogger.info('Claimed premium reward for tier $tier (queued for sync)');
    return true;
  }

  /// Reset battle pass (for new season)
  Future<void> reset() async {
    emit(BattlePassState.initial().copyWith(status: BattlePassStatus.ready));
    await _saveState();
    AppLogger.info('Battle pass reset for new season');
  }

  /// Clear error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
