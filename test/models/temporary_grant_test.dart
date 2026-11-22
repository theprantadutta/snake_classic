import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/models/temporary_grant.dart';
import 'package:snake_classic/utils/constants.dart';

void main() {
  final t0 = DateTime(2026, 11, 22, 10);

  TemporaryGrant grant(
    TemporaryGrantKind kind,
    String id,
    DateTime expires, {
    TemporaryGrantSource source = TemporaryGrantSource.adTrial,
    String? previousId,
  }) => TemporaryGrant(
    kind: kind,
    id: id,
    expiresAt: expires,
    source: source,
    previousId: previousId,
  );

  group('TemporaryGrant expiry', () {
    test('active strictly before its expiry, not at or after it', () {
      final g = grant(TemporaryGrantKind.skin, 'fire', t0);
      expect(g.isActiveAt(t0.subtract(const Duration(seconds: 1))), isTrue);
      expect(g.isActiveAt(t0), isFalse);
      expect(g.isActiveAt(t0.add(const Duration(hours: 1))), isFalse);
    });

    test('prune splits running grants from expired ones', () {
      final ledger = TemporaryGrantLedger.empty
          .upsert(grant(TemporaryGrantKind.skin, 'fire', t0))
          .upsert(
            grant(
              TemporaryGrantKind.trail,
              'trail_glow',
              t0.add(const Duration(hours: 5)),
            ),
          );
      final split = ledger.prune(t0.add(const Duration(minutes: 1)));
      expect(split.expired.map((g) => g.id), ['fire']);
      expect(split.active.grants.map((g) => g.id), ['trail_glow']);
      expect(split.active.nextExpiry, t0.add(const Duration(hours: 5)));
    });

    test('nothing expires early', () {
      final ledger = TemporaryGrantLedger.empty.upsert(
        grant(
          TemporaryGrantKind.theme,
          'space',
          t0.add(TemporaryGrant.duration),
        ),
      );
      final split = ledger.prune(
        t0.add(const Duration(hours: 23, minutes: 59)),
      );
      expect(split.expired, isEmpty);
      expect(split.active.grants, hasLength(1));
    });

    test('a repeat grant extends, never shortens, and keeps the first '
        'previousId', () {
      final first = grant(
        TemporaryGrantKind.xpBoost,
        TemporaryGrant.xpBoostId,
        t0.add(const Duration(hours: 20)),
        previousId: 'classic',
      );
      final shorter = grant(
        TemporaryGrantKind.xpBoost,
        TemporaryGrant.xpBoostId,
        t0.add(const Duration(hours: 2)),
        previousId: 'other',
      );
      final ledger = TemporaryGrantLedger.empty.upsert(first).upsert(shorter);
      expect(ledger.grants, hasLength(1));
      expect(ledger.grants.single.expiresAt, first.expiresAt);
      expect(ledger.grants.single.previousId, 'classic');

      final longer = grant(
        TemporaryGrantKind.xpBoost,
        TemporaryGrant.xpBoostId,
        t0.add(const Duration(hours: 30)),
      );
      expect(ledger.upsert(longer).grants.single.expiresAt, longer.expiresAt);
    });

    test('cosmeticUnlocks lists only running cosmetic grants', () {
      final ledger = TemporaryGrantLedger.empty
          .upsert(
            grant(
              TemporaryGrantKind.skin,
              'fire',
              t0.add(const Duration(hours: 1)),
            ),
          )
          .upsert(grant(TemporaryGrantKind.trail, 'trail_glow', t0))
          .upsert(
            grant(
              TemporaryGrantKind.xpBoost,
              TemporaryGrant.xpBoostId,
              t0.add(const Duration(hours: 1)),
            ),
          );
      expect(ledger.cosmeticUnlocks(t0.add(const Duration(minutes: 1))).keys, [
        'skin:fire',
      ]);
    });

    test('only one ad trial is reported as running', () {
      final ledger = TemporaryGrantLedger.empty.upsert(
        grant(
          TemporaryGrantKind.theme,
          'space',
          t0.add(const Duration(hours: 1)),
          source: TemporaryGrantSource.dailyBonus,
        ),
      );
      expect(ledger.activeAdTrial(t0), isNull);
      final withTrial = ledger.upsert(
        grant(
          TemporaryGrantKind.skin,
          'fire',
          t0.add(const Duration(hours: 1)),
        ),
      );
      expect(withTrial.activeAdTrial(t0)?.id, 'fire');
      expect(withTrial.activeAdTrial(t0.add(const Duration(hours: 2))), isNull);
    });
  });

  group('Season XP multiplier', () {
    final boost = grant(
      TemporaryGrantKind.xpBoost,
      TemporaryGrant.xpBoostId,
      t0.add(TemporaryGrant.duration),
      source: TemporaryGrantSource.dailyBonus,
    );

    test('is 2 while the boost runs and 1 after', () {
      final ledger = TemporaryGrantLedger.empty.upsert(boost);
      expect(ledger.seasonXpMultiplier(t0), 2);
      expect(ledger.seasonXpMultiplier(t0.add(const Duration(hours: 23))), 2);
      expect(ledger.seasonXpMultiplier(t0.add(TemporaryGrant.duration)), 1);
    });

    test('is 1 with no boost, and cosmetic grants do not count', () {
      expect(TemporaryGrantLedger.empty.seasonXpMultiplier(t0), 1);
      final ledger = TemporaryGrantLedger.empty.upsert(
        grant(
          TemporaryGrantKind.skin,
          'fire',
          t0.add(const Duration(hours: 1)),
        ),
      );
      expect(ledger.seasonXpMultiplier(t0), 1);
    });
  });

  group('serialization', () {
    test('round-trips', () {
      final ledger = TemporaryGrantLedger.empty
          .upsert(
            grant(
              TemporaryGrantKind.theme,
              'crystal',
              t0,
              source: TemporaryGrantSource.dailyBonus,
              previousId: 'classic',
            ),
          )
          .upsert(grant(TemporaryGrantKind.trail, 'trail_glow', t0));
      final back = TemporaryGrantLedger.decode(ledger.encode());
      expect(back.grants, hasLength(2));
      final theme = back.find(TemporaryGrantKind.theme, 'crystal')!;
      expect(theme.expiresAt.isAtSameMomentAs(t0), isTrue);
      expect(theme.source, TemporaryGrantSource.dailyBonus);
      expect(theme.previousId, 'classic');
    });

    test('junk decodes to an empty ledger, bad rows are dropped', () {
      expect(TemporaryGrantLedger.decode(null).isEmpty, isTrue);
      expect(TemporaryGrantLedger.decode('not json').isEmpty, isTrue);
      expect(TemporaryGrantLedger.decode('{"a":1}').isEmpty, isTrue);
      final mixed = TemporaryGrantLedger.decode(
        '[{"kind":"skin","id":"fire","expires_at":"2026-11-23T10:00:00Z",'
        '"source":"adTrial"},{"kind":"hat","id":"x"},42]',
      );
      expect(mixed.grants.map((g) => g.id), ['fire']);
    });

    test('theme grant ids are the enum identifier, not the display name', () {
      expect(TemporaryGrant.themeGrantId(GameTheme.miamiNights), 'miamiNights');
      for (final t in GameTheme.values) {
        expect(
          TemporaryGrant.themeFromGrantId(TemporaryGrant.themeGrantId(t)),
          t,
        );
      }
    });
  });

  group('trial progress', () {
    const key = 'skin:fire';

    test('counts ads for one item on one day', () {
      final one = CosmeticTrialProgress.afterAd(null, key, t0);
      expect(one.adsWatched, 1);
      expect(CosmeticTrialProgress.watchedFor(one, key, t0), 1);
      final two = CosmeticTrialProgress.afterAd(one, key, t0);
      expect(two.adsWatched, 2);
    });

    test('a new day or another item starts from zero', () {
      final one = CosmeticTrialProgress.afterAd(null, key, t0);
      final tomorrow = t0.add(const Duration(days: 1));
      expect(CosmeticTrialProgress.watchedFor(one, key, tomorrow), 0);
      expect(CosmeticTrialProgress.watchedFor(one, 'trail:trail_glow', t0), 0);
      expect(CosmeticTrialProgress.afterAd(one, key, tomorrow).adsWatched, 1);
    });

    test('round-trips and survives junk', () {
      final one = CosmeticTrialProgress.afterAd(null, key, t0);
      final back = CosmeticTrialProgress.decode(one.encode())!;
      expect(back.key, key);
      expect(back.adsWatched, 1);
      expect(CosmeticTrialProgress.decode('nope'), isNull);
    });
  });

  group('daily bonus items', () {
    test('days 3, 5 and 7 carry the three items', () {
      final byDay = {
        for (final b in DailyLoginBonus.getWeeklyBonuses()) b.day: b.item,
      };
      expect(byDay[3], DailyBonusItem.speedBoost);
      expect(byDay[5], DailyBonusItem.xpBoost);
      expect(byDay[7], DailyBonusItem.themeDay);
      expect(byDay.entries.where((e) => e.value != null).map((e) => e.key), [
        3,
        5,
        7,
      ]);
    });

    test('the popup fallback labels map too', () {
      expect(
        DailyBonusItem.fromLabel('Speed Boost'),
        DailyBonusItem.speedBoost,
      );
      expect(DailyBonusItem.fromLabel('2x XP Boost'), DailyBonusItem.xpBoost);
      expect(
        DailyBonusItem.fromLabel('Premium Theme'),
        DailyBonusItem.themeDay,
      );
      expect(DailyBonusItem.fromLabel(null), isNull);
    });
  });
}
