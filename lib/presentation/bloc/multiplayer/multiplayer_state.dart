import 'package:equatable/equatable.dart';
import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/models/multiplayer_error.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/utils/direction.dart';

export 'package:snake_classic/models/multiplayer_error.dart';

/// Status of the multiplayer cubit
enum MultiplayerStatus {
  initial,
  loading,
  idle,
  inMatchmaking, // Searching for opponents
  inLobby,
  playing,
  reconnecting, // Attempting to reconnect
  finished,
  error,
}

/// State class for MultiplayerCubit
/// Where this match's rewards have got to.
///
/// Rewards are decided by the server and fetched, so between the result
/// arriving and the settlement landing there is a real gap. Saying
/// "processing" during it is honest; showing a number the client made up —
/// which is what the old broadcast-driven credit did — was not.
enum SettlementStatus {
  /// Nothing owed, or no match has ended yet.
  none,

  /// The result is in and the settlement has not been applied yet.
  processing,

  /// Applied. [MultiplayerState.settlement] holds what was awarded.
  applied,
}

class MultiplayerState extends Equatable {
  final MultiplayerStatus status;
  final MultiplayerGame? currentGame;

  /// Stable error code resolved to a localized message at render time
  /// (see MultiplayerErrorL10n.localizedMessage). State never carries
  /// user-facing English.
  final MultiplayerError? errorCode;
  final bool isLoading;

  // Server-authoritative match state. [snapshot] is the latest engine
  // tick (also the GameStarted/MatchResumed payload); the client renders
  // it verbatim — no local simulation. [matchEnd] is the parsed
  // GameEnded result, set exactly once per match.
  final MatchSnapshot? snapshot;
  final MatchEndResult? matchEnd;
  final int boardSize;

  /// Where this match's rewards have got to. The result screen shows
  /// "processing" until the server's settlement lands, rather than a number
  /// the client invented.
  final SettlementStatus settlementStatus;

  /// What the server actually awarded, once applied.
  final MultiplayerSettlement? settlement;

  /// Local input echo: the direction we last sent to the server, shown
  /// on the swipe indicator until a snapshot confirms (or overrides) it.
  final Direction? intentDirection;

  /// Countdown length announced by the server's GameStarting payload —
  /// drives the lobby countdown overlay so client and server can't drift.
  final int countdownSeconds;

  /// Seconds left on the matchmade READY check, or null when no deadline
  /// is running.
  ///
  /// Only matchmade lobbies arm this. A friend room can sit open as long
  /// as its members like — they know each other and can talk. Two matched
  /// strangers cannot, so without a deadline one of them tabbing away
  /// leaves the other staring at a lobby that will never start. At zero
  /// the room is abandoned and the waiting player goes back to the queue.
  final int? readyDeadlineSeconds;

  /// True while this lobby came from matchmaking rather than a room code.
  /// The two paths differ in what the lobby is allowed to do to you: only
  /// a matchmade one expires.
  final bool isMatchmadeLobby;

  // Matchmaking state
  final bool isMatchmaking;
  final int matchmakingQueuePosition;
  final int matchmakingEstimatedWait;
  final MultiplayerGameMode? matchmakingMode;
  final int? matchmakingPlayerCount;
  final int matchmakingElapsedSeconds;

  /// The deadline the SERVER promises to resolve the queue by, in seconds
  /// from joining it. Comes from the queue-status response; the fallback here
  /// only matters before the first poll lands.
  ///
  /// The client no longer runs a deadline of its own. It used to count down
  /// from 60 and then declare "no players found", which was wrong twice over:
  /// an empty queue is not a failure (the server seats a house opponent), and
  /// the client giving up while the server was still working is how a match
  /// that had already been created went unclaimed.
  final int matchmakingDeadlineSeconds;
  final bool matchmakingUnreachable;

  const MultiplayerState({
    this.status = MultiplayerStatus.initial,
    this.currentGame,
    this.errorCode,
    this.isLoading = false,
    this.snapshot,
    this.matchEnd,
    this.boardSize = 20,
    this.intentDirection,
    this.countdownSeconds = 3,
    this.readyDeadlineSeconds,
    this.isMatchmadeLobby = false,
    this.isMatchmaking = false,
    this.matchmakingQueuePosition = 0,
    this.matchmakingEstimatedWait = 0,
    this.matchmakingMode,
    this.matchmakingPlayerCount,
    this.matchmakingElapsedSeconds = 0,
    this.matchmakingDeadlineSeconds = 35,
    this.matchmakingUnreachable = false,
    this.settlementStatus = SettlementStatus.none,
    this.settlement,
  });

  /// Initial state
  factory MultiplayerState.initial() => const MultiplayerState();

  /// Create a copy with updated values
  MultiplayerState copyWith({
    MultiplayerStatus? status,
    MultiplayerGame? currentGame,
    MultiplayerError? errorCode,
    bool? isLoading,
    bool clearGame = false,
    bool clearError = false,
    MatchSnapshot? snapshot,
    MatchEndResult? matchEnd,
    int? boardSize,
    SettlementStatus? settlementStatus,
    MultiplayerSettlement? settlement,
    Direction? intentDirection,
    bool clearIntentDirection = false,
    int? countdownSeconds,
    int? readyDeadlineSeconds,
    bool clearReadyDeadline = false,
    bool? isMatchmadeLobby,
    bool clearMatch = false,
    bool? isMatchmaking,
    int? matchmakingQueuePosition,
    int? matchmakingEstimatedWait,
    MultiplayerGameMode? matchmakingMode,
    int? matchmakingPlayerCount,
    int? matchmakingElapsedSeconds,
    int? matchmakingDeadlineSeconds,
    bool? matchmakingUnreachable,
    bool clearMatchmaking = false,
  }) {
    return MultiplayerState(
      status: status ?? this.status,
      currentGame: clearGame ? null : (currentGame ?? this.currentGame),
      errorCode: clearError ? null : (errorCode ?? this.errorCode),
      isLoading: isLoading ?? this.isLoading,
      snapshot: (clearMatch || clearGame) ? null : (snapshot ?? this.snapshot),
      matchEnd: (clearMatch || clearGame) ? null : (matchEnd ?? this.matchEnd),
      boardSize: boardSize ?? this.boardSize,
      settlementStatus: settlementStatus ?? this.settlementStatus,
      settlement: settlement ?? this.settlement,
      intentDirection: (clearMatch || clearGame || clearIntentDirection)
          ? null
          : (intentDirection ?? this.intentDirection),
      countdownSeconds: countdownSeconds ?? this.countdownSeconds,
      readyDeadlineSeconds: (clearReadyDeadline || clearGame)
          ? null
          : (readyDeadlineSeconds ?? this.readyDeadlineSeconds),
      isMatchmadeLobby: clearGame
          ? false
          : (isMatchmadeLobby ?? this.isMatchmadeLobby),
      isMatchmaking: clearMatchmaking
          ? false
          : (isMatchmaking ?? this.isMatchmaking),
      matchmakingQueuePosition: clearMatchmaking
          ? 0
          : (matchmakingQueuePosition ?? this.matchmakingQueuePosition),
      matchmakingEstimatedWait: clearMatchmaking
          ? 0
          : (matchmakingEstimatedWait ?? this.matchmakingEstimatedWait),
      matchmakingMode: clearMatchmaking
          ? null
          : (matchmakingMode ?? this.matchmakingMode),
      matchmakingPlayerCount: clearMatchmaking
          ? null
          : (matchmakingPlayerCount ?? this.matchmakingPlayerCount),
      matchmakingDeadlineSeconds:
          matchmakingDeadlineSeconds ?? this.matchmakingDeadlineSeconds,
      matchmakingElapsedSeconds: clearMatchmaking
          ? 0
          : (matchmakingElapsedSeconds ?? this.matchmakingElapsedSeconds),
      matchmakingUnreachable: clearMatchmaking
          ? false
          : (matchmakingUnreachable ?? this.matchmakingUnreachable),
    );
  }

  /// Whether user is currently in a game
  bool get isInGame => currentGame != null;

  /// Whether game can be started
  bool get canStartGame => currentGame?.canStart ?? false;

  /// Whether user is waiting for players
  bool get isWaitingForPlayers =>
      currentGame?.status == MultiplayerGameStatus.waiting &&
      !(currentGame?.isFull ?? true);

  /// Whether game is ready to start
  bool get isReadyToStart => currentGame?.canStart ?? false;

  /// Whether game is actively playing
  bool get isGameActive => currentGame?.status == MultiplayerGameStatus.playing;

  /// Whether game is finished
  bool get isGameFinished => currentGame?.isFinished ?? false;

  /// Game room code formatted for display
  String? get formattedRoomCode {
    final code = currentGame?.roomCode;
    if (code == null) return null;

    // Format as XXX-XXX
    if (code.length == 6) {
      return '${code.substring(0, 3)}-${code.substring(3)}';
    }
    return code;
  }

  /// Get game duration
  Duration? get gameDuration {
    if (currentGame?.startedAt == null) return null;
    return DateTime.now().difference(currentGame!.startedAt!);
  }

  @override
  List<Object?> get props => [
    status,
    currentGame,
    errorCode,
    isLoading,
    snapshot,
    matchEnd,
    settlementStatus,
    settlement,
    boardSize,
    intentDirection,
    countdownSeconds,
    readyDeadlineSeconds,
    isMatchmadeLobby,
    isMatchmaking,
    matchmakingQueuePosition,
    matchmakingEstimatedWait,
    matchmakingMode,
    matchmakingPlayerCount,
    matchmakingElapsedSeconds,
    matchmakingDeadlineSeconds,
    matchmakingUnreachable,
  ];
}
