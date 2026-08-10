import 'package:drift/drift.dart';
import 'package:snake_classic/data/database/app_database.dart' as db;
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';

/// How far this device has got applying one settlement.
///
/// Applying a settlement is three separate durable writes — statistics, coins,
/// battle-pass XP — through three different subsystems, with no transaction
/// spanning them. A single "applied" flag could only be set before them all (a
/// crash then loses real rewards) or after (a crash then replays whatever
/// already landed, double-counting statistics). Neither is acceptable for
/// money, so each step is recorded as it completes and a retry resumes from
/// the first one still outstanding.
class SettlementProgress {
  final String settlementId;
  final bool statsApplied;
  final bool coinsApplied;
  final bool xpApplied;
  final bool completed;

  const SettlementProgress({
    required this.settlementId,
    this.statsApplied = false,
    this.coinsApplied = false,
    this.xpApplied = false,
    this.completed = false,
  });

  bool get allStepsDone => statsApplied && coinsApplied && xpApplied;

  SettlementProgress copyWith({
    bool? statsApplied,
    bool? coinsApplied,
    bool? xpApplied,
    bool? completed,
  }) {
    return SettlementProgress(
      settlementId: settlementId,
      statsApplied: statsApplied ?? this.statsApplied,
      coinsApplied: coinsApplied ?? this.coinsApplied,
      xpApplied: xpApplied ?? this.xpApplied,
      completed: completed ?? this.completed,
    );
  }
}

/// Durable record of settlement application progress.
///
/// An interface so the crash cases can be tested — the point of this whole
/// design is what happens when the process dies between two writes, and that
/// is not observable through a real database from inside the same process.
abstract class SettlementLedger {
  Future<SettlementProgress?> read(String settlementId);
  Future<void> write(SettlementProgress progress);

  /// Ids among [candidates] that are fully applied. Partially applied ones are
  /// deliberately absent: they must be resumed, not skipped.
  Future<Set<String>> completedIds(List<String> candidates);
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

/// Where a settlement's rewards actually land.
///
/// Every method is awaited by the applier and must not return until its write
/// is durable — a step that reports success before it has landed reintroduces
/// exactly the loss this design exists to prevent.
abstract class SettlementRewardSink {
  Future<void> applyStats(MultiplayerSettlement settlement);
  Future<void> applyCoins(MultiplayerSettlement settlement);
  Future<void> applyBattlePassXp(MultiplayerSettlement settlement);
}

/// Drift-backed ledger.
class DriftSettlementLedger implements SettlementLedger {
  DriftSettlementLedger(this._db);

  final db.AppDatabase _db;

  @override
  Future<SettlementProgress?> read(String settlementId) async {
    final row = await (_db.select(_db.appliedMultiplayerSettlements)
          ..where((t) => t.settlementId.equals(settlementId)))
        .getSingleOrNull();
    if (row == null) return null;
    return SettlementProgress(
      settlementId: row.settlementId,
      statsApplied: row.statsApplied,
      coinsApplied: row.coinsApplied,
      xpApplied: row.xpApplied,
      completed: row.completedAt != null,
    );
  }

  @override
  Future<void> write(SettlementProgress progress) async {
    await _db.into(_db.appliedMultiplayerSettlements).insertOnConflictUpdate(
          db.AppliedMultiplayerSettlementsCompanion.insert(
            settlementId: progress.settlementId,
            statsApplied: Value(progress.statsApplied),
            coinsApplied: Value(progress.coinsApplied),
            xpApplied: Value(progress.xpApplied),
            completedAt: progress.completed
                ? Value(DateTime.now())
                : const Value.absent(),
          ),
        );
  }

  @override
  Future<Set<String>> completedIds(List<String> candidates) async {
    if (candidates.isEmpty) return <String>{};
    final rows = await (_db.select(_db.appliedMultiplayerSettlements)
          ..where((t) =>
              t.settlementId.isIn(candidates) & t.completedAt.isNotNull()))
        .get();
    return rows.map((r) => r.settlementId).toSet();
  }
}

/// Applies one settlement, resuming from wherever a previous attempt stopped.
///
/// The ordering rule, in one place: **each step is recorded only after its
/// write has returned.** A crash before the record replays that one step (the
/// underlying grants tolerate it — the step simply has not happened yet); a
/// crash after it skips that step forever. What can never happen is the whole
/// settlement being marked done while any part of it is still outstanding.
class SettlementApplier {
  SettlementApplier({
    required SettlementLedger ledger,
    required SettlementRewardSink sink,
  }) {
    _ledger = ledger;
    _sink = sink;
  }

  late final SettlementLedger _ledger;
  late final SettlementRewardSink _sink;

  /// Apply everything still outstanding for [settlement].
  ///
  /// Returns true once the settlement is fully applied — the ONLY condition
  /// under which the caller may acknowledge it to the server. Throws if a step
  /// fails, having durably recorded every step that did succeed, so the retry
  /// picks up where this attempt stopped.
  Future<bool> apply(MultiplayerSettlement settlement) async {
    var progress = await _ledger.read(settlement.id) ??
        SettlementProgress(settlementId: settlement.id);

    if (progress.completed) return true;

    // A match the server never settled pays nothing and records nothing. Mark
    // it done so it stops coming back, without pretending anything was
    // granted.
    if (settlement.wasInterrupted) {
      await _ledger.write(progress.copyWith(
        statsApplied: true,
        coinsApplied: true,
        xpApplied: true,
        completed: true,
      ));
      return true;
    }

    if (!progress.statsApplied) {
      await _sink.applyStats(settlement);
      progress = progress.copyWith(statsApplied: true);
      await _ledger.write(progress);
    }

    if (!progress.coinsApplied) {
      await _sink.applyCoins(settlement);
      progress = progress.copyWith(coinsApplied: true);
      await _ledger.write(progress);
    }

    if (!progress.xpApplied) {
      await _sink.applyBattlePassXp(settlement);
      progress = progress.copyWith(xpApplied: true);
      await _ledger.write(progress);
    }

    await _ledger.write(progress.copyWith(completed: true));
    return true;
  }
}
