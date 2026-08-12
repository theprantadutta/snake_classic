import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/input_result.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_input_feedback.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_state.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/direction.dart';

/// One input, one cue.
///
/// The original defect was a counting defect. An accepted turn produced two
/// haptics — the cubit's lightImpact and the screen's selectionClick — while a
/// refused or impossible one produced the screen's click and the success
/// animation regardless, so the game told the player it had done something it
/// had not. Then the first fix over-corrected: refusals went completely
/// silent, which is indistinguishable from input the game never received.
///
/// These tests count what actually reaches the platform.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> vibrations;

  setUp(() {
    vibrations = [];
    HapticService().setEnabled(true);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            vibrations.add(call.arguments?.toString() ?? 'vibrate');
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// Play a cue and wait past the refusal's second click.
  Future<void> play(InputResult result) async {
    MultiplayerInputFeedback(HapticService()).play(result);
    await Future<void>.delayed(
      MultiplayerInputFeedback.rejectionGap + const Duration(milliseconds: 60),
    );
  }

  const accepted = 'HapticFeedbackType.lightImpact';
  const rejected = 'HapticFeedbackType.selectionClick';

  group('the cue for each result', () {
    test('accepted is exactly one effect', () async {
      await play(InputResult.accepted);

      expect(vibrations, [accepted]);
    });

    test('accepted never buzzes twice', () async {
      // The regression that started this: the cubit and the screen each
      // fired one. Nothing outside this class may add another.
      await play(InputResult.accepted);

      expect(vibrations.length, 1);
    });

    test('rejected is a double click, and never the accepted effect', () async {
      await play(InputResult.rejected);

      expect(vibrations, [rejected, rejected]);
      expect(vibrations, isNot(contains(accepted)));
    });

    test('ignored is silence', () async {
      await play(InputResult.ignored);

      expect(vibrations, isEmpty);
    });

    test('the two cues are distinguishable without looking', () async {
      await play(InputResult.accepted);
      final acceptedCue = [...vibrations];
      vibrations.clear();

      await play(InputResult.rejected);

      expect(vibrations, isNot(acceptedCue));
    });
  });

  group('the cue map', () {
    test('each result maps to exactly one cue', () {
      expect(
        MultiplayerInputFeedback.cueFor(InputResult.accepted),
        InputCue.accepted,
      );
      expect(
        MultiplayerInputFeedback.cueFor(InputResult.rejected),
        InputCue.rejected,
      );
      expect(
        MultiplayerInputFeedback.cueFor(InputResult.ignored),
        InputCue.none,
      );
    });

    test('no result maps to the accepted cue but accepted', () {
      for (final result in InputResult.values) {
        expect(
          MultiplayerInputFeedback.cueFor(result) == InputCue.accepted,
          result == InputResult.accepted,
          reason: result.name,
        );
      }
    });

    test('every cue is reachable', () {
      // A cue nobody can be given is a cue nobody will ever feel.
      expect(InputResult.values.map(MultiplayerInputFeedback.cueFor).toSet(), {
        InputCue.accepted,
        InputCue.rejected,
        InputCue.none,
      });
    });
  });

  group('the visual cue is exclusive too', () {
    // The screen shows the accent-coloured directional echo while
    // intentDirection is set, and the red block while lastRejectedInputAt is.
    // The two must never be up at once, or a refused turn would be wearing
    // half of the accepted cue.
    const playing = MultiplayerState(status: MultiplayerStatus.playing);

    test('accepting clears any standing refusal flash', () {
      final refused = playing.copyWith(
        lastRejectedInputAt: DateTime(2026, 8, 12),
        lastRejectedDirection: Direction.left,
      );

      final accepted = refused.copyWith(
        intentDirection: Direction.up,
        clearRejectedInput: true,
      );

      expect(accepted.lastRejectedInputAt, isNull);
      expect(accepted.lastRejectedDirection, isNull);
      expect(accepted.intentDirection, Direction.up);
    });

    test('a refusal does not touch the accepted echo', () {
      // It cannot: the refused input was never sent, so what the server was
      // last told stands.
      final steering = playing.copyWith(intentDirection: Direction.up);

      final refused = steering.copyWith(
        lastRejectedInputAt: DateTime(2026, 8, 12),
        lastRejectedDirection: Direction.down,
      );

      expect(refused.intentDirection, Direction.up);
      expect(refused.lastRejectedDirection, Direction.down);
    });

    test('the flash is clearable on its own', () {
      final refused = playing.copyWith(
        lastRejectedInputAt: DateTime(2026, 8, 12),
        lastRejectedDirection: Direction.left,
      );

      expect(
        refused.copyWith(clearRejectedInput: true).lastRejectedInputAt,
        isNull,
      );
    });
  });

  test('haptics off silences every result', () async {
    // The motion/haptics setting still wins. This is the one legitimate way
    // to get silence out of an accepted turn.
    HapticService().setEnabled(false);
    addTearDown(() => HapticService().setEnabled(true));

    for (final result in InputResult.values) {
      await play(result);
    }

    expect(vibrations, isEmpty);
  });
}
