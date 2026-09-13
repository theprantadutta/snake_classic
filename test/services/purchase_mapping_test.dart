import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snake_classic/services/purchases/product_ids.dart';
import 'package:snake_classic/services/purchases/purchase_mapping.dart';

/// The decisions behind PurchaseService that do not need a store.
///
/// Every one of these moves real money or real entitlements: which backend
/// answers mean "deliver", what the backend is told about a purchase, which
/// Play offer a subscription buys, and what the free-trial badge says.
void main() {
  // ---------------------------------------------------------------- fixtures

  PurchaseAndroid android({
    String productId = ProductIds.coinPackSmall,
    String? token = 'tok_1',
    String? orderId = 'GPA.1',
    PurchaseState state = PurchaseState.Purchased,
    bool? acknowledged = false,
  }) =>
      PurchaseAndroid(
        id: orderId ?? token ?? '',
        isAutoRenewing: false,
        productId: productId,
        purchaseState: state,
        purchaseToken: token,
        quantity: 1,
        store: IapStore.Google,
        transactionDate: 0,
        transactionId: orderId,
        isAcknowledgedAndroid: acknowledged,
      );

  PurchaseIOS ios({
    String productId = ProductIds.goldenSnake,
    String? jws = 'eyJ.jws.sig',
    String transactionId = '2000000123',
  }) =>
      PurchaseIOS(
        id: transactionId,
        isAutoRenewing: false,
        productId: productId,
        purchaseState: PurchaseState.Purchased,
        purchaseToken: jws,
        quantity: 1,
        store: IapStore.Apple,
        transactionDate: 0,
        transactionId: transactionId,
      );

  PricingPhaseAndroid phase({
    required String micros,
    String period = 'P1M',
    int recurrence = 1,
    int cycles = 0,
    String formatted = r'$4.99',
  }) =>
      PricingPhaseAndroid(
        billingCycleCount: cycles,
        billingPeriod: period,
        formattedPrice: formatted,
        priceAmountMicros: micros,
        priceCurrencyCode: 'USD',
        recurrenceMode: recurrence,
      );

  SubscriptionOffer androidOffer({
    required String id,
    String basePlan = 'monthly',
    String? offerToken = 'offer_tok',
    required List<PricingPhaseAndroid> phases,
  }) =>
      SubscriptionOffer(
        id: id,
        basePlanIdAndroid: basePlan,
        offerTokenAndroid: offerToken,
        displayPrice: phases.first.formattedPrice,
        price: 0,
        type: DiscountOfferType.Introductory,
        pricingPhasesAndroid: PricingPhasesAndroid(pricingPhaseList: phases),
      );

  final basePlanOnly = androidOffer(
    id: 'monthly',
    phases: [phase(micros: '4990000')],
  );
  final withTrial = androidOffer(
    id: 'trial-3d',
    offerToken: 'trial_tok',
    phases: [
      phase(micros: '0', period: 'P3D', recurrence: 3, formatted: 'Free'),
      phase(micros: '4990000'),
    ],
  );

  ProductSubscriptionAndroid androidSub(List<SubscriptionOffer> offers) =>
      ProductSubscriptionAndroid(
        currency: 'USD',
        description: '',
        displayPrice: offers.first.displayPrice,
        id: ProductIds.snakeClassicProMonthly,
        nameAndroid: 'Pro',
        subscriptionOffers: offers,
        title: 'Pro',
      );

  // -------------------------------------------------- backend verdicts

  group('what the backend reply means for delivery', () {
    test('a verified receipt is delivered', () {
      expect(
        classifyVerifyResponse({'is_valid': true}),
        VerifyOutcome.granted,
      );
    });

    test('no reply at all (offline, 401, 5xx) is retried later', () {
      expect(classifyVerifyResponse(null), VerifyOutcome.transient);
    });

    test('an explicit no is a refusal', () {
      expect(
        classifyVerifyResponse({'is_valid': false, 'message': 'Invalid purchase'}),
        VerifyOutcome.rejected,
      );
      expect(classifyVerifyResponse({}), VerifyOutcome.rejected);
    });

    test('the stable "not now" codes are retried, whatever the wording', () {
      for (final code in transientBackendErrorPrefixes) {
        expect(
          classifyVerifyResponse({'is_valid': false, 'error': '$code: anything'}),
          VerifyOutcome.transient,
          reason: code,
        );
      }
    });

    test('a batch entry reports its reason under "message"', () {
      // The batch endpoint copies Result.Error into each item's message.
      expect(
        classifyVerifyResponse({
          'is_valid': false,
          'message': 'PURCHASE_PENDING: still processing',
        }),
        VerifyOutcome.transient,
      );
    });
  });

  // -------------------------------------------------- backend payload

  group('what the backend is told', () {
    test('Android sends the purchase token as receipt AND token, keyed by order id', () {
      final payload = backendPayloadFor(android())!;
      expect(payload.platform, 'android');
      expect(payload.transactionId, 'GPA.1');
      expect(payload.receiptData, 'tok_1');
      expect(payload.purchaseToken, 'tok_1');
    });

    test('a pending Play purchase has no order id yet, so the token keys it', () {
      final payload = backendPayloadFor(
        android(orderId: null, state: PurchaseState.Pending),
      )!;
      expect(payload.transactionId, 'tok_1');
    });

    test('an Android purchase without a token cannot be verified', () {
      expect(backendPayloadFor(android(token: null)), isNull);
      expect(backendPayloadFor(android(token: '')), isNull);
    });

    test('iOS sends the signed transaction as the receipt, keyed by transaction id', () {
      final payload = backendPayloadFor(ios())!;
      expect(payload.platform, 'ios');
      expect(payload.transactionId, '2000000123');
      expect(payload.receiptData, 'eyJ.jws.sig');
      expect(payload.purchaseToken, isNull);
    });

    test('the retry queue round-trips under the legacy keys', () {
      final payload = backendPayloadFor(android())!;
      final restored = BackendPurchasePayload.fromJson(payload.toJson())!;
      expect(restored.toJson(), payload.toJson());
      expect(restored.toBatchEntry()['platform'], 'android');
      expect(
        (restored.toBatchEntry()['purchase_data'] as Map)['purchase_token'],
        'tok_1',
      );
    });

    test('a queue entry written by an older build still parses', () {
      final legacy = BackendPurchasePayload.fromJson({
        'product_id': ProductIds.coinPackMega,
        'transaction_id': 'GPA.9',
        'platform': 'android',
        'receipt_data': 'tok_9',
        'purchase_token': 'tok_9',
        'queued_at': '2026-01-01T00:00:00Z',
      });
      expect(legacy, isNotNull);
      expect(legacy!.productId, ProductIds.coinPackMega);
    });
  });

  group('the key a delivered purchase is remembered under', () {
    test('Android uses the order id, as the previous plugin did', () {
      expect(purchaseIdentity(android()), 'GPA.1');
    });

    test('a pending Android purchase falls back to its token', () {
      expect(purchaseIdentity(android(orderId: null)), 'tok_1');
    });

    test('iOS uses the transaction id', () {
      expect(purchaseIdentity(ios()), '2000000123');
    });
  });

  // -------------------------------------------------- purchase requests

  group('the request that buys a product', () {
    const user = '3f2504e0-4f89-11d3-9a0c-0305e82c3301';

    test('a one-time product is tagged with the account on both stores', () {
      final props = buildPurchaseRequest(
        product: ProductAndroid(
          currency: 'USD',
          description: '',
          displayPrice: r'$0.99',
          id: ProductIds.coinPackSmall,
          nameAndroid: 'Coins',
          title: 'Coins',
        ),
        accountId: user,
      );
      final json = props.toJson();
      expect(json['type'], 'in-app');
      final request = json['requestPurchase'] as Map;
      expect((request['google'] as Map)['obfuscatedAccountId'], user);
      expect((request['apple'] as Map)['appAccountToken'], user);
    });

    test('StoreKit only accepts a UUID account token, so anything else is left off', () {
      final props = buildPurchaseRequest(
        product: ProductAndroid(
          currency: 'USD',
          description: '',
          displayPrice: r'$0.99',
          id: ProductIds.coinPackSmall,
          nameAndroid: 'Coins',
          title: 'Coins',
        ),
        accountId: 'user-123',
      );
      final request = props.toJson()['requestPurchase'] as Map;
      expect((request['apple'] as Map)['appAccountToken'], isNull);
      // Play takes any string.
      expect((request['google'] as Map)['obfuscatedAccountId'], 'user-123');
    });

    test('a subscription buys the free-trial offer when Play lists one', () {
      final props = buildPurchaseRequest(
        product: androidSub([basePlanOnly, withTrial]),
        accountId: user,
      );
      final json = props.toJson();
      expect(json['type'], 'subs');
      final google = (json['requestSubscription'] as Map)['google'] as Map;
      final offers = google['subscriptionOffers'] as List;
      expect((offers.single as Map)['offerToken'], 'trial_tok');
    });

    test('with no trial on offer the base plan is bought', () {
      final props = buildPurchaseRequest(
        product: androidSub([basePlanOnly]),
        accountId: user,
      );
      final google =
          (props.toJson()['requestSubscription'] as Map)['google'] as Map;
      final offers = google['subscriptionOffers'] as List;
      expect((offers.single as Map)['offerToken'], 'offer_tok');
    });

    test('a plan switch names the old purchase and the replacement mode', () {
      final props = buildPurchaseRequest(
        product: androidSub([basePlanOnly]),
        accountId: user,
        replacing: const OwnedSubscription(
          productId: ProductIds.snakeClassicProYearly,
          purchaseToken: 'old_tok',
        ),
        replacementMode: SubscriptionReplacementModeAndroid.Deferred,
      );
      final google =
          (props.toJson()['requestSubscription'] as Map)['google'] as Map;
      expect(google['purchaseToken'], 'old_tok');
      final replacement = google['subscriptionProductReplacementParams'] as Map;
      expect(replacement['oldProductId'], ProductIds.snakeClassicProYearly);
      expect(replacement['replacementMode'], 'deferred');
    });
  });

  // -------------------------------------------------- prices and trials

  group('the price a subscription shows', () {
    test('is the recurring phase, not the free trial that comes first', () {
      expect(recurringPriceFromOffers([withTrial]), r'$4.99');
    });

    test('prefers the base plan when several offers carry a price', () {
      final promo = androidOffer(
        id: 'promo',
        phases: [
          phase(micros: '1990000', recurrence: 2, cycles: 3, formatted: r'$1.99'),
          phase(micros: '4990000'),
        ],
      );
      expect(recurringPriceFromOffers([promo, basePlanOnly]), r'$4.99');
    });

    test('is unknown when no phase carries a price', () {
      expect(recurringPriceFromOffers([]), isNull);
      expect(recurringPriceFromOffers(null), isNull);
    });
  });

  group('the free trial the store actually offers', () {
    test('Android: the zero-priced, non-recurring phase, in days', () {
      expect(freeTrialDays(androidSub([basePlanOnly, withTrial])), 3);
    });

    test('Android: a week-long trial is seven days, not one', () {
      final weekTrial = androidOffer(
        id: 'trial-1w',
        phases: [
          phase(micros: '0', period: 'P1W', recurrence: 3, formatted: 'Free'),
          phase(micros: '4990000'),
        ],
      );
      expect(freeTrialDays(androidSub([weekTrial])), 7);
    });

    test('Android: a free base plan is not a trial', () {
      final freeForever = androidOffer(
        id: 'free',
        phases: [phase(micros: '0', recurrence: 1, formatted: 'Free')],
      );
      expect(freeTrialDays(androidSub([freeForever])), isNull);
    });

    test('Android: no trial on offer means no badge', () {
      expect(freeTrialDays(androidSub([basePlanOnly])), isNull);
    });

    test('iOS: a free-trial introductory offer, period times count', () {
      final product = ProductSubscriptionIOS(
        currency: 'USD',
        description: '',
        displayNameIOS: 'Pro',
        displayPrice: r'$4.99',
        id: ProductIds.snakeClassicProMonthly,
        introductoryPricePaymentModeIOS: PaymentModeIOS.FreeTrial,
        isFamilyShareableIOS: false,
        jsonRepresentationIOS: '{}',
        title: 'Pro',
        typeIOS: ProductTypeIOS.AutoRenewableSubscription,
        subscriptionOffers: const [
          SubscriptionOffer(
            id: 'intro',
            displayPrice: 'Free',
            price: 0,
            type: DiscountOfferType.Introductory,
            paymentMode: PaymentMode.FreeTrial,
            period: SubscriptionPeriod(unit: SubscriptionPeriodUnit.Day, value: 3),
            periodCount: 1,
          ),
        ],
      );
      expect(freeTrialDays(product), 3);
    });

    test('iOS: a paid introductory offer is not a trial', () {
      final product = ProductSubscriptionIOS(
        currency: 'USD',
        description: '',
        displayNameIOS: 'Pro',
        displayPrice: r'$4.99',
        id: ProductIds.snakeClassicProMonthly,
        introductoryPricePaymentModeIOS: PaymentModeIOS.PayAsYouGo,
        isFamilyShareableIOS: false,
        jsonRepresentationIOS: '{}',
        title: 'Pro',
        typeIOS: ProductTypeIOS.AutoRenewableSubscription,
        subscriptionOffers: const [
          SubscriptionOffer(
            id: 'intro',
            displayPrice: r'$0.99',
            price: 0.99,
            type: DiscountOfferType.Introductory,
            paymentMode: PaymentMode.PayAsYouGo,
            period: SubscriptionPeriod(unit: SubscriptionPeriodUnit.Month, value: 1),
            periodCount: 1,
          ),
        ],
      );
      expect(freeTrialDays(product), isNull);
    });
  });
}
