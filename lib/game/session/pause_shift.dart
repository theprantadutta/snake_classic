import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/premium_power_up.dart';

/// Pure wall-clock accounting for pause/resume.
///
/// Everything time-driven in a run (active power-ups, the on-board power-up,
/// bonus/special food expiry, the game-duration anchor) is computed against
/// `DateTime.now()`. Pausing must therefore do two things, and they must
/// cancel out exactly:
///
///  1. [stampPausedAt] — freeze: stamp `pausedAt` on every wall-clock-driven
///     object so its getters use the stamp as "now" and the displayed times
///     stop moving while the game is frozen.
///  2. [shiftAfterPause] — unfreeze: shift every anchor forward by the pause
///     duration AND clear `pausedAt`, so the elapsed real-world time is
///     cancelled and the getters resume against the live clock with the same
///     remaining time they showed when the pause began.
///
/// Both functions are pure GameState → GameState (no clock reads, no
/// services) so the tricky math is unit-testable — see
/// test/game/session/pause_shift_test.dart. GameCubit owns WHEN to call them
/// and the accompanying status changes / timer cancels.

/// Freeze: returns [state] with `pausedAt` stamped on active power-ups, the
/// on-board power-up, and the state itself. Preserves
/// [PremiumActivePowerUp] identity — the old inline version rebuilt every
/// active as a plain [ActivePowerUp], silently downgrading premium
/// power-ups on pause (an active ghost mode stopped being ghost mode).
model.GameState stampPausedAt(model.GameState state, DateTime pauseStamp) {
  final pausedActive = state.activePowerUps
      .map((p) => _withClock(p, activatedAt: p.activatedAt, pausedAt: pauseStamp))
      .toList();
  final pausedOnBoard = state.powerUp != null
      ? PowerUp(
          position: state.powerUp!.position,
          type: state.powerUp!.type,
          createdAt: state.powerUp!.createdAt,
          pausedAt: pauseStamp,
        )
      : null;

  return state.copyWith(
    activePowerUps: pausedActive,
    powerUp: pausedOnBoard,
    pausedAt: pauseStamp,
  );
}

/// Unfreeze: returns [state] with every wall-clock anchor shifted forward by
/// [pauseDuration] and `pausedAt` cleared.
///
/// Food gets the same shift: `Food.isExpired` compares `DateTime.now()` to
/// `createdAt` with no pause concept of its own, so without this a 10–15s
/// pause was enough to expire any bonus/special sitting on the board. Normal
/// food never expires; the shift is harmless either way.
model.GameState shiftAfterPause(
  model.GameState state,
  Duration pauseDuration,
) {
  final shiftedActive = state.activePowerUps
      .map((p) => _withClock(p, activatedAt: p.activatedAt.add(pauseDuration)))
      .toList();
  final shiftedPowerUp = state.powerUp != null
      ? PowerUp(
          position: state.powerUp!.position,
          type: state.powerUp!.type,
          createdAt: state.powerUp!.createdAt.add(pauseDuration),
        )
      : null;

  Food shiftFood(Food f) => Food(
        position: f.position,
        type: f.type,
        createdAt: f.createdAt.add(pauseDuration),
      );
  final shiftedFood = state.food != null ? shiftFood(state.food!) : null;
  final shiftedFoods = state.foods.map(shiftFood).toList();
  final shiftedGameStart = state.gameStartTime?.add(pauseDuration);

  return state.copyWith(
    activePowerUps: shiftedActive,
    powerUp: shiftedPowerUp,
    food: shiftedFood,
    foods: shiftedFoods,
    gameStartTime: shiftedGameStart,
    clearPausedAt: true,
  );
}

/// Rebuild an active power-up with a new clock, preserving its concrete type
/// (premium actives keep their premiumType + additionalData).
ActivePowerUp _withClock(
  ActivePowerUp p, {
  required DateTime activatedAt,
  DateTime? pausedAt,
}) {
  if (p is PremiumActivePowerUp) {
    return PremiumActivePowerUp(
      premiumType: p.premiumType,
      activatedAt: activatedAt,
      duration: p.duration,
      pausedAt: pausedAt,
      additionalData: p.additionalData,
    );
  }
  return ActivePowerUp(
    type: p.type,
    activatedAt: activatedAt,
    duration: p.duration,
    pausedAt: pausedAt,
  );
}
