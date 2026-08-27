import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';

/// What a run costs to keep alive.
///
/// A revive is the one place in the game where a player spends real value —
/// coins, or the attention a rewarded ad is paid for — to undo a mistake. The
/// price has to rise, or the high score stops being a record of a run and
/// starts being a record of how long someone was willing to keep paying.
void main() {
  group('revive pricing', () {
    test('the first revive costs the base price', () {
      expect(GameCubit.reviveCoinCostFor(0), GameCubit.reviveCoinCost);
    });

    test('the second costs double', () {
      // The escalation is the whole point. A flat price makes the second
      // revive a formality; this makes it a decision.
      expect(
        GameCubit.reviveCoinCostFor(1),
        GameCubit.reviveCoinCost * 2,
        reason: 'each revive should cost strictly more than the last',
      );
    });

    test('the price never decreases', () {
      var previous = 0;
      for (var used = 0; used < GameCubit.maxRevivesPerGame; used++) {
        final cost = GameCubit.reviveCoinCostFor(used);
        expect(
          cost,
          greaterThan(previous),
          reason: 'revive $used must cost more than revive ${used - 1}',
        );
        previous = cost;
      }
    });
  });

  group('how many revives a run allows', () {
    test('more than one, so the ad offer can repeat', () {
      // The player who just watched an ad to save a run is the most willing
      // person in the app to watch another. One revive per run refused them.
      expect(GameCubit.maxRevivesPerGame, greaterThan(1));
    });

    test('but bounded, so a run still has to end', () {
      // A run that can be revived indefinitely is not a run. If this ever
      // grows past a small number, the leaderboard stops meaning anything.
      expect(
        GameCubit.maxRevivesPerGame,
        lessThanOrEqualTo(3),
        reason: 'unbounded revives make the high score meaningless',
      );
    });
  });
}
