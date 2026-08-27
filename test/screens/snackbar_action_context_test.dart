import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// A snack bar outlives the screen that showed it, and its action must cope.
///
/// The multiplayer lobby shows a 4-second error snack bar and, when a match
/// starts, replaces itself with the game screen. `ScaffoldMessenger` is
/// app-level, so the snack bar keeps floating over the game with the lobby
/// already gone. Its "Dismiss" button used to call
/// `ScaffoldMessenger.of(context)` on the context it had captured from the
/// lobby — a defunct element by then — and the `!` inside that lookup threw.
/// 40 crashes across 27 users.
///
/// These pin the two things the fix depends on: that the action no longer
/// touches the dead context, and that the button still actually dismisses,
/// since it now relies on the framework to do that. If a Flutter upgrade ever
/// stops `_SnackBarActionState._handlePressed` from calling
/// `hideCurrentSnackBar` itself, the second test fails and tells us the empty
/// callback has become a silently dead button.
void main() {
  /// Shows a snack bar from the first route, then replaces that route so the
  /// context the action captured is unmounted while the snack bar remains.
  Future<void> showThenLeaveScreen(
    WidgetTester tester,
    VoidCallback Function(BuildContext origin) buildAction,
  ) async {
    final nav = GlobalKey<NavigatorState>();

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: nav,
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('connection lost'),
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 4),
                      action: SnackBarAction(
                        label: 'Dismiss',
                        onPressed: buildAction(context),
                      ),
                    ),
                  );
                },
                child: const Text('show'),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('show'));
    await tester.pump();
    expect(find.text('Dismiss'), findsOneWidget);

    // What the lobby does the instant a match starts.
    nav.currentState!.pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => const Scaffold(body: Center(child: Text('game'))),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('game'), findsOneWidget);
    expect(
      find.text('Dismiss'),
      findsOneWidget,
      reason: 'the snack bar belongs to the app-level messenger, so it stays',
    );
  }

  testWidgets('dismissing after the screen is gone does not throw', (
    tester,
  ) async {
    await showThenLeaveScreen(tester, (_) => () {});

    await tester.tap(find.text('Dismiss'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });

  testWidgets('the button still dismisses, without a callback of its own', (
    tester,
  ) async {
    // The whole justification for the empty callback: the framework's own
    // hideCurrentSnackBar still runs, using the action's own live context.
    await showThenLeaveScreen(tester, (_) => () {});

    await tester.tap(find.text('Dismiss'));
    await tester.pumpAndSettle();

    expect(find.text('Dismiss'), findsNothing);
    expect(find.text('connection lost'), findsNothing);
  });

  testWidgets('the old shape — looking the messenger up on the captured '
      'context — is what threw', (tester) async {
    // Kept as the executable record of the bug, so nobody "tidies" the empty
    // callback back into this.
    //
    // The thrown error differs by build mode: in release, where the crash was
    // reported from, the lookup returns null and the `!` throws "Null check
    // operator used on a null value". In a debug build like this test, the
    // framework asserts first and throws "Looking up a deactivated widget's
    // ancestor is unsafe" instead. Same defect, two faces — which is why the
    // Crashlytics text does not match what a developer sees locally.
    await showThenLeaveScreen(
      tester,
      (origin) => () => ScaffoldMessenger.of(origin).hideCurrentSnackBar(),
    );

    await tester.tap(find.text('Dismiss'));
    await tester.pump();

    expect(
      tester.takeException(),
      isNotNull,
      reason: 'reaching through the dead context is the crash',
    );
  });
}
