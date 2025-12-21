import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
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
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;

        return BlocBuilder<BattlePassCubit, BattlePassState>(
          builder: (context, battlePassState) {
            final hasBattlePass = battlePassState.isActive;
            final currentLevel = battlePassState.currentTier;
            final currentXp = battlePassState.currentXP;

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
                        child: _buildRewardTrackList(
                          theme,
                          battlePassState,
                          hasBattlePass,
                          currentLevel,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: !hasBattlePass ? _buildPurchaseBar(theme) : null,
            );
          },
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
            icon: Icon(Icons.arrow_back, color: theme.accentColor, size: 24),
          ),
          const SizedBox(width: 8),
          Icon(Icons.timeline, color: theme.accentColor, size: 28),
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
            tooltip: _showPremiumPreview
                ? 'Hide Premium Preview'
                : 'Show Premium Preview',
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonInfoHeader(GameTheme theme, bool hasBattlePass) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _currentSeason.themeColor.withValues(alpha: 0.15),
            _currentSeason.themeColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _currentSeason.themeColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: _currentSeason.themeColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _currentSeason.themeColor,
                  _currentSeason.themeColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _currentSeason.themeColor.withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(Icons.timeline, color: Colors.white, size: 24),
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
                        _currentSeason.name,
                        style: TextStyle(
                          color: theme.accentColor,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: hasBattlePass
                              ? [Colors.amber, Colors.orange]
                              : [Colors.grey, Colors.grey.shade600],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        hasBattlePass ? 'PREMIUM' : 'FREE',
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
                  _currentSeason.description,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(
    GameTheme theme,
    int currentLevel,
    int currentXp,
  ) {
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.accentColor.withValues(alpha: 0.15),
            theme.accentColor.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.accentColor.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Tier info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'TIER',
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                Text(
                  '$currentLevel',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Progress info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Next Tier Progress',
                      style: TextStyle(
                        color: theme.accentColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
                  height: 6,
                  decoration: BoxDecoration(
                    color: theme.backgroundColor.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
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
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: [
                          BoxShadow(
                            color: _currentSeason.themeColor.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Season ends: ${daysLeft}d ${hoursLeft}h',
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.6),
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

  Widget _buildRewardTrackList(
    GameTheme theme,
    BattlePassState battlePassState,
    bool hasBattlePass,
    int currentLevel,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _currentSeason.maxLevel,
      itemBuilder: (context, index) {
        final level = index + 1;
        final levelData = _currentSeason.getLevelData(level);
        if (levelData == null) return const SizedBox.shrink();

        final isUnlocked = level <= currentLevel;
        final isNextLevel = level == currentLevel + 1;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isNextLevel
                  ? [
                      _currentSeason.themeColor.withValues(alpha: 0.2),
                      _currentSeason.themeColor.withValues(alpha: 0.1),
                    ]
                  : isUnlocked
                  ? [
                      Colors.green.withValues(alpha: 0.15),
                      Colors.green.withValues(alpha: 0.08),
                    ]
                  : [
                      theme.accentColor.withValues(alpha: 0.1),
                      theme.accentColor.withValues(alpha: 0.05),
                    ],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isNextLevel
                  ? _currentSeason.themeColor
                  : isUnlocked
                  ? Colors.green.withValues(alpha: 0.4)
                  : theme.accentColor.withValues(alpha: 0.2),
              width: isNextLevel ? 2 : 1,
            ),
            boxShadow: isNextLevel
                ? [
                    BoxShadow(
                      color: _currentSeason.themeColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: _buildLevelRow(
            theme,
            levelData,
            isUnlocked,
            isNextLevel,
            hasBattlePass || _showPremiumPreview,
            level,
          ),
        );
      },
    );
  }

  Widget _buildLevelRow(
    GameTheme theme,
    BattlePassLevel levelData,
    bool isUnlocked,
    bool isNextLevel,
    bool showPremiumRewards,
    int level,
  ) {
    return Row(
      children: [
        // Level indicator
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      _currentSeason.themeColor,
                      _currentSeason.themeColor.withValues(alpha: 0.8),
                    ],
                  )
                : LinearGradient(
                    colors: [
                      theme.accentColor.withValues(alpha: 0.3),
                      theme.accentColor.withValues(alpha: 0.2),
                    ],
                  ),
            shape: BoxShape.circle,
            border: levelData.isMilestone
                ? Border.all(color: Colors.amber, width: 2)
                : null,
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: _currentSeason.themeColor.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              '${levelData.level}',
              style: TextStyle(
                color: isUnlocked ? Colors.white : theme.accentColor,
                fontWeight: FontWeight.bold,
                fontSize: levelData.isMilestone ? 16 : 14,
                shadows: isUnlocked
                    ? null
                    : [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

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
    );
  }

  Widget _buildRewardCard(
    GameTheme theme,
    BattlePassReward reward,
    bool isUnlocked,
    BattlePassTier tier,
    int level, {
    bool showLocked = false,
  }) {
    final isPremium = tier == BattlePassTier.premium;

    return Container(
      height: 56,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isPremium
              ? isUnlocked
                    ? [
                        Colors.amber.withValues(alpha: 0.25),
                        Colors.orange.withValues(alpha: 0.15),
                      ]
                    : [
                        Colors.amber.withValues(alpha: 0.1),
                        Colors.orange.withValues(alpha: 0.05),
                      ]
              : isUnlocked
              ? [
                  theme.accentColor.withValues(alpha: 0.2),
                  theme.accentColor.withValues(alpha: 0.1),
                ]
              : [
                  Colors.grey.withValues(alpha: 0.1),
                  Colors.grey.withValues(alpha: 0.05),
                ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isPremium
              ? isUnlocked
                    ? Colors.amber
                    : Colors.amber.withValues(alpha: 0.3)
              : isUnlocked
              ? theme.accentColor.withValues(alpha: 0.4)
              : Colors.grey.withValues(alpha: 0.3),
          width: reward.isSpecial ? 2 : 1,
        ),
        boxShadow: isUnlocked && reward.isSpecial
            ? [
                BoxShadow(
                  color: (isPremium ? Colors.amber : theme.accentColor)
                      .withValues(alpha: 0.3),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Stack(
        children: [
          Row(
            children: [
              Text(
                reward.icon,
                style: TextStyle(
                  fontSize: 20,
                  color: isUnlocked
                      ? null
                      : theme.accentColor.withValues(alpha: 0.4),
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
                            ? theme.accentColor
                            : theme.accentColor.withValues(alpha: 0.5),
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
                              ? theme.accentColor.withValues(alpha: 0.7)
                              : theme.accentColor.withValues(alpha: 0.3),
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          // Claim button for unlocked, unclaimed rewards
          if (isUnlocked &&
              !showLocked &&
              _canClaimReward(reward, level, tier))
            Positioned(
              right: 4,
              top: 4,
              child: GestureDetector(
                onTap: () => _claimReward(reward, level, tier),
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
                  child: Icon(Icons.lock, color: Colors.white, size: 16),
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
                child: const Icon(Icons.star, color: Colors.white, size: 8),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPurchaseBar(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.backgroundColor.withValues(alpha: 0.95),
            theme.backgroundColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, -3),
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
                      color: theme.accentColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'Get access to premium rewards',
                    style: TextStyle(
                      color: theme.accentColor.withValues(alpha: 0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _currentSeason.themeColor,
                    _currentSeason.themeColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: _currentSeason.themeColor.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _purchaseBattlePass,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

  void _handleBattlePassPurchase() async {
    final purchaseService = PurchaseService();
    final battlePassCubit = context.read<BattlePassCubit>();

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              ),
              SizedBox(width: 12),
              Text('Processing Battle Pass purchase...'),
            ],
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );

      await purchaseService.purchaseProduct(ProductIds.battlePass);
      await battlePassCubit.activate();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Battle Pass purchased successfully! ✓'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {}); // Refresh UI
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Battle Pass purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _canClaimReward(
    BattlePassReward reward,
    int level,
    BattlePassTier tier,
  ) {
    final battlePassState = context.read<BattlePassCubit>().state;
    if (tier == BattlePassTier.free) {
      return !battlePassState.isFreeTierClaimed(level);
    } else {
      return !battlePassState.isPremiumTierClaimed(level);
    }
  }

  Future<void> _claimReward(
    BattlePassReward reward,
    int level,
    BattlePassTier tier,
  ) async {
    try {
      final battlePassCubit = context.read<BattlePassCubit>();

      bool success;
      if (tier == BattlePassTier.free) {
        success = await battlePassCubit.claimFreeReward(level);
      } else {
        success = await battlePassCubit.claimPremiumReward(level);
      }

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
