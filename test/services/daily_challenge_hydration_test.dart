import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/daily_challenge.dart';
import 'package:snake_classic/services/daily_challenge_hydration.dart';

/// A persisted row, as `_toCompanion` writes it.
LocalChallengeRow row({
  String id = 'c1',
  String type = 'GameMode',
  String title = 'Classic Lover',
  String description = 'Play 1 game in Classic mode',
  int progress = 0,
  int target = 1,
  int coins = 8,
  bool completed = false,
  bool claimed = false,
  String? requiredGameMode,
  int xp = 0,
  String? difficulty,
}) {
  return LocalChallengeRow(
    challengeId: id,
    challengeType: type,
    title: title,
    description: description,
    currentProgress: progress,
    targetProgress: target,
    rewardCoins: coins,
    isCompleted: completed,
    rewardClaimed: claimed,
    requiredGameMode: requiredGameMode,
    xpReward: xp,
    difficulty: difficulty,
  );
}

/// A challenge as the backend hands it back.
DailyChallenge backend({
  String id = 'c1',
  String title = 'Classic Lover',
  int progress = 0,
  int target = 1,
  int coins = 8,
  bool completed = false,
  bool claimed = false,
  String? requiredGameMode,
}) {
  return DailyChallenge(
    id: id,
    title: title,
    description: 'Play 1 game in Classic mode',
    type: ChallengeType.gameMode,
    difficulty: ChallengeDifficulty.easy,
    targetValue: target,
    currentProgress: progress,
    isCompleted: completed,
    coinReward: coins,
    xpReward: 20,
    requiredGameMode: requiredGameMode,
    claimedReward: claimed,
  );
}

Map<String, LocalChallengeRow> byId(List<LocalChallengeRow> rows) =>
    {for (final r in rows) r.challengeId: r};

void main() {
  group('backend unavailable', () {
    test(
      'a completed, unclaimed local row stays visible and stays claimable',
      () {
        // The exact state found on the device: completed, never claimed.
        final hydrated = hydrateFromLocalRows([
          row(progress: 1, target: 1, completed: true, claimed: false),
        ]);

        expect(hydrated, hasLength(1));
        expect(hydrated.single.isCompleted, isTrue);
        expect(hydrated.single.claimedReward, isFalse);
        expect(
          hydrated.single.canClaim,
          isTrue,
          reason: 'an earned reward must remain claimable while offline',
        );
        expect(hydrated.single.coinReward, 8);
      },
    );

    test('an in-progress local row is visible but not claimable', () {
      final hydrated = hydrateFromLocalRows([
        row(id: 'c2', progress: 18, target: 180, completed: false),
      ]);

      expect(hydrated.single.currentProgress, 18);
      expect(hydrated.single.isCompleted, isFalse);
      expect(hydrated.single.canClaim, isFalse);
    });

    test('an already-claimed local row is visible and NOT claimable again', () {
      final hydrated = hydrateFromLocalRows([
        row(progress: 1, target: 1, completed: true, claimed: true),
      ]);

      expect(hydrated.single.claimedReward, isTrue);
      expect(
        hydrated.single.canClaim,
        isFalse,
        reason: 'hydration must never re-offer a reward that was already paid',
      );
    });

    test('hydration never invents a claim — flags come straight off the row',
        () {
      final rows = [
        row(id: 'a', completed: true, claimed: false),
        row(id: 'b', completed: true, claimed: true),
        row(id: 'c', completed: false, claimed: false),
      ];

      final hydrated = hydrateFromLocalRows(rows);
      expect(
        {for (final c in hydrated) c.id: c.claimedReward},
        {'a': false, 'b': true, 'c': false},
      );
    });

    test('the synthetic all-complete bonus row is not a visible challenge', () {
      final bonusId = allCompleteBonusIdFor(DateTime(2026, 8, 9));
      expect(isAllCompleteBonusId(bonusId), isTrue);

      final hydrated = hydrateFromLocalRows([
        row(id: 'c1', completed: true),
        row(id: bonusId, type: 'bonus', completed: true, claimed: true),
      ]);

      expect(hydrated.map((c) => c.id), ['c1']);
    });

    test('no local rows hydrates to an empty list, not a crash', () {
      expect(hydrateFromLocalRows(const []), isEmpty);
      expect(countsFor(const []).allCompleted, isFalse);
    });

    test('the reward XP and difficulty survive, so the card tells the truth',
        () {
      // Without these columns a hydrated card advertised "0 XP" and "Easy"
      // for every challenge — the screen misstating its own rewards.
      final hydrated = hydrateFromLocalRows([
        row(xp: 20, difficulty: 'hard'),
      ]);
      expect(hydrated.single.xpReward, 20);
      expect(hydrated.single.difficulty, ChallengeDifficulty.hard);
    });

    test('a row with no difficulty recorded falls back to easy', () {
      expect(
        hydrateFromLocalRows([row()]).single.difficulty,
        ChallengeDifficulty.easy,
      );
    });

    test('the required game mode survives, so progress still targets it', () {
      // Without this the challenge would read as "any mode" and credit a
      // Zen game toward a Classic-only goal for the whole offline session.
      final hydrated = hydrateFromLocalRows([
        row(requiredGameMode: 'classic'),
      ]);
      expect(hydrated.single.requiredGameMode, 'classic');
    });
  });

  group('restart persistence', () {
    test('the same rows hydrate to the same list, in the same order', () {
      final rows = [
        row(id: 'zzz', completed: true),
        row(id: 'aaa', progress: 2, target: 5),
        row(id: 'mmm', completed: true, claimed: true),
      ];

      final first = hydrateFromLocalRows(rows);
      // A restart reads them back in whatever order SQLite returns them.
      final second = hydrateFromLocalRows(rows.reversed);

      expect(first.map((c) => c.id), ['aaa', 'mmm', 'zzz']);
      expect(second.map((c) => c.id), first.map((c) => c.id));
      expect(
        second.map((c) => c.claimedReward),
        first.map((c) => c.claimedReward),
      );
      expect(
        second.map((c) => c.currentProgress),
        first.map((c) => c.currentProgress),
      );
    });

    test('counts survive a restart', () {
      final hydrated = hydrateFromLocalRows([
        row(id: 'a', completed: true),
        row(id: 'b', completed: true, claimed: true),
        row(id: 'c', progress: 1, target: 5),
      ]);

      final counts = countsFor(hydrated);
      expect(counts.total, 3);
      expect(counts.completed, 2);
      expect(counts.allCompleted, isFalse);
    });

    test('all-complete is true only when every challenge is complete', () {
      final all = hydrateFromLocalRows([
        row(id: 'a', completed: true),
        row(id: 'b', completed: true, claimed: true),
      ]);
      expect(countsFor(all).allCompleted, isTrue);
    });

    test('a row over target with no flag still reads as complete', () {
      // Written by an older client that only bumped progress.
      final hydrated = hydrateFromLocalRows([
        row(progress: 5, target: 5, completed: false),
      ]);
      expect(hydrated.single.isCompleted, isTrue);
      expect(hydrated.single.canClaim, isTrue);
    });
  });

  group('successful refresh merge', () {
    test('offline progress the server has not seen yet wins (MAX)', () {
      final merged = mergeBackendWithLocal(
        [backend(progress: 1, target: 5)],
        byId([row(progress: 4, target: 5)]),
      );
      expect(merged.single.currentProgress, 4);
    });

    test('server progress wins when it is ahead', () {
      final merged = mergeBackendWithLocal(
        [backend(progress: 4, target: 5)],
        byId([row(progress: 1, target: 5)]),
      );
      expect(merged.single.currentProgress, 4);
    });

    test('a claim made offline is not resurrected by the refresh', () {
      // The server still reports it unclaimed — the outbox hasn't drained.
      final merged = mergeBackendWithLocal(
        [backend(completed: true, claimed: false)],
        byId([row(completed: true, claimed: true)]),
      );
      expect(merged.single.claimedReward, isTrue);
      expect(
        merged.single.canClaim,
        isFalse,
        reason: 'a refresh must not re-offer a reward already taken offline',
      );
    });

    test('a claim made on another device is adopted', () {
      final merged = mergeBackendWithLocal(
        [backend(completed: true, claimed: true)],
        byId([row(completed: true, claimed: false)]),
      );
      expect(merged.single.claimedReward, isTrue);
      expect(merged.single.canClaim, isFalse);
    });

    test('completion is absorbing-true from either side', () {
      expect(
        mergeBackendWithLocal(
          [backend(completed: false)],
          byId([row(completed: true)]),
        ).single.isCompleted,
        isTrue,
      );
      expect(
        mergeBackendWithLocal(
          [backend(completed: true)],
          byId([row(completed: false)]),
        ).single.isCompleted,
        isTrue,
      );
    });

    test('merged progress crossing the target marks it complete', () {
      final merged = mergeBackendWithLocal(
        [backend(progress: 2, target: 5, completed: false)],
        byId([row(progress: 5, target: 5, completed: false)]),
      );
      expect(merged.single.isCompleted, isTrue);
    });

    test('a challenge with no local row passes through untouched', () {
      final merged = mergeBackendWithLocal([backend(progress: 3)], const {});
      expect(merged.single.currentProgress, 3);
      expect(merged.single.claimedReward, isFalse);
    });

    test(
      'a local-only challenge with an unclaimed reward is kept, not dropped',
      () {
        // The backend response omits it (partial response, or it hasn't
        // recorded the completion yet). Dropping it would take an earned
        // reward off the screen with no way back.
        final merged = mergeBackendWithLocal(
          [backend(id: 'server-only')],
          byId([row(id: 'local-only', completed: true, claimed: false)]),
        );
        expect(merged.map((c) => c.id), ['server-only', 'local-only']);
        expect(merged.last.canClaim, isTrue);
      },
    );

    test('a local-only row that is already claimed is NOT resurrected', () {
      final merged = mergeBackendWithLocal(
        [backend(id: 'server-only')],
        byId([row(id: 'local-only', completed: true, claimed: true)]),
      );
      expect(merged.map((c) => c.id), ['server-only']);
    });

    test('a local-only row still in progress is left to the server', () {
      final merged = mergeBackendWithLocal(
        [backend(id: 'server-only')],
        byId([row(id: 'local-only', progress: 1, target: 5)]),
      );
      expect(merged.map((c) => c.id), ['server-only']);
    });

    test('the bonus row is never surfaced as a local-only challenge', () {
      final bonusId = allCompleteBonusIdFor(DateTime(2026, 8, 9));
      final merged = mergeBackendWithLocal(
        [backend(id: 'server-only')],
        byId([
          row(id: bonusId, type: 'bonus', completed: true, claimed: false),
        ]),
      );
      expect(merged.map((c) => c.id), ['server-only']);
    });
  });

  group('no duplicate reward', () {
    test('a claimed challenge is never claimable again through any path', () {
      final claimedRow = row(completed: true, claimed: true);

      // via hydration (offline cold start)
      expect(hydrateFromLocalRows([claimedRow]).single.canClaim, isFalse);

      // via a refresh where the server has caught up
      expect(
        mergeBackendWithLocal(
          [backend(completed: true, claimed: true)],
          byId([claimedRow]),
        ).single.canClaim,
        isFalse,
      );

      // via a refresh where the server has NOT caught up
      expect(
        mergeBackendWithLocal(
          [backend(completed: true, claimed: false)],
          byId([claimedRow]),
        ).single.canClaim,
        isFalse,
      );
    });

    test(
      'hydrate → refresh → hydrate keeps a claim settled at every step',
      () {
        // The loop that produced the original report: relaunch, refresh,
        // relaunch. The reward must be offered exactly zero more times.
        var local = row(completed: true, claimed: true);

        final afterFirstLaunch = hydrateFromLocalRows([local]);
        expect(afterFirstLaunch.single.canClaim, isFalse);

        final afterRefresh = mergeBackendWithLocal(
          [backend(completed: true, claimed: false)],
          byId([local]),
        );
        expect(afterRefresh.single.canClaim, isFalse);

        // The refresh result is what gets persisted back.
        local = row(
          completed: afterRefresh.single.isCompleted,
          claimed: afterRefresh.single.claimedReward,
        );
        expect(hydrateFromLocalRows([local]).single.canClaim, isFalse);
      },
    );

    test('the reward amount comes from the row, not an optimistic model', () {
      // A stale in-memory copy claiming a bigger reward can't inflate the
      // payout: hydration reads the coins off the persisted row.
      final hydrated = hydrateFromLocalRows([row(coins: 8, completed: true)]);
      expect(hydrated.single.coinReward, 8);
    });
  });
}
