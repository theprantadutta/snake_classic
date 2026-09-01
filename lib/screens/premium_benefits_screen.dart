import 'package:flutter/material.dart';
import 'package:snake_classic/utils/contrast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/formatting.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/subscription_legal_footer.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';

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
    return BlocBuilder<PremiumCubit, PremiumState>(
      builder: (context, premiumState) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            final theme = themeState.currentTheme;

            return Scaffold(
              extendBodyBehindAppBar: true,
              appBar: AppBar(
                title: Text(
                  AppLocalizations.of(context)!.settingsProTitle,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back, color: theme.primaryColor),
                  onPressed: () => context.pop(),
                ),
              ),
              body: AppBackground(
                theme: theme,
                child: Column(
                  children: [
                    // Add top padding to account for AppBar
                    SizedBox(
                      height:
                          MediaQuery.of(context).padding.top + kToolbarHeight,
                    ),

                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // Three audiences, three screens. A paying
                            // subscriber gets their plan and a way to change
                            // it; a promo holder gets Pro status plus the
                            // plans, because they have something to convert
                            // to; everyone else gets the paywall.
                            if (premiumState.hasPaidSubscription) ...[
                              _buildPremiumActiveCard(theme, premiumState),
                              const SizedBox(height: 16),
                              _buildPlanSwitchCard(theme, premiumState),
                              const SizedBox(height: 16),
                              _buildManageRow(theme),
                              const SizedBox(height: 20),
                              _buildFeaturesList(theme, unlocked: true),
                            ] else if (premiumState.hasPremium) ...[
                              // Pro via promo — no plan to switch, but every
                              // reason to show what subscribing would keep.
                              _buildPremiumActiveCard(theme, premiumState),
                              const SizedBox(height: 20),
                              _buildPricingToggle(theme),
                              const SizedBox(height: 16),
                              _buildPricingCards(theme),
                              const SizedBox(height: 20),
                              _buildFeaturesList(theme, unlocked: true),
                            ] else ...[
                              _buildPremiumHeaderCard(theme),
                              const SizedBox(height: 20),
                              _buildPricingToggle(theme),
                              const SizedBox(height: 16),
                              _buildPricingCards(theme),
                              const SizedBox(height: 20),
                              _buildFeaturesList(theme),
                              const SizedBox(height: 8),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // A paying subscriber has nothing to buy, so no CTA bar. A
              // promo holder still does — theirs is the conversion.
              bottomNavigationBar: premiumState.hasPaidSubscription
                  ? null
                  : _buildBottomButton(theme, isPromo: premiumState.isOnPromo),
            );
          },
        );
      },
    );
  }

  /// Status card for anyone who already has Pro.
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
    final expiry =
        isPromo ? premiumState.promoExpiresAt : premiumState.subscriptionExpiry;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.withValues(alpha: 0.15),
            Colors.teal.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: HudCorners(
        color: kRewardGold,
        inset: 9,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.verified, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.pbActive,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            // The plan chip only appears for a paid subscription. A promo
            // holder has Pro but no plan, and inventing one here would make
            // the switch card below look like it applies to them.
            if (planLabel != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  '${l10n.pbYourPlan}  \u00b7  $planLabel',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: context.letterSpacing(0.5),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              expiry != null
                  ? l10n.pbRenewsOn(context.formatDate(expiry))
                  : l10n.pbActiveSub,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.7),
                fontSize: 15,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// The other billing period, with the money consequence stated up front.
  ///
  /// Play bills an upgrade and a downgrade very differently, and the user
  /// cannot see which they are getting from the button alone — so the card
  /// says whether anything is charged today before they tap.
  Widget _buildPlanSwitchCard(GameTheme theme, PremiumState premiumState) {
    final l10n = AppLocalizations.of(context)!;
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
    final accent = toYearly ? kRewardGold : theme.accentColor;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accent.withValues(alpha: 0.35), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                toYearly ? Icons.trending_up : Icons.trending_down,
                color: accent,
                size: context.scaled(22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  toYearly ? l10n.pbSwitchToYearly : l10n.pbSwitchToMonthly,
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '$price$period',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            toYearly
                ? l10n.pbSwitchToYearlyBlurb
                : l10n.pbSwitchToMonthlyBlurb,
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.72),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: context.scaled(46),
            child: ElevatedButton(
              onPressed: _switchingPlan ? null : () => _switchPlan(target),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: inkOn(accent),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _switchingPlan
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation(inkOn(accent)),
                      ),
                    )
                  : Text(
                      toYearly
                          ? l10n.pbSwitchToYearly
                          : l10n.pbSwitchToMonthly,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
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
    return InkWell(
      borderRadius: BorderRadius.circular(14),
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
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.22),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.settings_outlined,
              color: theme.accentColor.withValues(alpha: 0.8),
              size: context.scaled(20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.pbManageSubscription,
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.pbManageBlurb,
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.open_in_new,
              color: theme.accentColor.withValues(alpha: 0.5),
              size: context.scaled(18),
            ),
          ],
        ),
      ),
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

  Widget _buildPremiumHeaderCard(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400.withValues(alpha: 0.15),
            Colors.indigo.shade400.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purple.shade400.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade400.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: HudCorners(
        color: kRewardGold,
        inset: 9,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.indigo.shade400],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.shade400.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.diamond, color: Colors.white, size: 32),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.settingsProTitle,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.pbHeaderSub,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingToggle(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleOption(l10n.storeMonthly, false, theme)),
          Expanded(child: _buildToggleOption(l10n.storeYearly, true, theme)),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, bool isYearly, GameTheme theme) {
    final isSelected = _isYearly == isYearly;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isYearly = isYearly;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.accentColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: theme.accentColor.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected
                ? theme.accentColor
                : theme.accentColor.withValues(alpha: 0.6),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCards(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      children: [
        _buildPricingCard(
          title: l10n.pbMonthlyPlan,
          price: PurchaseService().getStorePriceOrDefault(
            ProductIds.snakeClassicProMonthly,
            4.99,
            localeTag: Localizations.localeOf(context).toLanguageTag(),
          ),
          period: l10n.storePerMonth,
          trialDays: PurchaseService().getFreeTrialDays(
            ProductIds.snakeClassicProMonthly,
          ),
          badge: null,
          accentColor: Colors.blue,
          isPopular: false,
          theme: theme,
        ),
        const SizedBox(height: 12),
        _buildPricingCard(
          title: l10n.pbYearlyPlan,
          price: _isYearly
              ? PurchaseService().getStorePriceOrDefault(
                  ProductIds.snakeClassicProYearly,
                  39.99,
                  localeTag: Localizations.localeOf(context).toLanguageTag(),
                )
              : PurchaseService().getStorePriceOrDefault(
                  ProductIds.snakeClassicProMonthly,
                  4.99,
                  localeTag: Localizations.localeOf(context).toLanguageTag(),
                ),
          period: _isYearly ? l10n.storePerYear : l10n.storePerMonth,
          // The card shows the monthly product when the toggle is off, so the
          // trial has to follow the product actually on display — the two
          // plans have different trial lengths.
          trialDays: PurchaseService().getFreeTrialDays(
            _isYearly
                ? ProductIds.snakeClassicProYearly
                : ProductIds.snakeClassicProMonthly,
          ),
          badge: _isYearly ? l10n.pbSave33 : null,
          accentColor: Colors.green,
          isPopular: _isYearly,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String price,
    required String period,
    String? badge,
    required Color accentColor,
    required bool isPopular,
    required GameTheme theme,

    /// Free-trial length the store reports for this plan, or null for none.
    int? trialDays,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accentColor.withValues(alpha: 0.15),
            accentColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: isPopular ? 0.4 : 0.3),
          width: isPopular ? 2 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: HudCorners(
        color: kRewardGold,
        inset: 9,
        child: Column(
          children: [
            if (isPopular)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      shadeFill(Colors.amber, 0.86),
                      shadeFill(Colors.orange, 0.78),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  AppLocalizations.of(context)!.pbMostPopular,
                  style: TextStyle(
                    color: inkOn(
                      shadeFill(Colors.amber, 0.86),
                      shadeFill(Colors.orange, 0.78),
                    ),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (isPopular) const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          badge,
                          style: TextStyle(
                            color: theme.accentColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      period,
                      style: TextStyle(
                        color: accentColor.withValues(alpha: 0.7),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (trialDays != null) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kRewardGold.withValues(alpha: 0.16),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: kRewardGold.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_clock_rounded,
                        size: 14,
                        color: kRewardGold,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          AppLocalizations.of(context)!
                              .storeFreeTrialBadge(trialDays),
                          style: TextStyle(
                            color: kRewardGold,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// [unlocked] flips the heading from a sales pitch to a statement of
  /// what the user already owns. Same rows either way — a subscriber
  /// should still be able to see what their money buys.
  Widget _buildFeaturesList(GameTheme theme, {bool unlocked = false}) {
    final l10n = AppLocalizations.of(context)!;
    // Honest list — every entry maps to an entitlement the server actually
    // grants on Pro verify (VerifyPurchaseCommandHandler). The previous
    // 'Exclusive Game Modes' line was a false promise (modes are uniformly
    // free per project rules) and 'Premium Power-ups' / 'VIP Tournaments'
    // were unimplemented — those are now real recurring bundles.
    final features = [
      _FeatureItem(
        Icons.favorite,
        l10n.pbFeatExtraLife,
        l10n.pbFeatExtraLifeDesc,
        highlighted: true,
      ),
      _FeatureItem(Icons.block, l10n.pbFeatNoAds, l10n.pbFeatNoAdsDesc),
      _FeatureItem(Icons.palette, l10n.pbFeatThemes, l10n.pbFeatThemesDesc),
      _FeatureItem(Icons.pets, l10n.pbFeatSkins, l10n.pbFeatSkinsDesc),
      _FeatureItem(Icons.gradient, l10n.pbFeatTrails, l10n.pbFeatTrailsDesc),
      _FeatureItem(Icons.grid_on, l10n.pbFeatBoards, l10n.pbFeatBoardsDesc),
      _FeatureItem(
        Icons.monetization_on,
        l10n.pbFeatCoins,
        l10n.pbFeatCoinsDesc,
      ),
      // In-game spawn boosts implemented in food.dart (Food.generateRandom
      // isPremium param) and game_cubit.dart (_trySpawnPowerUp). Backed by
      // the snapshot of PremiumCubit.hasPremium at game start.
      _FeatureItem(Icons.auto_awesome, l10n.pbFeatLucky, l10n.pbFeatLuckyDesc),
      _FeatureItem(Icons.bolt, l10n.pbFeatPowerUps, l10n.pbFeatPowerUpsDesc),
      _FeatureItem(Icons.flash_on, l10n.pbFeatBundle, l10n.pbFeatBundleDesc),
      _FeatureItem(
        Icons.emoji_events,
        l10n.pbFeatTournament,
        l10n.pbFeatTournamentDesc,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (unlocked) ...[
              Icon(
                Icons.check_circle,
                color: theme.accentColor,
                size: context.scaled(20),
              ),
              const SizedBox(width: 8),
            ],
            Expanded(
              child: Text(
                unlocked ? l10n.pbAllUnlocked : l10n.pbIncludes,
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...features.map((feature) => _buildFeatureCard(feature, theme)),
      ],
    );
  }

  Widget _buildFeatureCard(_FeatureItem feature, GameTheme theme) {
    final hl = feature.highlighted;
    final accent = hl ? Colors.amber : theme.accentColor;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: hl
            ? Colors.amber.withValues(alpha: 0.12)
            : theme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hl
              ? Colors.amber.withValues(alpha: 0.6)
              : theme.accentColor.withValues(alpha: 0.2),
          width: hl ? 2 : 1,
        ),
        boxShadow: hl
            ? [
                BoxShadow(
                  color: Colors.amber.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: HudCorners(
        color: theme.accentColor,
        inset: 8,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: hl ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(feature.icon, color: accent, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          feature.title,
                          style: TextStyle(
                            color: accent,
                            fontSize: hl ? 17 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (hl) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                shadeFill(Colors.amber, 0.86),
                                shadeFill(Colors.orange, 0.78),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.pbProPerk,
                            style: TextStyle(
                              color: inkOn(
                                shadeFill(Colors.amber, 0.86),
                                shadeFill(Colors.orange, 0.78),
                              ),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: context.letterSpacing(0.5),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    feature.description,
                    style: TextStyle(
                      color: hl
                          ? Colors.amber.withValues(alpha: 0.85)
                          : theme.accentColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// [isPromo] retitles the CTA: a promo holder is not starting a trial,
  /// they are keeping something they already have.
  Widget _buildBottomButton(GameTheme theme, {bool isPromo = false}) {
    final l10n = AppLocalizations.of(context)!;
    final productId = _isYearly
        ? ProductIds.snakeClassicProYearly
        : ProductIds.snakeClassicProMonthly;
    final price = PurchaseService().getStorePriceOrDefault(
      productId,
      _isYearly ? 39.99 : 4.99,
      localeTag: Localizations.localeOf(context).toLanguageTag(),
    );
    final period = _isYearly ? l10n.storePerYear : l10n.storePerMonth;
    final trialDays = PurchaseService().getFreeTrialDays(productId);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.9),
        border: Border(
          top: BorderSide(
            color: theme.accentColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary CTA — honest about payment
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _subscribe,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 0,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.purple.shade400, Colors.indigo.shade400],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.shade400.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    // "Subscribe — $4.99/month" misstates what the button does
                    // when nothing is charged for another few days.
                    trialDays != null
                        ? l10n.storeStartFreeTrial
                        : l10n.pbSubscribeCta(period, price),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.pbReassurance,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            SubscriptionLegalFooter(theme: theme),
          ],
        ),
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

class _FeatureItem {
  final IconData icon;
  final String title;
  final String description;

  /// Emphasize this row (amber border/glow + "PRO PERK" badge). Used to make
  /// the always-free revive stand out from the rest of the list.
  final bool highlighted;

  _FeatureItem(
    this.icon,
    this.title,
    this.description, {
    this.highlighted = false,
  });
}
