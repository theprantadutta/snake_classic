/// Why the last sync attempt failed, at the coarseness a person can act on.
enum SyncFailureCategory {
  none,

  /// Never reached the server.
  transport,

  /// The session is gone. Nothing will drain until the user signs in again.
  auth,

  /// The backend answered 5xx.
  server,

  /// The server refused the payload on its merits. Retrying unchanged will
  /// not help — this is what a dead letter is made of.
  rejected,
}

/// One truthful answer to "is my data safe on the server yet?".
///
/// There were two systems claiming to answer that. `SyncEngine` is the
/// canonical outbox pusher for scores, statistics, coins, settings and the
/// rest; `DataSyncService` is a legacy transport that now owns little beyond
/// FCM token registration — and yet it was what the status indicator rendered
/// and what the app lifecycle called on foreground and background.
///
/// So the indicator could say everything was synced while the canonical
/// outbox held pending scores and a dead-lettered submission, and
/// `forceSyncNow()` on resume did not force the drain that actually mattered.
/// This snapshot comes from the canonical engine, and carries the legacy
/// queue as a named component rather than letting it speak for the whole.
class SyncStatusSnapshot {
  const SyncStatusSnapshot({
    this.pendingCount = 0,
    this.deadLetterCount = 0,
    this.legacyPendingCount = 0,
    this.isDraining = false,
    this.lastAttemptAt,
    this.lastSuccessAt,
    this.lastFailure = SyncFailureCategory.none,
  });

  /// Items in the canonical outbox waiting to go up.
  final int pendingCount;

  /// Items the server refused permanently, including rejected scores. These
  /// never leave on their own and are the thing most worth surfacing: they
  /// are silent data loss unless somebody is told.
  final int deadLetterCount;

  /// The remaining legacy queue (FCM token registration). Counted separately
  /// on purpose — it is not cloud-sync truth and should not be dressed up as
  /// it while it is being retired.
  final int legacyPendingCount;

  final bool isDraining;
  final DateTime? lastAttemptAt;
  final DateTime? lastSuccessAt;
  final SyncFailureCategory lastFailure;

  /// Everything the server needs to have is up there.
  bool get isFullySynced =>
      pendingCount == 0 && deadLetterCount == 0 && !isDraining;

  /// Something needs a person: a permanent rejection, or an expired session
  /// that will keep everything stuck until they sign in.
  bool get needsAttention =>
      deadLetterCount > 0 || lastFailure == SyncFailureCategory.auth;

  /// Work is waiting but nothing is wrong — the ordinary offline state.
  bool get hasPendingWork => pendingCount > 0 || legacyPendingCount > 0;

  SyncStatusSnapshot copyWith({
    int? pendingCount,
    int? deadLetterCount,
    int? legacyPendingCount,
    bool? isDraining,
    DateTime? lastAttemptAt,
    DateTime? lastSuccessAt,
    SyncFailureCategory? lastFailure,
  }) {
    return SyncStatusSnapshot(
      pendingCount: pendingCount ?? this.pendingCount,
      deadLetterCount: deadLetterCount ?? this.deadLetterCount,
      legacyPendingCount: legacyPendingCount ?? this.legacyPendingCount,
      isDraining: isDraining ?? this.isDraining,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastSuccessAt: lastSuccessAt ?? this.lastSuccessAt,
      lastFailure: lastFailure ?? this.lastFailure,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is SyncStatusSnapshot &&
      other.pendingCount == pendingCount &&
      other.deadLetterCount == deadLetterCount &&
      other.legacyPendingCount == legacyPendingCount &&
      other.isDraining == isDraining &&
      other.lastAttemptAt == lastAttemptAt &&
      other.lastSuccessAt == lastSuccessAt &&
      other.lastFailure == lastFailure;

  @override
  int get hashCode => Object.hash(
    pendingCount,
    deadLetterCount,
    legacyPendingCount,
    isDraining,
    lastAttemptAt,
    lastSuccessAt,
    lastFailure,
  );

  @override
  String toString() =>
      'SyncStatusSnapshot(pending: $pendingCount, deadLetter: $deadLetterCount, '
      'legacy: $legacyPendingCount, draining: $isDraining, '
      'lastFailure: ${lastFailure.name})';
}
