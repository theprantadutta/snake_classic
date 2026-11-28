// Visual check of the About screen without a device:
//   flutter test tools/render_about_test.dart
// Writes build/about_{top,bottom}.png (a 390x844 dp phone at 2x) with the
// real JetBrains Mono font. Outside test/ so the normal suite never runs it.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/game_statistics.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/screens/about_screen.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/design/lb_tokens.dart';

Future<void> _loadFonts() async {
  final loader = FontLoader('JetBrainsMono');
  for (final w in ['Regular', 'Medium', 'SemiBold', 'Bold', 'ExtraBold']) {
    loader.addFont(
      Future.value(
        ByteData.sublistView(
          File('assets/fonts/JetBrainsMono-$w.ttf').readAsBytesSync(),
        ),
      ),
    );
  }
  await loader.load();
}

Future<void> _shot(WidgetTester tester, GlobalKey key, String name) async {
  final boundary =
      key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final bytes = await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: 2);
    return image.toByteData(format: ui.ImageByteFormat.png);
  });
  Directory('build').createSync(recursive: true);
  File('build/about_$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render About', (tester) async {
    await tester.runAsync(_loadFonts);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final key = GlobalKey();
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(create: (_) => _StubThemeCubit()),
          BlocProvider<PremiumCubit>(create: (_) => _StubPremiumCubit()),
        ],
        child: RepaintBoundary(
          key: key,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'JetBrainsMono',
              extensions: [LBPalette.of(GameTheme.classic)],
            ),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              ...GlobalMaterialLocalizations.delegates,
            ],
            supportedLocales: AppLocalizations.supportedLocales,
            home: AboutScreen(
              version: ('8.3.0', '90'),
              statistics: GameStatistics(
                totalGamesPlayed: 42,
                highScore: 380,
                totalFoodConsumed: 517,
                totalGameTime: 3 * 3600 + 25 * 60,
                firstPlayedDate: DateTime(2026, 8, 14),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _shot(tester, key, 'top');
    for (var i = 0; i < 2; i++) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -700));
      await tester.pumpAndSettle();
      await _shot(tester, key, 'scroll${i + 1}');
    }
  });
}

class _StubThemeCubit extends Cubit<ThemeState> implements ThemeCubit {
  _StubThemeCubit() : super(const ThemeState(currentTheme: GameTheme.classic));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _StubPremiumCubit extends Cubit<PremiumState> implements PremiumCubit {
  _StubPremiumCubit() : super(PremiumState.initial());

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}
