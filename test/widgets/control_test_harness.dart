import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_state.dart';
import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/models/snake.dart';
import 'package:snake_classic/utils/direction.dart';

/// Shared scaffolding for the gameplay-control widget tests.
///
/// These widgets are ordinary presentation code — they need a Directionality,
/// a MediaQuery and the localizations, and nothing else. Keeping the harness
/// here means none of the tests reaches for the app's DI container.

/// Wrap a control under test in the minimum an app gives it.
Widget harness(
  Widget child, {
  Size size = const Size(360, 640),
  double textScale = 1.0,
  Locale locale = const Locale('en'),
}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: MediaQuery(
      data: MediaQueryData(
        size: size,
        textScaler: TextScaler.linear(textScale),
      ),
      child: Scaffold(body: Center(child: child)),
    ),
  );
}

/// Resize the test surface so layout-sensitive widgets see a real phone.
Future<void> useScreen(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
}

/// A playable game state for widgets that only read length/speed/status.
GameState playingState({
  GameStatus status = GameStatus.playing,
  int length = 3,
}) {
  return GameState(
    snake: Snake(
      body: [for (var i = 0; i < length; i++) Position(4 - i, 10)],
      currentDirection: Direction.right,
    ),
    status: status,
  );
}

/// Records every haptic the platform is asked for during a test.
///
/// The audit's feedback rules are counting rules — an accepted input gets
/// exactly one effect, a meaningless tap gets none — so the tests have to be
/// able to count. `HapticFeedback` goes out over SystemChannels.platform, so
/// that is where we listen.
class HapticRecorder {
  final List<String> calls = [];

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'HapticFeedback.vibrate') {
            calls.add(call.arguments?.toString() ?? 'vibrate');
          }
          return null;
        });
    addTearDown(
      () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(SystemChannels.platform, null),
    );
  }
}
