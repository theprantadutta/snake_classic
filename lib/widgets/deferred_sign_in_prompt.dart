import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/first_run_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/logger.dart';
import 'package:snake_classic/widgets/account_upgrade_sheet.dart';

/// The sign-in ask, moved to the moment it actually converts.
///
/// Onboarding used to demand an account before the player had seen the board.
/// That is backwards: someone with a score of zero has nothing to persist and
/// no reason to care, and ~23% of installs simply left rather than answer.
/// This prompt waits until the player has a personal best worth protecting,
/// then offers to save it — the same request, with a reason attached.
///
/// Gating, in order:
///   * still a guest (signed-in players never see it);
///   * finished the first-run window ([FirstRunService.onboardingGameCount]);
///   * just set a new personal best — the one moment their score is
///     demonstrably valuable to them;
///   * at least [_minDaysBetweenAsks] since the last ask;
///   * at most [_maxAsks] asks ever.
///
/// The last two are the anti-nag budget. A prompt that reappears every session
/// trains players to dismiss it on reflex and costs more goodwill than the
/// conversions are worth, so this asks a few times at good moments and then
/// stops forever. Profile keeps a permanent, always-available entry point for
/// anyone who wants to sign in on their own terms.
class DeferredSignInPrompt {
  DeferredSignInPrompt._();

  static const _kLastAskMs = 'deferred_signin_last_ask_ms';
  static const _kAskCount = 'deferred_signin_ask_count';

  static const int _maxAsks = 3;
  static const Duration _minDaysBetweenAsks = Duration(days: 3);

  /// Shows the prompt if every gate above passes. Returns true if the player
  /// connected an account.
  ///
  /// [isNewHighScore] should be the game-over screen's own verdict, so the ask
  /// lands on the beat where the player is already feeling good about the run.
  /// Never throws — a failure to read prefs silently skips the ask rather than
  /// interrupting the game-over flow.
  static Future<bool> maybeShow(
    BuildContext context, {
    required bool isSignedIn,
    required bool isNewHighScore,
    required GameTheme theme,
  }) async {
    if (isSignedIn) return false;
    if (!isNewHighScore) return false;
    if (!FirstRunService().hasCompletedOnboarding) return false;

    try {
      final prefs = await SharedPreferences.getInstance();

      final askCount = prefs.getInt(_kAskCount) ?? 0;
      if (askCount >= _maxAsks) return false;

      final lastAskMs = prefs.getInt(_kLastAskMs);
      if (lastAskMs != null) {
        final since = DateTime.now().millisecondsSinceEpoch - lastAskMs;
        if (since < _minDaysBetweenAsks.inMilliseconds) return false;
      }

      if (!context.mounted) return false;

      // Budget is spent on SHOWING, not on converting — otherwise a player who
      // dismisses three times in a row keeps being asked forever.
      await prefs.setInt(_kAskCount, askCount + 1);
      await prefs.setInt(
        _kLastAskMs,
        DateTime.now().millisecondsSinceEpoch,
      );

      if (!context.mounted) return false;

      final analytics =
          getIt.isRegistered<AnalyticsFacade>() ? getIt<AnalyticsFacade>() : null;
      analytics?.trackOnboardingStepShown('deferred_sign_in');

      final connected = await showAccountUpgradeSheet(context);
      if (connected) {
        analytics?.trackOnboardingStepCompleted('deferred_sign_in');
      }
      return connected;
    } catch (e) {
      AppLogger.error('DeferredSignInPrompt.maybeShow failed', e);
      return false;
    }
  }
}
