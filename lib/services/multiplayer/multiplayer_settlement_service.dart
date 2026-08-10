import 'dart:async';
import 'package:get_it/get_it.dart';

import 'package:snake_classic/data/database/app_database.dart' as db;
import 'package:snake_classic/data/database/settlement_write.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/connectivity_service.dart';
import 'package:snake_classic/services/multiplayer/multiplayer_settlement.dart';
import 'package:snake_classic/services/multiplayer/settlement_ledger.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/services/statistics_service.dart';
import 'package:snake_classic/utils/logger.dart';

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
  /// Supply either [database] (production) or [writer] (tests).
  MultiplayerSettlementService({
    db.AppDatabase? database,
    ApiService? apiService,
    SettlementApi? api,
    SettlementWriter? writer,
    Future<void> Function(SettlementWriteResult)? onApplied,
  })  : assert(database != null || writer != null,
            'needs a database or an injected writer'),
        _api = api ?? ApiSettlementApi(apiService ?? ApiService()),
        _writer = writer ??
            DriftSettlementWriter(
              database!,
              onApplied: onApplied ?? _refreshInMemoryState,
            );

  final SettlementApi _api;
  final SettlementWriter _writer;

  /// Re-read the in-memory layer from the database AFTER a settlement commits.
  ///
  /// The write path deliberately touches no cubit: it is one transaction of
  /// DAO writes, so a rollback cannot leave memory ahead of the database. The
  /// cost is that memory is stale until this runs, which is why it runs here
  /// rather than being left to the watch streams.
  ///
  /// The level-up celebration is announced without crediting anything — the
  /// coins for it were already paid inside the transaction. That is the bug
  /// this replaced: ProgressionService fired an unawaited, unrecorded coin
  /// grant on level-up, so a replayed settlement paid it again.
  static Future<void> _refreshInMemoryState(SettlementWriteResult result) async {
    Future<void> safely(String what, Future<void> Function() action) async {
      try {
        await action();
      } catch (e) {
        // The rewards are already durable. A refresh failing is a display
        // problem that the next launch fixes, not a lost reward.
        AppLogger.error('Settlement refresh ($what) failed', e);
      }
    }

    if (GetIt.I.isRegistered<CoinsCubit>()) {
      await safely('coins', () => GetIt.I<CoinsCubit>().reloadFromDrift());
    }
    if (GetIt.I.isRegistered<BattlePassCubit>()) {
      await safely(
          'battle pass', () => GetIt.I<BattlePassCubit>().reloadFromDrift());
    }
    await safely('statistics', () => StatisticsService().reloadFromDrift());
    await safely(
      'progression',
      () => ProgressionService().reloadFromDrift(
        announceLevelUp: result.leveledUp ? result.levelAfter : null,
      ),
    );
  }

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
          await _writer.appliedIds(fetched.map((s) => s.id).toList());
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
          final done = await _writer.applyOnce(settlement);
          if (!done) continue;
          applied++;
          acknowledgeable.add(settlement.id);
          if (!_appliedController.isClosed) {
            _appliedController.add(settlement);
          }
        } catch (e) {
          // The transaction rolled back, so nothing was applied and nothing
          // was lost. Leave it unacknowledged so the server keeps offering it,
          // and schedule a retry so recovery does not wait for the next
          // launch.
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
