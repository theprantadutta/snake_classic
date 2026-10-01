import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/presentation/bloc/power_up/power_up_cubit.dart';

void main() {
  group('legacy power-up inventory keys', () {
    test('every legacy key folds into a type that works in play', () {
      for (final entry in PowerUpCubit.legacyInventoryKeys.entries) {
        expect(
          PowerUpCubit.typeFromInventoryKey(entry.value),
          isNotNull,
          reason: '${entry.key} -> ${entry.value} must be activatable',
        );
      }
    });

    test('working and unknown keys are left alone', () {
      for (final key in ['speed_boost', 'invincibility', 'score_multiplier', 'slow_motion', 'something_new']) {
        expect(PowerUpCubit.normaliseInventoryKey(key), key);
      }
    });

    test('Pro and battle-pass legacy grants map as documented', () {
      expect(PowerUpCubit.normaliseInventoryKey('teleport'), 'speed_boost');
      expect(PowerUpCubit.normaliseInventoryKey('ghostMode'), 'invincibility');
      expect(PowerUpCubit.normaliseInventoryKey('score_shield'), 'invincibility');
      expect(PowerUpCubit.normaliseInventoryKey('magneticFood'), 'score_multiplier');
      expect(PowerUpCubit.normaliseInventoryKey('megaSlowMotion'), 'slow_motion');
    });
  });
}
