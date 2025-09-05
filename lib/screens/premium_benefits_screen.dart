import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/premium_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

class PremiumBenefitsScreen extends StatefulWidget {
  const PremiumBenefitsScreen({super.key});

  @override
  State<PremiumBenefitsScreen> createState() => _PremiumBenefitsScreenState();
}

class _PremiumBenefitsScreenState extends State<PremiumBenefitsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isYearly = false;

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
    return Consumer2<PremiumProvider, ThemeProvider>(
      builder: (context, premiumProvider, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        
        return Scaffold(
          body: AppBackground(
            theme: theme,
            child: CustomScrollView(
              slivers: [
                _buildAppBar(theme, premiumProvider),
                _buildPricingSection(theme, premiumProvider),
                _buildBenefitsComparison(theme, premiumProvider),
                _buildFeatureHighlights(theme),
                _buildTestimonials(theme),
                _buildFAQ(theme),
              ],
            ),
          ),
          bottomNavigationBar: premiumProvider.hasPremium 
              ? null 
              : _buildCTASection(theme, premiumProvider),
        );
      },
    );
  }

  Widget _buildAppBar(GameTheme theme, PremiumProvider premiumProvider) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      backgroundColor: Colors.transparent,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.accentColor,
                theme.accentColor.withValues(alpha: 0.8),
                theme.backgroundColor,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _PremiumBackgroundPainter(theme.accentColor),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60), // App bar space
                    
                    if (premiumProvider.hasPremium) ...[
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Premium Active!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Enjoy all premium features',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Upgrade to Premium',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Unlock exclusive features & content',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      foregroundColor: Colors.white,
    );
  }

  Widget _buildPricingSection(GameTheme theme, PremiumProvider premiumProvider) {
    if (premiumProvider.hasPremium) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 24),
            
            // Pricing toggle
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.backgroundColor.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildPricingTab('Monthly', false, theme),
                  _buildPricingTab('Yearly', true, theme),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Pricing cards
            if (_isYearly) ...[
              _buildPricingCard(
                title: 'Snake Pro - Yearly',
                subtitle: 'Best Value!',
                price: '\$39.99',
                period: '/year',
                originalPrice: '\$59.88',
                savings: 'Save 33%',
                theme: theme,
                isPopular: true,
              ),
            ] else ...[
              _buildPricingCard(
                title: 'Snake Pro',
                subtitle: 'Monthly Plan',
                price: '\$4.99',
                period: '/month',
                theme: theme,
                isPopular: false,
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Battle Pass option
            _buildPricingCard(
              title: 'Battle Pass',
              subtitle: 'Current Season',
              price: '\$9.99',
              period: '/season',
              description: '60 days of exclusive rewards',
              theme: theme,
              isPopular: false,
              isBattlePass: true,
            ),
            
            const SizedBox(height: 24),
            
            // Trial offer
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green, width: 1),
              ),
              child: Row(
                children: [
                  const Icon(Icons.card_giftcard, color: Colors.green, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '3-Day Free Trial',
                          style: TextStyle(
                            color: theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Try all premium features risk-free',
                          style: TextStyle(
                            color: theme.textColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingTab(String label, bool isYearly, GameTheme theme) {
    final isSelected = _isYearly == isYearly;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _isYearly = isYearly;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.textColor.withValues(alpha: 0.7),
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildPricingCard({
    required String title,
    required String subtitle,
    required String price,
    required String period,
    String? originalPrice,
    String? savings,
    String? description,
    required GameTheme theme,
    required bool isPopular,
    bool isBattlePass = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isPopular 
            ? theme.accentColor.withValues(alpha: 0.1)
            : theme.backgroundColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPopular ? theme.accentColor : theme.textColor.withValues(alpha: 0.2),
          width: isPopular ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: theme.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: theme.textColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            color: theme.textColor.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (originalPrice != null) ...[
                      Text(
                        originalPrice,
                        style: TextStyle(
                          color: theme.textColor.withValues(alpha: 0.5),
                          fontSize: 12,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      if (savings != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            savings,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      const SizedBox(height: 4),
                    ],
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          price,
                          style: TextStyle(
                            color: theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        Text(
                          period,
                          style: TextStyle(
                            color: theme.textColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          if (isPopular)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomLeft: Radius.circular(8),
                  ),
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
            ),
        ],
      ),
    );
  }

  Widget _buildBenefitsComparison(GameTheme theme, PremiumProvider premiumProvider) {
    final benefits = [
      _BenefitItem('Core Snake Game', true, true, '🐍'),
      _BenefitItem('6 Premium Themes', false, true, '🎨'),
      _BenefitItem('All Snake Skins & Trails', false, true, '✨'),
      _BenefitItem('Large Board Sizes (35x35, 40x40, 50x50)', false, true, '📐'),
      _BenefitItem('Exclusive Game Modes (Zen, Speed, Multi-food)', false, true, '🎮'),
      _BenefitItem('Premium Power-ups & Abilities', false, true, '⚡'),
      _BenefitItem('2x Snake Coins Earning Rate', false, true, '🪙'),
      _BenefitItem('Cloud Save Backup', false, true, '☁️'),
      _BenefitItem('Priority Tournament Access', false, true, '🏆'),
      _BenefitItem('Exclusive Premium Tournaments', false, true, '👑'),
      _BenefitItem('Advanced Statistics & Analytics', false, true, '📊'),
      _BenefitItem('Daily Premium Challenges', false, true, '📅'),
      _BenefitItem('Premium Profile Badge & Highlights', false, true, '🏅'),
      _BenefitItem('No Ads (Ad-free Experience)', false, true, '🚫'),
      _BenefitItem('Priority Customer Support', false, true, '💬'),
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Free vs Premium Comparison',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            
            // Header row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: theme.backgroundColor.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Expanded(flex: 3, child: SizedBox()),
                  Expanded(
                    child: Text(
                      'Free',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Premium',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Benefits rows
            ...benefits.asMap().entries.map((entry) {
              final index = entry.key;
              final benefit = entry.value;
              
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: index % 2 == 0 
                      ? Colors.transparent 
                      : theme.backgroundColor.withValues(alpha: 0.1),
                ),
                child: Row(
                  children: [
                    Text(benefit.icon, style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Text(
                        benefit.title,
                        style: TextStyle(
                          color: theme.textColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        benefit.inFree ? Icons.check : Icons.close,
                        color: benefit.inFree ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Icon(
                        benefit.inPremium ? Icons.check : Icons.close,
                        color: benefit.inPremium ? Colors.green : Colors.red,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureHighlights(GameTheme theme) {
    final highlights = [
      _FeatureHighlight(
        '🎨', 
        'Premium Themes & Cosmetics',
        'Unlock all 6 premium themes, exclusive snake skins, and spectacular trail effects to customize your game experience.',
      ),
      _FeatureHighlight(
        '📐', 
        'Larger Game Boards',
        'Challenge yourself on massive 35x35, 40x40, and 50x50 boards for extended gameplay and higher score potential.',
      ),
      _FeatureHighlight(
        '🎮', 
        'Exclusive Game Modes',
        'Access Zen mode (no walls), Speed Challenge, and Multi-food mode for varied and exciting gameplay experiences.',
      ),
      _FeatureHighlight(
        '⚡', 
        'Premium Power-ups',
        'Use exclusive power-ups like Teleport, Ghost Mode, Size Reducer, and more for strategic advantages.',
      ),
      _FeatureHighlight(
        '🪙', 
        'Double Coins & Rewards',
        'Earn Snake Coins 2x faster and get better rewards from daily challenges, tournaments, and achievements.',
      ),
      _FeatureHighlight(
        '👑', 
        'VIP Tournament Access',
        'Join exclusive premium tournaments with bigger prizes and compete against other premium players.',
      ),
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'Premium Features',
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
            
            ...highlights.map((highlight) => Container(
              margin: const EdgeInsets.only(bottom: 16),
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
                  Text(highlight.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          highlight.title,
                          style: TextStyle(
                            color: theme.textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          highlight.description,
                          style: TextStyle(
                            color: theme.textColor.withValues(alpha: 0.7),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTestimonials(GameTheme theme) {
    final testimonials = [
      _Testimonial(
        '⭐⭐⭐⭐⭐',
        'Premium features are totally worth it! The larger boards and exclusive skins make the game so much more fun.',
        'GameMaster2024',
      ),
      _Testimonial(
        '⭐⭐⭐⭐⭐',
        'The premium power-ups completely changed my strategy. Ghost mode is a game-changer!',
        'SnakeChampion',
      ),
      _Testimonial(
        '⭐⭐⭐⭐⭐',
        'Love the premium tournaments. The competition is fierce but the rewards are amazing!',
        'ProPlayer99',
      ),
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'What Premium Players Say',
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            
            ...testimonials.map((testimonial) => Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.backgroundColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    testimonial.rating,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${testimonial.text}"',
                    style: TextStyle(
                      color: theme.textColor,
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '— ${testimonial.author}',
                    style: TextStyle(
                      color: theme.textColor.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQ(GameTheme theme) {
    final faqs = [
      _FAQ(
        'Can I cancel my subscription anytime?',
        'Yes! You can cancel your subscription at any time through the Google Play Store. You\'ll continue to have premium access until the end of your current billing period.',
      ),
      _FAQ(
        'What happens to my premium content if I cancel?',
        'You\'ll keep any purchased cosmetics and themes permanently. Premium features like exclusive game modes and tournaments will no longer be accessible after cancellation.',
      ),
      _FAQ(
        'Is there a free trial available?',
        'New users get a 3-day free trial to experience all premium features risk-free. No charges until the trial ends.',
      ),
      _FAQ(
        'Do premium subscriptions sync across devices?',
        'Yes! Your premium status and all unlocked content sync automatically across all your devices when signed in with the same Google account.',
      ),
    ];

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: TextStyle(
                color: theme.textColor,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 20),
            
            ...faqs.map((faq) => ExpansionTile(
              title: Text(
                faq.question,
                style: TextStyle(
                  color: theme.textColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    faq.answer,
                    style: TextStyle(
                      color: theme.textColor.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
              iconColor: theme.textColor,
              collapsedIconColor: theme.textColor.withValues(alpha: 0.7),
            )).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildCTASection(GameTheme theme, PremiumProvider premiumProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _startFreeTrial,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.accentColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Start 3-Day Free Trial',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _purchaseBattlePass,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.accentColor,
                      side: BorderSide(color: theme.accentColor, width: 2),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Get Battle Pass',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'No commitment • Cancel anytime • Secure payment',
              style: TextStyle(
                color: theme.textColor.withValues(alpha: 0.6),
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _startFreeTrial() {
    // TODO: Implement free trial purchase flow
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

  void _purchaseBattlePass() {
    Navigator.of(context).pushNamed('/battle_pass');
  }
}

class _BenefitItem {
  final String title;
  final bool inFree;
  final bool inPremium;
  final String icon;

  _BenefitItem(this.title, this.inFree, this.inPremium, this.icon);
}

class _FeatureHighlight {
  final String icon;
  final String title;
  final String description;

  _FeatureHighlight(this.icon, this.title, this.description);
}

class _Testimonial {
  final String rating;
  final String text;
  final String author;

  _Testimonial(this.rating, this.text, this.author);
}

class _FAQ {
  final String question;
  final String answer;

  _FAQ(this.question, this.answer);
}

class _PremiumBackgroundPainter extends CustomPainter {
  final Color accentColor;

  _PremiumBackgroundPainter(this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = accentColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw crown pattern
    for (int i = 0; i < 15; i++) {
      final x = (i * size.width / 8) % size.width;
      final y = (i * 40.0) % size.height;
      
      // Crown shape
      final path = Path();
      path.moveTo(x - 8, y + 8);
      path.lineTo(x - 4, y - 4);
      path.lineTo(x, y + 4);
      path.lineTo(x + 4, y - 8);
      path.lineTo(x + 8, y + 4);
      path.lineTo(x + 12, y - 4);
      path.lineTo(x + 16, y + 8);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}