import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/services/daily_challenge_service.dart';
import 'package:snake_classic/providers/providers.dart';

/// State for daily challenges data
class DailyChallengesState {
  final List<DailyChallenge> challenges;
  final int completedCount;
  final int totalCount;
  final bool allCompleted;
  final int bonusCoins;
  final bool isLoading;
  final bool hasUnclaimedRewards;
  final String? error;

  const DailyChallengesState({
    this.challenges = const [],
    this.completedCount = 0,
    this.totalCount = 0,
    this.allCompleted = false,
    this.bonusCoins = 0,
    this.isLoading = false,
    this.hasUnclaimedRewards = false,
    this.error,
  });

  DailyChallengesState copyWith({
    List<DailyChallenge>? challenges,
    int? completedCount,
    int? totalCount,
    bool? allCompleted,
    int? bonusCoins,
    bool? isLoading,
    bool? hasUnclaimedRewards,
    String? error,
  }) {
    return DailyChallengesState(
      challenges: challenges ?? this.challenges,
      completedCount: completedCount ?? this.completedCount,
      totalCount: totalCount ?? this.totalCount,
      allCompleted: allCompleted ?? this.allCompleted,
      bonusCoins: bonusCoins ?? this.bonusCoins,
      isLoading: isLoading ?? this.isLoading,
      hasUnclaimedRewards: hasUnclaimedRewards ?? this.hasUnclaimedRewards,
      error: error,
    );
  }
}

/// Notifier for daily challenges with TTL-based auto-refresh
class DailyChallengesNotifier extends StateNotifier<DailyChallengesState> {
  final Ref _ref;
  final DailyChallengeService _service;
  Timer? _ttlTimer;
  VoidCallback? _serviceListener;

  static const _ttl = Duration(minutes: 5);

  DailyChallengesNotifier(this._ref)
    : _service = DailyChallengeService(),
      super(const DailyChallengesState(isLoading: true)) {
    _initialize();
  }

  void _initialize() {
    // Listen to service changes
    _serviceListener = _onServiceChanged;
    _service.addListener(_serviceListener!);

    // Initial load
    _loadData();

    // Set up TTL-based refresh
    _startTtlTimer();

    // Listen for connectivity changes - refresh when coming online
    _ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      final wasOffline = previous?.value == false;
      final isNowOnline = next.value == true;
      if (wasOffline && isNowOnline) {
        refresh();
      }
    });
  }

  void _onServiceChanged() {
    _syncStateFromService();
  }

  void _syncStateFromService() {
    state = state.copyWith(
      challenges: _service.challenges,
      completedCount: _service.completedCount,
      totalCount: _service.totalCount,
      allCompleted: _service.allCompleted,
      bonusCoins: _service.bonusCoins,
      isLoading: _service.isLoading,
      hasUnclaimedRewards: _service.hasUnclaimedRewards,
    );
  }

  void _startTtlTimer() {
    _ttlTimer?.cancel();
    _ttlTimer = Timer.periodic(_ttl, (_) {
      final isOnline = _ref.read(isOnlineSyncProvider);
      if (isOnline) {
        refresh();
      }
    });
  }

  Future<void> _loadData() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.initialize();
      _syncStateFromService();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load daily challenges',
      );
    }
  }

  /// Refresh challenges from the server
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _service.refreshChallenges();
      _syncStateFromService();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh daily challenges',
      );
    }
  }

  /// Update progress for a challenge type (called after game ends)
  Future<void> updateProgress(
    ChallengeType type,
    int value, {
    String? gameMode,
  }) async {
    await _service.updateProgress(type, value, gameMode: gameMode);
    _syncStateFromService();
  }

  /// Claim reward for a specific challenge
  Future<bool> claimReward(String challengeId) async {
    final success = await _service.claimReward(challengeId);
    if (success) {
      _syncStateFromService();
    }
    return success;
  }

  /// Claim all unclaimed rewards
  Future<int> claimAllRewards() async {
    final totalClaimed = await _service.claimAllRewards();
    _syncStateFromService();
    return totalClaimed;
  }

  @override
  void dispose() {
    _ttlTimer?.cancel();
    if (_serviceListener != null) {
      _service.removeListener(_serviceListener!);
    }
    super.dispose();
  }
}

/// Provider for daily challenges state
final dailyChallengesProvider =
    StateNotifierProvider<DailyChallengesNotifier, DailyChallengesState>((ref) {
      return DailyChallengesNotifier(ref);
    });

/// Convenience provider for just the challenges list
final dailyChallengesListProvider = Provider<List<DailyChallenge>>((ref) {
  return ref.watch(dailyChallengesProvider).challenges;
});

/// Convenience provider for loading state
final dailyChallengesLoadingProvider = Provider<bool>((ref) {
  return ref.watch(dailyChallengesProvider).isLoading;
});

/// Convenience provider for unclaimed rewards
final hasUnclaimedRewardsProvider = Provider<bool>((ref) {
  return ref.watch(dailyChallengesProvider).hasUnclaimedRewards;
});
