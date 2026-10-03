import 'dart:async';
import 'dart:convert';

import 'package:snake_classic/data/daos/telemetry_dao.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/services/api_service.dart';
import 'package:snake_classic/services/telemetry/install_identity.dart';
import 'package:snake_classic/utils/logger.dart';

/// Sends dirty telemetry rows to `POST /telemetry/batch`.
///
/// Deliberately NOT the SyncEngine. The SyncEngine drains only for signed-in
/// players, and guests — no account, an install id only — are exactly the
/// people the retention funnel loses. Telemetry is also not user state: it
/// has no outbox, nothing on the server is reconciled from it, and resending
/// is harmless because the server keeps the max of every counter.
///
/// Flushed on app start, on background, when connectivity returns, every
/// [flushInterval] while foregrounded (TelemetryService arranges all four),
/// and right after a feedback answer. A row is marked uploaded only on a 200;
/// [_send] covers every other answer the server gives.
class TelemetryUploader {
  TelemetryUploader({
    required this._dao,
    required this._api,
    required this._identity,
    required this._locale,
    required this._installedAt,
    this._beforeFlush,
    bool Function()? canAttempt,
    DateTime Function()? clock,
  })  : _canAttempt = canAttempt ?? (() => true),
        _clock = clock ?? DateTime.now;

  /// Contract limits for one request.
  static const int maxSessionsPerBatch = 50;
  static const int maxFeedbackPerBatch = 20;
  static const int maxBodyBytes = 256 * 1024;

  /// The server allows 30 requests per 10 minutes per install. A backlog
  /// larger than this many batches waits for the next flush.
  static const int maxBatchesPerFlush = 5;

  static const Duration flushInterval = Duration(minutes: 5);

  /// Uploaded rows are kept this long, then pruned.
  static const Duration uploadedRetention = Duration(days: 14);

  /// Rows that never got through are dropped after this long — a bound on
  /// storage for a device that cannot reach the server for weeks.
  static const Duration staleRetention = Duration(days: 30);

  final TelemetryDao _dao;
  final ApiService _api;
  final InstallIdentity? Function() _identity;
  final String Function() _locale;
  final DateTime? Function() _installedAt;
  final Future<void> Function()? _beforeFlush;
  final bool Function() _canAttempt;
  final DateTime Function() _clock;

  Future<void>? _inFlight;
  bool _again = false;
  Timer? _periodic;

  /// Set by a 429. Until then a flush still writes and prunes locally but
  /// sends nothing — the next scheduled flush is soon enough, and asking
  /// again sooner only spends the limit.
  DateTime? _rateLimitedUntil;

  /// Send everything dirty. A call while a flush is running schedules one
  /// more pass after it rather than a second concurrent one, so an answer
  /// submitted mid-upload still goes out now.
  Future<void> flush() {
    final running = _inFlight;
    if (running != null) {
      _again = true;
      return running;
    }
    final run = _flushLoop();
    _inFlight = run;
    return run;
  }

  Future<void> _flushLoop() async {
    try {
      do {
        _again = false;
        await _flushOnce();
      } while (_again);
    } finally {
      _inFlight = null;
    }
  }

  Future<void> _flushOnce() async {
    try {
      // The open session is written first, so the batch carries it as it
      // stands right now rather than as of the last debounced write.
      await _beforeFlush?.call();

      final identity = _identity();
      final limited = _rateLimitedUntil;
      final backingOff = limited != null && _clock().isBefore(limited);
      if (identity != null && !backingOff && _canAttempt()) {
        for (var i = 0; i < maxBatchesPerFlush; i++) {
          final more = await _sendOneBatch(identity);
          if (!more) break;
        }
      }

      final now = _clock();
      await _dao.prune(
        uploadedBefore: now.subtract(uploadedRetention),
        staleBefore: now.subtract(staleRetention),
      );
    } catch (e) {
      AppLogger.error('Telemetry: flush failed', e);
    }
  }

  /// Send one batch of dirty rows. Returns whether another batch is worth
  /// sending now: only after a full batch that the server answered.
  Future<bool> _sendOneBatch(InstallIdentity identity) async {
    final sessions = await _dao.dirtySessions(limit: maxSessionsPerBatch);
    final feedback = await _dao.dirtyFeedback(limit: maxFeedbackPerBatch);
    if (sessions.isEmpty && feedback.isEmpty) return false;

    // The server's own checks, applied here first. A row that would fail
    // them would take its whole batch down with it (one bad item rejects
    // all), so it is set aside before it can.
    final badSessions = {
      for (final s in sessions)
        if (!isValidSession(s)) s.sessionId,
    };
    final badFeedback = {
      for (final f in feedback)
        if (!isValidFeedback(f)) f.feedbackId,
    };
    if (badSessions.isNotEmpty || badFeedback.isNotEmpty) {
      AppLogger.warning(
        'Telemetry: set aside ${badSessions.length} session(s) and '
        '${badFeedback.length} answer(s) that fail the contract',
      );
      await _dao.poisonSessions(badSessions.toList());
      await _dao.deleteFeedback(badFeedback.toList());
    }

    final outcome = await _send(
      identity,
      [for (final s in sessions) if (!badSessions.contains(s.sessionId)) s],
      [for (final f in feedback) if (!badFeedback.contains(f.feedbackId)) f],
    );
    final answered =
        outcome == _Outcome.accepted || outcome == _Outcome.rejected;
    return answered &&
        (sessions.length == maxSessionsPerBatch ||
            feedback.length == maxFeedbackPerBatch);
  }

  /// POST [sessions] + [feedback], handling the server's answers:
  ///   * 200 — mark them uploaded;
  ///   * 413, or a body known to be over the limit — split in two and send
  ///     each half; a single row too large on its own is set aside;
  ///   * 400 — the whole batch was refused and nothing written. Every row in
  ///     it is set aside: resending the same batch can only fail the same way;
  ///   * 429 — rate limited; nothing more is sent until the next scheduled
  ///     flush. Not an error;
  ///   * anything else (offline, 5xx) — the rows stay dirty for next time.
  Future<_Outcome> _send(
    InstallIdentity identity,
    List<TelemetrySession> sessions,
    List<TelemetryFeedbackData> feedback,
  ) async {
    if (sessions.isEmpty && feedback.isEmpty) return _Outcome.accepted;
    final count = sessions.length + feedback.length;
    final body = buildBody(identity, sessions, feedback);

    // Known to be too large: treat exactly like the server's 413 without
    // spending a request on it.
    var status = 413;
    if (count == 1 || utf8.encode(jsonEncode(body)).length <= maxBodyBytes) {
      final result = await _api.postTelemetryBatch(body);
      status = result.statusCode ?? 0;
    }

    switch (status) {
      case 200:
        final at = _clock();
        await _dao.markSessionsUploaded(
          {for (final s in sessions) s.sessionId: s.revision},
          at,
        );
        await _dao.markFeedbackUploaded(
          [for (final f in feedback) f.feedbackId],
          at,
        );
        return _Outcome.accepted;

      case 413 when count > 1:
        final sHalf = sessions.length ~/ 2;
        final fHalf = feedback.length ~/ 2;
        final first = await _send(
          identity,
          sessions.sublist(0, sHalf),
          feedback.sublist(0, fHalf),
        );
        if (first == _Outcome.rateLimited || first == _Outcome.failed) {
          return first;
        }
        return _send(identity, sessions.sublist(sHalf), feedback.sublist(fHalf));

      case 400:
      case 413:
        AppLogger.warning(
          'Telemetry: server refused a batch ($status) — setting aside '
          '${sessions.length} session(s) and ${feedback.length} answer(s)',
        );
        await _dao.poisonSessions([for (final s in sessions) s.sessionId]);
        await _dao.deleteFeedback([for (final f in feedback) f.feedbackId]);
        return _Outcome.rejected;

      case 429:
        // A little short of a full interval, so the next periodic tick is
        // past it rather than racing it.
        _rateLimitedUntil =
            _clock().add(flushInterval - const Duration(seconds: 30));
        AppLogger.info('Telemetry: rate limited, waiting for the next flush');
        return _Outcome.rateLimited;

      default:
        AppLogger.warning('Telemetry: batch not sent (status $status)');
        return _Outcome.failed;
    }
  }

  /// Lower-case words joined by underscores: how the server wants `design`,
  /// `platform` and `trigger`.
  static final RegExp _token = RegExp(r'^[a-z][a-z0-9_]*$');
  static final RegExp _uuid = RegExp(
    r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
  );
  static final RegExp _day = RegExp(r'^\d{4}-\d{2}-\d{2}$');

  /// The server's acceptance rules for one session.
  static bool isValidSession(TelemetrySession s) =>
      _uuid.hasMatch(s.sessionId) &&
      _token.hasMatch(s.design) &&
      s.appVersion.isNotEmpty &&
      _day.hasMatch(s.localDay) &&
      [
        s.build,
        s.foregroundMs,
        s.runsStarted,
        s.runsFinished,
        s.runsAgain,
        s.bestScore,
        s.totalScore,
        s.runMs,
        s.multiplayerMatches,
        s.adImpressionsBanner,
        s.adImpressionsInterstitial,
        s.adImpressionsRewarded,
        s.adImpressionsAppOpen,
        s.rewardedCompleted,
        s.rewardedAbandoned,
        s.adRevenueMicros,
        s.purchasesStarted,
        s.purchasesCompleted,
        s.storeViews,
      ].every((v) => v >= 0);

  /// The server's acceptance rules for one feedback answer.
  static bool isValidFeedback(TelemetryFeedbackData f) =>
      _uuid.hasMatch(f.feedbackId) &&
      _token.hasMatch(f.design) &&
      _token.hasMatch(f.trigger) &&
      f.rating >= 1 &&
      f.rating <= 5 &&
      (f.comment?.length ?? 0) <= 500;

  /// The request body, snake_case like the rest of the API.
  Map<String, dynamic> buildBody(
    InstallIdentity identity,
    List<TelemetrySession> sessions,
    List<TelemetryFeedbackData> feedback,
  ) {
    final installedAt = _installedAt();
    return {
      'install_id': identity.installId,
      'app_version': identity.appVersion,
      'build': identity.build,
      'platform': identity.platform,
      'design': identity.design,
      'locale': _locale(),
      'installed_at': ?_iso(installedAt),
      'sessions': [for (final s in sessions) sessionJson(s)],
      'feedback': [for (final f in feedback) feedbackJson(f)],
    };
  }

  static Map<String, dynamic> sessionJson(TelemetrySession s) => {
    'session_id': s.sessionId,
    'design': s.design,
    'app_version': s.appVersion,
    'build': s.build,
    'started_at': _iso(s.startedAt),
    'ended_at': _iso(s.endedAt),
    'local_day': s.localDay,
    'foreground_ms': s.foregroundMs,
    'runs_started': s.runsStarted,
    'runs_finished': s.runsFinished,
    'runs_again': s.runsAgain,
    'best_score': s.bestScore,
    'total_score': s.totalScore,
    'run_ms': s.runMs,
    'multiplayer_matches': s.multiplayerMatches,
    'ad_impressions_banner': s.adImpressionsBanner,
    'ad_impressions_interstitial': s.adImpressionsInterstitial,
    'ad_impressions_rewarded': s.adImpressionsRewarded,
    'ad_impressions_app_open': s.adImpressionsAppOpen,
    'rewarded_completed': s.rewardedCompleted,
    'rewarded_abandoned': s.rewardedAbandoned,
    'ad_revenue_micros': s.adRevenueMicros,
    'purchases_started': s.purchasesStarted,
    'purchases_completed': s.purchasesCompleted,
    'store_views': s.storeViews,
    'abnormal_end': s.abnormalEnd,
  };

  static Map<String, dynamic> feedbackJson(TelemetryFeedbackData f) => {
    'feedback_id': f.feedbackId,
    'design': f.design,
    'app_version': f.appVersion,
    'rating': f.rating,
    'comment': f.comment,
    'trigger': f.trigger,
    'created_at': _iso(f.createdAt),
  };

  static String? _iso(DateTime? t) => t?.toUtc().toIso8601String();

  // ==================== Scheduling ====================

  /// Flush every [flushInterval] until [stopPeriodic]. Idempotent.
  void startPeriodic() {
    _periodic ??= Timer.periodic(flushInterval, (_) => unawaited(flush()));
  }

  void stopPeriodic() {
    _periodic?.cancel();
    _periodic = null;
  }
}

enum _Outcome { accepted, rejected, rateLimited, failed }
