import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';

import 'product_ids.dart';

/// The pure half of the purchase flow: everything that can be decided from a
/// store object or a backend reply without talking to the store. Kept apart
/// from PurchaseService so it can be tested without a billing client.

// ---------------------------------------------------------------------------
// Backend verification
// ---------------------------------------------------------------------------

/// What the backend's answer to a receipt means for delivery.
enum VerifyOutcome {
  /// Verified and recorded. Deliver, then finish the store transaction.
  granted,

  /// Could not be verified right now: offline, not signed in yet, the
  /// store's server API unreachable, or the payment is still clearing.
  /// Deliver locally, keep the receipt queued, and retry later.
  transient,

  /// Looked at and refused. Deliver nothing.
  rejected,
}

/// Backend error codes that mean "not now" rather than "no". They are the
/// stable prefixes VerifyPurchaseCommandHandler puts in front of its
/// messages; the client matches on the prefix, never the wording.
const transientBackendErrorPrefixes = <String>[
  // Google's or Apple's API could not be reached.
  'PURCHASE_VERIFICATION_UNAVAILABLE',
  // A deferred payment (cash, carrier billing) the store has not cleared.
  'PURCHASE_PENDING',
  // The account is a guest. Resolves the moment they sign in for real.
  'ANONYMOUS_ACCOUNT_PURCHASE_BLOCKED',
];

/// Classify one reply from `/purchases/verify` (or one entry of the batch
/// endpoint). `null` is what ApiService returns when the backend could not
/// be reached or answered 401/5xx.
VerifyOutcome classifyVerifyResponse(Map<String, dynamic>? response) {
  if (response == null) return VerifyOutcome.transient;
  if (response['is_valid'] == true) return VerifyOutcome.granted;
  final reason = (response['error'] ?? response['message'])?.toString() ?? '';
  for (final prefix in transientBackendErrorPrefixes) {
    if (reason.startsWith(prefix)) return VerifyOutcome.transient;
  }
  return VerifyOutcome.rejected;
}

/// What `/purchases/verify` needs to see for one store purchase.
///
/// Field names are the wire names, and they are also the keys of the
/// persisted retry queue, so an entry queued by an older build still
/// parses.
class BackendPurchasePayload {
  const BackendPurchasePayload({
    required this.platform,
    required this.productId,
    required this.transactionId,
    required this.receiptData,
    this.purchaseToken,
  });

  /// 'android' or 'ios'.
  final String platform;

  /// The store product id (prefixed).
  final String productId;

  /// The backend's dedup key: the Play order id (GPA…) or the StoreKit 2
  /// transaction id. Falls back to the purchase token when Play has not
  /// issued an order id, which it does not for a purchase that is still
  /// pending.
  final String transactionId;

  /// Android: the purchase token. iOS: the signed transaction (JWS), which
  /// the backend verifies cryptographically.
  final String receiptData;

  /// Android only; the same token again, on the field the backend reads for
  /// the Google Play Developer API call.
  final String? purchaseToken;

  Map<String, dynamic> toJson() => {
        'product_id': productId,
        'transaction_id': transactionId,
        'platform': platform,
        'receipt_data': receiptData,
        'purchase_token': purchaseToken,
      };

  static BackendPurchasePayload? fromJson(Map<String, dynamic> json) {
    final productId = json['product_id']?.toString();
    final platform = json['platform']?.toString();
    if (productId == null || productId.isEmpty) return null;
    if (platform == null || platform.isEmpty) return null;
    return BackendPurchasePayload(
      platform: platform,
      productId: productId,
      transactionId: json['transaction_id']?.toString() ?? '',
      receiptData: json['receipt_data']?.toString() ?? '',
      purchaseToken: json['purchase_token']?.toString(),
    );
  }

  /// One entry of the `/purchases/verify-batch` body.
  Map<String, dynamic> toBatchEntry() => {
        'purchase_data': {
          'product_id': productId,
          'transaction_id': transactionId,
          'receipt_data': receiptData,
          'purchase_token': purchaseToken,
        },
        'platform': platform,
      };
}

/// Build the backend payload for a store purchase, or null when the store
/// gave us nothing a backend could check (no token / no signed transaction).
BackendPurchasePayload? backendPayloadFor(Purchase purchase) {
  if (purchase is PurchaseIOS) {
    // OpenIAP puts the StoreKit 2 JWS on the unified purchaseToken field.
    final jws = purchase.purchaseToken;
    if (jws == null || jws.isEmpty) return null;
    return BackendPurchasePayload(
      platform: 'ios',
      productId: purchase.productId,
      transactionId: purchase.transactionId,
      receiptData: jws,
    );
  }
  if (purchase is PurchaseAndroid) {
    final token = purchase.purchaseToken;
    if (token == null || token.isEmpty) return null;
    final orderId = purchase.transactionId;
    return BackendPurchasePayload(
      platform: 'android',
      productId: purchase.productId,
      transactionId: (orderId != null && orderId.isNotEmpty) ? orderId : token,
      receiptData: token,
      purchaseToken: token,
    );
  }
  return null;
}

/// The key a purchase is remembered under so a replay (StoreKit replays
/// unfinished transactions on every launch; Play reports every owned item
/// on every query) is delivered once.
///
/// Android uses the order id when Play issued one, which is also what the
/// previous billing plugin reported as the purchase id, so the set persisted
/// by older builds keeps protecting the same purchases.
String? purchaseIdentity(Purchase purchase) {
  final id = purchase is PurchaseIOS ? purchase.transactionId : purchase.id;
  return id.isEmpty ? null : id;
}

// ---------------------------------------------------------------------------
// Purchase requests
// ---------------------------------------------------------------------------

/// The subscription this account holds, as far as the store is concerned.
class OwnedSubscription {
  const OwnedSubscription({required this.productId, this.purchaseToken});

  final String productId;

  /// Android only. Play needs the OLD purchase's token to run a plan change
  /// as a replacement rather than a second, rejected, purchase.
  final String? purchaseToken;
}

final _uuid = RegExp(
  r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
);

/// StoreKit silently drops an `appAccountToken` that is not a UUID. Our
/// backend user id is a Guid, so it passes; anything else is left off
/// rather than sent to be discarded.
bool isUuid(String? value) => value != null && _uuid.hasMatch(value);

/// The request that buys [product], tagged with our user id so the store's
/// server notifications can be mapped back to this account.
///
/// Pass [replacing] to move an existing Android subscription to [product]
/// instead of starting a second one (Play rejects that as already owned).
/// StoreKit changes plans within a subscription group on its own, so the
/// iOS half of the request ignores it.
RequestPurchaseProps buildPurchaseRequest({
  required ProductCommon product,
  required String? accountId,
  OwnedSubscription? replacing,
  SubscriptionReplacementModeAndroid? replacementMode,
}) {
  final sku = product.id;
  final appAccountToken = isUuid(accountId) ? accountId : null;

  if (!ProductIds.isSubscription(sku)) {
    return RequestPurchaseProps.inApp((
      apple: RequestPurchaseIosProps(sku: sku, appAccountToken: appAccountToken),
      google: RequestPurchaseAndroidProps(
        skus: [sku],
        obfuscatedAccountId: accountId,
      ),
    ));
  }

  // Play requires an offer token on every subscription purchase. Only the
  // offers this user is eligible for come back from the store, so picking
  // the free-trial one when it is present is safe.
  final offers = product is ProductSubscriptionAndroid
      ? product.subscriptionOffers
      : const <SubscriptionOffer>[];
  final offer = pickSubscriptionOffer(offers);
  final offerToken = offer?.offerTokenAndroid;

  return RequestPurchaseProps.subs((
    apple: RequestSubscriptionIosProps(
      sku: sku,
      appAccountToken: appAccountToken,
    ),
    google: RequestSubscriptionAndroidProps(
      skus: [sku],
      obfuscatedAccountId: accountId,
      subscriptionOffers: offerToken == null
          ? null
          : [AndroidSubscriptionOfferInput(sku: sku, offerToken: offerToken)],
      purchaseToken: replacing?.purchaseToken,
      subscriptionProductReplacementParams: replacing == null
          ? null
          : SubscriptionProductReplacementParamsAndroid(
              oldProductId: replacing.productId,
              replacementMode: replacementMode ??
                  SubscriptionReplacementModeAndroid.WithTimeProration,
            ),
    ),
  ));
}

/// Which of a subscription's Android offers to buy.
///
/// The one with a free trial when there is one, otherwise the base plan,
/// otherwise whatever came first.
SubscriptionOffer? pickSubscriptionOffer(List<SubscriptionOffer> offers) {
  if (offers.isEmpty) return null;
  for (final offer in offers) {
    if (trialDaysFromOffer(offer) != null) return offer;
  }
  for (final offer in offers) {
    final basePlan = offer.basePlanIdAndroid;
    if (basePlan != null && offer.id == basePlan) return offer;
  }
  return offers.first;
}

// ---------------------------------------------------------------------------
// Prices and trials
// ---------------------------------------------------------------------------

/// Play's recurrenceMode for the perpetual base price.
const _infiniteRecurring = 1;

/// The formatted price of the recurring (non-zero) pricing phase across a
/// subscription's Android offers, or null when none has one.
///
/// A subscription's headline price is derived from its first pricing phase,
/// which reads as "Free" whenever a free trial comes first, even though the
/// real recurring price sits in a later phase.
String? recurringPriceFromOffers(List<SubscriptionOffer>? offers) {
  if (offers == null) return null;
  for (final offer in _basePlanFirst(offers)) {
    final phases = offer.pricingPhasesAndroid?.pricingPhaseList;
    if (phases == null) continue;
    PricingPhaseAndroid? recurring;
    for (final phase in phases) {
      if (_micros(phase) > 0) recurring = phase;
    }
    if (recurring != null && recurring.formattedPrice.isNotEmpty) {
      return recurring.formattedPrice;
    }
  }
  return null;
}

/// Length of the free trial a subscription product actually offers, in
/// days, or null when the store reports none.
///
/// Read from the store rather than hardcoded on purpose. The trial lives in
/// Play Console / App Store Connect, differs per plan, can be changed
/// without a release, and is not offered to someone who has used one. A
/// hardcoded "3-day free trial" would be wrong for that last group and
/// would drift the first time the offer is edited; advertising a trial the
/// store does not grant is the kind of mismatch that gets a build rejected.
///
/// Returns null wherever the store does not report one, and the UI then
/// says nothing, which is the safe direction to fail.
int? freeTrialDays(ProductCommon product) {
  final offers = switch (product) {
    ProductSubscriptionAndroid p => p.subscriptionOffers,
    ProductSubscriptionIOS p => p.subscriptionOffers,
    ProductAndroid p => p.subscriptionOffers,
    ProductIOS p => p.subscriptionOffers,
    _ => null,
  };
  if (offers == null) return null;
  for (final offer in offers) {
    final days = trialDaysFromOffer(offer);
    if (days != null) return days;
  }
  return null;
}

/// Days of free trial one offer carries, or null when it is not a trial.
///
/// Android: a zero-priced pricing phase that does not recur forever (a free
/// base plan is not a trial), its `billingPeriod` an ISO-8601 duration.
/// iOS: the normalised offer, a free-trial payment mode with a period.
int? trialDaysFromOffer(SubscriptionOffer offer) {
  final phases = offer.pricingPhasesAndroid?.pricingPhaseList;
  if (phases != null) {
    for (final phase in phases) {
      if (_micros(phase) != 0) continue;
      if (phase.recurrenceMode == _infiniteRecurring) continue;
      final days = iso8601PeriodInDays(phase.billingPeriod);
      if (days == null) continue;
      final cycles = phase.billingCycleCount > 0 ? phase.billingCycleCount : 1;
      return days * cycles;
    }
    return null;
  }

  if (offer.paymentMode != PaymentMode.FreeTrial) return null;
  final period = offer.period;
  if (period == null || period.value <= 0) return null;
  final unitDays = switch (period.unit) {
    SubscriptionPeriodUnit.Day => 1,
    SubscriptionPeriodUnit.Week => 7,
    SubscriptionPeriodUnit.Month => 30,
    SubscriptionPeriodUnit.Year => 365,
    SubscriptionPeriodUnit.Unknown => 0,
  };
  if (unitDays == 0) return null;
  final rawCount = offer.periodCount ?? 1;
  final count = rawCount > 0 ? rawCount : 1;
  final days = period.value * unitDays * count;
  return days > 0 ? days : null;
}

/// Days in an ISO-8601 period such as "P3D", "P1W", "P1M", the shape Google
/// Play reports a billing period in. Months and years are nominal (30/365);
/// trials are configured in days or weeks, so that approximation never
/// reaches the UI in practice.
int? iso8601PeriodInDays(String period) {
  final match = RegExp(
    r'^P(?:(\d+)Y)?(?:(\d+)M)?(?:(\d+)W)?(?:(\d+)D)?$',
  ).firstMatch(period);
  if (match == null) return null;
  int part(int group) => int.tryParse(match.group(group) ?? '') ?? 0;
  final days = part(1) * 365 + part(2) * 30 + part(3) * 7 + part(4);
  return days > 0 ? days : null;
}

int _micros(PricingPhaseAndroid phase) =>
    int.tryParse(phase.priceAmountMicros) ?? -1;

Iterable<SubscriptionOffer> _basePlanFirst(List<SubscriptionOffer> offers) {
  bool isBasePlan(SubscriptionOffer o) =>
      o.basePlanIdAndroid != null && o.id == o.basePlanIdAndroid;
  return [
    ...offers.where(isBasePlan),
    ...offers.where((o) => !isBasePlan(o)),
  ];
}
