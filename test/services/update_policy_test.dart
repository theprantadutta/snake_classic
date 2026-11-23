import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/update_policy.dart';

/// Which Play update flow a launch gets. A routine release is offered with
/// our own dialog (whose "Update now" runs Play's blocking flow), the
/// blocking flow runs unasked only for releases marked urgent, and a refusal
/// is respected for a day rather than re-asked on the next cold start.
void main() {
  UpdateFlow decide({
    bool available = true,
    int priority = 0,
    bool immediate = true,
    bool flexible = true,
    Duration? sinceDeclined,
  }) =>
      UpdatePolicy.decide(
        updateAvailable: available,
        priority: priority,
        immediateAllowed: immediate,
        flexibleAllowed: flexible,
        sinceDeclined: sinceDeclined,
      );

  test('no update, no flow', () {
    expect(decide(available: false), UpdateFlow.none);
  });

  test('a routine release is offered (our dialog first, never a wall)', () {
    expect(decide(priority: 0), UpdateFlow.offer);
    expect(decide(priority: 3), UpdateFlow.offer);
  });

  test('an urgent release gets the blocking flow without asking', () {
    expect(decide(priority: 4), UpdateFlow.immediate);
    expect(decide(priority: 5), UpdateFlow.immediate);
  });

  test('an urgent release cuts through a snooze', () {
    expect(
      decide(priority: 5, sinceDeclined: const Duration(minutes: 5)),
      UpdateFlow.immediate,
    );
  });

  test('a snoozed offer is left alone for a day', () {
    expect(decide(sinceDeclined: const Duration(hours: 23)), UpdateFlow.none);
    expect(decide(sinceDeclined: const Duration(hours: 25)), UpdateFlow.offer);
  });

  test('when Play only allows the background download, use it as a fallback',
      () {
    expect(decide(immediate: false), UpdateFlow.flexible);
    expect(decide(priority: 5, immediate: false), UpdateFlow.flexible);
  });

  test('when Play allows neither, nothing', () {
    expect(decide(immediate: false, flexible: false), UpdateFlow.none);
  });
}
