import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/services/multiplayer/settlement_ledger.dart';

/// A ledger that survives "crashes" — a new applier reads the same map, which
/// is what a real restart sees.
class FakeLedger implements SettlementLedger {
  final Map<String, SettlementProgress> rows = {};
  int writes = 0;

  /// Simulates the process dying at the moment of a durable write: the write
  /// does NOT land, and the caller never returns.
  String? failOnWriteAfterStep;

  @override
  Future<SettlementProgress?> read(String settlementId) async =>
      rows[settlementId];

  @override
  Future<void> write(SettlementProgress progress) async {
    writes++;
    if (failOnWriteAfterStep != null &&
        _stepOf(progress) == failOnWriteAfterStep) {
      throw StateError('crash while recording ${failOnWriteAfterStep!}');
    }
    rows[progress.settlementId] = progress;
  }

  @override
  Future<Set<String>> completedIds(List<String> candidates) async => candidates
      .where((id) => rows[id]?.completed == true)
      .toSet();

  static String _stepOf(SettlementProgress p) {
    if (p.completed) return 'completed';
    if (p.xpApplied) return 'xp';
    if (p.coinsApplied) return 'coins';
    if (p.statsApplied) return 'stats';
    return 'none';
  }
}

/// Counts every grant so a duplicate is visible, and can be told to fail a
/// specific step.
class FakeSink implements SettlementRewardSink {
  int stats = 0;
  int coins = 0;
  int xp = 0;

  String? failStep;

  @override
  Future<void> applyStats(MultiplayerSettlement s) async {
    if (failStep == 'stats') throw StateError('stats write failed');
    stats++;
  }

  @override
  Future<void> applyCoins(MultiplayerSettlement s) async {
    if (failStep == 'coins') throw StateError('coin grant failed');
    coins++;
  }

  @override
  Future<void> applyBattlePassXp(MultiplayerSettlement s) async {
    if (failStep == 'xp') throw StateError('xp flush failed');
    xp++;
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

/// A fresh applier over the SAME ledger — what the next launch gets.
SettlementApplier restart(FakeLedger ledger, FakeSink sink) =>
    SettlementApplier(ledger: ledger, sink: sink);

void main() {
  group('the happy path', () {
    test('applies each reward exactly once and completes', () async {
      final ledger = FakeLedger();
      final sink = FakeSink();

      final done = await restart(ledger, sink).apply(settlement());

      expect(done, isTrue);
      expect((sink.stats, sink.coins, sink.xp), (1, 1, 1));
      expect(ledger.rows['s1']!.completed, isTrue);
    });

    test('a second pass over a completed settlement grants nothing', () async {
      final ledger = FakeLedger();
      final sink = FakeSink();

      await restart(ledger, sink).apply(settlement());
      await restart(ledger, sink).apply(settlement());

      expect((sink.stats, sink.coins, sink.xp), (1, 1, 1));
    });

    test('an interrupted match completes without granting anything', () async {
      final ledger = FakeLedger();
      final sink = FakeSink();

      final done = await restart(ledger, sink)
          .apply(settlement(endReason: 'ServerInterrupted', coins: 0, xp: 0));

      expect(done, isTrue);
      expect((sink.stats, sink.coins, sink.xp), (0, 0, 0));
      expect(ledger.rows['s1']!.completed, isTrue);
    });
  });

  group('a reward write fails', () {
    test('stats failing leaves nothing applied and nothing completed', () async {
      final ledger = FakeLedger();
      final sink = FakeSink()..failStep = 'stats';

      await expectLater(
        restart(ledger, sink).apply(settlement()),
        throwsA(isA<StateError>()),
      );

      expect(sink.stats, 0);
      expect(ledger.rows['s1']?.completed ?? false, isFalse);
    });

    test(
      'coins failing keeps stats recorded so the retry does not redo them',
      () async {
        final ledger = FakeLedger();
        final sink = FakeSink()..failStep = 'coins';

        await expectLater(
          restart(ledger, sink).apply(settlement()),
          throwsA(isA<StateError>()),
        );

        expect(sink.stats, 1);
        expect(ledger.rows['s1']!.statsApplied, isTrue);
        expect(ledger.rows['s1']!.coinsApplied, isFalse);
        expect(ledger.rows['s1']!.completed, isFalse,
            reason: 'an incomplete settlement must never be acknowledged');
      },
    );

    test('the retry resumes at coins and completes without redoing stats',
        () async {
      final ledger = FakeLedger();
      final failing = FakeSink()..failStep = 'coins';

      await expectLater(
        restart(ledger, failing).apply(settlement()),
        throwsA(isA<StateError>()),
      );

      // The retry — same ledger, a sink that now works.
      final working = FakeSink();
      final done = await restart(ledger, working).apply(settlement());

      expect(done, isTrue);
      expect(working.stats, 0, reason: 'stats were already applied');
      expect(working.coins, 1);
      expect(working.xp, 1);
      expect(ledger.rows['s1']!.completed, isTrue);
    });

    test('xp failing still leaves the coins granted and recorded', () async {
      final ledger = FakeLedger();
      final sink = FakeSink()..failStep = 'xp';

      await expectLater(
        restart(ledger, sink).apply(settlement()),
        throwsA(isA<StateError>()),
      );

      expect(sink.coins, 1);
      expect(ledger.rows['s1']!.coinsApplied, isTrue);
      expect(ledger.rows['s1']!.completed, isFalse);

      final working = FakeSink();
      await restart(ledger, working).apply(settlement());

      expect(working.coins, 0, reason: 'coins must not be granted twice');
      expect(working.xp, 1);
    });
  });

  group('a crash at each recording boundary', () {
    // The ledger write itself dying is the hard case: the reward LANDED but
    // the record of it did not.

    test('crash while recording stats replays only stats', () async {
      final ledger = FakeLedger()..failOnWriteAfterStep = 'stats';
      final first = FakeSink();

      await expectLater(
        restart(ledger, first).apply(settlement()),
        throwsA(isA<StateError>()),
      );
      expect(first.stats, 1);
      expect(ledger.rows.containsKey('s1'), isFalse);

      // Next launch. Stats run again — statistics is the one step where a
      // replay is survivable, and losing the coins that follow is not.
      ledger.failOnWriteAfterStep = null;
      final second = FakeSink();
      final done = await restart(ledger, second).apply(settlement());

      expect(done, isTrue);
      expect(second.coins, 1, reason: 'the coins must still be paid');
      expect(second.xp, 1);
      expect(ledger.rows['s1']!.completed, isTrue);
    });

    test('crash while recording coins does not lose the xp step', () async {
      final ledger = FakeLedger()..failOnWriteAfterStep = 'coins';
      final first = FakeSink();

      await expectLater(
        restart(ledger, first).apply(settlement()),
        throwsA(isA<StateError>()),
      );
      expect(first.coins, 1);
      // Stats were recorded before the crash.
      expect(ledger.rows['s1']!.statsApplied, isTrue);
      expect(ledger.rows['s1']!.coinsApplied, isFalse);

      ledger.failOnWriteAfterStep = null;
      final second = FakeSink();
      await restart(ledger, second).apply(settlement());

      expect(second.stats, 0, reason: 'stats were already recorded');
      expect(second.xp, 1);
      expect(ledger.rows['s1']!.completed, isTrue);
    });

    test(
      'crash while recording completion leaves every step done, so the retry '
      'grants nothing more',
      () async {
        final ledger = FakeLedger()..failOnWriteAfterStep = 'completed';
        final first = FakeSink();

        await expectLater(
          restart(ledger, first).apply(settlement()),
          throwsA(isA<StateError>()),
        );
        expect((first.stats, first.coins, first.xp), (1, 1, 1));
        expect(ledger.rows['s1']!.allStepsDone, isTrue);
        expect(ledger.rows['s1']!.completed, isFalse,
            reason: 'not completed means not acknowledged — it comes back');

        ledger.failOnWriteAfterStep = null;
        final second = FakeSink();
        final done = await restart(ledger, second).apply(settlement());

        expect(done, isTrue);
        expect((second.stats, second.coins, second.xp), (0, 0, 0),
            reason: 'every step was already done — the retry only completes it');
        expect(ledger.rows['s1']!.completed, isTrue);
      },
    );

    test('a crash never marks a settlement complete with work outstanding',
        () async {
      for (final step in ['stats', 'coins', 'xp']) {
        final ledger = FakeLedger();
        final sink = FakeSink()..failStep = step;

        await expectLater(
          restart(ledger, sink).apply(settlement()),
          throwsA(isA<StateError>()),
        );

        expect(ledger.rows['s1']?.completed ?? false, isFalse,
            reason: 'failed at $step but reported complete');
      }
    });

    test('any number of crashes still pays exactly once', () async {
      final ledger = FakeLedger();
      final totals = FakeSink();

      // Fail at every boundary in turn, then succeed. Each attempt uses the
      // same counting sink so duplicates across the whole sequence show up.
      for (final step in ['stats', 'coins', 'xp']) {
        totals.failStep = step;
        try {
          await restart(ledger, totals).apply(settlement());
        } catch (_) {
          // expected
        }
      }
      totals.failStep = null;
      final done = await restart(ledger, totals).apply(settlement());

      expect(done, isTrue);
      expect((totals.stats, totals.coins, totals.xp), (1, 1, 1));
    });
  });
}
