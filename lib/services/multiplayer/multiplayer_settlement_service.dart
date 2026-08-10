import 'dart:async';

import 'package:snake_classic/data/database/app_database.dart' as db;
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/game_end_pipeline.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/services/multiplayer/settlement_ledger.dart';
import 'package:snake_classic/utils/logger.dart';

/// Routes a settlement's rewards into the real economy subsystems.
///
/// Every method awaits its write all the way down. A step that returned before
/// its grant was durable would let the applier record it as done while it was
/// still in flight, which is exactly the loss this design exists to prevent.
class PipelineRewardSink implements SettlementRewardSink {
  PipelineRewardSink(this._pipeline);

  final GameEndPipeline _pipeline;

  @override
  Future<void> applyStats(MultiplayerSettlement s) {
    return _pipeline.recordMultiplayerMatch(
      score: s.score,
      foodsEaten: s.foodsEaten,
      gameTimeSeconds: s.durationSeconds,
      alive: s.survivedToEnd,
      deathReason: s.deathReason,
    );
  }

  @override
  Future<void> applyCoins(MultiplayerSettlement s) async {
    final granted = await _pipeline.creditMultiplayerCoins(
      coins: s.coinsAwarded,
      won: s.isWin,
    );
    if (!granted) {
      // Throwing is what keeps the step unrecorded, so the retry tries again.
      // Swallowing it would mark the coins applied and lose them.
      throw StateError('Coin grant for settlement ${s.id} did not land');
    }
  }

  @override
  Future<void> applyBattlePassXp(MultiplayerSettlement s) {
    return _pipeline.creditMultiplayerBattlePassXp(
      battlePassXp: s.battlePassXpAwarded,
      won: s.isWin,
    );
  }
}

/// The production transport: the real API.
class ApiSettlementApi implements SettlementApi {
  ApiSettlementApi(this._api);

  final ApiService _api;

  @override
  Future<List<Map<String, dynamic>>?> fetchPending() =>
      _api.getPendingMultiplayerSettlements();

  @override
  Future<bool> acknowledge(List<String> settlementIds) =>
      _api.ackMultiplayerSettlements(settlementIds);
}

/// Applies the match rewards the server says this player is owed.
///
/// Two guarantees that pull in opposite directions:
///
///   * nothing is acknowledged until it has been durably applied, so a reward
///     is never lost; and
///   * nothing is applied twice, so statistics and coins are never inflated.
///
/// A single "applied" flag can satisfy only one of them — set it before the
/// writes and a crash loses rewards, set it after and a crash replays whatever
/// already landed. So progress is recorded per step (see [SettlementApplier]),
/// a retry resumes rather than restarts, and acknowledgement happens only once
/// every step is done.
///
/// Retrieval is durable on three legs, because a settlement is money owed and
/// giving up on it is not an option: backoff within the session, a
/// connectivity listener, and a pass on every sign-in.
class MultiplayerSettlementService {
  /// Supply either the real dependency or its seam for each of the three
  /// collaborators. Production passes [database] and [endPipeline]; tests pass
  /// [ledger], [rewardSink] and [api], because what is worth testing here is
  /// what happens when a write fails halfway — which is not reachable through
  /// the real ones.
  MultiplayerSettlementService({
    db.AppDatabase? database,
    GameEndPipeline? endPipeline,
    ApiService? apiService,
    SettlementApi? api,
    SettlementLedger? ledger,
    SettlementRewardSink? rewardSink,
  })  : assert(database != null || ledger != null,
            'needs a database or an injected ledger'),
        assert(endPipeline != null || rewardSink != null,
            'needs a pipeline or an injected reward sink'),
        _api = api ?? ApiSettlementApi(apiService ?? ApiService()),
        _ledger = ledger ?? DriftSettlementLedger(database!) {
    _applier = SettlementApplier(
      ledger: _ledger,
      sink: rewardSink ?? PipelineRewardSink(endPipeline!),
    );
  }

  final SettlementApi _api;
  final SettlementLedger _ledger;
  late final SettlementApplier _applier;

  /// Guards against two triggers overlapping (a match ending as the launch
  /// pass is still running). Without it both could read the ledger before
  /// either writes to it.
  bool _running = false;

  /// Settlements applied on this device, as they are applied. The multiplayer
  /// cubit listens so the result screen can stop saying "processing".
  final _appliedController =
      StreamController<MultiplayerSettlement>.broadcast();
  Stream<MultiplayerSettlement> get appliedStream => _appliedController.stream;

  /// Backoff for a failed attempt — whether the fetch failed or a reward write
  /// did. Both mean the player is still owed something.
  static const List<Duration> retryDelays = [
    Duration(seconds: 3),
    Duration(seconds: 15),
    Duration(seconds: 60),
  ];
  int _retryAttempt = 0;
  Timer? _retryTimer;

  ConnectivityService? _connectivity;
  bool _lastHadInternet = true;

  /// Start watching for connectivity coming back.
  ///
  /// The third durability leg: the sign-in pass covers an app restart and the
  /// backoff covers a transient failure; this covers a device that was simply
  /// offline when the match ended and is not going to be restarted soon.
  void startWatching(ConnectivityService connectivity) {
    if (_connectivity != null) return;
    _connectivity = connectivity;
    _lastHadInternet = connectivity.hasInternetAccess;
    connectivity.addListener(_onConnectivityChanged);
  }

  void _onConnectivityChanged() {
    final hasInternet = _connectivity?.hasInternetAccess ?? true;
    if (hasInternet && !_lastHadInternet) {
      AppLogger.info('Network returned — retrying multiplayer settlements');
      _retryAttempt = 0;
      unawaited(syncPending());
    }
    _lastHadInternet = hasInternet;
  }

  void _scheduleRetry() {
    if (_retryAttempt >= retryDelays.length) return;
    final delay = retryDelays[_retryAttempt];
    _retryAttempt++;
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () => unawaited(syncPending()));
  }

  void dispose() {
    _retryTimer?.cancel();
    _connectivity?.removeListener(_onConnectivityChanged);
    _appliedController.close();
  }

  /// Fetch, apply and acknowledge everything outstanding. Returns the number
  /// of settlements brought to fully-applied by this pass.
  Future<int> syncPending() async {
    if (_running) return 0;
    _running = true;
    try {
      final rows = await _api.fetchPending();
      if (rows == null) {
        // The request failed — not "there is nothing owed". Keep trying.
        _scheduleRetry();
        return 0;
      }
      _retryAttempt = 0;
      if (rows.isEmpty) return 0;

      final fetched = MultiplayerSettlement.parseAll(rows);
      if (fetched.isEmpty) return 0;

      // Only FULLY applied settlements are skipped. A partially applied one is
      // in [toApply] on purpose: the applier resumes it from its last
      // completed step.
      final completed =
          await _ledger.completedIds(fetched.map((s) => s.id).toList());
      final plan = planSettlements(fetched: fetched, alreadyApplied: completed);

      // Already complete but still pending server-side: the acknowledgement
      // never landed last time. Re-acknowledging is how it stops coming back.
      final acknowledgeable = plan.toAcknowledge
          .where(completed.contains)
          .toList();

      var applied = 0;
      var anyFailed = false;

      for (final settlement in plan.toApply) {
        try {
          final done = await _applier.apply(settlement);
          if (!done) continue;
          applied++;
          acknowledgeable.add(settlement.id);
          if (!_appliedController.isClosed) {
            _appliedController.add(settlement);
          }
        } catch (e) {
          // Whatever steps succeeded are recorded; the rest are still owed.
          // Leave it unacknowledged so the server keeps offering it, and
          // schedule a retry so recovery does not wait for the next launch.
          anyFailed = true;
          AppLogger.error(
            'Failed to apply multiplayer settlement ${settlement.id} — '
            'will resume from the last completed step',
            e,
          );
        }
      }

      if (acknowledgeable.isNotEmpty) {
        await _api.acknowledge(acknowledgeable);
      }

      if (anyFailed) _scheduleRetry();

      if (applied > 0) {
        AppLogger.info('Applied $applied multiplayer settlement(s)');
      }
      return applied;
    } catch (e) {
      AppLogger.error('Multiplayer settlement sync failed', e);
      _scheduleRetry();
      return 0;
    } finally {
      _running = false;
    }
  }
}
