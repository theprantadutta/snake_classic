import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';

Map<String, dynamic> row({
  String id = 's1',
  String gameId = 'g1',
  String result = 'Win',
  int coins = 25,
  int xp = 20,
  int score = 120,
  int foods = 12,
  int duration = 95,
  bool survived = true,
  String? deathReason,
  String endReason = 'LastAlive',
  int ratingDelta = 16,
  int ratingAfter = 1016,
  bool versusBot = false,
}) {
  return {
    'id': id,
    'game_id': gameId,
    'result': result,
    'coins_awarded': coins,
    'battle_pass_xp_awarded': xp,
    'score': score,
    'foods_eaten': foods,
    'duration_seconds': duration,
    'survived_to_end': survived,
    'death_reason': deathReason,
    'end_reason': endReason,
    'rating_delta': ratingDelta,
    'rating_after': ratingAfter,
    'versus_bot': versusBot,
  };
}

void main() {
  group('parsing a settlement', () {
    test('reads every field the client needs to apply it', () {
      final s = MultiplayerSettlement.fromJson(row())!;

      expect(s.id, 's1');
      expect(s.gameId, 'g1');
      expect(s.isWin, isTrue);
      expect(s.coinsAwarded, 25);
      expect(s.battlePassXpAwarded, 20);
      expect(s.score, 120);
      expect(s.foodsEaten, 12);
      expect(s.durationSeconds, 95);
      expect(s.survivedToEnd, isTrue);
      expect(s.ratingDelta, 16);
      expect(s.versusBot, isFalse);
    });

    test('a loss is not a win', () {
      final s = MultiplayerSettlement.fromJson(
        row(result: 'Loss', coins: 0, xp: 8, survived: false, deathReason: 'wall'),
      )!;

      expect(s.isWin, isFalse);
      expect(s.coinsAwarded, 0);
      expect(s.battlePassXpAwarded, 8);
      expect(s.deathReason, 'wall');
    });

    test('a server-interrupted match is recognisable and pays nothing', () {
      final s = MultiplayerSettlement.fromJson(
        row(endReason: 'ServerInterrupted', result: 'Draw', coins: 0, xp: 0),
      )!;

      expect(s.wasInterrupted, isTrue);
      expect(s.coinsAwarded, 0);
      expect(s.battlePassXpAwarded, 0);
    });

    test('a row with no id is rejected rather than applied blindly', () {
      expect(MultiplayerSettlement.fromJson({'coins_awarded': 25}), isNull);
      expect(MultiplayerSettlement.fromJson({'id': '', 'coins_awarded': 25}), isNull);
    });

    test('one malformed row does not discard the rest of the batch', () {
      final parsed = MultiplayerSettlement.parseAll([
        row(id: 'a'),
        {'nonsense': true},
        row(id: 'b'),
      ]);

      expect(parsed.map((s) => s.id), ['a', 'b']);
    });

    test('missing numeric fields degrade to zero rather than throwing', () {
      final s = MultiplayerSettlement.fromJson({'id': 'x'})!;
      expect(s.coinsAwarded, 0);
      expect(s.score, 0);
      expect(s.durationSeconds, 0);
    });
  });

  group('exactly-once planning', () {
    test('a settlement never seen before is applied and acknowledged', () {
      final fetched = MultiplayerSettlement.parseAll([row(id: 'a')]);

      final plan = planSettlements(fetched: fetched, alreadyApplied: const {});

      expect(plan.toApply.map((s) => s.id), ['a']);
      expect(plan.toAcknowledge, ['a']);
    });

    test(
      'a settlement already applied locally is acknowledged but NOT re-applied',
      () {
        // The crash-between-steps case: applied last run, the ack never
        // landed, so the server hands it back. Paying it again here is the
        // exact failure the local ledger exists to prevent.
        final fetched = MultiplayerSettlement.parseAll([row(id: 'a')]);

        final plan = planSettlements(
          fetched: fetched,
          alreadyApplied: const {'a'},
        );

        expect(plan.toApply, isEmpty);
        expect(
          plan.toAcknowledge,
          ['a'],
          reason: 're-acknowledging is how it stops coming back',
        );
      },
    );

    test('a duplicated row within one batch is applied once', () {
      final fetched = MultiplayerSettlement.parseAll([
        row(id: 'a'),
        row(id: 'a'),
      ]);

      final plan = planSettlements(fetched: fetched, alreadyApplied: const {});

      expect(plan.toApply, hasLength(1));
      expect(plan.toAcknowledge, ['a']);
    });

    test('a mixed batch applies only the new rows', () {
      final fetched = MultiplayerSettlement.parseAll([
        row(id: 'old'),
        row(id: 'new'),
      ]);

      final plan = planSettlements(
        fetched: fetched,
        alreadyApplied: const {'old'},
      );

      expect(plan.toApply.map((s) => s.id), ['new']);
      expect(plan.toAcknowledge, ['old', 'new']);
    });

    test('an empty fetch plans nothing', () {
      final plan = planSettlements(fetched: const [], alreadyApplied: const {});
      expect(plan.isEmpty, isTrue);
    });

    test(
      'repeated syncs of the same settlement pay it exactly once',
      () {
        // Three launches in a row where the ack keeps failing.
        final fetched = MultiplayerSettlement.parseAll([row(id: 'a')]);
        final ledger = <String>{};
        var applications = 0;

        for (var launch = 0; launch < 3; launch++) {
          final plan = planSettlements(
            fetched: fetched,
            alreadyApplied: ledger,
          );
          for (final s in plan.toApply) {
            applications++;
            ledger.add(s.id);
          }
        }

        expect(applications, 1);
      },
    );
  });
}
