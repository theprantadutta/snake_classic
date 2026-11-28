import 'package:drift/native.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/presentation/bloc/game/game_settings_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/control_tuning.dart';
import 'package:snake_classic/widgets/dialogs/control_choice_dialog.dart';

import 'control_test_harness.dart';

/// The tuning under the control picker (Settings, Pause, the intro) and the
/// one-time "Pick your controls" intro.
void main() {
  late AppDatabase db;
  late GameSettingsCubit cubit;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await StorageService().initialize(db);
    cubit = GameSettingsCubit(StorageService());
  });

  tearDown(() async {
    await cubit.close();
    await db.close();
  });

  Future<void> pumpTuning(WidgetTester tester) async {
    await useScreen(tester, const Size(420, 900));
    await tester.pumpWidget(
      BlocProvider<GameSettingsCubit>.value(
        value: cubit,
        child: harness(
          BlocBuilder<GameSettingsCubit, GameSettingsState>(
            builder: (_, s) => SizedBox(
              width: 400,
              child: SingleChildScrollView(child: ControlTuning(settings: s)),
            ),
          ),
          size: const Size(420, 900),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('ControlTuning shows what applies to the chosen control', () {
    testWidgets('swipe: sensitivity only', (tester) async {
      await cubit.setDPadEnabled(false);
      await pumpTuning(tester);
      expect(find.text('SWIPE SENSITIVITY'), findsOneWidget);
      expect(find.text('BUTTON SIZE'), findsNothing);
    });

    testWidgets('d-pad: size and position', (tester) async {
      await cubit.setDPadEnabled(true);
      await cubit.setControlLayout(ControlLayout.dPad);
      await pumpTuning(tester);
      expect(find.text('BUTTON SIZE'), findsOneWidget);
      expect(find.text('SWIPE SENSITIVITY'), findsNothing);
      expect(find.text('LEFT'), findsOneWidget);
    });

    testWidgets('turn buttons: size, no position', (tester) async {
      await cubit.setDPadEnabled(true);
      await cubit.setControlLayout(ControlLayout.turnButtons);
      await pumpTuning(tester);
      expect(find.text('BUTTON SIZE'), findsOneWidget);
      expect(find.text('LEFT'), findsNothing);
    });

    testWidgets('stick: nothing to tune', (tester) async {
      await cubit.setDPadEnabled(true);
      await cubit.setControlLayout(ControlLayout.joystick);
      await pumpTuning(tester);
      expect(find.text('BUTTON SIZE'), findsNothing);
      expect(find.text('SWIPE SENSITIVITY'), findsNothing);
    });
  });

  testWidgets('tapping an option writes it through the cubit', (tester) async {
    await cubit.setDPadEnabled(true);
    await cubit.setControlLayout(ControlLayout.dPad);
    await pumpTuning(tester);

    await tester.tap(find.text('HUGE'));
    await tester.pumpAndSettle();
    expect(cubit.state.controlSize, ControlSize.extraLarge);
    expect(await StorageService().getControlSize(), ControlSize.extraLarge);

    await tester.tap(find.text('RIGHT'));
    await tester.pumpAndSettle();
    expect(cubit.state.dPadPosition, DPadPosition.bottomRight);

    await cubit.setDPadEnabled(false);
    await tester.pumpAndSettle();
    await tester.tap(find.text('HIGH'));
    await tester.pumpAndSettle();
    expect(cubit.state.swipeSensitivity, SwipeSensitivity.high);
  });

  group('ControlsIntro: once per install, never before the first game', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('not before the very first game (play-first stays instant)', () async {
      expect(await ControlsIntro.shouldShow(gamesStarted: 0), isFalse);
    });

    test('before the second game, and for existing players', () async {
      expect(await ControlsIntro.shouldShow(gamesStarted: 1), isTrue);
      expect(await ControlsIntro.shouldShow(gamesStarted: 250), isTrue);
    });

    test('never again once seen', () async {
      await ControlsIntro.markSeen();
      expect(await ControlsIntro.shouldShow(gamesStarted: 1), isFalse);
      expect(await ControlsIntro.shouldShow(gamesStarted: 5), isFalse);
    });

    testWidgets('the sheet lists all four styles, switches live, and PLAY '
        'closes it', (tester) async {
      await useScreen(tester, const Size(400, 860));
      var closed = false;
      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<GameSettingsCubit>.value(value: cubit),
            BlocProvider<ThemeCubit>(create: (_) => _StubThemeCubit()),
          ],
          child: harness(
            Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  await showControlsIntroSheet(context);
                  closed = true;
                },
                child: const Text('open'),
              ),
            ),
            size: const Size(400, 860),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('PICK YOUR CONTROLS'), findsOneWidget);
      expect(tester.takeException(), isNull, reason: 'fits a 400x860 phone');
      // Marked seen as soon as it opens.
      expect(await ControlsIntro.shouldShow(gamesStarted: 3), isFalse);

      // Pick the d-pad: settings change immediately, and the d-pad tuning
      // appears under the choices.
      await tester.tap(find.text('D-PAD').first);
      await tester.pumpAndSettle();
      expect(cubit.state.dPadEnabled, isTrue);
      expect(cubit.state.controlLayout, ControlLayout.dPad);
      expect(find.text('BUTTON SIZE'), findsOneWidget);

      await tester.ensureVisible(find.text('PLAY'));
      await tester.tap(find.text('PLAY'));
      await tester.pumpAndSettle();
      expect(closed, isTrue);
      expect(find.text('PICK YOUR CONTROLS'), findsNothing);
    });
  });
}

class _StubThemeCubit extends Cubit<ThemeState> implements ThemeCubit {
  _StubThemeCubit() : super(const ThemeState(currentTheme: GameTheme.classic));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}
