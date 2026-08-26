import 'package:flutter/material.dart';
import 'package:snake_classic/utils/contrast.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/subscription_legal_footer.dart';

class PremiumBenefitsScreen extends StatefulWidget {
  const PremiumBenefitsScreen({super.key});

  @override
  State<PremiumBenefitsScreen> createState() => _PremiumBenefitsScreenState();
}

class _PremiumBenefitsScreenState extends State<PremiumBenefitsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isYearly = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
                  style:
                      const TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
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
                            if (premiumState.hasPremium) ...[
                              _buildPremiumActiveCard(theme),
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
              bottomNavigationBar: premiumState.hasPremium
                  ? null
                  : _buildBottomButton(theme),
            );
          },
        );
      },
    );
  }

  Widget _buildPremiumActiveCard(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
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
          const SizedBox(height: 8),
          Text(
            l10n.pbActiveSub,
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      )),
    );
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
      )),
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
              ProductIds.snakeClassicProMonthly, 4.99,
              localeTag: Localizations.localeOf(context).toLanguageTag()),
          period: l10n.storePerMonth,
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
                  ProductIds.snakeClassicProYearly, 39.99,
                  localeTag: Localizations.localeOf(context).toLanguageTag())
              : PurchaseService().getStorePriceOrDefault(
                  ProductIds.snakeClassicProMonthly, 4.99,
                  localeTag: Localizations.localeOf(context).toLanguageTag()),
          period: _isYearly ? l10n.storePerYear : l10n.storePerMonth,
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
        ],
      )),
    );
  }

  Widget _buildFeaturesList(GameTheme theme) {
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
      _FeatureItem(
        Icons.block,
        l10n.pbFeatNoAds,
        l10n.pbFeatNoAdsDesc,
      ),
      _FeatureItem(
        Icons.palette,
        l10n.pbFeatThemes,
        l10n.pbFeatThemesDesc,
      ),
      _FeatureItem(
        Icons.pets,
        l10n.pbFeatSkins,
        l10n.pbFeatSkinsDesc,
      ),
      _FeatureItem(
        Icons.gradient,
        l10n.pbFeatTrails,
        l10n.pbFeatTrailsDesc,
      ),
      _FeatureItem(
        Icons.grid_on,
        l10n.pbFeatBoards,
        l10n.pbFeatBoardsDesc,
      ),
      _FeatureItem(
        Icons.monetization_on,
        l10n.pbFeatCoins,
        l10n.pbFeatCoinsDesc,
      ),
      // In-game spawn boosts implemented in food.dart (Food.generateRandom
      // isPremium param) and game_cubit.dart (_trySpawnPowerUp). Backed by
      // the snapshot of PremiumCubit.hasPremium at game start.
      _FeatureItem(
        Icons.auto_awesome,
        l10n.pbFeatLucky,
        l10n.pbFeatLuckyDesc,
      ),
      _FeatureItem(
        Icons.bolt,
        l10n.pbFeatPowerUps,
        l10n.pbFeatPowerUpsDesc,
      ),
      _FeatureItem(
        Icons.flash_on,
        l10n.pbFeatBundle,
        l10n.pbFeatBundleDesc,
      ),
      _FeatureItem(
        Icons.emoji_events,
        l10n.pbFeatTournament,
        l10n.pbFeatTournamentDesc,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.pbIncludes,
          style: TextStyle(
            color: theme.accentColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
                            horizontal: 8, vertical: 2),
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
      )),
    );
  }

  Widget _buildBottomButton(GameTheme theme) {
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
                    l10n.pbSubscribeCta(period, price),
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
        SnackBar(
          content: Text(AppLocalizations.of(context)!.pbNotAvailable),
          backgroundColor: Colors.red,
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

  _FeatureItem(this.icon, this.title, this.description,
      {this.highlighted = false});
}
