import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/sync/statistics_merge.dart';

/// The restore path used to write the cloud statistics blob straight over
/// local Drift. Because the apply runs right after `clearSyncQueue()` and
/// writes with `enqueueSync: false`, anything local that hadn't been pushed
/// yet was destroyed on both sides at once — silently, with no error, and
/// with no way to get it back.
///
/// These tests pin the merge rules that replaced it. They mirror
/// `SyncStatisticsCommandHandler.MergeStatistics` on the backend; if you
/// change one side, change the other and update these.
void main() {
  Map<String, dynamic> merge(
    Map<String, dynamic> local,
    Map<String, dynamic> cloud,
  ) {
    final result = mergeStatisticsJson(jsonEncode(local), jsonEncode(cloud));
    return jsonDecode(result.json) as Map<String, dynamic>;
  }

  group('monotonic counters', () {
    test('never regress when the cloud snapshot is behind local', () {
      // The guest-period scenario: reinstall, play 40 games offline, then
      // sign into an account whose cloud copy still says 12.
      final merged = merge(
        {'totalGamesPlayed': 40, 'totalScore': 9000, 'highScore': 730},
        {'totalGamesPlayed': 12, 'totalScore': 2500, 'highScore': 410},
      );

      expect(merged['totalGamesPlayed'], 40);
      expect(merged['totalScore'], 9000);
      expect(merged['highScore'], 730);
    });

    test('adopt the cloud value when it is ahead', () {
      final merged = merge(
        {'totalGamesPlayed': 3, 'highScore': 100},
        {'totalGamesPlayed': 88, 'highScore': 4200},
      );

      expect(merged['totalGamesPlayed'], 88);
      expect(merged['highScore'], 4200);
    });

    test('take whichever side has the field when the other is missing', () {
      final merged = merge({'perfectGames': 7}, {'wallCollisions': 21});

      expect(merged['perfectGames'], 7);
      expect(merged['wallCollisions'], 21);
    });

    test('every documented monotonic field is actually folded', () {
      // Guards the lockstep requirement with the backend list: a field
      // added to kStatsMonotonicFields but mishandled would show up here.
      final local = {for (final f in kStatsMonotonicFields) f: 5};
      final cloud = {for (final f in kStatsMonotonicFields) f: 2};
      final merged = merge(local, cloud);

      for (final field in kStatsMonotonicFields) {
        expect(merged[field], 5, reason: '$field should MAX-fold to local');
      }
    });
  });

  group('monotonic maps', () {
    test('merge per key, keeping the larger count on each', () {
      final merged = merge(
        {
          'foodTypeCount': {'apple': 30, 'cherry': 4},
        },
        {
          'foodTypeCount': {'apple': 11, 'banana': 9},
        },
      );

      final food = merged['foodTypeCount'] as Map<String, dynamic>;
      expect(food['apple'], 30, reason: 'local ahead');
      expect(food['cherry'], 4, reason: 'local-only key survives');
      expect(food['banana'], 9, reason: 'cloud-only key survives');
    });
  });

  group('recentScores and dates', () {
    test('keeps the longer score history', () {
      final merged = merge(
        {
          'recentScores': [1, 2, 3, 4],
        },
        {
          'recentScores': [9],
        },
      );

      expect(merged['recentScores'], [1, 2, 3, 4]);
    });

    test('keeps the earliest firstPlayed and the latest lastPlayed', () {
      final merged = merge(
        {
          'firstPlayedDate': '2026-01-05T00:00:00.000Z',
          'lastPlayedDate': '2026-08-09T00:00:00.000Z',
        },
        {
          'firstPlayedDate': '2025-03-01T00:00:00.000Z',
          'lastPlayedDate': '2026-02-02T00:00:00.000Z',
        },
      );

      expect(merged['firstPlayedDate'], '2025-03-01T00:00:00.000Z');
      expect(merged['lastPlayedDate'], '2026-08-09T00:00:00.000Z');
    });
  });

  group('derived fields', () {
    test('are recomputed from the folded base, not carried over stale', () {
      // Local has the games, cloud has a stale ratio computed off its own
      // smaller totals. Neither side's averageScore is right for the merge.
      final merged = merge(
        {'totalGamesPlayed': 10, 'totalScore': 1000, 'averageScore': 100.0},
        {'totalGamesPlayed': 4, 'totalScore': 100, 'averageScore': 25.0},
      );

      expect(merged['totalGamesPlayed'], 10);
      expect(merged['totalScore'], 1000);
      expect(merged['averageScore'], 100.0);
    });

    test('divide-by-zero degrades to zero rather than NaN', () {
      final merged = merge({'totalGamesPlayed': 0}, {'totalGamesPlayed': 0});

      expect(merged['averageScore'], 0.0);
      expect(merged['collisionRate'], 0.0);
      expect(merged['survivalRate'], 0.0);
    });
  });

  group('localAhead signalling', () {
    test('is true when local holds a counter the cloud is behind on', () {
      final result = mergeStatisticsJson(
        jsonEncode({'totalGamesPlayed': 40}),
        jsonEncode({'totalGamesPlayed': 12}),
      );

      // Drives the outbox re-enqueue — without it the merged value would
      // never reach the server, because clearSyncQueue() already ran.
      expect(result.localAhead, isTrue);
    });

    test('is false when the cloud is at or ahead of local everywhere', () {
      final result = mergeStatisticsJson(
        jsonEncode({'totalGamesPlayed': 12}),
        jsonEncode({'totalGamesPlayed': 40}),
      );

      expect(result.localAhead, isFalse);
    });
  });

  group('degenerate input', () {
    test('empty local takes the cloud snapshot verbatim', () {
      final result = mergeStatisticsJson('{}', jsonEncode({'highScore': 500}));

      expect(jsonDecode(result.json)['highScore'], 500);
      expect(result.localAhead, isFalse);
    });

    test('empty cloud keeps local and flags it for push', () {
      final result = mergeStatisticsJson(jsonEncode({'highScore': 500}), '{}');

      expect(jsonDecode(result.json)['highScore'], 500);
      expect(result.localAhead, isTrue);
    });

    test('unparseable input degrades instead of throwing', () {
      final result = mergeStatisticsJson('not json', '{"highScore": 3}');

      expect(result.parseFailed, isTrue);
      expect(() => jsonDecode(result.json), returnsNormally);
    });

    test('counters written as strings by older clients still fold', () {
      final merged = merge({'highScore': '900'}, {'highScore': 120});

      expect(merged['highScore'], 900);
    });
  });
}
