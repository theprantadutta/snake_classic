import 'package:snake_classic/data/database/app_database.dart' as db;
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/game_end_pipeline.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/utils/logger.dart';

/// Applies the match rewards the server says this player is owed.
///
/// The order is deliberate and is the whole point: apply locally, record
/// locally, THEN acknowledge remotely. A crash anywhere in that sequence costs
/// an extra fetch, never a duplicate payout — the local ledger is checked
/// before anything is credited, and the server keeps handing the row back
/// until it is acknowledged.
///
/// Runs after every match and on launch. The launch pass is what repairs a
/// result whose broadcast never arrived, which used to be unrecoverable.
class MultiplayerSettlementService {
  MultiplayerSettlementService({
    required db.AppDatabase database,
    required GameEndPipeline endPipeline,
    ApiService? apiService,
  })  : _db = database,
        _api = apiService ?? ApiService() {
    _endPipeline = endPipeline;
  }

  final db.AppDatabase _db;
  late final GameEndPipeline _endPipeline;
  final ApiService _api;

  /// Guards against two triggers overlapping (a match ending as the launch
  /// pass is still running). Without it both could read the ledger before
  /// either writes to it.
  bool _running = false;

  /// Fetch, apply and acknowledge everything outstanding. Returns the number
  /// of settlements newly applied.
  Future<int> syncPending() async {
    if (_running) return 0;
    _running = true;
    try {
      final rows = await _api.getPendingMultiplayerSettlements();
      if (rows == null || rows.isEmpty) return 0;

      final fetched = MultiplayerSettlement.parseAll(rows);
      if (fetched.isEmpty) return 0;

      final applied = await _appliedIds(fetched.map((s) => s.id).toList());
      final plan = planSettlements(fetched: fetched, alreadyApplied: applied);

      for (final settlement in plan.toApply) {
        try {
          await _apply(settlement);
          // Recorded BEFORE acknowledging: if the ack never lands, the next
          // fetch returns this row again and the ledger is what stops it
          // being paid twice.
          await _markApplied(settlement.id);
        } catch (e) {
          AppLogger.error(
            'Failed to apply multiplayer settlement ${settlement.id}',
            e,
          );
          // Leave it unacknowledged so it comes back next time.
          plan.toAcknowledge.remove(settlement.id);
        }
      }

      if (plan.toAcknowledge.isNotEmpty) {
        await _api.ackMultiplayerSettlements(plan.toAcknowledge);
      }

      if (plan.toApply.isNotEmpty) {
        AppLogger.info(
          'Applied ${plan.toApply.length} multiplayer settlement(s)',
        );
      }
      return plan.toApply.length;
    } catch (e) {
      AppLogger.error('Multiplayer settlement sync failed', e);
      return 0;
    } finally {
      _running = false;
    }
  }

  Future<void> _apply(MultiplayerSettlement settlement) async {
    // An interrupted match has no verdict, so it pays nothing and records
    // nothing. The row exists only so the player can be told.
    if (settlement.wasInterrupted) return;

    await _endPipeline.recordMultiplayerMatch(
      score: settlement.score,
      foodsEaten: settlement.foodsEaten,
      gameTimeSeconds: settlement.durationSeconds,
      alive: settlement.survivedToEnd,
      deathReason: settlement.deathReason,
    );

    _endPipeline.creditMultiplayerSettlement(
      coins: settlement.coinsAwarded,
      battlePassXp: settlement.battlePassXpAwarded,
      won: settlement.isWin,
    );
  }

  Future<Set<String>> _appliedIds(List<String> candidates) async {
    if (candidates.isEmpty) return <String>{};
    final rows = await (_db.select(_db.appliedMultiplayerSettlements)
          ..where((t) => t.settlementId.isIn(candidates)))
        .get();
    return rows.map((r) => r.settlementId).toSet();
  }

  Future<void> _markApplied(String settlementId) async {
    await _db
        .into(_db.appliedMultiplayerSettlements)
        .insertOnConflictUpdate(
          db.AppliedMultiplayerSettlementsCompanion.insert(
            settlementId: settlementId,
          ),
        );
  }
}
