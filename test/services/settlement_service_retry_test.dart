import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement_service.dart';
import 'package:snake_classic/services/multiplayer/settlement_ledger.dart';

/// A scripted transport. Records what was acknowledged, so a settlement being
/// acknowledged before it was applied is visible.
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

/// Stands in for the transactional writer.
///
/// It cannot half-apply — that is the writer's contract, and it is proved
/// against a real database in settlement_write_integration_test. What this
/// fake exists to exercise is the layer above: whether the service retries,
/// and whether it acknowledges only what actually applied.
class FakeWriter implements SettlementWriter {
  final Set<String> applied = {};
  final Map<String, int> applyCalls = {};

  /// Settlement id whose apply throws, as a rolled-back transaction would.
  String? failFor;

  @override
  Future<bool> applyOnce(MultiplayerSettlement settlement) async {
    applyCalls.update(settlement.id, (v) => v + 1, ifAbsent: () => 1);
    if (settlement.id == failFor) {
      throw StateError('transaction rolled back for ${settlement.id}');
    }
    if (!applied.add(settlement.id)) return false;
    return true;
  }

  @override
  Future<bool> isApplied(String settlementId) async =>
      applied.contains(settlementId);

  @override
  Future<Set<String>> appliedIds(List<String> candidates) async =>
      candidates.where(applied.contains).toSet();
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
  required FakeWriter writer,
}) {
  return MultiplayerSettlementService(api: api, writer: writer);
}

void main() {
  test('an applied settlement is acknowledged', () async {
    final api = FakeApi([row()]);
    final writer = FakeWriter();

    final applied = await newService(api: api, writer: writer).syncPending();

    expect(applied, 1);
    expect(api.allAcked, ['s1']);
  });

  test('a settlement whose transaction rolled back is NOT acknowledged',
      () async {
    // Acknowledging tells the server to stop offering it. Do that with the
    // rewards rolled back and they are gone for good.
    final api = FakeApi([row()]);
    final writer = FakeWriter()..failFor = 's1';

    final applied = await newService(api: api, writer: writer).syncPending();

    expect(applied, 0);
    expect(api.allAcked, isEmpty);
    expect(writer.applied, isEmpty);
  });

  test('a rolled-back apply schedules an automatic retry', () {
    fakeAsync((async) {
      final api = FakeApi([row()]);
      final writer = FakeWriter()..failFor = 's1';
      final service = newService(api: api, writer: writer);

      service.syncPending();
      async.flushMicrotasks();
      expect(api.fetches, 1);
      expect(api.allAcked, isEmpty);

      // Whatever broke has recovered.
      writer.failFor = null;

      async.elapse(MultiplayerSettlementService.retryDelays.first);
      async.flushMicrotasks();

      expect(api.fetches, 2, reason: 'the retry must fire on its own');
      expect(api.allAcked, ['s1']);
      expect(writer.applyCalls['s1'], 2, reason: 'it was retried, not dropped');
      expect(writer.applied, {'s1'});

      service.dispose();
    });
  });

  test('a failed FETCH also schedules a retry', () {
    fakeAsync((async) {
      final api = FakeApi(null); // null = the request failed
      final service = newService(api: api, writer: FakeWriter());

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
      final service = newService(api: api, writer: FakeWriter());

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
    'without being applied again',
    () async {
      final writer = FakeWriter();

      final firstApi = FakeApi([row()]);
      await newService(api: firstApi, writer: writer).syncPending();
      expect(writer.applyCalls['s1'], 1);

      // The server still offers it — the ack was lost in flight.
      final secondApi = FakeApi([row()]);
      final applied =
          await newService(api: secondApi, writer: writer).syncPending();

      expect(applied, 0, reason: 'nothing new was applied');
      expect(writer.applyCalls['s1'], 1, reason: 'apply was not called again');
      expect(secondApi.allAcked, ['s1'],
          reason: 're-acknowledging is how it stops coming back');
    },
  );

  test('one failing settlement does not block another from settling', () async {
    final api = FakeApi([row(id: 'good'), row(id: 'bad')]);
    final writer = FakeWriter()..failFor = 'bad';

    final applied = await newService(api: api, writer: writer).syncPending();

    expect(applied, 1);
    expect(api.allAcked, ['good']);
    expect(writer.applied, {'good'});
  });
}
