import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snake_classic/models/tournament.dart';
import 'package:snake_classic/services/tournament_service.dart';
import 'package:snake_classic/providers/providers.dart';

/// State for tournaments data
class TournamentsState {
  final List<Tournament> activeTournaments;
  final List<Tournament> historyTournaments;
  final Map<String, dynamic> userStats;
  final bool isLoading;
  final bool isOffline;
  final String? error;

  const TournamentsState({
    this.activeTournaments = const [],
    this.historyTournaments = const [],
    this.userStats = const {},
    this.isLoading = false,
    this.isOffline = false,
    this.error,
  });

  TournamentsState copyWith({
    List<Tournament>? activeTournaments,
    List<Tournament>? historyTournaments,
    Map<String, dynamic>? userStats,
    bool? isLoading,
    bool? isOffline,
    String? error,
  }) {
    return TournamentsState(
      activeTournaments: activeTournaments ?? this.activeTournaments,
      historyTournaments: historyTournaments ?? this.historyTournaments,
      userStats: userStats ?? this.userStats,
      isLoading: isLoading ?? this.isLoading,
      isOffline: isOffline ?? this.isOffline,
      error: error,
    );
  }
}

/// Notifier for tournaments with TTL-based auto-refresh
class TournamentsNotifier extends StateNotifier<TournamentsState> {
  final Ref _ref;
  final TournamentService _service;
  Timer? _ttlTimer;

  static const _ttl = Duration(minutes: 5);

  TournamentsNotifier(this._ref)
      : _service = TournamentService(),
        super(const TournamentsState(isLoading: true)) {
    _initialize();
  }

  void _initialize() {
    // Initial load
    _loadData();

    // Set up TTL-based refresh
    _startTtlTimer();

    // Listen for connectivity changes - refresh when coming online
    _ref.listen<AsyncValue<bool>>(isOnlineProvider, (previous, next) {
      final wasOffline = previous?.value == false;
      final isNowOnline = next.value == true;

      state = state.copyWith(isOffline: !(next.value ?? false));

      if (wasOffline && isNowOnline) {
        refresh();
      }
    });
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
      final results = await Future.wait([
        _service.getActiveTournaments(),
        _service.getTournamentHistory(),
        _service.getUserTournamentStats(),
      ]);

      state = state.copyWith(
        activeTournaments: results[0] as List<Tournament>,
        historyTournaments: results[1] as List<Tournament>,
        userStats: results[2] as Map<String, dynamic>,
        isLoading: false,
        isOffline: !_ref.read(isOnlineSyncProvider),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load tournaments',
      );
    }
  }

  /// Refresh tournaments from the server
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final results = await Future.wait([
        _service.getActiveTournaments(),
        _service.getTournamentHistory(),
        _service.getUserTournamentStats(),
      ]);

      state = state.copyWith(
        activeTournaments: results[0] as List<Tournament>,
        historyTournaments: results[1] as List<Tournament>,
        userStats: results[2] as Map<String, dynamic>,
        isLoading: false,
        isOffline: !_ref.read(isOnlineSyncProvider),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to refresh tournaments',
      );
    }
  }

  /// Join a tournament
  Future<bool> joinTournament(String tournamentId) async {
    final success = await _service.joinTournament(tournamentId);
    if (success) {
      // Refresh to get updated participant count
      await refresh();
    }
    return success;
  }

  /// Submit score to a tournament
  Future<bool> submitScore(
    String tournamentId,
    int score,
    Map<String, dynamic> gameStats,
  ) async {
    return await _service.submitScore(tournamentId, score, gameStats);
  }

  /// Get tournament by ID
  Future<Tournament?> getTournament(String tournamentId) async {
    return await _service.getTournament(tournamentId);
  }

  /// Get tournament leaderboard
  Future<List<TournamentParticipant>> getTournamentLeaderboard(
    String tournamentId, {
    int limit = 50,
  }) async {
    return await _service.getTournamentLeaderboard(tournamentId, limit: limit);
  }

  @override
  void dispose() {
    _ttlTimer?.cancel();
    super.dispose();
  }
}

/// Provider for tournaments state
final tournamentsProvider =
    StateNotifierProvider<TournamentsNotifier, TournamentsState>((ref) {
  return TournamentsNotifier(ref);
});

/// Convenience provider for active tournaments
final activeTournamentsProvider = Provider<List<Tournament>>((ref) {
  return ref.watch(tournamentsProvider).activeTournaments;
});

/// Convenience provider for tournament history
final tournamentHistoryProvider = Provider<List<Tournament>>((ref) {
  return ref.watch(tournamentsProvider).historyTournaments;
});

/// Convenience provider for loading state
final tournamentsLoadingProvider = Provider<bool>((ref) {
  return ref.watch(tournamentsProvider).isLoading;
});

/// Convenience provider for offline state
final tournamentsOfflineProvider = Provider<bool>((ref) {
  return ref.watch(tournamentsProvider).isOffline;
});

/// Provider for tournament leaderboard (family provider by tournament ID)
final tournamentLeaderboardProvider =
    FutureProvider.family<List<TournamentParticipant>, String>(
  (ref, tournamentId) async {
    final notifier = ref.watch(tournamentsProvider.notifier);
    return await notifier.getTournamentLeaderboard(tournamentId);
  },
);
