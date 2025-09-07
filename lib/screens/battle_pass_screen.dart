import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:snake_classic/providers/premium_provider.dart';
import 'package:snake_classic/providers/theme_provider.dart';
import 'package:snake_classic/services/purchase_service.dart';
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/widgets/app_background.dart';

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
          body: AppBackground(
            theme: theme,
            child: SafeArea(
              child: Column(
                children: [
                  // Header
                  _buildHeader(theme, hasBattlePass),

                  // Season info header
                  _buildSeasonInfoHeader(theme, hasBattlePass),

                  // Progress bar
                  _buildProgressSection(theme, currentLevel, currentXp),

                  // Reward track
                  Expanded(
                    child: _buildRewardTrackList(theme, premiumProvider, hasBattlePass, currentLevel),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: !hasBattlePass ? _buildPurchaseBar(theme) : null,
        );
      },
    );
  }

  Widget _buildHeader(GameTheme theme, bool hasBattlePass) {
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
            Icons.timeline,
            color: theme.accentColor,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Battle Pass',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: theme.accentColor,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {
              setState(() {
                _showPremiumPreview = !_showPremiumPreview;
              });
            },
            icon: Icon(
              _showPremiumPreview ? Icons.visibility_off : Icons.visibility,
              color: theme.accentColor.withValues(alpha: 0.7),
              size: 24,
            ),
            tooltip: _showPremiumPreview ? 'Hide Premium Preview' : 'Show Premium Preview',
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonInfoHeader(GameTheme theme, bool hasBattlePass) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _currentSeason.themeColor.withValues(alpha: 0.2),
              _currentSeason.themeColor.withValues(alpha: 0.1),
              theme.accentColor.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _currentSeason.themeColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _currentSeason.themeColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.timeline,
                    color: _currentSeason.themeColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Season',
                        style: TextStyle(
                          color: theme.accentColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _currentSeason.name,
                        style: TextStyle(
                          color: theme.accentColor,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: hasBattlePass ? Colors.amber : Colors.grey.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    hasBattlePass ? 'PREMIUM' : 'FREE',
                    style: TextStyle(
                      color: hasBattlePass ? Colors.white : theme.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _currentSeason.description,
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.8),
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(GameTheme theme, int currentLevel, int currentXp) {
    final nextLevel = currentLevel + 1;
    final nextLevelData = _currentSeason.getLevelData(nextLevel);
    
    final xpForCurrentLevel = _currentSeason.getTotalXpForLevel(currentLevel);
    final xpForNextLevel = nextLevelData?.xpRequired ?? 0;
    final progressInLevel = xpForNextLevel > 0 
        ? ((currentXp - xpForCurrentLevel) / xpForNextLevel).clamp(0.0, 1.0)
        : 1.0;

    final timeRemaining = _currentSeason.timeRemaining;
    final daysLeft = timeRemaining.inDays;
    final hoursLeft = timeRemaining.inHours % 24;

    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _currentSeason.themeColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // Level and XP header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tier $currentLevel',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$currentXp XP earned',
                      style: TextStyle(
                        color: theme.accentColor.withValues(alpha: 0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Season ends in',
                      style: TextStyle(
                        color: theme.accentColor.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$daysLeft days, $hoursLeft hours',
                      style: TextStyle(
                        color: _currentSeason.themeColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Progress bar
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Progress to Tier $nextLevel',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${(progressInLevel * 100).toInt()}%',
                      style: TextStyle(
                        color: _currentSeason.themeColor,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progressInLevel,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            _currentSeason.themeColor,
                            _currentSeason.themeColor.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRewardTrackList(GameTheme theme, PremiumProvider premiumProvider, 
      bool hasBattlePass, int currentLevel) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _currentSeason.maxLevel,
      itemBuilder: (context, index) {
        final level = index + 1;
        final levelData = _currentSeason.getLevelData(level);
        if (levelData == null) return const SizedBox.shrink();
        
        final isUnlocked = level <= currentLevel;
        final isNextLevel = level == currentLevel + 1;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.accentColor.withValues(alpha: isUnlocked ? 0.15 : 0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isNextLevel 
                  ? _currentSeason.themeColor
                  : isUnlocked
                      ? Colors.green.withValues(alpha: 0.4)
                      : theme.accentColor.withValues(alpha: 0.2),
              width: isNextLevel ? 2 : 1,
            ),
            boxShadow: isNextLevel ? [
              BoxShadow(
                color: _currentSeason.themeColor.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ] : null,
          ),
          child: _buildLevelRow(
            theme, 
            levelData, 
            isUnlocked, 
            isNextLevel, 
            hasBattlePass || _showPremiumPreview,
            premiumProvider,
            level,
          ),
        );
      },
    );
  }

  Widget _buildLevelRow(GameTheme theme, BattlePassLevel levelData, 
      bool isUnlocked, bool isNextLevel, bool showPremiumRewards, 
      PremiumProvider premiumProvider, int level) {
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
                      premiumProvider,
                      level,
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
                      premiumProvider,
                      level,
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
      bool isUnlocked, BattlePassTier tier, PremiumProvider premiumProvider, 
      int level, {bool showLocked = false}) {
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
          
          // Claim button for unlocked, unclaimed rewards
          if (isUnlocked && !showLocked && _canClaimReward(premiumProvider, reward, level, tier))
            Positioned(
              right: 4,
              top: 4,
              child: GestureDetector(
                onTap: () => _claimReward(premiumProvider, reward, level, tier),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.download,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
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

  bool _canClaimReward(PremiumProvider premiumProvider, BattlePassReward reward, int level, BattlePassTier tier) {
    // Check if reward is already claimed
    // This would need to be implemented in PremiumProvider to check claimed rewards
    // For now, assume all unlocked rewards can be claimed
    return true; // TODO: Implement proper claimed reward checking
  }

  Future<void> _claimReward(PremiumProvider premiumProvider, BattlePassReward reward, int level, BattlePassTier tier) async {
    try {
      final rewardData = {
        'type': reward.type.name,
        'itemId': reward.itemId,
        'quantity': reward.quantity,
        'tier': tier.name,
        'level': level,
      };

      final success = await premiumProvider.claimBattlePassReward(reward.id, rewardData);
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${reward.name} claimed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh the UI
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to claim reward'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error claiming reward: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

