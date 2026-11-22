import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/models/temporary_grant.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/utils/logger.dart';

/// Owns the device-local [TemporaryGrantLedger]: the daily-bonus XP boost
/// and premium theme, and the "watch 2 ads, wear it for a day" trials.
///
/// Storage is SharedPreferences, never Drift: these grants must not reach
/// the sync outbox, where they would come back from the backend as
/// permanent ownership (CLAUDE.md: device-only state that never travels).
///
/// Expiry: one timer armed for the earliest expiry, plus [pruneExpired] on
/// load and on every resume, so a grant that ran out while the app was
/// closed or suspended is noticed at once. Expired grants are announced on
/// [expirations]; PremiumCubit listens and puts the default cosmetic back.
class TemporaryGrantsService {
  TemporaryGrantsService({this._analytics, DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  static const String _ledgerKey = 'temporary_grants_v1';
  static const String _trialProgressKey = 'cosmetic_trial_progress_v1';

  final AnalyticsFacade? _analytics;
  final DateTime Function() _clock;

  TemporaryGrantLedger _ledger = TemporaryGrantLedger.empty;
  CosmeticTrialProgress? _trialProgress;
  Future<void>? _loading;
  Timer? _expiryTimer;

  final StreamController<TemporaryGrantLedger> _changes =
      StreamController<TemporaryGrantLedger>.broadcast();
  final StreamController<List<TemporaryGrant>> _expirations =
      StreamController<List<TemporaryGrant>>.broadcast();

  /// The ledger after every change (grant, expiry, trial progress).
  Stream<TemporaryGrantLedger> get changes => _changes.stream;

  /// Grants that just ran out, cosmetic and XP boost alike.
  Stream<List<TemporaryGrant>> get expirations => _expirations.stream;

  TemporaryGrantLedger get ledger => _ledger;
  DateTime now() => _clock();

  /// Season XP multiplier right now (2 while the XP boost runs). Reads the
  /// in-memory ledger only, so it is safe on the XP-award path.
  int get seasonXpMultiplier => _ledger.seasonXpMultiplier(_clock());

  /// Read the stored ledger once. Expired grants found here are announced
  /// on [expirations] like any other expiry, so the app falls back to the
  /// defaults on start too. Returns those expired grants.
  Future<List<TemporaryGrant>> load() async {
    final pending = _loading ??= _readFromPrefs();
    await pending;
    return pruneExpired();
  }

  Future<void> _readFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _ledger = TemporaryGrantLedger.decode(prefs.getString(_ledgerKey));
      _trialProgress = CosmeticTrialProgress.decode(
        prefs.getString(_trialProgressKey),
      );
    } catch (e) {
      AppLogger.warning('TemporaryGrants: could not read the ledger: $e');
    }
  }

  /// Add (or extend) a grant and persist it.
  Future<void> grant(TemporaryGrant grant) async {
    await (_loading ??= _readFromPrefs());
    _ledger = _ledger.upsert(grant);
    await _persistLedger();
    _changes.add(_ledger);
    _armTimer();
    AppLogger.info('TemporaryGrants: granted $grant');
  }

  /// Drop every grant that has run out and announce them. Cheap when
  /// nothing has; call it on resume.
  Future<List<TemporaryGrant>> pruneExpired() async {
    final split = _ledger.prune(_clock());
    if (split.expired.isNotEmpty) {
      _ledger = split.active;
      await _persistLedger();
      _changes.add(_ledger);
      for (final g in split.expired) {
        _logExpiry(g);
      }
      _expirations.add(split.expired);
      AppLogger.info('TemporaryGrants: expired ${split.expired}');
    }
    _armTimer();
    return split.expired;
  }

  void _logExpiry(TemporaryGrant g) {
    final analytics = _analytics;
    if (analytics == null) return;
    if (g.kind == TemporaryGrantKind.xpBoost) {
      analytics.trackXpBoost(stage: 'expired');
    } else if (g.source == TemporaryGrantSource.adTrial) {
      analytics.trackCosmeticTrial(
        stage: 'expired',
        cosmeticType: g.kind.name,
        cosmeticId: g.id,
      );
    }
  }

  void _armTimer() {
    _expiryTimer?.cancel();
    _expiryTimer = null;
    final next = _ledger.nextExpiry;
    if (next == null) return;
    var wait = next.difference(_clock());
    if (wait.isNegative) wait = Duration.zero;
    // One second late is fine; it keeps a just-expired grant from
    // re-arming a zero timer against a clock that hasn't quite passed it.
    _expiryTimer = Timer(wait + const Duration(seconds: 1), () {
      unawaited(pruneExpired());
    });
  }

  Future<void> _persistLedger() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_ledger.isEmpty) {
        await prefs.remove(_ledgerKey);
      } else {
        await prefs.setString(_ledgerKey, _ledger.encode());
      }
    } catch (e) {
      AppLogger.warning('TemporaryGrants: could not save the ledger: $e');
    }
  }

  // ==================== Ad trials ====================

  /// Ads already watched today towards a trial of [kind]/[id].
  int trialAdsWatched(TemporaryGrantKind kind, String id) =>
      CosmeticTrialProgress.watchedFor(
        _trialProgress,
        TemporaryGrant.keyFor(kind, id),
        _clock(),
      );

  /// The ad trial running now, if any. Only one runs at a time.
  TemporaryGrant? get activeAdTrial => _ledger.activeAdTrial(_clock());

  /// Count one completed rewarded ad towards a trial of [kind]/[id] and
  /// return how many have been watched today (1 or 2). Progress resets when
  /// it reaches [CosmeticTrialProgress.adsRequired]; the caller then grants.
  Future<int> recordTrialAd(TemporaryGrantKind kind, String id) async {
    await (_loading ??= _readFromPrefs());
    final key = TemporaryGrant.keyFor(kind, id);
    final next = CosmeticTrialProgress.afterAd(_trialProgress, key, _clock());
    final done = next.adsWatched >= CosmeticTrialProgress.adsRequired;
    _trialProgress = done ? null : next;
    try {
      final prefs = await SharedPreferences.getInstance();
      final progress = _trialProgress;
      if (progress == null) {
        await prefs.remove(_trialProgressKey);
      } else {
        await prefs.setString(_trialProgressKey, progress.encode());
      }
    } catch (e) {
      AppLogger.warning('TemporaryGrants: could not save trial progress: $e');
    }
    _changes.add(_ledger);
    return next.adsWatched;
  }

  void dispose() {
    _expiryTimer?.cancel();
    _changes.close();
    _expirations.close();
  }
}
