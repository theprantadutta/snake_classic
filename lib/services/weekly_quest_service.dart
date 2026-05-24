import 'package:flutter/foundation.dart';
import 'package:snake_classic/models/weekly_quest.dart';

/// Offline-first stub. Weekly quests are issued + scored by the
/// backend; no local Drift table backs them in this build. The
/// service stays in the tree so DI / cubit subscriptions compile,
/// but it never reports quests, never claims rewards, never fires
/// progress updates.
///
/// To revive: restore the prior implementation from git history,
/// re-add the WeeklyQuests endpoints to [ApiService], and (optionally)
/// add a local `WeeklyQuests` Drift table to mirror per-user progress.
class WeeklyQuestService extends ChangeNotifier {
  static final WeeklyQuestService _instance = WeeklyQuestService._internal();
  factory WeeklyQuestService() => _instance;
  WeeklyQuestService._internal();

  List<WeeklyQuest> get quests => const [];
  bool get isLoading => false;
  int get completedCount => 0;
  int get claimableCount => 0;
  bool get hasUnclaimedRewards => false;
  bool get isStale => false;

  Future<void> initialize() async {}

  Future<void> refresh() async {}

  Future<void> reportProgress({
    required WeeklyQuestType type,
    required int incrementBy,
    String? gameMode,
  }) async {}

  Future<void> reportProgressBatch(
    List<({WeeklyQuestType type, int incrementBy, String? gameMode})> updates,
  ) async {}

  Future<bool> claimReward(String questId) async => false;
}
