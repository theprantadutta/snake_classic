import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement_service.dart';
import 'package:snake_classic/services/multiplayer/settlement_ledger.dart';

import 'settlement_applier_test.dart' show FakeLedger, FakeSink;

/// A scripted transport. Records what was acknowledged, so a settlement being
/// acknowledged before it was fully applied is visible.
class FakeApi implements SettlementApi {
  FakeApi(this.rows);

  List<Map<String, dynamic>>? rows;
  int fetches = 0;
  final List<List<String>> acks = [];

  @override
  Future<List<Map<String, dynamic>>?> fetchPending() async {
    fetches++;
    return rows;
  }

  @override
  Future<bool> acknowledge(List<String> settlementIds) async {
    acks.add(List.of(settlementIds));
    return true;
  }

  List<String> get allAcked => acks.expand((a) => a).toList();
}

Map<String, dynamic> row({String id = 's1', int coins = 25, int xp = 20}) => {
      'id': id,
      'game_id': 'g1',
      'result': 'Win',
      'coins_awarded': coins,
      'battle_pass_xp_awarded': xp,
      'score': 120,
      'foods_eaten': 12,
      'duration_seconds': 95,
      'survived_to_end': true,
      'death_reason': null,
      'end_reason': 'LastAlive',
      'rating_delta': 16,
      'rating_after': 1016,
      'versus_bot': false,
    };

MultiplayerSettlementService newService({
  required FakeApi api,
  required FakeLedger ledger,
  required FakeSink sink,
}) {
  return MultiplayerSettlementService(
    // No database or pipeline: the ledger and sink are injected instead.
    api: api,
    ledger: ledger,
    rewardSink: sink,
  );
}

void main() {
  test('a fully applied settlement is acknowledged', () async {
    final api = FakeApi([row()]);
    final ledger = FakeLedger();
    final sink = FakeSink();

    final applied =
        await newService(api: api, ledger: ledger, sink: sink).syncPending();

    expect(applied, 1);
    expect(api.allAcked, ['s1']);
  });

  test(
    'a settlement whose coin grant failed is NOT acknowledged',
    () async {
      // The core rule: acknowledging tells the server to stop offering it. Do
      // that with rewards outstanding and they are gone for good.
      final api = FakeApi([row()]);
      final ledger = FakeLedger();
      final sink = FakeSink()..failStep = 'coins';

      final applied =
          await newService(api: api, ledger: ledger, sink: sink).syncPending();

      expect(applied, 0);
      expect(api.allAcked, isEmpty);
      expect(ledger.rows['s1']!.statsApplied, isTrue);
      expect(ledger.rows['s1']!.completed, isFalse);
    },
  );

  test('a local apply failure schedules an automatic retry', () {
    fakeAsync((async) {
      final api = FakeApi([row()]);
      final ledger = FakeLedger();
      final sink = FakeSink()..failStep = 'coins';
      final service = newService(api: api, ledger: ledger, sink: sink);

      service.syncPending();
      async.flushMicrotasks();
      expect(api.fetches, 1);
      expect(api.allAcked, isEmpty);

      // The grant starts working — a transient economy failure resolving.
      sink.failStep = null;

      // First backoff step.
      async.elapse(MultiplayerSettlementService.retryDelays.first);
      async.flushMicrotasks();

      expect(api.fetches, 2, reason: 'the retry must fire on its own');
      expect(api.allAcked, ['s1']);
      expect(ledger.rows['s1']!.completed, isTrue);
      // Resumed rather than restarted.
      expect(sink.stats, 1);
      expect(sink.coins, 1);

      service.dispose();
    });
  });

  test('a failed FETCH also schedules a retry', () {
    fakeAsync((async) {
      final api = FakeApi(null); // null = the request failed
      final ledger = FakeLedger();
      final sink = FakeSink();
      final service = newService(api: api, ledger: ledger, sink: sink);

      service.syncPending();
      async.flushMicrotasks();
      expect(api.fetches, 1);

      api.rows = [row()];
      async.elapse(MultiplayerSettlementService.retryDelays.first);
      async.flushMicrotasks();

      expect(api.fetches, 2);
      expect(api.allAcked, ['s1']);

      service.dispose();
    });
  });

  test('retries back off rather than hammering', () {
    fakeAsync((async) {
      final api = FakeApi(null);
      final service = newService(
        api: api,
        ledger: FakeLedger(),
        sink: FakeSink(),
      );

      service.syncPending();
      async.flushMicrotasks();
      expect(api.fetches, 1);

      // Not yet — the first delay has not elapsed.
      async.elapse(const Duration(seconds: 1));
      async.flushMicrotasks();
      expect(api.fetches, 1);

      async.elapse(MultiplayerSettlementService.retryDelays[0]);
      async.flushMicrotasks();
      expect(api.fetches, 2);

      // The second delay is longer than the first.
      async.elapse(MultiplayerSettlementService.retryDelays[0]);
      async.flushMicrotasks();
      expect(api.fetches, 2);

      async.elapse(MultiplayerSettlementService.retryDelays[1]);
      async.flushMicrotasks();
      expect(api.fetches, 3);

      service.dispose();
    });
  });

  test(
    'a settlement already applied but never acknowledged is re-acknowledged '
    'without being paid again',
    () async {
      final ledger = FakeLedger();
      final sink = FakeSink();

      // First run: applies and acknowledges.
      final firstApi = FakeApi([row()]);
      await newService(api: firstApi, ledger: ledger, sink: sink).syncPending();
      expect(sink.coins, 1);

      // The server still offers it — the ack was lost in flight.
      final secondApi = FakeApi([row()]);
      final applied = await newService(
        api: secondApi,
        ledger: ledger,
        sink: sink,
      ).syncPending();

      expect(applied, 0, reason: 'nothing new was applied');
      expect(sink.coins, 1, reason: 'it must not be paid twice');
      expect(secondApi.allAcked, ['s1'],
          reason: 're-acknowledging is how it stops coming back');
    },
  );

  test('one failing settlement does not block another from settling', () async {
    final api = FakeApi([row(id: 'good'), row(id: 'bad')]);
    final ledger = FakeLedger();
    final sink = _SelectiveSink(failFor: 'bad');

    final applied =
        await newService(api: api, ledger: ledger, sink: sink).syncPending();

    expect(applied, 1);
    expect(api.allAcked, ['good']);
    expect(ledger.rows['bad']!.completed, isFalse);
  });
}

/// Fails only for one settlement id.
class _SelectiveSink extends FakeSink {
  _SelectiveSink({required this.failFor});

  final String failFor;

  @override
  Future<void> applyCoins(MultiplayerSettlement s) async {
    if (s.id == failFor) throw StateError('coin grant failed for ${s.id}');
    return super.applyCoins(s);
  }
}
