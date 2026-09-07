import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/update_policy.dart';

/// Which Play update flow a launch gets. Flexible by default, the blocking
/// flow only for releases the publisher marked urgent, and a refusal is
/// respected for a day rather than re-asked on the next cold start.
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

  test('a routine release is offered flexibly, even though Play would allow '
      'the blocking flow', () {
    expect(decide(priority: 0), UpdateFlow.flexible);
    expect(decide(priority: 3), UpdateFlow.flexible);
  });

  test('an urgent release gets the blocking flow', () {
    expect(decide(priority: 4), UpdateFlow.immediate);
    expect(decide(priority: 5), UpdateFlow.immediate);
  });

  test('an urgent release cuts through a snooze', () {
    expect(
      decide(priority: 5, sinceDeclined: const Duration(minutes: 5)),
      UpdateFlow.immediate,
    );
  });

  test('a declined routine offer is left alone for a day', () {
    expect(
      decide(sinceDeclined: const Duration(hours: 23)),
      UpdateFlow.none,
    );
    expect(
      decide(sinceDeclined: const Duration(hours: 25)),
      UpdateFlow.flexible,
    );
  });

  test('when Play only allows the blocking flow, a routine release waits', () {
    expect(decide(flexible: false), UpdateFlow.none);
  });

  test('an urgent release that Play will not run immediately falls back to '
      'flexible rather than nothing', () {
    expect(decide(priority: 5, immediate: false), UpdateFlow.flexible);
  });
}
