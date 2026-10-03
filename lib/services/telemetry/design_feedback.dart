import 'dart:async';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/data/daos/telemetry_dao.dart';
import 'package:snake_classic/data/database/app_database.dart';
import 'package:snake_classic/services/telemetry/install_identity.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:uuid/uuid.dart';

/// What the in-app feedback question needs to know about this install.
@immutable
class DesignFeedbackState {
  const DesignFeedbackState({
    required this.finishedRuns,
    required this.submitted,
    required this.dismissals,
    this.lastDismissedAt,
  });

  final int finishedRuns;
  final bool submitted;
  final int dismissals;
  final DateTime? lastDismissedAt;
}

/// When to ask "How's the game feeling?" (CONTRACT.md, "In-app feedback").
///
/// Pure, so the rules can be tested without prefs or widgets. Both designs
/// must ask on exactly these terms or their answers do not compare.
abstract final class DesignFeedbackPolicy {
  /// Finished runs on this install before the question can appear.
  static const int minFinishedRuns = 5;

  /// Time since install before the question can appear — long enough that
  /// the answer describes the game, not the first impression.
  static const Duration minInstallAge = Duration(days: 2);

  /// Dismissals after which the question never comes back.
  static const int maxDismissals = 2;

  /// After a first dismissal, the wait before the one second chance. Without
  /// it, a "not now" would be answered by the same sheet on the very next
  /// visit to Home.
  static const Duration redisplayAfter = Duration(days: 3);

  static bool isEligible(
    DesignFeedbackState state, {
    required DateTime? installedAt,
    required DateTime now,
  }) {
    if (state.submitted) return false;
    if (state.dismissals >= maxDismissals) return false;
    if (state.finishedRuns < minFinishedRuns) return false;
    // Unknown install time: wait rather than guess.
    if (installedAt == null) return false;
    if (now.difference(installedAt) < minInstallAge) return false;
    final last = state.lastDismissedAt;
    if (state.dismissals > 0 &&
        last != null &&
        now.difference(last) < redisplayAfter) {
      return false;
    }
    return true;
  }
}

/// The feedback question's device-local bookkeeping, in SharedPreferences:
/// first-run-style prompt state that describes this install and must never
/// travel (CLAUDE.md storage rule). The answers themselves go to Drift.
class DesignFeedbackStore {
  DesignFeedbackStore({Future<SharedPreferences> Function()? prefs})
      : _prefs = prefs ?? SharedPreferences.getInstance;

  static const _kFinishedRuns = 'telemetry_finished_runs';
  static const _kSubmitted = 'design_feedback_submitted';
  static const _kDismissals = 'design_feedback_dismissals';
  static const _kLastDismissedMs = 'design_feedback_last_dismissed_ms';

  final Future<SharedPreferences> Function() _prefs;

  /// Serialises the read-modify-write of the run counter: two game overs
  /// reported back to back must count as two.
  Future<void> _queue = Future.value();

  Future<void> recordFinishedRun() {
    _queue = _queue.then((_) async {
      final p = await _prefs();
      await p.setInt(_kFinishedRuns, (p.getInt(_kFinishedRuns) ?? 0) + 1);
    }).catchError(
      (Object e) => AppLogger.error('DesignFeedbackStore: run count failed', e),
    );
    return _queue;
  }

  Future<DesignFeedbackState> read() async {
    await _queue;
    final p = await _prefs();
    final lastMs = p.getInt(_kLastDismissedMs);
    return DesignFeedbackState(
      finishedRuns: p.getInt(_kFinishedRuns) ?? 0,
      submitted: p.getBool(_kSubmitted) ?? false,
      dismissals: p.getInt(_kDismissals) ?? 0,
      lastDismissedAt:
          lastMs == null ? null : DateTime.fromMillisecondsSinceEpoch(lastMs),
    );
  }

  Future<void> recordDismissed(DateTime at) async {
    final p = await _prefs();
    await p.setInt(_kDismissals, (p.getInt(_kDismissals) ?? 0) + 1);
    await p.setInt(_kLastDismissedMs, at.millisecondsSinceEpoch);
  }

  Future<void> recordSubmitted() async {
    final p = await _prefs();
    await p.setBool(_kSubmitted, true);
  }
}

/// Decides whether to ask, and records what the player answered.
class DesignFeedbackService {
  DesignFeedbackService({
    required this._store,
    required this._dao,
    required this._identity,
    required this._installedAt,
    this._onAnswered,
    DateTime Function()? clock,
    this._uuid = const Uuid(),
  }) : _clock = clock ?? DateTime.now;

  /// The `trigger` reported with every answer: the question appears only
  /// once the player has a few finished runs behind them.
  static const String triggerAfterRuns = 'after_runs';

  /// The longest comment the contract accepts.
  static const int maxCommentLength = 500;

  final DesignFeedbackStore _store;
  final TelemetryDao _dao;
  final InstallIdentity Function() _identity;
  final DateTime? Function() _installedAt;
  final Future<void> Function()? _onAnswered;
  final DateTime Function() _clock;
  final Uuid _uuid;

  /// One offer per process at most, whatever the answer: a player who swipes
  /// the sheet away and returns to Home should not meet it again until the
  /// policy says so — and never twice in a sitting.
  bool _offeredThisProcess = false;

  /// Whether to show the question now. Claims this process's one offer when
  /// it says yes, so two callers racing cannot both show it.
  Future<bool> claimOffer() async {
    if (_offeredThisProcess) return false;
    final state = await _store.read();
    final eligible = DesignFeedbackPolicy.isEligible(
      state,
      installedAt: _installedAt(),
      now: _clock(),
    );
    if (!eligible || _offeredThisProcess) return false;
    _offeredThisProcess = true;
    return true;
  }

  /// The player answered. The answer is written to Drift for the uploader,
  /// which is then asked to send it straight away.
  Future<void> submit({required int rating, String? comment}) async {
    final id = _identity();
    try {
      await _dao.insertFeedback(
        TelemetryFeedbackCompanion.insert(
          feedbackId: _uuid.v4(),
          design: id.design,
          appVersion: id.appVersion,
          rating: rating.clamp(1, 5),
          comment: Value(clampComment(comment)),
          trigger: triggerAfterRuns,
          createdAt: _clock(),
        ),
      );
    } catch (e) {
      AppLogger.error('DesignFeedback: answer could not be saved', e);
    }
    await _store.recordSubmitted();
    final onAnswered = _onAnswered;
    if (onAnswered != null) unawaited(onAnswered());
  }

  /// [comment] trimmed, empty as null, and cut to [maxCommentLength] UTF-16
  /// code units — the unit the server counts in. The text field limits
  /// characters, and one emoji is two code units, so a full field could
  /// otherwise be over the limit and have its whole batch refused. Never cuts
  /// a surrogate pair in half.
  static String? clampComment(String? comment) {
    final trimmed = comment?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    if (trimmed.length <= maxCommentLength) return trimmed;
    var end = maxCommentLength;
    final last = trimmed.codeUnitAt(end - 1);
    if (last >= 0xD800 && last <= 0xDBFF) end--;
    return trimmed.substring(0, end).trimRight();
  }

  /// The player closed the question without answering.
  Future<void> dismiss() => _store.recordDismissed(_clock());

  @visibleForTesting
  void resetOfferForTest() => _offeredThisProcess = false;
}
