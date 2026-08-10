import 'package:drift/drift.dart';
import 'package:snake_classic/data/database/app_database.dart' as db;
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';

/// One durable effect of applying a settlement.
enum SettlementStep { stats, coins, xp }

/// How far this device has got applying one settlement.
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

  bool hasStep(SettlementStep step) => switch (step) {
        SettlementStep.stats => statsApplied,
        SettlementStep.coins => coinsApplied,
        SettlementStep.xp => xpApplied,
      };

  SettlementProgress withStep(SettlementStep step) => switch (step) {
        SettlementStep.stats => copyWith(statsApplied: true),
        SettlementStep.coins => copyWith(coinsApplied: true),
        SettlementStep.xp => copyWith(xpApplied: true),
      };

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

/// Durable record of settlement application progress, and the thing that makes
/// each step happen exactly once.
///
/// The whole guarantee lives in [runStepOnce]. Recording a step AFTER its
/// effect returned — the obvious way to write this, and what this did at
/// first — leaves a window where the reward has landed and the record has not.
/// A crash there replays the step on the next attempt and pays it twice. No
/// ordering of two separate writes closes that window: the record has to
/// commit WITH the effect, in one transaction, or not at all.
abstract class SettlementLedger {
  Future<SettlementProgress?> read(String settlementId);

  /// Run [effect] and record [step] as one atomic unit: either the reward and
  /// its record are both durable, or neither is. Returns false when the step
  /// was already recorded, in which case [effect] is NOT run.
  ///
  /// A rollback can leave a cubit's in-memory state briefly ahead of what is
  /// durable. That is acceptable and self-correcting: every cubit on these
  /// paths rehydrates from Drift — watches during the session, a load on
  /// launch — so durable state is the authority and memory is a cache of it.
  Future<bool> runStepOnce(
    String settlementId,
    SettlementStep step,
    Future<void> Function() effect,
  );

  /// Mark the settlement fully applied. Grants nothing, so repeating it is
  /// free: a crash before it simply means the next attempt finds every step
  /// already recorded and completes without replaying any of them.
  Future<void> markCompleted(String settlementId);

  /// Ids among [candidates] that are fully applied. Partially applied ones are
  /// deliberately absent: they must be resumed, not skipped.
  Future<Set<String>> completedIds(List<String> candidates);
}

/// Where a settlement's rewards actually land.
///
/// Each of these runs inside the ledger's transaction, so its durable write
/// and the record of it commit together.
abstract class SettlementRewardSink {
  Future<void> applyStats(MultiplayerSettlement settlement);
  Future<void> applyCoins(MultiplayerSettlement settlement);
  Future<void> applyBattlePassXp(MultiplayerSettlement settlement);
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

/// Drift-backed ledger.
///
/// [runStepOnce] opens a Drift transaction and calls the effect inside it.
/// Every reward path here ends in a write on this same [db.AppDatabase], and
/// Drift joins a nested `transaction()` to the open one as a savepoint — so
/// the reward and its marker genuinely commit or roll back together.
class DriftSettlementLedger implements SettlementLedger {
  DriftSettlementLedger(this._db);

  final db.AppDatabase _db;

  @override
  Future<SettlementProgress?> read(String settlementId) => _read(settlementId);

  Future<SettlementProgress?> _read(String settlementId) async {
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
  Future<bool> runStepOnce(
    String settlementId,
    SettlementStep step,
    Future<void> Function() effect,
  ) {
    return _db.transaction(() async {
      // Read INSIDE the transaction: a concurrent pass must not see a stale
      // "not applied yet" and grant the same reward alongside this one.
      final existing = await _read(settlementId) ??
          SettlementProgress(settlementId: settlementId);
      if (existing.hasStep(step)) return false;

      await effect();
      await _write(existing.withStep(step));
      return true;
    });
  }

  @override
  Future<void> markCompleted(String settlementId) async {
    final existing = await _read(settlementId) ??
        SettlementProgress(settlementId: settlementId);
    await _write(existing.copyWith(completed: true));
  }

  Future<void> _write(SettlementProgress progress) async {
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
/// Every reward goes through [SettlementLedger.runStepOnce], which is the only
/// place that decides whether a step still needs doing and the only place that
/// records that it was done — in the same transaction as the reward itself.
/// The applier deliberately does no check-then-act of its own: that pattern is
/// what created the window where a crash between the act and the record paid a
/// reward twice.
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
  /// Returns true once fully applied — the ONLY condition under which the
  /// caller may acknowledge it. Throws if a step fails, having committed every
  /// step that did succeed, so the retry resumes rather than restarts.
  Future<bool> apply(MultiplayerSettlement settlement) async {
    final progress = await _ledger.read(settlement.id);
    if (progress?.completed == true) return true;

    // A match the server never settled pays nothing and records nothing. Mark
    // it done so it stops coming back, without pretending anything was granted.
    if (settlement.wasInterrupted) {
      await _ledger.markCompleted(settlement.id);
      return true;
    }

    await _ledger.runStepOnce(
      settlement.id,
      SettlementStep.stats,
      () => _sink.applyStats(settlement),
    );
    await _ledger.runStepOnce(
      settlement.id,
      SettlementStep.coins,
      () => _sink.applyCoins(settlement),
    );
    await _ledger.runStepOnce(
      settlement.id,
      SettlementStep.xp,
      () => _sink.applyBattlePassXp(settlement),
    );

    await _ledger.markCompleted(settlement.id);
    return true;
  }
}
