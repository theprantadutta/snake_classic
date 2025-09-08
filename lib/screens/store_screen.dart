import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/premium_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/providers/coins_provider.dart';
import 'package:snake_classic/models/snake_coins.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class StoreScreen extends StatefulWidget {
  const StoreScreen({super.key});

  @override
  State<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends State<StoreScreen>
    with SingleTickerProviderStateMixin {
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
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text(
              'Snake Store',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.primaryColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: AppBackground(
            theme: theme,
            child: Column(
              children: [
                // Add top padding to account for AppBar
                SizedBox(
                  height: MediaQuery.of(context).padding.top + kToolbarHeight,
                ),

                // Coins display header
                _buildCoinsHeader(theme, coinsProvider),

                // Tab Bar
                Container(
                  color: Colors.transparent,
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: theme.accentColor,
                    labelColor: theme.accentColor,
                    unselectedLabelColor: theme.accentColor.withValues(alpha: 0.6),
                    isScrollable: true,
                    tabs: const [
                      Tab(text: 'Premium', icon: Icon(Icons.diamond, size: 16)),
                      Tab(text: 'Coins', icon: Icon(Icons.monetization_on, size: 16)),
                      Tab(text: 'Skins', icon: Icon(Icons.palette, size: 16)),
                      Tab(text: 'Power-ups', icon: Icon(Icons.flash_on, size: 16)),
                      Tab(text: 'Modes', icon: Icon(Icons.games, size: 16)),
                      Tab(text: 'Boards', icon: Icon(Icons.grid_on, size: 16)),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPremiumTab(theme, premiumProvider),
                      _buildCoinsTab(theme, coinsProvider),
                      _buildSkinsTab(theme, premiumProvider, coinsProvider),
                      _buildPowerUpsTab(theme, premiumProvider, coinsProvider),
                      _buildGameModesTab(theme, premiumProvider),
                      _buildBoardsTab(theme, premiumProvider),
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
                gradient: LinearGradient(colors: [Colors.amber, Colors.orange]),
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
                    '${coinsProvider.balance.total}',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (coinsProvider.hasPremiumBonus)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [Colors.purple.shade400, Colors.indigo.shade400]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${coinsProvider.earningMultiplier}x BONUS',
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

  Widget _buildPremiumTab(GameTheme theme, PremiumProvider premiumProvider) {
    if (premiumProvider.hasPremium) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                child: const Icon(
                  Icons.verified,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Premium Active!',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Enjoying all premium features',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildPremiumPromoCard(theme),
          const SizedBox(height: 16),
          _buildQuickPremiumFeatures(theme),
          const SizedBox(height: 20),
          _buildPremiumCTA(theme),
        ],
      ),
    );
  }

  Widget _buildPremiumPromoCard(GameTheme theme) {
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
            child: const Icon(
              Icons.diamond,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Go Premium!',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Unlock everything Snake Classic has to offer',
            style: TextStyle(
              color: theme.accentColor.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickPremiumFeatures(GameTheme theme) {
    final features = [
      'All Premium Themes',
      'Large Game Boards', 
      'Exclusive Game Modes',
      'Premium Power-ups',
      '2x Coin Rewards',
      'VIP Tournaments',
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.accentColor.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: theme.accentColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  features[index],
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPremiumCTA(GameTheme theme) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: () => Navigator.of(context).pushNamed('/premium'),
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
          child: const Text(
            'Upgrade to Premium',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
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
          Text(
            'Buy Snake Coins',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...CoinPurchaseOption.availableOptions.map((option) =>
              _buildCoinPackCard(option, theme)),
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
          _buildEarnMethodCard('Play Games', '5 coins per game', Icons.games, theme),
          _buildEarnMethodCard('Daily Login', '10-50 coins daily', Icons.calendar_today, theme),
          _buildEarnMethodCard('Achievements', '25-100 coins', Icons.emoji_events, theme),
          _buildEarnMethodCard('Tournaments', '100+ coins', Icons.leaderboard, theme),
        ],
      ),
    );
  }

  Widget _buildCoinPackCard(CoinPurchaseOption option, GameTheme theme) {
    return Container(
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
              gradient: LinearGradient(colors: [Colors.amber, Colors.orange]),
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
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            '\$${option.price.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.amber,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarnMethodCard(String title, String reward, IconData icon, GameTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
          width: 1,
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
            child: Icon(
              icon,
              color: theme.accentColor,
              size: 20,
            ),
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
            style: TextStyle(
              color: Colors.amber,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkinsTab(GameTheme theme, PremiumProvider premiumProvider, CoinsProvider coinsProvider) {
    final skins = [
      _SkinItem('Classic Snake', Icons.straighten, 'Free', true, false),
      _SkinItem('Rainbow Trail', Icons.auto_awesome, '50 coins', false, false),
      _SkinItem('Electric Snake', Icons.electric_bolt, '75 coins', false, false),
      _SkinItem('Fire Snake', Icons.local_fire_department, '100 coins', false, true),
      _SkinItem('Ice Snake', Icons.ac_unit, '125 coins', false, true),
      _SkinItem('Cosmic Snake', Icons.stars, '150 coins', false, true),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Snake Skins & Trails',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.0,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: skins.length,
            itemBuilder: (context, index) {
              return _buildSkinCard(skins[index], theme);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSkinCard(_SkinItem skin, GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: skin.isOwned 
              ? Colors.green.withValues(alpha: 0.4)
              : skin.isPremium
                  ? Colors.purple.shade400.withValues(alpha: 0.4)
                  : theme.accentColor.withValues(alpha: 0.2),
          width: skin.isOwned ? 2 : 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: skin.isOwned
                  ? Colors.green.withValues(alpha: 0.2)
                  : skin.isPremium
                      ? Colors.purple.shade400.withValues(alpha: 0.2)
                      : theme.accentColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              skin.icon,
              color: skin.isOwned
                  ? Colors.green
                  : skin.isPremium
                      ? Colors.purple.shade400
                      : theme.accentColor,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            skin.name,
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: skin.isOwned
                  ? Colors.green
                  : skin.isPremium
                      ? Colors.purple.shade400
                      : Colors.amber,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              skin.isOwned ? 'OWNED' : skin.price,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerUpsTab(GameTheme theme, PremiumProvider premiumProvider, CoinsProvider coinsProvider) {
    final powerUps = [
      _PowerUpItem('Speed Boost', 'Enhanced speed with trail effects', Icons.speed, '50 coins'),
      _PowerUpItem('Invincibility', 'Temporary invincibility shield', Icons.shield, '75 coins'),
      _PowerUpItem('Ghost Mode', 'Phase through walls and yourself', Icons.visibility_off, '100 coins'),
      _PowerUpItem('Teleport', 'Instantly move to a safe location', Icons.my_location, '80 coins'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Premium Power-ups',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...powerUps.map((powerUp) => _buildPowerUpCard(powerUp, theme)),
        ],
      ),
    );
  }

  Widget _buildPowerUpCard(_PowerUpItem powerUp, GameTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
          width: 1,
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
            child: Icon(
              powerUp.icon,
              color: theme.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  powerUp.name,
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  powerUp.description,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            powerUp.price,
            style: TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGameModesTab(GameTheme theme, PremiumProvider premiumProvider) {
    final gameModes = [
      _GameModeItem('Classic', 'Traditional snake gameplay', Icons.straighten, true, false),
      _GameModeItem('Zen Mode', 'No walls, peaceful gameplay', Icons.spa, false, true),
      _GameModeItem('Speed Challenge', 'Fast-paced action mode', Icons.speed, false, true),
      _GameModeItem('Multi-Food', 'Multiple food items at once', Icons.fastfood, false, true),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Game Modes',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...gameModes.map((mode) => _buildGameModeCard(mode, theme)),
        ],
      ),
    );
  }

  Widget _buildGameModeCard(_GameModeItem mode, GameTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: mode.isPremium
              ? Colors.purple.shade400.withValues(alpha: 0.4)
              : theme.accentColor.withValues(alpha: 0.2),
          width: mode.isPremium ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: mode.isPremium
                  ? Colors.purple.shade400.withValues(alpha: 0.2)
                  : theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              mode.icon,
              color: mode.isPremium
                  ? Colors.purple.shade400
                  : theme.accentColor,
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
                      mode.name,
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (mode.isPremium) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
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
                  mode.description,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (mode.isPremium)
            Icon(
              Icons.lock,
              color: Colors.purple.shade400,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildBoardsTab(GameTheme theme, PremiumProvider premiumProvider) {
    final boards = [
      _BoardItem('Small', '15x15', 'Perfect for quick games', Icons.smartphone, true),
      _BoardItem('Medium', '20x20', 'Balanced gameplay', Icons.tablet, true),
      _BoardItem('Large', '25x25', 'Extended gameplay', Icons.computer, true),
      _BoardItem('Huge', '35x35', 'Epic snake adventures', Icons.tv, false),
      _BoardItem('Massive', '50x50', 'Ultimate challenge', Icons.desktop_windows, false),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Board Sizes',
            style: TextStyle(
              color: theme.accentColor,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...boards.map((board) => _buildBoardCard(board, theme)),
        ],
      ),
    );
  }

  Widget _buildBoardCard(_BoardItem board, GameTheme theme) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.accentColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: !board.isFree
              ? Colors.purple.shade400.withValues(alpha: 0.4)
              : theme.accentColor.withValues(alpha: 0.2),
          width: !board.isFree ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: !board.isFree
                  ? Colors.purple.shade400.withValues(alpha: 0.2)
                  : theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              board.icon,
              color: !board.isFree
                  ? Colors.purple.shade400
                  : theme.accentColor,
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
                      '${board.name} (${board.size})',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (!board.isFree) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'PRO',
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
                  board.description,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          if (!board.isFree)
            Icon(
              Icons.lock,
              color: Colors.purple.shade400,
              size: 20,
            ),
        ],
      ),
    );
  }
}

class _SkinItem {
  final String name;
  final IconData icon;
  final String price;
  final bool isOwned;
  final bool isPremium;

  _SkinItem(this.name, this.icon, this.price, this.isOwned, this.isPremium);
}

class _PowerUpItem {
  final String name;
  final String description;
  final IconData icon;
  final String price;

  _PowerUpItem(this.name, this.description, this.icon, this.price);
}

class _GameModeItem {
  final String name;
  final String description;
  final IconData icon;
  final bool isFree;
  final bool isPremium;

  _GameModeItem(this.name, this.description, this.icon, this.isFree, this.isPremium);
}

class _BoardItem {
  final String name;
  final String size;
  final String description;
  final IconData icon;
  final bool isFree;

  _BoardItem(this.name, this.size, this.description, this.icon, this.isFree);
}