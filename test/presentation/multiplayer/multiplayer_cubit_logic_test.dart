import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/multiplayer_game.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_cubit.dart';
import 'package:snake_classic/services/multiplayer_service.dart';

import 'fake_multiplayer.dart';

/// Versus lobby/match logic found broken against production on two real
/// devices (2026-11-26). Each group is one of those bugs.
void main() {
  /// Matchmade lobby with [game] already known to the service.
  Harness matchmadeLobby(FakeAsync async, {MultiplayerGame? game}) {
    final h = Harness();
    h.service.game = game ?? lobbyGame();
    h.service.gameId = h.service.game!.id;
    h.cubit; // construct: subscribes to the hub streams
    h.service.matchmaking.add(
      const MatchmakingStatus(matchFound: true, gameId: 'g1'),
    );
    async.flushMicrotasks();
    return h;
  }

  /// A live match: lobby, GameStarted, first Tick.
  Harness liveMatch(FakeAsync async) {
    final h = matchmadeLobby(async);
    h.service.pushGame(
      lobbyGame(status: MultiplayerGameStatus.playing),
    );
    h.service.snapshots.add(snapshotAt(1));
    async.flushMicrotasks();
    return h;
  }

  group('ready deadline', () {
    test('stops once everyone is ready and resumes on un-ready', () {
      fakeAsync((async) {
        final h = matchmadeLobby(async);
        expect(h.cubit.state.status, MultiplayerStatus.inLobby);
        expect(h.cubit.state.readyDeadlineSeconds, 30);

        async.elapse(const Duration(seconds: 10));
        expect(h.cubit.state.readyDeadlineSeconds, 20);

        // Both ready (production: 23 s in). The READY clock is over.
        h.service.pushGame(lobbyGame(meReady: true, rivalReady: true));
        async.flushMicrotasks();
        expect(h.cubit.state.readyDeadlineSeconds, isNull);
        expect(
          h.cubit.state.hostStartDeadlineSeconds,
          MultiplayerCubit.hostStartDeadlineSeconds,
        );
        expect(h.cubit.state.isWaitingForHostStart, isTrue);

        // Well past the old 30 s cut-off: nobody is kicked.
        async.elapse(const Duration(seconds: 25));
        expect(h.cubit.state.status, MultiplayerStatus.inLobby);
        expect(h.cubit.state.errorCode, isNull);
        expect(h.cubit.state.hostStartDeadlineSeconds, 15);

        // Rival un-readies: READY resumes with what it had left.
        h.service.pushGame(lobbyGame(meReady: true));
        async.flushMicrotasks();
        expect(h.cubit.state.readyDeadlineSeconds, 20);
        expect(h.cubit.state.hostStartDeadlineSeconds, isNull);

        async.elapse(const Duration(seconds: 19));
        expect(h.cubit.state.status, MultiplayerStatus.inLobby);
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();
        expect(h.cubit.state.status, MultiplayerStatus.idle);
        expect(h.cubit.state.errorCode, MultiplayerError.readyTimeout);
        expect(h.service.leaveCalls, 1);
        expect(h.analytics.named('versus_lobby_closed'), [
          {'reason': 'ready_timeout'},
        ]);
      });
    });

    test('host who never presses START ends it with hostDidNotStart', () {
      fakeAsync((async) {
        final h = matchmadeLobby(async);
        h.service.pushGame(lobbyGame(meReady: true, rivalReady: true));
        async.flushMicrotasks();

        async.elapse(
          const Duration(seconds: MultiplayerCubit.hostStartDeadlineSeconds - 1),
        );
        expect(h.cubit.state.status, MultiplayerStatus.inLobby);
        async.elapse(const Duration(seconds: 1));
        async.flushMicrotasks();

        expect(h.cubit.state.status, MultiplayerStatus.idle);
        expect(h.cubit.state.errorCode, MultiplayerError.hostDidNotStart);
        expect(h.cubit.state.hostStartDeadlineSeconds, isNull);
        expect(h.cubit.state.currentGame, isNull);
        expect(h.analytics.named('versus_lobby_closed'), [
          {'reason': 'host_did_not_start'},
        ]);
      });
    });

    test('the countdown starting stops both clocks', () {
      fakeAsync((async) {
        final h = matchmadeLobby(async);
        h.service.pushGame(lobbyGame(meReady: true, rivalReady: true));
        h.service.pushGame(
          lobbyGame(
            meReady: true,
            rivalReady: true,
            status: MultiplayerGameStatus.starting,
          ),
        );
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 2));
        h.service.pushGame(lobbyGame(status: MultiplayerGameStatus.playing));
        async.flushMicrotasks();

        async.elapse(const Duration(seconds: 120));
        expect(h.cubit.state.status, MultiplayerStatus.playing);
        expect(h.cubit.state.errorCode, isNull);
      });
    });
  });

  group('matchmaking race', () {
    test('a join that returns after MatchFound cannot regress the lobby', () {
      fakeAsync((async) {
        final h = Harness();
        h.service.game = lobbyGame();
        h.service.gameId = 'g1';
        final join = Completer<JoinQueueOutcome>();
        h.service.onJoinMatchmaking = () => join.future;

        final statuses = <MultiplayerStatus>[];
        h.cubit.stream.listen((s) => statuses.add(s.status));

        bool? result;
        h.cubit
            .quickMatch(MultiplayerGameMode.classic)
            .then((r) => result = r);
        async.flushMicrotasks();

        // The server pushes MatchFound from inside JoinMatchmaking...
        h.service.matchmaking.add(
          const MatchmakingStatus(matchFound: true, gameId: 'g1'),
        );
        async.flushMicrotasks();
        expect(h.cubit.state.status, MultiplayerStatus.inLobby);

        // ...then the join's own "searching" report and its return land.
        h.service.matchmaking.add(const MatchmakingStatus(isSearching: true));
        join.complete(JoinQueueOutcome.joined);
        async.flushMicrotasks();

        expect(result, isTrue);
        expect(h.cubit.state.status, MultiplayerStatus.inLobby);
        expect(h.cubit.state.isMatchmaking, isFalse);
        expect(h.cubit.state.isLoading, isFalse);
        expect(
          statuses.skipWhile((s) => s != MultiplayerStatus.inLobby),
          everyElement(MultiplayerStatus.inLobby),
          reason: 'nothing after the match may say "searching"',
        );

        // No search watch for a match that already exists.
        async.elapse(const Duration(seconds: 10));
        expect(h.service.queuePolls, 0);
        expect(h.cubit.state.status, MultiplayerStatus.inLobby);
      });
    });

    test('the service reporting matched is honoured too', () {
      fakeAsync((async) {
        final h = Harness();
        h.service.onJoinMatchmaking =
            () async => JoinQueueOutcome.matched;
        bool? result;
        h.cubit
            .quickMatch(MultiplayerGameMode.classic)
            .then((r) => result = r);
        async.flushMicrotasks();
        expect(result, isTrue);
        expect(h.cubit.state.status, isNot(MultiplayerStatus.inMatchmaking));
        expect(h.cubit.state.errorCode, isNull);
        async.elapse(const Duration(seconds: 6));
        expect(h.service.queuePolls, 0);
      });
    });

    test('an ordinary join still searches and polls', () {
      fakeAsync((async) {
        final h = Harness();
        h.cubit.quickMatch(MultiplayerGameMode.classic);
        async.flushMicrotasks();
        expect(h.cubit.state.status, MultiplayerStatus.inMatchmaking);
        async.elapse(const Duration(seconds: 4));
        expect(h.service.queuePolls, greaterThan(0));
        h.cubit.cancelMatchmaking();
        async.flushMicrotasks();
      });
    });
  });

  group('late snapshot', () {
    test('a Tick after GameEnded does not reopen the match', () {
      fakeAsync((async) {
        final h = liveMatch(async);
        expect(h.cubit.state.status, MultiplayerStatus.playing);
        expect(h.cubit.canSteer, isTrue);

        h.service.matchEnds.add(rivalWins());
        async.flushMicrotasks();
        expect(h.cubit.state.status, MultiplayerStatus.finished);
        final quality = h.analytics.named('versus_match_quality').single;
        expect(quality['result'], 'loss');
        expect(quality.keys, containsAll(
          ['rtt_ms', 'late_snapshots', 'max_gap_ms', 'correction_pct'],
        ));

        h.service.snapshots.add(snapshotAt(2));
        async.flushMicrotasks();
        expect(h.cubit.state.status, MultiplayerStatus.finished);
        expect(h.cubit.state.snapshot?.tick, 1);
        expect(h.cubit.state.matchEnd, isNotNull);
        expect(h.cubit.canSteer, isFalse);
      });
    });

    test('the finished game update arriving after the result changes nothing',
        () {
      fakeAsync((async) {
        final h = liveMatch(async);
        h.service.matchEnds.add(rivalWins());
        h.service.pushGame(lobbyGame(status: MultiplayerGameStatus.finished));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10));
        expect(h.cubit.state.status, MultiplayerStatus.finished);
        expect(h.cubit.state.matchEnd, isNotNull);
        expect(h.cubit.state.errorCode, isNull);
      });
    });
  });

  group('finished without a result', () {
    test('the watchdog leaves a result-less finish', () {
      fakeAsync((async) {
        final h = liveMatch(async);
        final syncsBefore = h.settlement.syncCalls;
        h.service.pushGame(lobbyGame(status: MultiplayerGameStatus.finished));
        async.flushMicrotasks();
        expect(h.cubit.state.status, MultiplayerStatus.finished);
        expect(h.cubit.state.matchEnd, isNull);

        async.elapse(MultiplayerCubit.matchEndWatchdogDelay);
        expect(h.cubit.state.status, MultiplayerStatus.idle);
        expect(h.cubit.state.errorCode, MultiplayerError.matchEndedAway);
        expect(h.settlement.syncCalls, greaterThan(syncsBefore));

        // And a straggling Tick for that game cannot bring it back.
        h.service.gameId = 'g1';
        h.service.snapshots.add(snapshotAt(9));
        async.flushMicrotasks();
        expect(h.cubit.state.status, MultiplayerStatus.idle);
      });
    });

    test('a result that arrives in time disarms it', () {
      fakeAsync((async) {
        final h = liveMatch(async);
        h.service.pushGame(lobbyGame(status: MultiplayerGameStatus.finished));
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 1));
        h.service.matchEnds.add(rivalWins());
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 10));
        expect(h.cubit.state.status, MultiplayerStatus.finished);
        expect(h.cubit.state.matchEnd, isNotNull);
      });
    });
  });

  group('connection drop mid-match', () {
    test('shows reconnecting, and a finished room ends it at once', () {
      fakeAsync((async) {
        final h = liveMatch(async);
        h.service.pushAction('connection_reconnecting');
        async.flushMicrotasks();
        expect(h.cubit.state.status, MultiplayerStatus.reconnecting);
        expect(h.cubit.canSteer, isFalse);

        h.service.pushAction('connection_restored');
        h.service.pushAction('reconnect_failed');
        async.flushMicrotasks();
        expect(h.cubit.state.status, MultiplayerStatus.idle);
        expect(h.cubit.state.errorCode, MultiplayerError.matchEndedAway);
        expect(
          h.analytics.named('versus_connection').map((e) => e['stage']),
          ['reconnecting', 'ended_away'],
        );
      });
    });

    test('a resumed match goes back to playing', () {
      fakeAsync((async) {
        final h = liveMatch(async);
        h.service.pushAction('connection_reconnecting');
        h.service.pushAction('connection_restored');
        async.flushMicrotasks();
        h.service.snapshots.add(snapshotAt(5));
        async.flushMicrotasks();
        expect(h.cubit.state.status, MultiplayerStatus.playing);
        async.elapse(const Duration(seconds: 30));
        expect(h.cubit.state.status, MultiplayerStatus.playing);
        expect(
          h.analytics.named('versus_connection').map((e) => e['stage']),
          ['reconnecting', 'recovered'],
        );
      });
    });

    test('an answer that never comes times out', () {
      fakeAsync((async) {
        final h = liveMatch(async);
        h.service.pushAction('connection_reconnecting');
        h.service.pushAction('connection_restored');
        async.flushMicrotasks();
        async.elapse(const Duration(seconds: 13));
        expect(h.cubit.state.status, MultiplayerStatus.idle);
        expect(h.cubit.state.errorCode, MultiplayerError.connectionLost);
      });
    });
  });

  group('leaveGame', () {
    test('clears the match even when the server call fails', () {
      fakeAsync((async) {
        final h = liveMatch(async);
        h.service.matchEnds.add(rivalWins());
        async.flushMicrotasks();
        expect(h.cubit.state.matchEnd, isNotNull);

        h.service.leaveThrows = true;
        h.cubit.leaveGame();
        async.flushMicrotasks();

        final s = h.cubit.state;
        expect(s.status, MultiplayerStatus.idle);
        expect(s.matchEnd, isNull);
        expect(s.snapshot, isNull);
        expect(s.currentGame, isNull);
        expect(s.settlementStatus, SettlementStatus.none);
        expect(s.errorCode, MultiplayerError.generic);
      });
    });
  });

  test('currentUserId is the identity the cubit judges by', () {
    final h = Harness();
    expect(h.cubit.currentUserId, kMe);
  });
}
