import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/data/daos/store_dao.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/models/coin_cosmetic.dart';
import 'package:snake_classic/services/coin_cosmetic_purchaser.dart';
import 'package:snake_classic/services/sync/sync_engine.dart';

/// Scripted buy endpoint.
class FakeApi implements CoinCosmeticsApi {
  FakeApi(this.responses);

  final List<CoinBuyResponse> responses;
  final calls = <String>[];
  bool authenticated = true;
  void Function()? onBuy;

  @override
  bool get isAuthenticated => authenticated;

  @override
  Future<CoinBuyResponse> buy(String type, String id) async {
    calls.add('$type:$id');
    onBuy?.call();
    return responses.removeAt(0);
  }

  @override
  Future<List<CoinCosmeticOffer>?> catalog() async => null;
}

CoinBuyResponse ok({
  required int charged,
  required int balance,
  bool alreadyOwned = false,
}) => CoinBuyResponse(
  statusCode: 200,
  body: {
    'cosmetic_type': 'skin',
    'cosmetic_id': 'fire',
    'coin_price': 800,
    'charged': charged,
    'already_owned': alreadyOwned,
    'coin_balance': balance,
    'owned_skins': ['fire'],
    'owned_trails': <String>[],
  },
);

CoinBuyResponse err(int status, String code) =>
    CoinBuyResponse(statusCode: status, body: {'error': code});

const fire = CoinCosmeticOffer(
  type: 'skin',
  id: 'fire',
  price: 800,
  owned: false,
);

void main() {
  late AppDatabase db;
  late StoreDao dao;

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    dao = StoreDao(db);
    await dao.applyCoinBalanceSnapshot(balance: 1000);
  });

  tearDown(() => db.close());

  Future<List<String>> outboxTypes() async =>
      (await db.select(db.syncQueue).get()).map((r) => r.dataType).toList();

  /// The purchaser wired like production, except for the network: the
  /// lock is the real SyncEngine lock, the balance store is real Drift.
  CoinCosmeticPurchaser purchaser(
    FakeApi api, {
    Future<int?> Function()? push,
    List<String>? log,
  }) => CoinCosmeticPurchaser(
    api: api,
    serialize: <T>(Future<T> Function() body) =>
        SyncEngine().runExclusive<T>(body),
    pushBalance:
        push ??
        () async {
          log?.add('push');
          return dao.getCoinBalance();
        },
    adoptBalance:
        ({
          required int serverBalance,
          required int pushedBalance,
          required int charged,
          required String description,
        }) async {
          log?.add('adopt');
          await dao.adoptServerBalanceAfterCharge(
            serverBalance: serverBalance,
            pushedBalance: pushedBalance,
            charged: charged,
            description: description,
          );
        },
    applyOwnership: (offer, outcome) async => log?.add('own'),
    localBalance: () => 1000,
  );

  group('balance handling (StoreDao.adoptServerBalanceAfterCharge)', () {
    test('adopts the server balance and syncs no client spend', () async {
      await db.delete(db.syncQueue).go();
      final result = await dao.adoptServerBalanceAfterCharge(
        serverBalance: 200,
        pushedBalance: 1000,
        charged: 800,
        description: 'skin:fire',
      );
      expect(result, 200);
      expect(await dao.getCoinBalance(), 200);
      // One absolute balance push, NO coin_transaction row: the server
      // already wrote the purchase to its ledger.
      expect(await outboxTypes(), [SyncDataType.coinBalance]);
      final history = await db.select(db.coinTransactions).get();
      expect(history.single.amount, -800);
      expect(history.single.type, 'spent');
    });

    test('keeps coins earned after the confirmed push', () async {
      await dao.addCoins(30, 'gameCompleted'); // local 1030, server knows 1000
      final result = await dao.adoptServerBalanceAfterCharge(
        serverBalance: 200,
        pushedBalance: 1000,
        charged: 800,
      );
      expect(result, 230);
    });

    test('the charge is applied once, never twice', () async {
      await dao.adoptServerBalanceAfterCharge(
        serverBalance: 200,
        pushedBalance: 1000,
        charged: 800,
      );
      // The queued coin_balance push carries the absolute 200, not -800.
      expect(await dao.getCoinBalance(), 200);
      final row = await dao.getCoinBalanceRow();
      expect(row!.totalSpent, 800);
    });
  });

  group('purchase flow', () {
    test('push, then buy, then adopt the balance and ownership', () async {
      final log = <String>[];
      final api = FakeApi([ok(charged: 800, balance: 200)])
        ..onBuy = () => log.add('buy');
      final outcome = await purchaser(api, log: log).buy(fire);

      expect(outcome.status, CoinBuyStatus.bought);
      expect(outcome.charged, 800);
      expect(log, ['push', 'buy', 'adopt', 'own']);
      expect(await dao.getCoinBalance(), 200);
    });

    test('a failed balance push means no buy at all', () async {
      final api = FakeApi([ok(charged: 800, balance: 200)]);
      final outcome = await purchaser(api, push: () async => null).buy(fire);
      expect(outcome.status, CoinBuyStatus.needsConnection);
      expect(api.calls, isEmpty);
      expect(await dao.getCoinBalance(), 1000);
    });

    test('no session: needs a connection, nothing sent', () async {
      final api = FakeApi([])..authenticated = false;
      final outcome = await purchaser(api).buy(fire);
      expect(outcome.status, CoinBuyStatus.needsConnection);
      expect(api.calls, isEmpty);
    });

    test('purchase_busy is retried once', () async {
      final api = FakeApi([
        err(409, 'purchase_busy'),
        ok(charged: 800, balance: 200),
      ]);
      final outcome = await purchaser(api).buy(fire);
      expect(outcome.status, CoinBuyStatus.bought);
      expect(api.calls, hasLength(2));
    });

    test('busy twice gives up without charging', () async {
      final api = FakeApi([
        err(409, 'purchase_busy'),
        err(409, 'purchase_busy'),
      ]);
      final outcome = await purchaser(api).buy(fire);
      expect(outcome.status, CoinBuyStatus.busy);
      expect(await dao.getCoinBalance(), 1000);
    });

    test('already owned: nothing charged, balance untouched', () async {
      final log = <String>[];
      final api = FakeApi([ok(charged: 0, balance: 1000, alreadyOwned: true)]);
      final outcome = await purchaser(api, log: log).buy(fire);
      expect(outcome.status, CoinBuyStatus.alreadyOwned);
      expect(log, ['push', 'own']);
      expect(await dao.getCoinBalance(), 1000);
    });

    test('insufficient coins reports the shortfall', () async {
      final api = FakeApi([err(400, 'insufficient_coins')]);
      final p = CoinCosmeticPurchaser(
        api: api,
        serialize: <T>(Future<T> Function() body) => body(),
        pushBalance: () async => 650,
        adoptBalance: ({
          required int serverBalance,
          required int pushedBalance,
          required int charged,
          required String description,
        }) async => fail('nothing was charged'),
        applyOwnership: (_, _) async => fail('not owned'),
        localBalance: () => 650,
      );
      final outcome = await p.buy(fire);
      expect(outcome.status, CoinBuyStatus.insufficientCoins);
      expect(outcome.shortBy, 150);
    });

    test('unknown cosmetic and server errors are reported', () async {
      expect(
        (await purchaser(FakeApi([err(400, 'unknown_cosmetic')])).buy(fire))
            .status,
        CoinBuyStatus.unknownCosmetic,
      );
      expect(
        (await purchaser(FakeApi([const CoinBuyResponse(statusCode: 500)]))
                .buy(fire))
            .status,
        CoinBuyStatus.failed,
      );
      expect(
        (await purchaser(FakeApi([const CoinBuyResponse.transportFailure()]))
                .buy(fire))
            .status,
        CoinBuyStatus.needsConnection,
      );
    });
  });

  group('serialization with the sync engine', () {
    test('a drain requested mid-purchase waits for the purchase', () async {
      final gate = Completer<void>();
      final order = <String>[];
      final api = FakeApi([ok(charged: 800, balance: 200)]);
      final p = purchaser(
        api,
        push: () async {
          order.add('push');
          await gate.future; // purchase holds the lock here
          return 1000;
        },
      );

      final purchase = p.buy(fire).then((_) => order.add('purchase done'));
      await Future<void>.delayed(Duration.zero);
      // A coin push via the outbox drain, requested while the purchase
      // runs: it must not run until the purchase is finished.
      final drain = SyncEngine().syncNow().then((_) => order.add('drain'));
      await Future<void>.delayed(Duration.zero);
      expect(order, ['push']);

      gate.complete();
      await Future.wait([purchase, drain]);
      // The drain only resolved once the lock was released, i.e. after the
      // whole push-buy-adopt section had run.
      expect(order.first, 'push');
      expect(order, containsAll(['drain', 'purchase done']));
      expect(await dao.getCoinBalance(), 200);
    });

    test('two exclusive sections never overlap', () async {
      final engine = SyncEngine();
      final events = <String>[];
      final first = Completer<void>();
      final a = engine.runExclusive(() async {
        events.add('a start');
        await first.future;
        events.add('a end');
      });
      final b = engine.runExclusive(() async {
        events.add('b start');
        events.add('b end');
      });
      await Future<void>.delayed(Duration.zero);
      expect(events, ['a start']);
      first.complete();
      await Future.wait([a, b]);
      expect(events, ['a start', 'a end', 'b start', 'b end']);
    });

    test('a double tap sends one request', () async {
      final gate = Completer<void>();
      final api = FakeApi([ok(charged: 800, balance: 200)]);
      final p = purchaser(
        api,
        push: () async {
          await gate.future;
          return 1000;
        },
      );
      final first = p.buy(fire);
      final second = await p.buy(fire);
      expect(second.status, CoinBuyStatus.busy);
      gate.complete();
      expect((await first).status, CoinBuyStatus.bought);
      expect(api.calls, hasLength(1));
    });
  });
}
