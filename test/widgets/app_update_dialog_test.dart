import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/services/app_release_policy.dart';
import 'package:snake_classic/services/app_release_service.dart';
import 'package:snake_classic/widgets/app_update_dialog.dart';

/// The dialog's two shapes, and the one property that matters most: a
/// required update must not have a way out.
///
/// The optional one is an interruption a player can wave away. The required
/// one takes the game away until they act, so every exit route — the Later
/// button, a tap on the barrier, the system back gesture — has to be closed,
/// and each is checked separately here because they are three different
/// mechanisms and closing one does not close the others.
void main() {
  Widget harness(Widget child) => MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: child),
      );

  Future<void> open(WidgetTester tester, UpdatePrompt prompt) async {
    // The dialog reads its destination off the singleton; without a store
    // URL it deliberately refuses to open at all.
    AppReleaseService().storeUrl = 'https://apps.apple.com/app/id6779621362';
    AppReleaseService().latestVersion = '6.4.3';

    await tester.pumpWidget(harness(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => showAppUpdateDialog(context, prompt),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('optional shows both actions and names the version', (tester) async {
    await open(tester, UpdatePrompt.optional);

    expect(find.text('Update available'), findsOneWidget);
    expect(find.textContaining('6.4.3'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
  });

  testWidgets('optional closes on Later', (tester) async {
    await open(tester, UpdatePrompt.optional);

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(find.text('Update available'), findsNothing);
  });

  testWidgets('optional closes on a barrier tap', (tester) async {
    await open(tester, UpdatePrompt.optional);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Update available'), findsNothing);
  });

  testWidgets('required offers no Later', (tester) async {
    await open(tester, UpdatePrompt.required);

    expect(find.text('Update required'), findsOneWidget);
    expect(find.text('Update'), findsOneWidget);
    expect(find.text('Later'), findsNothing);
  });

  testWidgets('required survives a barrier tap', (tester) async {
    await open(tester, UpdatePrompt.required);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('Update required'), findsOneWidget);
  });

  testWidgets('required survives the system back gesture', (tester) async {
    await open(tester, UpdatePrompt.required);

    // What Android's back button / iOS's back swipe actually delivers.
    final popped = await tester.binding.defaultBinaryMessenger
        .handlePlatformMessage(
      'flutter/navigation',
      const JSONMethodCodec().encodeMethodCall(
        const MethodCall('popRoute'),
      ),
      (_) {},
    );
    await tester.pumpAndSettle();

    expect(popped, isNotNull);
    expect(find.text('Update required'), findsOneWidget);
  });

  testWidgets('nothing opens without a store URL', (tester) async {
    AppReleaseService().storeUrl = null;

    await tester.pumpWidget(harness(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () =>
              showAppUpdateDialog(context, UpdatePrompt.required),
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Telling someone they must update, with no way to do it, would be a
    // dead end with no escape. Better to say nothing.
    expect(find.text('Update required'), findsNothing);
  });

  testWidgets('none never opens', (tester) async {
    await open(tester, UpdatePrompt.none);

    expect(find.text('Update available'), findsNothing);
    expect(find.text('Update required'), findsNothing);
  });
}
