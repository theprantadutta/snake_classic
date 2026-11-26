import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_recovery.dart';
import 'package:snake_classic/presentation/bloc/multiplayer/multiplayer_state.dart';

import 'fake_multiplayer.dart';

void main() {
  group('acceptsSnapshot', () {
    test('a live or reconnecting match takes snapshots', () {
      for (final status in [
        MultiplayerStatus.playing,
        MultiplayerStatus.reconnecting,
        MultiplayerStatus.inLobby,
      ]) {
        expect(
          MultiplayerRecovery.acceptsSnapshot(
            status: status,
            hasMatchEnd: false,
            currentGameId: 'g2',
            endedGameId: 'g1',
          ),
          isTrue,
          reason: '$status',
        );
      }
    });

    test('a finished match, or one with its result, refuses them', () {
      expect(
        MultiplayerRecovery.acceptsSnapshot(
          status: MultiplayerStatus.finished,
          hasMatchEnd: false,
        ),
        isFalse,
      );
      expect(
        MultiplayerRecovery.acceptsSnapshot(
          status: MultiplayerStatus.playing,
          hasMatchEnd: true,
        ),
        isFalse,
      );
    });

    test('the game that ended refuses them whatever the status', () {
      expect(
        MultiplayerRecovery.acceptsSnapshot(
          status: MultiplayerStatus.idle,
          hasMatchEnd: false,
          currentGameId: 'g1',
          endedGameId: 'g1',
        ),
        isFalse,
      );
    });
  });

  test('afterSnapshot never un-finishes a match', () {
    final finished = const MultiplayerState().copyWith(
      status: MultiplayerStatus.finished,
      matchEnd: rivalWins(),
      snapshot: snapshotAt(1),
    );
    final after = MultiplayerRecovery.afterSnapshot(
      finished,
      snapshot: snapshotAt(2),
      boardSize: 20,
    );
    expect(after.status, MultiplayerStatus.finished);
    expect(after.snapshot?.tick, 1);
  });

  test('afterSnapshot still brings a reconnect back to playing', () {
    final reconnecting = const MultiplayerState().copyWith(
      status: MultiplayerStatus.reconnecting,
      errorCode: MultiplayerError.connectionLost,
    );
    final after = MultiplayerRecovery.afterSnapshot(
      reconnecting,
      snapshot: snapshotAt(3),
      boardSize: 20,
    );
    expect(after.status, MultiplayerStatus.playing);
    expect(after.errorCode, isNull);
  });
}
