import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/catalog_l10n.dart';
import 'package:snake_classic/l10n/enum_l10n.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/models/premium_power_up.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/auth/auth_cubit.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/widgets/ads/reward_toast.dart';
import 'package:snake_classic/widgets/subscription_legal_footer.dart';
import 'package:snake_classic/presentation/bloc/power_up/power_up_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/services/ads/ad_service.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/account_upgrade_sheet.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/store/store_parts.dart';
import 'package:snake_classic/widgets/lb_screens/store/store_pro_parts.dart';

/// The store (Living Board screens 14/15).
///
/// Presentation follows the Living Board; everything that touches money is
/// unchanged from the pre-redesign screen: product IDs, purchase / restore /
/// equip calls, the pending-purchase ("Verifying…") bookkeeping, the guest
/// upgrade gate, analytics and every ad call.
class StoreScreen extends StatefulWidget {
  final int initialTab;

  const StoreScreen({super.key, this.initialTab = 0});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  /// Index of the visible tab. Drives the banner suppression and the
  /// per-tab subtitle.
  int _tabIndex = 0;

  /// The Pro tab. Order is fixed by CLAUDE.md: Pro / Coins / Themes / Skins /
  /// Trails / Power-Ups.
  static const int _proTabIndex = 0;

  // Tracks productIds whose purchase was just initiated but whose ownership
  // hasn't reflected back from the backend yet. The card switches from
  // "BUY" to a "Verifying..." spinner during this window (typically 2-15s
  // for Play Store → webhook → entitlement → cubit). Auto-cleared once
  // the PremiumCubit reports the item as owned, or after a safety timeout
  // so the spinner never spins forever if a webhook is genuinely lost.
  final Set<String> _pendingProductIds = {};

  // Listens for cancel/failure terminal events from the purchase stream so a
  // product's "Verifying…" spinner is dropped immediately when the user backs
  // out of the store sheet or the payment fails — instead of spinning until
  // the 45s safety timeout in _markPending.
  StreamSubscription<String>? _purchaseStatusSub;

  /// Pro tab plan selection; GO PRO buys this one. Yearly by default.
  bool _proYearly = true;

  // Which item each catalogue tab shows in its featured card. Null = the
  // default (the first item the player can still buy, else the equipped one).
  // Browsing only — nothing is bought or equipped by focusing.
  String? _focusCoinId;
  GameTheme? _focusTheme;
  SnakeSkinType? _focusSkin;
  TrailEffectType? _focusTrail;

  // Tab order: Pro / Coins / Themes / Skins / Trails / Power-Ups.
  // Keeps Coins at index 1 so existing `?tab=1` deep links still land on
  // coins. Themes replaces the old Boards tab (boards aren't products).
  // Modes tab removed entirely — modes are uniformly free now.
  static const _tabNames = [
    'Pro',
    'Coins',
    'Themes',
    'Skins',
    'Trails',
    'Power-Ups',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _tabNames.length,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, _tabNames.length - 1),
    );
    _tabIndex = _tabController.index;
    _tabController.addListener(_onTabChanged);
    _purchaseStatusSub = PurchaseService().purchaseStatusStream.listen(
      _onPurchaseStatus,
    );
  }

  /// Drop the "Verifying…" spinner the moment a purchase is canceled or fails.
  /// These product-scoped events come from PurchaseService after the async
  /// purchase stream reports a non-success terminal status — the path that the
  /// synchronous try/catch around purchaseProduct() can't see.
  void _onPurchaseStatus(String status) {
    String? productId;
    var failed = false;
    var pending = false;
    if (status.startsWith('purchase_canceled:')) {
      productId = status.substring('purchase_canceled:'.length);
    } else if (status.startsWith('purchase_failed:')) {
      productId = status.substring('purchase_failed:'.length);
      failed = true;
    } else if (status.startsWith('purchase_pending:')) {
      // A deferred payment (cash at a kiosk, carrier billing): the store
      // has accepted the order but no money has moved. Nothing unlocks
      // until it clears, so the card goes back to "Buy" with a note.
      productId = status.substring('purchase_pending:'.length);
      pending = true;
    } else {
      return;
    }
    if (!mounted) return;
    if (_pendingProductIds.contains(productId)) {
      setState(() => _pendingProductIds.remove(productId));
    }
    // Only surface a message on a genuine failure; a user-initiated cancel
    // should quietly return the card to its "Buy" state.
    if (failed) {
      ScaffoldMessenger.of(context).showSnackBar(
        arcadeSnackBar(
          context,
          message: AppLocalizations.of(context)!.storePurchaseFailed,
          tone: ArcadeSnackTone.error,
        ),
      );
    } else if (pending) {
      ScaffoldMessenger.of(context).showSnackBar(
        arcadeSnackBar(
          context,
          message: AppLocalizations.of(context)!.storePurchasePending,
        ),
      );
    }
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      getIt<AnalyticsFacade>().trackStoreTabViewed(
        _tabNames[_tabController.index],
      );
    }
    // Tracked separately from the analytics guard above, which deliberately
    // fires once at the START of a transition. The banner needs the SETTLED
    // index, so this runs on every listener tick and rebuilds only on a real
    // change.
    if (_tabIndex != _tabController.index) {
      setState(() => _tabIndex = _tabController.index);
    }
  }

  @override
  void dispose() {
    _purchaseStatusSub?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return BlocBuilder<PremiumCubit, PremiumState>(
      builder: (context, premiumState) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<CoinsCubit, CoinsState>(
              builder: (context, coinsState) {
                final theme = themeState.currentTheme;
                final g = context.lbGutter;
                return LBScaffold(
                  title: l10n.lbStoreTitle,
                  subtitle: _subtitleFor(l10n, _tabIndex),
                  // No banner on the Pro tab. Running an ad on the screen
                  // that sells ad removal undercuts the pitch on the very
                  // surface where it has to land, and it is the one place in
                  // the app where the ad and the product are in direct
                  // conflict. Every other tab keeps it.
                  banner: _tabIndex != _proTabIndex,
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          g,
                          context.lbCell * .8,
                          g,
                          2,
                        ),
                        child: StoreBalanceRow(
                          balance: coinsState.balance.total,
                          bonusLabel: coinsState.hasPremiumBonus
                              ? l10n.storeBonusMultiplier(
                                  '${coinsState.earningMultiplier}',
                                )
                              : null,
                        ),
                      ),
                      StoreTabStrip(
                        controller: _tabController,
                        labels: [
                          l10n.storeTabPro,
                          l10n.storeTabCoins,
                          l10n.storeTabThemes,
                          l10n.storeTabSkins,
                          l10n.storeTabTrails,
                          l10n.storeTabPowerUps,
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildProTab(theme, premiumState),
                            _buildCoinsTab(theme, coinsState),
                            _buildThemesTab(theme, premiumState),
                            _buildSkinsTab(theme, premiumState),
                            _buildTrailsTab(theme, premiumState),
                            _buildPowerUpsTab(theme, premiumState, coinsState),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  String _subtitleFor(AppLocalizations l10n, int tab) => switch (tab) {
    0 => l10n.lbStoreSubPro,
    1 => l10n.lbStoreSubCoins,
    2 => l10n.lbStoreSubThemes,
    3 => l10n.lbStoreSubSkins,
    4 => l10n.lbStoreSubTrails,
    _ => l10n.lbStoreSubPowerups,
  };

  /// One tab's scrolling body, on the content gutter.
  Widget _tabList(List<Widget> children) {
    final g = context.lbGutter;
    return ListView(
      padding: EdgeInsets.fromLTRB(g, 8, g, context.lbCell * 1.5),
      children: children,
    );
  }

  /// A catalogue grid that scrolls with its tab.
  Widget _grid(List<StoreItemBlock> items) => StoreCatalogGrid(items: items);

  /// The Pro tab's body: fills the viewport so the Pro card (the [Expanded]
  /// child) takes up spare height on tall phones; scrolls on short ones.
  Widget _proFill(List<Widget> children) {
    final g = context.lbGutter;
    return StoreFillScroll(
      padding: EdgeInsets.fromLTRB(g, 8, g, context.lbCell * .75),
      children: children,
    );
  }

  /// Living Board confirm step in front of every store sheet. Resolves true
  /// only on the buy action; cancel, back and barrier taps are a no.
  Future<bool> _confirmPurchase({
    required String title,
    required String body,
    required String buyLabel,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showLBDialog<bool>(
      context: context,
      title: title,
      body: body,
      primaryLabel: buyLabel,
      onPrimary: () => Navigator.of(context, rootNavigator: true).pop(true),
      secondaryLabel: l10n.commonCancel,
      onSecondary: () => Navigator.of(context, rootNavigator: true).pop(false),
    );
    return confirmed == true;
  }

  // ===========================================================================
  // PRO TAB
  // ===========================================================================

  Widget _buildProTab(GameTheme theme, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    // Drops any Pro SKU from the pending set once PremiumCubit reports
    // hasPremium=true — the spinner on the GO PRO button stops the moment the
    // backend's VerifyPurchase response lands.
    _reconcilePendingPurchases(premiumState);
    final perks = lbProPerks(l10n);
    final restore = StoreFooter(onRestore: () => lbRestorePurchases(context));

    // Paid Pro user — status, then the one action they might actually want
    // here: moving between billing periods. The plan blocks stay hidden (they
    // are a buy surface, and this user has already bought), but a subscriber
    // who wants yearly should not have to hunt for it.
    if (premiumState.hasPremium && !premiumState.isOnPromo) {
      return _proFill([
        _buildProActiveBanner(theme, premiumState),
        if (premiumState.hasPaidSubscription) ...[
          const SizedBox(height: 4),
          _buildProPlanSwitchRow(theme, premiumState),
        ],
        const SizedBox(height: 4),
        Expanded(child: StoreProCard(perks: perks, expand: true)),
        const SizedBox(height: 12),
        restore,
      ]);
    }

    // Promo user — status block with FREE PRO chip + perks + plan picker
    // below so they can convert without leaving the tab. The block's
    // "Keep Pro" action defaults to monthly; the picker lets them choose.
    if (premiumState.hasPremium && premiumState.isOnPromo) {
      return _proFill([
        _buildProActiveBanner(theme, premiumState),
        const SizedBox(height: 4),
        Expanded(child: StoreProCard(perks: perks, expand: true)),
        const SizedBox(height: 14),
        LBSectionLabel(l10n.storeSubscribeBeforePromoEnds),
        _buildProPlanPicker(),
        const SizedBox(height: 12),
        restore,
        SubscriptionLegalFooter(theme: theme),
      ]);
    }

    // What it is, then what it costs: the perks are the argument, the plan
    // blocks are the ask.
    return _proFill([
      Expanded(child: StoreProCard(perks: perks, expand: true)),
      _buildProPlanPicker(),
      const SizedBox(height: 12),
      restore,
      SubscriptionLegalFooter(theme: theme),
    ]);
  }

  /// MONTHLY / YEARLY blocks (yearly selected by default) and GO PRO, which
  /// buys the selected plan through [_purchaseSubscription].
  Widget _buildProPlanPicker() {
    final l10n = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    final monthlyPrice = PurchaseService().getStorePriceOrDefault(
      ProductIds.snakeClassicProMonthly,
      4.99,
      localeTag: localeTag,
    );
    final yearlyPrice = PurchaseService().getStorePriceOrDefault(
      ProductIds.snakeClassicProYearly,
      49.99,
      localeTag: localeTag,
    );
    // Whatever Play / App Store Connect actually offers on each plan for THIS
    // user — null when there is none, including for someone who has already
    // used their trial. Never hardcoded; see PurchaseService.getFreeTrialDays.
    final monthlyTrial = PurchaseService().getFreeTrialDays(
      ProductIds.snakeClassicProMonthly,
    );
    final yearlyTrial = PurchaseService().getFreeTrialDays(
      ProductIds.snakeClassicProYearly,
    );
    // While either plan is mid-verify, GO PRO and plan switching are
    // disabled so the user can't kick off a second purchase before the
    // first one's VerifyPurchase response lands — that would double-charge
    // and bug out the PremiumCubit's mid-flight state.
    final anyProPending =
        _pendingProductIds.contains(ProductIds.snakeClassicProMonthly) ||
        _pendingProductIds.contains(ProductIds.snakeClassicProYearly);
    final productId = _proYearly
        ? ProductIds.snakeClassicProYearly
        : ProductIds.snakeClassicProMonthly;
    final title = _proYearly ? l10n.storeYearly : l10n.storeMonthly;
    final trialDays = _proYearly ? yearlyTrial : monthlyTrial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StorePlanRow(
          monthly: StorePlanBlock(
            label: l10n.lbMonthly,
            price: monthlyPrice,
            line: l10n.lbPerMonth,
            selected: !_proYearly,
            trialLabel: monthlyTrial != null
                ? l10n.storeFreeTrialBadge(monthlyTrial)
                : null,
            onTap: anyProPending
                ? null
                : () => setState(() => _proYearly = false),
          ),
          yearly: StorePlanBlock(
            label: l10n.lbYearly,
            price: yearlyPrice,
            line: l10n.lbPerYearBestValue,
            selected: _proYearly,
            trialLabel: yearlyTrial != null
                ? l10n.storeFreeTrialBadge(yearlyTrial)
                : null,
            onTap: anyProPending
                ? null
                : () => setState(() => _proYearly = true),
          ),
        ),
        StoreGoProButton(
          // "Subscribe" is wrong when the first charge is days away — and
          // "Start free trial" is the wording the stores expect next to a
          // trial offer.
          trialLabel: trialDays != null ? l10n.storeStartFreeTrial : null,
          busyLabel: anyProPending ? l10n.storeVerifyingEllipsis : null,
          onTap: () => _purchaseSubscription(
            productId,
            l10n.storePlanDisplayName(title),
          ),
        ),
      ],
    );
  }

  /// Compact "move to the other billing period" row for an existing
  /// subscriber.
  ///
  /// Deliberately terser than the premium screen's version: the store is a
  /// browsing surface, so this states the offer and the money consequence in
  /// one line each and sends the decision to the store sheet. The full
  /// explanation lives on the Pro screen.
  Widget _buildProPlanSwitchRow(GameTheme theme, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final target = premiumState.switchTarget;
    if (target == null) return const SizedBox.shrink();

    final toYearly = target == PremiumPlan.yearly;
    final productId = toYearly
        ? ProductIds.snakeClassicProYearly
        : ProductIds.snakeClassicProMonthly;
    final busy = _pendingProductIds.contains(productId);
    final accent = toYearly ? LB.gold : p.head;

    return LBBlock(
      kind: toYearly ? LBBlockKind.gold : LBBlockKind.outline,
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Row(
        children: [
          LBPixelIcon(LBIcon.chart, cell: 4, color: accent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (toYearly ? l10n.pbSwitchToYearly : l10n.pbSwitchToMonthly)
                      .toUpperCase(),
                  style: LBText.button(p, color: accent, size: 12.5),
                ),
                const SizedBox(height: 3),
                Text(
                  toYearly
                      ? l10n.pbSwitchToYearlyBlurb
                      : l10n.pbSwitchToMonthlyBlurb,
                  style: LBText.body(p, size: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          StoreActionBlock(
            label: toYearly ? l10n.storeYearly : l10n.storeMonthly,
            busy: busy,
            feedback: false,
            onTap: () => _switchPlan(productId),
          ),
        ],
      ),
    );
  }

  /// Hand a plan change to the store.
  ///
  /// Routed through PremiumCubit.switchPlan rather than a plain buy: Play
  /// rejects purchasing the other subscription while one is active unless the
  /// existing purchase is named as the one being replaced.
  Future<void> _switchPlan(String productId) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final snackTheme = context.read<ThemeCubit>().state.currentTheme;
    final cubit = context.read<PremiumCubit>();
    final toYearly = productId == ProductIds.snakeClassicProYearly;

    setState(() => _pendingProductIds.add(productId));
    try {
      final launched = await cubit.switchPlan(productId);
      if (!mounted) return;
      messenger.showSnackBar(
        arcadeSnackBarFor(
          snackTheme,
          message: !launched
              ? l10n.storeSubNotAvailable
              : toYearly
              ? l10n.pbSwitchedToYearly
              : l10n.pbSwitchedToMonthly,
          tone: launched ? ArcadeSnackTone.success : ArcadeSnackTone.warning,
        ),
      );
    } finally {
      if (mounted) setState(() => _pendingProductIds.remove(productId));
    }
  }

  Widget _buildProActiveBanner(GameTheme theme, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    // Promo grants (welcome bonus / app-wide giveaway) get a PROMO chip + a
    // convert action so the user knows this is a limited window and there's
    // an action they can take. Paid Pro gets the plain "Pro is on" status.
    final isPromo = premiumState.isOnPromo;
    final expiry = isPromo
        ? premiumState.promoExpiresAt
        : premiumState.subscriptionExpiry;
    final expiryLabel = isPromo
        ? (expiry != null ? _formatPromoCountdown(expiry) : l10n.storeFreePro)
        : (expiry != null ? l10n.settingsRenews(_formatDate(expiry)) : null);

    if (!isPromo) {
      return StoreProActiveBlock(
        title: l10n.lbProActive,
        line: l10n.lbProActiveLine,
        detail: expiryLabel,
      );
    }
    return StoreProActiveBlock(
      title: l10n.storeYoureOnFreePro,
      chip: LBChip(label: l10n.storePromoBadge, kind: LBChipKind.gold),
      line: expiryLabel!,
      // Convert action — single tap straight into the store sheet for the
      // monthly plan, consistent with the GO PRO path.
      action: StoreActionBlock(
        label: l10n.storeKeepPro,
        kind: LBBlockKind.gold,
        feedback: false,
        onTap: () {
          _purchaseSubscription(
            ProductIds.snakeClassicProMonthly,
            l10n.storeProMonthly,
          );
        },
      ),
    );
  }

  /// Human-friendly countdown for promo expiry — "Ends in 2d 5h" / "Ends in
  /// 14h 20m" / "Ends in 32m" / "Ending soon". Negative durations
  /// (race between sync + revoke job) fall back to "Ending soon".
  String _formatPromoCountdown(DateTime expiry) {
    final l10n = AppLocalizations.of(context)!;
    final remaining = expiry.difference(DateTime.now());
    if (remaining.isNegative || remaining.inMinutes <= 0) {
      return l10n.storeEndingSoon;
    }
    final days = remaining.inDays;
    final hours = remaining.inHours.remainder(24);
    final minutes = remaining.inMinutes.remainder(60);
    if (days > 0) return l10n.storeEndsInDh(days, hours);
    if (hours > 0) return l10n.storeEndsInHm(hours, minutes);
    return l10n.storeEndsInM(minutes);
  }

  String _formatDate(DateTime d) {
    return context.formatDate(d);
  }

  /// Anonymous (guest) users can't make purchases — every paid path on this
  /// screen funnels through this check. On block we show the upgrade sheet;
  /// the caller bails so the user can re-tap Buy after they link an account.
  Future<bool> _ensurePurchasable() async {
    final user = context.read<AuthCubit>().state.user;
    if (user == null || !user.isAnonymous) return true;
    await showAccountUpgradeSheet(context);
    return false;
  }

  Future<void> _purchaseSubscription(
    String productId,
    String displayName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _ensurePurchasable()) return;
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    // Mark pending up-front so GO PRO swaps to a "Verifying…" state
    // covering the ~2–15s window between Play Store confirmation and the
    // backend's VerifyPurchase response landing in PremiumCubit. Auto-cleared
    // by _reconcilePendingPurchases when hasPremium flips true, or by the
    // 45s safety timeout in _markPending if the webhook is genuinely lost.
    _markPending(productId);
    // Captured with scaffoldMessenger above, for the same reason: both are
    // used on the far side of the purchase await.
    final snackTheme = context.read<ThemeCubit>().state.currentTheme;
    try {
      await PurchaseService().purchaseProduct(productId);
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          arcadeSnackBarFor(
            snackTheme,
            message: l10n.storeInitiatingPurchase(displayName),
          ),
        );
      }
    } catch (e) {
      // Failure path — drop the pending state immediately so the user can
      // retry without waiting for the 45s safety timeout.
      if (mounted) {
        setState(() => _pendingProductIds.remove(productId));
        scaffoldMessenger.showSnackBar(
          arcadeSnackBarFor(
            snackTheme,
            message: l10n.storeSubNotAvailable,
            tone: ArcadeSnackTone.error,
          ),
        );
      }
    }
  }

  // ===========================================================================
  // COINS TAB
  // ===========================================================================

  Widget _buildCoinsTab(GameTheme theme, CoinsState coinsState) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final options = CoinPurchaseOption.availableOptions;
    final featured = options.firstWhere(
      (o) => o.id == _focusCoinId,
      orElse: () =>
          options.firstWhere((o) => o.isPopular, orElse: () => options.first),
    );
    return _tabList([
      _buildCoinFeatured(featured, theme),
      const SizedBox(height: 14),
      LBSectionLabel(l10n.storeBuyCoins),
      for (final option in options) _buildCoinPackRow(option, theme),
      const SizedBox(height: 16),
      LBSectionLabel(l10n.storeEarnFreeCoins),
      // Rewarded ad — self-hides for Pro / when no ad is available.
      const StoreRewardedCoinsRow(),
      _buildEarnMethodRow(
        l10n.storeEarnPlay,
        l10n.storeEarnPlayReward,
        LBIcon.play,
        p,
      ),
      _buildEarnMethodRow(
        l10n.storeEarnDaily,
        l10n.storeEarnDailyReward,
        LBIcon.calendar,
        p,
      ),
      _buildEarnMethodRow(
        l10n.storeEarnAchievements,
        l10n.storeEarnAchievementsReward,
        LBIcon.trophy,
        p,
      ),
      _buildEarnMethodRow(
        l10n.storeEarnTournaments,
        l10n.storeEarnTournamentsReward,
        LBIcon.swords,
        p,
      ),
    ]);
  }

  String _coinPackPrice(CoinPurchaseOption option) =>
      PurchaseService().getStorePriceOrDefault(
        ProductIds.withPrefix(option.id),
        option.price,
        localeTag: Localizations.localeOf(context).toLanguageTag(),
      );

  Widget _buildCoinFeatured(CoinPurchaseOption option, GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return StoreFeaturedCard(
      preview: LBPixelIcon(
        LBIcon.coin,
        cell: storePreviewCell(context, 16),
        color: LB.gold,
      ),
      title: option.localizedName(l10n),
      titleColor: LB.gold,
      line: option.localizedDisplayCoins(l10n),
      badge: option.isPopular
          ? LBChip(label: l10n.storePopularBadge, kind: LBChipKind.gold)
          : null,
      action: StoreActionBlock(
        label: l10n.lbBuyPrice(_coinPackPrice(option)),
        kind: LBBlockKind.goldFill,
        feedback: false,
        onTap: () {
          setState(() => _focusCoinId = option.id);
          _purchaseCoinPack(option, theme);
        },
      ),
    );
  }

  Widget _buildCoinPackRow(CoinPurchaseOption option, GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final focused = option.id == (_focusCoinId ?? '') ||
        (_focusCoinId == null && option.isPopular);
    return LBBlock(
      kind: focused ? LBBlockKind.gold : LBBlockKind.outline,
      selected: focused,
      feedback: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: () {
        setState(() => _focusCoinId = option.id);
        _purchaseCoinPack(option, theme);
      },
      child: Row(
        children: [
          LBPixelIcon(LBIcon.coin, cell: 4, color: LB.gold),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        option.localizedName(l10n).toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: LBText.button(p, color: p.ink, size: 12.5),
                      ),
                    ),
                    if (option.isPopular) ...[
                      const SizedBox(width: 8),
                      LBChip(
                        label: l10n.storePopularBadge,
                        kind: LBChipKind.gold,
                        height: 18,
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  option.localizedDisplayCoins(l10n),
                  style: LBText.body(p, size: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Text(
            _coinPackPrice(option),
            style: LBText.value(p, color: LB.gold, size: 16),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseCoinPack(
    CoinPurchaseOption option,
    GameTheme theme,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _ensurePurchasable()) return;
    if (!mounted) return;
    final price = PurchaseService().getStorePriceOrDefault(
      ProductIds.withPrefix(option.id),
      option.price,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
    final confirmed = await _confirmPurchase(
      title: l10n.storeBuyItem(option.localizedName(l10n)),
      body: l10n.storeBuyCoinsBody(option.localizedDisplayCoins(l10n), price),
      buyLabel: l10n.storeBuyForPrice(price),
    );
    if (!confirmed || !mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await PurchaseService().purchaseProduct(
        ProductIds.withPrefix(option.id),
      );
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          arcadeSnackBar(
            context,
            message: l10n.storeInitiatingFor(option.localizedName(l10n)),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          arcadeSnackBar(
            context,
            message: l10n.storeProductNotAvailable,
            tone: ArcadeSnackTone.error,
          ),
        );
      }
    }
  }

  Widget _buildEarnMethodRow(
    String title,
    String reward,
    LBIcon icon,
    LBPalette p,
  ) {
    return LBRow(
      title: title,
      leading: LBPixelIcon(icon, cell: 3.6, color: p.lime),
      trailing: Text(
        reward,
        style: LBText.button(p, color: LB.gold, size: 12.5),
      ),
    );
  }

  // ===========================================================================
  // THEMES TAB
  // ===========================================================================

  /// Row on the cosmetic tabs (themes / skins / trails) telling the user a Pro
  /// subscription unlocks everything in that tab. Tapping it (when not
  /// already Pro) jumps to the Pro tab. Power-Ups are intentionally excluded —
  /// Pro doesn't unlock the power-up catalog.
  Widget _buildProIncludedBanner(
    GameTheme theme,
    PremiumState premiumState, {
    required String ownedBody,
    required String upsellBody,
  }) {
    final l10n = AppLocalizations.of(context)!;
    final isPro = premiumState.hasPremium;
    return LBRow(
      kind: LBBlockKind.gold,
      titleColor: LB.gold,
      title: isPro ? l10n.storeUnlockedWithPro : l10n.storeIncludedWithPro,
      subtitle: isPro ? ownedBody : upsellBody,
      leading: LBPixelIcon(
        isPro ? LBIcon.check : LBIcon.crown,
        cell: 4,
        color: LB.gold,
      ),
      trailing: isPro
          ? null
          : LBPixelIcon(LBIcon.next, cell: 3, color: LB.gold),
      onTap: isPro ? null : () => _tabController.animateTo(0),
    );
  }

  Widget _buildThemesTab(GameTheme theme, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    // Premium themes — listed as products in the Play Store catalog.
    const premiumThemes = [
      GameTheme.crystal,
      GameTheme.cyberpunk,
      GameTheme.space,
      GameTheme.ocean,
      GameTheme.desert,
      GameTheme.forest,
    ];
    // Free themes — included with every install. Surfaced here so the
    // user has an obvious way to switch back to their previous theme
    // after trying a premium one. The home/settings theme selector
    // still works, but this tab is the canonical store + switcher.
    const freeThemes = [
      GameTheme.classic,
      GameTheme.modern,
      GameTheme.neon,
      GameTheme.retro,
    ];

    // Once a pending purchase reflects as owned, drop it from the pending
    // set on the next frame so we don't trigger a build-during-build.
    _reconcilePendingPurchases(premiumState);

    final focus =
        _focusTheme ??
        premiumThemes.firstWhere(
          (t) => !premiumState.isThemeUnlocked(t),
          orElse: () => theme,
        );

    return _tabList([
      _buildThemeFeatured(focus, theme, premiumState),
      const SizedBox(height: 4),
      _buildThemesBundleCard(theme, premiumState),
      const SizedBox(height: 14),
      LBSectionLabel(l10n.storePremiumThemes),
      _grid([
        for (final t in premiumThemes)
          _buildThemeBlock(t, theme, premiumState, focus),
      ]),
      const SizedBox(height: 14),
      LBSectionLabel(l10n.storeFreeThemes),
      Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Text(
          l10n.storeFreeThemesSubtitle,
          style: LBText.body(p, size: 11),
        ),
      ),
      _grid([
        for (final t in freeThemes)
          _buildThemeBlock(t, theme, premiumState, focus),
      ]),
      const SizedBox(height: 14),
      _buildProIncludedBanner(
        theme,
        premiumState,
        ownedBody: l10n.storeProBannerThemesOwned,
        upsellBody: l10n.storeProBannerThemesUpsell,
      ),
    ]);
  }

  /// The theme's own board, snake and apple, drawn from its [LBPalette].
  List<Color> _themeSnakeColors(LBPalette pal) {
    final n = StoreCellSnake.segments;
    return [
      for (var i = 0; i < n; i++)
        i == 0
            ? pal.head
            : pal.lime.withValues(alpha: 1 - (i / (n - 1)) * .55),
    ];
  }

  Widget _buildThemeFeatured(
    GameTheme target,
    GameTheme currentTheme,
    PremiumState premiumState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final isOwned = premiumState.isThemeUnlocked(target);
    final isActive = currentTheme == target;
    final productId = _productIdForTheme(target);
    final isPending =
        productId != null && _pendingProductIds.contains(productId);
    final pal = LBPalette.of(target);

    final Widget action;
    if (isPending) {
      action = StoreActionBlock(
        label: l10n.storePillVerifying,
        kind: LBBlockKind.muted,
        busy: true,
      );
    } else if (isActive) {
      action = StoreActionBlock(
        label: l10n.storePillActive,
        kind: LBBlockKind.muted,
      );
    } else if (isOwned) {
      action = StoreActionBlock(
        label: l10n.storePillApply,
        onTap: () => context.read<ThemeCubit>().setTheme(target),
      );
    } else if (productId != null) {
      final price = PurchaseService().getStorePriceOrDefault(
        productId,
        1.99,
        localeTag: Localizations.localeOf(context).toLanguageTag(),
      );
      action = StoreActionBlock(
        label: l10n.lbBuyPrice(price),
        kind: LBBlockKind.goldFill,
        feedback: false,
        onTap: () {
          setState(() => _focusTheme = target);
          _purchaseThemeProduct(productId, target.name);
        },
      );
    } else {
      action = const SizedBox.shrink();
    }

    return StoreFeaturedCard(
      preview: StoreCellSnake(
        colors: _themeSnakeColors(pal),
        cell: storePreviewCell(context, 9.5),
        board: pal,
      ),
      title: target.localizedName(l10n),
      titleColor: isOwned ? null : LB.gold,
      line: _shortThemeDescription(target),
      action: action,
      footnote: !isOwned && productId != null && !premiumState.hasPremium
          ? l10n.lbOrFreeWithPro
          : null,
    );
  }

  StoreItemBlock _buildThemeBlock(
    GameTheme target,
    GameTheme currentTheme,
    PremiumState premiumState,
    GameTheme focus,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final isOwned = premiumState.isThemeUnlocked(target);
    final isActive = currentTheme == target;
    final productId = _productIdForTheme(target);
    final isPending =
        productId != null && _pendingProductIds.contains(productId);
    final price = productId == null
        ? l10n.storePillFree
        : PurchaseService().getStorePriceOrDefault(
            productId,
            1.99,
            localeTag: Localizations.localeOf(context).toLanguageTag(),
          );
    final pal = LBPalette.of(target);
    final (status, statusColor) = isPending
        ? (l10n.storePillVerifying, p.inkMuted)
        : isActive
        ? (l10n.storePillActive, p.lime)
        : isOwned
        ? (l10n.storePillApply, p.head)
        : (price, p.inkMuted);
    return StoreItemBlock(
      swatch: [pal.lime, pal.head, pal.lime, pal.head, pal.food],
      swatchBackground: pal.board,
      name: target.localizedName(l10n),
      status: status,
      statusColor: statusColor,
      busy: isPending,
      focused: target == focus,
      active: isActive,
      onTap: isPending
          ? null
          : () {
              setState(() => _focusTheme = target);
              // Owned themes apply on tap, as before; locked ones are bought
              // from the featured card above.
              if (isOwned && !isActive) {
                context.read<ThemeCubit>().setTheme(target);
              }
            },
    );
  }

  /// Drop any pendingProductIds that the backend now reports as owned.
  /// Scheduled post-frame to avoid setState-during-build crashes.
  void _reconcilePendingPurchases(PremiumState premiumState) {
    if (_pendingProductIds.isEmpty) return;
    final justOwned = <String>[];
    for (final productId in _pendingProductIds) {
      if (_isProductOwned(productId, premiumState)) {
        justOwned.add(productId);
      }
    }
    if (justOwned.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _pendingProductIds.removeAll(justOwned));
    });
  }

  /// Resolve "is this productId now owned" across themes / skins / trails /
  /// bundles so the pending spinner clears regardless of the cosmetic type.
  bool _isProductOwned(String productId, PremiumState premiumState) {
    // Pro subscription SKUs — once PremiumCubit flips to hasPremium=true the
    // Pro tab swaps to the "Pro is on" block, but we also clear pending
    // so any leftover spinner state doesn't survive a tab switch.
    if (productId == ProductIds.snakeClassicProMonthly ||
        productId == ProductIds.snakeClassicProYearly) {
      return premiumState.hasPremium;
    }
    // Themes — including the all-themes bundle. Pro subscribers also have
    // all premium themes implicitly.
    if (productId == ProductIds.themesBundle) {
      return premiumState.isBundleOwned('premium_themes_bundle');
    }
    for (final t in GameTheme.values) {
      if (_productIdForTheme(t) == productId) {
        return premiumState.isThemeUnlocked(t);
      }
    }
    // Skins: store ID is `${prefix}skin_<id>`
    final stripped = productId.startsWith(ProductIds.prefix)
        ? productId.substring(ProductIds.prefix.length)
        : productId;
    if (stripped.startsWith('skin_')) {
      return premiumState.isSkinOwned(stripped.substring('skin_'.length));
    }
    // Trails: store ID is `${prefix}trail_<id>` — kept with the prefix in
    // PremiumState.ownedTrails per the existing convention.
    if (stripped.startsWith('trail_')) {
      return premiumState.isTrailOwned(stripped);
    }
    // Any remaining bundle products — owned set uses the bare ID.
    return premiumState.isBundleOwned(stripped);
  }

  Widget _buildThemesBundleCard(GameTheme theme, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final bundleOwned = premiumState.isBundleOwned('premium_themes_bundle');
    final isPending = _pendingProductIds.contains(ProductIds.themesBundle);
    final price = PurchaseService().getStorePriceOrDefault(
      ProductIds.themesBundle,
      7.99,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
    final Widget status;
    if (isPending) {
      status = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          StoreSpinner(color: p.inkMuted),
          const SizedBox(width: 6),
          Text(
            l10n.storePillVerifying,
            style: LBText.button(p, color: p.inkMuted, size: 11.5),
          ),
        ],
      );
    } else {
      status = Text(
        bundleOwned ? l10n.storePillOwned : price,
        style: bundleOwned
            ? LBText.button(p, color: p.lime, size: 12)
            : LBText.value(p, color: LB.gold, size: 16),
      );
    }
    return LBBlock(
      kind: LBBlockKind.gold,
      feedback: false,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      onTap: (bundleOwned || isPending)
          ? null
          : () => _purchaseThemeProduct(
              ProductIds.themesBundle,
              l10n.storeAllThemesBundle,
            ),
      child: Row(
        children: [
          LBPixelIcon(LBIcon.gift, cell: 4.4, color: LB.gold),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.storeAllThemesBundle.toUpperCase(),
                  style: LBText.button(p, color: LB.gold, size: 12.5),
                ),
                const SizedBox(height: 3),
                Text(
                  l10n.storeAllThemesBundleSubtitle,
                  style: LBText.body(p, size: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          status,
        ],
      ),
    );
  }

  String _shortThemeDescription(GameTheme target) {
    final l10n = AppLocalizations.of(context)!;
    switch (target) {
      case GameTheme.classic:
        return l10n.storeThemeDescClassic;
      case GameTheme.modern:
        return l10n.storeThemeDescModern;
      case GameTheme.neon:
        return l10n.storeThemeDescNeon;
      case GameTheme.retro:
        return l10n.storeThemeDescRetro;
      case GameTheme.space:
        return l10n.storeThemeDescSpace;
      case GameTheme.ocean:
        return l10n.storeThemeDescOcean;
      case GameTheme.cyberpunk:
        return l10n.storeThemeDescCyberpunk;
      case GameTheme.forest:
        return l10n.storeThemeDescForest;
      case GameTheme.desert:
        return l10n.storeThemeDescDesert;
      case GameTheme.crystal:
        return l10n.storeThemeDescCrystal;
    }
  }

  String? _productIdForTheme(GameTheme target) {
    switch (target) {
      case GameTheme.crystal:
        return ProductIds.crystalTheme;
      case GameTheme.cyberpunk:
        return ProductIds.cyberpunkTheme;
      case GameTheme.space:
        return ProductIds.spaceTheme;
      case GameTheme.ocean:
        return ProductIds.oceanTheme;
      case GameTheme.desert:
        return ProductIds.desertTheme;
      case GameTheme.forest:
        return ProductIds.forestTheme;
      default:
        return null;
    }
  }

  Future<void> _purchaseThemeProduct(
    String productId,
    String displayName,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _ensurePurchasable()) return;
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final price = PurchaseService().getStorePriceOrDefault(
      productId,
      1.99,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
    final confirmed = await _confirmPurchase(
      title: displayName,
      body: l10n.storeUnlockFor(displayName, price),
      buyLabel: l10n.storeBuyForPrice(price),
    );

    if (confirmed != true) return;

    try {
      await PurchaseService().purchaseProduct(productId);
      if (!mounted) return;
      _markPending(productId);
      scaffoldMessenger.showSnackBar(
        arcadeSnackBar(
          context,
          message: l10n.storeVerifyingPurchase(displayName),
        ),
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          arcadeSnackBar(
            context,
            message: l10n.storeThemeNotAvailable,
            tone: ArcadeSnackTone.error,
          ),
        );
      }
    }
  }

  /// Mark a productId as "purchase pending" so its card shows the
  /// verifying spinner. Auto-cleared once ownership reflects in
  /// PremiumState (see _reconcilePendingPurchases), or after 45s as a
  /// safety net so a dropped Play Store callback doesn't leave the UI
  /// stuck in a verifying state forever.
  void _markPending(String productId) {
    setState(() => _pendingProductIds.add(productId));
    Future.delayed(const Duration(seconds: 45), () {
      if (!mounted) return;
      if (!_pendingProductIds.contains(productId)) return;
      setState(() => _pendingProductIds.remove(productId));
    });
  }

  // ===========================================================================
  // SKINS TAB
  // ===========================================================================

  /// The skin's own colours along the S, head lightened so it reads as the
  /// head. Classic follows the theme's snake colour, as it does in play.
  List<Color> _skinSnakeColors(SnakeSkinType skin, LBPalette p) {
    final pal = skin == SnakeSkinType.classic ? [p.lime] : skin.colors;
    final n = StoreCellSnake.segments;
    final two = storeSwatch(pal, p.lime, count: 2);
    return [
      for (var i = 0; i < n; i++)
        () {
          final base = pal.length <= 2
              ? two[i % 2]
              : pal[((i * (pal.length - 1)) / (n - 1)).round()];
          return i == 0 ? Color.lerp(base, Colors.white, .45)! : base;
        }(),
    ];
  }

  String _skinTagline(SnakeSkinType skin, AppLocalizations l10n) =>
      switch (skin) {
        SnakeSkinType.classic => skin.localizedDescription(l10n),
        SnakeSkinType.golden => l10n.lbSkinTagGolden,
        SnakeSkinType.rainbow => l10n.lbSkinTagRainbow,
        SnakeSkinType.galaxy => l10n.lbSkinTagGalaxy,
        SnakeSkinType.dragon => l10n.lbSkinTagDragon,
        SnakeSkinType.electric => l10n.lbSkinTagElectric,
        SnakeSkinType.fire => l10n.lbSkinTagFire,
        SnakeSkinType.ice => l10n.lbSkinTagIce,
        SnakeSkinType.shadow => l10n.lbSkinTagShadow,
        SnakeSkinType.neon => l10n.lbSkinTagNeon,
        SnakeSkinType.crystal => l10n.lbSkinTagCrystal,
        SnakeSkinType.cosmic => l10n.lbSkinTagCosmic,
      };

  void _equipSkin(SnakeSkinType skin) {
    final l10n = AppLocalizations.of(context)!;
    context.read<PremiumCubit>().selectSkin(skin.id);
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: l10n.storeEquippedToast(skin.localizedName(l10n)),
        tone: ArcadeSnackTone.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _skinPrice(SnakeSkinType skin, AppLocalizations l10n) =>
      skin.isPremium
      ? PurchaseService().getStorePriceOrDefault(
          ProductIds.skinStoreId(skin.id),
          skin.price,
          localeTag: Localizations.localeOf(context).toLanguageTag(),
        )
      : l10n.storePillFree;

  Widget _buildSkinsTab(GameTheme theme, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    _reconcilePendingPurchases(premiumState);
    const skins = SnakeSkinType.values;
    final focus =
        _focusSkin ??
        skins.firstWhere(
          // Pro subscription unlocks all premium skins (mirrors theme
          // bundling), so for Pro this falls through to the equipped skin.
          (s) => !premiumState.isSkinUnlocked(s),
          orElse: () => skins.firstWhere(
            (s) => s.id == premiumState.selectedSkinId,
            orElse: () => skins.first,
          ),
        );

    return _tabList([
      _buildSkinFeatured(focus, premiumState),
      const SizedBox(height: 10),
      _grid([
        for (final skin in skins)
          () {
            final isUnlocked = premiumState.isSkinUnlocked(skin);
            final isSelected = premiumState.selectedSkinId == skin.id;
            final isPending = _pendingProductIds.contains(
              ProductIds.skinStoreId(skin.id),
            );
            final (status, statusColor) = isPending
                ? (l10n.storePillVerifying, p.inkMuted)
                : isSelected
                ? (l10n.lbEquipped, p.lime)
                : isUnlocked
                ? (l10n.lbEquip, p.head)
                : (_skinPrice(skin, l10n), p.inkMuted);
            return StoreItemBlock(
              swatch: storeSwatch(
                skin == SnakeSkinType.classic ? [p.lime] : skin.colors,
                p.lime,
              ),
              name: skin.localizedName(l10n),
              status: status,
              statusColor: statusColor,
              busy: isPending,
              focused: skin == focus,
              active: isSelected,
              onTap: isPending
                  ? null
                  : () {
                      setState(() => _focusSkin = skin);
                      // Owned skins equip on tap, as before; locked ones are
                      // bought from the featured card above.
                      if (isUnlocked && !isSelected) _equipSkin(skin);
                    },
            );
          }(),
      ]),
      const SizedBox(height: 14),
      _buildProIncludedBanner(
        theme,
        premiumState,
        ownedBody: l10n.storeProBannerSkinsOwned,
        upsellBody: l10n.storeProBannerSkinsUpsell,
      ),
    ]);
  }

  Widget _buildSkinFeatured(SnakeSkinType skin, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final isUnlocked = premiumState.isSkinUnlocked(skin);
    final isSelected = premiumState.selectedSkinId == skin.id;
    final productId = ProductIds.skinStoreId(skin.id);
    final isPending = _pendingProductIds.contains(productId);

    final Widget action;
    if (isPending) {
      action = StoreActionBlock(
        label: l10n.storePillVerifying,
        kind: LBBlockKind.muted,
        busy: true,
      );
    } else if (isSelected) {
      action = StoreActionBlock(
        label: l10n.lbEquipped,
        kind: LBBlockKind.muted,
      );
    } else if (isUnlocked) {
      action = StoreActionBlock(
        label: l10n.lbEquip,
        onTap: () => _equipSkin(skin),
      );
    } else {
      action = StoreActionBlock(
        label: l10n.lbBuyPrice(_skinPrice(skin, l10n)),
        kind: LBBlockKind.goldFill,
        feedback: false,
        onTap: () {
          setState(() => _focusSkin = skin);
          _purchaseCosmetic(
            productId: productId,
            displayName: skin.localizedName(l10n),
            fallbackPrice: skin.price,
          );
        },
      );
    }

    return StoreFeaturedCard(
      preview: StoreCellSnake(
        colors: _skinSnakeColors(skin, p),
        cell: storePreviewCell(context, 11.5),
      ),
      title: skin.localizedName(l10n),
      titleColor: isUnlocked ? null : LB.gold,
      line: _skinTagline(skin, l10n),
      action: action,
      footnote: !isUnlocked && !premiumState.hasPremium
          ? l10n.lbOrFreeWithPro
          : null,
    );
  }

  // ===========================================================================
  // TRAILS TAB
  // ===========================================================================

  /// The snake in the theme's colours, its tail painted in the trail's
  /// colours and fading out. "No trail" just fades.
  List<Color> _trailSnakeColors(TrailEffectType trail, LBPalette p) {
    final n = StoreCellSnake.segments;
    const body = 7;
    return [
      for (var i = 0; i < n; i++)
        if (i == 0)
          p.head
        else if (i < body || trail.colors.isEmpty)
          p.lime.withValues(alpha: 1 - (i / (n - 1)) * .55)
        else
          trail.colors[(i - body) % trail.colors.length].withValues(
            alpha: .95 - ((i - body) / (n - body)) * .65,
          ),
    ];
  }

  void _equipTrail(TrailEffectType trail) {
    final l10n = AppLocalizations.of(context)!;
    context.read<PremiumCubit>().selectTrail(trail.id);
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: l10n.storeEquippedToast(trail.localizedName(l10n)),
        tone: ArcadeSnackTone.success,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  String _trailPrice(TrailEffectType trail, AppLocalizations l10n) =>
      trail.isPremium
      ? PurchaseService().getStorePriceOrDefault(
          ProductIds.withPrefix(trail.id),
          trail.price,
          localeTag: Localizations.localeOf(context).toLanguageTag(),
        )
      : l10n.storePillFree;

  Widget _buildTrailsTab(GameTheme theme, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    _reconcilePendingPurchases(premiumState);
    const trails = TrailEffectType.values;
    final focus =
        _focusTrail ??
        trails.firstWhere(
          // Pro subscription unlocks all premium trails (mirrors theme
          // bundling), so for Pro this falls through to the equipped trail.
          (t) => !premiumState.isTrailUnlocked(t),
          orElse: () => trails.firstWhere(
            (t) => t.id == premiumState.selectedTrailId,
            orElse: () => trails.first,
          ),
        );

    return _tabList([
      _buildTrailFeatured(focus, premiumState),
      const SizedBox(height: 10),
      _grid([
        for (final trail in trails)
          () {
            final isUnlocked = premiumState.isTrailUnlocked(trail);
            final isSelected = premiumState.selectedTrailId == trail.id;
            final isPending = _pendingProductIds.contains(
              ProductIds.withPrefix(trail.id),
            );
            final (status, statusColor) = isPending
                ? (l10n.storePillVerifying, p.inkMuted)
                : isSelected
                ? (l10n.lbEquipped, p.lime)
                : isUnlocked
                ? (l10n.lbEquip, p.head)
                : (_trailPrice(trail, l10n), p.inkMuted);
            return StoreItemBlock(
              swatch: storeSwatch(trail.colors, p.cellOff),
              name: trail.localizedName(l10n),
              status: status,
              statusColor: statusColor,
              busy: isPending,
              focused: trail == focus,
              active: isSelected,
              onTap: isPending
                  ? null
                  : () {
                      setState(() => _focusTrail = trail);
                      // Owned trails equip on tap, as before; locked ones are
                      // bought from the featured card above.
                      if (isUnlocked && !isSelected) _equipTrail(trail);
                    },
            );
          }(),
      ]),
      const SizedBox(height: 14),
      _buildProIncludedBanner(
        theme,
        premiumState,
        ownedBody: l10n.storeProBannerTrailsOwned,
        upsellBody: l10n.storeProBannerTrailsUpsell,
      ),
    ]);
  }

  Widget _buildTrailFeatured(TrailEffectType trail, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final isUnlocked = premiumState.isTrailUnlocked(trail);
    final isSelected = premiumState.selectedTrailId == trail.id;
    final productId = ProductIds.withPrefix(trail.id);
    final isPending = _pendingProductIds.contains(productId);

    final Widget action;
    if (isPending) {
      action = StoreActionBlock(
        label: l10n.storePillVerifying,
        kind: LBBlockKind.muted,
        busy: true,
      );
    } else if (isSelected) {
      action = StoreActionBlock(
        label: l10n.lbEquipped,
        kind: LBBlockKind.muted,
      );
    } else if (isUnlocked) {
      action = StoreActionBlock(
        label: l10n.lbEquip,
        onTap: () => _equipTrail(trail),
      );
    } else {
      action = StoreActionBlock(
        label: l10n.lbBuyPrice(_trailPrice(trail, l10n)),
        kind: LBBlockKind.goldFill,
        feedback: false,
        onTap: () {
          setState(() => _focusTrail = trail);
          _purchaseCosmetic(
            productId: productId,
            displayName: trail.localizedName(l10n),
            fallbackPrice: trail.price,
          );
        },
      );
    }

    return StoreFeaturedCard(
      preview: StoreCellSnake(
        colors: _trailSnakeColors(trail, p),
        cell: storePreviewCell(context, 11.5),
      ),
      title: trail.localizedName(l10n),
      titleColor: isUnlocked ? null : LB.gold,
      line: trail.localizedDescription(l10n),
      action: action,
      footnote: !isUnlocked && !premiumState.hasPremium
          ? l10n.lbOrFreeWithPro
          : null,
    );
  }

  Future<void> _purchaseCosmetic({
    required String productId,
    required String displayName,
    required double fallbackPrice,
  }) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _ensurePurchasable()) return;
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final price = PurchaseService().getStorePriceOrDefault(
      productId,
      fallbackPrice,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
    final confirmed = await _confirmPurchase(
      title: displayName,
      body: l10n.storeUnlockFor(displayName, price),
      buyLabel: l10n.storeBuyForPrice(price),
    );

    if (confirmed != true) return;

    try {
      await PurchaseService().purchaseProduct(productId);
      if (!mounted) return;
      _markPending(productId);
      scaffoldMessenger.showSnackBar(
        arcadeSnackBar(
          context,
          message: l10n.storeVerifyingPurchase(displayName),
        ),
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          arcadeSnackBar(
            context,
            message: l10n.storeItemNotAvailable,
            tone: ArcadeSnackTone.error,
          ),
        );
      }
    }
  }

  // ===========================================================================
  // POWER-UPS TAB
  // ===========================================================================
  // Power-ups now have a real coin-purchased inventory backed by the
  // /api/v1/PowerUps/{inventory,purchase,consume} endpoints. The 4 types
  // here match the PowerUpType enum used by the gameplay engine, so each
  // purchase produces a usable stockpile entry (activation UI lands in a
  // follow-up — for now the inventory accrues server-side and the user
  // can see their count).

  /// Rewarded-ad block granting one free Speed Boost. Self-hides for Pro /
  /// web / when the SDK isn't ready; disables when no ad is loaded.
  Widget _buildFreePowerUpAdCard(BuildContext context, GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final ads = getIt.isRegistered<AdService>() ? getIt<AdService>() : null;
    if (ads == null || !ads.adsEnabled) return const SizedBox.shrink();
    // Opt-in placement, uncapped by design (the daily caps were removed) —
    // the only gate is whether a rewarded ad is loaded.
    final ready = ads.isRewardedReady;
    return Opacity(
      opacity: ready ? 1 : 0.5,
      child: LBBlock(
        feedback: false,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        onTap: ready
            ? () {
                final powerUps = context.read<PowerUpCubit>();
                // Capture before the ad — onReward fires after dismissal,
                // an async gap where reading context is unsafe.
                final messenger = ScaffoldMessenger.of(context);
                ads.showRewardedFor(
                  placement: AdService.placementFreePowerUp,
                  onReward: () {
                    powerUps.grantFreePowerUp();
                    showRewardToast(
                      messenger,
                      l10n.storeFreeSpeedBoostInventory,
                      icon: Icons.flash_on,
                    );
                  },
                );
              }
            : null,
        child: Row(
          children: [
            LBPixelIcon(LBIcon.tv, cell: 4, color: p.lime),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    l10n.storeWatchAdTitle.toUpperCase(),
                    style: LBText.button(p, size: 12.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    ready ? l10n.storeWatchAdReady : l10n.storeWatchAdNotReady,
                    style: LBText.body(p, size: 11),
                  ),
                ],
              ),
            ),
            LBPixelIcon(LBIcon.bolt, cell: 3.6, color: p.lime),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerUpsTab(
    GameTheme theme,
    PremiumState premiumState,
    CoinsState coinsState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    // Power-up types use snake_case to match the JSON dictionary keys
    // returned by the backend (ASP.NET applies DictionaryKeyPolicy =
    // SnakeCaseLower to outgoing dicts). Mapping back to PowerUpType for
    // activation lives in the game cubit (next commit).
    // Coin costs MUST match PurchasePowerUpWithCoinsCommandHandler.AllowedCosts
    // on the backend — server rejects request.CoinCost mismatches outright.
    final powerUps = [
      _PowerUpCatalogItem(
        type: 'speed_boost',
        name: l10n.puSpeedBoost,
        description: l10n.puSpeedBoostDesc,
        icon: LBIcon.bolt,
        coinCost: 500,
      ),
      _PowerUpCatalogItem(
        type: 'invincibility',
        name: l10n.puInvincibility,
        description: l10n.puInvincibilityDesc,
        icon: LBIcon.shield,
        coinCost: 1000,
      ),
      _PowerUpCatalogItem(
        type: 'score_multiplier',
        name: l10n.puScoreMultiplier,
        description: l10n.puScoreMultiplierDesc,
        icon: LBIcon.star,
        coinCost: 750,
      ),
      _PowerUpCatalogItem(
        type: 'slow_motion',
        name: l10n.puSlowMotion,
        description: l10n.puSlowMotionDesc,
        icon: LBIcon.hourglass,
        coinCost: 500,
      ),
    ];

    return BlocBuilder<PowerUpCubit, PowerUpState>(
      builder: (context, powerUpState) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        return _tabList([
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 0, 2, 8),
            child: Text(l10n.storePowerUpsInfo, style: LBText.body(p, size: 11)),
          ),
          // Rewarded ad — free Speed Boost. Self-hides for Pro / no ad.
          _buildFreePowerUpAdCard(context, theme),
          const SizedBox(height: 12),
          LBSectionLabel(l10n.storePowerUps),
          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220 * context.uiScale,
              mainAxisExtent: 26 * context.uiScale + 104 * textScale,
            ),
            children: [
              for (final item in powerUps)
                _buildPowerUpCatalogCard(item, powerUpState),
            ],
          ),
          const SizedBox(height: 16),
          LBSectionLabel(l10n.storePowerUpBundles),
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              l10n.storeBundlesSubtitle,
              style: LBText.body(p, size: 11),
            ),
          ),
          ...PowerUpBundle.availableBundles.map(
            (bundle) => _buildPowerUpBundleCard(
              bundle,
              theme,
              premiumState,
              coinsState,
            ),
          ),
        ]);
      },
    );
  }

  Widget _buildPowerUpCatalogCard(
    _PowerUpCatalogItem item,
    PowerUpState powerUpState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final owned = powerUpState.countFor(item.type);
    return LBBlock(
      feedback: false,
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),
      onTap: () => _purchasePowerUpWithCoins(item),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              LBPixelIcon(item.icon, cell: 4, color: p.lime),
              const Spacer(),
              if (owned > 0)
                LBChip(
                  label: l10n.storeOwnedCountBadge(owned),
                  height: 20,
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: LBText.button(p, color: p.ink, size: 12),
              ),
              const SizedBox(height: 2),
              Text(
                item.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: LBText.body(p, size: 10.5).copyWith(height: 1.3),
              ),
            ],
          ),
          Text(
            l10n.lbBuyCoins(context.formatInt(item.coinCost)),
            style: LBText.button(p, color: LB.gold, size: 12),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePowerUpWithCoins(_PowerUpCatalogItem item) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _ensurePurchasable()) return;
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final coinsCubit = context.read<CoinsCubit>();
    final powerUpCubit = context.read<PowerUpCubit>();
    final snackTheme = context.read<ThemeCubit>().state.currentTheme;
    final coinsBalance = coinsCubit.state.balance.total;
    if (coinsBalance < item.coinCost) {
      scaffoldMessenger.showSnackBar(
        arcadeSnackBar(
          context,
          message: l10n.storeInsufficientCoins,
          tone: ArcadeSnackTone.error,
        ),
      );
      return;
    }

    final confirmed = await _confirmPurchase(
      title: item.name,
      body: l10n.storeBuyPowerUpBody(item.coinCost, item.name),
      buyLabel: l10n.storeBuyCostCoins(item.coinCost),
    );
    if (confirmed != true || !mounted) return;

    final newBalance = await powerUpCubit.purchaseWithCoins(
      item.type,
      item.coinCost,
    );
    if (!mounted) return;
    if (newBalance == null) {
      scaffoldMessenger.showSnackBar(
        arcadeSnackBar(
          context,
          message: l10n.storePurchaseFailedRetry,
          tone: ArcadeSnackTone.error,
        ),
      );
      return;
    }
    // Reflect the server-authoritative coin balance locally so the
    // CoinsCubit and any other UI stays in sync without an extra round-trip.
    await coinsCubit.setServerBalance(newBalance);
    scaffoldMessenger.showSnackBar(
      arcadeSnackBarFor(
        snackTheme,
        message: l10n.storeAddedToLoadout(item.name),
        tone: ArcadeSnackTone.success,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildPowerUpBundleCard(
    PowerUpBundle bundle,
    GameTheme theme,
    PremiumState premiumState,
    CoinsState coinsState,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final isOwned = premiumState.isBundleOwned(bundle.id);
    final canAfford = coinsState.balance.total >= bundle.bundlePrice;
    return LBBlock(
      kind: isOwned ? LBBlockKind.outline : LBBlockKind.gold,
      selected: isOwned,
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: LBPixelIcon(LBIcon.gift, cell: 4, color: LB.gold),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bundle.localizedName(l10n).toUpperCase(),
                      style: LBText.button(p, color: LB.gold, size: 12.5),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      bundle.localizedDescription(l10n),
                      style: LBText.body(p, size: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final pu in bundle.powerUps)
                LBChip(label: pu.localizedName(l10n), height: 20),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (bundle.originalPrice > bundle.bundlePrice) ...[
                Text(
                  l10n.storeCoinsAmount(bundle.originalPrice.toInt()),
                  style: LBText.body(p, color: p.inkDim, size: 11).copyWith(
                    decoration: TextDecoration.lineThrough,
                    decorationColor: p.inkDim,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Text(
                  l10n.storeCoinsAmount(bundle.bundlePrice.toInt()),
                  style: LBText.value(p, color: LB.gold, size: 15),
                ),
              ),
              const Spacer(),
              StoreActionBlock(
                label: isOwned
                    ? l10n.storePillOwned
                    : canAfford
                    ? l10n.storeBuyUpper
                    : l10n.storeNeedCoins,
                kind: isOwned
                    ? LBBlockKind.muted
                    : canAfford
                    ? LBBlockKind.goldFill
                    : LBBlockKind.muted,
                feedback: false,
                onTap: isOwned
                    ? null
                    : () => _purchaseCoinBundle(bundle, canAfford),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseCoinBundle(PowerUpBundle bundle, bool canAfford) async {
    final l10n = AppLocalizations.of(context)!;
    if (!await _ensurePurchasable()) return;
    if (!mounted) return;
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (!canAfford) {
      scaffoldMessenger.showSnackBar(
        arcadeSnackBar(
          context,
          message: l10n.storeInsufficientCoins,
          tone: ArcadeSnackTone.error,
        ),
      );
      return;
    }
    // Server-authoritative purchase. Backend looks up the bundle in
    // ProductCatalog.PowerUpBundles, atomically debits coins, and increments
    // PowerUpInventory. We rely on the server response — no local coin spend.
    final coinsCubit = context.read<CoinsCubit>();
    final powerUpCubit = context.read<PowerUpCubit>();
    final newBalance = await powerUpCubit.purchaseBundleWithCoins(bundle.id);
    if (!mounted) return;
    if (newBalance == null) {
      scaffoldMessenger.showSnackBar(
        arcadeSnackBar(
          context,
          message: l10n.storePurchaseFailedRetry,
          tone: ArcadeSnackTone.error,
        ),
      );
      return;
    }
    // Mark the bundle owned locally so the UI swaps to the "owned" state;
    // server doesn't track set-membership for power-up bundles (it tracks
    // consumable counts in PowerUpInventory), so we keep this flag client-side.
    await context.read<PremiumCubit>().unlockBundle(bundle.id);
    await coinsCubit.setServerBalance(newBalance);
    if (!mounted) return;
    scaffoldMessenger.showSnackBar(
      arcadeSnackBar(
        context,
        message: l10n.storeBundleUnlocked(bundle.localizedName(l10n)),
        tone: ArcadeSnackTone.success,
      ),
    );
  }
}

// =============================================================================
// Helpers
// =============================================================================

class _PowerUpCatalogItem {
  final String type;
  final String name;
  final String description;
  final LBIcon icon;
  final int coinCost;
  const _PowerUpCatalogItem({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.coinCost,
  });
}
