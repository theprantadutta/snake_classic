import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/game/engine/tick_result.dart';
import 'package:snake_classic/models/game_state.dart' as model;
import 'package:snake_classic/presentation/bloc/game/game_state.dart';
import 'package:snake_classic/utils/direction.dart';

void main() {
  const events = <TickEvent>[LeveledUpEvent(fromLevel: 1, toLevel: 2)];

  group('GameCubitState.copyWith tick events', () {
    final tick = GameCubitState(
      gameState: model.GameState.initial(),
      tickEvents: events,
    );

    test('an emit that keeps the game state keeps its events', () {
      // An accepted input landing in the same frame as the tick: the board
      // only builds this later state, so dropping the events here lost the
      // bite (no gulp, no swallow, the food just vanished).
      final input = tick.copyWith(
        lastAcceptedInputAt: DateTime(2026),
        lastAcceptedDirection: Direction.up,
      );
      expect(identical(input.gameState, tick.gameState), isTrue);
      expect(input.tickEvents, events);
    });

    test('an emit that replaces the game state without events drops them',
        () {
      final next = tick.copyWith(gameState: model.GameState.initial());
      expect(next.tickEvents, isEmpty);
    });

    test('explicit events always win', () {
      final next = tick.copyWith(tickEvents: const []);
      expect(next.tickEvents, isEmpty);
    });
  });
}
