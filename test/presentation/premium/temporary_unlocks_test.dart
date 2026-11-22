import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/models/temporary_grant.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/progression_service.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/services/temporary_grants_service.dart';
import 'package:snake_classic/utils/constants.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final expiry = DateTime(2026, 11, 23, 10);

  group('PremiumState honours temporary unlocks', () {
    final withTrials = PremiumState(
      temporaryUnlocks: {
        TemporaryGrant.keyFor(TemporaryGrantKind.skin, 'fire'): expiry,
        TemporaryGrant.keyFor(TemporaryGrantKind.trail, 'trail_glow'): expiry,
        TemporaryGrant.keyFor(
          TemporaryGrantKind.theme,
          TemporaryGrant.themeGrantId(GameTheme.crystal),
        ): expiry,
      },
    );

    test('temporarily unlocked items are usable and selectable', () {
      expect(withTrials.isSkinUsable('fire'), isTrue);
      expect(withTrials.isSkinUnlocked(SnakeSkinType.fire), isTrue);
      expect(withTrials.isTrailUsable('trail_glow'), isTrue);
      expect(withTrials.isTrailUnlocked(TrailEffectType.glow), isTrue);
      expect(withTrials.isThemeUnlocked(GameTheme.crystal), isTrue);
    });

    test('but never count as owned', () {
      expect(withTrials.isSkinOwned('fire'), isFalse);
      expect(withTrials.isTrailOwned('trail_glow'), isFalse);
      expect(withTrials.ownedSkins, isEmpty);
      expect(withTrials.ownedThemes, isEmpty);
      expect(withTrials.isThemePermanentlyUnlocked(GameTheme.crystal), isFalse);
    });

    test('other premium items stay locked', () {
      expect(withTrials.isSkinUsable('dragon'), isFalse);
      expect(withTrials.isTrailUnlocked(TrailEffectType.dragon), isFalse);
      expect(withTrials.isThemeUnlocked(GameTheme.space), isFalse);
    });

    test('dropping the unlock locks the item again', () {
      final expired = withTrials.copyWith(temporaryUnlocks: const {});
      expect(expired.isSkinUsable('fire'), isFalse);
      expect(expired.isThemeUnlocked(GameTheme.crystal), isFalse);
      expect(expired == withTrials, isFalse);
    });

    test('expiry is exposed for the store footnote', () {
      expect(
        withTrials.temporaryUnlockExpiry(TemporaryGrantKind.skin, 'fire'),
        expiry,
      );
      expect(
        withTrials.temporaryUnlockExpiry(TemporaryGrantKind.skin, 'ice'),
        isNull,
      );
    });
  });

  group('daily bonus theme pick', () {
    final now = DateTime(2026, 11, 22);

    test('lends a locked premium theme, never Miami Nights', () {
      final pick = PremiumCubit.pickDailyBonusTheme(const PremiumState(), now);
      expect(pick, isNotNull);
      expect(PremiumContent.premiumThemes, contains(pick));
      expect(pick, isNot(GameTheme.miamiNights));
    });

    test('skips themes the player already has', () {
      final owned = PremiumContent.premiumThemes.toSet()
        ..remove(GameTheme.ocean);
      final pick = PremiumCubit.pickDailyBonusTheme(
        PremiumState(ownedThemes: owned),
        now,
      );
      expect(pick, GameTheme.ocean);
    });

    test('nothing to lend for Pro', () {
      // hasPremium compares against the real clock, so expire it from now.
      final pro = PremiumState(
        tier: PremiumTier.pro,
        subscriptionExpiry: DateTime.now().add(const Duration(days: 30)),
      );
      expect(PremiumCubit.pickDailyBonusTheme(pro, now), isNull);
    });
  });

  group('2x Season XP boost', () {
    var now = DateTime(2026, 11, 22, 10);

    setUp(() {
      now = DateTime(2026, 11, 22, 10);
      SharedPreferences.setMockInitialValues({});
    });

    BattlePassCubit cubit(TemporaryGrantsService? grants) => BattlePassCubit(
      storageService: StorageService(),
      analytics: AnalyticsFacade(const []),
      progressionService: ProgressionService(),
      temporaryGrants: grants,
    );

    Future<TemporaryGrantsService> boosted() async {
      final grants = TemporaryGrantsService(clock: () => now);
      await grants.load();
      await grants.grant(
        TemporaryGrant(
          kind: TemporaryGrantKind.xpBoost,
          id: TemporaryGrant.xpBoostId,
          expiresAt: now.add(TemporaryGrant.duration),
          source: TemporaryGrantSource.dailyBonus,
        ),
      );
      return grants;
    }

    test('doubles Season XP while it runs', () async {
      final grants = await boosted();
      final bp = cubit(grants);
      bp.bufferXP(15, source: 'daily_game');
      bp.bufferXP(5, source: 'game_completed');
      expect(bp.bufferedXp, 40);
      await bp.close();
      grants.dispose();
    });

    test('stops doubling once it expires', () async {
      final grants = await boosted();
      final bp = cubit(grants);
      bp.bufferXP(10);
      now = now.add(const Duration(hours: 24));
      bp.bufferXP(10);
      expect(bp.bufferedXp, 30);
      await bp.close();
      grants.dispose();
    });

    test('no boost, no change', () async {
      final bp = cubit(null);
      bp.bufferXP(10);
      expect(bp.bufferedXp, 10);
      await bp.close();
    });
  });
}
