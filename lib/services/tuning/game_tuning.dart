import 'dart:convert';

/// Game tuning values: pacing, adaptive assist, ad cadence and revive price.
///
/// The backend publishes a JSON document (`GET /game-tuning`, edited on the
/// dashboard's Game tuning page) and this class is the only reader of it.
/// Every value is clamped to a range the game is known to be playable in, and
/// anything missing, malformed or out of range falls back to the built-in
/// default below. The defaults are exactly what the game did before tuning
/// existed, so a device that never reaches the server plays as it always has.
///
/// Keep [knownKeys] and the dashboard's reference table
/// (snake-classic-backend/dashboard/src/routes/(dashboard)/game-tuning) in
/// step when adding a knob.
class GameTuning {
  const GameTuning({
    this.assistEnabled = false,
    this.assistMaxLevel = 3,
    this.assistWindowRuns = 5,
    this.assistEarlyDeathSeconds = 15,
    this.assistSpeedStepMs = 25,
    this.assistRampStep = 0.15,
    this.assistBestScoreCap = 500,
    this.onboardingStartSpeedMs = 380,
    this.interstitialEveryNGames = 2,
    this.interstitialMinGapSeconds = 90,
    this.reviveCoinCost = 1500,
  });

  /// Adaptive assist on/off. Off by default: the first rollout is an A/B
  /// experiment that turns it on for half of new installs.
  final bool assistEnabled;

  /// Strongest assist level (0-3). 0 keeps tracking but applies nothing.
  final int assistMaxLevel;

  /// How many recent runs the assist level is computed from.
  final int assistWindowRuns;

  /// A run shorter than this (seconds) counts as an early death.
  final int assistEarlyDeathSeconds;

  /// Milliseconds added to the starting tick per assist level.
  final int assistSpeedStepMs;

  /// How much each assist level softens the speed ramp (0-0.3).
  final double assistRampStep;

  /// No assist once the player's best score reaches this.
  final int assistBestScoreCap;

  /// Starting tick for the first three (onboarding) games on Normal.
  final int onboardingStartSpeedMs;

  /// Game-over interstitial cadence (every N games).
  final int interstitialEveryNGames;

  /// Minimum seconds between two interstitials.
  final int interstitialMinGapSeconds;

  /// Coin price of the first revive / continue in a run.
  final int reviveCoinCost;

  static const GameTuning defaults = GameTuning();

  static const Set<String> knownKeys = {
    'assist_enabled',
    'assist_max_level',
    'assist_window_runs',
    'assist_early_death_s',
    'assist_speed_step_ms',
    'assist_ramp_step',
    'assist_best_score_cap',
    'onboarding_start_speed_ms',
    'interstitial_every_n_games',
    'interstitial_min_gap_s',
    'revive_coin_cost',
  };

  /// Builds tuning from a flat `{key: number|bool}` map, clamping each value
  /// and falling back to the default for anything missing or of the wrong
  /// type. Unknown keys are ignored (a newer dashboard may know more knobs
  /// than this build).
  factory GameTuning.fromValues(Map<String, Object?> values) {
    const d = defaults;
    return GameTuning(
      assistEnabled: _bool(values['assist_enabled'], d.assistEnabled),
      assistMaxLevel: _int(values['assist_max_level'], d.assistMaxLevel, 0, 3),
      assistWindowRuns:
          _int(values['assist_window_runs'], d.assistWindowRuns, 2, 10),
      assistEarlyDeathSeconds: _int(
          values['assist_early_death_s'], d.assistEarlyDeathSeconds, 5, 60),
      assistSpeedStepMs:
          _int(values['assist_speed_step_ms'], d.assistSpeedStepMs, 0, 40),
      assistRampStep:
          _double(values['assist_ramp_step'], d.assistRampStep, 0, 0.3),
      assistBestScoreCap: _int(
          values['assist_best_score_cap'], d.assistBestScoreCap, 0, 100000),
      onboardingStartSpeedMs: _int(values['onboarding_start_speed_ms'],
          d.onboardingStartSpeedMs, 300, 450),
      interstitialEveryNGames: _int(values['interstitial_every_n_games'],
          d.interstitialEveryNGames, 1, 10),
      interstitialMinGapSeconds: _int(values['interstitial_min_gap_s'],
          d.interstitialMinGapSeconds, 30, 600),
      reviveCoinCost:
          _int(values['revive_coin_cost'], d.reviveCoinCost, 100, 10000),
    );
  }

  static bool _bool(Object? raw, bool fallback) => raw is bool ? raw : fallback;

  static int _int(Object? raw, int fallback, int min, int max) {
    if (raw is! num || raw.isNaN || raw.isInfinite) return fallback;
    return raw.round().clamp(min, max);
  }

  static double _double(Object? raw, double fallback, double min, double max) {
    if (raw is! num || raw.isNaN || raw.isInfinite) return fallback;
    return raw.toDouble().clamp(min, max);
  }

  @override
  bool operator ==(Object other) =>
      other is GameTuning &&
      other.assistEnabled == assistEnabled &&
      other.assistMaxLevel == assistMaxLevel &&
      other.assistWindowRuns == assistWindowRuns &&
      other.assistEarlyDeathSeconds == assistEarlyDeathSeconds &&
      other.assistSpeedStepMs == assistSpeedStepMs &&
      other.assistRampStep == assistRampStep &&
      other.assistBestScoreCap == assistBestScoreCap &&
      other.onboardingStartSpeedMs == onboardingStartSpeedMs &&
      other.interstitialEveryNGames == interstitialEveryNGames &&
      other.interstitialMinGapSeconds == interstitialMinGapSeconds &&
      other.reviveCoinCost == reviveCoinCost;

  @override
  int get hashCode => Object.hash(
        assistEnabled,
        assistMaxLevel,
        assistWindowRuns,
        assistEarlyDeathSeconds,
        assistSpeedStepMs,
        assistRampStep,
        assistBestScoreCap,
        onboardingStartSpeedMs,
        interstitialEveryNGames,
        interstitialMinGapSeconds,
        reviveCoinCost,
      );
}

/// One experiment from the tuning document.
class TuningExperiment {
  const TuningExperiment({
    required this.key,
    required this.variants,
    this.newPlayersOnly = false,
    this.enabled = true,
  });

  final String key;
  final List<TuningVariant> variants;

  /// `audience: "new"` — only installs that had not started a game when
  /// they first saw this experiment are enrolled. Everyone else keeps the
  /// base values, so the comparison is between two groups of new players.
  final bool newPlayersOnly;
  final bool enabled;

  int get totalWeight => variants.fold(0, (sum, v) => sum + v.weight);

  /// The variant for [installId]: a stable hash of `key:installId` placed on
  /// the cumulative weights. Stable across launches and app versions, so a
  /// player never switches group, and the backend can recompute any
  /// install's group from telemetry with the same function.
  TuningVariant? variantFor(String installId) {
    final total = totalWeight;
    if (total <= 0 || installId.isEmpty) return null;
    final bucket = fnv1a32('$key:$installId') % total;
    var cumulative = 0;
    for (final v in variants) {
      cumulative += v.weight;
      if (bucket < cumulative) return v;
    }
    return variants.last;
  }
}

class TuningVariant {
  const TuningVariant({
    required this.name,
    required this.weight,
    this.values = const {},
  });

  final String name;
  final int weight;
  final Map<String, Object?> values;
}

/// The parsed tuning document.
class TuningDocument {
  const TuningDocument({
    this.version = 0,
    this.values = const {},
    this.experiments = const [],
  });

  final int version;
  final Map<String, Object?> values;
  final List<TuningExperiment> experiments;

  static const TuningDocument empty = TuningDocument();

  /// Parses the `GET /game-tuning` body (`{version, config: {values,
  /// experiments}}`). Malformed parts are dropped, never thrown: a broken
  /// document must degrade to the defaults, not to a crash at launch.
  static TuningDocument parse(Object? body) {
    if (body is! Map) return empty;
    final version = body['version'];
    final config = body['config'];
    if (config is! Map) return empty;

    final experiments = <TuningExperiment>[];
    final rawExperiments = config['experiments'];
    if (rawExperiments is List) {
      for (final raw in rawExperiments) {
        final parsed = _parseExperiment(raw);
        if (parsed != null) experiments.add(parsed);
      }
    }

    return TuningDocument(
      version: version is int ? version : 0,
      values: _flatValues(config['values']),
      experiments: experiments,
    );
  }

  static TuningDocument? tryDecode(String? json) {
    if (json == null || json.isEmpty) return null;
    try {
      return parse(jsonDecode(json));
    } catch (_) {
      return null;
    }
  }

  static TuningExperiment? _parseExperiment(Object? raw) {
    if (raw is! Map) return null;
    final key = raw['key'];
    final rawVariants = raw['variants'];
    if (key is! String || key.isEmpty || rawVariants is! List) return null;

    final variants = <TuningVariant>[];
    for (final v in rawVariants) {
      if (v is! Map) continue;
      final name = v['name'];
      final weight = v['weight'];
      if (name is! String || name.isEmpty || weight is! num || weight < 0) {
        continue;
      }
      variants.add(TuningVariant(
        name: name,
        weight: weight.round(),
        values: _flatValues(v['values']),
      ));
    }
    if (variants.length < 2) return null;

    return TuningExperiment(
      key: key,
      variants: variants,
      newPlayersOnly: raw['audience'] == 'new',
      enabled: raw['enabled'] != false,
    );
  }

  static Map<String, Object?> _flatValues(Object? raw) {
    if (raw is! Map) return const {};
    final out = <String, Object?>{};
    raw.forEach((k, v) {
      if (k is String && (v is num || v is bool)) out[k] = v;
    });
    return out;
  }
}

/// 32-bit FNV-1a over the UTF-8 bytes of [input]. Small, stable and easy to
/// reimplement server-side (C#: uint hash = 2166136261; foreach byte:
/// hash ^= b; hash *= 16777619).
int fnv1a32(String input) {
  var hash = 0x811c9dc5;
  for (final b in utf8.encode(input)) {
    hash ^= b;
    hash = (hash * 0x01000193) & 0xFFFFFFFF;
  }
  return hash;
}
