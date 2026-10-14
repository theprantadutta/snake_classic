import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/ads/ad_load_stats.dart';
import 'package:snake_classic/services/analytics/analytics_client.dart';

class _Recorder implements AnalyticsClient {
  final List<Map<String, Object?>> events = [];

  @override
  Future<void> trackAdLoadStats({
    required String format,
    required int requests,
    required int filled,
    required int failed,
    required int refreshOk,
    required int refreshFailed,
    required String codes,
    String? lastError,
  }) async {
    events.add({
      'format': format,
      'requests': requests,
      'filled': filled,
      'failed': failed,
      'refreshOk': refreshOk,
      'refreshFailed': refreshFailed,
      'codes': codes,
      'lastError': lastError,
    });
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => Future<void>.value();
}

void main() {
  test('one event per format, codes most frequent first', () {
    final stats = AdLoadStats();
    final analytics = _Recorder();

    for (var i = 0; i < 4; i++) {
      stats.requested('banner');
    }
    stats.filled('banner');
    stats.failed('banner', 3, 'No fill.');
    stats.failed('banner', 3, 'No fill.');
    stats.failed('banner', 2, 'Network error.');
    stats.refreshed();
    stats.refreshFailed(3, 'No fill.');
    stats.requested('rewarded');
    stats.filled('rewarded');

    stats.flush(analytics);

    expect(analytics.events, hasLength(2));
    final banner = analytics.events.firstWhere((e) => e['format'] == 'banner');
    expect(banner['requests'], 4);
    expect(banner['filled'], 1);
    expect(banner['failed'], 3);
    expect(banner['refreshOk'], 1);
    expect(banner['refreshFailed'], 1);
    expect(banner['codes'], '3:3,2:1');
    expect(banner['lastError'], 'No fill.');
  });

  test('flush resets, and an empty session sends nothing', () {
    final stats = AdLoadStats();
    final analytics = _Recorder();
    stats.requested('interstitial');
    stats.flush(analytics);
    stats.flush(analytics);
    expect(analytics.events, hasLength(1));
  });
}
