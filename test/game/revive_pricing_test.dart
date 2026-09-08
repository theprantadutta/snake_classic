import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/presentation/bloc/game/game_cubit.dart';

/// How many times a run can be saved, and what that costs.
///
/// A revive is the one place in the game where a player spends real value —
/// coins, or the attention a rewarded ad is paid for — to undo a mistake.
/// How many are allowed is a design decision, not a tuning knob, because it
/// is what separates a high score that records a run from one that records
/// how long someone was willing to keep paying.
void main() {
  group('how many revives a run allows', () {
    test('exactly one, for every player', () {
      // Deliberately an equality, not a bound. This briefly sat at 2, which
      // read as "let the ad-watching player watch another" — but the cap is
      // not per-player, so it also gave Pro users a second FREE continue.
      // Pro revives cost neither an ad nor coins, so raising this hands out
      // free lives, which is why the count is pinned rather than bounded.
      expect(
        GameCubit.maxRevivesPerGame,
        1,
        reason: 'raising this gives Pro players extra free lives, not just '
            'free players extra ad-watched ones',
      );
    });
  });

  group('revive pricing', () {
    test('the offered revive costs the base price', () {
      // The only reachable index while the cap is 1.
      expect(GameCubit.reviveCoinCostFor(0), GameCubit.reviveCoinCost);
    });

    test('the price would still escalate if the cap were raised', () {
      // Not reachable today. Kept because a flat price is the wrong shape
      // for a second revive — it would make one a formality rather than a
      // decision — and this is what stops that regressing unnoticed if the
      // cap ever moves.
      expect(GameCubit.reviveCoinCostFor(1), GameCubit.reviveCoinCost * 2);
      expect(
        GameCubit.reviveCoinCostFor(2),
        greaterThan(GameCubit.reviveCoinCostFor(1)),
      );
    });
  });
}
