import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/app_release_policy.dart';

/// The rule that decides whether an iOS player is interrupted, and whether
/// they can dismiss the interruption.
///
/// The blocking path is the one worth pinning hardest: it takes the game
/// away from someone who opened it to play, so every route into it should
/// be deliberate and every ambiguity should route away from it.
void main() {
  UpdatePrompt decide({
    bool enabled = true,
    String? current = '6.2.0',
    String? latest = '6.4.3',
    String? minimum = '6.0.1',
    Duration? sinceDeclined,
  }) =>
      AppReleasePolicy.decide(
        enabled: enabled,
        currentVersion: current,
        latestVersion: latest,
        minimumSupportedVersion: minimum,
        sinceDeclined: sinceDeclined,
      );

  group('AppVersion', () {
    test('orders by segment value, not lexicographically', () {
      final a = AppVersion.tryParse('6.4.10')!;
      final b = AppVersion.tryParse('6.4.9')!;
      expect(a.compareTo(b), greaterThan(0));
      expect(b.compareTo(a), lessThan(0));
    });

    test('treats a missing segment as zero', () {
      expect(AppVersion.tryParse('6.4')!.compareTo(AppVersion.tryParse('6.4.0')!), 0);
      expect(AppVersion.tryParse('6')!.compareTo(AppVersion.tryParse('6.0.0.0')!), 0);
    });

    test('rejects anything that is not dotted numerics', () {
      for (final bad in [
        null, '', '   ', 'v6.4.3', '6.4.3-beta', '6..3', '6.4.', 'six',
        '6.4.3.2.1', '+6.4', '-6.4', '1234567',
      ]) {
        expect(AppVersion.tryParse(bad), isNull, reason: 'should reject "$bad"');
      }
    });

    test('accepts the shapes an operator actually types', () {
      for (final good in ['6', '6.4', '6.4.3', '6.4.3.54', ' 6.4.3 ', '10.0.0']) {
        expect(AppVersion.tryParse(good), isNotNull, reason: 'should accept "$good"');
      }
    });
  });

  group('decide', () {
    test('below the floor blocks', () {
      expect(decide(current: '5.1.0', minimum: '6.0.1'), UpdatePrompt.required);
    });

    test('blocking beats a fresh decline — a floor cannot be snoozed', () {
      expect(
        decide(
          current: '5.1.0',
          minimum: '6.0.1',
          sinceDeclined: const Duration(minutes: 1),
        ),
        UpdatePrompt.required,
      );
    });

    test('behind the latest but above the floor is dismissible', () {
      expect(decide(current: '6.2.0'), UpdatePrompt.optional);
    });

    test('exactly at the floor is not blocked', () {
      expect(decide(current: '6.0.1', minimum: '6.0.1'), UpdatePrompt.optional);
    });

    test('on the latest says nothing', () {
      expect(decide(current: '6.4.3'), UpdatePrompt.none);
    });

    test('ahead of the latest says nothing', () {
      // A TestFlight build, or the store row not yet raised after a release.
      expect(decide(current: '6.5.0'), UpdatePrompt.none);
    });

    test('a recent decline suppresses the optional prompt', () {
      expect(
        decide(sinceDeclined: const Duration(hours: 1)),
        UpdatePrompt.none,
      );
    });

    test('an expired decline asks again', () {
      expect(
        decide(sinceDeclined: const Duration(hours: 25)),
        UpdatePrompt.optional,
      );
    });

    test('disabled says nothing, whatever the versions claim', () {
      expect(
        decide(enabled: false, current: '1.0.0', minimum: '6.0.1'),
        UpdatePrompt.none,
      );
    });
  });

  group('never blocks on an unknown', () {
    test('an unparseable running version is left alone', () {
      // A packaging bug must not cost the player the game.
      expect(decide(current: 'garbage', minimum: '6.0.1'), UpdatePrompt.none);
      expect(decide(current: null, minimum: '6.0.1'), UpdatePrompt.none);
    });

    test('an unparseable floor is ignored, and the nudge still works', () {
      expect(decide(minimum: 'nonsense'), UpdatePrompt.optional);
    });

    test('an unparseable latest silences the nudge but keeps the floor', () {
      expect(decide(latest: 'nonsense'), UpdatePrompt.none);
      expect(
        decide(current: '5.1.0', latest: 'nonsense', minimum: '6.0.1'),
        UpdatePrompt.required,
      );
    });

    test('a policy that never arrived says nothing', () {
      expect(decide(latest: null, minimum: null), UpdatePrompt.none);
    });
  });
}
