import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/direction.dart';
import 'package:snake_classic/widgets/dpad_controls.dart';
import 'package:snake_classic/widgets/game_bottom_bar.dart';
import 'package:snake_classic/widgets/turn_buttons.dart';

import 'control_test_harness.dart';

/// "I wish the D-pad could be resized. I'd like it to be bigger." (Play
/// review, Nov 2026). The size setting must change the control a player
/// actually touches, keep it on screen, and make the zone tall enough to
/// hold it.
void main() {
  Future<Size> dPadSizeFor(
    WidgetTester tester,
    ControlSize size, {
    double zone = 400,
    Size screen = const Size(400, 900),
  }) async {
    await useScreen(tester, screen);
    await tester.pumpWidget(
      harness(
        SizedBox(
          width: screen.width,
          child: GameBottomBar(
            gameState: playingState(),
            theme: GameTheme.classic,
            isSmallScreen: false,
            dPadEnabled: true,
            controlLayout: ControlLayout.dPad,
            controlSize: size,
            height: zone,
            onDirection: (_) {},
          ),
        ),
        size: screen,
      ),
    );
    return tester.getSize(find.byType(DPadControls));
  }

  testWidgets('normal keeps the old 190 dp cap', (tester) async {
    expect((await dPadSizeFor(tester, ControlSize.normal)).width, 190);
  });

  testWidgets('every step up draws a bigger pad', (tester) async {
    final sizes = <double>[];
    for (final s in ControlSize.values) {
      sizes.add((await dPadSizeFor(tester, s)).width);
    }
    for (var i = 1; i < sizes.length; i++) {
      expect(sizes[i], greaterThan(sizes[i - 1]), reason: '$sizes');
    }
    expect(sizes.last, closeTo(190 * 1.5, .01));
  });

  testWidgets('extra large never runs off a narrow phone', (tester) async {
    const screen = Size(320, 900);
    final size = await dPadSizeFor(
      tester,
      ControlSize.extraLarge,
      screen: screen,
    );
    expect(size.width, lessThanOrEqualTo(screen.width - 48));
    expect(tester.takeException(), isNull, reason: 'no overflow');
  });

  testWidgets('a short zone still bounds it (it never overflows the zone)',
      (tester) async {
    final size = await dPadSizeFor(tester, ControlSize.extraLarge, zone: 160);
    expect(size.height, lessThanOrEqualTo(160));
    expect(tester.takeException(), isNull);
  });

  testWidgets('the size reaches the turn buttons too', (tester) async {
    Future<double> heightFor(ControlSize size) async {
      await useScreen(tester, const Size(400, 900));
      await tester.pumpWidget(
        harness(
          GameBottomBar(
            gameState: playingState(),
            theme: GameTheme.classic,
            isSmallScreen: false,
            dPadEnabled: true,
            controlLayout: ControlLayout.turnButtons,
            controlSize: size,
            height: 420,
            onDirection: (_) {},
            onRelativeTurn: (_) {},
          ),
          size: const Size(400, 900),
        ),
      );
      return tester.getSize(find.byType(TurnButtons)).height;
    }

    final small = await heightFor(ControlSize.small);
    final large = await heightFor(ControlSize.large);
    expect(large, greaterThan(small));
  });

  testWidgets('a bigger pad still steers: each arm fires its direction',
      (tester) async {
    final fired = <Direction>[];
    await useScreen(tester, const Size(400, 900));
    await tester.pumpWidget(
      harness(
        GameBottomBar(
          gameState: playingState(),
          theme: GameTheme.classic,
          isSmallScreen: false,
          dPadEnabled: true,
          controlLayout: ControlLayout.dPad,
          controlSize: ControlSize.extraLarge,
          height: 400,
          onDirection: fired.add,
        ),
        size: const Size(400, 900),
      ),
    );
    final rect = tester.getRect(find.byType(DPadControls));
    final c = rect.center;
    final arm = rect.width * .4;
    for (final point in [
      c + Offset(0, -arm),
      c + Offset(arm, 0),
      c + Offset(0, arm),
      c + Offset(-arm, 0),
    ]) {
      await tester.tapAt(point);
      await tester.pump();
    }
    expect(fired, [
      Direction.up,
      Direction.right,
      Direction.down,
      Direction.left,
    ]);
  });

  group('zone floor', () {
    testWidgets('normal and small keep the 150 dp floor; large and up raise '
        'it, and only for on-screen controls', (tester) async {
      late BuildContext ctx;
      await tester.pumpWidget(
        harness(
          Builder(
            builder: (c) {
              ctx = c;
              return const SizedBox();
            },
          ),
        ),
      );
      double floor(bool onScreen, ControlLayout layout, ControlSize size) =>
          GameBottomBar.zoneMin(
            ctx,
            dPadEnabled: onScreen,
            layout: layout,
            size: size,
          );

      expect(floor(true, ControlLayout.dPad, ControlSize.normal), 150);
      expect(floor(true, ControlLayout.dPad, ControlSize.small), 150);
      expect(
        floor(true, ControlLayout.dPad, ControlSize.large),
        greaterThan(150),
      );
      expect(
        floor(true, ControlLayout.dPad, ControlSize.extraLarge),
        greaterThan(floor(true, ControlLayout.dPad, ControlSize.large)),
      );
      // Swipe and the stick don't have a size: the board keeps its room.
      expect(floor(false, ControlLayout.dPad, ControlSize.extraLarge), 150);
      expect(floor(true, ControlLayout.joystick, ControlSize.extraLarge), 150);
    });
  });
}
