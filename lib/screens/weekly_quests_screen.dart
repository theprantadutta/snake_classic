import 'dart:async';

import 'package:flutter/material.dart';
import 'package:snake_classic/l10n/app_localizations.dart';
import 'package:snake_classic/l10n/server_text_l10n.dart';
import 'package:snake_classic/models/weekly_quest.dart';
import 'package:snake_classic/services/audio_service.dart';
import 'package:snake_classic/services/haptic_service.dart';
import 'package:snake_classic/services/weekly_quest_service.dart';
import 'package:snake_classic/widgets/arcade_snackbar.dart';
import 'package:snake_classic/widgets/lb/lb.dart';
import 'package:snake_classic/widgets/lb_screens/daily/lb_daily_parts.dart';

/// Weekly quests, on the same system as Daily (screen 09): progress block,
/// one block per quest, CLAIM per quest.
class WeeklyQuestsScreen extends StatefulWidget {
  const WeeklyQuestsScreen({super.key});

  @override
  State<WeeklyQuestsScreen> createState() => _WeeklyQuestsScreenState();
}

class _WeeklyQuestsScreenState extends State<WeeklyQuestsScreen> {
  final WeeklyQuestService _service = WeeklyQuestService();
  final AudioService _audioService = AudioService();

  /// Re-renders the "resets in" countdown once a minute.
  Timer? _clock;

  @override
  void initState() {
    super.initState();
    // initialize() no-ops if already loaded; refresh() is the explicit
    // user-pull-to-refresh path.
    WidgetsBinding.instance.addPostFrameCallback((_) => _service.initialize());
    _clock = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _clock?.cancel();
    super.dispose();
  }

  Future<void> _claimReward(WeeklyQuest quest) async {
    // Capture before the await — reading context across the async gap is unsafe.
    final l10n = AppLocalizations.of(context)!;
    final success = await _service.claimReward(quest.id);
    if (!success || !mounted) return;

    // No grant here. WeeklyQuestService.claimReward already credited the
    // coins — this screen crediting them again meant one tap produced two
    // transactions, the same defect the daily-challenge screens had.
    HapticService().mediumImpact();
    _audioService.playSound('coin_collect');
    ScaffoldMessenger.of(context).showSnackBar(
      arcadeSnackBar(
        context,
        message: l10n.wqClaimToast(quest.coinReward, quest.battlePassXpReward),
        tone: ArcadeSnackTone.success,
        icon: Icons.monetization_on,
      ),
    );
  }

  static LBIcon _questIcon(WeeklyQuestType type) => switch (type) {
        WeeklyQuestType.score => LBIcon.star,
        WeeklyQuestType.foodEaten => LBIcon.apple,
        WeeklyQuestType.gamesPlayed => LBIcon.play,
        WeeklyQuestType.survival => LBIcon.hourglass,
        WeeklyQuestType.gameMode => LBIcon.grid,
        WeeklyQuestType.tournamentParticipation => LBIcon.trophy,
        WeeklyQuestType.dailyChallengesCompleted => LBIcon.calendar,
        WeeklyQuestType.battlePassTiersReached => LBIcon.crown,
      };

  /// "resets in …" from the quests' week start, when it lies within the
  /// coming week. Null (line omitted) when there is no honest answer.
  String? _resetLine(AppLocalizations l10n, List<WeeklyQuest> quests) {
    if (quests.isEmpty) return null;
    final end = quests.first.weekStartDate.add(const Duration(days: 7));
    final left = end.difference(DateTime.now());
    if (left.isNegative || left > const Duration(days: 7)) return null;
    return l10n.lbResetsIn(lbResetCountdown(l10n, left));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final p = context.lb;
    final g = context.lbGutter;
    return ListenableBuilder(
      listenable: _service,
      builder: (context, _) {
        final quests = _service.quests;
        final claimable = _service.claimableCount;
        final reset = _resetLine(l10n, quests);
        final subline = [
          ?reset,
          if (claimable > 0) l10n.wqClaimable(claimable),
        ].join(' · ');
        return LBScaffold(
          title: l10n.lbWeeklyTitle,
          subtitle: l10n.lbWeeklySubtitle,
          trailing: LBRefreshBlock(
            busy: _service.isLoading,
            onTap: _service.refresh,
          ),
          body: RefreshIndicator(
            onRefresh: _service.refresh,
            color: p.lime,
            backgroundColor: p.deep,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(g, context.lbCell * .9, g, context.lbCell * 1.5),
              children: [
                LBDailyProgressBlock(
                  done: _service.completedCount,
                  total: quests.length,
                  subline: subline.isEmpty ? null : subline,
                  icon: LBIcon.calendar,
                ),
                if (_service.isLoading && quests.isEmpty)
                  ...List.generate(3, (_) => const LBQuestSkeleton())
                else if (quests.isEmpty)
                  LBEmptyBlock(icon: LBIcon.calendar, title: l10n.wqNoQuests)
                else
                  for (final quest in quests)
                    LBQuestBlock(
                      icon: _questIcon(quest.type),
                      title: quest.localizedTitle(l10n),
                      description: quest.localizedDescription(l10n),
                      difficulty: quest.difficulty,
                      current: quest.currentProgress,
                      target: quest.targetValue,
                      progress: quest.progressPercentage,
                      completed: quest.isCompleted,
                      rewardLine: l10n.lbRewardCoinsXp(
                        context.formatInt(quest.coinReward),
                        context.formatInt(quest.battlePassXpReward),
                      ),
                      action: quest.canClaim
                          ? LBQuestClaim(() => _claimReward(quest))
                          : quest.claimedReward
                              ? const LBQuestClaimed()
                              : null,
                    ),
              ],
            ),
          ),
        );
      },
    );
  }
}
