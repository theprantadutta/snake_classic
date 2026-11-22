import 'dart:async';

import 'package:snake_classic/models/coin_cosmetic.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// What the buy endpoint answered, before any interpretation.
class CoinBuyResponse {
  const CoinBuyResponse({this.statusCode, this.body});

  /// Never reached the server (offline, timeout, DNS).
  const CoinBuyResponse.transportFailure() : statusCode = null, body = null;

  final int? statusCode;
  final Map<String, dynamic>? body;

  bool get reachedServer => statusCode != null;
  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
  String? get errorCode => body?['error'] as String?;
}

/// The two backend calls coin cosmetics need. An interface so the purchase
/// flow can be tested without HTTP.
abstract class CoinCosmeticsApi {
  bool get isAuthenticated;

  /// POST /cosmetics/buy-with-coins.
  Future<CoinBuyResponse> buy(String type, String id);

  /// GET /cosmetics/coin-catalog, or null when it could not be fetched.
  Future<List<CoinCosmeticOffer>?> catalog();
}

class ApiCoinCosmeticsApi implements CoinCosmeticsApi {
  ApiCoinCosmeticsApi([ApiService? api]) : _api = api ?? ApiService();

  final ApiService _api;

  @override
  bool get isAuthenticated => _api.isAuthenticated;

  @override
  Future<CoinBuyResponse> buy(String type, String id) async {
    final r = await _api.buyCosmeticWithCoins(
      cosmeticType: type,
      cosmeticId: id,
    );
    return CoinBuyResponse(statusCode: r.statusCode, body: r.body);
  }

  @override
  Future<List<CoinCosmeticOffer>?> catalog() async {
    final result = await _api.sendJson(
      method: 'GET',
      path: '/cosmetics/coin-catalog',
    );
    final value = result.value;
    if (!result.isSuccess || value == null) return null;
    // A bare JSON array is wrapped under 'data' by the decoder.
    return CoinCosmeticOffer.parseList(value['data'] ?? value['items']);
  }
}

enum CoinBuyStatus {
  /// Charged and owned now.
  bought,

  /// The server says it was already owned; nothing was charged.
  alreadyOwned,

  /// Not enough coins on the server's balance. See [CoinBuyOutcome.shortBy].
  insufficientCoins,

  /// No backend session, or the request never reached the server.
  needsConnection,

  /// 409 purchase_busy twice in a row. Nothing was charged.
  busy,

  /// The server doesn't sell it for coins (stale catalog).
  unknownCosmetic,

  /// Anything else: 5xx, a malformed answer, a gone account.
  failed,
}

class CoinBuyOutcome {
  const CoinBuyOutcome(
    this.status, {
    this.charged = 0,
    this.serverBalance,
    this.ownedSkins,
    this.ownedTrails,
    this.shortBy = 0,
  });

  final CoinBuyStatus status;
  final int charged;
  final int? serverBalance;
  final List<String>? ownedSkins;
  final List<String>? ownedTrails;

  /// For [CoinBuyStatus.insufficientCoins]: coins still missing by the
  /// LOCAL balance. 0 when the device shows enough but the server doesn't
  /// have them yet (earnings not pushed).
  final int shortBy;

  bool get isOwned =>
      status == CoinBuyStatus.bought || status == CoinBuyStatus.alreadyOwned;
}

/// Buys a coin-priced cosmetic on the server and keeps the local coin
/// balance consistent with the coin-balance sync.
///
/// The server charges `users.coins`, which `/sync/coin-balance` overwrites
/// with whatever this device last pushed (last write wins). So the whole
/// purchase runs inside [serialize] (SyncEngine.runExclusive: no outbox
/// drain, so no other coin push, can interleave):
///  1. [pushBalance] pushes the local balance and awaits the server's ack.
///     If it fails the buy is NOT attempted (needs a connection): the
///     server would judge, and charge, a stale balance.
///  2. The buy (one retry on 409 purchase_busy, nothing charged).
///  3. [adoptBalance] adopts the server's `coin_balance` (plus anything
///     earned locally since the push), with no client spend synced up
///     (StoreDao.adoptServerBalanceAfterCharge).
///  4. [applyOwnership] adopts the server's owned lists.
class CoinCosmeticPurchaser {
  CoinCosmeticPurchaser({
    required this._api,
    required this._serialize,
    required this._pushBalance,
    required this._adoptBalance,
    required this._applyOwnership,
    required this._localBalance,
  });

  final CoinCosmeticsApi _api;

  /// Runs its body with the sync engine's coin push locked out.
  final Future<T> Function<T>(Future<T> Function() body) _serialize;

  /// Pushes the local balance now; the balance pushed, or null on failure.
  final Future<int?> Function() _pushBalance;

  final Future<void> Function({
    required int serverBalance,
    required int pushedBalance,
    required int charged,
    required String description,
  })
  _adoptBalance;
  final Future<void> Function(CoinCosmeticOffer offer, CoinBuyOutcome)
  _applyOwnership;
  final int Function() _localBalance;

  bool _inFlight = false;

  Future<CoinBuyOutcome> buy(CoinCosmeticOffer offer) async {
    if (!_api.isAuthenticated) {
      return const CoinBuyOutcome(CoinBuyStatus.needsConnection);
    }
    // A second tap while the first is running: the server is idempotent,
    // but there is no reason to send it twice.
    if (_inFlight) return const CoinBuyOutcome(CoinBuyStatus.busy);
    _inFlight = true;
    try {
      return await _serialize<CoinBuyOutcome>(() async {
        final pushed = await _pushBalance();
        if (pushed == null) {
          AppLogger.info('Coin balance push failed; not buying ${offer.id}');
          return const CoinBuyOutcome(CoinBuyStatus.needsConnection);
        }
        var response = await _api.buy(offer.type, offer.id);
        if (response.statusCode == 409) {
          // purchase_busy: nothing was charged; one retry.
          response = await _api.buy(offer.type, offer.id);
        }
        return _interpret(offer, response, pushed);
      });
    } finally {
      _inFlight = false;
    }
  }

  Future<CoinBuyOutcome> _interpret(
    CoinCosmeticOffer offer,
    CoinBuyResponse response,
    int pushedBalance,
  ) async {
    if (!response.reachedServer) {
      return const CoinBuyOutcome(CoinBuyStatus.needsConnection);
    }
    if (response.statusCode == 401) {
      return const CoinBuyOutcome(CoinBuyStatus.needsConnection);
    }
    if (response.isSuccess) {
      final body = response.body;
      if (body == null) return const CoinBuyOutcome(CoinBuyStatus.failed);
      final charged = (body['charged'] as num?)?.toInt() ?? 0;
      final outcome = CoinBuyOutcome(
        body['already_owned'] == true && charged == 0
            ? CoinBuyStatus.alreadyOwned
            : CoinBuyStatus.bought,
        charged: charged,
        serverBalance: (body['coin_balance'] as num?)?.toInt(),
        ownedSkins: _strings(body['owned_skins']),
        ownedTrails: _strings(body['owned_trails']),
      );
      // Already owned (charged 0): nothing moved, the balance is left alone.
      if (charged > 0) {
        await _adoptBalance(
          // The server charged the balance just pushed; if it didn't say
          // what is left, that is the same number.
          serverBalance: outcome.serverBalance ?? pushedBalance - charged,
          pushedBalance: pushedBalance,
          charged: charged,
          description: '${offer.type}:${offer.id}',
        );
      }
      await _applyOwnership(offer, outcome);
      return outcome;
    }
    switch (response.errorCode) {
      case 'insufficient_coins':
        final short = offer.price - _localBalance();
        return CoinBuyOutcome(
          CoinBuyStatus.insufficientCoins,
          shortBy: short > 0 ? short : 0,
        );
      case 'unknown_cosmetic':
        return const CoinBuyOutcome(CoinBuyStatus.unknownCosmetic);
      case 'purchase_busy':
        return const CoinBuyOutcome(CoinBuyStatus.busy);
    }
    if (response.statusCode == 409) {
      return const CoinBuyOutcome(CoinBuyStatus.busy);
    }
    return const CoinBuyOutcome(CoinBuyStatus.failed);
  }

  static List<String>? _strings(Object? raw) =>
      raw is List ? raw.whereType<String>().toList() : null;
}
