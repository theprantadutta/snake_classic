import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/tuning/game_tuning.dart';
import 'package:snake_classic/utils/constants.dart';

/// How a run is paced: the starting tick and how hard the speed ramps.
class RunPace {
  const RunPace({
    required this.assistLevel,
    this.startingSpeedMs,
    this.rampScale = 1.0,
  });

  /// 0 = no assist.
  final int assistLevel;

  /// Override for the base tick, or null for the difficulty's own.
  final int? startingSpeedMs;

  /// Multiplies the level and length speed-ups (1.0 = unchanged; 0.7 =
  /// 30% gentler).
  final double rampScale;

  static const RunPace standard = RunPace(assistLevel: 0);
}

/// Adaptive assist: a quietly gentler snake for players who keep dying in
/// the first seconds.
///
/// Why: on day 0, players whose runs average under 15 s come back the next
/// day 8% of the time; 60 s+ runs, 30%+. Same pattern at equal run counts
/// (1–3 runs: 11% vs 24%). Skill explains part of that, which is why this
/// ships behind an A/B experiment (tuning key `assist_enabled`) rather than
/// for everyone.
///
/// Rules, all deliberately narrow:
///   * Normal difficulty only. Easy is already gentle; Hard is a choice.
///   * Never in tournaments or timed/precision modes, which are compared
///     against other players or a clock.
///   * Never once the player's best score reaches
///     [GameTuning.assistBestScoreCap], so it cannot help anyone near the
///     leaderboards, and players outgrow it.
///   * It only ever makes the game easier, never harder. It never touches
///     prices, rewards or ads: difficulty is not a sales lever.
///
/// The level comes from the share of early deaths (runs shorter than
/// [GameTuning.assistEarlyDeathSeconds]) in the last
/// [GameTuning.assistWindowRuns] runs: none → 0, all → max. It needs at
/// least two runs, so the first games use the onboarding pace alone.
class AdaptiveAssist {
  const AdaptiveAssist._();

  /// Modes whose runs are free play, where a gentler pace changes nothing
  /// for anyone else.
  static const Set<GameMode> eligibleModes = {
    GameMode.classic,
    GameMode.multiFood,
    GameMode.powerUpMadness,
    GameMode.survival,
  };

  static int levelFor({
    required GameTuning tuning,
    required List<int> recentRunSeconds,
    required int bestScore,
  }) {
    if (!tuning.assistEnabled || tuning.assistMaxLevel <= 0) return 0;
    if (bestScore >= tuning.assistBestScoreCap) return 0;

    final window = recentRunSeconds.length > tuning.assistWindowRuns
        ? recentRunSeconds.sublist(
            recentRunSeconds.length - tuning.assistWindowRuns)
        : recentRunSeconds;
    if (window.length < 2) return 0;

    final early =
        window.where((s) => s < tuning.assistEarlyDeathSeconds).length;
    final share = early / window.length;
    // 0–19% → 0, 20–49% → 1, 50–74% → 2, 75%+ → 3 with max 3.
    final level = (share * (tuning.assistMaxLevel + 1)).floor();
    return level.clamp(0, tuning.assistMaxLevel);
  }

  /// The pace for the next run.
  ///
  /// [onboarding] keeps the existing first-three-games pace (for every
  /// player, assist or not); assist can only slow the start further.
  static RunPace paceFor({
    required GameTuning tuning,
    required Difficulty difficulty,
    required GameMode mode,
    required bool isTournament,
    required bool onboarding,
    required List<int> recentRunSeconds,
    required int bestScore,
  }) {
    if (isTournament || difficulty != Difficulty.normal) {
      return RunPace.standard;
    }

    final onboardingStart = onboarding ? tuning.onboardingStartSpeedMs : null;

    final level = eligibleModes.contains(mode)
        ? levelFor(
            tuning: tuning,
            recentRunSeconds: recentRunSeconds,
            bestScore: bestScore,
          )
        : 0;

    if (level == 0) {
      return RunPace(assistLevel: 0, startingSpeedMs: onboardingStart);
    }

    final assisted = difficulty.baseSpeed + level * tuning.assistSpeedStepMs;
    final start = onboardingStart == null || assisted > onboardingStart
        ? assisted
        : onboardingStart;
    final rampScale = (1.0 - level * tuning.assistRampStep).clamp(0.4, 1.0);

    return RunPace(
      assistLevel: level,
      startingSpeedMs: start,
      rampScale: rampScale,
    );
  }
}

/// The lengths of the player's recent runs, for [AdaptiveAssist].
///
/// Device-local (SharedPreferences): it describes how this player is doing
/// on this device right now, so it has no business travelling with the
/// account.
class RunHistoryStore {
  RunHistoryStore._();

  static RunHistoryStore instance = RunHistoryStore._();
  static RunHistoryStore createForTest() => RunHistoryStore._();

  static const String _key = 'assist_recent_runs_v1';
  static const int capacity = 10;

  SharedPreferences? _prefs;
  List<int> _runs = const [];

  List<int> get recentRunSeconds => _runs;

  Future<void> initialize({SharedPreferences? prefs}) async {
    try {
      _prefs = prefs ?? await SharedPreferences.getInstance();
      _runs = (_prefs!.getStringList(_key) ?? const [])
          .map(int.tryParse)
          .whereType<int>()
          .toList(growable: false);
    } catch (_) {
      _runs = const [];
    }
  }

  /// Adds a finished run's length (seconds), keeping the newest [capacity].
  Future<void> record(int seconds) async {
    if (seconds < 0) return;
    final next = [..._runs, seconds];
    _runs = next.length > capacity
        ? next.sublist(next.length - capacity)
        : List.unmodifiable(next);
    try {
      await _prefs?.setStringList(
          _key, _runs.map((s) => s.toString()).toList());
    } catch (_) {}
  }
}
