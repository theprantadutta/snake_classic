import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/analytics/analytics_client.dart';
import 'package:snake_classic/services/analytics/retention_events.dart';

/// Records the generic calls the retention events ride on.
class _Recorder implements AnalyticsClient {
  final List<(String, Map<String, Object>)> events = [];
  final Map<String, String?> props = {};

  @override
  Future<void> trackEvent(String name, Map<String, Object> parameters) async =>
      events.add((name, parameters));

  @override
  Future<void> setUserProperty(String name, String? value) async =>
      props[name] = value;

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

void main() {
  group('isoWeekLabel', () {
    test('mid-year dates', () {
      expect(isoWeekLabel(DateTime(2026, 11, 22)), '2026-W47'); // Sunday
      expect(isoWeekLabel(DateTime(2026, 11, 23)), '2026-W48'); // Monday
    });

    test('year boundaries follow the ISO Thursday rule', () {
      // 1 Jan 2026 is a Thursday: week 1 of 2026.
      expect(isoWeekLabel(DateTime(2026, 1, 1)), '2026-W01');
      // 29 Dec 2025 (Monday) is in 2026-W01 too.
      expect(isoWeekLabel(DateTime(2025, 12, 29)), '2026-W01');
      // 1 Jan 2027 is a Friday: still the last week of 2026.
      expect(isoWeekLabel(DateTime(2027, 1, 1)), '2026-W53');
    });
  });

  group('RetentionEvents', () {
    test('first_input rounds to a tenth of a second', () async {
      final r = _Recorder();
      await r.trackFirstInput(
        runNumber: 1,
        secondsSinceRunStart: 2.4567,
        controlScheme: 'swipe',
      );
      expect(r.events.single.$1, 'first_input');
      expect(r.events.single.$2, {
        'run_number': 1,
        'seconds_since_run_start': 2.5,
        'control_scheme': 'swipe',
      });
    });

    test('daily_bonus_claimed sends doubled as 0/1', () async {
      final r = _Recorder();
      await r.trackDailyBonusClaimed(
        day: 3,
        streak: 3,
        doubled: true,
        surface: 'home',
      );
      expect(r.events.single.$2['doubled'], 1);
      expect(r.events.single.$2['surface'], 'home');
    });

    test('event names stay within GA4 limits', () async {
      final r = _Recorder();
      await r.trackReviveOffer(outcome: 'declined', runNumber: 4);
      await r.trackNextGoalShown(goals: 'daily,season');
      await r.trackNextGoalTapped(goal: 'season');
      await r.trackStreakBroken(previousStreak: 5);
      await r.trackWeeklyQuestCompleted(questId: 'q1');
      await r.trackWeeklyQuestClaimed(questId: 'q1');
      await r.trackNotificationPermission(
        stage: 'soft_shown',
        placement: 'first_best',
      );
      await r.trackDayOneReminder(result: 'scheduled');
      for (final (name, params) in r.events) {
        expect(name.length, lessThanOrEqualTo(40), reason: name);
        expect(RegExp(r'^[a-z][a-z0-9_]*$').hasMatch(name), isTrue);
        for (final v in params.values) {
          expect(v is String || v is num, isTrue, reason: '$name: $v');
        }
      }
    });

    test('user properties', () async {
      final r = _Recorder();
      await r.setOnboardingDone(true);
      await r.setNotificationPermission('granted');
      await r.setInstallWeek(DateTime(2026, 11, 23));
      expect(r.props, {
        'onboarding_done': '1',
        'notif_permission': 'granted',
        'install_week': '2026-W48',
      });
    });
  });
}
