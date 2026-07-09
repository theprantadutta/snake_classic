import 'package:snake_classic/models/position.dart';
import 'package:snake_classic/utils/direction.dart';

/// Server-authoritative snapshot of a live 1v1 match, broadcast on every
/// engine tick (`Tick`), inside `GameStarted.snapshot`, and inside
/// `MatchResumed.snapshot`. Clients render this verbatim — there is no
/// local simulation, collision detection, or scoring on the phone.
///
/// Wire format (snake_case, see MatchRoom.Snapshot() in the backend):
/// `{tick, tick_ms, elapsed_game_ms, food: [x,y], players: [...]}` with
/// each player's `body` as `[[x,y], ...]`, head first.
class MatchSnapshot {
  final int tick;

  /// Current server tick interval — the interpolation window for smooth
  /// rendering between this snapshot and the next.
  final int tickMs;
  final int elapsedGameMs;
  final Position food;
  final List<MatchPlayerState> players;

  const MatchSnapshot({
    required this.tick,
    required this.tickMs,
    required this.elapsedGameMs,
    required this.food,
    required this.players,
  });

  factory MatchSnapshot.fromJson(Map<String, dynamic> json) {
    return MatchSnapshot(
      tick: (json['tick'] as num?)?.toInt() ?? 0,
      tickMs: (json['tick_ms'] as num?)?.toInt() ?? 200,
      elapsedGameMs: (json['elapsed_game_ms'] as num?)?.toInt() ?? 0,
      food: _parseCell(json['food']) ?? const Position(0, 0),
      players: (json['players'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MatchPlayerState.fromJson)
          .toList(),
    );
  }

  MatchPlayerState? playerByUserId(String userId) {
    for (final p in players) {
      if (p.userId == userId) return p;
    }
    return null;
  }

  MatchPlayerState? playerByIndex(int index) {
    for (final p in players) {
      if (p.playerIndex == index) return p;
    }
    return null;
  }
}

/// One snake in a [MatchSnapshot].
class MatchPlayerState {
  final int playerIndex;
  final String userId;
  final String username;
  final bool alive;
  final bool connected;

  /// Direction committed by the server at this tick (not the locally
  /// echoed input intent).
  final Direction direction;
  final int score;

  /// wall | self | opponent | head_on | forfeit — null while alive.
  final String? deathReason;

  /// Head first, grid coordinates.
  final List<Position> body;

  const MatchPlayerState({
    required this.playerIndex,
    required this.userId,
    required this.username,
    required this.alive,
    required this.connected,
    required this.direction,
    required this.score,
    required this.deathReason,
    required this.body,
  });

  factory MatchPlayerState.fromJson(Map<String, dynamic> json) {
    return MatchPlayerState(
      playerIndex: (json['player_index'] as num?)?.toInt() ?? 0,
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? 'Player',
      alive: json['alive'] as bool? ?? true,
      connected: json['connected'] as bool? ?? true,
      direction: _parseDirection(json['direction']),
      score: (json['score'] as num?)?.toInt() ?? 0,
      deathReason: json['death_reason']?.toString(),
      body: (json['body'] as List? ?? [])
          .map(_parseCell)
          .whereType<Position>()
          .toList(),
    );
  }

  Position? get head => body.isNotEmpty ? body.first : null;
}

/// Parsed `GameEnded` payload — the match result the server persisted.
/// `winner_coin_reward` rides along so client and server agree on the
/// coin amount the client credits through the normal CoinsCubit path.
class MatchEndResult {
  /// last_alive | mutual_crash | timeout | aborted (snake_case enum).
  final String reason;

  /// Null means draw, regardless of [reason].
  final String? winnerUserId;
  final int winnerCoinReward;
  final List<MatchEndPlayer> players;

  const MatchEndResult({
    required this.reason,
    required this.winnerUserId,
    required this.winnerCoinReward,
    required this.players,
  });

  factory MatchEndResult.fromJson(Map<String, dynamic> json) {
    return MatchEndResult(
      reason: json['reason']?.toString() ?? '',
      winnerUserId: json['winner_user_id']?.toString(),
      winnerCoinReward: (json['winner_coin_reward'] as num?)?.toInt() ?? 0,
      players: (json['players'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MatchEndPlayer.fromJson)
          .toList(),
    );
  }

  bool get isDraw => winnerUserId == null;
  bool isWinner(String userId) => winnerUserId == userId;

  MatchEndPlayer? playerByUserId(String userId) {
    for (final p in players) {
      if (p.userId == userId) return p;
    }
    return null;
  }
}

/// Per-player final line in a [MatchEndResult].
class MatchEndPlayer {
  final int playerIndex;
  final String userId;
  final String username;
  final int score;
  final int foodsEaten;
  final bool alive;
  final String? deathReason;

  const MatchEndPlayer({
    required this.playerIndex,
    required this.userId,
    required this.username,
    required this.score,
    required this.foodsEaten,
    required this.alive,
    required this.deathReason,
  });

  factory MatchEndPlayer.fromJson(Map<String, dynamic> json) {
    return MatchEndPlayer(
      playerIndex: (json['player_index'] as num?)?.toInt() ?? 0,
      userId: json['user_id']?.toString() ?? '',
      username: json['username']?.toString() ?? 'Player',
      score: (json['score'] as num?)?.toInt() ?? 0,
      foodsEaten: (json['foods_eaten'] as num?)?.toInt() ?? 0,
      alive: json['alive'] as bool? ?? false,
      deathReason: json['death_reason']?.toString(),
    );
  }
}

/// `[x, y]` cell array → Position (the server sends bare int pairs).
Position? _parseCell(dynamic cell) {
  if (cell is List && cell.length >= 2) {
    final x = cell[0];
    final y = cell[1];
    if (x is num && y is num) return Position(x.toInt(), y.toInt());
  }
  return null;
}

Direction _parseDirection(dynamic value) {
  final name = value?.toString().toLowerCase();
  return Direction.values.firstWhere(
    (d) => d.name == name,
    orElse: () => Direction.right,
  );
}
