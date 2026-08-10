import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement_service.dart';
import 'package:snake_classic/services/multiplayer/settlement_ledger.dart';

import 'settlement_applier_test.dart'
    show FakeLedger, FakeSink, SettlementWorld;

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
  required SettlementWorld world,
  SettlementRewardSink? sink,
}) {
  return MultiplayerSettlementService(
    // No database or pipeline: the ledger and sink are injected instead.
    api: api,
    ledger: FakeLedger(world),
    rewardSink: sink ?? FakeSink(world),
  );
}

void main() {
  test('a fully applied settlement is acknowledged', () async {
    final api = FakeApi([row()]);
    final world = SettlementWorld();

    final applied = await newService(api: api, world: world).syncPending();

    expect(applied, 1);
    expect(api.allAcked, ['s1']);
    expect((world.stats, world.coins, world.xp), (1, 1, 1));
  });

  test('a settlement whose coin grant failed is NOT acknowledged', () async {
    // The core rule: acknowledging tells the server to stop offering it. Do
    // that with rewards outstanding and they are gone for good.
    final api = FakeApi([row()]);
    final world = SettlementWorld()..failStep = SettlementStep.coins;

    final applied = await newService(api: api, world: world).syncPending();

    expect(applied, 0);
    expect(api.allAcked, isEmpty);
    expect(world.progress['s1']!.statsApplied, isTrue);
    expect(world.progress['s1']!.completed, isFalse);
  });

  test('a local apply failure schedules an automatic retry', () {
    fakeAsync((async) {
      final api = FakeApi([row()]);
      final world = SettlementWorld()..failStep = SettlementStep.coins;
      final service = newService(api: api, world: world);

      service.syncPending();
      async.flushMicrotasks();
      expect(api.fetches, 1);
      expect(api.allAcked, isEmpty);

      // The grant starts working — a transient economy failure resolving.
      world.failStep = null;

      async.elapse(MultiplayerSettlementService.retryDelays.first);
      async.flushMicrotasks();

      expect(api.fetches, 2, reason: 'the retry must fire on its own');
      expect(api.allAcked, ['s1']);
      expect(world.progress['s1']!.completed, isTrue);
      // Resumed, not restarted — and paid exactly once overall.
      expect((world.stats, world.coins, world.xp), (1, 1, 1));

      service.dispose();
    });
  });

  test('a crash mid-apply is retried and still pays exactly once', () {
    fakeAsync((async) {
      final api = FakeApi([row()]);
      final world = SettlementWorld()..crashDuring = SettlementStep.coins;
      final service = newService(api: api, world: world);

      service.syncPending();
      async.flushMicrotasks();
      expect(api.allAcked, isEmpty);
      expect(world.coins, 0, reason: 'the rollback undid the credit');

      world.crashDuring = null;
      async.elapse(MultiplayerSettlementService.retryDelays.first);
      async.flushMicrotasks();

      expect(api.allAcked, ['s1']);
      expect((world.stats, world.coins, world.xp), (1, 1, 1));

      service.dispose();
    });
  });

  test('a failed FETCH also schedules a retry', () {
    fakeAsync((async) {
      final api = FakeApi(null); // null = the request failed
      final world = SettlementWorld();
      final service = newService(api: api, world: world);

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
      final service = newService(api: api, world: SettlementWorld());

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
      final world = SettlementWorld();

      // First run: applies and acknowledges.
      final firstApi = FakeApi([row()]);
      await newService(api: firstApi, world: world).syncPending();
      expect(world.coins, 1);

      // The server still offers it — the ack was lost in flight.
      final secondApi = FakeApi([row()]);
      final applied =
          await newService(api: secondApi, world: world).syncPending();

      expect(applied, 0, reason: 'nothing new was applied');
      expect((world.stats, world.coins, world.xp), (1, 1, 1),
          reason: 'it must not be paid twice');
      expect(secondApi.allAcked, ['s1'],
          reason: 're-acknowledging is how it stops coming back');
    },
  );

  test('one failing settlement does not block another from settling', () async {
    final api = FakeApi([row(id: 'good'), row(id: 'bad')]);
    final world = SettlementWorld();

    final applied = await newService(
      api: api,
      world: world,
      sink: _SelectiveSink(world, failFor: 'bad'),
    ).syncPending();

    expect(applied, 1);
    expect(api.allAcked, ['good']);
    expect(world.progress['bad']!.completed, isFalse);
  });
}

/// Fails the coin step only for one settlement id.
class _SelectiveSink extends FakeSink {
  _SelectiveSink(super.world, {required this.failFor});

  final String failFor;

  @override
  Future<void> applyCoins(MultiplayerSettlement s) async {
    if (s.id == failFor) throw StateError('coin grant failed for ${s.id}');
    return super.applyCoins(s);
  }
}
