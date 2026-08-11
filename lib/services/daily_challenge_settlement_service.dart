import 'dart:async';

import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/data/database/settlement_write.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/utils/logger.dart';

/// One reward the server says is owed.
class DailyChallengeSettlement {
  final String id;
  final String settlementKey;
  final String? challengeId;
  final int coinsAwarded;
  final int xpAwarded;
  final bool isSetBonus;

  const DailyChallengeSettlement({
    required this.id,
    required this.settlementKey,
    required this.challengeId,
    required this.coinsAwarded,
    required this.xpAwarded,
    required this.isSetBonus,
  });

  static DailyChallengeSettlement? tryParse(Map<String, dynamic> json) {
    final id = json['id']?.toString();
    final key = json['settlement_key']?.toString();
    if (id == null || id.isEmpty || key == null || key.isEmpty) return null;

    return DailyChallengeSettlement(
      id: id,
      settlementKey: key,
      challengeId: json['challenge_id']?.toString(),
      coinsAwarded: (json['coins_awarded'] as num?)?.toInt() ?? 0,
      xpAwarded: (json['xp_awarded'] as num?)?.toInt() ?? 0,
      isSetBonus: json['is_set_bonus'] == true || json['challenge_id'] == null,
    );
  }
}

/// The transport, behind an interface so the retry and exactly-once behaviour
/// can be tested without a socket.
abstract class DailyChallengeSettlementApi {
  Future<List<Map<String, dynamic>>?> fetchPending();
  Future<bool> acknowledge(List<String> settlementIds);
}

class _HttpDailyChallengeSettlementApi implements DailyChallengeSettlementApi {
  final ApiService _api;
  _HttpDailyChallengeSettlementApi(this._api);

  @override
  Future<List<Map<String, dynamic>>?> fetchPending() =>
      _api.getPendingDailyChallengeSettlements();

  @override
  Future<bool> acknowledge(List<String> settlementIds) =>
      _api.ackDailyChallengeSettlements(settlementIds);
}

/// Applies a settlement's durable effect. Real implementation is one Drift
/// transaction; the interface exists so the service above it is testable.
abstract class DailyChallengeSettlementWriter {
  /// True when THIS call applied it; false when it was already applied.
  /// Throws if anything failed — in which case nothing was written.
  Future<bool> applyOnce(DailyChallengeSettlement settlement);
}

class DriftDailyChallengeSettlementWriter
    implements DailyChallengeSettlementWriter {
  DriftDailyChallengeSettlementWriter(this._db, {this.onApplied});

  final AppDatabase _db;

  /// Called after a successful commit so the caller can refresh in-memory
  /// state from durable truth. Never called for a rolled-back attempt.
  final Future<void> Function(DailyChallengeWriteResult result)? onApplied;

  @override
  Future<bool> applyOnce(DailyChallengeSettlement settlement) async {
    final result = await _db.applyDailyChallengeSettlementOnce(
      settlementId: settlement.id,
      settlementKey: settlement.settlementKey,
      coinsAwarded: settlement.coinsAwarded,
      xpAwarded: settlement.xpAwarded,
      description: settlement.isSetBonus
          ? 'Daily challenges complete'
          : 'Daily challenge',
    );

    if (result.applied) {
      await onApplied?.call(result);
    }
    return result.applied;
  }
}

/// Turns "the server says you are owed this" into coins and XP on this device,
/// exactly once.
///
/// Claiming used to credit coins directly: a local Drift flag, then a separate
/// CoinsCubit call. Two devices offline could each see the same challenge
/// legitimately unclaimed and each pay themselves, and a crash between the two
/// writes lost the reward for good on that install.
///
/// Now a claim records a durable INTENT and nothing else. The server settles
/// it once per account, and this service applies the settlement inside one
/// transaction and acknowledges it afterwards. The ordering matters: apply,
/// then acknowledge. Acknowledging first would tell the server to stop
/// offering a reward that had not landed anywhere.
class DailyChallengeSettlementServiceClient {
  DailyChallengeSettlementServiceClient({
    required this.api,
    required this.writer,
  });

  /// Production wiring.
  factory DailyChallengeSettlementServiceClient.forDatabase(
    AppDatabase db, {
    Future<void> Function(DailyChallengeWriteResult result)? onApplied,
  }) {
    return DailyChallengeSettlementServiceClient(
      api: _HttpDailyChallengeSettlementApi(ApiService()),
      writer: DriftDailyChallengeSettlementWriter(db, onApplied: onApplied),
    );
  }

  final DailyChallengeSettlementApi api;
  final DailyChallengeSettlementWriter writer;

  /// Backoff for a failed fetch or a failed apply. Bounded: a reward that
  /// cannot be applied now is not lost, it is waiting.
  static const List<Duration> retryDelays = [
    Duration(seconds: 3),
    Duration(seconds: 15),
    Duration(seconds: 60),
  ];

  Timer? _retryTimer;
  int _attempt = 0;
  bool _inFlight = false;

  /// Fetch, apply, acknowledge. Returns how many settlements this call
  /// applied.
  ///
  /// Deliberately no connectivity preflight. The request is the authority on
  /// whether the backend is reachable, and a probe that says otherwise has
  /// already been observed to be wrong on LAN backends, captive Wi-Fi and
  /// split-tunnel VPNs.
  Future<int> syncPending() async {
    if (_inFlight) return 0;
    _inFlight = true;
    try {
      final rows = await api.fetchPending();
      if (rows == null) {
        _scheduleRetry();
        return 0;
      }

      final settlements = rows
          .map(DailyChallengeSettlement.tryParse)
          .whereType<DailyChallengeSettlement>()
          .toList();
      if (settlements.isEmpty) {
        _attempt = 0;
        return 0;
      }

      final applied = <String>[];
      var newlyApplied = 0;
      var anyFailed = false;

      for (final settlement in settlements) {
        try {
          final didApply = await writer.applyOnce(settlement);
          if (didApply) newlyApplied++;
          // Acknowledge whether or not THIS call applied it: a settlement
          // that was already applied here still needs the server to stop
          // offering it.
          applied.add(settlement.id);
        } catch (e) {
          // The transaction rolled back, so nothing was written. Do NOT
          // acknowledge — that would tell the server to forget a reward this
          // device never banked.
          anyFailed = true;
          AppLogger.error(
            'Daily challenge settlement ${settlement.id} failed to apply', e);
        }
      }

      if (applied.isNotEmpty) {
        final acked = await api.acknowledge(applied);
        if (!acked) {
          // Harmless: the settlements are applied and the ledger will refuse
          // them on the next delivery. Retry so the server stops re-offering.
          _scheduleRetry();
          return newlyApplied;
        }
      }

      if (anyFailed) {
        _scheduleRetry();
      } else {
        _attempt = 0;
      }
      return newlyApplied;
    } catch (e) {
      AppLogger.error('Daily challenge settlement sync failed', e);
      _scheduleRetry();
      return 0;
    } finally {
      _inFlight = false;
    }
  }

  void _scheduleRetry() {
    if (_attempt >= retryDelays.length) return;
    final delay = retryDelays[_attempt];
    _attempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () => unawaited(syncPending()));
  }

  void dispose() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }
}
