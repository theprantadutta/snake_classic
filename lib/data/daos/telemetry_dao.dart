import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:snake_classic/data/database/app_database.dart';

part 'telemetry_dao.g.dart';

/// Reads and writes the design-metrics telemetry tables.
///
/// No sync outbox here, on purpose: these rows are not user state and the
/// SyncEngine never drains them. TelemetryUploader is their only reader.
@DriftAccessor(tables: [TelemetrySessions, TelemetryFeedback])
class TelemetryDao extends DatabaseAccessor<AppDatabase>
    with _$TelemetryDaoMixin {
  TelemetryDao(super.db);

  // ==================== Sessions ====================

  /// Write the whole session snapshot. The tracker is the only writer of an
  /// open session and always sends a higher [TelemetrySessionsCompanion.revision]
  /// than the last one, so a full replace can never lose a counter.
  Future<void> upsertSession(TelemetrySessionsCompanion row) =>
      into(telemetrySessions).insertOnConflictUpdate(row);

  /// Close every session that never recorded its end, other than
  /// [currentSessionId]: the process was killed or crashed while it was in
  /// the foreground. Its end is estimated as the last time it was written.
  ///
  /// Returns how many sessions were closed this way.
  Future<int> closeAbandonedSessions(String currentSessionId) {
    return (update(telemetrySessions)
          ..where(
            (t) =>
                t.endedAt.isNull() & t.sessionId.equals(currentSessionId).not(),
          ))
        .write(
      TelemetrySessionsCompanion.custom(
        abnormalEnd: const Constant(true),
        endedAt: telemetrySessions.lastActiveAt,
        dirty: const Constant(true),
        revision: telemetrySessions.revision + const Constant(1),
      ),
    );
  }

  /// Sessions the server has not seen in their current form, oldest first.
  /// Poisoned sessions are never offered again.
  Future<List<TelemetrySession>> dirtySessions({required int limit}) =>
      (select(telemetrySessions)
            ..where((t) => t.dirty.equals(true) & t.poisoned.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.startedAt)])
            ..limit(limit))
          .get();

  /// Mark sessions clean — but only at the revision that was actually sent.
  /// A session written again while the upload was in flight keeps its dirty
  /// flag and goes out on the next flush.
  Future<void> markSessionsUploaded(
    Map<String, int> revisionsSent,
    DateTime uploadedAt,
  ) {
    return transaction(() async {
      for (final entry in revisionsSent.entries) {
        await (update(telemetrySessions)
              ..where(
                (t) =>
                    t.sessionId.equals(entry.key) &
                    t.revision.equals(entry.value),
              ))
            .write(
          TelemetrySessionsCompanion(
            dirty: const Value(false),
            uploadedAt: Value(uploadedAt),
          ),
        );
      }
    });
  }

  /// Give up on sessions the server refused (or would refuse). They stay on
  /// disk, flagged, until the stale-row prune — see
  /// [TelemetrySessions.poisoned].
  Future<void> poisonSessions(List<String> sessionIds) {
    if (sessionIds.isEmpty) return Future.value();
    return (update(telemetrySessions)
          ..where((t) => t.sessionId.isIn(sessionIds)))
        .write(
      const TelemetrySessionsCompanion(
        poisoned: Value(true),
        dirty: Value(false),
      ),
    );
  }

  @visibleForTesting
  Future<TelemetrySession?> sessionById(String sessionId) =>
      (select(telemetrySessions)..where((t) => t.sessionId.equals(sessionId)))
          .getSingleOrNull();

  // ==================== Feedback ====================

  Future<void> insertFeedback(TelemetryFeedbackCompanion row) =>
      into(telemetryFeedback).insert(row, mode: InsertMode.insertOrIgnore);

  Future<List<TelemetryFeedbackData>> dirtyFeedback({required int limit}) =>
      (select(telemetryFeedback)
            ..where((t) => t.dirty.equals(true))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)])
            ..limit(limit))
          .get();

  /// Drop answers the server refused (or would refuse). An answer is
  /// immutable, so unlike a session nothing would ever make it acceptable.
  Future<void> deleteFeedback(List<String> ids) {
    if (ids.isEmpty) return Future.value();
    return (delete(telemetryFeedback)..where((t) => t.feedbackId.isIn(ids)))
        .go();
  }

  @visibleForTesting
  Future<List<TelemetryFeedbackData>> allFeedback() =>
      select(telemetryFeedback).get();

  Future<void> markFeedbackUploaded(List<String> ids, DateTime uploadedAt) {
    if (ids.isEmpty) return Future.value();
    return (update(telemetryFeedback)..where((t) => t.feedbackId.isIn(ids)))
        .write(
      TelemetryFeedbackCompanion(
        dirty: const Value(false),
        uploadedAt: Value(uploadedAt),
      ),
    );
  }

  // ==================== Pruning ====================

  /// Delete rows the server already has, once they are older than
  /// [uploadedBefore], and rows that have been waiting since before
  /// [staleBefore] without ever getting through.
  ///
  /// The second rule only bounds storage on a device that cannot reach the
  /// server for weeks (or whose rows the server keeps refusing); a session
  /// that old is no longer useful to the dashboard anyway.
  Future<void> prune({
    required DateTime uploadedBefore,
    required DateTime staleBefore,
  }) {
    return transaction(() async {
      await (delete(telemetrySessions)
            ..where(
              (t) =>
                  (t.dirty.equals(false) &
                      t.uploadedAt.isSmallerThanValue(uploadedBefore)) |
                  t.lastActiveAt.isSmallerThanValue(staleBefore),
            ))
          .go();
      await (delete(telemetryFeedback)
            ..where(
              (t) =>
                  (t.dirty.equals(false) &
                      t.uploadedAt.isSmallerThanValue(uploadedBefore)) |
                  t.createdAt.isSmallerThanValue(staleBefore),
            ))
          .go();
    });
  }
}
