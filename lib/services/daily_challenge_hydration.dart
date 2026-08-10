/// Rules for turning the locally-persisted daily-challenge rows into the
/// in-memory list the UI renders, and for reconciling that list against a
/// backend refresh.
///
/// ## Why this exists
///
/// `DailyChallengeService.initialize()` used to be a documented no-op — the
/// in-memory list was populated *only* by a successful backend fetch. Drift
/// held today's rows the whole time (progress, completion, and claim state,
/// all written offline-first), but nothing ever read them back. So on any
/// launch where the backend was unreachable the challenges screen was empty,
/// and a completed-but-unclaimed challenge — a reward the player had already
/// earned — was invisible until the server came back.
///
/// Hydration is read-only by construction. Nothing here claims a reward,
/// marks a row claimed, or grants coins: it only decides what the player can
/// SEE. Claiming stays on its existing offline-first path (Drift write +
/// `dailyChallengeClaim` outbox row in one transaction, keyed on the
/// challenge id so a retry settles once), which means a challenge surfaced by
/// hydration can be claimed offline and the claim reaches the server on the
/// next drain.
///
/// Kept free of Drift and Flutter imports so the offline behaviour can be
/// tested without a native SQLite build — see `docs/TEST_GAPS.md` for why
/// that build isn't wired up.
library;

import 'package:snake_classic/models/daily_challenge.dart';

/// One persisted daily-challenge row, reduced to the fields these rules need.
/// The service adapts its Drift row into this; tests construct it directly.
class LocalChallengeRow {
  final String challengeId;
  final String challengeType;
  final String title;
  final String description;
  final int currentProgress;
  final int targetProgress;
  final int rewardCoins;
  final bool isCompleted;
  final bool rewardClaimed;
  final String? requiredGameMode;
  final int xpReward;
  final String? difficulty;

  const LocalChallengeRow({
    required this.challengeId,
    required this.challengeType,
    required this.title,
    required this.description,
    required this.currentProgress,
    required this.targetProgress,
    required this.rewardCoins,
    required this.isCompleted,
    required this.rewardClaimed,
    this.requiredGameMode,
    this.xpReward = 0,
    this.difficulty,
  });
}

/// The synthetic all-complete bonus is stored as a challenge row so the
/// existing claim outbox carries it, but it is not one of the day's
/// challenges and must never appear in the list.
const String kAllCompleteBonusIdPrefix = 'all_complete_bonus_';

/// Local-day-anchored id for the all-complete bonus row. A new day gets a new
/// id, so yesterday's bonus can't lock today's.
String allCompleteBonusIdFor(DateTime day) {
  final y = day.year.toString().padLeft(4, '0');
  final m = day.month.toString().padLeft(2, '0');
  final d = day.day.toString().padLeft(2, '0');
  return '$kAllCompleteBonusIdPrefix$y-$m-$d';
}

bool isAllCompleteBonusId(String id) => id.startsWith(kAllCompleteBonusIdPrefix);

/// Project a persisted row into the model the UI renders.
///
/// Every field the card renders is persisted as of v17. `requiredGameMode`
/// had to be, because it decides which games count toward the goal; `xpReward`
/// and `difficulty` because without them a hydrated card advertised "0 XP" and
/// "Easy" for every challenge — the screen misstating its own rewards.
DailyChallenge challengeFromLocalRow(LocalChallengeRow row) {
  return DailyChallenge(
    id: row.challengeId,
    title: row.title,
    description: row.description,
    type: ChallengeType.fromString(row.challengeType),
    difficulty: ChallengeDifficulty.fromString(row.difficulty ?? 'easy'),
    targetValue: row.targetProgress,
    currentProgress: row.currentProgress,
    // Claimed implies completed, and a row can be over target without the
    // flag if it was written by an older client.
    isCompleted: row.rewardClaimed ||
        row.isCompleted ||
        (row.targetProgress > 0 && row.currentProgress >= row.targetProgress),
    coinReward: row.rewardCoins,
    xpReward: row.xpReward,
    requiredGameMode: row.requiredGameMode,
    claimedReward: row.rewardClaimed,
  );
}

/// Today's challenges as persisted locally — what the player sees when the
/// backend can't be reached. Excludes the synthetic bonus row.
///
/// Order is stable (by challenge id) so a restart renders the same list in the
/// same order rather than whatever order the rows came back in.
List<DailyChallenge> hydrateFromLocalRows(Iterable<LocalChallengeRow> rows) {
  final challenges = [
    for (final row in rows)
      if (!isAllCompleteBonusId(row.challengeId)) challengeFromLocalRow(row),
  ];
  challenges.sort((a, b) => a.id.compareTo(b.id));
  return challenges;
}

/// Reconcile one backend challenge with its local row: MAX on the monotonic
/// progress (client-ahead offline gains win), OR on the absorbing-true
/// completed / claimed flags. Claimed implies completed.
///
/// The OR on `claimedReward` is what stops a refresh from resurrecting a
/// reward the player already took offline — the backend hasn't seen that claim
/// until the outbox drains, so it will keep reporting it unclaimed.
DailyChallenge mergeWithLocal(DailyChallenge backend, LocalChallengeRow? local) {
  if (local == null) return backend;
  final mergedProgress = local.currentProgress > backend.currentProgress
      ? local.currentProgress
      : backend.currentProgress;
  final mergedClaimed = backend.claimedReward || local.rewardClaimed;
  final mergedCompleted = mergedClaimed ||
      backend.isCompleted ||
      local.isCompleted ||
      (backend.targetValue > 0 && mergedProgress >= backend.targetValue);
  return backend.copyWith(
    currentProgress: mergedProgress,
    isCompleted: mergedCompleted,
    claimedReward: mergedClaimed,
  );
}

/// The list to show after a successful refresh: every backend challenge
/// reconciled with its local row, plus any local-only challenge that still
/// carries an unclaimed reward.
///
/// That last part matters. The backend list is normally the whole of today's
/// set, but if a challenge is missing from it — a partial response, a row this
/// device completed before the server recorded it — dropping it would take an
/// earned, unclaimed reward off the screen with no way to get it back. Rows
/// that are already claimed, or not yet complete, are left to the backend:
/// keeping those would be resurrecting state the server is entitled to own.
List<DailyChallenge> mergeBackendWithLocal(
  List<DailyChallenge> fromBackend,
  Map<String, LocalChallengeRow> localById,
) {
  final merged = [
    for (final c in fromBackend) mergeWithLocal(c, localById[c.id]),
  ];
  final seen = {for (final c in merged) c.id};

  final orphanedRewards = [
    for (final row in localById.values)
      if (!seen.contains(row.challengeId) &&
          !isAllCompleteBonusId(row.challengeId) &&
          row.isCompleted &&
          !row.rewardClaimed)
        challengeFromLocalRow(row),
  ]..sort((a, b) => a.id.compareTo(b.id));

  return [...merged, ...orphanedRewards];
}

/// Counts derived from a challenge list. `allCompleted` is false for an empty
/// list — nothing is "all complete" when there is nothing.
({int completed, int total, bool allCompleted}) countsFor(
  List<DailyChallenge> challenges,
) {
  final completed = challenges.where((c) => c.isCompleted).length;
  final total = challenges.length;
  return (
    completed: completed,
    total: total,
    allCompleted: total > 0 && completed == total,
  );
}
