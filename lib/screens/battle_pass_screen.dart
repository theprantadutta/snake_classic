import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/premium_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/utils/constants.dart';

class BattlePassScreen extends StatefulWidget {
  const BattlePassScreen({super.key});

  @override
  State<BattlePassScreen> createState() => _BattlePassScreenState();
}

class _BattlePassScreenState extends State<BattlePassScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late BattlePassSeason _currentSeason;
  bool _showPremiumPreview = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentSeason = BattlePassSeason.createSampleSeason();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<PremiumProvider, ThemeProvider>(
      builder: (context, premiumProvider, themeProvider, child) {
        final theme = themeProvider.currentTheme;
        final hasBattlePass = premiumProvider.hasBattlePass;
        final currentLevel = premiumProvider.battlePassTier;
        final currentXp = premiumProvider.battlePassXP;
        
        return Scaffold(
          backgroundColor: theme.backgroundColor,
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildAppBar(theme, hasBattlePass),
              _buildSeasonInfo(theme, hasBattlePass),
              _buildProgressBar(theme, currentLevel, currentXp),
              _buildRewardTrack(theme, premiumProvider, hasBattlePass, currentLevel),
            ],
          ),
          bottomNavigationBar: !hasBattlePass ? _buildPurchaseBar(theme) : null,
        );
      },
    );
  }

  Widget _buildAppBar(GameTheme theme, bool hasBattlePass) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: _currentSeason.themeColor,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          _currentSeason.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: Offset(1, 1),
                blurRadius: 3,
                color: Colors.black54,
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _currentSeason.themeColor,
                _currentSeason.themeColor.withValues(alpha: 0.7),
                theme.backgroundColor.withValues(alpha: 0.9),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Background pattern
              Positioned.fill(
                child: CustomPaint(
                  painter: _BattlePassBackgroundPainter(_currentSeason.themeColor),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), // App bar space
                    Text(
                      _currentSeason.description,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        shadows: [
                          Shadow(
                            offset: Offset(1, 1),
                            blurRadius: 3,
                            color: Colors.black54,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: hasBattlePass ? Colors.amber : Colors.grey,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        hasBattlePass ? 'PREMIUM' : 'FREE',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(_showPremiumPreview ? Icons.visibility_off : Icons.visibility),
          onPressed: () {
            setState(() {
              _showPremiumPreview = !_showPremiumPreview;
            });
          },
          tooltip: _showPremiumPreview ? 'Hide Premium Preview' : 'Show Premium Preview',
        ),
      ],
    );
  }

  Widget _buildSeasonInfo(GameTheme theme, bool hasBattlePass) {
    final timeRemaining = _currentSeason.timeRemaining;
    final daysLeft = timeRemaining.inDays;
    final hoursLeft = timeRemaining.inHours % 24;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _currentSeason.themeColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Season Progress',
                    style: TextStyle(
                      color: theme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Season ends in $daysLeft days, $hoursLeft hours',
                    style: TextStyle(
                      color: theme.textColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _currentSeason.themeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentSeason.maxLevel} Tiers',
                style: TextStyle(
                  color: _currentSeason.themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(GameTheme theme, int currentLevel, int currentXp) {
    final nextLevel = currentLevel + 1;
    final nextLevelData = _currentSeason.getLevelData(nextLevel);
    
    final xpForCurrentLevel = _currentSeason.getTotalXpForLevel(currentLevel);
    final xpForNextLevel = nextLevelData?.xpRequired ?? 0;
    final progressInLevel = xpForNextLevel > 0 
        ? ((currentXp - xpForCurrentLevel) / xpForNextLevel).clamp(0.0, 1.0)
        : 1.0;

    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.cardColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tier $currentLevel',
                  style: TextStyle(
                    color: theme.textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                  ),
                ),
                Text(
                  '$currentXp XP',
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.7),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Progress bar
            Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.textColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progressInLevel,
                  child: Container(
                    height: 8,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          _currentSeason.themeColor,
                          _currentSeason.themeColor.withValues(alpha: 0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (nextLevelData != null)
              Text(
                '${(currentXp - xpForCurrentLevel).clamp(0, xpForNextLevel)} / $xpForNextLevel XP to next tier',
                style: TextStyle(
                  color: theme.textColor.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              )
            else
              Text(
                'Max tier reached!',
                style: TextStyle(
                  color: Colors.amber,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardTrack(GameTheme theme, PremiumProvider premiumProvider, 
      bool hasBattlePass, int currentLevel) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final level = index + 1;
          final levelData = _currentSeason.getLevelData(level);
          if (levelData == null) return null;
          
          final isUnlocked = level <= currentLevel;
          final isNextLevel = level == currentLevel + 1;
          
          return Container(
            margin: EdgeInsets.fromLTRB(16, index == 0 ? 16 : 8, 16, 8),
            decoration: BoxDecoration(
              color: theme.cardColor.withValues(alpha: isUnlocked ? 0.4 : 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isNextLevel 
                    ? _currentSeason.themeColor
                    : theme.accentColor.withValues(alpha: 0.3),
                width: isNextLevel ? 2 : 1,
              ),
            ),
            child: _buildLevelRow(
              theme, 
              levelData, 
              isUnlocked, 
              isNextLevel, 
              hasBattlePass || _showPremiumPreview,
            ),
          );
        },
        childCount: _currentSeason.maxLevel,
      ),
    );
  }

  Widget _buildLevelRow(GameTheme theme, BattlePassLevel levelData, 
      bool isUnlocked, bool isNextLevel, bool showPremiumRewards) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Level indicator
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isUnlocked 
                  ? _currentSeason.themeColor 
                  : theme.textColor.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: levelData.isMilestone
                  ? Border.all(color: Colors.amber, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '${levelData.level}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: levelData.isMilestone ? 18 : 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          
          // Rewards
          Expanded(
            child: Row(
              children: [
                // Free reward
                if (levelData.freeReward != null) ...[
                  Expanded(
                    child: _buildRewardCard(
                      theme,
                      levelData.freeReward!,
                      isUnlocked,
                      BattlePassTier.free,
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                
                // Premium reward
                if (levelData.premiumReward != null) ...[
                  Expanded(
                    child: _buildRewardCard(
                      theme,
                      levelData.premiumReward!,
                      isUnlocked && showPremiumRewards,
                      BattlePassTier.premium,
                      showLocked: !showPremiumRewards,
                    ),
                  ),
                ] else if (levelData.freeReward != null) ...[
                  // Empty premium slot
                  Expanded(
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: theme.textColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3),
                          style: BorderStyle.none,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Premium',
                          style: TextStyle(
                            color: theme.textColor.withValues(alpha: 0.4),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardCard(GameTheme theme, BattlePassReward reward, 
      bool isUnlocked, BattlePassTier tier, {bool showLocked = false}) {
    final isPremium = tier == BattlePassTier.premium;
    
    return Container(
      height: 60,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isPremium 
            ? Colors.amber.withValues(alpha: isUnlocked ? 0.3 : 0.1)
            : theme.textColor.withValues(alpha: isUnlocked ? 0.2 : 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPremium ? Colors.amber : Colors.grey,
          width: reward.isSpecial ? 2 : 1,
        ),
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Text(
                reward.icon,
                style: TextStyle(
                  fontSize: 20,
                  color: isUnlocked ? null : theme.textColor.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      reward.name,
                      style: TextStyle(
                        color: isUnlocked 
                            ? theme.textColor 
                            : theme.textColor.withValues(alpha: 0.5),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (reward.quantity > 1)
                      Text(
                        '×${reward.quantity}',
                        style: TextStyle(
                          color: isUnlocked 
                              ? theme.textColor.withValues(alpha: 0.7)
                              : theme.textColor.withValues(alpha: 0.3),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          
          // Lock overlay
          if (showLocked || (!isUnlocked && isPremium))
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.lock,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          
          // Special reward indicator
          if (reward.isSpecial)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 8,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPurchaseBar(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Unlock Premium Battle Pass',
                    style: TextStyle(
                      color: theme.textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Get access to premium rewards',
                    style: TextStyle(
                      color: theme.textColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: _purchaseBattlePass,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentSeason.themeColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                '\$${_currentSeason.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _purchaseBattlePass() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Purchase Battle Pass'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Unlock ${_currentSeason.name} premium rewards?'),
            const SizedBox(height: 16),
            Text(
              'Price: \$${_currentSeason.price.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
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
              _handleBattlePassPurchase();
            },
            child: const Text('Purchase'),
          ),
        ],
      ),
    );
  }

  void _handleBattlePassPurchase() {
    // TODO: Implement actual purchase through PurchaseService
    final purchaseService = PurchaseService();
    final product = purchaseService.getProduct(ProductIds.battlePass);
    
    if (product != null) {
      purchaseService.buyProduct(product);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Battle Pass product not available'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _BattlePassBackgroundPainter extends CustomPainter {
  final Color themeColor;

  _BattlePassBackgroundPainter(this.themeColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = themeColor.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw decorative patterns
    for (int i = 0; i < 20; i++) {
      final x = (i * size.width / 10) % size.width;
      final y = (i * 30.0) % size.height;
      
      canvas.drawCircle(
        Offset(x, y),
        2.0 + (i % 3),
        paint,
      );
    }

    // Draw connecting lines
    final linePaint = Paint()
      ..color = themeColor.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (int i = 0; i < 10; i++) {
      canvas.drawLine(
        Offset(0, i * size.height / 10),
        Offset(size.width, (i + 1) * size.height / 10),
        linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}