import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/services/multiplayer/settlement_ledger.dart';

/// Everything that survives a crash: the rewards actually credited, and the
/// record of which steps happened.
///
/// The earlier version of this test used a fresh counting sink per attempt and
/// asserted only what the SECOND attempt did. That hid the bug it was supposed
/// to catch: a reward could land, the process die before the record committed,
/// and the retry pay it again — two credits in total, one per attempt, and
/// both assertions green. Totals here are cumulative across every attempt, so
/// a double payment is a failure.
class SettlementWorld {
  // Durable, post-commit reward totals.
  int stats = 0;
  int coins = 0;
  int xp = 0;

  final Map<String, SettlementProgress> progress = {};

  /// Step at which the process "dies" mid-transaction. The transaction rolls
  /// back — the reward and its record both vanish — and the call throws.
  SettlementStep? crashDuring;

  /// Step whose reward write fails outright (an economy error rather than a
  /// crash). Same rollback, same throw.
  SettlementStep? failStep;

  int transactionsCommitted = 0;
  int transactionsRolledBack = 0;
}

/// A ledger that behaves like a real transaction: the effect and the step
/// record commit together, or neither does.
class FakeLedger implements SettlementLedger {
  FakeLedger(this.world);

  final SettlementWorld world;

  @override
  Future<SettlementProgress?> read(String settlementId) async =>
      world.progress[settlementId];

  @override
  Future<bool> runStepOnce(
    String settlementId,
    SettlementStep step,
    Future<void> Function() effect,
  ) async {
    final existing = world.progress[settlementId] ??
        SettlementProgress(settlementId: settlementId);
    if (existing.hasStep(step)) return false;

    // Snapshot everything the transaction could touch.
    final before = (
      stats: world.stats,
      coins: world.coins,
      xp: world.xp,
      progress: world.progress[settlementId],
    );

    void rollback() {
      world.stats = before.stats;
      world.coins = before.coins;
      world.xp = before.xp;
      if (before.progress == null) {
        world.progress.remove(settlementId);
      } else {
        world.progress[settlementId] = before.progress!;
      }
      world.transactionsRolledBack++;
    }

    try {
      await effect();

      // The process dies here — AFTER the reward write, BEFORE the commit.
      // This is the exact window the design has to close: a real transaction
      // discards both, so the retry re-runs the effect and the total stays 1.
      if (world.crashDuring == step) {
        rollback();
        throw StateError('crashed mid-transaction on $step');
      }

      world.progress[settlementId] = existing.withStep(step);
      world.transactionsCommitted++;
      return true;
    } catch (e) {
      if (world.crashDuring != step) rollback();
      rethrow;
    }
  }

  @override
  Future<void> markCompleted(String settlementId) async {
    final existing = world.progress[settlementId] ??
        SettlementProgress(settlementId: settlementId);
    world.progress[settlementId] = existing.copyWith(completed: true);
  }

  @override
  Future<Set<String>> completedIds(List<String> candidates) async => candidates
      .where((id) => world.progress[id]?.completed == true)
      .toSet();
}

/// Credits the world's durable totals. A rollback in the ledger undoes these,
/// exactly as a database rollback would.
class FakeSink implements SettlementRewardSink {
  FakeSink(this.world);

  final SettlementWorld world;

  /// Every call, committed or rolled back. Distinguishes "the effect ran
  /// twice but only counted once" (correct) from "it never re-ran" (a lost
  /// reward).
  int statsAttempts = 0;
  int coinsAttempts = 0;
  int xpAttempts = 0;

  @override
  Future<void> applyStats(MultiplayerSettlement s) async {
    statsAttempts++;
    if (world.failStep == SettlementStep.stats) {
      throw StateError('stats write failed');
    }
    world.stats++;
  }

  @override
  Future<void> applyCoins(MultiplayerSettlement s) async {
    coinsAttempts++;
    if (world.failStep == SettlementStep.coins) {
      throw StateError('coin grant failed');
    }
    world.coins++;
  }

  @override
  Future<void> applyBattlePassXp(MultiplayerSettlement s) async {
    xpAttempts++;
    if (world.failStep == SettlementStep.xp) {
      throw StateError('xp flush failed');
    }
    world.xp++;
  }
}

MultiplayerSettlement settlement({
  String id = 's1',
  String endReason = 'LastAlive',
  int coins = 25,
  int xp = 20,
}) {
  return MultiplayerSettlement(
    id: id,
    gameId: 'g1',
    result: 'Win',
    coinsAwarded: coins,
    battlePassXpAwarded: xp,
    score: 120,
    foodsEaten: 12,
    durationSeconds: 95,
    survivedToEnd: true,
    deathReason: null,
    endReason: endReason,
    ratingDelta: 16,
    ratingAfter: 1016,
    versusBot: false,
  );
}

/// A fresh applier over the SAME world — what the next launch gets.
SettlementApplier restart(SettlementWorld world) => SettlementApplier(
      ledger: FakeLedger(world),
      sink: FakeSink(world),
    );

/// The one assertion that matters, everywhere.
void expectPaidExactlyOnce(SettlementWorld world) {
  expect(
    (world.stats, world.coins, world.xp),
    (1, 1, 1),
    reason: 'durable reward totals across every attempt must be exactly one',
  );
}

void main() {
  group('the happy path', () {
    test('applies each reward exactly once and completes', () async {
      final world = SettlementWorld();

      final done = await restart(world).apply(settlement());

      expect(done, isTrue);
      expectPaidExactlyOnce(world);
      expect(world.progress['s1']!.completed, isTrue);
    });

    test('a second pass over a completed settlement grants nothing', () async {
      final world = SettlementWorld();

      await restart(world).apply(settlement());
      await restart(world).apply(settlement());

      expectPaidExactlyOnce(world);
    });

    test('an interrupted match completes without granting anything', () async {
      final world = SettlementWorld();

      final done = await restart(world)
          .apply(settlement(endReason: 'ServerInterrupted', coins: 0, xp: 0));

      expect(done, isTrue);
      expect((world.stats, world.coins, world.xp), (0, 0, 0));
      expect(world.progress['s1']!.completed, isTrue);
    });
  });

  group('a crash AFTER the reward write and BEFORE the record commits', () {
    // The window that made the previous design wrong. A real transaction
    // discards both halves, so the retry re-runs the effect and pays once.

    for (final step in SettlementStep.values) {
      test('crashing during $step still pays exactly once overall', () async {
        final world = SettlementWorld()..crashDuring = step;

        await expectLater(
          restart(world).apply(settlement()),
          throwsA(isA<StateError>()),
        );

        // The rolled-back step left no record and no credit.
        expect(world.progress['s1']?.hasStep(step) ?? false, isFalse);
        expect(world.transactionsRolledBack, 1);

        // Next launch.
        world.crashDuring = null;
        final second = restart(world);
        final sink = FakeSink(world);
        final done = await SettlementApplier(
          ledger: FakeLedger(world),
          sink: sink,
        ).apply(settlement());
        expect(done, isTrue);
        expect(second, isNotNull);

        expectPaidExactlyOnce(world);
        expect(world.progress['s1']!.completed, isTrue);
      });
    }

    test('the effect IS retried after a rollback — nothing is silently lost',
        () async {
      final world = SettlementWorld()..crashDuring = SettlementStep.coins;
      final firstSink = FakeSink(world);

      await expectLater(
        SettlementApplier(ledger: FakeLedger(world), sink: firstSink)
            .apply(settlement()),
        throwsA(isA<StateError>()),
      );
      expect(firstSink.coinsAttempts, 1);
      expect(world.coins, 0, reason: 'the rollback undid the credit');

      world.crashDuring = null;
      final secondSink = FakeSink(world);
      await SettlementApplier(ledger: FakeLedger(world), sink: secondSink)
          .apply(settlement());

      expect(secondSink.coinsAttempts, 1, reason: 'it ran again');
      expect(secondSink.statsAttempts, 0, reason: 'stats had already committed');
      expectPaidExactlyOnce(world);
    });

    test('crashing at every step in turn still pays exactly once', () async {
      final world = SettlementWorld();

      for (final step in SettlementStep.values) {
        world.crashDuring = step;
        try {
          await restart(world).apply(settlement());
        } catch (_) {
          // expected
        }
      }

      world.crashDuring = null;
      final done = await restart(world).apply(settlement());

      expect(done, isTrue);
      expectPaidExactlyOnce(world);
    });
  });

  group('a reward write fails outright', () {
    test('stats failing leaves nothing credited and nothing completed',
        () async {
      final world = SettlementWorld()..failStep = SettlementStep.stats;

      await expectLater(
        restart(world).apply(settlement()),
        throwsA(isA<StateError>()),
      );

      expect((world.stats, world.coins, world.xp), (0, 0, 0));
      expect(world.progress['s1']?.completed ?? false, isFalse);
    });

    test('coins failing keeps stats committed and blocks completion', () async {
      final world = SettlementWorld()..failStep = SettlementStep.coins;

      await expectLater(
        restart(world).apply(settlement()),
        throwsA(isA<StateError>()),
      );

      expect(world.stats, 1);
      expect(world.coins, 0);
      expect(world.progress['s1']!.statsApplied, isTrue);
      expect(world.progress['s1']!.coinsApplied, isFalse);
      expect(world.progress['s1']!.completed, isFalse,
          reason: 'an incomplete settlement must never be acknowledged');
    });

    test('the retry resumes and the totals still come to one each', () async {
      final world = SettlementWorld()..failStep = SettlementStep.coins;

      await expectLater(
        restart(world).apply(settlement()),
        throwsA(isA<StateError>()),
      );

      world.failStep = null;
      final sink = FakeSink(world);
      final done = await SettlementApplier(
        ledger: FakeLedger(world),
        sink: sink,
      ).apply(settlement());

      expect(done, isTrue);
      expect(sink.statsAttempts, 0, reason: 'stats were already committed');
      expectPaidExactlyOnce(world);
      expect(world.progress['s1']!.completed, isTrue);
    });

    test('xp failing still leaves the coins credited exactly once', () async {
      final world = SettlementWorld()..failStep = SettlementStep.xp;

      await expectLater(
        restart(world).apply(settlement()),
        throwsA(isA<StateError>()),
      );
      expect(world.coins, 1);

      world.failStep = null;
      await restart(world).apply(settlement());

      expectPaidExactlyOnce(world);
    });

    test('a failure never marks a settlement complete', () async {
      for (final step in SettlementStep.values) {
        final world = SettlementWorld()..failStep = step;

        await expectLater(
          restart(world).apply(settlement()),
          throwsA(isA<StateError>()),
        );

        expect(world.progress['s1']?.completed ?? false, isFalse,
            reason: 'failed at $step but reported complete');
      }
    });
  });

  group('crashing after every step but before completion', () {
    test('the retry completes it and grants nothing further', () async {
      final world = SettlementWorld();
      final first = FakeSink(world);

      // All three steps commit; the process dies before markCompleted.
      final ledger = FakeLedger(world);
      await ledger.runStepOnce(
          's1', SettlementStep.stats, () => first.applyStats(settlement()));
      await ledger.runStepOnce(
          's1', SettlementStep.coins, () => first.applyCoins(settlement()));
      await ledger.runStepOnce('s1', SettlementStep.xp,
          () => first.applyBattlePassXp(settlement()));

      expect(world.progress['s1']!.allStepsDone, isTrue);
      expect(world.progress['s1']!.completed, isFalse,
          reason: 'not completed means not acknowledged — it comes back');

      final second = FakeSink(world);
      final done = await SettlementApplier(
        ledger: FakeLedger(world),
        sink: second,
      ).apply(settlement());

      expect(done, isTrue);
      expect((second.statsAttempts, second.coinsAttempts, second.xpAttempts),
          (0, 0, 0),
          reason: 'every step was recorded — the retry only completes it');
      expectPaidExactlyOnce(world);
    });
  });

  group('the ledger is the only authority on whether a step runs', () {
    test('a recorded step is never handed to the sink again', () async {
      final world = SettlementWorld();
      await restart(world).apply(settlement());

      final sink = FakeSink(world);
      await SettlementApplier(ledger: FakeLedger(world), sink: sink)
          .apply(settlement());

      expect((sink.statsAttempts, sink.coinsAttempts, sink.xpAttempts),
          (0, 0, 0));
    });

    test('every commit paired a reward with its record', () async {
      final world = SettlementWorld();
      await restart(world).apply(settlement());

      expect(world.transactionsCommitted, 3);
      expect(world.transactionsRolledBack, 0);
    });
  });
}
