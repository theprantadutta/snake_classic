import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/models/season_cosmetics.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final season = BattlePassSeason.createSampleSeason();

  /// First tier whose [premium]/free reward is of [type].
  (int, String) firstReward(
    BattlePassRewardType type, {
    required bool premium,
  }) {
    for (final level in season.levels) {
      final r = premium ? level.premiumReward : level.freeReward;
      if (r != null && r.type == type && r.itemId != null) {
        return (level.level, r.itemId!);
      }
    }
    throw StateError('no $type reward');
  }

  final (skinTier, skinId) = firstReward(
    BattlePassRewardType.skin,
    premium: true,
  );
  final (trailTier, trailId) = firstReward(
    BattlePassRewardType.trail,
    premium: false,
  );
  final (themeTier, themeId) = firstReward(
    BattlePassRewardType.theme,
    premium: false,
  );

  group('derived Season cosmetics', () {
    test('claimed tiers own their skin, trail and theme', () {
      final owned = SeasonCosmetics.fromClaims(
        season,
        claimedFreeTiers: {trailTier, themeTier},
        claimedPremiumTiers: {skinTier},
      );
      expect(owned.skins, {skinId});
      expect(owned.trails, {trailId});
      expect(owned.themes.map((t) => t.toString().split('.').last), [themeId]);
    });

    test('unclaimed tiers own nothing', () {
      final owned = SeasonCosmetics.fromClaims(
        season,
        claimedFreeTiers: const {},
        claimedPremiumTiers: const {},
      );
      expect(owned.isEmpty, isTrue);
      final state = PremiumState(seasonCosmetics: owned);
      expect(state.isSkinOwned(skinId), isFalse);
      expect(state.isTrailOwned(trailId), isFalse);
    });

    test('a premium reward stays owned after the pass / Pro lapses', () {
      // Derived from the claim alone: no entitlement is consulted.
      final owned = SeasonCosmetics.fromClaims(
        season,
        claimedFreeTiers: const {},
        claimedPremiumTiers: {skinTier},
      );
      final lapsed = PremiumState(
        tier: PremiumTier.free,
        seasonCosmetics: owned,
      );
      expect(lapsed.hasPremium, isFalse);
      expect(lapsed.isSkinOwned(skinId), isTrue);
      expect(lapsed.isSkinUsable(skinId), isTrue);
    });

    test('it never enters the owned sets that sync', () {
      final state = PremiumState(
        seasonCosmetics: SeasonCosmetics.fromClaims(
          season,
          claimedFreeTiers: {trailTier},
          claimedPremiumTiers: {skinTier},
        ),
      );
      expect(state.ownedSkins, isEmpty);
      expect(state.ownedTrails, isEmpty);
    });
  });

  group('backend entitlement apply', () {
    late PremiumCubit cubit;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      cubit = PremiumCubit(
        purchaseService: PurchaseService(),
        storageService: StorageService(),
        analytics: AnalyticsFacade(const []),
      );
    });

    tearDown(() => cubit.close());

    test(
      'a sync that omits Season rewards neither strips nor unequips them',
      () async {
        cubit.applySeasonCosmetics(
          SeasonCosmetics.fromClaims(
            season,
            claimedFreeTiers: {trailTier},
            claimedPremiumTiers: {skinTier},
          ),
        );
        await cubit.selectSkin(skinId);
        await cubit.selectTrail(trailId);
        expect(cubit.state.selectedSkinId, skinId);

        // The server knows only a bought golden skin.
        await cubit.applyBackendEntitlementsForTest({
          'owned_skins': ['golden'],
          'owned_trails': <String>[],
          'is_premium': false,
        });

        expect(cubit.state.ownedSkins, {'golden'});
        expect(cubit.state.isSkinOwned(skinId), isTrue);
        expect(cubit.state.isTrailOwned(trailId), isTrue);
        expect(cubit.state.selectedSkinId, skinId);
        expect(cubit.state.selectedTrailId, trailId);
      },
    );

    test('without the Season claim the same sync does reset it', () async {
      cubit.applySeasonCosmetics(
        SeasonCosmetics.fromClaims(
          season,
          claimedFreeTiers: const {},
          claimedPremiumTiers: {skinTier},
        ),
      );
      await cubit.selectSkin(skinId);
      // The claim is gone (e.g. another season's state restored).
      cubit.applySeasonCosmetics(SeasonCosmetics.none);
      await cubit.applyBackendEntitlementsForTest({
        'owned_skins': <String>[],
        'is_premium': false,
      });
      expect(cubit.state.selectedSkinId, 'classic');
    });

    test(
      'Season themes unlock and coin offers parse from premium-content',
      () async {
        cubit.applySeasonCosmetics(
          SeasonCosmetics.fromClaims(
            season,
            claimedFreeTiers: {themeTier},
            claimedPremiumTiers: const {},
          ),
        );
        await cubit.applyBackendEntitlementsForTest({
          'owned_themes': <String>[],
          'coin_cosmetics': [
            {
              'cosmetic_type': 'trail',
              'cosmetic_id': 'trail_glow',
              'coin_price': 300,
              'owned': false,
            },
            {'cosmetic_type': 'skin'}, // malformed: dropped
          ],
        });
        final theme = GameTheme.values.firstWhere(
          (t) => t.toString().split('.').last == themeId,
        );
        expect(cubit.state.isThemeUnlocked(theme), isTrue);
        expect(cubit.state.coinCosmetics, hasLength(1));
        expect(cubit.state.coinOfferFor('trail', 'trail_glow')?.price, 300);
      },
    );
  });
}
