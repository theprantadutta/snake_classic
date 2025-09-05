import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/premium_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/coins_provider.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/models/premium_cosmetics.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<PremiumProvider, ThemeProvider, CoinsProvider>(
      builder: (context, premiumProvider, themeProvider, coinsProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          body: AppBackground(
            theme: theme,
            child: CustomScrollView(
            slivers: [
              _buildAppBar(theme, coinsProvider),
              _buildFeaturedOffers(theme, premiumProvider, coinsProvider),
              SliverToBoxAdapter(
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: theme.accentColor,
                  labelColor: theme.textColor,
                  unselectedLabelColor: theme.textColor.withValues(alpha: 0.6),
                  tabs: const [
                    Tab(text: 'Premium', icon: Icon(Icons.star)),
                    Tab(text: 'Coins', icon: Icon(Icons.monetization_on)),
                    Tab(text: 'Cosmetics', icon: Icon(Icons.palette)),
                    Tab(text: 'Power-ups', icon: Icon(Icons.flash_on)),
                    Tab(text: 'Game Modes', icon: Icon(Icons.games)),
                    Tab(text: 'Boards', icon: Icon(Icons.grid_on)),
                  ],
                ),
              ),
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildPremiumTab(theme, premiumProvider),
                    _buildCoinsTab(theme, coinsProvider),
                    _buildCosmeticsTab(theme, premiumProvider, coinsProvider),
                    _buildPowerUpsTab(theme, premiumProvider, coinsProvider),
                    _buildGameModesTab(theme, premiumProvider),
                    _buildBoardSizesTab(theme, premiumProvider),
                  ],
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  Widget _buildAppBar(GameTheme theme, CoinsProvider coinsProvider) {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      backgroundColor: theme.accentColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text('Store'),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.accentColor,
                theme.accentColor.withValues(alpha: 0.8),
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: 16,
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🪙', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      Text(
                        '${coinsProvider.balance.total}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedOffers(GameTheme theme, PremiumProvider premiumProvider, CoinsProvider coinsProvider) {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Featured Offers',
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 16),
            
            // Premium subscription offer
            if (!premiumProvider.hasPremium) ...[
              _buildFeaturedOfferCard(
                title: 'Snake Pro Subscription',
                subtitle: '3-Day Free Trial',
                description: 'Unlock everything: themes, game modes, premium boards, and more!',
                price: '\$4.99/month',
                originalPrice: null,
                discount: 'Try Free',
                icon: '👑',
                gradientColors: [Colors.purple, Colors.blue],
                onTap: () => _showPremiumPurchase(),
                theme: theme,
              ),
              const SizedBox(height: 12),
            ],
            
            // Battle Pass offer
            _buildFeaturedOfferCard(
              title: 'Cosmic Battle Pass',
              subtitle: '60 Days of Rewards',
              description: '100 tiers of exclusive rewards, skins, and cosmic content',
              price: '\$9.99',
              originalPrice: null,
              discount: '60 Days',
              icon: '⚔️',
              gradientColors: [Colors.indigo, Colors.purple],
              onTap: () => Navigator.pushNamed(context, '/battle_pass'),
              theme: theme,
            ),
            const SizedBox(height: 12),
            
            // Coin pack offer
            _buildFeaturedOfferCard(
              title: 'Value Coin Pack',
              subtitle: 'Most Popular',
              description: '500 coins + 50 bonus coins for premium items',
              price: '\$4.99',
              originalPrice: null,
              discount: '10% Bonus',
              icon: '🪙',
              gradientColors: [Colors.amber, Colors.orange],
              onTap: () => _showCoinPurchase(CoinPurchaseOption.availableOptions[1]),
              theme: theme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedOfferCard({
    required String title,
    required String subtitle,
    required String description,
    required String price,
    String? originalPrice,
    required String discount,
    required String icon,
    required List<Color> gradientColors,
    required VoidCallback onTap,
    required GameTheme theme,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors.map((c) => c.withValues(alpha: 0.8)).toList(),
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Center(
                child: Text(icon, style: const TextStyle(fontSize: 30)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          discount,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (originalPrice != null) ...[
                  Text(
                    originalPrice,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                ],
                Text(
                  price,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumTab(GameTheme theme, PremiumProvider premiumProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (premiumProvider.hasPremium) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.orange],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.white, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Premium Active!',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'Enjoying all premium features',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/premium_benefits'),
                    child: const Text('Details', style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildSubscriptionOption(
              'Snake Pro Monthly',
              '\$4.99/month',
              '3-Day Free Trial',
              'All premium features included',
              theme,
              () => _showPremiumPurchase(),
            ),
            const SizedBox(height: 16),
            _buildSubscriptionOption(
              'Snake Pro Yearly',
              '\$39.99/year',
              'Save 33%',
              'Best value - 2 months free!',
              theme,
              () => _showPremiumPurchase(isYearly: true),
            ),
          ],
          
          const SizedBox(height: 24),
          Text(
            'Battle Pass',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          _buildBattlePassOption(theme, premiumProvider),
        ],
      ),
    );
  }

  Widget _buildSubscriptionOption(
    String title,
    String price,
    String badge,
    String description,
    GameTheme theme,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (badge.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            badge,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: theme.textColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: TextStyle(
                color: theme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBattlePassOption(GameTheme theme, PremiumProvider premiumProvider) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/battle_pass'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.withValues(alpha: 0.8), Colors.purple.withValues(alpha: 0.8)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('⚔️', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Cosmic Battle Pass',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '100 tiers of cosmic rewards',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const Text(
                  '\$9.99',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: premiumProvider.hasBattlePass ? premiumProvider.battlePassTier / 100.0 : 0.0,
              backgroundColor: Colors.white.withValues(alpha: 0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.amber),
            ),
            const SizedBox(height: 8),
            Text(
              premiumProvider.hasBattlePass
                  ? 'Tier ${premiumProvider.battlePassTier}/100'
                  : 'Join the cosmic adventure',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinsTab(GameTheme theme, CoinsProvider coinsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Balance display
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('🪙', style: TextStyle(fontSize: 40)),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Current Balance',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${coinsProvider.balance.total} Coins',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                        ),
                      ),
                    ],
                  ),
                ),
                if (coinsProvider.hasPremiumBonus)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${coinsProvider.earningMultiplier}x Bonus',
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
          
          const SizedBox(height: 24),
          Text(
            'Buy Coins',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          
          // Coin purchase options
          ...CoinPurchaseOption.availableOptions.map((option) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: _buildCoinPurchaseOption(option, theme),
            );
          }).toList(),
          
          const SizedBox(height: 24),
          Text(
            'Earn Free Coins',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          
          // Free earning methods
          _buildEarnCoinsMethod('🎮', 'Play Games', '5 coins per game', theme),
          _buildEarnCoinsMethod('📅', 'Daily Login', '10-50 coins daily', theme),
          _buildEarnCoinsMethod('🏆', 'Complete Achievements', '25-100 coins', theme),
          _buildEarnCoinsMethod('👑', 'Win Tournaments', '100+ coins', theme),
        ],
      ),
    );
  }

  Widget _buildCoinPurchaseOption(CoinPurchaseOption option, GameTheme theme) {
    return GestureDetector(
      onTap: () => _showCoinPurchase(option),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: option.isPopular 
                ? theme.accentColor 
                : theme.textColor.withValues(alpha: 0.2),
            width: option.isPopular ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Center(
                    child: Text('🪙', style: TextStyle(fontSize: 24)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.name,
                        style: TextStyle(
                          color: theme.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        option.displayCoins,
                        style: TextStyle(
                          color: theme.textColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        option.description,
                        style: TextStyle(
                          color: theme.textColor.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '\$${option.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
            
            if (option.isPopular)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'POPULAR',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            
            if (option.isBestValue)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BEST VALUE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEarnCoinsMethod(String icon, String method, String amount, GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              method,
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: Colors.amber,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCosmeticsTab(GameTheme theme, PremiumProvider premiumProvider, CoinsProvider coinsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Snake Skins',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: SnakeSkinType.values.length > 6 ? 6 : SnakeSkinType.values.length,
            itemBuilder: (context, index) {
              final skin = SnakeSkinType.values[index];
              final isUnlocked = !skin.isPremium || premiumProvider.isSkinUnlocked(skin.id);
              
              return _buildCosmeticItem(
                skin.icon,
                skin.displayName,
                isUnlocked ? 'Owned' : '${skin.price.toStringAsFixed(2)} coins',
                isUnlocked,
                theme,
                () => _purchaseCosmeticItem(skin.displayName, skin.price.round(), coinsProvider),
              );
            },
          ),
          
          const SizedBox(height: 24),
          Text(
            'Trail Effects',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: TrailEffectType.values.length > 6 ? 6 : TrailEffectType.values.length,
            itemBuilder: (context, index) {
              final trail = TrailEffectType.values[index];
              final isUnlocked = !trail.isPremium || premiumProvider.isTrailUnlocked(trail.id);
              
              return _buildCosmeticItem(
                trail.icon,
                trail.displayName,
                isUnlocked ? 'Owned' : '${trail.price.toStringAsFixed(2)} coins',
                isUnlocked,
                theme,
                () => _purchaseCosmeticItem(trail.displayName, trail.price.round(), coinsProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCosmeticItem(
    String icon,
    String name,
    String price,
    bool isUnlocked,
    GameTheme theme,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: isUnlocked ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked 
                ? Colors.green.withValues(alpha: 0.5)
                : theme.textColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(
              name,
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.green : theme.accentColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                price,
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

  Widget _buildPowerUpsTab(GameTheme theme, PremiumProvider premiumProvider, CoinsProvider coinsProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Power-ups',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          
          _buildPowerUpItem('⚡', 'Mega Speed Boost', 'Enhanced speed boost with trail effects', '50 coins', theme),
          _buildPowerUpItem('🛡️', 'Mega Invincibility', 'Longer invincibility with golden glow', '75 coins', theme),
          _buildPowerUpItem('👻', 'Ghost Mode', 'Phase through walls and yourself', '100 coins', theme),
          _buildPowerUpItem('🌟', 'Teleport', 'Instantly move to a safe location', '80 coins', theme),
          _buildPowerUpItem('🔍', 'Size Reducer', 'Temporarily shrink your snake', '60 coins', theme),
          _buildPowerUpItem('🔥', 'Combo Multiplier', 'Build up score multipliers', '90 coins', theme),
        ],
      ),
    );
  }

  Widget _buildPowerUpItem(String icon, String name, String description, String price, GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.textColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                price,
                style: TextStyle(
                  color: theme.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 60,
                height: 30,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Implement power-up purchase
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.accentColor,
                    padding: EdgeInsets.zero,
                  ),
                  child: const Text('Buy', style: TextStyle(fontSize: 10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGameModesTab(GameTheme theme, PremiumProvider premiumProvider) {
    final freeModes = GameMode.values.where((mode) => !mode.isPremium).toList();
    final premiumModes = GameMode.values.where((mode) => mode.isPremium).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Free Game Modes',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          
          ...freeModes.map((mode) => _buildGameModeItem(mode, true, theme)).toList(),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Premium Game Modes',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              if (!premiumProvider.hasPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...premiumModes.map((mode) => _buildGameModeItem(mode, premiumProvider.hasPremium, theme)).toList(),
        ],
      ),
    );
  }

  Widget _buildGameModeItem(GameMode mode, bool isUnlocked, GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isUnlocked ? 0.3 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked 
              ? theme.accentColor.withValues(alpha: 0.3)
              : theme.textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: isUnlocked ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    mode.icon, 
                    style: TextStyle(
                      fontSize: 24,
                      color: isUnlocked ? null : theme.textColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.name,
                      style: TextStyle(
                        color: isUnlocked ? theme.textColor : theme.textColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mode.description,
                      style: TextStyle(
                        color: isUnlocked 
                            ? theme.textColor.withValues(alpha: 0.7)
                            : theme.textColor.withValues(alpha: 0.3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (!isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
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
    );
  }

  Widget _buildBoardSizesTab(GameTheme theme, PremiumProvider premiumProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Free Board Sizes',
            style: TextStyle(
              color: theme.textColor,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 12),
          
          ...GameConstants.freeBoardSizes.map((size) => 
            _buildBoardSizeItem(size, true, theme)
          ).toList(),
          
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Premium Board Sizes',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 8),
              if (!premiumProvider.hasPremium)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'PREMIUM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...GameConstants.premiumBoardSizes.map((size) => 
            _buildBoardSizeItem(size, premiumProvider.hasPremium, theme)
          ).toList(),
        ],
      ),
    );
  }

  Widget _buildBoardSizeItem(BoardSize size, bool isUnlocked, GameTheme theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: isUnlocked ? 0.3 : 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnlocked 
              ? theme.accentColor.withValues(alpha: 0.3)
              : theme.textColor.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.accentColor.withValues(alpha: isUnlocked ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Center(
                  child: Text(
                    size.icon, 
                    style: TextStyle(
                      fontSize: 24,
                      color: isUnlocked ? null : theme.textColor.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${size.name} (${size.width}x${size.height})',
                      style: TextStyle(
                        color: isUnlocked ? theme.textColor : theme.textColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      size.description,
                      style: TextStyle(
                        color: isUnlocked 
                            ? theme.textColor.withValues(alpha: 0.7)
                            : theme.textColor.withValues(alpha: 0.3),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          if (!isUnlocked)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
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
    );
  }

  void _showPremiumPurchase({bool isYearly = false}) {
    final purchaseService = PurchaseService();
    final product = purchaseService.getProduct(ProductIds.snakeClassicProMonthly);
    
    if (product != null) {
      purchaseService.buyProduct(product);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Premium subscription not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCoinPurchase(CoinPurchaseOption option) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(option.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(option.description),
            const SizedBox(height: 16),
            Text(
              option.displayCoins,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Price: \$${option.price.toStringAsFixed(2)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
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
              // TODO: Implement coin purchase via Google Play
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _purchaseCosmeticItem(String itemName, int coinCost, CoinsProvider coinsProvider) {
    if (!coinsProvider.canAfford(coinCost)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Not enough coins! Need $coinCost coins.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase $itemName?'),
        content: Text('This will cost $coinCost coins.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              final success = await coinsProvider.spendCoins(
                coinCost,
                CoinSpendingCategory.cosmetics,
                itemName: itemName,
              );
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$itemName purchased!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Purchase failed!'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }
}