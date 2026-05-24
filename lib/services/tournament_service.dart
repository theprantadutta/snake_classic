import 'dart:async';
import 'package:snake_classic/models/tournament.dart';

/// Server-authoritative leaderboard shape used by the (now dormant)
/// tournament detail screen. Kept as a class so existing imports
/// resolve; instances are produced empty by the stub service.
class TournamentLeaderboardResult {
  final List<TournamentParticipant> entries;
  final int? userRank;

  const TournamentLeaderboardResult({
    required this.entries,
    required this.userRank,
  });
}

/// Offline-first stub. Tournaments depend on a live backend (join,
/// rank, prize distribution) and are disabled in this build. The
/// service stays in the tree so DI and existing call sites compile;
/// every method returns empty data, and `joinTournament` returns false.
///
/// To revive: restore the prior implementation from git history and
/// re-add the tournament endpoints to [ApiService].
class TournamentService {
  static TournamentService? _instance;

  final StreamController<String> _joinedController =
      StreamController<String>.broadcast();

  Stream<String> get onTournamentJoined => _joinedController.stream;

  TournamentService._internal();

  factory TournamentService() {
    _instance ??= TournamentService._internal();
    return _instance!;
  }

  Future<List<Tournament>> getActiveTournaments() async => const [];

  Future<List<Tournament>> getTournamentHistory({int limit = 10}) async =>
      const [];

  Future<Tournament?> getTournament(String tournamentId) async => null;

  Future<bool> joinTournament(String tournamentId, {String? entryTier}) async =>
      false;

  Future<bool> submitScore(
    String tournamentId,
    int score,
    Map<String, dynamic> gameStats,
  ) async => false;

  Future<TournamentLeaderboardResult> getTournamentLeaderboard(
    String tournamentId, {
    int limit = 50,
  }) async => const TournamentLeaderboardResult(entries: [], userRank: null);

  Future<Map<String, dynamic>> getUserTournamentStats() async => const {};

  Future<bool> hasCachedData() async => false;

  Future<void> clearCache() async {}

  Stream<List<Tournament>> watchActiveTournaments() => const Stream.empty();

  Stream<List<TournamentParticipant>> watchTournamentLeaderboard(
    String tournamentId, {
    int limit = 50,
  }) => const Stream.empty();
}
