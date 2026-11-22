import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snake_classic/models/temporary_grant.dart';
import 'package:snake_classic/services/temporary_grants_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  var now = DateTime(2026, 11, 22, 10);
  TemporaryGrantsService service() => TemporaryGrantsService(clock: () => now);

  setUp(() {
    now = DateTime(2026, 11, 22, 10);
    SharedPreferences.setMockInitialValues({});
  });

  TemporaryGrant skinTrial(DateTime expires) => TemporaryGrant(
    kind: TemporaryGrantKind.skin,
    id: 'fire',
    expiresAt: expires,
    source: TemporaryGrantSource.adTrial,
    previousId: 'classic',
  );

  test('a grant persists across instances (an app restart)', () async {
    final a = service();
    await a.load();
    await a.grant(skinTrial(now.add(TemporaryGrant.duration)));
    a.dispose();

    final b = service();
    expect(await b.load(), isEmpty);
    expect(b.ledger.isActive(TemporaryGrantKind.skin, 'fire', now), isTrue);
    expect(b.activeAdTrial?.id, 'fire');
    b.dispose();
  });

  test(
    'a grant that expired while the app was closed is announced on load',
    () async {
      final a = service();
      await a.load();
      await a.grant(skinTrial(now.add(TemporaryGrant.duration)));
      a.dispose();

      now = now.add(const Duration(hours: 25));
      final b = service();
      final announced = <List<TemporaryGrant>>[];
      final sub = b.expirations.listen(announced.add);
      final expired = await b.load();
      await Future<void>.delayed(Duration.zero);

      expect(expired.map((g) => g.id), ['fire']);
      expect(announced.single.single.previousId, 'classic');
      expect(b.ledger.isEmpty, isTrue);
      await sub.cancel();
      b.dispose();

      // And it is gone from storage, so it is not announced twice.
      final c = service();
      expect(await c.load(), isEmpty);
      c.dispose();
    },
  );

  test('pruneExpired on resume drops only what ran out', () async {
    final s = service();
    await s.load();
    await s.grant(skinTrial(now.add(const Duration(hours: 1))));
    await s.grant(
      TemporaryGrant(
        kind: TemporaryGrantKind.xpBoost,
        id: TemporaryGrant.xpBoostId,
        expiresAt: now.add(TemporaryGrant.duration),
        source: TemporaryGrantSource.dailyBonus,
      ),
    );
    expect(s.seasonXpMultiplier, 2);

    now = now.add(const Duration(hours: 2));
    final expired = await s.pruneExpired();
    expect(expired.map((g) => g.kind), [TemporaryGrantKind.skin]);
    expect(s.seasonXpMultiplier, 2);

    now = now.add(const Duration(hours: 23));
    expect(s.seasonXpMultiplier, 1);
    s.dispose();
  });

  test('two completed ads for the same item reach the trial; progress then '
      'resets', () async {
    final s = service();
    await s.load();
    expect(s.trialAdsWatched(TemporaryGrantKind.trail, 'trail_glow'), 0);
    expect(await s.recordTrialAd(TemporaryGrantKind.trail, 'trail_glow'), 1);
    expect(s.trialAdsWatched(TemporaryGrantKind.trail, 'trail_glow'), 1);

    // Progress survives a restart within the day.
    final again = service();
    await again.load();
    expect(again.trialAdsWatched(TemporaryGrantKind.trail, 'trail_glow'), 1);
    expect(
      await again.recordTrialAd(TemporaryGrantKind.trail, 'trail_glow'),
      2,
    );
    expect(again.trialAdsWatched(TemporaryGrantKind.trail, 'trail_glow'), 0);
    s.dispose();
    again.dispose();
  });

  test('progress is per item and per day', () async {
    final s = service();
    await s.load();
    await s.recordTrialAd(TemporaryGrantKind.trail, 'trail_glow');
    expect(await s.recordTrialAd(TemporaryGrantKind.skin, 'fire'), 1);
    expect(s.trialAdsWatched(TemporaryGrantKind.trail, 'trail_glow'), 0);

    now = now.add(const Duration(days: 1));
    expect(s.trialAdsWatched(TemporaryGrantKind.skin, 'fire'), 0);
    s.dispose();
  });
}
