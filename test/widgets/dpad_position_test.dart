import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/dpad_row_layout.dart';
import 'package:snake_classic/widgets/game_bottom_bar.dart';
import 'package:snake_classic/widgets/steerable_dpad.dart';

import 'control_test_harness.dart';

/// The setting that did nothing.
///
/// `d_pad_position_index` was stored in Drift, synced, and offered in
/// Settings as Left / Centre / Right, and then both gameplay screens built
/// the same centred row regardless. These tests hold the placement rule —
/// shared by single-player and multiplayer through [DPadRowLayout] — and the
/// promise that existing saved values are honoured as they stand.
void main() {
  const dPad = SizedBox(key: Key('dpad'), width: 100, height: 100);
  Widget leading(Alignment a) =>
      Align(alignment: a, child: const SizedBox(key: Key('leading'), width: 40));
  Widget trailing(Alignment a) => Align(
    alignment: a,
    child: const SizedBox(key: Key('trailing'), width: 40),
  );

  Future<List<double>> centresFor(
    WidgetTester tester,
    DPadPosition position,
  ) async {
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: 360,
          child: DPadRowLayout.build(
            position: position,
            dPad: dPad,
            leading: leading,
            trailing: trailing,
          ),
        ),
      ),
    );
    return [
      tester.getCenter(find.byKey(const Key('dpad'))).dx,
      tester.getCenter(find.byKey(const Key('leading'))).dx,
      tester.getCenter(find.byKey(const Key('trailing'))).dx,
    ];
  }

  group('the saved position places the d-pad', () {
    testWidgets('left puts it before both readouts', (tester) async {
      final [dpadX, leadingX, trailingX] = await centresFor(
        tester,
        DPadPosition.bottomLeft,
      );

      expect(dpadX, lessThan(leadingX));
      expect(dpadX, lessThan(trailingX));
    });

    testWidgets('right puts it after both readouts', (tester) async {
      final [dpadX, leadingX, trailingX] = await centresFor(
        tester,
        DPadPosition.bottomRight,
      );

      expect(dpadX, greaterThan(leadingX));
      expect(dpadX, greaterThan(trailingX));
    });

    testWidgets('centre keeps one readout on each side', (tester) async {
      final [dpadX, leadingX, trailingX] = await centresFor(
        tester,
        DPadPosition.bottomCenter,
      );

      expect(leadingX, lessThan(dpadX));
      expect(trailingX, greaterThan(dpadX));
    });

    testWidgets('the control keeps its size wherever it goes', (tester) async {
      final sizes = <Size>[];
      for (final position in DPadPosition.values) {
        await tester.pumpWidget(
          harness(
            SizedBox(
              width: 360,
              child: DPadRowLayout.build(
                position: position,
                dPad: dPad,
                leading: leading,
                trailing: trailing,
              ),
            ),
          ),
        );
        sizes.add(tester.getSize(find.byKey(const Key('dpad'))));
      }

      // Placement is a reorder, not a resize: the board above must not have
      // to reflow because the player moved the control.
      expect(sizes.toSet(), hasLength(1));
    });
  });

  group('single-player honours it end to end', () {
    Future<double> dPadCentreIn(
      WidgetTester tester,
      DPadPosition position,
    ) async {
      await useScreen(tester, const Size(360, 640));
      await tester.pumpWidget(
        harness(
          GameBottomBar(
            gameState: playingState(),
            theme: GameTheme.classic,
            isSmallScreen: false,
            dPadEnabled: true,
            dPadPosition: position,
            onDirection: (_) {},
          ),
        ),
      );
      return tester.getCenter(find.byType(SteerableDPad)).dx;
    }

    testWidgets('all three stored values reach the bar', (tester) async {
      final left = await dPadCentreIn(tester, DPadPosition.bottomLeft);
      final centre = await dPadCentreIn(tester, DPadPosition.bottomCenter);
      final right = await dPadCentreIn(tester, DPadPosition.bottomRight);

      expect(left, lessThan(centre));
      expect(centre, lessThan(right));
    });

    testWidgets('a bar built without a position stays centred', (
      tester,
    ) async {
      // The default is load-bearing: it is what every existing install that
      // never touched the setting is running with, and the stored index for
      // "centre" must keep meaning centre after this change.
      await useScreen(tester, const Size(360, 640));
      await tester.pumpWidget(
        harness(
          GameBottomBar(
            gameState: playingState(),
            theme: GameTheme.classic,
            isSmallScreen: false,
            dPadEnabled: true,
            onDirection: (_) {},
          ),
        ),
      );
      final defaulted = tester.getCenter(find.byType(SteerableDPad)).dx;

      final explicit = await dPadCentreIn(tester, DPadPosition.bottomCenter);
      expect(defaulted, explicit);
    });

    testWidgets('the stored index mapping is not renumbered', (tester) async {
      // Persisted values are read back by index. Reordering this enum would
      // silently move every existing player's d-pad, which is exactly the
      // "migration" this fix promised not to need.
      expect(DPadPosition.values.map((p) => p.name).toList(), [
        'bottomLeft',
        'bottomCenter',
        'bottomRight',
      ]);
    });
  });

  group('the d-pad only takes input when steering is possible', () {
    testWidgets('a live control is at full opacity and takes pointers', (
      tester,
    ) async {
      Direction? steered;
      await tester.pumpWidget(
        harness(
          SteerableDPad(
            onDirection: (d) => steered = d,
            theme: GameTheme.classic,
            size: 140,
            canSteer: true,
          ),
        ),
      );

      final centre = tester.getCenter(find.byType(SteerableDPad));
      await tester.tapAt(centre + const Offset(0, 50));

      expect(steered, Direction.down);
      expect(_opacityOf(tester), 1.0);
      expect(_ignoringIn(tester), isFalse);
    });

    testWidgets('a dead or reconnecting player cannot press it', (
      tester,
    ) async {
      Direction? steered;
      await tester.pumpWidget(
        harness(
          SteerableDPad(
            onDirection: (d) => steered = d,
            theme: GameTheme.classic,
            size: 140,
            canSteer: false,
          ),
        ),
      );

      final centre = tester.getCenter(find.byType(SteerableDPad));
      await tester.tapAt(centre + const Offset(0, 50));
      await tester.tapAt(centre + const Offset(50, 0));

      expect(steered, isNull);
      expect(_opacityOf(tester), 0.45);
      expect(_ignoringIn(tester), isTrue);
    });

    testWidgets('pressing it produces no haptic of its own', (tester) async {
      // The domain layer owns input haptics. The d-pad firing one too is
      // exactly how an accepted turn came to buzz twice.
      final haptics = HapticRecorder()..install();
      HapticService().setEnabled(true);
      Direction? steered;
      await tester.pumpWidget(
        harness(
          SteerableDPad(
            onDirection: (d) => steered = d,
            theme: GameTheme.classic,
            size: 140,
            canSteer: true,
          ),
        ),
      );

      final centre = tester.getCenter(find.byType(SteerableDPad));
      await tester.tapAt(centre + const Offset(50, 0));
      await tester.pump();

      expect(steered, Direction.right);
      expect(haptics.calls, isEmpty);
    });

    testWidgets('single-player dims it once the run is over', (tester) async {
      await useScreen(tester, const Size(360, 640));
      await tester.pumpWidget(
        harness(
          GameBottomBar(
            gameState: playingState(status: GameStatus.gameOver),
            theme: GameTheme.classic,
            isSmallScreen: false,
            dPadEnabled: true,
            onDirection: (_) {},
          ),
        ),
      );

      final pad = tester.widget<SteerableDPad>(find.byType(SteerableDPad));
      expect(pad.canSteer, isFalse);
    });
  });
  group('the tutorial can borrow the d-pad from a paused game', () {
    Future<Direction?> pressDown(
      WidgetTester tester, {
      required bool? override,
    }) async {
      Direction? steered;
      await useScreen(tester, const Size(360, 640));
      await tester.pumpWidget(
        harness(
          GameBottomBar(
            gameState: playingState(status: GameStatus.paused),
            theme: GameTheme.classic,
            isSmallScreen: false,
            dPadEnabled: true,
            canSteerOverride: override,
            onDirection: (d) => steered = d,
          ),
        ),
      );

      final centre = tester.getCenter(find.byType(SteerableDPad));
      await tester.tapAt(centre + const Offset(0, 40));
      await tester.pump();
      return steered;
    }

    testWidgets('the override makes a paused d-pad usable', (tester) async {
      // The tutorial pauses the game and then asks the player to turn. Without
      // this the control it is teaching is dimmed and swallows every press,
      // so a d-pad player cannot finish the practice steps at all.
      expect(await pressDown(tester, override: true), Direction.down);
    });

    testWidgets('and it looks usable while it is', (tester) async {
      await useScreen(tester, const Size(360, 640));
      await tester.pumpWidget(
        harness(
          GameBottomBar(
            gameState: playingState(status: GameStatus.paused),
            theme: GameTheme.classic,
            isSmallScreen: false,
            dPadEnabled: true,
            canSteerOverride: true,
            onDirection: (_) {},
          ),
        ),
      );

      expect(_opacityOf(tester), 1.0);
      expect(_ignoringIn(tester), isFalse);
    });

    testWidgets('an ordinary paused game is still not steerable', (
      tester,
    ) async {
      expect(await pressDown(tester, override: null), isNull);
    });

    testWidgets('and still looks unavailable', (tester) async {
      await useScreen(tester, const Size(360, 640));
      await tester.pumpWidget(
        harness(
          GameBottomBar(
            gameState: playingState(status: GameStatus.paused),
            theme: GameTheme.classic,
            isSmallScreen: false,
            dPadEnabled: true,
            onDirection: (_) {},
          ),
        ),
      );

      expect(_opacityOf(tester), 0.45);
      expect(_ignoringIn(tester), isTrue);
    });

    testWidgets('a false override can still lock a running game out', (
      tester,
    ) async {
      // The override is the whole answer when present, in both directions.
      Direction? steered;
      await useScreen(tester, const Size(360, 640));
      await tester.pumpWidget(
        harness(
          GameBottomBar(
            gameState: playingState(),
            theme: GameTheme.classic,
            isSmallScreen: false,
            dPadEnabled: true,
            canSteerOverride: false,
            onDirection: (d) => steered = d,
          ),
        ),
      );

      final centre = tester.getCenter(find.byType(SteerableDPad));
      await tester.tapAt(centre + const Offset(0, 40));
      await tester.pump();

      expect(steered, isNull);
    });
  });
}

double _opacityOf(WidgetTester tester) => tester
    .widget<Opacity>(
      find.descendant(
        of: find.byType(SteerableDPad),
        matching: find.byType(Opacity),
      ),
    )
    .opacity;

bool _ignoringIn(WidgetTester tester) => tester
    .widget<IgnorePointer>(
      find.descendant(
        of: find.byType(SteerableDPad),
        matching: find.byType(IgnorePointer),
      ),
    )
    .ignoring;
