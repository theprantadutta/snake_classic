import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/logger.dart';
import 'ads/ad_service.dart';
import 'analytics/analytics_facade.dart';
import 'api_service.dart';
import 'purchases/product_ids.dart';
import 'purchases/purchase_mapping.dart' as mapping;
import 'purchases/purchase_mapping.dart' show OwnedSubscription, VerifyOutcome;

export 'purchases/product_ids.dart';
export 'purchases/purchase_mapping.dart' show OwnedSubscription, VerifyOutcome;

/// Store purchases on top of flutter_inapp_purchase (OpenIAP): Play Billing
/// Library 9.1 on Android, StoreKit 2 on iOS.
///
/// The flow, in the order OpenIAP prescribes:
///
///  1. listeners are attached, THEN the store connection is opened;
///  2. products are fetched;
///  3. a purchase is requested — the outcome arrives on the listeners, never
///     as a return value;
///  4. every purchase the store reports as paid is verified by our backend
///     (Google Play Developer API / Apple's signed transaction) before
///     anything is delivered;
///  5. only then is the store transaction finished: consumed for coin packs
///     and tournament entries, acknowledged for everything else. Play
///     refunds anything left unacknowledged for three days, which is the
///     right end for a purchase we could not verify.
///
/// A purchase the store reports as PENDING (cash, carrier billing, parental
/// approval) is neither delivered nor finished; the store re-reports it as
/// paid once the money clears and [reconcileStoreState] picks it up.
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final FlutterInappPurchase _iap = FlutterInappPurchase.instance;
  StreamSubscription<Purchase>? _purchaseSub;
  StreamSubscription<PurchaseError>? _errorSub;

  bool _isAvailable = false;
  bool _isInitialized = false;
  List<ProductCommon> _products = [];
  final List<Purchase> _purchases = [];
  bool _purchasePending = false;
  String? _queryProductError;
  bool _reconciling = false;

  /// Product IDs whose billing flow was launched but haven't produced ANY
  /// listener event yet. Play normally reports a backed-out sheet as a
  /// user-cancelled error, but not always; app-resume (see
  /// [notifyAppResumed]) is the safety net that clears a stuck
  /// "verifying" state.
  final Set<String> _inFlightProductIds = {};
  Timer? _resumeCancelWatchdog;

  /// Grace window after the app resumes from the billing sheet — a genuine
  /// purchase often delivers its event a beat after resume, so we wait this
  /// long for a real terminal event before treating a still-in-flight
  /// product as a silent cancel.
  static const Duration _resumeCancelGrace = Duration(seconds: 3);

  /// SharedPreferences key for persisted pending verifications.
  static const String _pendingVerificationsKey =
      'pending_purchase_verifications';

  /// SharedPreferences key for delivered purchase IDs (deduplication).
  /// Prevents double-delivery if the app crashes between delivery and
  /// finishing the transaction, and stops store replays (StoreKit replays
  /// unfinished transactions every launch; Play reports every owned item on
  /// every query) from delivering twice.
  static const String _deliveredPurchaseIdsKey = 'delivered_purchase_ids';

  /// In-memory set of already-delivered purchase IDs.
  final Set<String> _deliveredPurchaseIds = {};

  /// Purchases the backend refused this session. Left unfinished on Android
  /// so Play refunds them, they would otherwise be re-verified on every
  /// reconcile until then.
  final Set<String> _rejectedThisSession = {};

  /// Purchases being verified right now, by identity. The purchase-stream
  /// event and the app-resume reconcile both see a fresh purchase within
  /// the same second (the billing sheet closing IS the resume), and without
  /// this both would verify it, both would deliver it, and the backend
  /// would see the same receipt twice at once.
  final Set<String> _fulfilling = {};

  // Getters
  bool get isAvailable => _isAvailable;
  List<ProductCommon> get products => _products;
  List<Purchase> get purchases => _purchases;
  bool get purchasePending => _purchasePending;
  String? get queryProductError => _queryProductError;

  // Stream controllers for UI updates
  final StreamController<bool> _purchasePendingController =
      StreamController<bool>.broadcast();
  final StreamController<List<ProductCommon>> _productsController =
      StreamController<List<ProductCommon>>.broadcast();
  final StreamController<String> _purchaseStatusController =
      StreamController<String>.broadcast();

  /// Lazily resolve [AnalyticsFacade] from GetIt — null-safe so the service
  /// stays usable in tests / before DI bootstrap completes.
  AnalyticsFacade? get _analytics {
    if (!GetIt.I.isRegistered<AnalyticsFacade>()) return null;
    return GetIt.I<AnalyticsFacade>();
  }

  /// Categorise a product ID for analytics. Falls back to "other" so we never
  /// drop an event because of a product ID we forgot to map.
  String _productTypeFor(String productId) {
    final id = ProductIds.stripPrefix(productId);
    if (ProductIds.subscriptionIds.any(
      (s) => ProductIds.stripPrefix(s) == id,
    )) {
      return 'subscription';
    }
    if (id.startsWith('coin_pack_')) return 'coins';
    if (id.startsWith('skin_')) return 'skin';
    if (id.startsWith('trail_')) return 'trail';
    if (id.endsWith('_theme') || id == 'premium_themes_bundle') return 'theme';
    if (id.contains('tournament')) return 'tournament_entry';
    return 'other';
  }

  Stream<bool> get purchasePendingStream => _purchasePendingController.stream;
  Stream<List<ProductCommon>> get productsStream => _productsController.stream;
  Stream<String> get purchaseStatusStream => _purchaseStatusController.stream;

  /// Getter for the backend user id (a Guid string), wired from main.dart.
  String? Function()? _userIdGetter;

  /// Set a getter for the backend user id. Every purchase is tagged with it:
  /// on Android as the Play Billing obfuscatedAccountId, which Google echoes
  /// back to our RTDN webhook as obfuscatedExternalAccountId; on iOS as the
  /// StoreKit appAccountToken. That lets the backend map a cleared deferred
  /// payment (PENDING → paid) back to this user even if the app never
  /// reopens to re-verify. User identity is still carried via JWT on verify.
  void setUserIdGetter(String? Function() getUserId) {
    _userIdGetter = getUserId;
  }

  Future<void> initialize() async {
    // Idempotency guard — prevent double initialization when called from
    // both main.dart and PremiumCubit.initialize().
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      AppLogger.info('Initializing Purchase Service...');

      // Load previously delivered purchase IDs for deduplication
      await _loadDeliveredPurchaseIds();

      // Listeners BEFORE the connection: StoreKit replays unfinished
      // transactions the moment the connection is up, and an event with
      // nobody listening is a purchase nobody delivers.
      _purchaseSub = _iap.purchaseUpdatedListener.listen(
        (purchase) => unawaited(_onPurchaseUpdated(purchase)),
        onError: (Object e) => AppLogger.error('Purchase stream error', e),
      );
      _errorSub = _iap.purchaseErrorListener.listen(
        _onPurchaseError,
        onError: (Object e) =>
            AppLogger.error('Purchase error stream error', e),
      );

      _isAvailable = await _iap.initConnection().timeout(
        const Duration(seconds: 10),
      );
      if (!_isAvailable) {
        AppLogger.error('In-app purchases not available on this device');
        return;
      }

      await loadProducts().timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          AppLogger.warning(
            'loadProducts timed out — continuing without product data',
          );
        },
      );
      // The store's own inventory is deliberately NOT reconciled here.
      // Every owned item would be run through backend verification, and
      // the user isn't authenticated yet, so every call would 401 and the
      // purchases would pile up in the pending-verification queue. The
      // reconcile is triggered by AuthCubit once it transitions to
      // authenticated (see runPostAuthRestore below).

      AppLogger.info(
        'Purchase Service initialized successfully (post-auth reconcile pending)',
      );
    } catch (e) {
      _isAvailable = false;
      AppLogger.error('Error initializing Purchase Service', e);
    }
  }

  Future<void> loadProducts() async {
    if (!_isAvailable) return;
    try {
      AppLogger.info('Loading products...');

      // One-time products and subscriptions are separate store queries.
      final oneTime = await _iap.fetchProducts<Product>(
        skus: ProductIds.oneTimeProductIds,
        type: ProductQueryType.InApp,
      );
      final subscriptions = await _iap.fetchProducts<ProductSubscription>(
        skus: ProductIds.subscriptionIds,
        type: ProductQueryType.Subs,
      );
      final loaded = <ProductCommon>[...oneTime, ...subscriptions];

      final found = loaded.map((p) => p.id).toSet();
      final missing = ProductIds.allProductIds
          .where((id) => !found.contains(id))
          .toList();
      if (missing.isNotEmpty) {
        AppLogger.warning('Products not found: $missing');
      }

      _products = loaded;
      _queryProductError = null;
      _productsController.add(_products);

      AppLogger.info('Loaded ${_products.length} products successfully');
    } catch (e) {
      AppLogger.error('Error loading products', e);
      _queryProductError = e.toString();
    }
  }

  /// Buy [product].
  ///
  /// Pass [replacing] to SWITCH an existing subscription rather than start a
  /// new one. Play treats a plan change as a replacement, not a purchase: buy
  /// the yearly SKU while the monthly one is active without naming the old
  /// purchase and the store rejects it as "already owned". [replacementMode]
  /// decides the money — see [switchSubscription].
  ///
  /// Returns true when the store sheet was launched. The outcome arrives on
  /// [purchaseStatusStream].
  Future<bool> buyProduct(
    ProductCommon product, {
    OwnedSubscription? replacing,
    SubscriptionReplacementModeAndroid? replacementMode,
  }) async {
    if (!_isAvailable) {
      _purchaseStatusController.add('In-app purchases not available');
      return false;
    }

    final productId = product.id;
    try {
      AppLogger.info('Initiating purchase for: $productId');
      _purchasePending = true;
      _purchasePendingController.add(true);

      // Funnel event — fired BEFORE the IAP sheet opens. Combined with
      // item_purchased / purchase_cancelled / purchase_failed, this gives
      // us the IAP-sheet abandonment rate.
      _analytics?.trackPurchaseInitiated(
        productId: productId,
        productType: _productTypeFor(productId),
      );

      // The billing sheet backgrounds the app; suppress the App Open ad that
      // would otherwise fire when the user returns from it.
      if (GetIt.I.isRegistered<AdService>()) {
        GetIt.I<AdService>().suppressNextAppOpen();
      }

      final request = mapping.buildPurchaseRequest(
        product: product,
        accountId: _userIdGetter?.call(),
        replacing: replacing,
        replacementMode: replacementMode,
      );

      // Track the launched flow so a silent cancel (no listener event when
      // the user backs out of the sheet) can be detected on app resume —
      // see notifyAppResumed.
      _inFlightProductIds.add(productId);
      await _iap.requestPurchase(request);
      return true;
    } on PurchaseError catch (e) {
      // A synchronous refusal: billing not ready, missing offer, or the
      // store already knows the answer.
      _inFlightProductIds.remove(productId);
      _purchasePending = false;
      _purchasePendingController.add(false);
      _reportPurchaseError(e, fallbackProductId: productId);
      return false;
    } catch (e) {
      AppLogger.error('Error buying product', e);
      _inFlightProductIds.remove(productId);
      _purchasePending = false;
      _purchasePendingController.add(false);
      _purchaseStatusController.add('purchase_failed:$productId');
      _purchaseStatusController.add('Purchase failed: ${e.toString()}');
      _analytics?.trackPurchaseFailed(
        productId: productId,
        errorCode: 'exception',
      );
      return false;
    }
  }

  /// Called when the app returns to the foreground (wired from main.dart's
  /// lifecycle observer). Detects a SILENT cancel of the store billing sheet:
  /// backing out of the Play purchase sheet sometimes emits no event at all,
  /// which would otherwise leave `_purchasePending` (and every "Verifying…"
  /// UI bound to it) stuck forever. After a short grace window — so a real
  /// `purchased` event that lands just after resume wins — any product still
  /// in flight is treated as cancelled: we broadcast a product-scoped cancel
  /// so cards drop their spinner, and reset the global pending flag. A late
  /// event arriving afterwards is still processed normally by the listener,
  /// so nothing is lost.
  void notifyAppResumed() {
    if (_inFlightProductIds.isEmpty) return;
    _resumeCancelWatchdog?.cancel();
    _resumeCancelWatchdog = Timer(_resumeCancelGrace, () {
      if (_inFlightProductIds.isEmpty) return;
      final abandoned = _inFlightProductIds.toList();
      _inFlightProductIds.clear();
      for (final productId in abandoned) {
        AppLogger.info(
          'Billing sheet returned with no event for $productId — treating as cancelled',
        );
        _purchaseStatusController.add('purchase_canceled:$productId');
      }
      _purchasePending = false;
      _purchasePendingController.add(false);
    });
  }

  // ==================== Store events ====================

  Future<void> _onPurchaseUpdated(Purchase purchase) async {
    final productId = purchase.productId;
    // Any event for this product means the billing flow produced a signal,
    // so it's no longer a silent-cancel candidate for the resume watchdog.
    _inFlightProductIds.remove(productId);

    try {
      switch (purchase.purchaseState) {
        case PurchaseState.Pending:
          // A deferred payment: the store has not charged yet, so nothing
          // is delivered and the transaction is left open. Play re-reports
          // it as purchased when the money clears (or drops it if it never
          // does), and reconcileStoreState picks it up from there.
          AppLogger.info('Purchase pending for $productId (deferred payment)');
          _purchaseStatusController.add('purchase_pending:$productId');
          _purchaseStatusController.add('Purchase pending...');
        case PurchaseState.Purchased:
          await _fulfil(purchase);
        case PurchaseState.Unknown:
          AppLogger.warning(
            'Purchase for $productId in an unknown state — not delivered',
          );
          _purchaseStatusController.add('purchase_failed:$productId');
          _purchaseStatusController.add('Purchase failed');
      }
    } catch (e, stack) {
      AppLogger.error('Error handling purchase update for $productId', e, stack);
    } finally {
      _purchasePending = false;
      _purchasePendingController.add(false);
    }
  }

  void _onPurchaseError(PurchaseError error) {
    // Play does not always name the product on an error. Fall back to what
    // we launched, so the right card drops its spinner.
    final affected = error.productId != null
        ? <String>{error.productId!}
        : Set<String>.of(_inFlightProductIds);
    _inFlightProductIds.removeAll(affected);
    _purchasePending = false;
    _purchasePendingController.add(false);

    if (affected.isEmpty) {
      _reportPurchaseError(error, fallbackProductId: null);
      return;
    }
    for (final productId in affected) {
      _reportPurchaseError(error, fallbackProductId: productId);
    }
  }

  void _reportPurchaseError(
    PurchaseError error, {
    required String? fallbackProductId,
  }) {
    final productId = error.productId ?? fallbackProductId ?? '';
    switch (error.code) {
      case ErrorCode.UserCancelled:
        AppLogger.info('Purchase canceled by user: $productId');
        // Clear the spinner the moment the user backs out of the store
        // sheet, rather than leaving the card stuck on "Verifying…".
        _purchaseStatusController.add('purchase_canceled:$productId');
        _analytics?.trackPurchaseCancelled(productId: productId);
      case ErrorCode.DeferredPayment:
      case ErrorCode.Pending:
        AppLogger.info('Purchase deferred for $productId: ${error.message}');
        _purchaseStatusController.add('purchase_pending:$productId');
      case ErrorCode.AlreadyOwned:
        // The store says they have it and we do not know about it: pick it
        // up from the store's inventory rather than leaving them stuck
        // with a card they can neither buy nor use.
        AppLogger.warning('Already owned: $productId — reconciling');
        _purchaseStatusController.add('purchase_failed:$productId');
        _analytics?.trackPurchaseFailed(
          productId: productId,
          errorCode: error.code?.value ?? 'unknown',
        );
        unawaited(reconcileStoreState());
      default:
        AppLogger.error(
          'Purchase error for $productId: ${error.code?.value ?? 'unknown'} ${error.message}'
          '${error.debugMessage == null ? '' : ' (${error.debugMessage})'}',
        );
        // Product-scoped terminal event FIRST so the store UI can drop this
        // item's "Verifying…" spinner the instant the payment fails (wrong
        // card, declined, etc.) instead of waiting out the 45s safety
        // timeout. The generic message follows for any plain listeners.
        _purchaseStatusController.add('purchase_failed:$productId');
        _purchaseStatusController.add('Purchase failed');
        _analytics?.trackPurchaseFailed(
          productId: productId,
          errorCode: error.code?.value ?? 'unknown',
        );
    }
  }

  // ==================== Delivery ====================

  /// Verify → deliver → finish, for one purchase the store reports as paid.
  /// Safe to call for the same purchase any number of times: a purchase
  /// already delivered is only (re)finished.
  Future<void> _fulfil(Purchase purchase) async {
    final identity = mapping.purchaseIdentity(purchase);
    if (identity != null && !_fulfilling.add(identity)) {
      AppLogger.info(
        'Purchase ${purchase.productId} is already being verified — skipping',
      );
      return;
    }
    try {
      await _fulfilUnguarded(purchase, identity);
    } finally {
      if (identity != null) _fulfilling.remove(identity);
    }
  }

  Future<void> _fulfilUnguarded(Purchase purchase, String? identity) async {
    final productId = purchase.productId;
    final consumable = ProductIds.isConsumable(productId);

    if (identity != null && _deliveredPurchaseIds.contains(identity)) {
      AppLogger.info(
        'Skipping already-delivered purchase: $identity ($productId)',
      );
      // A delivered purchase the store still reports as unfinished (crash
      // between delivery and finish) gets finished now.
      await _finish(purchase, consumable: consumable);
      return;
    }
    if (identity != null && _rejectedThisSession.contains(identity)) return;

    final payload = mapping.backendPayloadFor(purchase);
    final outcome = payload == null
        ? VerifyOutcome.rejected
        : await _verifyWithBackend(payload);

    // Cache the store's subscription object regardless of backend verdict:
    // a plan switch needs it, and a transient verification failure should
    // not cost the user the ability to change plans.
    _rememberSubscription(purchase);

    switch (outcome) {
      case VerifyOutcome.granted:
        _purchases.add(purchase);
        // Broadcast for PremiumCubit to handle content delivery
        _purchaseStatusController.add('purchase_completed:$productId');
        _purchaseStatusController.add('Purchase successful!');
      case VerifyOutcome.transient:
        // The store has charged them; our backend could not confirm it
        // right now. Deliver locally so the player is not left staring at
        // a paid-for nothing, and keep the receipt queued until the backend
        // accepts it.
        if (payload != null) await _queuePendingVerification(payload);
        _purchases.add(purchase);
        _purchaseStatusController.add('purchase_completed:$productId');
        _purchaseStatusController.add(
          'Purchase delivered (backend sync pending)',
        );
      case VerifyOutcome.rejected:
        // The backend looked at the receipt and said no. Nothing is
        // delivered. On Android the purchase is left unacknowledged so Play
        // refunds it within three days; on iOS it is finished so StoreKit
        // stops replaying it on every launch.
        AppLogger.warning(
          'Backend rejected purchase ${identity ?? '?'} ($productId)',
        );
        if (identity != null) _rejectedThisSession.add(identity);
        _purchaseStatusController.add('purchase_failed:$productId');
        _purchaseStatusController.add('Purchase failed');
        _analytics?.trackPurchaseFailed(
          productId: productId,
          errorCode: 'backend_rejected',
        );
        if (Platform.isIOS || Platform.isMacOS) {
          await _finish(purchase, consumable: consumable);
        }
        return;
    }

    // Mark as delivered AFTER broadcasting so PremiumCubit processes it
    if (identity != null) await _markAsDelivered(identity);

    await _finish(purchase, consumable: consumable);

    // Funnel terminal event — fires once per fulfilled purchase (replays
    // hit the dedup branch above and don't double-log).
    _analytics?.trackItemPurchased(
      itemId: productId,
      itemType: _productTypeFor(productId),
      price: getProduct(productId)?.displayPrice ?? 'unknown',
    );
  }

  /// Consume (consumables) or acknowledge (everything else) with the store.
  Future<void> _finish(Purchase purchase, {required bool consumable}) async {
    if (!consumable &&
        purchase is PurchaseAndroid &&
        purchase.isAcknowledgedAndroid == true) {
      return;
    }
    try {
      await _iap.finishTransaction(
        purchase: purchase,
        isConsumable: consumable,
      );
    } catch (e) {
      // Not fatal: an unfinished purchase comes back on the next reconcile
      // and is finished then (Android gives us three days).
      AppLogger.error('Failed to finish transaction for ${purchase.productId}', e);
    }
  }

  // ==================== Backend Verification (via ApiService) ====================

  Future<VerifyOutcome> _verifyWithBackend(
    mapping.BackendPurchasePayload payload,
  ) async {
    try {
      final result = await ApiService().verifyPurchase(
        platform: payload.platform,
        receiptData: payload.receiptData,
        productId: payload.productId,
        transactionId: payload.transactionId,
        purchaseToken: payload.purchaseToken,
      );
      final outcome = mapping.classifyVerifyResponse(result);
      switch (outcome) {
        case VerifyOutcome.granted:
          AppLogger.info('Purchase verified by backend: ${payload.productId}');
        case VerifyOutcome.transient:
          AppLogger.warning(
            'Backend verification unavailable for ${payload.productId}: '
            '${result?['error'] ?? result?['message'] ?? 'no response'}',
          );
        case VerifyOutcome.rejected:
          AppLogger.error(
            'Backend verification rejected ${payload.productId}: '
            '${result?['error'] ?? result?['message'] ?? 'invalid'}',
          );
      }
      return outcome;
    } catch (e) {
      AppLogger.error('Error verifying purchase with backend', e);
      return VerifyOutcome.transient;
    }
  }

  // ==================== Offline Retry Queue ====================

  /// Persist a failed verification so it can be retried later.
  Future<void> _queuePendingVerification(
    mapping.BackendPurchasePayload payload,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existing = prefs.getStringList(_pendingVerificationsKey) ?? [];
      final entry = jsonEncode({
        ...payload.toJson(),
        'queued_at': DateTime.now().toIso8601String(),
      });
      existing.add(entry);
      await prefs.setStringList(_pendingVerificationsKey, existing);
      AppLogger.info('Queued pending verification for ${payload.productId}');
    } catch (e) {
      AppLogger.error('Error queuing pending verification', e);
    }
  }

  /// Retry all pending verifications. Called on app resume and connectivity
  /// restore. Uses the batch endpoint when several are pending.
  Future<void> retryPendingVerifications() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pending = prefs.getStringList(_pendingVerificationsKey) ?? [];
      if (pending.isEmpty) return;

      AppLogger.info(
        'Retrying ${pending.length} pending purchase verifications',
      );
      final apiService = ApiService();
      if (!apiService.isAuthenticated) return;

      // Parse all pending entries. Anything unparseable is dropped: it can
      // never be sent, so keeping it would only pin the queue.
      final entries = <mapping.BackendPurchasePayload>[];
      for (final entryJson in pending) {
        try {
          final decoded = jsonDecode(entryJson);
          if (decoded is Map<String, dynamic>) {
            final payload = mapping.BackendPurchasePayload.fromJson(decoded);
            if (payload != null) entries.add(payload);
          }
        } catch (_) {}
      }
      if (entries.isEmpty) {
        await prefs.setStringList(_pendingVerificationsKey, const []);
        return;
      }

      // A verdict per entry: keep only what is still transient.
      final remaining = <mapping.BackendPurchasePayload>[];

      // Use batch endpoint if multiple pending, individual for single
      List<VerifyOutcome>? outcomes;
      if (entries.length >= 2) {
        final result = await apiService.batchVerifyPurchases(
          entries.map((e) => e.toBatchEntry()).toList(),
        );
        final results = result?['results'];
        if (results is List) {
          outcomes = List<VerifyOutcome>.generate(entries.length, (i) {
            if (i >= results.length) return VerifyOutcome.transient;
            final r = results[i];
            return mapping.classifyVerifyResponse(
              r is Map ? Map<String, dynamic>.from(r) : null,
            );
          });
        }
      }

      // Fallback: individual verification (single pending or batch failed)
      outcomes ??= [
        for (final entry in entries) await _verifyWithBackend(entry),
      ];

      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        switch (outcomes[i]) {
          case VerifyOutcome.granted:
            AppLogger.info(
              'Pending verification succeeded: ${entry.productId}',
            );
          case VerifyOutcome.transient:
            remaining.add(entry);
          case VerifyOutcome.rejected:
            // Already delivered locally when it was queued; the backend's
            // entitlement sync is what reconciles that. Retrying forever
            // would not change the answer.
            AppLogger.warning(
              'Pending verification rejected, dropping: ${entry.productId}',
            );
        }
      }

      await prefs.setStringList(
        _pendingVerificationsKey,
        remaining.map((e) => jsonEncode(e.toJson())).toList(),
      );
      if (remaining.isEmpty) {
        AppLogger.info('All pending verifications completed');
      } else {
        AppLogger.warning('${remaining.length} verifications still pending');
      }
    } catch (e) {
      AppLogger.error('Error retrying pending verifications', e);
    }
  }

  // ==================== Deduplication ====================

  /// Load previously delivered purchase IDs from SharedPreferences.
  Future<void> _loadDeliveredPurchaseIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(_deliveredPurchaseIdsKey) ?? [];
      _deliveredPurchaseIds.addAll(ids);
      if (ids.isNotEmpty) {
        AppLogger.info('Loaded ${ids.length} delivered purchase IDs for dedup');
      }
    } catch (e) {
      AppLogger.error('Error loading delivered purchase IDs', e);
    }
  }

  /// Record a purchase ID as delivered so it won't be double-credited
  /// if the store reports it again (replay, reconcile, crash).
  Future<void> _markAsDelivered(String purchaseId) async {
    _deliveredPurchaseIds.add(purchaseId);
    try {
      final prefs = await SharedPreferences.getInstance();
      // Keep only the last 500 IDs to avoid unbounded growth
      final ids = _deliveredPurchaseIds.toList();
      if (ids.length > 500) {
        final trimmed = ids.sublist(ids.length - 500);
        _deliveredPurchaseIds
          ..clear()
          ..addAll(trimmed);
      }
      await prefs.setStringList(
        _deliveredPurchaseIdsKey,
        _deliveredPurchaseIds.toList(),
      );
    } catch (e) {
      AppLogger.error('Error persisting delivered purchase ID', e);
    }
  }

  // ==================== Restore & reconcile ====================

  /// Restore purchases: ask the store to sync (on iOS this may show the App
  /// Store sign-in), then run everything it reports through delivery.
  Future<void> restorePurchases() async {
    if (!_isAvailable) {
      _purchaseStatusController.add('In-app purchases not available');
      return;
    }
    try {
      AppLogger.info('Restoring purchases...');
      await _iap.restorePurchases();
      await reconcileStoreState();
      AppLogger.info('Purchases restored successfully');
    } catch (e) {
      AppLogger.error('Error restoring purchases', e);
      _purchaseStatusController.add('Failed to restore purchases');
    }
  }

  /// Run every purchase the store still reports through the delivery
  /// pipeline. Covers restores, purchases completed while we were away (a
  /// cleared deferred payment, a purchase made on another device) and
  /// anything left unfinished by a crash. Cheap when nothing is new:
  /// delivered purchases are skipped by identity, and a purchase the store
  /// still calls pending stays with the store.
  Future<void> reconcileStoreState() async {
    if (!_isAvailable || _reconciling) return;
    _reconciling = true;
    try {
      final available = await _iap.getAvailablePurchases();
      AppLogger.info('Store reports ${available.length} owned purchase(s)');
      for (final purchase in available) {
        _rememberSubscription(purchase);
        if (purchase.purchaseState != PurchaseState.Purchased) continue;
        await _fulfil(purchase);
      }
    } catch (e) {
      AppLogger.error('Error reconciling store purchases', e);
    } finally {
      _reconciling = false;
    }
  }

  /// One-shot post-authentication setup. Triggered from AuthCubit when it
  /// transitions to authenticated. Reconciles the store's inventory through
  /// the delivery pipeline (which now has a valid JWT for backend verify)
  /// AND drains any purchases that 401'd in a previous unauth session.
  /// Idempotent and safe to call multiple times.
  bool _postAuthRestoreDone = false;
  Future<void> runPostAuthRestore() async {
    if (_postAuthRestoreDone) {
      // Subsequent re-auths just drain the pending queue; no need to
      // re-walk the whole store inventory.
      await retryPendingVerifications();
      return;
    }
    _postAuthRestoreDone = true;
    try {
      AppLogger.info('Running post-auth purchase reconcile + verification drain');
      await reconcileStoreState().timeout(
        const Duration(seconds: 15),
        onTimeout: () =>
            AppLogger.warning('Post-auth store reconcile timed out'),
      );
      await retryPendingVerifications();
    } catch (e) {
      AppLogger.error('Error during post-auth purchase restore', e);
    }
  }

  // ==================== Product queries ====================

  ProductCommon? getProduct(String productId) {
    for (final product in _products) {
      if (product.id == productId) return product;
    }
    return null;
  }

  /// Display price for a product, handling the Google Play **subscription**
  /// quirk: a subscription's headline price is derived from its first
  /// pricing phase, which reads as "Free" whenever a free-trial phase comes
  /// first, even though the real recurring price exists in a later phase.
  /// For Android subs we dig out the recurring (non-zero) phase's formatted
  /// price; otherwise the store's own display price is right.
  String? _displayPrice(ProductCommon? product) {
    if (product == null) return null;
    if (product is ProductSubscriptionAndroid) {
      final recurring =
          mapping.recurringPriceFromOffers(product.subscriptionOffers);
      if (recurring != null && recurring.isNotEmpty) return recurring;
    }
    final price = product.displayPrice;
    if (price.isEmpty) return null;
    return price;
  }

  /// Length of the free trial a subscription actually offers, in days, or
  /// null when the store reports none. See [mapping.freeTrialDays].
  int? getFreeTrialDays(String productId) {
    final product = getProduct(productId);
    if (product == null) return null;
    return mapping.freeTrialDays(product);
  }

  /// Days in an ISO-8601 period such as "P3D", "P1W", "P1M" — the shape
  /// Google Play reports a billing period in.
  @visibleForTesting
  static int? iso8601PeriodInDays(String period) =>
      mapping.iso8601PeriodInDays(period);

  /// Get the store-formatted price for a product (e.g. "$1.99").
  /// Returns null if the product hasn't been loaded from the store.
  String? getStorePrice(String productId) =>
      _displayPrice(getProduct(productId));

  /// Get the store price, falling back to a formatted default.
  ///
  /// The fallback is a USD amount; pass [localeTag] (e.g.
  /// `Localizations.localeOf(context).toLanguageTag()`) so the currency
  /// symbol/separators render for the user's locale.
  String getStorePriceOrDefault(
    String productId,
    double fallbackPrice, {
    String? localeTag,
  }) {
    return _displayPrice(getProduct(productId)) ??
        NumberFormat.simpleCurrency(locale: localeTag ?? 'en_US', name: 'USD')
            .format(fallbackPrice);
  }

  Future<bool> purchaseProduct(String productId) async {
    final product = getProduct(productId);
    if (product == null) {
      throw Exception('Product $productId not found');
    }
    return await buyProduct(product);
  }

  // ==================== Subscription plan switching ====================

  /// The live subscription, as last seen from the store.
  OwnedSubscription? _ownedSubscription;

  void _rememberSubscription(Purchase purchase) {
    if (!ProductIds.isSubscription(purchase.productId)) return;
    _ownedSubscription = OwnedSubscription(
      productId: purchase.productId,
      purchaseToken: purchase.purchaseToken,
    );
  }

  /// The subscription this account currently holds, or null.
  ///
  /// Asks the store when nothing has come through the listener yet: on a
  /// cold start nothing has been bought or replayed, so the cache is empty
  /// even for a long-standing subscriber — and a switch attempted with no
  /// old purchase degrades into a plain buy, which Play rejects as "already
  /// owned".
  Future<OwnedSubscription?> currentSubscription() async {
    if (_ownedSubscription != null) return _ownedSubscription;
    if (!_isAvailable) return null;
    try {
      final active = await _iap.getActiveSubscriptions(
        ProductIds.subscriptionIds,
      );
      ActiveSubscription? live;
      for (final s in active) {
        if (s.isActive) {
          live = s;
          break;
        }
      }
      live ??= active.isEmpty ? null : active.first;
      if (live != null) {
        _ownedSubscription = OwnedSubscription(
          productId: live.productId,
          purchaseToken: live.purchaseTokenAndroid ?? live.purchaseToken,
        );
      }
    } catch (e) {
      AppLogger.warning('Could not read the current subscription: $e');
    }
    return _ownedSubscription;
  }

  /// The product id of the active subscription, or null when there isn't one.
  String? get activeSubscriptionId => _ownedSubscription?.productId;

  /// Open the store's own subscription management surface.
  ///
  /// Cancelling, changing payment method and viewing the renewal date all
  /// belong to Play / the App Store — both stores require it, and neither
  /// exposes an in-app API for them. Deep-linking to the specific SKU lands
  /// the user on this subscription rather than a list of everything they own.
  Future<void> openManageSubscription({String? productId}) async {
    await _iap.deepLinkToSubscriptions(
      skuAndroid: productId,
      packageNameAndroid: 'com.pranta.snakeclassic',
    );
  }

  /// Move an existing subscription to [targetProductId].
  ///
  /// The replacement mode is chosen by direction, and the choice is about
  /// money rather than mechanics:
  ///
  /// * **Upgrade** (monthly → yearly) charges the prorated price —
  ///   effective immediately, the unused remainder of the month is credited
  ///   against the year. The user gets what they just paid for, and Pro never
  ///   lapses across the switch.
  /// * **Downgrade** (yearly → monthly) is deferred — the period already paid
  ///   for runs to its end and monthly starts after it. Switching immediately
  ///   would mean refunding the remainder of a year, and nobody expects a
  ///   downgrade to move money toward them.
  ///
  /// Returns false when there is no subscription to replace or the store
  /// refuses to launch the flow. Like every purchase, the actual result
  /// arrives asynchronously on the purchase status stream.
  Future<bool> switchSubscription(String targetProductId) async {
    if (!ProductIds.isSubscription(targetProductId)) {
      throw ArgumentError('$targetProductId is not a subscription');
    }

    final target = getProduct(targetProductId);
    if (target == null) {
      throw Exception('Product $targetProductId not found');
    }

    final replacing = await currentSubscription();
    if (replacing == null) {
      // Nothing to replace — treat it as a first-time subscribe rather than
      // failing, so a user whose purchase we simply could not read still gets
      // a working buy button.
      AppLogger.warning(
        'switchSubscription($targetProductId): no active subscription found, '
        'falling back to a plain purchase',
      );
      return buyProduct(target);
    }

    if (replacing.productId == targetProductId) {
      AppLogger.info('Already on $targetProductId — nothing to switch');
      return false;
    }

    final isUpgrade = targetProductId == ProductIds.snakeClassicProYearly;
    return buyProduct(
      target,
      replacing: replacing,
      replacementMode: isUpgrade
          ? SubscriptionReplacementModeAndroid.ChargeProratedPrice
          : SubscriptionReplacementModeAndroid.Deferred,
    );
  }

  bool isPurchased(String productId) {
    return _purchases.any(
      (purchase) =>
          purchase.productId == productId &&
          purchase.purchaseState == PurchaseState.Purchased,
    );
  }

  bool hasActiveSubscription(String subscriptionId) {
    for (final purchase in _purchases) {
      if (purchase.productId == subscriptionId) {
        return purchase.purchaseState == PurchaseState.Purchased;
      }
    }
    return false;
  }

  void dispose() {
    _resumeCancelWatchdog?.cancel();
    _purchaseSub?.cancel();
    _errorSub?.cancel();
    unawaited(_iap.endConnection().catchError((_) => false));
    _purchasePendingController.close();
    _productsController.close();
    _purchaseStatusController.close();
  }
}
