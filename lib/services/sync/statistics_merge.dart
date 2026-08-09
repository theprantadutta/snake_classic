// Pure per-field merge for the `GameStatistics` model JSON.
//
// This is the DOWN direction of the statistics sync. The backend already
// owns the UP direction in `SyncStatisticsCommandHandler.MergeStatistics`
// and folds correctly there; this file is its mirror, so a snapshot coming
// back down can't undo what went up.
//
// Why it exists at all: the restore used to write the cloud blob straight
// over local Drift. Combined with the `clearSyncQueue()` that runs just
// before it, that meant a device which played through the play-first guest
// period and then signed into an existing account lost every one of those
// games — from local AND from the server, permanently, with no error.
//
// Kept pure (no Drift, no logging, no services) so the rules are testable
// on their own, in the same spirit as `game/session/pause_shift.dart`.

import 'dart:convert';
import 'dart:math' as math;

/// Outcome of [mergeStatisticsJson].
class StatisticsMergeResult {
  /// The merged document, ready to write to Drift.
  final String json;

  /// True when local held something the cloud snapshot did not — the
  /// caller must re-enqueue an outbox row so the merge reaches the server.
  final bool localAhead;

  /// True when one side could not be parsed and the merge degraded to
  /// picking a whole document. Callers may want to log this.
  final bool parseFailed;

  const StatisticsMergeResult({
    required this.json,
    required this.localAhead,
    this.parseFailed = false,
  });
}

/// Fields whose semantics are monotonic (only ever grow), folded by MAX.
///
/// MUST stay in lockstep with `MonotonicLongFields` in
/// `SyncStatisticsCommandHandler.cs`. A counter added there but not here
/// silently regresses on every restore.
const List<String> kStatsMonotonicFields = [
  'totalGamesPlayed',
  'totalScore',
  'highScore',
  'totalGameTime',
  'totalFoodConsumed',
  'totalFoodPoints',
  'totalPowerUpsCollected',
  'totalPowerUpTime',
  'longestSurvivalTime',
  'highestLevel',
  'totalLevelsGained',
  'gamesSurvived30s',
  'wallCollisions',
  'selfCollisions',
  'totalCollisions',
  'longestWinStreak',
  'gamesWithoutWallHit',
  'perfectGames',
  'totalSessions',
  'achievementsUnlocked',
  'totalAchievements',
];

/// `{ key: int }` maps folded by per-key MAX. Mirrors
/// `MonotonicMapFields` in `SyncStatisticsCommandHandler.cs`.
const List<String> kStatsMonotonicMapFields = [
  'foodTypeCount',
  'powerUpTypeCount',
  'dailyPlayTime',
];

/// Fold [cloudJson] into [localJson]. Local wins ties, matching the
/// backend's "client wins" rule for non-monotonic and derived fields.
StatisticsMergeResult mergeStatisticsJson(String localJson, String cloudJson) {
  Map<String, dynamic>? local;
  Map<String, dynamic>? cloud;
  try {
    local = _decodeObject(localJson);
    cloud = _decodeObject(cloudJson);
  } catch (_) {
    // Can't reason about either side. Prefer the cloud copy — it is at
    // least internally consistent — and flag nothing for re-push.
    return StatisticsMergeResult(
      json: cloudJson,
      localAhead: false,
      parseFailed: true,
    );
  }

  if (local == null || cloud == null) {
    return StatisticsMergeResult(
      json: local == null ? cloudJson : localJson,
      localAhead: local != null,
      parseFailed: true,
    );
  }

  // Nothing local worth keeping — take the snapshot verbatim.
  if (local.isEmpty) {
    return StatisticsMergeResult(json: cloudJson, localAhead: false);
  }
  // Nothing usable from the cloud — keep local untouched, and make sure it
  // gets pushed (the server clearly doesn't have it).
  if (cloud.isEmpty) {
    return StatisticsMergeResult(json: localJson, localAhead: true);
  }

  // Start from local so unmerged and derived fields resolve local-wins,
  // then copy across any key only the cloud has, so a field written by a
  // newer client on another device isn't dropped on the floor here.
  final merged = Map<String, dynamic>.from(local);
  for (final entry in cloud.entries) {
    merged.putIfAbsent(entry.key, () => entry.value);
  }

  var localAhead = false;

  for (final field in kStatsMonotonicFields) {
    final localVal = _asNum(local[field]);
    final cloudVal = _asNum(cloud[field]);
    if (localVal == null && cloudVal == null) continue;
    if (localVal != null && (cloudVal == null || localVal > cloudVal)) {
      localAhead = true;
    }
    if (localVal == null) {
      merged[field] = cloudVal!.toInt();
    } else if (cloudVal == null) {
      merged[field] = localVal.toInt();
    } else {
      merged[field] = math.max(localVal, cloudVal).toInt();
    }
  }

  for (final field in kStatsMonotonicMapFields) {
    final localMap = local[field];
    final cloudMap = cloud[field];
    if (localMap is! Map && cloudMap is! Map) continue;
    final result = <String, int>{};
    if (cloudMap is Map) {
      for (final entry in cloudMap.entries) {
        final v = _asNum(entry.value);
        if (v != null) result['${entry.key}'] = v.toInt();
      }
    }
    if (localMap is Map) {
      for (final entry in localMap.entries) {
        final v = _asNum(entry.value);
        if (v == null) continue;
        final key = '${entry.key}';
        final existing = result[key];
        if (existing == null || v > existing) {
          localAhead = true;
          result[key] = v.toInt();
        }
      }
    }
    merged[field] = result;
  }

  // recentScores — keep the longer history; local wins ties.
  final localRecent = local['recentScores'];
  final cloudRecent = cloud['recentScores'];
  if (cloudRecent is List &&
      (localRecent is! List || cloudRecent.length > localRecent.length)) {
    merged['recentScores'] = cloudRecent;
  } else if (localRecent is List) {
    merged['recentScores'] = localRecent;
    if (cloudRecent is! List || localRecent.length > cloudRecent.length) {
      localAhead = true;
    }
  }

  // Dates: keep the EARLIER first-played and the LATER last-played.
  final localFirst = _parseDate(local['firstPlayedDate']);
  final cloudFirst = _parseDate(cloud['firstPlayedDate']);
  if (cloudFirst != null &&
      (localFirst == null || cloudFirst.isBefore(localFirst))) {
    merged['firstPlayedDate'] = cloud['firstPlayedDate'];
  } else if (localFirst != null) {
    merged['firstPlayedDate'] = local['firstPlayedDate'];
    if (cloudFirst == null || localFirst.isBefore(cloudFirst)) {
      localAhead = true;
    }
  }

  final localLast = _parseDate(local['lastPlayedDate']);
  final cloudLast = _parseDate(cloud['lastPlayedDate']);
  if (cloudLast != null && (localLast == null || cloudLast.isAfter(localLast))) {
    merged['lastPlayedDate'] = cloud['lastPlayedDate'];
  } else if (localLast != null) {
    merged['lastPlayedDate'] = local['lastPlayedDate'];
    if (cloudLast == null || localLast.isAfter(cloudLast)) {
      localAhead = true;
    }
  }

  recomputeDerivedStats(merged);

  return StatisticsMergeResult(
    json: jsonEncode(merged),
    localAhead: localAhead,
  );
}

/// Recompute the fields that are functions of the folded base counters, so
/// a stale ratio never survives the merge. Mirrors
/// `SyncStatisticsCommandHandler.RecomputeDerivedFields`.
void recomputeDerivedStats(Map<String, dynamic> obj) {
  final totalGames = _asNum(obj['totalGamesPlayed'])?.toInt() ?? 0;
  final totalScore = _asNum(obj['totalScore'])?.toInt() ?? 0;
  final totalGameTime = _asNum(obj['totalGameTime'])?.toInt() ?? 0;
  final totalCollisions = _asNum(obj['totalCollisions'])?.toInt() ?? 0;
  final gamesSurvived30s = _asNum(obj['gamesSurvived30s'])?.toInt() ?? 0;
  final totalSessions = _asNum(obj['totalSessions'])?.toInt() ?? 0;
  final achievementsUnlocked = _asNum(obj['achievementsUnlocked'])?.toInt() ?? 0;
  final totalAchievements = _asNum(obj['totalAchievements'])?.toInt() ?? 0;

  obj['averageScore'] = totalGames > 0 ? totalScore / totalGames : 0.0;
  obj['averageGameTime'] =
      totalGames > 0 ? (totalGameTime / totalGames).round() : 0;
  obj['collisionRate'] = totalGames > 0 ? totalCollisions / totalGames : 0.0;
  obj['survivalRate'] = totalGames > 0 ? gamesSurvived30s / totalGames : 0.0;
  obj['achievementProgress'] =
      totalAchievements > 0 ? achievementsUnlocked / totalAchievements : 0.0;
  obj['averageGamesPerSession'] =
      totalSessions > 0 ? (totalGames / totalSessions).round() : totalGames;
}

Map<String, dynamic>? _decodeObject(String json) {
  if (json.trim().isEmpty) return <String, dynamic>{};
  final decoded = jsonDecode(json);
  return decoded is Map<String, dynamic> ? decoded : null;
}

/// Tolerant numeric read — the model JSON has been written by several
/// client versions and a counter can arrive as int, double, or a string.
num? _asNum(dynamic value) {
  if (value is num) return value;
  if (value is String) return num.tryParse(value);
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value is DateTime) return value;
  if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
  if (value is int) {
    return DateTime.fromMillisecondsSinceEpoch(value, isUtc: true);
  }
  return null;
}
