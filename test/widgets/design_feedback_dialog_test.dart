import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/design_feedback_dialog.dart';

/// The classic design's feedback dialog: no answer without a rating, SEND
/// hands back the rating and the comment, NOT NOW hands back nothing (which
/// maybeShowDesignFeedback records as a dismissal).
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

  /// Opens the dialog and returns a getter for what it popped.
  Future<({DesignFeedbackAnswer? Function() result, bool Function() closed})>
      open(WidgetTester tester) async {
    DesignFeedbackAnswer? answer;
    var closed = false;
    await tester.pumpWidget(harness(
      Builder(
        builder: (context) => ElevatedButton(
          onPressed: () async {
            answer = await showDialog<DesignFeedbackAnswer>(
              context: context,
              builder: (_) =>
                  DesignFeedbackDialog(theme: GameTheme.values.first),
            );
            closed = true;
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return (result: () => answer, closed: () => closed);
  }

  ElevatedButton sendButton(WidgetTester tester) => tester.widget(
        find.widgetWithText(ElevatedButton, 'Send'),
      );

  testWidgets('asks the shared question with the shared strings',
      (tester) async {
    await open(tester);
    expect(find.text("How's the game feeling?"), findsOneWidget);
    expect(find.text('Rate it from 1 to 5. A comment is optional.'),
        findsOneWidget);
    expect(find.text('Not great'), findsOneWidget);
    expect(find.text('Love it'), findsOneWidget);
    expect(find.text('Comment (optional)'), findsOneWidget);
    for (var i = 1; i <= 5; i++) {
      expect(find.bySemanticsLabel('$i out of 5'), findsOneWidget);
    }
  });

  testWidgets('SEND is disabled until a rating is picked', (tester) async {
    await open(tester);
    expect(sendButton(tester).onPressed, isNull);
    await tester.tap(find.text('3'));
    await tester.pump();
    expect(sendButton(tester).onPressed, isNotNull);
  });

  testWidgets('SEND returns the rating and the comment', (tester) async {
    final h = await open(tester);
    await tester.tap(find.text('4'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'smooth');
    await tester.tap(find.text('Send'));
    await tester.pumpAndSettle();
    expect(h.closed(), isTrue);
    expect(h.result()?.rating, 4);
    expect(h.result()?.comment, 'smooth');
  });

  testWidgets('NOT NOW returns no answer', (tester) async {
    final h = await open(tester);
    await tester.tap(find.text('2'));
    await tester.pump();
    await tester.tap(find.text('Not now'));
    await tester.pumpAndSettle();
    expect(h.closed(), isTrue);
    expect(h.result(), isNull);
  });
}
