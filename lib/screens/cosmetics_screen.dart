import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/premium_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/coins_provider.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
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
    final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
    setState(() {
      _selectedSkin = _skinIdToType(premiumProvider.selectedSkinId);
      _selectedTrail = _trailIdToType(premiumProvider.selectedTrailId);
    });
  }

  Future<void> _saveSelection() async {
    final premiumProvider = Provider.of<PremiumProvider>(context, listen: false);
    
    // Save selections to premium provider
    await premiumProvider.selectSkin(_selectedSkin.id);
    await premiumProvider.selectTrail(_selectedTrail.id);
    
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
    return Consumer3<PremiumProvider, ThemeProvider, CoinsProvider>(
      builder: (context, premiumProvider, themeProvider, coinsProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          body: AppBackground(
            theme: theme,
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(theme),
                  
                  // Coins display header
                  _buildCoinsHeader(theme, coinsProvider),

                  // Tab Bar
                  _buildTabBar(theme),

                  // Tab content
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSkinsTab(premiumProvider, coinsProvider, theme),
                        _buildTrailsTab(premiumProvider, coinsProvider, theme),
                        _buildBundlesTab(premiumProvider, coinsProvider, theme),
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
  }

  Widget _buildHeader(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.arrow_back,
              color: theme.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 8),
          Icon(
            Icons.palette,
            color: theme.accentColor,
            size: 28,
          ),
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
            icon: Icon(
              Icons.check,
              color: theme.accentColor,
              size: 24,
            ),
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

  Widget _buildCoinsHeader(GameTheme theme, CoinsProvider coinsProvider) {
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
                  '${coinsProvider.balance.total}',
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
                // Navigate back to store coins tab
                Navigator.pop(context);
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('Buy More'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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

  Widget _buildSkinsTab(PremiumProvider premiumProvider, CoinsProvider coinsProvider, GameTheme theme) {
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

  Widget _buildTrailsTab(PremiumProvider premiumProvider, CoinsProvider coinsProvider, GameTheme theme) {
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

  Widget _buildBundlesTab(PremiumProvider premiumProvider, CoinsProvider coinsProvider, GameTheme theme) {
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
          boxShadow: isSelected ? [
            BoxShadow(
              color: theme.accentColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Icon container with color background
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? (isSelected ? theme.accentColor : Colors.green.withValues(alpha: 0.2))
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
                Text(
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
                
                const SizedBox(height: 4),
                
                // Description
                Text(
                  description,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                                ? '${price.toInt()} coins'
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
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 24,
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