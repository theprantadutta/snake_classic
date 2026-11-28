import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/models/game_statistics.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/review_service.dart';
import 'package:snake_classic/services/statistics_service.dart';

/// The rating ask (8.3): 5 games and a day since first play, on both
/// platforms. Android used 8 games / 3 days, which almost nobody reached,
/// so the store rating came from players who rate unprompted.
void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  ReviewService serviceWith(GameStatistics stats, _FakeReview review) =>
      ReviewService(
        inAppReview: review,
        statisticsService: _FakeStats(stats),
        analytics: AnalyticsFacade(const []),
      );

  GameStatistics played(int games, Duration since) => GameStatistics(
    totalGamesPlayed: games,
    firstPlayedDate: DateTime.now().subtract(since),
  );

  test('5 games and a day in: asks', () async {
    final review = _FakeReview();
    final s = serviceWith(played(5, const Duration(days: 1, hours: 1)), review);
    expect(await s.maybeRequestReview(ReviewTrigger.newHighScore), isTrue);
  });

  test('4 games: too early', () async {
    final s = serviceWith(played(4, const Duration(days: 5)), _FakeReview());
    expect(await s.maybeRequestReview(ReviewTrigger.newHighScore), isFalse);
  });

  test('installed this morning: too early, however many games', () async {
    final s = serviceWith(played(30, const Duration(hours: 6)), _FakeReview());
    expect(await s.maybeRequestReview(ReviewTrigger.newHighScore), isFalse);
  });

  test('asks at most once per 60 days', () async {
    final s = serviceWith(played(10, const Duration(days: 4)), _FakeReview());
    expect(await s.maybeRequestReview(ReviewTrigger.newHighScore), isTrue);
    expect(
      await s.maybeRequestReview(ReviewTrigger.achievementUnlocked),
      isFalse,
    );
  });

  test('never when the platform has no review API', () async {
    final s = serviceWith(
      played(10, const Duration(days: 4)),
      _FakeReview(available: false),
    );
    expect(await s.maybeRequestReview(ReviewTrigger.newHighScore), isFalse);
  });
}

class _FakeStats extends ChangeNotifier implements StatisticsService {
  _FakeStats(this.statistics);

  @override
  final GameStatistics statistics;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}

class _FakeReview implements InAppReview {
  _FakeReview({this.available = true});

  final bool available;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<void> requestReview() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      super.noSuchMethod(invocation);
}
