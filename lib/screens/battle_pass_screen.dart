import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:snake_classic/presentation/bloc/premium/battle_pass_cubit.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
// import 'package:snake_classic/services/purchase_service.dart'; // TODO: Re-enable with purchase flow
import 'package:snake_classic/models/battle_pass.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/game_animations.dart';
import 'package:snake_classic/widgets/app_background.dart';
// import 'package:snake_classic/widgets/game_button.dart'; // TODO: Re-enable with purchase flow

// ---------------------------------------------------------------------------
// Node state enum for reward cells
// ---------------------------------------------------------------------------
enum _NodeState { locked, unlocked, claimable, claimed, premiumLocked }

// ---------------------------------------------------------------------------
// Main Screen
// ---------------------------------------------------------------------------
class BattlePassScreen extends StatefulWidget {
  const BattlePassScreen({super.key});

  @override
  State<BattlePassScreen> createState() => _BattlePassScreenState();
}

class _BattlePassScreenState extends State<BattlePassScreen> {
  late final ScrollController _scrollController;
  bool _didAutoScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _autoScrollToCurrentTier(int currentTier) {
    if (_didAutoScroll || !_scrollController.hasClients) return;
    _didAutoScroll = true;

    final screenWidth = MediaQuery.of(context).size.width;
    final offset = (currentTier * 88.0) - (screenWidth / 2) + 44;
    final maxScroll = _scrollController.position.maxScrollExtent;
    _scrollController.animateTo(
      offset.clamp(0.0, maxScroll),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  // -------------------------------------------------------------------------
  // State derivation
  // -------------------------------------------------------------------------
  _NodeState _getNodeState(
    int tier,
    bool isPremium,
    BattlePassState s,
  ) {
    if (isPremium && !s.isActive) return _NodeState.premiumLocked;
    if (tier > s.currentTier) return _NodeState.locked;
    final claimed = isPremium
        ? s.isPremiumTierClaimed(tier)
        : s.isFreeTierClaimed(tier);
    if (claimed) return _NodeState.claimed;
    return _NodeState.claimable;
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;

        return BlocBuilder<BattlePassCubit, BattlePassState>(
          builder: (context, bpState) {
            final season = bpState.season;

            // Loading state
            if (bpState.status == BattlePassStatus.loading && season == null) {
              return Scaffold(
                body: AppBackground(
                  theme: theme,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: theme.accentColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Expanded(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Empty state — no season available after loading
            if (season == null) {
              return Scaffold(
                body: AppBackground(
                  theme: theme,
                  child: SafeArea(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: theme.accentColor,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Center(
                            child: Text(
                              'No active season',
                              style: TextStyle(
                                color: theme.accentColor.withValues(alpha: 0.6),
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Trigger auto-scroll once state is ready
            if (bpState.status == BattlePassStatus.ready && !_didAutoScroll) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _autoScrollToCurrentTier(bpState.currentTier);
              });
            }

            return Scaffold(
              body: AppBackground(
                theme: theme,
                child: SafeArea(
                  child: Column(
                    children: [
                      _CompactHeader(
                        season: season,
                        theme: theme,
                      ),
                      // Coming Soon banner
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.withValues(alpha: 0.25),
                              Colors.orange.withValues(alpha: 0.15),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.construction, color: Colors.amber, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Coming Soon! Battle Pass is not yet available for purchase.',
                                style: TextStyle(
                                  color: theme.accentColor,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _SeasonStrip(
                        season: season,
                        theme: theme,
                        hasPremium: bpState.isActive,
                        currentTier: bpState.currentTier,
                      ),
                      _XpProgressBar(
                        season: season,
                        theme: theme,
                        currentLevel: bpState.currentTier,
                        currentXp: bpState.currentXP,
                        xpForNext: bpState.xpForNextTier,
                      ),
                      Expanded(
                        child: _RewardTrack(
                          season: season,
                          theme: theme,
                          bpState: bpState,
                          scrollController: _scrollController,
                          getNodeState: _getNodeState,
                          onClaim: _claimReward,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Battle Pass purchase is Coming Soon — disable CTA
              bottomNavigationBar: null,
            );
          },
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // Actions
  // -------------------------------------------------------------------------
  Future<void> _claimReward(int tier, bool isPremium) async {
    try {
      final cubit = context.read<BattlePassCubit>();
      final success = isPremium
          ? await cubit.claimPremiumReward(tier)
          : await cubit.claimFreeReward(tier);

      if (success && mounted) {
        final season = cubit.state.season;
        final levelData = season?.getLevelData(tier);
        final reward =
            isPremium ? levelData?.premiumReward : levelData?.freeReward;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Text(reward?.icon ?? '🎁',
                    style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Text('${reward?.name ?? 'Reward'} claimed!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
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

  // TODO: Re-enable when purchase flow is implemented
  // void _showPurchaseSheet(GameTheme theme, BattlePassSeason season) {
  //   showModalBottomSheet(
  //     context: context,
  //     backgroundColor: Colors.transparent,
  //     isScrollControlled: true,
  //     builder: (_) => DraggableScrollableSheet(
  //       initialChildSize: 0.75,
  //       minChildSize: 0.5,
  //       maxChildSize: 0.9,
  //       builder: (ctx, scrollCtrl) => _PurchaseSheet(
  //         season: season,
  //         theme: theme,
  //         scrollController: scrollCtrl,
  //         onPurchase: _handlePurchase,
  //         onDismiss: () => Navigator.of(ctx).pop(),
  //       ),
  //     ),
  //   );
  // }

  // TODO: Re-enable when purchase flow is implemented
  // Future<void> _handlePurchase() async {
  //   final purchaseService = PurchaseService();
  //   final cubit = context.read<BattlePassCubit>();
  //
  //   try {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: const Row(
  //           children: [
  //             SizedBox(
  //               width: 18,
  //               height: 18,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2,
  //                 color: Colors.white,
  //               ),
  //             ),
  //             SizedBox(width: 14),
  //             Text('Processing purchase...'),
  //           ],
  //         ),
  //         backgroundColor: Colors.amber.shade700,
  //         duration: const Duration(seconds: 3),
  //       ),
  //     );
  //
  //     await purchaseService.purchaseProduct(ProductIds.battlePass);
  //     await cubit.activate();
  //
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(
  //           content: Row(
  //             children: [
  //               Icon(Icons.check_circle, color: Colors.white),
  //               SizedBox(width: 12),
  //               Text('Premium Battle Pass activated!'),
  //             ],
  //           ),
  //           backgroundColor: Colors.green,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (mounted) {
  //       ScaffoldMessenger.of(context).hideCurrentSnackBar();
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: Text('Purchase failed: ${e.toString()}'),
  //           backgroundColor: Colors.red,
  //         ),
  //       );
  //     }
  //   }
  // }
}

// ===========================================================================
// 1. _CompactHeader
// ===========================================================================
class _CompactHeader extends StatelessWidget {
  final BattlePassSeason season;
  final GameTheme theme;

  const _CompactHeader({required this.season, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: theme.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => LinearGradient(
              colors: [
                theme.accentColor,
                theme.accentColor.withValues(alpha: 0.7),
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
          // Timer chip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.accentColor.withValues(alpha: 0.2),
                  theme.accentColor.withValues(alpha: 0.1),
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
                Icon(
                  Icons.timer_outlined,
                  color: theme.accentColor.withValues(alpha: 0.8),
                  size: 14,
                ),
                const SizedBox(width: 6),
                Text(
                  '${season.timeRemaining.inDays}d left',
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
    ).gameEntrance();
  }
}

// ===========================================================================
// 2. _SeasonStrip
// ===========================================================================
class _SeasonStrip extends StatelessWidget {
  final BattlePassSeason season;
  final GameTheme theme;
  final bool hasPremium;
  final int currentTier;

  const _SeasonStrip({
    required this.season,
    required this.theme,
    required this.hasPremium,
    required this.currentTier,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: theme.accentColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: theme.accentColor.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          children: [
            Text(
              season.name.toUpperCase(),
              style: TextStyle(
                color: season.themeColor,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.5,
              ),
            ),
            const Spacer(),
            // Pass type badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                gradient: hasPremium
                    ? const LinearGradient(
                        colors: [Colors.amber, Colors.orange],
                      )
                    : null,
                color: hasPremium
                    ? null
                    : theme.accentColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                hasPremium ? 'PREMIUM' : 'FREE',
                style: TextStyle(
                  color: hasPremium ? Colors.white : theme.accentColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Tier $currentTier / ${season.maxLevel}',
              style: TextStyle(
                color: theme.accentColor.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    ).gameEntrance(delay: const Duration(milliseconds: 50));
  }
}

// ===========================================================================
// 3. _XpProgressBar
// ===========================================================================
class _XpProgressBar extends StatelessWidget {
  final BattlePassSeason season;
  final GameTheme theme;
  final int currentLevel;
  final int currentXp;
  final int xpForNext;

  const _XpProgressBar({
    required this.season,
    required this.theme,
    required this.currentLevel,
    required this.currentXp,
    required this.xpForNext,
  });

  @override
  Widget build(BuildContext context) {
    final progress =
        xpForNext > 0 ? (currentXp / xpForNext).clamp(0.0, 1.0) : 1.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'LEVEL $currentLevel',
                style: TextStyle(
                  color: theme.accentColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '$currentXp / $xpForNext XP',
                style: TextStyle(
                  color: season.themeColor,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Stack(
              children: [
                // Background
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: theme.accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                // Fill
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: progress),
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                  builder: (context, value, _) {
                    return FractionallySizedBox(
                      widthFactor: value,
                      child: Container(
                        height: 8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              season.themeColor,
                              season.themeColor.withValues(alpha: 0.7),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  season.themeColor.withValues(alpha: 0.4),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    ).gameEntrance(delay: const Duration(milliseconds: 100));
  }
}

// ===========================================================================
// 4. _RewardTrack (Core Widget)
// ===========================================================================
class _RewardTrack extends StatelessWidget {
  final BattlePassSeason season;
  final GameTheme theme;
  final BattlePassState bpState;
  final ScrollController scrollController;
  final _NodeState Function(int tier, bool isPremium, BattlePassState s)
      getNodeState;
  final Future<void> Function(int tier, bool isPremium) onClaim;

  const _RewardTrack({
    required this.season,
    required this.theme,
    required this.bpState,
    required this.scrollController,
    required this.getNodeState,
    required this.onClaim,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Row labels
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 2),
          child: Row(
            children: [
              Text(
                'FREE',
                style: TextStyle(
                  color: theme.accentColor.withValues(alpha: 0.6),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                'PREMIUM',
                style: TextStyle(
                  color: Colors.amber.withValues(alpha: 0.8),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        // Scrollable track
        Expanded(
          child: Stack(
            children: [
              ListView.builder(
                controller: scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: season.maxLevel,
                itemBuilder: (context, index) {
                  final tier = index + 1;
                  return _buildTrackColumn(tier);
                },
              ),
              // Left fade
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                width: 24,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.backgroundColor,
                          theme.backgroundColor.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Right fade
              Positioned(
                right: 0,
                top: 0,
                bottom: 0,
                width: 24,
                child: IgnorePointer(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.backgroundColor.withValues(alpha: 0),
                          theme.backgroundColor,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTrackColumn(int tier) {
    final isCurrent = tier == bpState.currentTier;
    final isUnlocked = tier <= bpState.currentTier;
    final isMilestone = tier % 10 == 0;
    final levelData = season.getLevelData(tier);

    return SizedBox(
      width: isCurrent ? 96 : 88,
      child: Column(
        children: [
          // Top half: Free reward
          Expanded(
            child: _RewardNode(
              reward: levelData?.freeReward,
              state: getNodeState(tier, false, bpState),
              isPremium: false,
              tier: tier,
              theme: theme,
              season: season,
              onClaim: () => onClaim(tier, false),
            ),
          ),
          // Center: Level indicator with connecting line
          SizedBox(
            height: 36,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Horizontal connecting line
                Positioned.fill(
                  child: Center(
                    child: Container(
                      height: 2,
                      color: isUnlocked
                          ? season.themeColor
                          : theme.accentColor.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                // Level circle
                _LevelIndicator(
                  level: tier,
                  isUnlocked: isUnlocked,
                  isCurrent: isCurrent,
                  isMilestone: isMilestone,
                  theme: theme,
                  season: season,
                ),
              ],
            ),
          ),
          // Bottom half: Premium reward
          Expanded(
            child: _RewardNode(
              reward: levelData?.premiumReward,
              state: getNodeState(tier, true, bpState),
              isPremium: true,
              tier: tier,
              theme: theme,
              season: season,
              onClaim: () => onClaim(tier, true),
            ),
          ),
        ],
      ),
    );
  }
}

// ===========================================================================
// _LevelIndicator
// ===========================================================================
class _LevelIndicator extends StatelessWidget {
  final int level;
  final bool isUnlocked;
  final bool isCurrent;
  final bool isMilestone;
  final GameTheme theme;
  final BattlePassSeason season;

  const _LevelIndicator({
    required this.level,
    required this.isUnlocked,
    required this.isCurrent,
    required this.isMilestone,
    required this.theme,
    required this.season,
  });

  @override
  Widget build(BuildContext context) {
    final size = isCurrent ? 36.0 : 32.0;

    Widget indicator = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: isUnlocked
            ? LinearGradient(
                colors: [
                  season.themeColor,
                  season.themeColor.withValues(alpha: 0.7),
                ],
              )
            : null,
        color: isUnlocked ? null : theme.accentColor.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(
          color: isCurrent
              ? season.themeColor
              : isMilestone
                  ? Colors.amber
                  : isUnlocked
                      ? Colors.transparent
                      : theme.accentColor.withValues(alpha: 0.25),
          width: isCurrent || isMilestone ? 2 : 1,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            '$level',
            style: TextStyle(
              color: isUnlocked
                  ? Colors.white
                  : theme.accentColor.withValues(alpha: 0.7),
              fontSize: isCurrent ? 14 : 12,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (isMilestone)
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                Icons.star,
                color: Colors.amber,
                size: isCurrent ? 12 : 10,
              ),
            ),
        ],
      ),
    );

    if (isCurrent) {
      indicator = indicator.gameBreathe(intensity: 1.06);
    }

    return indicator;
  }
}

// ===========================================================================
// _RewardNode
// ===========================================================================
class _RewardNode extends StatefulWidget {
  final BattlePassReward? reward;
  final _NodeState state;
  final bool isPremium;
  final int tier;
  final GameTheme theme;
  final BattlePassSeason season;
  final VoidCallback onClaim;

  const _RewardNode({
    required this.reward,
    required this.state,
    required this.isPremium,
    required this.tier,
    required this.theme,
    required this.season,
    required this.onClaim,
  });

  @override
  State<_RewardNode> createState() => _RewardNodeState();
}

class _RewardNodeState extends State<_RewardNode> {
  bool _animateClaim = false;

  void _handleClaim() {
    setState(() => _animateClaim = true);
    widget.onClaim();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _animateClaim = false);
    });
  }

  BoxDecoration _buildDecoration() {
    final isPremium = widget.isPremium;
    final state = widget.state;
    final accent = widget.theme.accentColor;

    // Gradient colors — tuned for dark backgrounds (all themes are near-black)
    List<Color> gradientColors;
    switch (state) {
      case _NodeState.claimable:
        gradientColors = isPremium
            ? [
                Colors.amber.withValues(alpha: 0.25),
                Colors.orange.withValues(alpha: 0.15),
              ]
            : [
                accent.withValues(alpha: 0.25),
                accent.withValues(alpha: 0.15),
              ];
      case _NodeState.claimed:
        gradientColors = isPremium
            ? [
                Colors.amber.withValues(alpha: 0.15),
                Colors.green.withValues(alpha: 0.10),
              ]
            : [
                Colors.green.withValues(alpha: 0.2),
                Colors.green.withValues(alpha: 0.10),
              ];
      case _NodeState.premiumLocked:
        gradientColors = [
          Colors.purple.withValues(alpha: 0.18),
          Colors.indigo.withValues(alpha: 0.10),
        ];
      case _NodeState.locked:
        gradientColors = [
          accent.withValues(alpha: 0.10),
          accent.withValues(alpha: 0.06),
        ];
      case _NodeState.unlocked:
        gradientColors = [
          accent.withValues(alpha: 0.18),
          accent.withValues(alpha: 0.10),
        ];
    }

    // Border — needs to stand out against dark bg
    Color borderColor;
    double borderWidth;
    switch (state) {
      case _NodeState.claimable:
        borderColor = Colors.green.withValues(alpha: 0.9);
        borderWidth = 2;
      case _NodeState.claimed:
        borderColor = Colors.green.withValues(alpha: 0.4);
        borderWidth = 1;
      case _NodeState.premiumLocked:
        borderColor = Colors.amber.withValues(alpha: 0.35);
        borderWidth = 1;
      case _NodeState.locked:
        borderColor = accent.withValues(alpha: 0.2);
        borderWidth = 1;
      case _NodeState.unlocked:
        borderColor = accent.withValues(alpha: 0.3);
        borderWidth = 1;
    }

    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: gradientColors,
      ),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: borderColor, width: borderWidth),
    );
  }

  Widget _buildStateIndicator() {
    switch (widget.state) {
      case _NodeState.claimable:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Colors.green, Color(0xFF2E7D32)],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Text(
            'CLAIM',
            style: TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ).gameBreathe(intensity: 1.03);
      case _NodeState.claimed:
        return Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Colors.green,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.white, size: 14),
        );
      case _NodeState.premiumLocked:
        return Icon(
          Icons.lock,
          color: Colors.amber.withValues(alpha: 0.7),
          size: 16,
        );
      case _NodeState.locked:
        return Icon(
          Icons.lock,
          color: widget.theme.accentColor.withValues(alpha: 0.5),
          size: 14,
        );
      case _NodeState.unlocked:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reward = widget.reward;

    // Empty slot
    if (reward == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: widget.theme.accentColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: widget.theme.accentColor.withValues(alpha: 0.12),
          ),
        ),
      );
    }

    final canClaim = widget.state == _NodeState.claimable;

    Widget node = GestureDetector(
      onTap: canClaim ? _handleClaim : null,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 1.0, end: _animateClaim ? 0.9 : 1.0),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, scale, child) {
          return Transform.scale(scale: scale, child: child);
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          padding: const EdgeInsets.all(8),
          decoration: _buildDecoration(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Reward icon
              Text(
                reward.icon,
                style: const TextStyle(fontSize: 28),
              ),
              const SizedBox(height: 6),
              // Name
              Text(
                reward.name,
                style: TextStyle(
                  color: widget.state == _NodeState.locked ||
                          widget.state == _NodeState.premiumLocked
                      ? widget.theme.accentColor.withValues(alpha: 0.6)
                      : widget.theme.accentColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Quantity
              if (reward.quantity > 1)
                Text(
                  'x${reward.quantity}',
                  style: TextStyle(
                    color: widget.theme.accentColor.withValues(alpha: 0.7),
                    fontSize: 10,
                  ),
                ),
              const SizedBox(height: 4),
              // State indicator
              _buildStateIndicator(),
            ],
          ),
        ),
      ),
    );

    return node;
  }
}

// ===========================================================================
// 5. _PremiumCTA (Kept from original, using gameBreathe)
// ===========================================================================
// TODO: Re-enable when purchase flow is implemented
// class _PremiumCTA extends StatelessWidget {
//   final BattlePassSeason season;
//   final GameTheme theme;
//   final VoidCallback onTap;
//
//   const _PremiumCTA({
//     required this.season,
//     required this.theme,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             theme.backgroundColor.withValues(alpha: 0),
//             theme.backgroundColor,
//           ],
//         ),
//       ),
//       child: SafeArea(
//         top: false,
//         child: InkWell(
//           onTap: onTap,
//           borderRadius: BorderRadius.circular(16),
//           child: Container(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [
//                   Colors.amber.shade600,
//                   Colors.orange.shade700,
//                 ],
//               ),
//               borderRadius: BorderRadius.circular(16),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.amber.withValues(alpha: 0.3),
//                   blurRadius: 20,
//                   spreadRadius: 2,
//                 ),
//               ],
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 24,
//                 vertical: 16,
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(10),
//                     decoration: BoxDecoration(
//                       color: Colors.white.withValues(alpha: 0.2),
//                       shape: BoxShape.circle,
//                     ),
//                     child: const Icon(
//                       Icons.workspace_premium,
//                       color: Colors.white,
//                       size: 24,
//                     ),
//                   ),
//                   const SizedBox(width: 16),
//                   Expanded(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'UNLOCK PREMIUM',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w800,
//                             letterSpacing: 0.5,
//                           ),
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           'Get all exclusive rewards',
//                           style: TextStyle(
//                             color: Colors.white.withValues(alpha: 0.8),
//                             fontSize: 13,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 16,
//                       vertical: 10,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       '\$${season.price.toStringAsFixed(2)}',
//                       style: TextStyle(
//                         color: Colors.orange.shade800,
//                         fontSize: 18,
//                         fontWeight: FontWeight.w900,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ).gameBreathe(intensity: 1.02),
//       ),
//     ).gameEntrance(delay: const Duration(milliseconds: 200));
//   }
// }

// ===========================================================================
// 6. _PurchaseSheet (Rebuilt)
// ===========================================================================
// TODO: Re-enable when purchase flow is implemented
// class _PurchaseSheet extends StatelessWidget {
//   final BattlePassSeason season;
//   final GameTheme theme;
//   final ScrollController scrollController;
//   final Future<void> Function() onPurchase;
//   final VoidCallback onDismiss;
//
//   const _PurchaseSheet({
//     required this.season,
//     required this.theme,
//     required this.scrollController,
//     required this.onPurchase,
//     required this.onDismiss,
//   });
//
//   List<BattlePassReward> get _featuredRewards {
//     final rewards = <BattlePassReward>[];
//     for (final level in season.levels) {
//       if (level.premiumReward != null && level.premiumReward!.isSpecial) {
//         rewards.add(level.premiumReward!);
//       }
//       if (rewards.length >= 6) break;
//     }
//     if (rewards.length < 5) {
//       for (final level in season.levels) {
//         if (level.premiumReward != null &&
//             !rewards.contains(level.premiumReward)) {
//           rewards.add(level.premiumReward!);
//           if (rewards.length >= 6) break;
//         }
//       }
//     }
//     return rewards;
//   }
//
//   int get _premiumRewardCount =>
//       season.levels.where((l) => l.premiumReward != null).length;
//
//   int get _skinCount => season.levels
//       .where((l) =>
//           l.premiumReward?.type == BattlePassRewardType.skin ||
//           l.premiumReward?.type == BattlePassRewardType.theme)
//       .length;
//
//   int get _xpRewardCount => season.levels
//       .where((l) => l.premiumReward?.type == BattlePassRewardType.xp)
//       .length;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: theme.backgroundColor,
//         borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//         border: Border.all(
//           color: Colors.amber.withValues(alpha: 0.3),
//           width: 1.5,
//         ),
//       ),
//       child: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 12),
//             child: Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: theme.accentColor.withValues(alpha: 0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//           Container(
//             width: 72,
//             height: 72,
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Colors.amber, Colors.orange.shade600],
//               ),
//               shape: BoxShape.circle,
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.amber.withValues(alpha: 0.4),
//                   blurRadius: 20,
//                   spreadRadius: 4,
//                 ),
//               ],
//             ),
//             child: const Icon(
//               Icons.workspace_premium,
//               color: Colors.white,
//               size: 36,
//             ),
//           ).gameHero(),
//           const SizedBox(height: 16),
//           Text(
//             'Upgrade to Premium',
//             style: TextStyle(
//               color: theme.accentColor,
//               fontSize: 24,
//               fontWeight: FontWeight.w800,
//             ),
//           ),
//           const SizedBox(height: 4),
//           Text(
//             season.name,
//             style: TextStyle(
//               color: season.themeColor,
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//           const SizedBox(height: 20),
//           Expanded(
//             child: SingleChildScrollView(
//               controller: scrollController,
//               padding: const EdgeInsets.symmetric(horizontal: 24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'FEATURED REWARDS',
//                     style: TextStyle(
//                       color: theme.accentColor.withValues(alpha: 0.6),
//                       fontSize: 11,
//                       fontWeight: FontWeight.w700,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   SizedBox(
//                     height: 100,
//                     child: ListView.builder(
//                       scrollDirection: Axis.horizontal,
//                       itemCount: _featuredRewards.length,
//                       itemBuilder: (context, index) {
//                         final reward = _featuredRewards[index];
//                         return Container(
//                           width: 80,
//                           margin: const EdgeInsets.only(right: 10),
//                           padding: const EdgeInsets.all(8),
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [
//                                 Colors.amber.withValues(alpha: 0.25),
//                                 Colors.orange.withValues(alpha: 0.12),
//                               ],
//                             ),
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(
//                               color: Colors.amber.withValues(alpha: 0.35),
//                             ),
//                           ),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Text(reward.icon,
//                                   style: const TextStyle(fontSize: 28)),
//                               const SizedBox(height: 4),
//                               Text(
//                                 reward.name,
//                                 style: TextStyle(
//                                   color: theme.accentColor,
//                                   fontSize: 10,
//                                   fontWeight: FontWeight.w600,
//                                 ),
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                                 textAlign: TextAlign.center,
//                               ),
//                             ],
//                           ),
//                         ).gameGridItem(index);
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 20),
//                   Row(
//                     children: [
//                       _buildStatCard(
//                         '$_premiumRewardCount',
//                         'Premium\nRewards',
//                       ),
//                       const SizedBox(width: 10),
//                       _buildStatCard(
//                         '$_skinCount',
//                         'Exclusive\nSkins',
//                       ),
//                       const SizedBox(width: 10),
//                       _buildStatCard(
//                         '$_xpRewardCount',
//                         'Bonus\nXP',
//                       ),
//                     ],
//                   ).gameEntrance(delay: const Duration(milliseconds: 100)),
//                   const SizedBox(height: 20),
//                   _buildBenefitRow(
//                     Icons.card_giftcard,
//                     'Exclusive Premium Rewards',
//                     0,
//                   ),
//                   _buildBenefitRow(
//                     Icons.palette,
//                     'Exclusive Themes & Skins',
//                     1,
//                   ),
//                   _buildBenefitRow(
//                     Icons.bolt,
//                     'Bonus XP Rewards',
//                     2,
//                   ),
//                   _buildBenefitRow(
//                     Icons.emoji_events,
//                     'Tournament Access',
//                     3,
//                   ),
//                   const SizedBox(height: 24),
//                 ],
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
//             child: Column(
//               children: [
//                 GameButton(
//                   text: 'Purchase for \$${season.price.toStringAsFixed(2)}',
//                   theme: theme,
//                   variant: GameButtonVariant.premium,
//                   size: GameButtonSize.hero,
//                   expanded: true,
//                   onPressed: () {
//                     onDismiss();
//                     onPurchase();
//                   },
//                 ),
//                 const SizedBox(height: 8),
//                 TextButton(
//                   onPressed: onDismiss,
//                   child: Text(
//                     'Maybe Later',
//                     style: TextStyle(
//                       color: theme.accentColor.withValues(alpha: 0.6),
//                       fontSize: 14,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: MediaQuery.of(context).padding.bottom),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildStatCard(String value, String label) {
//     return Expanded(
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
//         decoration: BoxDecoration(
//           color: theme.accentColor.withValues(alpha: 0.12),
//           borderRadius: BorderRadius.circular(12),
//           border: Border.all(
//             color: theme.accentColor.withValues(alpha: 0.2),
//           ),
//         ),
//         child: Column(
//           children: [
//             Text(
//               value,
//               style: TextStyle(
//                 color: Colors.amber,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w900,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               label,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: theme.accentColor.withValues(alpha: 0.6),
//                 fontSize: 11,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBenefitRow(IconData icon, String text, int index) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(
//               color: Colors.amber.withValues(alpha: 0.2),
//               borderRadius: BorderRadius.circular(10),
//             ),
//             child: Icon(icon, color: Colors.amber, size: 20),
//           ),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Text(
//               text,
//               style: TextStyle(
//                 color: theme.accentColor,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ),
//           Icon(
//             Icons.check_circle,
//             color: Colors.green.withValues(alpha: 0.7),
//             size: 20,
//           ),
//         ],
//       ),
//     ).gameListItem(index);
//   }
// }
