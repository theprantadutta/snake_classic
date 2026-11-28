import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/services/tuning/game_tuning.dart';
import 'package:snake_classic/services/tuning/tuning_service.dart';

/// Server game tuning: the document the backend publishes is clamped,
/// cached and split into A/B groups on the device. The load-bearing promise
/// is that nothing the server sends (or fails to send) can break the game:
/// defaults equal the pre-tuning behaviour, values are clamped, and a
/// player never changes group.
void main() {
  group('GameTuning.fromValues', () {
    test('empty map gives the built-in defaults (pre-tuning behaviour)', () {
      final t = GameTuning.fromValues(const {});
      expect(t, GameTuning.defaults);
      expect(t.assistEnabled, isFalse);
      expect(t.onboardingStartSpeedMs, 380);
      expect(t.interstitialEveryNGames, 2);
      expect(t.interstitialMinGapSeconds, 90);
      expect(t.reviveCoinCost, 1500);
    });

    test('reads every known key', () {
      final t = GameTuning.fromValues(const {
        'assist_enabled': true,
        'assist_max_level': 2,
        'assist_window_runs': 6,
        'assist_early_death_s': 20,
        'assist_speed_step_ms': 30,
        'assist_ramp_step': 0.2,
        'assist_best_score_cap': 800,
        'onboarding_start_speed_ms': 400,
        'interstitial_every_n_games': 3,
        'interstitial_min_gap_s': 120,
        'revive_coin_cost': 1000,
      });
      expect(t.assistEnabled, isTrue);
      expect(t.assistMaxLevel, 2);
      expect(t.assistWindowRuns, 6);
      expect(t.assistEarlyDeathSeconds, 20);
      expect(t.assistSpeedStepMs, 30);
      expect(t.assistRampStep, 0.2);
      expect(t.assistBestScoreCap, 800);
      expect(t.onboardingStartSpeedMs, 400);
      expect(t.interstitialEveryNGames, 3);
      expect(t.interstitialMinGapSeconds, 120);
      expect(t.reviveCoinCost, 1000);
    });

    test('clamps out-of-range values to the playable range', () {
      final t = GameTuning.fromValues(const {
        'assist_max_level': 99,
        'assist_window_runs': 0,
        'assist_speed_step_ms': 500,
        'assist_ramp_step': 5,
        'onboarding_start_speed_ms': 50,
        'interstitial_every_n_games': 0,
        'interstitial_min_gap_s': 1,
        'revive_coin_cost': 1,
      });
      expect(t.assistMaxLevel, 3);
      expect(t.assistWindowRuns, 2);
      expect(t.assistSpeedStepMs, 40);
      expect(t.assistRampStep, 0.3);
      expect(t.onboardingStartSpeedMs, 300);
      expect(t.interstitialEveryNGames, 1);
      expect(t.interstitialMinGapSeconds, 30);
      expect(t.reviveCoinCost, 100);
    });

    test('wrong types and unknown keys fall back / are ignored', () {
      final t = GameTuning.fromValues(const {
        'assist_enabled': 1,
        'revive_coin_cost': true,
        'interstitial_every_n_games': double.nan,
        'some_future_knob': 7,
      });
      expect(t, GameTuning.defaults);
    });

    test('rounds fractional integers', () {
      expect(
        GameTuning.fromValues(const {'interstitial_every_n_games': 2.6})
            .interstitialEveryNGames,
        3,
      );
    });
  });

  group('TuningDocument.parse', () {
    test('drops malformed parts instead of throwing', () {
      final doc = TuningDocument.parse({
        'version': 4,
        'config': {
          'values': {'a': 1, 'b': 'text', 'c': true, 'd': null},
          'experiments': [
            'nonsense',
            {'key': 'one_variant', 'variants': [
              {'name': 'x', 'weight': 1},
            ]},
            {'key': 'ok', 'variants': [
              {'name': 'x', 'weight': 1},
              {'name': 'bad', 'weight': -1},
              {'name': 'y', 'weight': 1, 'values': {'assist_enabled': true}},
            ]},
          ],
        },
      });
      expect(doc.version, 4);
      expect(doc.values, {'a': 1, 'c': true});
      expect(doc.experiments, hasLength(1));
      expect(doc.experiments.single.variants.map((v) => v.name), ['x', 'y']);
    });

    test('non-map bodies give the empty document', () {
      expect(TuningDocument.parse(null).version, 0);
      expect(TuningDocument.parse([1, 2]).experiments, isEmpty);
      expect(TuningDocument.parse({'version': 3}).version, 0);
      expect(TuningDocument.tryDecode('{not json'), isNull);
    });
  });

  group('experiment assignment', () {
    test('FNV-1a matches the reference value the backend reimplements', () {
      // Published FNV-1a 32-bit test vectors.
      expect(fnv1a32(''), 0x811c9dc5);
      expect(fnv1a32('a'), 0xe40c292c);
      expect(fnv1a32('foobar'), 0xbf9cf968);
    });

    const experiment = TuningExperiment(key: 'assist_v1', variants: [
      TuningVariant(name: 'control', weight: 50),
      TuningVariant(name: 'assist', weight: 50),
    ]);

    test('is stable for an install', () {
      final first = experiment.variantFor('install-123')!.name;
      for (var i = 0; i < 5; i++) {
        expect(experiment.variantFor('install-123')!.name, first);
      }
    });

    test('splits a population close to the weights', () {
      var assist = 0;
      const n = 4000;
      for (var i = 0; i < n; i++) {
        if (experiment.variantFor('device-$i')!.name == 'assist') assist++;
      }
      expect(assist / n, closeTo(0.5, 0.04));
    });

    test('a zero-weight variant is never chosen', () {
      const lopsided = TuningExperiment(key: 'k', variants: [
        TuningVariant(name: 'never', weight: 0),
        TuningVariant(name: 'always', weight: 10),
      ]);
      for (var i = 0; i < 200; i++) {
        expect(lopsided.variantFor('d$i')!.name, 'always');
      }
    });

    test('no install id means no variant', () {
      expect(experiment.variantFor(''), isNull);
    });
  });

  group('TuningService', () {
    Map<String, Object?> body({
      int version = 2,
      Map<String, Object?> values = const {},
      List<Object?> experiments = const [],
    }) =>
        {
          'version': version,
          'config': {'values': values, 'experiments': experiments},
        };

    Map<String, Object?> assistExperiment({String audience = 'new'}) => {
          'key': 'assist_v1',
          'audience': audience,
          'variants': [
            {'name': 'control', 'weight': 0, 'values': {}},
            {'name': 'assist', 'weight': 1, 'values': {'assist_enabled': true}},
          ],
        };

    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('starts on defaults with no cache and no network', () async {
      final s = TuningService.createForTest();
      await s.initialize(installId: 'i', gamesStarted: 0);
      expect(s.current, GameTuning.defaults);
      expect(s.version, 0);
      expect(s.variantLabel, isEmpty);
    });

    test('refresh applies, caches, and survives a restart offline', () async {
      final prefs = await SharedPreferences.getInstance();
      final s = TuningService.createForTest();
      await s.initialize(installId: 'i', gamesStarted: 5, prefs: prefs);
      await s.refresh(
        fetch: () async => body(values: {'interstitial_every_n_games': 3}),
        installId: 'i',
        gamesStarted: 5,
      );
      expect(s.current.interstitialEveryNGames, 3);
      expect(s.version, 2);

      final restarted = TuningService.createForTest();
      await restarted.initialize(installId: 'i', gamesStarted: 5, prefs: prefs);
      expect(restarted.current.interstitialEveryNGames, 3);
    });

    test('a failed or malformed fetch keeps what is in use', () async {
      final s = TuningService.createForTest();
      await s.initialize(installId: 'i', gamesStarted: 0);
      await s.refresh(
        fetch: () async => body(values: {'revive_coin_cost': 900}),
        installId: 'i',
        gamesStarted: 0,
      );
      await s.refresh(
          fetch: () async => null, installId: 'i', gamesStarted: 0);
      await s.refresh(
          fetch: () async => {'error': 'x'}, installId: 'i', gamesStarted: 0);
      await s.refresh(
          fetch: () async => throw Exception('offline'),
          installId: 'i',
          gamesStarted: 0);
      expect(s.current.reviveCoinCost, 900);
    });

    test('new install is enrolled and gets the variant values', () async {
      final s = TuningService.createForTest();
      await s.initialize(installId: 'fresh', gamesStarted: 0);
      await s.refresh(
        fetch: () async => body(experiments: [assistExperiment()]),
        installId: 'fresh',
        gamesStarted: 0,
      );
      expect(s.current.assistEnabled, isTrue);
      expect(s.variants, {'assist_v1': 'assist'});
      expect(s.variantLabel, 'assist_v1:assist');
    });

    test('an existing player is excluded from a new-players experiment, '
        'and stays excluded', () async {
      final prefs = await SharedPreferences.getInstance();
      final s = TuningService.createForTest();
      await s.initialize(installId: 'veteran', gamesStarted: 12, prefs: prefs);
      await s.refresh(
        fetch: () async => body(experiments: [assistExperiment()]),
        installId: 'veteran',
        gamesStarted: 12,
      );
      expect(s.current.assistEnabled, isFalse);
      expect(s.variants, isEmpty);
    });

    test('audience "all" enrols existing players too', () async {
      final s = TuningService.createForTest();
      await s.initialize(installId: 'veteran', gamesStarted: 12);
      await s.refresh(
        fetch: () async => body(experiments: [assistExperiment(audience: 'all')]),
        installId: 'veteran',
        gamesStarted: 12,
      );
      expect(s.current.assistEnabled, isTrue);
    });

    test('enrolment is sticky: re-weighting never moves a player', () async {
      final prefs = await SharedPreferences.getInstance();
      final s = TuningService.createForTest();
      await s.initialize(installId: 'p', gamesStarted: 0, prefs: prefs);
      await s.refresh(
        fetch: () async => body(experiments: [assistExperiment()]),
        installId: 'p',
        gamesStarted: 0,
      );
      expect(s.variants['assist_v1'], 'assist');

      // The operator flips the weights so every NEW player gets control.
      final flipped = {
        'key': 'assist_v1',
        'audience': 'new',
        'variants': [
          {'name': 'control', 'weight': 1, 'values': {}},
          {'name': 'assist', 'weight': 0, 'values': {'assist_enabled': true}},
        ],
      };
      await s.refresh(
        fetch: () async => body(experiments: [flipped]),
        installId: 'p',
        gamesStarted: 4,
      );
      expect(s.variants['assist_v1'], 'assist');
      expect(s.current.assistEnabled, isTrue);
    });

    test('a disabled experiment applies nothing', () async {
      final s = TuningService.createForTest();
      await s.initialize(installId: 'p', gamesStarted: 0);
      await s.refresh(
        fetch: () async => body(experiments: [
          {...assistExperiment(), 'enabled': false},
        ]),
        installId: 'p',
        gamesStarted: 0,
      );
      expect(s.current.assistEnabled, isFalse);
      expect(s.variants, isEmpty);
    });

    test('variant values override the base values', () async {
      final s = TuningService.createForTest();
      await s.initialize(installId: 'p', gamesStarted: 0);
      await s.refresh(
        fetch: () async => body(
          values: {'assist_enabled': false, 'revive_coin_cost': 1200},
          experiments: [assistExperiment()],
        ),
        installId: 'p',
        gamesStarted: 0,
      );
      expect(s.current.assistEnabled, isTrue);
      expect(s.current.reviveCoinCost, 1200);
    });
  });
}
