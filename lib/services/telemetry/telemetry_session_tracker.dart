import 'dart:async';
import 'dart:math' as math;

import 'package:drift/drift.dart' show Value;
import 'package:snake_classic/data/daos/telemetry_dao.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/services/telemetry/install_identity.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// Aggregates the current app session for the design-metrics telemetry and
/// keeps it on disk (docs/design-metrics/CONTRACT.md, "Semantics").
///
/// It is fed from two directions and decides nothing else:
///   * analytics events, via TelemetryAnalyticsClient — runs, ads, purchases,
///     store visits — so no gameplay or monetisation call site knows it
///     exists;
///   * app lifecycle, via TelemetryService — [foregrounded] / [backgrounded].
///
/// Every input is applied to memory synchronously, before anything is
/// awaited. That ordering is load-bearing: the analytics facade calls its
/// clients synchronously, and a game over is reported immediately before the
/// next run's start when AGAIN is pressed inside the continue window. If the
/// two were applied out of order the "again" decision would be lost.
///
/// The clock is injected so the 30-minute and 60-second rules can be tested
/// without waiting for them.
class TelemetrySessionTracker {
  TelemetrySessionTracker({
    required this._dao,
    required this._identity,
    DateTime Function()? clock,
    this.persistDebounce = const Duration(seconds: 2),
    this._uuid = const Uuid(),
  }) : _clock = clock ?? DateTime.now {
    final now = _clock();
    _begin(now);
    // A cold start is a foreground start: the session begins now.
    _foregroundSince = now;
  }

  /// A return to the foreground at least this long after leaving it starts a
  /// new session; anything shorter continues the same one.
  static const Duration backgroundTimeout = Duration(minutes: 30);

  /// A single-player run started within this long of the previous run's game
  /// over, in the same session, counts as "again".
  static const Duration againWindow = Duration(seconds: 60);

  final TelemetryDao _dao;
  final InstallIdentity _identity;
  final DateTime Function() _clock;
  final Uuid _uuid;

  /// How long counter changes are coalesced before they are written. Session
  /// boundaries are written at once; only the steady trickle of counters
  /// (a banner impression a minute, a run every few) waits for this.
  final Duration persistDebounce;

  bool _started = false;
  Timer? _debounce;
  Future<void> _writes = Future.value();

  // ---- The session ------------------------------------------------------

  late String _sessionId;
  late DateTime _startedAt;
  late String _localDay;
  DateTime? _endedAt;
  late _Counters _c;
  int _revision = 0;

  /// Foreground time already banked by earlier foreground stretches of this
  /// session; the open stretch (since [_foregroundSince]) is added on read.
  int _foregroundMsBanked = 0;
  DateTime? _foregroundSince;
  DateTime? _backgroundedAt;

  // ---- The run in progress ---------------------------------------------

  DateTime? _runStartedAt;
  int _runPausedMs = 0;
  DateTime? _runPausedAt;

  /// When the last finished run ended, for the "again" rule. Cleared when a
  /// run starts (one game over earns at most one "again") and at every new
  /// session (the rule is per session).
  DateTime? _lastGameOverAt;

  String get sessionId => _sessionId;
  bool get isForeground => _foregroundSince != null;

  /// Close whatever the previous process left open, then put the current
  /// session on disk. Events that arrived earlier were kept in memory and
  /// are written now.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    try {
      final closed = await _dao.closeAbandonedSessions(_sessionId);
      if (closed > 0) {
        AppLogger.info('Telemetry: $closed session(s) ended abnormally');
      }
    } catch (e) {
      AppLogger.error('Telemetry: could not close abandoned sessions', e);
    }
    await persistNow();
  }

  // ==================== Lifecycle ====================

  /// The app came (back) to the foreground.
  void foregrounded() {
    if (_foregroundSince != null) return;
    final now = _clock();
    final away = _backgroundedAt;
    if (away != null && now.difference(away) >= backgroundTimeout) {
      // The previous session was closed and written when it went to the
      // background; this is a new one.
      _begin(now);
    } else {
      // A quick trip out continues the session. Its end is no longer known.
      _endedAt = null;
    }
    _backgroundedAt = null;
    _foregroundSince = now;
    unawaited(persistNow());
  }

  /// The app went to the background. The session's end is recorded now, so a
  /// process killed in the background (the normal way an Android app dies)
  /// is never mistaken for a crash.
  void backgrounded() {
    final since = _foregroundSince;
    if (since == null) return;
    final now = _clock();
    _foregroundMsBanked += _msBetween(since, now);
    _foregroundSince = null;
    _backgroundedAt = now;
    _endedAt = now;
    unawaited(persistNow());
  }

  // ==================== Runs ====================

  /// A single-player run started (`game_started`).
  void runStarted() {
    final now = _clock();
    final lastOver = _lastGameOverAt;
    if (lastOver != null && now.difference(lastOver) <= againWindow) {
      _c.runsAgain++;
    }
    _lastGameOverAt = null;
    _c.runsStarted++;
    _runStartedAt = now;
    _runPausedMs = 0;
    _runPausedAt = null;
    _changed();
  }

  void runPaused() {
    if (_runStartedAt == null || _runPausedAt != null) return;
    _runPausedAt = _clock();
  }

  void runResumed() {
    final pausedAt = _runPausedAt;
    if (pausedAt == null) return;
    _runPausedMs += _msBetween(pausedAt, _clock());
    _runPausedAt = null;
  }

  /// A single-player run finished (`game_over`).
  ///
  /// The event can arrive after the moment of game over: on the Living Board
  /// the run's finalization, which is what reports it, waits out the
  /// game-over continue window (up to ~8 s, longer while the player is paying
  /// for a continue) — or until AGAIN is pressed. The classic UI reports it
  /// at once. Timing the "again" gap from the event's arrival would make the
  /// redesign's gaps look shorter for no reason but bookkeeping, so the game
  /// over is placed where the run's own clock puts it: start + paused time +
  /// [durationSeconds], which the game measures at the true moment and which
  /// excludes pauses on both designs. Arrival time is the upper bound.
  void runFinished({required int score, required int durationSeconds}) {
    final now = _clock();
    var overAt = now;
    final startedAt = _runStartedAt;
    if (startedAt != null) {
      final paused = _runPausedMs +
          (_runPausedAt == null ? 0 : _msBetween(_runPausedAt!, now));
      final byRunClock = startedAt.add(
        Duration(milliseconds: paused + durationSeconds * 1000),
      );
      if (byRunClock.isBefore(now)) overAt = byRunClock;
      _c.runMs += math.max(0, _msBetween(startedAt, overAt) - paused);
    } else {
      // Started before this process was tracking (cannot normally happen);
      // the game's own measurement is the only one there is.
      _c.runMs += math.max(0, durationSeconds) * 1000;
    }
    _c.runsFinished++;
    _c.totalScore += math.max(0, score);
    _c.bestScore = math.max(_c.bestScore, score);
    _lastGameOverAt = overAt;
    _runStartedAt = null;
    _runPausedMs = 0;
    _runPausedAt = null;
    _changed();
  }

  void multiplayerMatchEnded() {
    _c.multiplayerMatches++;
    _changed();
  }

  // ==================== Ads ====================

  /// [format] as reported by AdService / the banner widget. A rewarded
  /// interstitial is a rewarded ad for the contract's purposes: it is the
  /// format whose completions and abandonments land in the rewarded counters.
  void adImpression(String format) {
    switch (format) {
      case 'banner':
        _c.adImpressionsBanner++;
      case 'interstitial':
        _c.adImpressionsInterstitial++;
      case 'rewarded':
      case 'rewarded_interstitial':
        _c.adImpressionsRewarded++;
      case 'app_open':
        _c.adImpressionsAppOpen++;
      default:
        return;
    }
    _changed();
  }

  void rewardedCompleted() {
    _c.rewardedCompleted++;
    _changed();
  }

  void rewardedAbandoned() {
    _c.rewardedAbandoned++;
    _changed();
  }

  void adRevenue(double valueMicros) {
    if (valueMicros.isNaN || valueMicros <= 0) return;
    _c.adRevenueMicros += valueMicros.round();
    _changed();
  }

  // ==================== Store ====================

  void purchaseStarted() {
    _c.purchasesStarted++;
    _changed();
  }

  void purchaseCompleted() {
    _c.purchasesCompleted++;
    _changed();
  }

  void storeViewed() {
    _c.storeViews++;
    _changed();
  }

  // ==================== Persistence ====================

  /// Write the current snapshot now, after any write already queued. Returns
  /// when it is on disk — the uploader awaits this so a flush sends the
  /// session as it is this moment.
  Future<void> persistNow() {
    _debounce?.cancel();
    _debounce = null;
    if (!_started) return _writes;
    final row = _snapshot(_clock());
    _writes = _writes.then((_) => _dao.upsertSession(row)).catchError(
      (Object e) => AppLogger.error('Telemetry: session write failed', e),
    );
    return _writes;
  }

  void _changed() {
    if (!_started) return;
    _debounce?.cancel();
    _debounce = Timer(persistDebounce, () => unawaited(persistNow()));
  }

  TelemetrySessionsCompanion _snapshot(DateTime now) {
    final since = _foregroundSince;
    final foregroundMs =
        _foregroundMsBanked + (since == null ? 0 : _msBetween(since, now));
    return TelemetrySessionsCompanion(
      sessionId: Value(_sessionId),
      design: Value(_identity.design),
      appVersion: Value(_identity.appVersion),
      build: Value(_identity.build),
      startedAt: Value(_startedAt),
      endedAt: Value(_endedAt),
      lastActiveAt: Value(now),
      localDay: Value(_localDay),
      foregroundMs: Value(foregroundMs),
      runsStarted: Value(_c.runsStarted),
      runsFinished: Value(_c.runsFinished),
      runsAgain: Value(_c.runsAgain),
      bestScore: Value(_c.bestScore),
      totalScore: Value(_c.totalScore),
      runMs: Value(_c.runMs),
      multiplayerMatches: Value(_c.multiplayerMatches),
      adImpressionsBanner: Value(_c.adImpressionsBanner),
      adImpressionsInterstitial: Value(_c.adImpressionsInterstitial),
      adImpressionsRewarded: Value(_c.adImpressionsRewarded),
      adImpressionsAppOpen: Value(_c.adImpressionsAppOpen),
      rewardedCompleted: Value(_c.rewardedCompleted),
      rewardedAbandoned: Value(_c.rewardedAbandoned),
      adRevenueMicros: Value(_c.adRevenueMicros),
      purchasesStarted: Value(_c.purchasesStarted),
      purchasesCompleted: Value(_c.purchasesCompleted),
      storeViews: Value(_c.storeViews),
      abnormalEnd: const Value(false),
      dirty: const Value(true),
      revision: Value(++_revision),
    );
  }

  void _begin(DateTime now) {
    _sessionId = _uuid.v4();
    _startedAt = now;
    _localDay = localDayOf(now);
    _endedAt = null;
    _c = _Counters();
    _revision = 0;
    _foregroundMsBanked = 0;
    _lastGameOverAt = null;
  }

  /// `yyyy-MM-dd` of [at] in the device's local time zone — retention is by
  /// the player's day, not UTC.
  static String localDayOf(DateTime at) {
    final l = at.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${l.year.toString().padLeft(4, '0')}-${two(l.month)}-${two(l.day)}';
  }

  static int _msBetween(DateTime from, DateTime to) =>
      math.max(0, to.difference(from).inMilliseconds);

  /// Stop the debounce timer. The singleton lives for the process; this is
  /// for tests.
  void dispose() {
    _debounce?.cancel();
    _debounce = null;
  }
}

class _Counters {
  int runsStarted = 0;
  int runsFinished = 0;
  int runsAgain = 0;
  int bestScore = 0;
  int totalScore = 0;
  int runMs = 0;
  int multiplayerMatches = 0;
  int adImpressionsBanner = 0;
  int adImpressionsInterstitial = 0;
  int adImpressionsRewarded = 0;
  int adImpressionsAppOpen = 0;
  int rewardedCompleted = 0;
  int rewardedAbandoned = 0;
  int adRevenueMicros = 0;
  int purchasesStarted = 0;
  int purchasesCompleted = 0;
  int storeViews = 0;
}
