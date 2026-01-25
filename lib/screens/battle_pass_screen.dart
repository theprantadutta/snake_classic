import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
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
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late BattlePassSeason _currentSeason;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _currentSeason = BattlePassSeason.createSampleSeason();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    // Initialize battle pass cubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BattlePassCubit>().initialize();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;

        return BlocBuilder<BattlePassCubit, BattlePassState>(
          builder: (context, battlePassState) {
            final hasPremium = battlePassState.isActive;
            final currentLevel = battlePassState.currentTier;
            final currentXp = battlePassState.currentXP;
            final xpForNext = battlePassState.xpForNextTier;

            return Scaffold(
              body: AppBackground(
                theme: theme,
                child: SafeArea(
                  child: Column(
                    children: [
                      _buildHeader(context, theme),
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              _buildSeasonBanner(theme, hasPremium),
                              _buildProgressCard(
                                theme,
                                currentLevel,
                                currentXp,
                                xpForNext,
                              ),
                              _buildRewardTrack(
                                theme,
                                battlePassState,
                                hasPremium,
                                currentLevel,
                              ),
                              const SizedBox(height: 100),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: !hasPremium
                  ? _buildPremiumCTA(theme)
                  : null,
            );
          },
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, GameTheme theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            style: IconButton.styleFrom(
              backgroundColor: theme.accentColor.withValues(alpha: 0.1),
            ),
            icon: Icon(Icons.arrow_back_ios_new_rounded,
                color: theme.accentColor, size: 20),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                _currentSeason.themeColor,
                _currentSeason.themeColor.withValues(alpha: 0.7),
                Colors.amber,
              ],
            ).createShader(bounds),
            child: const Text(
              'BATTLE PASS',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.accentColor.withValues(alpha: 0.15),
                  theme.accentColor.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.timer_outlined,
                    color: theme.accentColor.withValues(alpha: 0.8), size: 16),
                const SizedBox(width: 6),
                Text(
                  '${_currentSeason.timeRemaining.inDays}d left',
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonBanner(GameTheme theme, bool hasPremium) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _currentSeason.themeColor.withValues(alpha: 0.25),
                _currentSeason.themeColor.withValues(alpha: 0.1),
                theme.backgroundColor.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _currentSeason.themeColor.withValues(
                alpha: 0.3 + (_glowController.value * 0.2),
              ),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _currentSeason.themeColor.withValues(
                  alpha: 0.2 + (_glowController.value * 0.1),
                ),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Season icon with glow
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _currentSeason.themeColor,
                      _currentSeason.themeColor.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _currentSeason.themeColor.withValues(alpha: 0.5),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '🐍',
                    style: TextStyle(fontSize: 32),
                  ),
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
                            _currentSeason.name.toUpperCase(),
                            style: TextStyle(
                              color: theme.accentColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                        _buildPassTypeBadge(hasPremium),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _currentSeason.description,
                      style: TextStyle(
                        color: theme.accentColor.withValues(alpha: 0.7),
                        fontSize: 13,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildSeasonStat(
                          Icons.layers_outlined,
                          '${_currentSeason.maxLevel} Tiers',
                          theme,
                        ),
                        const SizedBox(width: 16),
                        _buildSeasonStat(
                          Icons.card_giftcard_outlined,
                          '${_currentSeason.levels.where((l) => l.premiumReward != null).length} Premium',
                          theme,
                        ),
                      ],
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

  Widget _buildPassTypeBadge(bool hasPremium) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: hasPremium
                  ? [Colors.amber, Colors.orange.shade600]
                  : [Colors.grey.shade600, Colors.grey.shade700],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: hasPremium
                ? [
                    BoxShadow(
                      color: Colors.amber.withValues(
                        alpha: 0.3 + (_pulseController.value * 0.2),
                      ),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                hasPremium ? Icons.workspace_premium : Icons.lock_open,
                color: Colors.white,
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                hasPremium ? 'PREMIUM' : 'FREE',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSeasonStat(IconData icon, String text, GameTheme theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: theme.accentColor.withValues(alpha: 0.6), size: 14),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: theme.accentColor.withValues(alpha: 0.7),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    GameTheme theme,
    int currentLevel,
    int currentXp,
    int xpForNext,
  ) {
    final progress = xpForNext > 0 ? (currentXp / xpForNext).clamp(0.0, 1.0) : 1.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.backgroundColor.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Current tier display
              _buildTierBadge(currentLevel, theme),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Level Progress',
                          style: TextStyle(
                            color: theme.accentColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _currentSeason.themeColor.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '$currentXp / $xpForNext XP',
                            style: TextStyle(
                              color: _currentSeason.themeColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    Stack(
                      children: [
                        Container(
                          height: 10,
                          decoration: BoxDecoration(
                            color: theme.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeOut,
                          height: 10,
                          width: (MediaQuery.of(context).size.width - 180) * progress,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                _currentSeason.themeColor,
                                _currentSeason.themeColor.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: [
                              BoxShadow(
                                color: _currentSeason.themeColor.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTierBadge(int level, GameTheme theme) {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          width: 65,
          height: 65,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                _currentSeason.themeColor,
                _currentSeason.themeColor.withValues(alpha: 0.7),
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: _currentSeason.themeColor.withValues(
                  alpha: 0.3 + (_glowController.value * 0.2),
                ),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'TIER',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1,
                ),
              ),
              Text(
                '$level',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  height: 1,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRewardTrack(
    GameTheme theme,
    BattlePassState battlePassState,
    bool hasPremium,
    int currentLevel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _currentSeason.themeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'REWARD TRACK',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
              const Spacer(),
              Text(
                '$currentLevel/${_currentSeason.maxLevel}',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        // Horizontal scrolling reward track
        SizedBox(
          height: 200,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _currentSeason.maxLevel,
            itemBuilder: (context, index) {
              final level = index + 1;
              final levelData = _currentSeason.getLevelData(level);
              if (levelData == null) return const SizedBox.shrink();

              final isUnlocked = level <= currentLevel;
              final isNext = level == currentLevel + 1;
              final isCurrent = level == currentLevel;

              return _buildRewardTile(
                theme,
                levelData,
                isUnlocked,
                isNext,
                isCurrent,
                hasPremium,
                battlePassState,
              );
            },
          ),
        ),
        // Vertical list for all tiers
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: _currentSeason.themeColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'ALL TIERS',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _currentSeason.maxLevel,
          itemBuilder: (context, index) {
            final level = index + 1;
            final levelData = _currentSeason.getLevelData(level);
            if (levelData == null) return const SizedBox.shrink();

            final isUnlocked = level <= currentLevel;
            final isNext = level == currentLevel + 1;

            return _buildTierRow(
              theme,
              levelData,
              isUnlocked,
              isNext,
              hasPremium,
              battlePassState,
            );
          },
        ),
      ],
    );
  }

  Widget _buildRewardTile(
    GameTheme theme,
    BattlePassLevel levelData,
    bool isUnlocked,
    bool isNext,
    bool isCurrent,
    bool hasPremium,
    BattlePassState battlePassState,
  ) {
    final hasReward = levelData.freeReward != null || levelData.premiumReward != null;
    if (!hasReward) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: isNext ? _pulseController : const AlwaysStoppedAnimation(0),
      builder: (context, child) {
        return Container(
          width: 130,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isNext
                  ? [
                      _currentSeason.themeColor.withValues(alpha: 0.3),
                      _currentSeason.themeColor.withValues(alpha: 0.1),
                    ]
                  : isUnlocked
                      ? [
                          Colors.green.withValues(alpha: 0.2),
                          Colors.green.withValues(alpha: 0.05),
                        ]
                      : [
                          theme.accentColor.withValues(alpha: 0.1),
                          theme.accentColor.withValues(alpha: 0.03),
                        ],
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isNext
                  ? _currentSeason.themeColor.withValues(
                      alpha: 0.5 + (_pulseController.value * 0.3),
                    )
                  : isUnlocked
                      ? Colors.green.withValues(alpha: 0.4)
                      : theme.accentColor.withValues(alpha: 0.15),
              width: isNext ? 2 : 1,
            ),
            boxShadow: isNext
                ? [
                    BoxShadow(
                      color: _currentSeason.themeColor.withValues(
                        alpha: 0.2 + (_pulseController.value * 0.15),
                      ),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              // Level header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? _currentSeason.themeColor.withValues(alpha: 0.3)
                      : theme.accentColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(15),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (levelData.isMilestone)
                      const Padding(
                        padding: EdgeInsets.only(right: 4),
                        child: Icon(Icons.star, color: Colors.amber, size: 14),
                      ),
                    Text(
                      'TIER ${levelData.level}',
                      style: TextStyle(
                        color: isUnlocked
                            ? Colors.white
                            : theme.accentColor.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (isUnlocked)
                      const Padding(
                        padding: EdgeInsets.only(left: 4),
                        child: Icon(Icons.check_circle, color: Colors.white, size: 14),
                      ),
                  ],
                ),
              ),
              // Rewards
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (levelData.freeReward != null)
                        _buildMiniRewardCard(
                          levelData.freeReward!,
                          isUnlocked,
                          false,
                          theme,
                          levelData.level,
                          battlePassState,
                        ),
                      if (levelData.premiumReward != null)
                        _buildMiniRewardCard(
                          levelData.premiumReward!,
                          isUnlocked && hasPremium,
                          true,
                          theme,
                          levelData.level,
                          battlePassState,
                          locked: !hasPremium,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMiniRewardCard(
    BattlePassReward reward,
    bool isUnlocked,
    bool isPremium,
    GameTheme theme,
    int level,
    BattlePassState battlePassState, {
    bool locked = false,
  }) {
    final isClaimed = isPremium
        ? battlePassState.isPremiumTierClaimed(level)
        : battlePassState.isFreeTierClaimed(level);
    final canClaim = isUnlocked && !isClaimed && !locked;

    return GestureDetector(
      onTap: canClaim ? () => _claimReward(reward, level, isPremium ? BattlePassTier.premium : BattlePassTier.free) : null,
      child: Container(
        height: 55,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPremium
                ? [
                    Colors.amber.withValues(alpha: isUnlocked ? 0.25 : 0.1),
                    Colors.orange.withValues(alpha: isUnlocked ? 0.15 : 0.05),
                  ]
                : [
                    theme.accentColor.withValues(alpha: isUnlocked ? 0.2 : 0.1),
                    theme.accentColor.withValues(alpha: isUnlocked ? 0.1 : 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: canClaim
                ? Colors.green
                : isPremium
                    ? Colors.amber.withValues(alpha: 0.4)
                    : theme.accentColor.withValues(alpha: 0.2),
            width: canClaim ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Text(reward.icon, style: TextStyle(fontSize: locked ? 14 : 18)),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        reward.name,
                        style: TextStyle(
                          color: locked
                              ? theme.accentColor.withValues(alpha: 0.4)
                              : theme.accentColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        isPremium ? 'Premium' : 'Free',
                        style: TextStyle(
                          color: isPremium
                              ? Colors.amber.withValues(alpha: 0.8)
                              : theme.accentColor.withValues(alpha: 0.5),
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (locked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white54, size: 16),
                  ),
                ),
              ),
            if (isClaimed)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 10),
                ),
              ),
            if (canClaim)
              Positioned(
                right: 2,
                top: 2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'CLAIM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTierRow(
    GameTheme theme,
    BattlePassLevel levelData,
    bool isUnlocked,
    bool isNext,
    bool hasPremium,
    BattlePassState battlePassState,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isNext
              ? [
                  _currentSeason.themeColor.withValues(alpha: 0.2),
                  _currentSeason.themeColor.withValues(alpha: 0.05),
                ]
              : isUnlocked
                  ? [
                      Colors.green.withValues(alpha: 0.15),
                      Colors.green.withValues(alpha: 0.03),
                    ]
                  : [
                      theme.accentColor.withValues(alpha: 0.08),
                      theme.accentColor.withValues(alpha: 0.02),
                    ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isNext
              ? _currentSeason.themeColor.withValues(alpha: 0.5)
              : isUnlocked
                  ? Colors.green.withValues(alpha: 0.3)
                  : theme.accentColor.withValues(alpha: 0.1),
          width: isNext ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Level indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: isUnlocked
                  ? LinearGradient(colors: [
                      _currentSeason.themeColor,
                      _currentSeason.themeColor.withValues(alpha: 0.7),
                    ])
                  : null,
              color: isUnlocked ? null : theme.accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: levelData.isMilestone
                  ? Border.all(color: Colors.amber, width: 2)
                  : null,
            ),
            child: Center(
              child: Text(
                '${levelData.level}',
                style: TextStyle(
                  color: isUnlocked ? Colors.white : theme.accentColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Rewards
          Expanded(
            child: Row(
              children: [
                if (levelData.freeReward != null)
                  Expanded(
                    child: _buildRowRewardCard(
                      theme,
                      levelData.freeReward!,
                      isUnlocked,
                      false,
                      levelData.level,
                      battlePassState,
                    ),
                  ),
                if (levelData.freeReward != null && levelData.premiumReward != null)
                  const SizedBox(width: 10),
                if (levelData.premiumReward != null)
                  Expanded(
                    child: _buildRowRewardCard(
                      theme,
                      levelData.premiumReward!,
                      isUnlocked && hasPremium,
                      true,
                      levelData.level,
                      battlePassState,
                      locked: !hasPremium,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowRewardCard(
    GameTheme theme,
    BattlePassReward reward,
    bool isUnlocked,
    bool isPremium,
    int level,
    BattlePassState battlePassState, {
    bool locked = false,
  }) {
    final isClaimed = isPremium
        ? battlePassState.isPremiumTierClaimed(level)
        : battlePassState.isFreeTierClaimed(level);
    final canClaim = isUnlocked && !isClaimed && !locked;

    return GestureDetector(
      onTap: canClaim
          ? () => _claimReward(
                reward,
                level,
                isPremium ? BattlePassTier.premium : BattlePassTier.free,
              )
          : null,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isPremium
                ? [
                    Colors.amber.withValues(alpha: canClaim ? 0.3 : 0.15),
                    Colors.orange.withValues(alpha: canClaim ? 0.2 : 0.08),
                  ]
                : [
                    theme.accentColor.withValues(alpha: canClaim ? 0.25 : 0.12),
                    theme.accentColor.withValues(alpha: canClaim ? 0.15 : 0.05),
                  ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: canClaim
                ? Colors.green
                : isPremium
                    ? Colors.amber.withValues(alpha: 0.3)
                    : theme.accentColor.withValues(alpha: 0.15),
            width: canClaim ? 2 : 1,
          ),
        ),
        child: Stack(
          children: [
            Row(
              children: [
                Text(
                  reward.icon,
                  style: TextStyle(fontSize: locked ? 16 : 22),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.name,
                        style: TextStyle(
                          color: locked
                              ? theme.accentColor.withValues(alpha: 0.4)
                              : theme.accentColor,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isPremium
                                    ? Colors.amber.withValues(alpha: 0.2)
                                    : theme.accentColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                isPremium ? 'Premium' : 'Free',
                                style: TextStyle(
                                  color: isPremium
                                      ? Colors.amber
                                      : theme.accentColor.withValues(alpha: 0.7),
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          if (reward.quantity > 1) ...[
                            const SizedBox(width: 4),
                            Text(
                              '×${reward.quantity}',
                              style: TextStyle(
                                color: theme.accentColor.withValues(alpha: 0.6),
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (canClaim)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.green, Color(0xFF2E7D32)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withValues(alpha: 0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      'CLAIM',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  )
                else if (isClaimed)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 16,
                    ),
                  ),
              ],
            ),
            if (locked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: const Center(
                    child: Icon(Icons.lock, color: Colors.white60, size: 20),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumCTA(GameTheme theme) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.backgroundColor.withValues(alpha: 0),
            theme.backgroundColor,
          ],
        ),
      ),
      child: SafeArea(
        child: AnimatedBuilder(
          animation: _glowController,
          builder: (context, child) {
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.shade600,
                    Colors.orange.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withValues(
                      alpha: 0.3 + (_glowController.value * 0.2),
                    ),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _purchaseBattlePass,
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.workspace_premium,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'UNLOCK PREMIUM',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Get all exclusive rewards',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.8),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '\$${_currentSeason.price.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _purchaseBattlePass() {
    final theme = context.read<ThemeCubit>().state.currentTheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.backgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: Colors.amber.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.accentColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber, Colors.orange.shade600],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.workspace_premium,
                color: Colors.white,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Upgrade to Premium',
              style: TextStyle(
                color: theme.accentColor,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _currentSeason.name,
              style: TextStyle(
                color: _currentSeason.themeColor,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 24),
            _buildPremiumBenefit(
              Icons.card_giftcard,
              'Exclusive Premium Rewards',
              'Unlock all premium tier rewards',
              theme,
            ),
            _buildPremiumBenefit(
              Icons.palette,
              'Exclusive Themes & Skins',
              'Stand out with unique cosmetics',
              theme,
            ),
            _buildPremiumBenefit(
              Icons.bolt,
              'Bonus XP',
              'Level up faster with XP boosts',
              theme,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context.pop();
                  _handleBattlePassPurchase();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Purchase for \$${_currentSeason.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                'Maybe Later',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  Widget _buildPremiumBenefit(
    IconData icon,
    String title,
    String subtitle,
    GameTheme theme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.amber, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: theme.accentColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: theme.accentColor.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
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
        SnackBar(
          content: const Row(
            children: [
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: 14),
              Text('Processing purchase...'),
            ],
          ),
          backgroundColor: Colors.amber.shade700,
          duration: const Duration(seconds: 3),
        ),
      );

      await purchaseService.purchaseProduct(ProductIds.battlePass);
      await battlePassCubit.activate();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Premium Battle Pass activated!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Purchase failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
            content: Row(
              children: [
                Text(reward.icon, style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text('${reward.name} claimed!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
