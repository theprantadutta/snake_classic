import 'package:snake_classic/models/food.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/power_up.dart';
import 'package:snake_classic/models/snake.dart';

/// Domain events produced by [SnakeSimulation.step] for a single logical tick.
///
/// The simulation is intentionally side-effect free: it computes the next
/// [model.GameState] and reports *what happened* as a list of these events.
/// The [GameCubit] (or any other host — e.g. the Flame game) translates each
/// event into audio / haptic / analytics / coin / XP / replay side effects.
sealed class TickEvent {
  const TickEvent();
}

/// The snake's head landed on a food cell this tick. Carries everything a host
/// needs to score it and surface feedback without re-deriving anything.
class FoodEatenEvent extends TickEvent {
  /// The food that was consumed (its position is the pre-regeneration cell).
  final Food food;

  /// Raw point value of the food type (before combo / multiplier).
  final int basePoints;

  /// Points actually added to the score after combo bonus and the active
  /// score-multiplier power-up.
  final int awardedPoints;

  /// Combo streak *after* this bite.
  final int newCombo;

  /// Combo multiplier after this bite (1.0 / 1.5 / 2.0 / 3.0).
  final double newMultiplier;

  /// True when this bite pushed the combo into a higher multiplier tier.
  final bool comboTierIncreased;

  const FoodEatenEvent({
    required this.food,
    required this.basePoints,
    required this.awardedPoints,
    required this.newCombo,
    required this.newMultiplier,
    required this.comboTierIncreased,
  });
}

/// The combo streak decayed to zero this tick — the snake went
/// [GameConstants.comboDecayMs] of game-time without eating. Hosts can
/// surface a subtle "streak lost" cue; the multiplier is already back
/// to 1.0 in the tick's nextState.
class ComboBrokenEvent extends TickEvent {
  /// The streak size that was lost.
  final int previousCombo;

  const ComboBrokenEvent({required this.previousCombo});
}

/// The score crossed one or more level thresholds this tick. A single
/// high-combo bite can span multiple levels, hence the range.
class LeveledUpEvent extends TickEvent {
  final int fromLevel;
  final int toLevel;

  const LeveledUpEvent({required this.fromLevel, required this.toLevel});
}

/// The snake collected the on-board power-up this tick.
class PowerUpCollectedEvent extends TickEvent {
  final PowerUp powerUp;

  const PowerUpCollectedEvent(this.powerUp);
}

/// The snake crashed this tick. When present, [TickResult.crashed] is true and
/// [TickResult.nextState] is null — the host owns the crash flow (revive offer,
/// survival respawn, game over). [fatalSnake] is the snake with its head on the
/// cell it died on (used for the death-lunge animation).
class CrashEvent extends TickEvent {
  final model.CrashReason reason;
  final Position position;
  final Position? collisionBodyPart;
  final Snake fatalSnake;

  const CrashEvent({
    required this.reason,
    required this.position,
    required this.fatalSnake,
    this.collisionBodyPart,
  });
}

/// Outcome of advancing the simulation by one logical tick.
class TickResult {
  /// The new game state. Null only when [crashed] is true.
  final model.GameState? nextState;

  /// Ordered list of things that happened this tick.
  final List<TickEvent> events;

  /// True when a fatal collision occurred — see [CrashEvent] in [events].
  final bool crashed;

  const TickResult({
    required this.nextState,
    required this.events,
    this.crashed = false,
  });

  /// Convenience: the single [CrashEvent] when [crashed], else null.
  CrashEvent? get crashEvent {
    for (final e in events) {
      if (e is CrashEvent) return e;
    }
    return null;
  }
}
