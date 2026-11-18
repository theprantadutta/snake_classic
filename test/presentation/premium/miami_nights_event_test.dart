import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_state.dart';
import 'package:snake_classic/utils/constants.dart';

void main() {
  final end = PremiumContent.miamiNightsFreeUntil;

  test('Miami Nights is free until the event ends, then Pro-only', () {
    final during = end.subtract(const Duration(minutes: 1));
    expect(PremiumContent.isEventFree(GameTheme.miamiNights, during), isTrue);
    expect(PremiumContent.isEventFree(GameTheme.miamiNights, end), isFalse);
  });

  test('only Miami Nights has an event window', () {
    for (final t in GameTheme.values) {
      if (t == GameTheme.miamiNights) continue;
      expect(PremiumContent.isEventFree(t, DateTime(2026, 11, 20)), isFalse);
    }
  });

  test('the themes bundle can never grant it', () {
    expect(PremiumContent.premiumThemes, isNot(contains(GameTheme.miamiNights)));
    expect(PremiumContent.proOnlyThemes, contains(GameTheme.miamiNights));
  });

  test('it stays last so stored theme indexes keep their meaning', () {
    expect(GameTheme.values.last, GameTheme.miamiNights);
    expect(GameTheme.crystal.index, 9);
  });
}
