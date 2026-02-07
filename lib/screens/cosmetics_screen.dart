import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/presentation/bloc/coins/coins_cubit.dart';
import 'package:snake_classic/presentation/bloc/premium/premium_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/router/routes.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class CosmeticsScreen extends StatefulWidget {
  const CosmeticsScreen({super.key});

  @override
  State<CosmeticsScreen> createState() => _CosmeticsScreenState();
}

class _CosmeticsScreenState extends State<CosmeticsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  SnakeSkinType _selectedSkin = SnakeSkinType.classic;
  TrailEffectType _selectedTrail = TrailEffectType.none;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load current cosmetics selection from preferences
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCurrentSelection();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _loadCurrentSelection() {
    final premiumCubit = context.read<PremiumCubit>();
    setState(() {
      _selectedSkin = _skinIdToType(premiumCubit.state.selectedSkinId);
      _selectedTrail = _trailIdToType(premiumCubit.state.selectedTrailId);
    });
  }

  Future<void> _saveSelection() async {
    final premiumCubit = context.read<PremiumCubit>();

    // Save selections to premium cubit
    await premiumCubit.selectSkin(_selectedSkin.id);
    await premiumCubit.selectTrail(_selectedTrail.id);

    // Show confirmation
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cosmetics applied successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  SnakeSkinType _skinIdToType(String skinId) {
    return SnakeSkinType.values.firstWhere(
      (type) => type.id == skinId,
      orElse: () => SnakeSkinType.classic,
    );
  }

  TrailEffectType _trailIdToType(String trailId) {
    return TrailEffectType.values.firstWhere(
      (type) => type.id == trailId,
      orElse: () => TrailEffectType.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;

        return BlocBuilder<PremiumCubit, PremiumState>(
          builder: (context, premiumState) {
            return BlocBuilder<CoinsCubit, CoinsState>(
              builder: (context, coinsState) {
                return Scaffold(
                  body: AppBackground(
                    theme: theme,
                    child: SafeArea(
                      child: Column(
                        children: [
                          // Header
                          _buildHeader(theme),

                          // Coins display header
                          _buildCoinsHeader(theme, coinsState),

                          // Tab Bar
                          _buildTabBar(theme),

                          // Tab content
                          Expanded(
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                _buildSkinsTab(premiumState, coinsState, theme),
                                _buildTrailsTab(
                                  premiumState,
                                  coinsState,
                                  theme,
                                ),
                                _buildBundlesTab(
                                  premiumState,
                                  coinsState,
                                  theme,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildHeader(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(Icons.arrow_back, color: theme.accentColor, size: 24),
          ),
          const SizedBox(width: 8),
          Icon(Icons.palette, color: theme.accentColor, size: 28),
          const SizedBox(width: 12),
          Text(
            'Cosmetics',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: _saveSelection,
            icon: Icon(Icons.check, color: theme.accentColor, size: 24),
            tooltip: 'Apply Selection',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(GameTheme theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: TabBar(
        controller: _tabController,
        indicatorColor: theme.accentColor,
        labelColor: theme.accentColor,
        unselectedLabelColor: Colors.white.withValues(alpha: 0.6),
        tabs: const [
          Tab(text: 'Skins'),
          Tab(text: 'Trails'),
          Tab(text: 'Bundles'),
        ],
      ),
    );
  }

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
              Colors.amber.withValues(alpha: 0.2),
              Colors.orange.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.monetization_on,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Snake Coins',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${coinsState.balance.total}',
                  style: TextStyle(
                    color: Colors.amber.shade700,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to store coins tab
                context.pushReplacement('${AppRoutes.store}?tab=1');
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Buy More'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkinsTab(
    PremiumState premiumState,
    CoinsState coinsState,
    GameTheme theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        final childAspectRatio = constraints.maxWidth > 600 ? 0.75 : 0.7;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: SnakeSkinType.values.length,
          itemBuilder: (context, index) {
            final skin = SnakeSkinType.values[index];
            final isUnlocked =
                !skin.isPremium || premiumState.isSkinOwned(skin.id);
            final isSelected = skin == _selectedSkin;

            return _buildCosmeticCard(
              title: skin.displayName,
              description: skin.description,
              icon: skin.icon,
              colors: skin.colors,
              price: skin.price,
              isUnlocked: isUnlocked,
              isSelected: isSelected,
              isPremium: skin.isPremium,
              theme: theme,
              onTap: () {
                if (isUnlocked) {
                  setState(() {
                    _selectedSkin = skin;
                  });
                } else {
                  _showPurchaseDialog(skin: skin);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildTrailsTab(
    PremiumState premiumState,
    CoinsState coinsState,
    GameTheme theme,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
        final childAspectRatio = constraints.maxWidth > 600 ? 0.75 : 0.7;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: TrailEffectType.values.length,
          itemBuilder: (context, index) {
            final trail = TrailEffectType.values[index];
            final isUnlocked =
                !trail.isPremium || premiumState.isTrailOwned(trail.id);
            final isSelected = trail == _selectedTrail;

            return _buildCosmeticCard(
              title: trail.displayName,
              description: trail.description,
              icon: trail.icon,
              colors: trail.colors,
              price: trail.price,
              isUnlocked: isUnlocked,
              isSelected: isSelected,
              isPremium: trail.isPremium,
              theme: theme,
              onTap: () {
                if (isUnlocked) {
                  setState(() {
                    _selectedTrail = trail;
                  });
                } else {
                  _showPurchaseDialog(trail: trail);
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBundlesTab(
    PremiumState premiumState,
    CoinsState coinsState,
    GameTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
          final childAspectRatio = constraints.maxWidth > 600 ? 1.4 : 1.2;

          return GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: CosmeticBundle.availableBundles.length,
            itemBuilder: (context, index) {
              final bundle = CosmeticBundle.availableBundles[index];
              final isUnlocked = premiumState.isBundleOwned(bundle.id);

              return _buildBundleCard(
                bundle: bundle,
                isUnlocked: isUnlocked,
                theme: theme,
                onTap: () {
                  if (!isUnlocked) {
                    _showBundlePurchaseDialog(bundle);
                  }
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildBundleCard({
    required CosmeticBundle bundle,
    required bool isUnlocked,
    required GameTheme theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked
                ? Colors.green.withValues(alpha: 0.4)
                : theme.accentColor.withValues(alpha: 0.2),
            width: isUnlocked ? 2 : 1,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon container with gradient background
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.accentColor.withValues(alpha: 0.3),
                            theme.accentColor.withValues(alpha: 0.1),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        bundle.icon,
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Title
                    Flexible(
                      child: Text(
                        bundle.name,
                        style: TextStyle(
                          color: theme.accentColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Description
                    Flexible(
                      child: Text(
                        bundle.description,
                        style: TextStyle(
                          color: theme.accentColor.withValues(alpha: 0.7),
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Price section
                    Column(
                      children: [
                        if (bundle.originalPrice > bundle.bundlePrice) ...[
                          Text(
                            '\$${bundle.originalPrice.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: theme.accentColor.withValues(alpha: 0.5),
                              fontSize: 10,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${bundle.savingsPercentage.toStringAsFixed(0)}% OFF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          '\$${bundle.bundlePrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: theme.accentColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Status indicator
                if (isUnlocked)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomLeft: Radius.circular(8),
                        ),
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCosmeticCard({
    required String title,
    required String description,
    required String icon,
    required List<Color> colors,
    required double price,
    required bool isUnlocked,
    required bool isSelected,
    required bool isPremium,
    required GameTheme theme,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? theme.accentColor
                : isUnlocked
                ? Colors.green.withValues(alpha: 0.4)
                : isPremium
                ? Colors.purple.shade400.withValues(alpha: 0.4)
                : theme.accentColor.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: theme.accentColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Icon container with color background
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUnlocked
                            ? (isSelected
                                  ? theme.accentColor
                                  : Colors.green.withValues(alpha: 0.2))
                            : isPremium
                            ? Colors.purple.shade400.withValues(alpha: 0.2)
                            : theme.accentColor.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        icon,
                        style: TextStyle(
                          fontSize: 32,
                          color: isUnlocked
                              ? (isSelected ? Colors.white : Colors.green)
                              : isPremium
                              ? Colors.purple.shade400
                              : theme.accentColor,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Title
                    Flexible(
                      child: Text(
                        title,
                        style: TextStyle(
                          color: theme.accentColor,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // Description
                    Flexible(
                      child: Text(
                        description,
                        style: TextStyle(
                          color: theme.accentColor.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Color gradient preview
                    if (colors.length > 1)
                      Container(
                        height: 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: colors),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),

                    if (colors.length > 1) const SizedBox(height: 12),

                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? theme.accentColor
                            : isUnlocked
                            ? Colors.green
                            : isPremium
                            ? Colors.purple.shade400
                            : Colors.amber,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        isSelected
                            ? 'SELECTED'
                            : isUnlocked
                            ? 'OWNED'
                            : price > 0
                            ? '\$${price.toStringAsFixed(2)}'
                            : 'FREE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),

                // Premium lock overlay
                if (!isUnlocked && isPremium)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.lock, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showPurchaseDialog({SnakeSkinType? skin, TrailEffectType? trail}) {
    final theme = context.read<ThemeCubit>().state.currentTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.shopping_cart, color: theme.accentColor),
            const SizedBox(width: 8),
            Text(
              'Premium Purchase',
              style: TextStyle(color: theme.accentColor),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              skin != null
                  ? 'Unlock ${skin.displayName} for \$${skin.price.toStringAsFixed(2)}?'
                  : 'Unlock ${trail!.displayName} for \$${trail.price.toStringAsFixed(2)}?',
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 12),
            Text(
              'This will be processed through Google Play Store.',
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processPurchase(skin: skin, trail: trail);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _processPurchase({SnakeSkinType? skin, TrailEffectType? trail}) async {
    final purchaseService = PurchaseService();
    final premiumCubit = context.read<PremiumCubit>();

    try {
      // Show processing indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                skin != null
                    ? 'Processing ${skin.displayName} purchase...'
                    : 'Processing ${trail!.displayName} purchase...',
              ),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );

      String productId;
      if (skin != null) {
        productId = skin.id;
        await purchaseService.purchaseProduct(productId);
        await premiumCubit.unlockSkin(productId);
      } else if (trail != null) {
        productId = trail.id;
        await purchaseService.purchaseProduct(productId);
        await premiumCubit.unlockTrail(productId);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              skin != null
                  ? '${skin.displayName} purchased successfully! ✓'
                  : '${trail!.displayName} purchased successfully! ✓',
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh UI to show unlocked state
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _processBundlePurchase(CosmeticBundle bundle) async {
    final purchaseService = PurchaseService();
    final premiumCubit = context.read<PremiumCubit>();

    try {
      // Show processing indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Text('Processing ${bundle.name} purchase...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 2),
        ),
      );

      // Purchase the bundle
      await purchaseService.purchaseProduct(bundle.id);

      // Unlock all items in the bundle
      for (final skin in bundle.skins) {
        await premiumCubit.unlockSkin(skin.id);
      }
      for (final trail in bundle.trails) {
        await premiumCubit.unlockTrail(trail.id);
      }
      await premiumCubit.unlockBundle(bundle.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${bundle.name} purchased successfully! All items unlocked! ✓',
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh UI to show unlocked states
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bundle purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showBundlePurchaseDialog(CosmeticBundle bundle) {
    final theme = context.read<ThemeCubit>().state.currentTheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.card_giftcard, color: theme.accentColor),
            const SizedBox(width: 8),
            Text(bundle.name, style: TextStyle(color: theme.accentColor)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              bundle.description,
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.8)),
            ),
            const SizedBox(height: 16),
            Text(
              'Price: \$${bundle.bundlePrice.toStringAsFixed(2)}',
              style: TextStyle(
                color: theme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            if (bundle.savings > 0)
              Text(
                'Save: \$${bundle.savings.toStringAsFixed(2)} (${bundle.savingsPercentage.toStringAsFixed(0)}%)',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Text(
              'This bundle includes multiple premium items with great savings!',
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: theme.accentColor.withValues(alpha: 0.7)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _processBundlePurchase(bundle);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('Purchase Bundle'),
          ),
        ],
      ),
    );
  }
}
