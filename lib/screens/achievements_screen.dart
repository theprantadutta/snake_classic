import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:snake_classic/l10n/achievement_l10n.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/models/achievement.dart';
import 'package:snake_classic/presentation/bloc/theme/theme_cubit.dart';
import 'package:snake_classic/services/achievement_service.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/utils/responsive.dart';
import 'package:snake_classic/utils/typography.dart';
import 'package:snake_classic/widgets/app_background.dart';
import 'package:snake_classic/widgets/screen_shell.dart';
import 'package:snake_classic/widgets/ads/banner_ad_widget.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AchievementService _achievementService = AchievementService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _achievementService.addListener(_onAchievementsChanged);
  }

  @override
  void dispose() {
    _achievementService.removeListener(_onAchievementsChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onAchievementsChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, themeState) {
        final theme = themeState.currentTheme;
        return _buildContent(context, theme);
      },
    );
  }

  Widget _buildContent(BuildContext context, GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      bottomNavigationBar: const SnakeBannerAd(),
      extendBodyBehindAppBar: true,
      // The last hand-rolled bar in the app. It only ever differed because it
      // needed a tab strip, which the shared one now takes.
      appBar: appScreenBar(
        context,
        theme,
        l10n.pfAchievements,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: theme.accentColor,
          labelColor: theme.accentColor,
          unselectedLabelColor: theme.accentColor.withValues(alpha: 0.6),
          tabs: [
            Tab(text: l10n.acAll),
            Tab(text: l10n.acUnlocked),
            Tab(text: l10n.acLocked),
          ],
        ),
      ),
      body: AppBackground(
        theme: theme,
        child: Column(
          children: [
            // Clear the app bar and its tab strip.
            //
            // extendBodyBehindAppBar draws the themed background up behind
            // the bar, which is what the other screens want — but the body
            // then starts at y=0, so without this the summary card was drawn
            // underneath the title and the tab labels landed on top of it.
            SizedBox(
              height:
                  MediaQuery.of(context).padding.top +
                  kToolbarHeight +
                  kTextTabBarHeight,
            ),

            // Progress Summary
            _buildProgressSummary(theme),

            // Achievements List
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAchievementsList(
                    _achievementService.achievements,
                    theme,
                  ),
                  _buildAchievementsList(
                    _achievementService.getUnlockedAchievements(),
                    theme,
                  ),
                  _buildAchievementsList(
                    _achievementService.getLockedAchievements(),
                    theme,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary(GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    // Stat counts use the same logic as the dashboard's AchievementsGrid:
    // - Total: every row in the catalog
    // - Unlocked: isUnlocked = true
    // - Claimed: rewardClaimed = true
    // - Pending: isUnlocked = false (locked, regardless of progress)
    final all = _achievementService.achievements;
    final total = all.length;
    final unlocked = all.where((a) => a.isUnlocked).length;
    final claimed = all.where((a) => a.rewardClaimed).length;
    final pending = all.where((a) => !a.isUnlocked).length;
    final completionPercentage = _achievementService.completionPercentage;
    final claimedOfUnlocked = unlocked > 0
        ? ((claimed / unlocked) * 100).round()
        : 0;
    final completionPct = (completionPercentage * 100).round();

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 16 + context.sideInset(),
        vertical: 16,
      ),
      padding: const EdgeInsets.all(16),
      decoration: screenCardDecoration(theme),
      child: Column(
        children: [
          // 4-tile grid — same labels and counting logic as the dashboard
          // AchievementsGrid header so the operator and the player see the
          // same numbers when troubleshooting.
          Row(
            children: [
              Expanded(
                child: _StatTile(
                  label: l10n.acTotalUpper,
                  value: '$total',
                  accent: Colors.white70,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: l10n.acUnlockedUpper,
                  value: '$unlocked',
                  accent: kRewardGold,
                  hint: l10n.acPercentComplete(completionPct),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: l10n.acClaimedUpper,
                  value: '$claimed',
                  accent: theme.accentColor,
                  hint: unlocked > 0
                      ? l10n.acPercentOfUnlocked(claimedOfUnlocked)
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatTile(
                  label: l10n.acPendingUpper,
                  value: '$pending',
                  accent: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Completion bar, in the accent — it was a gradient.
          Container(
            height: context.scaled(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: completionPercentage,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsList(
    List<Achievement> achievements,
    GameTheme theme,
  ) {
    if (achievements.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.workspace_premium_outlined,
              size: context.scaled(64),
              color: theme.primaryColor.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)!.acEmpty,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: 16 + context.sideInset(),
        vertical: 16,
      ),
      itemCount: achievements.length,
      itemBuilder: (context, index) {
        final achievement = achievements[index];

        return _buildAchievementCard(achievement, theme);
      },
    );
  }

  /// One achievement.
  ///
  /// It was three columns — icon, a text block, and a stack of chips — with
  /// the rarity as a filled pill in one of four hues and the two rewards as
  /// a cyan chip above a gold chip. Every row was a different height because
  /// the middle column wrapped while the right column did not, and the four
  /// rarity colours plus cyan meant five hues per screenful. Nothing in it
  /// pointed at what the row was for.
  ///
  /// Now it is two columns and three lines: what it is called, what it asks
  /// of you, and what it pays. Rarity is a word in its own colour rather
  /// than a filled chip, the rewards read as one line of text, and the
  /// progress bar only appears when there is progress to show.
  Widget _buildAchievementCard(Achievement achievement, GameTheme theme) {
    final l10n = AppLocalizations.of(context)!;
    final isUnlocked = achievement.isUnlocked;
    final claimed = achievement.rewardClaimed;
    final progress = achievement.progressPercentage;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: screenCardDecoration(
          theme,
          borderColor: isUnlocked
              ? achievement.rarityColor.withValues(alpha: 0.45)
              : null,
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // The badge. Filled in the rarity colour once earned, a quiet
            // outline until then — "not yet", rather than the dead grey
            // square it used to be.
            Container(
              width: context.scaled(44),
              height: context.scaled(44),
              decoration: BoxDecoration(
                color: isUnlocked
                    ? achievement.rarityColor.withValues(alpha: 0.9)
                    : theme.accentColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isUnlocked
                      ? achievement.rarityColor
                      : theme.accentColor.withValues(alpha: 0.25),
                ),
              ),
              child: Icon(
                achievement.icon,
                color: isUnlocked
                    ? Colors.white
                    : theme.accentColor.withValues(alpha: 0.55),
                size: context.scaled(22),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          achievement.localizedTitle(l10n),
                          style: TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            color: claimed
                                ? Colors.white.withValues(alpha: 0.6)
                                : Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Rarity as a word, not a filled chip. The colour still
                      // says which tier it is; it just no longer draws a
                      // coloured box around every row on the screen.
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          achievement.localizedRarityName(l10n).toUpperCase(),
                          style: TextStyle(
                            color: achievement.rarityColor.withValues(
                              alpha: 0.9,
                            ),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: context.letterSpacing(1),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    achievement.localizedDescription(l10n),
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: Colors.white.withValues(alpha: 0.55),
                    ),
                  ),
                  if (!isUnlocked && progress > 0) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.10,
                              ),
                              valueColor: AlwaysStoppedAnimation(
                                theme.accentColor,
                              ),
                              minHeight: 5,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${achievement.currentProgress}/'
                          '${achievement.targetValue}',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Colors.white.withValues(alpha: 0.6),
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 10),
                  // The reward, as one line. It was a cyan chip stacked over
                  // a gold chip in a third column, which is what made every
                  // row a different height.
                  Row(
                    children: [
                      Icon(
                        Icons.monetization_on,
                        size: 13,
                        color: kRewardGold.withValues(
                          alpha: claimed ? 0.4 : 0.9,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          '${l10n.coinsAmount(achievement.coinReward)}'
                          '  ·  ${l10n.acXpReward(achievement.xpReward)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(
                              alpha: claimed ? 0.4 : 0.6,
                            ),
                          ),
                        ),
                      ),
                      if (isUnlocked)
                        Text(
                          (claimed ? l10n.acClaimedUpper : l10n.acUnlockedUpper)
                              .toUpperCase(),
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: context.letterSpacing(1),
                            color: claimed
                                ? Colors.white.withValues(alpha: 0.4)
                                : kRewardGold,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One figure in the summary row. Mirrors the dashboard's StatTile primitive
/// so a Total / Unlocked / Claimed / Pending row reads identically in both
/// surfaces.
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  final String? hint;

  const _StatTile({
    required this.label,
    required this.value,
    required this.accent,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: context.scaled(8),
        vertical: context.scaled(10),
      ),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.30)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 9,
              fontWeight: FontWeight.w800,
              letterSpacing: context.letterSpacing(1.0),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              height: 1.0,
            ),
          ),
          if (hint != null) ...[
            const SizedBox(height: 4),
            Text(
              hint!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.55),
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }
}
