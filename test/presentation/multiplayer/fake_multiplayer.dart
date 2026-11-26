import 'dart:async';

import 'package:snake_classic/models/match_snapshot.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement_service.dart';
import 'package:snake_classic/services/multiplayer_service.dart';
import 'package:snake_classic/services/unified_user_service.dart';
import 'package:snake_classic/utils/direction.dart';

/// Hand-rolled stand-ins for the multiplayer cubit's collaborators. The
/// streams are the hub: a test pushes what the server would have sent.

const kMe = 'me';
const kRival = 'rival';

class FakeMultiplayerService implements MultiplayerService {
  final matchmaking = StreamController<MatchmakingStatus>.broadcast();
  final errors = StreamController<MultiplayerError>.broadcast();
  final snapshots = StreamController<MatchSnapshot>.broadcast();
  final matchEnds = StreamController<MatchEndResult>.broadcast();
  final games = StreamController<MultiplayerGame?>.broadcast();
  final actions = StreamController<MultiplayerGameAction>.broadcast();

  MultiplayerGame? game;
  String? gameId;

  /// Answer for the next joinMatchmaking; defaults to joined at once.
  Future<JoinQueueOutcome> Function()? onJoinMatchmaking;
  bool leaveThrows = false;
  int queuePolls = 0;
  int leaveCalls = 0;

  /// Push a lobby/match update the way the hub handlers do.
  void pushGame(MultiplayerGame g) {
    game = g;
    gameId = g.id;
    games.add(g);
  }

  void pushAction(String type) => actions.add(
    MultiplayerGameAction(
      actionType: type,
      playerId: '',
      timestamp: DateTime(2026),
      data: const {},
    ),
  );

  @override
  Stream<MatchmakingStatus> get matchmakingStream => matchmaking.stream;
  @override
  Stream<MultiplayerError> get errorStream => errors.stream;
  @override
  Stream<MatchSnapshot> get snapshotStream => snapshots.stream;
  @override
  Stream<MatchEndResult> get matchEndStream => matchEnds.stream;
  @override
  Stream<MultiplayerGame?> get gameStream => games.stream;
  @override
  Stream<MultiplayerGameAction> get gameActionsStream => actions.stream;

  @override
  MultiplayerGame? get currentGame => game;
  @override
  String? get currentGameId => gameId;
  @override
  String? get currentRoomCode => 'ABCDEF';
  @override
  int get boardSize => 20;

  @override
  Future<JoinQueueOutcome> joinMatchmaking({
    required MultiplayerGameMode mode,
    required int playerCount,
  }) => onJoinMatchmaking?.call() ?? Future.value(JoinQueueOutcome.joined);

  @override
  Future<void> leaveMatchmaking() async {}

  @override
  Future<void> leaveGame() async {
    leaveCalls++;
    if (leaveThrows) throw StateError('hub exploded');
    game = null;
    gameId = null;
  }

  @override
  Future<Map<String, dynamic>?> fetchQueueStatus() async {
    queuePolls++;
    return {'state': 'queued'};
  }

  @override
  bool applyPolledQueueStatus(Map<String, dynamic> status) => false;

  @override
  Future<bool> markPlayerReady({bool isReady = true}) async => true;

  @override
  Future<Duration?> sendInput(Direction direction) async => null;

  @override
  void dispose() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeUserService implements UnifiedUserService {
  @override
  UnifiedUser? get currentUser => UnifiedUser(
    uid: kMe,
    userType: UserType.google,
    username: 'me',
    displayName: 'Me',
    createdAt: DateTime(2026),
    lastSeen: DateTime(2026),
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeAudio implements AudioService {
  @override
  void playSound(
    String soundName, {
    double volume = 1.0,
    double playbackRate = 1.0,
  }) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeHaptics implements HapticService {
  @override
  Future<void> lightImpact() async {}
  @override
  Future<void> mediumImpact() async {}
  @override
  Future<void> heavyImpact() async {}
  @override
  Future<void> selectionClick() async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class FakeSettlementService implements MultiplayerSettlementService {
  final applied = StreamController<MultiplayerSettlement>.broadcast();
  int syncCalls = 0;

  @override
  Stream<MultiplayerSettlement> get appliedStream => applied.stream;

  @override
  Future<int> syncPending() async {
    syncCalls++;
    return 0;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class Harness {
  final service = FakeMultiplayerService();
  final settlement = FakeSettlementService();
  late final MultiplayerCubit cubit = MultiplayerCubit(
    multiplayerService: service,
    userService: FakeUserService(),
    audioService: FakeAudio(),
    hapticService: FakeHaptics(),
    analytics: AnalyticsFacade(const []),
    settlementService: settlement,
  );
}

MultiplayerGame lobbyGame({
  String id = 'g1',
  bool meReady = false,
  bool rivalReady = false,
  MultiplayerGameStatus status = MultiplayerGameStatus.waiting,
}) => MultiplayerGame(
  id: id,
  mode: MultiplayerGameMode.classic,
  status: status,
  players: [
    MultiplayerPlayer(
      userId: kRival,
      displayName: 'Rival',
      status: rivalReady ? PlayerStatus.ready : PlayerStatus.waiting,
      rank: 0,
    ),
    MultiplayerPlayer(
      userId: kMe,
      displayName: 'Me',
      status: meReady ? PlayerStatus.ready : PlayerStatus.waiting,
      rank: 1,
    ),
  ],
  roomCode: 'ABCDEF',
  createdAt: DateTime(2026),
);

MatchSnapshot snapshotAt(int tick, {bool meAlive = true}) =>
    MatchSnapshot.fromJson({
      'tick': tick,
      'tick_ms': 200,
      'elapsed_game_ms': tick * 200,
      'food': [5, 5],
      'players': [
        {
          'player_index': 0,
          'user_id': kRival,
          'alive': true,
          'direction': 'left',
          'body': [
            [15, 10],
            [16, 10],
          ],
        },
        {
          'player_index': 1,
          'user_id': kMe,
          'alive': meAlive,
          'direction': 'right',
          'body': [
            [4 + tick, 10],
            [3 + tick, 10],
          ],
        },
      ],
    });

MatchEndResult rivalWins() => MatchEndResult.fromJson({
  'reason': 'last_alive',
  'winner_user_id': kRival,
  'winner_coin_reward': 10,
  'players': [
    {'player_index': 0, 'user_id': kRival, 'score': 30, 'alive': true},
    {
      'player_index': 1,
      'user_id': kMe,
      'score': 10,
      'alive': false,
      'death_reason': 'wall',
    },
  ],
});
