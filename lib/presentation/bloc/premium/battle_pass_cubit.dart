import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/data_sync_service.dart';
import 'package:snake_classic/utils/logger.dart';

import 'battle_pass_state.dart';

export 'battle_pass_state.dart';

/// Cubit for managing battle pass progression
class BattlePassCubit extends Cubit<BattlePassState> {
  final StorageService _storageService;
  final DataSyncService _dataSyncService = DataSyncService();

  BattlePassCubit({
    required StorageService storageService,
  })  : _storageService = storageService,
        super(BattlePassState.initial());

  /// Initialize battle pass state
  Future<void> initialize() async {
    if (state.status == BattlePassStatus.ready) return;

    emit(state.copyWith(status: BattlePassStatus.loading));

    try {
      final battlePassData = await _storageService.getBattlePassData();

      if (battlePassData != null) {
        final data = json.decode(battlePassData);
        emit(state.copyWith(
          status: BattlePassStatus.ready,
          isActive: data['is_active'] ?? false,
          currentTier: data['current_tier'] ?? 0,
          currentXP: data['current_xp'] ?? 0,
          xpForNextTier: data['xp_for_next_tier'] ?? 100,
          expiryDate: data['expiry_date'] != null
              ? DateTime.tryParse(data['expiry_date'])
              : null,
          claimedFreeTiers: (data['claimed_free_tiers'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toSet() ??
              {},
          claimedPremiumTiers: (data['claimed_premium_tiers'] as List<dynamic>?)
                  ?.map((e) => e as int)
                  .toSet() ??
              {},
        ));
      } else {
        emit(state.copyWith(status: BattlePassStatus.ready));
      }

      AppLogger.info(
          'BattlePassCubit initialized. Active: ${state.isActive}, Tier: ${state.currentTier}');
    } catch (e) {
      AppLogger.error('Error initializing BattlePassCubit', e);
      emit(state.copyWith(
        status: BattlePassStatus.error,
        errorMessage: e.toString(),
      ));
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
    };
    await _storageService.setBattlePassData(json.encode(data));
  }

  /// Activate battle pass (after purchase)
  Future<void> activate({Duration duration = const Duration(days: 90)}) async {
    final expiryDate = DateTime.now().add(duration);
    emit(state.copyWith(
      isActive: true,
      expiryDate: expiryDate,
    ));
    await _saveState();
    AppLogger.info('Battle pass activated until ${expiryDate.toIso8601String()}');
  }

  /// Add XP to battle pass
  Future<void> addXP(int xp) async {
    if (!state.isValid) return;
    if (state.currentTier >= BattlePassState.maxTier) return;

    var newXP = state.currentXP + xp;
    var newTier = state.currentTier;
    var xpForNext = state.xpForNextTier;

    // Level up logic
    while (newXP >= xpForNext && newTier < BattlePassState.maxTier) {
      newXP -= xpForNext;
      newTier++;
      xpForNext = state.xpRequiredForTier(newTier);
    }

    emit(state.copyWith(
      currentXP: newXP,
      currentTier: newTier,
      xpForNextTier: xpForNext,
    ));
    await _saveState();

    AppLogger.info('Added $xp XP. New tier: $newTier, XP: $newXP/$xpForNext');
  }

  /// Claim free tier reward (offline-first: updates locally, syncs in background)
  Future<bool> claimFreeReward(int tier) async {
    if (tier > state.currentTier) return false;
    if (state.claimedFreeTiers.contains(tier)) return false;

    // Update local state immediately
    final updatedClaimed = {...state.claimedFreeTiers, tier};
    emit(state.copyWith(claimedFreeTiers: updatedClaimed));
    await _saveState();

    // Queue for background sync
    _dataSyncService.queueSync(
      'battle_pass_claim',
      {
        'level': tier,
        'tier': 'free',
        'claimed_at': DateTime.now().toIso8601String(),
      },
      priority: SyncPriority.high,
    );

    AppLogger.info('Claimed free reward for tier $tier');
    return true;
  }

  /// Claim premium tier reward (offline-first: updates locally, syncs in background)
  Future<bool> claimPremiumReward(int tier) async {
    if (!state.isValid) return false;
    if (tier > state.currentTier) return false;
    if (state.claimedPremiumTiers.contains(tier)) return false;

    // Update local state immediately
    final updatedClaimed = {...state.claimedPremiumTiers, tier};
    emit(state.copyWith(claimedPremiumTiers: updatedClaimed));
    await _saveState();

    // Queue for background sync
    _dataSyncService.queueSync(
      'battle_pass_claim',
      {
        'level': tier,
        'tier': 'premium',
        'claimed_at': DateTime.now().toIso8601String(),
      },
      priority: SyncPriority.high,
    );

    AppLogger.info('Claimed premium reward for tier $tier');
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
