import 'package:snake_classic/services/analytics/analytics_client.dart';
import 'package:snake_classic/utils/logger.dart';

/// Per-session tally of ad requests and their outcomes, sent to Analytics as
/// one `ad_load_stats` event per format when the app goes to the background.
///
/// It exists to explain the banner match rate. AdMob's console shows that
/// banners fill only ~21% of requests (October 2026: 250K requests, 43K
/// impressions in 30 days, on every app version) but never says why, and the
/// app's logs don't reach Sentry. The failure codes tell the causes apart:
///  * 3 (no fill): the network had nothing for us. Inventory/demand, not code.
///  * 1 (invalid request) / 0 (internal): something in how we ask.
///  * 2 (network): the device was offline or flaky.
/// And [refreshFailed] against [failed] separates failed auto-refreshes of a
/// banner already on screen (harmless, the old creative stays up) from
/// placements that got no ad at all.
///
/// Aggregated rather than an event per failure: banners alone fail ~200K
/// times a month, which would drown every other event in Analytics.
class AdLoadStats {
  final Map<String, _FormatTally> _tallies = {};

  _FormatTally _of(String format) =>
      _tallies.putIfAbsent(format, _FormatTally.new);

  /// A load request was sent to AdMob (initial loads only; banner
  /// auto-refreshes are counted by [refreshed] / [refreshFailed]).
  void requested(String format) => _of(format).requests++;

  void filled(String format) => _of(format).filled++;

  void failed(String format, int code, String message) {
    final t = _of(format);
    t.failed++;
    t.codes[code] = (t.codes[code] ?? 0) + 1;
    t.lastMessage = message;
  }

  /// AdMob auto-refreshed a banner that is on screen.
  void refreshed() => _of('banner').refreshOk++;

  /// An auto-refresh of an on-screen banner failed; it keeps its old creative.
  void refreshFailed(int code, String message) {
    final t = _of('banner');
    t.refreshFailed++;
    t.codes[code] = (t.codes[code] ?? 0) + 1;
    t.lastMessage = message;
  }

  /// Send what this session has seen and start over. Called when the app is
  /// backgrounded, which is the last moment a session reliably reaches.
  void flush(AnalyticsClient? analytics) {
    if (_tallies.isEmpty) return;
    for (final entry in _tallies.entries) {
      final t = entry.value;
      if (t.isEmpty) continue;
      // "3:41,2:5" — failure code to count, most frequent first.
      final codes = (t.codes.entries.toList()
            ..sort((a, b) => b.value.compareTo(a.value)))
          .map((e) => '${e.key}:${e.value}')
          .join(',');
      AppLogger.info(
        'Ad load stats ${entry.key}: requests=${t.requests} '
        'filled=${t.filled} failed=${t.failed} refreshOk=${t.refreshOk} '
        'refreshFailed=${t.refreshFailed} codes=$codes',
      );
      analytics?.trackAdLoadStats(
        format: entry.key,
        requests: t.requests,
        filled: t.filled,
        failed: t.failed,
        refreshOk: t.refreshOk,
        refreshFailed: t.refreshFailed,
        codes: codes,
        lastError: t.lastMessage,
      );
    }
    _tallies.clear();
  }
}

class _FormatTally {
  int requests = 0;
  int filled = 0;
  int failed = 0;
  int refreshOk = 0;
  int refreshFailed = 0;
  final Map<int, int> codes = {};
  String? lastMessage;

  bool get isEmpty =>
      requests == 0 && refreshOk == 0 && refreshFailed == 0 && failed == 0;
}
