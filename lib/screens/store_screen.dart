import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/models/premium_power_up.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/power_up/power_up_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/core/di/injection.dart';
import 'package:snake_classic/services/analytics/analytics_facade.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class StoreScreen extends StatefulWidget {
  final int initialTab;

  const StoreScreen({super.key, this.initialTab = 0});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Tracks productIds whose purchase was just initiated but whose ownership
  // hasn't reflected back from the backend yet. The card switches from
  // "BUY" to a "Verifying..." spinner during this window (typically 2-15s
  // for Play Store → webhook → entitlement → cubit). Auto-cleared once
  // the PremiumCubit reports the item as owned, or after a safety timeout
  // so the spinner never spins forever if a webhook is genuinely lost.
  final Set<String> _pendingProductIds = {};

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
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) return;
    getIt<AnalyticsFacade>().trackStoreTabViewed(_tabNames[_tabController.index]);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PremiumCubit, PremiumState>(
      builder: (context, premiumState) {
        return BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<CoinsCubit, CoinsState>(
              builder: (context, coinsState) {
                final theme = themeState.currentTheme;
                return Scaffold(
                  extendBodyBehindAppBar: true,
                  appBar: AppBar(
                    title: const Text(
                      'Snake Store',
                      style: TextStyle(
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
                        SizedBox(
                          height: MediaQuery.of(context).padding.top +
                              kToolbarHeight,
                        ),
                        _buildCoinsHeader(theme, coinsState),
                        TabBar(
                          controller: _tabController,
                          indicatorColor: theme.accentColor,
                          labelColor: theme.accentColor,
                          unselectedLabelColor:
                              theme.accentColor.withValues(alpha: 0.6),
                          isScrollable: true,
                          tabs: const [
                            Tab(text: 'Pro', icon: Icon(Icons.diamond, size: 16)),
                            Tab(
                              text: 'Coins',
                              icon: Icon(Icons.monetization_on, size: 16),
                            ),
                            Tab(
                              text: 'Themes',
                              icon: Icon(Icons.color_lens, size: 16),
                            ),
                            Tab(
                              text: 'Skins',
                              icon: Icon(Icons.pets, size: 16),
                            ),
                            Tab(
                              text: 'Trails',
                              icon: Icon(Icons.auto_awesome, size: 16),
                            ),
                            Tab(
                              text: 'Power-Ups',
                              icon: Icon(Icons.flash_on, size: 16),
                            ),
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
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // ===========================================================================
  // Coins header (top of every tab)
  // ===========================================================================

  Widget _buildCoinsHeader(GameTheme theme, CoinsState coinsState) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withValues(alpha: 0.15),
              Colors.orange.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.amber.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Snake Coins',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${coinsState.balance.total}',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (coinsState.hasPremiumBonus)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.shade400,
                      Colors.indigo.shade400,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${coinsState.earningMultiplier}x BONUS',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // PRO TAB
  // ===========================================================================

  Widget _buildProTab(GameTheme theme, PremiumState premiumState) {
    if (premiumState.hasPremium) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildProActiveBanner(theme, premiumState),
            const SizedBox(height: 16),
            _buildProFeatureGrid(theme),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildProHero(theme),
          const SizedBox(height: 20),
          Text(
            'Choose your plan',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildProPlanCard(
                  theme: theme,
                  title: 'Monthly',
                  productId: ProductIds.snakeClassicProMonthly,
                  fallbackPrice: 4.99,
                  cadence: '/month',
                  savingsLabel: null,
                  highlight: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProPlanCard(
                  theme: theme,
                  title: 'Yearly',
                  productId: ProductIds.snakeClassicProYearly,
                  fallbackPrice: 49.99,
                  cadence: '/year',
                  savingsLabel: 'Save 17%',
                  highlight: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            "What you get",
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildProFeatureGrid(theme),
        ],
      ),
    );
  }

  Widget _buildProHero(GameTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade400.withValues(alpha: 0.18),
            Colors.indigo.shade400.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.purple.shade400.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.shade400.withValues(alpha: 0.18),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.indigo.shade400],
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.diamond, color: Colors.white, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
            'Snake Classic Pro',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'All premium themes · large boards · 2× coins · ad-free',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProPlanCard({
    required GameTheme theme,
    required String title,
    required String productId,
    required double fallbackPrice,
    required String cadence,
    required String? savingsLabel,
    required bool highlight,
  }) {
    final price =
        PurchaseService().getStorePriceOrDefault(productId, fallbackPrice);
    final borderColor = highlight
        ? Colors.amber.withValues(alpha: 0.6)
        : theme.accentColor.withValues(alpha: 0.25);
    return GestureDetector(
      onTap: () => _purchaseSubscription(productId, '$title plan'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: highlight ? 2 : 1),
          boxShadow: highlight
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (savingsLabel != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      savingsLabel,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            Text(
              price,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              cadence,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    _purchaseSubscription(productId, '$title plan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: highlight
                      ? Colors.amber
                      : theme.primaryColor.withValues(alpha: 0.9),
                  foregroundColor:
                      highlight ? Colors.black : Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Subscribe',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProActiveBanner(GameTheme theme, PremiumState premiumState) {
    final expiry = premiumState.subscriptionExpiry;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.withValues(alpha: 0.18),
            Colors.teal.withValues(alpha: 0.10),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.35),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Colors.green, Colors.teal]),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.verified, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "You're Pro!",
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (expiry != null)
                  Text(
                    'Renews ${_formatDate(expiry)}',
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProFeatureGrid(GameTheme theme) {
    final features = const [
      (Icons.color_lens, 'All 6 premium themes'),
      (Icons.grid_4x4, 'Premium board sizes (35×35, 40×40, 50×50)'),
      (Icons.monetization_on, '2× coin earnings'),
      (Icons.block, 'Ad-free gameplay'),
      (Icons.flash_on, 'Power-up perks'),
      (Icons.leaderboard, 'VIP tournaments'),
    ];
    return Column(
      children: features
          .map(
            (f) => Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.accentColor.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                children: [
                  Icon(f.$1, color: theme.accentColor, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      f.$2,
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.check_circle,
                    color: Colors.green.withValues(alpha: 0.8),
                    size: 18,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _purchaseSubscription(String productId, String displayName) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    try {
      await PurchaseService().purchaseProduct(productId);
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Initiating $displayName purchase...'),
            backgroundColor: Colors.blue,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content:
                Text('Subscription not available. Please try again later.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ===========================================================================
  // COINS TAB
  // ===========================================================================

  Widget _buildCoinsTab(GameTheme theme, CoinsState coinsState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Buy Snake Coins',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...CoinPurchaseOption.availableOptions.map(
            (option) => _buildCoinPackCard(option, theme),
          ),
          const SizedBox(height: 24),
          Text(
            'Earn Free Coins',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildEarnMethodCard(
            'Play Games',
            '5 coins per game',
            Icons.games,
            theme,
          ),
          _buildEarnMethodCard(
            'Daily Login',
            '10-50 coins daily',
            Icons.calendar_today,
            theme,
          ),
          _buildEarnMethodCard(
            'Achievements',
            '25-100 coins',
            Icons.emoji_events,
            theme,
          ),
          _buildEarnMethodCard(
            'Tournaments',
            '100+ coins',
            Icons.leaderboard,
            theme,
          ),
        ],
      ),
    );
  }

  void _purchaseCoinPack(CoinPurchaseOption option, GameTheme theme) {
    final price = PurchaseService().getStorePriceOrDefault(
        ProductIds.withPrefix(option.id), option.price);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Buy ${option.name}'),
        content: Text('Purchase ${option.displayCoins} for $price?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final navigator = Navigator.of(dialogContext);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop();
              try {
                await PurchaseService()
                    .purchaseProduct(ProductIds.withPrefix(option.id));
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content:
                          Text('Initiating purchase for ${option.name}...'),
                      backgroundColor: theme.accentColor,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  scaffoldMessenger.showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Product not available. Please try again later.'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: Text('Buy - $price'),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinPackCard(CoinPurchaseOption option, GameTheme theme) {
    return GestureDetector(
      onTap: () => _purchaseCoinPack(option, theme),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.amber.withValues(alpha: 0.15),
              Colors.orange.withValues(alpha: 0.08),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: option.isPopular
                ? Colors.red.withValues(alpha: 0.4)
                : Colors.amber.withValues(alpha: 0.3),
            width: option.isPopular ? 2 : 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        option.name,
                        style: TextStyle(
                          color: theme.accentColor,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (option.isPopular) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'POPULAR',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    option.displayCoins,
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              PurchaseService().getStorePriceOrDefault(
                  ProductIds.withPrefix(option.id), option.price),
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarnMethodCard(
    String title,
    String reward,
    IconData icon,
    GameTheme theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: theme.accentColor, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            reward,
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // THEMES TAB
  // ===========================================================================

  Widget _buildThemesTab(GameTheme theme, PremiumState premiumState) {
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildThemesBundleCard(theme, premiumState),
          const SizedBox(height: 20),
          Text(
            'Premium themes',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: premiumThemes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) =>
                _buildThemeCard(premiumThemes[index], theme, premiumState),
          ),
          const SizedBox(height: 24),
          Text(
            'Free themes',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Always available — switch back any time.',
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.65),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: freeThemes.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.72,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) =>
                _buildThemeCard(freeThemes[index], theme, premiumState),
          ),
        ],
      ),
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
    // Cosmetic bundles (starter_pack etc.) — owned set uses bare ID.
    return premiumState.isBundleOwned(stripped);
  }

  Widget _buildThemesBundleCard(GameTheme theme, PremiumState premiumState) {
    final bundleOwned = premiumState.isBundleOwned('premium_themes_bundle');
    final isPending = _pendingProductIds.contains(ProductIds.themesBundle);
    final price = PurchaseService().getStorePriceOrDefault(
      ProductIds.themesBundle,
      7.99,
    );
    return GestureDetector(
      onTap: (bundleOwned || isPending)
          ? null
          : () => _purchaseThemeProduct(
                ProductIds.themesBundle,
                'All Themes Bundle',
              ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade400.withValues(alpha: 0.18),
              Colors.indigo.shade400.withValues(alpha: 0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.5),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade400, Colors.indigo.shade400],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child:
                  const Icon(Icons.card_giftcard, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'All Themes Bundle',
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'All 6 premium themes · save 33%',
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            _buildBundleStatusPill(
              isOwned: bundleOwned,
              isPending: isPending,
              priceLabel: price,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBundleStatusPill({
    required bool isOwned,
    required bool isPending,
    required String priceLabel,
  }) {
    if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 1.5,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 6),
            Text(
              'VERIFYING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: isOwned ? Colors.green : Colors.amber,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        isOwned ? 'OWNED' : priceLabel,
        style: TextStyle(
          color: isOwned ? Colors.white : Colors.black,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildThemeCard(
    GameTheme target,
    GameTheme currentTheme,
    PremiumState premiumState,
  ) {
    final isOwned = premiumState.isThemeUnlocked(target);
    final isActive = currentTheme == target;
    final productId = _productIdForTheme(target);
    final isPending =
        productId != null && _pendingProductIds.contains(productId);
    final price = productId == null
        ? 'FREE'
        : PurchaseService().getStorePriceOrDefault(productId, 1.99);
    return GestureDetector(
      onTap: isPending
          ? null
          : () {
              if (isOwned) {
                context.read<ThemeCubit>().setTheme(target);
              } else if (productId != null) {
                _purchaseThemeProduct(productId, target.name);
              }
            },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: currentTheme.accentColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isActive
                ? currentTheme.accentColor
                : currentTheme.accentColor.withValues(alpha: 0.2),
            width: isActive ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: _ThemePreview(theme: target),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              target.name,
              style: TextStyle(
                color: currentTheme.accentColor,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            _buildStatusPill(
              currentTheme: currentTheme,
              isActive: isActive,
              isOwned: isOwned,
              isPending: isPending,
              fallbackPriceLabel: price,
            ),
          ],
        ),
      ),
    );
  }

  /// The bottom-of-card pill that toggles between ACTIVE / APPLY / price /
  /// VERIFYING (with spinner). Centralized so the bundle card and theme
  /// cards stay visually consistent.
  Widget _buildStatusPill({
    required GameTheme currentTheme,
    required bool isActive,
    required bool isOwned,
    required bool isPending,
    required String fallbackPriceLabel,
  }) {
    final Color background;
    final Color foreground;
    Widget child;
    if (isPending) {
      background = Colors.blueGrey;
      foreground = Colors.white;
      child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
              valueColor: AlwaysStoppedAnimation<Color>(foreground),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'VERIFYING',
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      );
    } else if (isActive) {
      background = currentTheme.accentColor;
      foreground = currentTheme.backgroundColor;
      child = Text(
        'ACTIVE',
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
    } else if (isOwned) {
      background = Colors.green;
      foreground = Colors.white;
      child = Text(
        'APPLY',
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
    } else {
      background = Colors.amber;
      foreground = Colors.black;
      child = Text(
        fallbackPriceLabel,
        style: TextStyle(
          color: foreground,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(8),
      ),
      alignment: Alignment.center,
      child: child,
    );
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

  Future<void> _purchaseThemeProduct(String productId, String displayName) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = context.read<ThemeCubit>().state.currentTheme;
    final price = PurchaseService().getStorePriceOrDefault(productId, 1.99);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.color_lens, color: theme.accentColor),
            const SizedBox(width: 8),
            Text(displayName, style: TextStyle(color: theme.accentColor)),
          ],
        ),
        content: Text(
          'Unlock $displayName for $price?',
          style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Buy - $price'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await PurchaseService().purchaseProduct(productId);
      if (!mounted) return;
      _markPending(productId);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Verifying $displayName purchase…'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Theme not available. Please try again later.'),
            backgroundColor: Colors.red,
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

  Widget _buildSkinsTab(GameTheme theme, PremiumState premiumState) {
    _reconcilePendingPurchases(premiumState);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: SnakeSkinType.values.length,
      itemBuilder: (context, index) {
        final skin = SnakeSkinType.values[index];
        final isUnlocked = !skin.isPremium || premiumState.isSkinOwned(skin.id);
        final isSelected = premiumState.selectedSkinId == skin.id;
        final productId = ProductIds.skinStoreId(skin.id);
        return _buildCosmeticCard(
          title: skin.displayName,
          description: skin.description,
          icon: skin.icon,
          colors: skin.colors,
          price: skin.isPremium
              ? PurchaseService()
                  .getStorePriceOrDefault(productId, skin.price)
              : 'FREE',
          isUnlocked: isUnlocked,
          isSelected: isSelected,
          isPremium: skin.isPremium,
          isPending: _pendingProductIds.contains(productId),
          theme: theme,
          onTap: () {
            if (isUnlocked) {
              context.read<PremiumCubit>().selectSkin(skin.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${skin.displayName} equipped'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1),
                ),
              );
            } else {
              _purchaseCosmetic(
                productId: productId,
                displayName: skin.displayName,
                fallbackPrice: skin.price,
              );
            }
          },
        );
      },
    );
  }

  // ===========================================================================
  // TRAILS TAB
  // ===========================================================================

  Widget _buildTrailsTab(GameTheme theme, PremiumState premiumState) {
    _reconcilePendingPurchases(premiumState);
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.70,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: TrailEffectType.values.length,
      itemBuilder: (context, index) {
        final trail = TrailEffectType.values[index];
        final isUnlocked =
            !trail.isPremium || premiumState.isTrailOwned(trail.id);
        final isSelected = premiumState.selectedTrailId == trail.id;
        final productId = ProductIds.withPrefix(trail.id);
        return _buildCosmeticCard(
          title: trail.displayName,
          description: trail.description,
          icon: trail.icon,
          colors: trail.colors,
          price: trail.isPremium
              ? PurchaseService()
                  .getStorePriceOrDefault(productId, trail.price)
              : 'FREE',
          isUnlocked: isUnlocked,
          isSelected: isSelected,
          isPremium: trail.isPremium,
          isPending: _pendingProductIds.contains(productId),
          theme: theme,
          onTap: () {
            if (isUnlocked) {
              context.read<PremiumCubit>().selectTrail(trail.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${trail.displayName} equipped'),
                  backgroundColor: Colors.green,
                  duration: const Duration(seconds: 1),
                ),
              );
            } else {
              _purchaseCosmetic(
                productId: productId,
                displayName: trail.displayName,
                fallbackPrice: trail.price,
              );
            }
          },
        );
      },
    );
  }

  Widget _buildCosmeticCard({
    required String title,
    required String description,
    required String icon,
    required List<Color> colors,
    required String price,
    required bool isUnlocked,
    required bool isSelected,
    required bool isPremium,
    required bool isPending,
    required GameTheme theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: isPending ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? theme.accentColor
                : isUnlocked
                    ? Colors.green.withValues(alpha: 0.35)
                    : isPremium
                        ? Colors.purple.shade400.withValues(alpha: 0.35)
                        : theme.accentColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? (isSelected
                            ? theme.accentColor
                            : Colors.green.withValues(alpha: 0.18))
                        : Colors.purple.shade400.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    icon,
                    style: TextStyle(
                      fontSize: 28,
                      color: isUnlocked
                          ? (isSelected ? Colors.white : Colors.green)
                          : Colors.purple.shade400,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Flexible(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: theme.accentColor,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 2),
                Flexible(
                  child: Text(
                    description,
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.7),
                      fontSize: 10,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 8),
                if (colors.length > 1)
                  Container(
                    height: 5,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: colors),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                const SizedBox(height: 8),
                _buildCosmeticStatusPill(
                  theme: theme,
                  isSelected: isSelected,
                  isUnlocked: isUnlocked,
                  isPending: isPending,
                  priceLabel: price,
                ),
              ],
            ),
            if (!isUnlocked && isPremium)
              Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.lock,
                  color: Colors.purple.shade300,
                  size: 16,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCosmeticStatusPill({
    required GameTheme theme,
    required bool isSelected,
    required bool isUnlocked,
    required bool isPending,
    required String priceLabel,
  }) {
    if (isPending) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.blueGrey,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 9,
              height: 9,
              child: CircularProgressIndicator(
                strokeWidth: 1.3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 4),
            Text(
              'VERIFYING',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.accentColor
            : isUnlocked
                ? Colors.green
                : Colors.amber,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isSelected
            ? 'EQUIPPED'
            : isUnlocked
                ? 'EQUIP'
                : priceLabel,
        style: TextStyle(
          color: isSelected
              ? theme.backgroundColor
              : isUnlocked
                  ? Colors.white
                  : Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<void> _purchaseCosmetic({
    required String productId,
    required String displayName,
    required double fallbackPrice,
  }) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final theme = context.read<ThemeCubit>().state.currentTheme;
    final price =
        PurchaseService().getStorePriceOrDefault(productId, fallbackPrice);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: theme.accentColor),
            const SizedBox(width: 8),
            Text(displayName, style: TextStyle(color: theme.accentColor)),
          ],
        ),
        content: Text(
          'Unlock $displayName for $price?',
          style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Buy - $price'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await PurchaseService().purchaseProduct(productId);
      if (!mounted) return;
      _markPending(productId);
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Verifying $displayName purchase…'),
          backgroundColor: Colors.blue,
        ),
      );
    } catch (e) {
      if (mounted) {
        scaffoldMessenger.showSnackBar(
          const SnackBar(
            content: Text('Item not available. Please try again later.'),
            backgroundColor: Colors.red,
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

  Widget _buildPowerUpsTab(
    GameTheme theme,
    PremiumState premiumState,
    CoinsState coinsState,
  ) {
    // Power-up types use snake_case to match the JSON dictionary keys
    // returned by the backend (ASP.NET applies DictionaryKeyPolicy =
    // SnakeCaseLower to outgoing dicts). Mapping back to PowerUpType for
    // activation lives in the game cubit (next commit).
    final powerUps = const [
      _PowerUpCatalogItem(
        type: 'speed_boost',
        name: 'Speed Boost',
        description: 'Increases snake speed for 7 seconds.',
        icon: Icons.speed,
        coinCost: 50,
      ),
      _PowerUpCatalogItem(
        type: 'invincibility',
        name: 'Invincibility',
        description: 'Pass through walls and yourself for 6 seconds.',
        icon: Icons.shield,
        coinCost: 75,
      ),
      _PowerUpCatalogItem(
        type: 'score_multiplier',
        name: 'Score Multiplier',
        description: 'Double points for 10 seconds.',
        icon: Icons.star,
        coinCost: 60,
      ),
      _PowerUpCatalogItem(
        type: 'slow_motion',
        name: 'Slow Motion',
        description: 'Slows the game for precision (8 seconds).',
        icon: Icons.slow_motion_video,
        coinCost: 50,
      ),
    ];

    return BlocBuilder<PowerUpCubit, PowerUpState>(
      builder: (context, powerUpState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: theme.accentColor.withValues(alpha: 0.18),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: theme.accentColor, size: 18),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Buy with coins, then arm one from the home screen '
                        'loadout chip — it activates 5s into your next game.',
                        style: TextStyle(
                          color: theme.accentColor.withValues(alpha: 0.85),
                          fontSize: 12,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Power-Ups',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              ...powerUps.map(
                (p) => _buildPowerUpCatalogCard(p, theme, powerUpState),
              ),
              const SizedBox(height: 24),
              Text(
                'Power-Up Bundles',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Unlock multiple power-up types at a discount.',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.7),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
              ...PowerUpBundle.availableBundles.map(
                (bundle) => _buildPowerUpBundleCard(
                    bundle, theme, premiumState, coinsState),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPowerUpCatalogCard(
    _PowerUpCatalogItem item,
    GameTheme theme,
    PowerUpState powerUpState,
  ) {
    final owned = powerUpState.countFor(item.type);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: theme.accentColor, size: 22),
              ),
              if (owned > 0)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Text(
                      'x$owned',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item.description,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _purchasePowerUpWithCoins(item, theme),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor.withValues(alpha: 0.85),
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.monetization_on,
                    size: 14, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${item.coinCost}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _purchasePowerUpWithCoins(
      _PowerUpCatalogItem item, GameTheme theme) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final coinsCubit = context.read<CoinsCubit>();
    final powerUpCubit = context.read<PowerUpCubit>();
    final coinsBalance = coinsCubit.state.balance.total;
    if (coinsBalance < item.coinCost) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(item.icon, color: theme.accentColor),
            const SizedBox(width: 8),
            Text(item.name, style: TextStyle(color: theme.accentColor)),
          ],
        ),
        content: Text(
          'Buy 1 ${item.name} for ${item.coinCost} coins?',
          style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text('Buy - ${item.coinCost} coins'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    final newBalance =
        await powerUpCubit.purchaseWithCoins(item.type, item.coinCost);
    if (!mounted) return;
    if (newBalance == null) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Purchase failed. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    // Reflect the server-authoritative coin balance locally so the
    // CoinsCubit and any other UI stays in sync without an extra round-trip.
    await coinsCubit.setServerBalance(newBalance);
    scaffoldMessenger.showSnackBar(
      SnackBar(
        content: Text('${item.name} added to your loadout!'),
        backgroundColor: Colors.green,
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
    final isOwned = premiumState.isBundleOwned(bundle.id);
    final canAfford = coinsState.balance.total >= bundle.bundlePrice;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withValues(alpha: 0.14),
            Colors.indigo.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isOwned
              ? Colors.green.withValues(alpha: 0.4)
              : Colors.purple.withValues(alpha: 0.3),
          width: isOwned ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.purple, Colors.indigo],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(bundle.icon, style: const TextStyle(fontSize: 22)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bundle.name,
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      bundle.description,
                      style: TextStyle(
                        color: theme.accentColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
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
            children: bundle.powerUps
                .map(
                  (p) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.purple.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '${p.icon} ${p.displayName}',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              if (bundle.originalPrice > bundle.bundlePrice)
                Text(
                  '${bundle.originalPrice.toInt()} coins',
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.5),
                    fontSize: 12,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              const SizedBox(width: 8),
              Text(
                '${bundle.bundlePrice.toInt()} coins',
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: isOwned
                    ? null
                    : () => _purchaseCoinBundle(bundle, canAfford),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isOwned
                      ? Colors.green
                      : canAfford
                          ? theme.primaryColor
                          : Colors.grey.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(isOwned
                    ? 'OWNED'
                    : canAfford
                        ? 'BUY'
                        : 'NEED COINS'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseCoinBundle(PowerUpBundle bundle, bool canAfford) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    if (!canAfford) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Insufficient coins!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final success = await context.read<CoinsCubit>().spendCoins(
          bundle.bundlePrice.toInt(),
          CoinSpendingCategory.powerUps,
          itemName: bundle.name,
        );
    if (!mounted) return;
    if (success) {
      await context.read<PremiumCubit>().unlockBundle(bundle.id);
      if (!mounted) return;
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('${bundle.name} unlocked!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        const SnackBar(
          content: Text('Purchase failed. Try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

// =============================================================================
// Helpers
// =============================================================================

class _ThemePreview extends StatelessWidget {
  final GameTheme theme;
  const _ThemePreview({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.backgroundColor,
            theme.backgroundColor.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Faint grid hint
          Positioned.fill(
            child: CustomPaint(
              painter: _ThemePreviewPainter(theme: theme),
            ),
          ),
        ],
      ),
    );
  }
}

class _ThemePreviewPainter extends CustomPainter {
  final GameTheme theme;
  _ThemePreviewPainter({required this.theme});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = theme.accentColor.withValues(alpha: 0.12)
      ..strokeWidth = 0.6;
    const cells = 8;
    final cellW = size.width / cells;
    final cellH = size.height / cells;
    for (int i = 1; i < cells; i++) {
      canvas.drawLine(
        Offset(cellW * i, 0),
        Offset(cellW * i, size.height),
        gridPaint,
      );
      canvas.drawLine(
        Offset(0, cellH * i),
        Offset(size.width, cellH * i),
        gridPaint,
      );
    }
    // Snake + food preview
    final snakePaint = Paint()..color = theme.snakeColor;
    final foodPaint = Paint()..color = theme.foodColor;
    final r = (cellW < cellH ? cellW : cellH) * 0.42;
    for (int i = 0; i < 4; i++) {
      canvas.drawCircle(
        Offset(cellW * (2 + i) + cellW / 2, cellH * 4 + cellH / 2),
        r,
        snakePaint,
      );
    }
    canvas.drawCircle(
      Offset(cellW * 6 + cellW / 2, cellH * 2 + cellH / 2),
      r,
      foodPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ThemePreviewPainter old) =>
      old.theme != theme;
}

class _PowerUpCatalogItem {
  final String type;
  final String name;
  final String description;
  final IconData icon;
  final int coinCost;
  const _PowerUpCatalogItem({
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.coinCost,
  });
}
