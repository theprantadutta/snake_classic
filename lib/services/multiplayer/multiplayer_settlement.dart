/// A match reward as the server decided it, and the rule for which ones this
/// device still has to apply.
///
/// Multiplayer rewards used to exist only as a client reaction to the
/// `GameEnded` broadcast: whoever received it credited their own coins, XP and
/// statistics. A socket that died in that instant lost all of it, and nothing
/// on the server knew anything was owed — reconnecting to a finished match is
/// refused, so there was no way back to it either.
///
/// Now the server records what each player is owed and the client fetches,
/// applies, and acknowledges. Acknowledgement alone cannot make that
/// exactly-once, because the app can die between applying and acknowledging
/// and the next fetch would hand back the same row. The local ledger
/// (`applied_multiplayer_settlements`) is the other half: applied locally
/// first, acknowledged remotely second, so a crash in between costs an extra
/// round trip rather than a double payout.
///
/// Pure and dependency-free so the exactly-once rule can be tested without a
/// server, a database, or a socket.
library;

/// One settlement, as `GET /multiplayer/settlements/pending` returns it.
class MultiplayerSettlement {
  final String id;
  final String gameId;

  /// 'Win' | 'Loss' | 'Draw'.
  final String result;
  final int coinsAwarded;
  final int battlePassXpAwarded;
  final int score;
  final int foodsEaten;
  final int durationSeconds;
  final bool survivedToEnd;
  final String? deathReason;

  /// Why the match ended. `ServerInterrupted` marks a match the server lost —
  /// those settle for nothing, and exist so the player learns what happened.
  final String endReason;
  final int ratingDelta;
  final int ratingAfter;
  final bool versusBot;

  const MultiplayerSettlement({
    required this.id,
    required this.gameId,
    required this.result,
    required this.coinsAwarded,
    required this.battlePassXpAwarded,
    required this.score,
    required this.foodsEaten,
    required this.durationSeconds,
    required this.survivedToEnd,
    required this.deathReason,
    required this.endReason,
    required this.ratingDelta,
    required this.ratingAfter,
    required this.versusBot,
  });

  bool get isWin => result.toLowerCase() == 'win';

  /// True when the server never reached a verdict. Nothing is paid; the row
  /// exists so the client can say so.
  bool get wasInterrupted => endReason.toLowerCase() == 'serverinterrupted';

  /// Parse one row. Returns null rather than throwing on a malformed entry —
  /// one bad row must not block every other reward in the batch.
  static MultiplayerSettlement? fromJson(Map<String, dynamic> json) {
    final id = (json['id'] ?? json['Id'])?.toString();
    if (id == null || id.isEmpty) return null;

    int intOf(String snake, String camel) =>
        (json[snake] ?? json[camel] as Object?) is num
            ? ((json[snake] ?? json[camel]) as num).toInt()
            : 0;

    return MultiplayerSettlement(
      id: id,
      gameId: (json['game_id'] ?? json['gameId'] ?? '').toString(),
      result: (json['result'] ?? json['Result'] ?? 'Draw').toString(),
      coinsAwarded: intOf('coins_awarded', 'coinsAwarded'),
      battlePassXpAwarded: intOf('battle_pass_xp_awarded', 'battlePassXpAwarded'),
      score: intOf('score', 'Score'),
      foodsEaten: intOf('foods_eaten', 'foodsEaten'),
      durationSeconds: intOf('duration_seconds', 'durationSeconds'),
      survivedToEnd:
          (json['survived_to_end'] ?? json['survivedToEnd']) == true,
      deathReason: (json['death_reason'] ?? json['deathReason'])?.toString(),
      endReason: (json['end_reason'] ?? json['endReason'] ?? '').toString(),
      ratingDelta: intOf('rating_delta', 'ratingDelta'),
      ratingAfter: intOf('rating_after', 'ratingAfter'),
      versusBot: (json['versus_bot'] ?? json['versusBot']) == true,
    );
  }

  static List<MultiplayerSettlement> parseAll(List<Map<String, dynamic>> rows) {
    final parsed = <MultiplayerSettlement>[];
    for (final row in rows) {
      final settlement = fromJson(row);
      if (settlement != null) parsed.add(settlement);
    }
    return parsed;
  }
}

/// What to do with a fetched batch: which rows still need applying, and which
/// need acknowledging.
class SettlementPlan {
  /// Rows to apply now — fetched, and not in the local applied ledger.
  final List<MultiplayerSettlement> toApply;

  /// Every fetched id. All of them get acknowledged, including ones already
  /// applied locally: an id in the ledger but still pending on the server is
  /// exactly the crash-between-steps case, and re-acknowledging is how it
  /// stops coming back.
  final List<String> toAcknowledge;

  const SettlementPlan({required this.toApply, required this.toAcknowledge});

  bool get isEmpty => toApply.isEmpty && toAcknowledge.isEmpty;
}

/// Decide what to do with [fetched] given the ids this device has already
/// applied.
///
/// Deliberately pure: this is the exactly-once rule, and it is the part worth
/// proving.
SettlementPlan planSettlements({
  required List<MultiplayerSettlement> fetched,
  required Set<String> alreadyApplied,
}) {
  final toApply = <MultiplayerSettlement>[];
  final toAcknowledge = <String>[];
  final seen = <String>{};

  for (final settlement in fetched) {
    // A server that returns the same row twice in one batch must not pay it
    // twice either.
    if (!seen.add(settlement.id)) continue;

    toAcknowledge.add(settlement.id);
    if (!alreadyApplied.contains(settlement.id)) {
      toApply.add(settlement);
    }
  }

  return SettlementPlan(toApply: toApply, toAcknowledge: toAcknowledge);
}
