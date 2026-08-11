import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/sync/sync_status.dart';

/// What the sync indicator is allowed to claim.
///
/// There were two systems answering "is my data safe on the server yet?".
/// SyncEngine is the canonical outbox pusher for scores, statistics, coins and
/// settings; DataSyncService is a legacy transport that by now owns little
/// beyond FCM token registration — and yet it was what the indicator rendered
/// and what the app lifecycle called on foreground and background. So the
/// indicator could show a contented "all synced" while the real outbox held
/// pending scores and a dead-lettered submission nobody was told about.
void main() {
  group('fully synced means fully synced', () {
    test('nothing pending, nothing rejected, nothing running', () {
      const status = SyncStatusSnapshot();
      expect(status.isFullySynced, isTrue);
      expect(status.needsAttention, isFalse);
      expect(status.hasPendingWork, isFalse);
    });

    test('pending canonical work is not "synced"', () {
      // The exact lie the old indicator told.
      const status = SyncStatusSnapshot(pendingCount: 3);
      expect(status.isFullySynced, isFalse);
      expect(status.hasPendingWork, isTrue);
    });

    test('a dead letter is not "synced" either', () {
      // A rejected score never leaves on its own. Showing a green cloud over
      // it is silent data loss with a reassuring icon on top.
      const status = SyncStatusSnapshot(deadLetterCount: 1);
      expect(status.isFullySynced, isFalse);
      expect(status.needsAttention, isTrue);
    });

    test('a drain in flight is not "synced" yet', () {
      const status = SyncStatusSnapshot(isDraining: true);
      expect(status.isFullySynced, isFalse);
    });
  });

  group('the legacy queue is counted, but does not speak for the whole', () {
    test('legacy work counts as pending work', () {
      const status = SyncStatusSnapshot(legacyPendingCount: 2);
      expect(status.hasPendingWork, isTrue);
    });

    test('legacy work alone does not block "fully synced"', () {
      // FCM token registration is not what anyone means by "my data is
      // backed up", and it is being retired. It must be visible without
      // being able to hold the canonical state hostage.
      const status = SyncStatusSnapshot(legacyPendingCount: 2);
      expect(status.isFullySynced, isTrue);
      expect(status.needsAttention, isFalse);
    });

    test('the two counts stay separable', () {
      const status = SyncStatusSnapshot(pendingCount: 4, legacyPendingCount: 1);
      expect(status.pendingCount, 4);
      expect(status.legacyPendingCount, 1);
    });
  });

  group('what needs a person', () {
    test('an expired session does, because nothing will drain until it is fixed', () {
      const status = SyncStatusSnapshot(
        pendingCount: 5,
        lastFailure: SyncFailureCategory.auth,
      );
      expect(status.needsAttention, isTrue);
    });

    test('a transport failure does not — that is just being offline', () {
      const status = SyncStatusSnapshot(
        pendingCount: 5,
        lastFailure: SyncFailureCategory.transport,
      );
      expect(status.needsAttention, isFalse,
          reason: 'a backlog while offline is the normal, working state');
    });

    test('a server failure does not either — it clears on its own', () {
      const status = SyncStatusSnapshot(
        pendingCount: 2,
        lastFailure: SyncFailureCategory.server,
      );
      expect(status.needsAttention, isFalse);
    });
  });

  test('equality is by value so the stream can dedupe', () {
    const a = SyncStatusSnapshot(pendingCount: 2, deadLetterCount: 1);
    const b = SyncStatusSnapshot(pendingCount: 2, deadLetterCount: 1);
    const c = SyncStatusSnapshot(pendingCount: 3, deadLetterCount: 1);

    expect(a, b);
    expect(a.hashCode, b.hashCode);
    expect(a, isNot(c));
  });

  test('copyWith preserves what it is not given', () {
    final at = DateTime.utc(2026, 8, 11);
    final base = SyncStatusSnapshot(pendingCount: 3, lastSuccessAt: at);
    final next = base.copyWith(isDraining: true);

    expect(next.pendingCount, 3);
    expect(next.lastSuccessAt, at);
    expect(next.isDraining, isTrue);
  });
}
