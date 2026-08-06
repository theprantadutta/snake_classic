import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/utils/logger.dart';

/// Device-local first-run state — the backbone of the "play first" onboarding.
///
/// A brand-new install used to cross eleven gates before the snake moved
/// (legal reader → auth wall → guest warning → username → 7-step walkthrough →
/// daily bonus → notification ask → mode sheet → 3s pre-game loader). Analytics
/// showed ~23% of installs never finished sign-in and ~40% never started a
/// single game, against a casual/arcade D1 benchmark of 25–32%. This service is
/// what lets every one of those gates ask "has this player actually played
/// yet?" and defer itself if not. See RETENTION_PLAN.md.
///
/// **SharedPreferences, not Drift — deliberately.** Per CLAUDE.md's storage
/// rule, first-run flags are device-only state that must NOT travel with the
/// user. Two properties fall out of that and both are wanted:
///   * A reinstall or a new device gets the gentle first-run treatment again —
///     that player really is new to *this* device and re-learning the controls.
///   * A cloud restore that lands a 10k high score can never retroactively
///     mark onboarding "done" for a device that has not rendered a frame of
///     gameplay, which is what would happen if this lived in a synced table.
///
/// Counts games **started**, not finished, so a player who rage-quits three
/// runs mid-game still graduates out of onboarding rather than being trapped
/// in it forever.
class FirstRunService {
  static final FirstRunService _instance = FirstRunService._();
  factory FirstRunService() => _instance;
  FirstRunService._();

  static const _kInstalledAtMs = 'first_run_installed_at_ms';
  static const _kGamesStarted = 'first_run_games_started';
  static const _kFirstGameLogged = 'first_run_first_game_logged';

  /// Games after which the full metagame UI comes online (walkthrough, the
  /// complete nav grid, the mode picker, the pre-game loader). Three is enough
  /// for a player to understand what the game IS and to have a score worth
  /// protecting — which is precisely what makes the deferred sign-in prompt
  /// convert where the up-front wall did not.
  static const int onboardingGameCount = 3;

  SharedPreferences? _prefs;
  bool _initialized = false;

  /// Warms the prefs cache and stamps the install time on the very first
  /// launch. Must be awaited in `main()` before any UI reads the sync getters
  /// below; they fail safe (treating the user as fully onboarded) if it never
  /// ran, so a missed init degrades to the old behaviour rather than showing
  /// first-run UI to a veteran.
  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _prefs = await SharedPreferences.getInstance();
      if (!_prefs!.containsKey(_kInstalledAtMs)) {
        await _prefs!.setInt(
          _kInstalledAtMs,
          DateTime.now().millisecondsSinceEpoch,
        );
        AppLogger.lifecycle('FirstRunService: new install stamped');
      }
      _initialized = true;
    } catch (e) {
      AppLogger.error('FirstRunService init failed', e);
    }
  }

  /// Number of games started on this device. 0 until the first tap of Play.
  int get gamesStarted => _prefs?.getInt(_kGamesStarted) ?? 0;

  /// True before the player has started a single game. Gates the things that
  /// must never precede gameplay: prompts, popups, permission asks, loaders.
  ///
  /// Fails safe to `false` when prefs are unavailable, so a storage failure
  /// shows the normal experience rather than trapping someone in onboarding.
  bool get isFirstGame => _prefs != null && gamesStarted == 0;

  /// True while the player is still inside the gentle first-run window.
  bool get isInOnboarding =>
      _prefs != null && gamesStarted < onboardingGameCount;

  /// True once the player has finished with the first-run treatment. Used by
  /// the deferred sign-in prompt as its "now they have something to lose" cue.
  bool get hasCompletedOnboarding => !isInOnboarding;

  /// Milliseconds since this install first launched, or null if unknown.
  int? get msSinceInstall {
    final stamped = _prefs?.getInt(_kInstalledAtMs);
    if (stamped == null) return null;
    return DateTime.now().millisecondsSinceEpoch - stamped;
  }

  /// Records a game start and, exactly once per install, emits
  /// `first_game_started` with the install→first-play latency. That latency is
  /// the headline number the whole retention effort is trying to drive down,
  /// so it is measured from the install stamp rather than from session start —
  /// a user who bounces off the front door and returns an hour later should
  /// show up as an hour, not as five seconds.
  Future<void> recordGameStarted() async {
    final prefs = _prefs;
    if (prefs == null) return;

    try {
      final next = gamesStarted + 1;
      await prefs.setInt(_kGamesStarted, next);

      if (next == 1 && !(prefs.getBool(_kFirstGameLogged) ?? false)) {
        await prefs.setBool(_kFirstGameLogged, true);
        final elapsedMs = msSinceInstall;
        if (elapsedMs != null && getIt.isRegistered<AnalyticsFacade>()) {
          getIt<AnalyticsFacade>().trackFirstGameStarted(
            secondsSinceInstall: (elapsedMs / 1000).round(),
          );
        }
        AppLogger.lifecycle(
          'FirstRunService: first game started '
          '(${elapsedMs != null ? '${(elapsedMs / 1000).round()}s' : 'unknown'} '
          'since install)',
        );
      }
    } catch (e) {
      AppLogger.error('FirstRunService.recordGameStarted failed', e);
    }
  }
}
