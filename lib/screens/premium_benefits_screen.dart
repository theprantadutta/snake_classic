import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/store/store_parts.dart';
import 'package:snake_classic/widgets/lb_screens/store/store_pro_parts.dart';
import 'package:snake_classic/widgets/subscription_legal_footer.dart';

/// The dedicated Pro screen, on the Living Board and in step with the
/// store's PRO tab (same card, perks, plan blocks and GO PRO button). The
/// purchase, plan-switch and manage-subscription flows are unchanged.
class PremiumBenefitsScreen extends StatefulWidget {
  const PremiumBenefitsScreen({super.key});

  @override
  State<PremiumBenefitsScreen> createState() => _PremiumBenefitsScreenState();
}

class _PremiumBenefitsScreenState extends State<PremiumBenefitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isYearly = true;

  /// True while a plan-change flow is being handed to the store.
  bool _switchingPlan = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // The purchase stream is silent until something happens, so a subscriber
    // arriving on a cold start has no plan recorded yet and would be shown
    // the paywall. Ask the store what they actually own.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.read<PremiumCubit>().refreshActivePlan();
    });
  }

  @override
  void dispose() {
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
            final theme = themeState.currentTheme;
            final g = context.lbGutter;

            return LBScaffold(
              title: l10n.lbPro,
              subtitle: premiumState.hasPremium
                  ? l10n.lbProActiveLine
                  : l10n.lbStoreSubPro,
              banner: false,
              onBack: () => context.pop(),
              // Fills the viewport so the Pro card (the Expanded child) takes
              // up spare height on tall phones; scrolls on short ones.
              body: StoreFillScroll(
                padding: EdgeInsets.fromLTRB(
                  g,
                  context.lbCell * .9,
                  g,
                  context.lbCell * .75,
                ),
                children: [
                  // Three audiences, three screens. A paying subscriber gets
                  // their plan and a way to change it; a promo holder gets Pro
                  // status plus the plans, because they have something to
                  // convert to; everyone else gets the paywall.
                  if (premiumState.hasPaidSubscription) ...[
                    _buildPremiumActiveCard(theme, premiumState),
                    const SizedBox(height: 4),
                    _buildPlanSwitchCard(theme, premiumState),
                    const SizedBox(height: 4),
                    _buildManageRow(theme),
                    const SizedBox(height: 14),
                    LBSectionLabel(l10n.pbAllUnlocked),
                    Expanded(child: _buildFeaturesList(theme)),
                  ] else if (premiumState.hasPremium) ...[
                    // Pro via promo — no plan to switch, but every reason to
                    // show what subscribing would keep.
                    _buildPremiumActiveCard(theme, premiumState),
                    const SizedBox(height: 14),
                    LBSectionLabel(l10n.pbAllUnlocked),
                    Expanded(child: _buildFeaturesList(theme)),
                    const SizedBox(height: 14),
                    _buildPricingCards(theme),
                  ] else ...[
                    Expanded(child: _buildFeaturesList(theme)),
                    _buildPricingCards(theme),
                  ],
                  const SizedBox(height: 12),
                  StoreFooter(onRestore: () => lbRestorePurchases(context)),
                ],
              ),
              // A paying subscriber has nothing to buy, so no CTA bar. A
              // promo holder still does — theirs is the conversion.
              bottom: premiumState.hasPaidSubscription
                  ? null
                  : _buildBottomButton(theme, isPromo: premiumState.isOnPromo),
            );
          },
        );
      },
    );
  }

  /// Status block for anyone who already has Pro.
  ///
  /// Names the actual plan and its renewal date rather than a generic
  /// "you're premium" — a subscriber opening this screen is usually here to
  /// check exactly those two things, or to change them.
  Widget _buildPremiumActiveCard(GameTheme theme, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    final isPromo = premiumState.isOnPromo;
    final planLabel = switch (premiumState.plan) {
      PremiumPlan.monthly => l10n.pbPlanMonthly,
      PremiumPlan.yearly => l10n.pbPlanYearly,
      PremiumPlan.none => null,
    };
    final expiry = isPromo
        ? premiumState.promoExpiresAt
        : premiumState.subscriptionExpiry;
    return StoreProActiveBlock(
      title: l10n.lbProActive,
      // The plan chip only appears for a paid subscription. A promo holder
      // has Pro but no plan, and inventing one here would make the switch
      // card below look like it applies to them.
      chip: planLabel != null
          ? LBChip(
              label: '${l10n.pbYourPlan}  ·  $planLabel',
              kind: LBChipKind.gold,
            )
          : null,
      line: expiry != null
          ? l10n.pbRenewsOn(context.formatDate(expiry))
          : l10n.pbActiveSub,
    );
  }

  /// The other billing period, with the money consequence stated up front.
  ///
  /// Play bills an upgrade and a downgrade very differently, and the user
  /// cannot see which they are getting from the button alone — so the card
  /// says whether anything is charged today before they tap.
  Widget _buildPlanSwitchCard(GameTheme theme, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final target = premiumState.switchTarget;
    if (target == null) return const SizedBox.shrink();

    final toYearly = target == PremiumPlan.yearly;
    final targetProductId = toYearly
        ? ProductIds.snakeClassicProYearly
        : ProductIds.snakeClassicProMonthly;
    final price = PurchaseService().getStorePriceOrDefault(
      targetProductId,
      toYearly ? 39.99 : 4.99,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
    final period = toYearly ? l10n.storePerYear : l10n.storePerMonth;
    final accent = toYearly ? LB.gold : p.head;
    final kind = toYearly ? LBBlockKind.gold : LBBlockKind.outline;

    return LBBlock(
      kind: kind,
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LBPixelIcon(LBIcon.chart, cell: 4, color: accent),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  (toYearly ? l10n.pbSwitchToYearly : l10n.pbSwitchToMonthly)
                      .toUpperCase(),
                  style: LBText.button(p, color: accent, size: 13),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$price$period',
                style: LBText.value(p, color: p.ink, size: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            toYearly ? l10n.pbSwitchToYearlyBlurb : l10n.pbSwitchToMonthlyBlurb,
            style: LBText.body(p, size: 11.5),
          ),
          const SizedBox(height: 12),
          StoreActionBlock(
            label: toYearly ? l10n.pbSwitchToYearly : l10n.pbSwitchToMonthly,
            kind: kind,
            busy: _switchingPlan,
            feedback: false,
            onTap: () => _switchPlan(target),
          ),
        ],
      ),
    );
  }

  /// Cancelling and payment methods live in the store, not here — both Play
  /// and the App Store require that, so this is a signpost rather than a
  /// control we could implement ourselves.
  Widget _buildManageRow(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    return LBRow(
      title: l10n.pbManageSubscription,
      subtitle: l10n.pbManageBlurb,
      leading: LBPixelIcon(LBIcon.gear, cell: 4, color: p.lime),
      trailing: LBPixelIcon(LBIcon.next, cell: 3, color: p.inkMuted),
      onTap: () async {
        try {
          await context.read<PremiumCubit>().openManageSubscription();
        } catch (_) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            arcadeSnackBar(
              context,
              message: l10n.pbNotAvailable,
              tone: ArcadeSnackTone.error,
            ),
          );
        }
      },
    );
  }

  /// Launch the plan change. The store sheet is the confirmation step, so
  /// there is no extra dialog in front of it; the card above already stated
  /// what the switch costs.
  Future<void> _switchPlan(PremiumPlan target) async {
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final cubit = context.read<PremiumCubit>();
    final productId = target == PremiumPlan.yearly
        ? ProductIds.snakeClassicProYearly
        : ProductIds.snakeClassicProMonthly;

    setState(() => _switchingPlan = true);
    try {
      final launched = await cubit.switchPlan(productId);
      if (!mounted) return;
      if (!launched) {
        messenger.showSnackBar(
          arcadeSnackBar(
            context,
            message: l10n.pbNotAvailable,
            tone: ArcadeSnackTone.error,
          ),
        );
        return;
      }
      // A downgrade never produces a visible entitlement change — it is
      // scheduled for the end of the paid period — so say so here rather
      // than leaving the user wondering whether the tap did anything.
      messenger.showSnackBar(
        arcadeSnackBar(
          context,
          message: target == PremiumPlan.yearly
              ? l10n.pbSwitchedToYearly
              : l10n.pbSwitchedToMonthly,
          tone: ArcadeSnackTone.success,
        ),
      );
    } finally {
      if (mounted) setState(() => _switchingPlan = false);
    }
  }

  /// MONTHLY / YEARLY blocks. The selected one is what the bottom button
  /// subscribes to.
  Widget _buildPricingCards(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    // Each block shows its own product's store price and the trial the store
    // reports for that product — the two plans have different trial lengths.
    final monthlyTrial = PurchaseService().getFreeTrialDays(
      ProductIds.snakeClassicProMonthly,
    );
    final yearlyTrial = PurchaseService().getFreeTrialDays(
      ProductIds.snakeClassicProYearly,
    );
    return StorePlanRow(
      monthly: StorePlanBlock(
        label: l10n.lbMonthly,
        price: PurchaseService().getStorePriceOrDefault(
          ProductIds.snakeClassicProMonthly,
          4.99,
          localeTag: localeTag,
        ),
        line: l10n.lbPerMonth,
        selected: !_isYearly,
        trialLabel: monthlyTrial != null
            ? l10n.storeFreeTrialBadge(monthlyTrial)
            : null,
        onTap: () => setState(() => _isYearly = false),
      ),
      yearly: StorePlanBlock(
        label: l10n.lbYearly,
        price: PurchaseService().getStorePriceOrDefault(
          ProductIds.snakeClassicProYearly,
          39.99,
          localeTag: localeTag,
        ),
        line: l10n.lbPerYearBestValue,
        selected: _isYearly,
        trialLabel: yearlyTrial != null
            ? l10n.storeFreeTrialBadge(yearlyTrial)
            : null,
        onTap: () => setState(() => _isYearly = true),
      ),
    );
  }

  /// The Pro card: the same perks the store's PRO tab lists, plus the extra
  /// in-game perks. Same rows for subscribers and buyers — a subscriber
  /// should still be able to see what their money buys.
  ///
  /// Honest list — every entry maps to an entitlement Pro actually grants.
  /// Board sizes are not here (every board is free for everyone) and neither
  /// is the premium power-up bundle (those power-ups don't work in play yet).
  /// Built for a bounded height ([Expanded]): the perks spread over it.
  Widget _buildFeaturesList(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return StoreProCard(
      perks: lbProPerks(l10n),
      expand: true,
      extra: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          LBSectionLabel(l10n.lbProAlsoIncluded),
          // In-game spawn boosts implemented in food.dart
          // (Food.generateRandom isPremium param) and game_cubit.dart
          // (_trySpawnPowerUp). Backed by the snapshot of
          // PremiumCubit.hasPremium at game start.
          StorePerkLine(l10n.pbFeatLucky, detail: l10n.pbFeatLuckyDesc),
          StorePerkLine(l10n.pbFeatPowerUps, detail: l10n.pbFeatPowerUpsDesc),
          StorePerkLine(
            l10n.pbFeatTournament,
            detail: l10n.pbFeatTournamentDesc,
          ),
        ],
      ),
    );
  }

  /// [isPromo] is kept for the call site: a promo holder is keeping
  /// something they already have, and the same button converts them.
  Widget _buildBottomButton(GameTheme theme, {bool isPromo = false}) {
    final l10n = AppLocalizations.of(context)!;
    final g = context.lbGutter;
    final productId = _isYearly
        ? ProductIds.snakeClassicProYearly
        : ProductIds.snakeClassicProMonthly;
    final trialDays = PurchaseService().getFreeTrialDays(productId);

    return Padding(
      padding: EdgeInsets.fromLTRB(g, 6, g, 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // GO PRO; "Start free trial" when nothing is charged for another
          // few days. The plan blocks above carry the store price.
          StoreGoProButton(
            trialLabel: trialDays != null ? l10n.storeStartFreeTrial : null,
            onTap: _subscribe,
          ),
          const SizedBox(height: 6),
          SubscriptionLegalFooter(theme: theme),
        ],
      ),
    );
  }

  /// Real subscription purchase — opens the Google Play sheet.
  void _subscribe() {
    final purchaseService = PurchaseService();
    final productId = _isYearly
        ? ProductIds.snakeClassicProYearly
        : ProductIds.snakeClassicProMonthly;
    final product = purchaseService.getProduct(productId);

    if (product != null) {
      purchaseService.buyProduct(product);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        arcadeSnackBar(
          context,
          message: AppLocalizations.of(context)!.pbNotAvailable,
          tone: ArcadeSnackTone.error,
        ),
      );
    }
  }
}
