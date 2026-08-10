import 'package:drift/drift.dart';
import 'package:snake_classic/data/database/app_database.dart' as db;
import 'package:snake_classic/data/database/settlement_write.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';

/// Applies one settlement's entire durable effect, atomically.
///
/// Deliberately ONE operation rather than three steps. Per-step progress was
/// an attempt to survive a crash between two of them, but each step still had
/// its own window between the reward landing and the record of it committing,
/// and the reward paths underneath swallowed their own failures so "the step
/// succeeded" could not be trusted anyway. One transaction removes the
/// question: the whole settlement applies or none of it does.
abstract class SettlementWriter {
  /// Returns true if this call applied the settlement, false if it was already
  /// applied. Throws if anything failed — in which case nothing was written.
  Future<bool> applyOnce(MultiplayerSettlement settlement);

  /// Whether [settlementId] is fully applied.
  Future<bool> isApplied(String settlementId);

  /// Ids among [candidates] that are fully applied.
  Future<Set<String>> appliedIds(List<String> candidates);
}

/// The two settlement calls, behind an interface.
///
/// ApiService is a singleton with a private constructor, so the retry
/// behaviour — which is the part that decides whether a player eventually gets
/// paid — could not otherwise be tested at all.
abstract class SettlementApi {
  Future<List<Map<String, dynamic>>?> fetchPending();
  Future<bool> acknowledge(List<String> settlementIds);
}

/// The real thing: one Drift transaction covering statistics, coins,
/// battle-pass XP, lifetime XP, the level-up coins that XP triggers, and the
/// settlement marker.
///
/// In-memory state is refreshed only AFTER the commit returns — the write path
/// touches no cubit at all, so a rollback cannot leave memory ahead of the
/// database.
class DriftSettlementWriter implements SettlementWriter {
  DriftSettlementWriter(this._db, {this.onApplied});

  final db.AppDatabase _db;

  /// Called after a successful commit with what changed, so the caller can
  /// refresh the in-memory layer. Never called for a rolled-back attempt.
  final Future<void> Function(SettlementWriteResult result)? onApplied;

  @override
  Future<bool> applyOnce(MultiplayerSettlement settlement) async {
    // A match the server never settled pays nothing. Mark it so it stops
    // coming back, without pretending anything was granted.
    if (settlement.wasInterrupted) {
      await _db.markSettlementApplied(settlement.id);
      return true;
    }

    final result = await _db.applyMultiplayerSettlementOnce(
      settlementId: settlement.id,
      coinsAwarded: settlement.coinsAwarded,
      battlePassXpAwarded: settlement.battlePassXpAwarded,
      score: settlement.score,
      foodsEaten: settlement.foodsEaten,
      durationSeconds: settlement.durationSeconds,
      survivedToEnd: settlement.survivedToEnd,
      deathReason: settlement.deathReason,
      won: settlement.isWin,
    );

    if (result.applied) {
      await onApplied?.call(result);
    }
    return result.applied;
  }

  @override
  Future<bool> isApplied(String settlementId) =>
      _db.isSettlementApplied(settlementId);

  @override
  Future<Set<String>> appliedIds(List<String> candidates) async {
    if (candidates.isEmpty) return <String>{};
    final rows = await (_db.select(_db.appliedMultiplayerSettlements)
          ..where((t) =>
              t.settlementId.isIn(candidates) & t.completedAt.isNotNull()))
        .get();
    return rows.map((r) => r.settlementId).toSet();
  }
}
