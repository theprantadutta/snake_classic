import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/widgets/app_update_dialog.dart';

import 'control_test_harness.dart';

class _Facade implements AnalyticsFacade {
  final List<(String, Map<String, Object>)> events = [];

  @override
  Future<void> trackEvent(String name, Map<String, Object> parameters) async =>
      events.add((name, parameters));

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

/// The Android update offer: "Update now" hands over to Play's blocking
/// flow (no Restart button to forget), "Later" snoozes. Play's method
/// channel is mocked: it answers the way Play does when the player backs
/// out of its update screen.
const _play = MethodChannel('de.ffuf.in_app_update/methods');
final playCalls = <String>[];

void main() {
  late _Facade facade;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    facade = _Facade();
    GetIt.I.registerSingleton<AnalyticsFacade>(facade);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_play, (call) async {
      playCalls.add(call.method);
      throw PlatformException(code: 'USER_DENIED_UPDATE');
    });
  });
  tearDown(() {
    GetIt.I.unregister<AnalyticsFacade>();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_play, null);
    playCalls.clear();
  });

  Future<void> open(WidgetTester tester) async {
    await tester.pumpWidget(
      harness(
        Builder(
          builder: (context) => Center(
            child: TextButton(
              onPressed: () => showPlayUpdateOfferDialog(context),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  List<String> stages() =>
      [for (final e in facade.events) e.$2['stage'] as String];

  testWidgets('shows the offer and logs it', (tester) async {
    await open(tester);
    expect(find.textContaining('restarts by itself'), findsOneWidget);
    expect(find.text('Update now'), findsOneWidget);
    expect(find.text('Later'), findsOneWidget);
    expect(stages(), ['offered']);
  });

  testWidgets('Later closes and snoozes', (tester) async {
    await open(tester);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(find.text('Update now'), findsNothing);
    expect(stages(), ['offered', 'snoozed']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('in_app_update_declined_ms'), isNotNull);
  });

  testWidgets('tapping outside counts as Later', (tester) async {
    await open(tester);
    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();
    expect(stages(), ['offered', 'snoozed']);
  });

  testWidgets("Update now hands over to Play's blocking flow; backing out "
      "of Play's screen snoozes like Later", (tester) async {
    await open(tester);
    await tester.tap(find.text('Update now'));
    await tester.pumpAndSettle();
    expect(find.text('Update now'), findsNothing);
    expect(playCalls, ['performImmediateUpdate']);
    expect(stages(), ['offered', 'accepted', 'immediate_result']);
    expect(facade.events.last.$2['result'], 'userDeniedUpdate');
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('in_app_update_declined_ms'), isNotNull);
  });

  testWidgets('Later never touches Play', (tester) async {
    await open(tester);
    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();
    expect(playCalls, isEmpty);
  });
}
