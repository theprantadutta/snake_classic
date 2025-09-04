import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/premium_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/utils/constants.dart';

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
    // TODO: Load from preferences service
    // For now, use defaults
    setState(() {
      _selectedSkin = SnakeSkinType.classic;
      _selectedTrail = TrailEffectType.none;
    });
  }

  void _saveSelection() {
    // TODO: Save to preferences service
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cosmetics applied successfully!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PremiumProvider, ThemeProvider>(
      builder: (context, premiumProvider, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          appBar: AppBar(
            title: const Text('Cosmetics'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            foregroundColor: theme.textColor,
            actions: [
              IconButton(
                icon: const Icon(Icons.check),
                onPressed: _saveSelection,
                tooltip: 'Apply Selection',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.accentColor,
              labelColor: theme.textColor,
              unselectedLabelColor: theme.textColor.withValues(alpha: 0.6),
              tabs: const [
                Tab(text: 'Snake Skins', icon: Icon(Icons.pets)),
                Tab(text: 'Trail Effects', icon: Icon(Icons.auto_awesome)),
                Tab(text: 'Bundles', icon: Icon(Icons.card_giftcard)),
              ],
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [
                  theme.accentColor.withValues(alpha: 0.1),
                  theme.backgroundColor,
                  theme.backgroundColor.withValues(alpha: 0.9),
                ],
                stops: const [0.0, 0.6, 1.0],
              ),
            ),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSkinsTab(premiumProvider, theme),
                _buildTrailsTab(premiumProvider, theme),
                _buildBundlesTab(premiumProvider, theme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSkinsTab(PremiumProvider premiumProvider, GameTheme theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: SnakeSkinType.values.length,
      itemBuilder: (context, index) {
        final skin = SnakeSkinType.values[index];
        final isUnlocked = !skin.isPremium || premiumProvider.isSkinUnlocked(skin.id);
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
  }

  Widget _buildTrailsTab(PremiumProvider premiumProvider, GameTheme theme) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: TrailEffectType.values.length,
      itemBuilder: (context, index) {
        final trail = TrailEffectType.values[index];
        final isUnlocked = !trail.isPremium || premiumProvider.isTrailUnlocked(trail.id);
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
  }

  Widget _buildBundlesTab(PremiumProvider premiumProvider, GameTheme theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: CosmeticBundle.availableBundles.length,
      itemBuilder: (context, index) {
        final bundle = CosmeticBundle.availableBundles[index];
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: theme.cardColor.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              ListTile(
                leading: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Center(
                    child: Text(
                      bundle.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                title: Text(
                  bundle.name,
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(
                  bundle.description,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (bundle.originalPrice > bundle.bundlePrice) ...[
                      Text(
                        '\$${bundle.originalPrice.toStringAsFixed(2)}',
                        style: TextStyle(
                          color: theme.textColor.withValues(alpha: 0.5),
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      Text(
                        '${bundle.savingsPercentage.toStringAsFixed(0)}% OFF',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _showBundlePurchaseDialog(bundle),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.accentColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text('Purchase Bundle'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
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
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? theme.accentColor 
                : theme.accentColor.withValues(alpha: 0.3),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Stack(
          children: [
            Column(
              children: [
                // Header with icon and price/status
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.isNotEmpty 
                        ? colors.first.withValues(alpha: 0.2)
                        : theme.accentColor.withValues(alpha: 0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        icon,
                        style: const TextStyle(fontSize: 40),
                      ),
                      const SizedBox(height: 8),
                      if (colors.length > 1)
                        Container(
                          height: 4,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: colors),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            color: theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: TextStyle(
                            color: theme.textColor.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        
                        // Status/Price
                        if (isUnlocked) ...[
                          if (isSelected)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: theme.accentColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'SELECTED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'OWNED',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ] else ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.accentColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              price > 0 ? '\$${price.toStringAsFixed(2)}' : 'FREE',
                              style: TextStyle(
                                color: theme.accentColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Lock overlay for premium items
            if (!isUnlocked && isPremium)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog({SnakeSkinType? skin, TrailEffectType? trail}) {
    // TODO: Implement premium purchase dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Premium Feature'),
        content: Text(
          skin != null 
              ? 'Unlock ${skin.displayName} for \$${skin.price.toStringAsFixed(2)}?'
              : 'Unlock ${trail!.displayName} for \$${trail.price.toStringAsFixed(2)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual purchase
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _showBundlePurchaseDialog(CosmeticBundle bundle) {
    // TODO: Implement bundle purchase dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(bundle.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(bundle.description),
            const SizedBox(height: 16),
            Text(
              'Price: \$${bundle.bundlePrice.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (bundle.savings > 0)
              Text(
                'Save: \$${bundle.savings.toStringAsFixed(2)} (${bundle.savingsPercentage.toStringAsFixed(0)}%)',
                style: const TextStyle(color: Colors.green),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Implement actual bundle purchase
            },
            child: const Text('Purchase Bundle'),
          ),
        ],
      ),
    );
  }
}