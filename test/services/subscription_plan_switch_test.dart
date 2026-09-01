import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_state.dart';
import 'package:snake_classic/services/purchase_service.dart';

/// Plan switching, from the state's point of view.
///
/// Snake Classic had no plan-switch path at all: every purchase went through
/// a plain `PurchaseParam`, so a monthly subscriber tapping "Yearly" was
/// asking Play to buy a subscription they already hold, which the store
/// rejects as "already owned". The fix names the old purchase and picks a
/// replacement mode by direction — and the direction is what these cover,
/// because getting it backwards moves real money the wrong way.
void main() {
  PremiumState pro(String? productId, {bool promo = false}) => PremiumState(
        status: PremiumStatus.ready,
        tier: PremiumTier.pro,
        subscriptionExpiry: DateTime.now().add(const Duration(days: 20)),
        activeSubscriptionId: productId,
        isOnPromo: promo,
      );

  group('plan is read from the store product id', () {
    test('monthly', () {
      expect(pro(ProductIds.snakeClassicProMonthly).plan, PremiumPlan.monthly);
    });

    test('yearly', () {
      expect(pro(ProductIds.snakeClassicProYearly).plan, PremiumPlan.yearly);
    });

    test('a free user has no plan', () {
      expect(const PremiumState().plan, PremiumPlan.none);
    });

    test('Pro granted by promo has no plan', () {
      // A promo holder is Pro but pays nothing, so there is no subscription to
      // replace. Treating them as monthly would offer a switch that Play would
      // reject, because there is no old purchase to name.
      final state = pro(null, promo: true);
      expect(state.hasPremium, isTrue);
      expect(state.plan, PremiumPlan.none);
      expect(state.hasPaidSubscription, isFalse);
      expect(state.switchTarget, isNull);
    });
  });

  group('switch target is the other billing period', () {
    test('monthly offers yearly', () {
      expect(
        pro(ProductIds.snakeClassicProMonthly).switchTarget,
        PremiumPlan.yearly,
      );
    });

    test('yearly offers monthly', () {
      expect(
        pro(ProductIds.snakeClassicProYearly).switchTarget,
        PremiumPlan.monthly,
      );
    });

    test('a free user is offered no switch', () {
      expect(const PremiumState().switchTarget, isNull);
    });
  });

  group('the copy matches what Play will actually bill', () {
    test('upgrading to yearly takes effect immediately', () {
      // chargeProratedPrice: billed now, unused month credited. The screen
      // says "starts today", so it had better.
      expect(
        pro(ProductIds.snakeClassicProMonthly).switchTakesEffectImmediately,
        isTrue,
      );
    });

    test('downgrading to monthly is deferred', () {
      // deferred: the paid year runs out first and nothing is charged today.
      // Saying "starts today" here would promise a refund we do not give.
      expect(
        pro(ProductIds.snakeClassicProYearly).switchTakesEffectImmediately,
        isFalse,
      );
    });
  });

  group('an expired subscription is not a live plan', () {
    test('expired Pro does not offer a switch', () {
      final expired = PremiumState(
        status: PremiumStatus.ready,
        tier: PremiumTier.pro,
        subscriptionExpiry: DateTime.now().subtract(const Duration(days: 1)),
        activeSubscriptionId: ProductIds.snakeClassicProMonthly,
      );
      expect(expired.hasPremium, isFalse);
      expect(expired.hasPaidSubscription, isFalse,
          reason: 'a lapsed subscriber should see the paywall, not a switch');
    });
  });

  group('subscription ids', () {
    test('both plans are registered as subscriptions', () {
      // switchSubscription() rejects anything not in this list, so a typo here
      // would silently turn a plan change back into a plain (rejected) buy.
      expect(
        ProductIds.subscriptionIds,
        containsAll(<String>[
          ProductIds.snakeClassicProMonthly,
          ProductIds.snakeClassicProYearly,
        ]),
      );
    });

    test('subscriptions are not consumable', () {
      for (final id in ProductIds.subscriptionIds) {
        expect(ProductIds.consumableIds, isNot(contains(id)));
      }
    });
  });
}
