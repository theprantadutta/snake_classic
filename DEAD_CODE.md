# Dead code — delete when the legacy-client window closes

> Future me — this is a snapshot of what was **already unreachable** when
> the Drift-first offline-first refactor landed on `master`, but couldn't
> be deleted in the same PR because old client builds still call the
> legacy surface. Use this as a punch list: pick a row, verify the
> "delete when" condition, then delete it.
>
> **Audit baseline:** branch `feat/offline-first-refactor`, 2026-05-28.
> Verified via direct grep — not by trusting agents wholesale, some of
> their dead-flags were wrong and have been removed below.

---

## Legend

| Marker | Meaning |
|--------|---------|
| 🟢 | **Delete immediately.** Already unreachable, no client (current or legacy) depends on it. |
| 🟡 | **Delete after the legacy-client window.** Old Flutter builds still call this endpoint or write this prefs key. Wait until analytics show those builds are gone (recommend ~2 minor versions after this PR ships). |
| 🟠 | **Decision needed.** Feature shell exists (screens, UI) but underlying logic is stubbed. Either delete the whole feature or revive the implementation — don't just half-do it. |

---

# Flutter (`snake_classic/`)

## Dormant methods inside services

### `lib/services/statistics_service.dart`

| | Item | Notes |
|--|------|-------|
| 🟢 | `_applyServerAggregates(GameStatistics, Map<String, dynamic>)` | ~60 lines, marked `// ignore: unused_element`. "Dormant in the offline-first build but retained in case the server merge path is revived." Only called from `_mergeStatistics` (also dead). |
| 🟢 | `_mergeStatistics(GameStatistics, GameStatistics)` | ~110 lines, marked `// ignore: unused_element`. Full client-side max-merge of stats. Stats now sync via SyncEngine outbox to the backend's per-field MAX-fold handler; the client never merges its own snapshot. |
| 🟢 | `_mergeMaps(Map<String, int>, Map<String, int>)` | Helper for `_mergeStatistics`. Dies with it. |
| 🟢 | `_earlierDate(DateTime?, DateTime?)` | Helper for `_mergeStatistics`. Dies with it. |
| 🟢 | `_laterDate(DateTime?, DateTime?)` | Helper for `_mergeStatistics`. Dies with it. |
| 🟢 | `_syncWithCloud()` and `_uploadToCloud()` | Both empty no-op bodies. Comments say "No-op in the offline-first build." Called from `initialize()`, `recordGameResult()`, `startNewSession()`, `forceSync()` — delete the methods AND the `await ...()` lines at the call sites in one pass. |
| 🟢 | `syncWithBackend()` and `forceSync()` | Legacy public entry points that exist only to keep older callers compiling. Grep for callers; if zero, delete. If non-zero, delete callers too. |

### `lib/services/achievement_service.dart`

| | Item | Notes |
|--|------|-------|
| 🟢 | `_updateAchievementsFromBackend(List<Map<String, dynamic>>)` | ~100 lines, marked `// ignore: unused_element`. Dormant backend-sync overlay. Achievement progress now flows through Drift watch + local evaluators only. Only docstring mentions reference the name — no live callers. |

### `lib/services/social_service.dart`

| | Item | Notes |
|--|------|-------|
| 🟢 | `updateUserStatus(UserStatus, {String?})` | `async {}` no-op. "Status / privacy updates were backend-only in the prior build. Left as no-ops here so existing call sites compile." |
| 🟢 | `updatePrivacySetting(bool)` | `async => false` no-op. Same reason. Grep for callers and delete method + caller together. |

### `lib/services/auth_service.dart`

| | Item | Notes |
|--|------|-------|
| 🟢 | `_trackGamePlayedLocally({...})` | `async {}` no-op. Game-played tracking removed; method kept only for callsite compatibility. |

### `lib/services/notification_service.dart`

| | Item | Notes |
|--|------|-------|
| 🟢 | `notifyFriendGameStarted({...})` | `async {}` no-op. Friend game-start notifications are dormant. |

### `lib/services/data_sync_service.dart`

| | Item | Notes |
|--|------|-------|
| 🟢 | `_syncScoresBatch(List<SyncQueueItem>)` | 4 lines, just marks items completed. "No-op in the offline-first build — score submission lost its backend endpoint." |
| 🟢 | `mergeData(Map<String, dynamic>, Map<String, dynamic>)` | ~15 lines, "Merge data with conflict resolution (most recent wins)." Zero callers; offline-first doesn't merge maps this way anymore. |
| 🟡 | `DataSyncService` as a whole | Partially dormant — still owns the legacy sync surface for `profile`, `preferences`, `fcm_token_register` dataTypes (see comment at line ~411). **Don't delete the class.** Do an audit pass to confirm those three dataTypes still need it, then collapse the rest of the switch (`score`, `achievement`, `coin_balance`, etc.) — those are already routed to `SyncEngine` via `_isOwned` / `outboxOwned`. |

## Retired SharedPreferences keys

### `lib/presentation/bloc/coins/coins_cubit.dart`

| | Item | Notes |
|--|------|-------|
| 🟡 | `_legacyBalanceKey = 'coin_balance'` | Only read by `_migrateLegacySharedPreferencesToDrift()`. Delete constant + migration once analytics confirms zero old installs. |
| 🟡 | `_legacyTransactionsKey = 'coin_transactions'` | Same as above. |
| 🟡 | `_legacyDailyBonusesKey = 'daily_bonuses'` | Only read by `_migrateLegacyDailyBonusToDrift()`. Same window guidance. |
| 🟡 | `_legacyLastBonusClaimDateKey = 'last_daily_bonus_claim_date'` | Same. |

### `lib/utils/constants.dart`

| | Item | Notes |
|--|------|-------|
| 🟢 | `statisticsKey = 'game_statistics'` | Already commented out with a "retired" note. Just remove the comment block + the dead line. |

## Multiplayer surface (whole feature)

The file `lib/services/multiplayer_service.dart` opens with this
docstring:

> Offline-first stub. Multiplayer requires both a live REST backend
> (create/join/list rooms) and a SignalR hub for real-time game state.
> Both are disabled in this build, so the service compiles but every
> method is inert — create returns null, join returns false, action
> methods are no-ops, streams are empty.

Every public method returns `null` / `false` / `const []`. But the cubit,
screens, and routes still exist — users can navigate to multiplayer
screens that don't work.

| | Item | Notes |
|--|------|-------|
| 🟠 | `lib/services/multiplayer_service.dart` | Inert stub. ~125 lines of no-op methods. |
| 🟠 | `lib/presentation/bloc/multiplayer/multiplayer_cubit.dart` | Listens to streams that never emit. |
| 🟠 | `lib/screens/multiplayer_lobby_screen.dart` and `multiplayer_game_screen.dart` | Routed under `/multiplayer/*`. |
| 🟠 | `lib/widgets/multiplayer_game_adapter.dart` and `multiplayer_game_board.dart` | Render code for the stub flow. |
| 🟠 | `multiplayerLobby` / `multiplayerLobbyWithId` / `multiplayerGame` routes in `lib/router/routes.dart` + `lib/router/app_router.dart` | Surface that lets users navigate to the dead screens. |

**Action:** decide before merge. Either delete the whole stack OR commit
to reviving multiplayer (restore from git history). Leaving it half-on
ships dead UI.

---

# Backend (`snake-classic-backend/`)

The Flutter client no longer calls any non-`/sync/` endpoint for synced
gameplay state. Several legacy controllers + their MediatR handlers +
DTOs are unreachable from the client.

## 🟢 Delete immediately — no client (current or legacy) ever calls these

| Item | Route | Reason |
|------|-------|--------|
| `DailyChallengesController.GenerateChallenges()` | `POST /api/v1/daily-challenges/generate` | `[AllowAnonymous]` debug endpoint. |
| `DailyChallengesController.TestReminder()` | `POST /api/v1/daily-challenges/test-reminder` | `[AllowAnonymous]` debug endpoint. |
| `MultiplayerController.GetAvailableGames()` | `GET /api/v1/multiplayer/available` | Flutter `MultiplayerService` is stubbed — no callers. |
| `MultiplayerController.GetQueueStatus()` | `GET /api/v1/multiplayer/debug/queue` | Debug-only. |
| `MultiplayerController.TriggerMatchmaking()` | `POST /api/v1/multiplayer/debug/process-matchmaking` | Debug-only. |
| `SubscriptionController.Cancel()` | `POST /api/v1/subscription/cancel` | Empty stub endpoint. |

## 🟢 Delete immediately — orphan domain entity

| Item | Location | Reason |
|------|----------|--------|
| `ScheduledJob` entity | `src/SnakeClassic.Domain/Entities/ScheduledJob.cs` + `Persistence/Configurations/ScheduledJobConfiguration.cs` + `DbSet<ScheduledJob> ScheduledJobs` in `AppDbContext.cs` and `IAppDbContext.cs` | Zero handler reads or writes it. Hangfire uses its own PostgreSQL job table. Migrations have to stay (immutable history), but the entity + config + DbSet declarations can go. |

## 🟡 Delete after legacy-client window — legacy CRUD superseded by `/sync/*`

Old client builds still POST/GET these. Verify the legacy-client install
base is gone before deleting.

### Daily bonus (replaced by `/sync/daily-bonus`)

- `DailyBonusController` — both routes (`GET /api/v1/daily-bonus/status`, `POST /api/v1/daily-bonus/claim`).
- `src/SnakeClassic.Application/Features/DailyBonus/Commands/ClaimDailyBonus/` (Command, Handler, Validator).
- `src/SnakeClassic.Application/Features/DailyBonus/Queries/GetDailyBonusStatus/` (Query, Handler).
- `src/SnakeClassic.Application/Features/DailyBonus/DTOs/DailyBonusDto.cs` records (`DailyBonusStatusDto`, `ClaimDailyBonusResultDto`, `ClaimDailyBonusErrorDto`).
- **Keep** the `DailyLoginBonus` **entity** — `SyncDailyBonusCommandHandler` writes to it.

### Scores (gameplay totals now ride `/sync/statistics`)

- `ScoresController.SubmitScore()` — `POST /api/v1/scores`.
- `ScoresController.GetMyScores()` — `GET /api/v1/scores/me`.
- `ScoresController.GetMyStats()` — `GET /api/v1/scores/me/stats`.
- `ScoresController.BatchSubmitScores()` — `POST /api/v1/scores/batch`.
- Associated commands/queries: `SubmitScoreCommand`, `GetUserScoresQuery`, `GetUserStatsQuery`, `BatchSubmitScoresCommand`.
- **Verify first:** does any admin route on `ScoresController` or any dashboard page read scores? The leaderboard endpoints elsewhere may share the `Score` entity, so don't drop that.

### Achievements (replaced by `/sync/achievements`)

- `AchievementsController.GetAllAchievements()` — `GET /api/v1/achievements`.
- `AchievementsController.UpdateProgress()` — `POST /api/v1/achievements/progress`.
- `AchievementsController.BatchUpdateProgress()` — `POST /api/v1/achievements/progress/batch`.
- `AchievementsController.ClaimReward()` — `POST /api/v1/achievements/claim`.
- Associated: `GetAchievementsQuery`, `UpdateAchievementProgressCommand`, `BatchUpdateAchievementProgressCommand`, `ClaimAchievementRewardCommand`.

### Battle pass (replaced by `/sync/battle-pass`)

- `BattlePassController.GetCurrentSeason()` — `GET /api/v1/battlepass/current-season`.
- `BattlePassController.GetProgress()` — `GET /api/v1/battlepass/progress`.
- `BattlePassController.AddXp()` — `POST /api/v1/battlepass/add-xp`.
- `BattlePassController.ClaimReward()` — `POST /api/v1/battlepass/claim-reward`.
- Associated queries/commands: `GetCurrentSeasonQuery`, `GetBattlePassProgressQuery`, `AddBattlePassXpCommand`, `ClaimBattlePassRewardCommand`.
- **Verify first:** `ClaimBattlePassRewardCommand` may be called by the dashboard's admin "grant reward" tool — confirm before deleting.

### Power-ups (replaced by `/sync/unlocked-items` for ownership)

- `PowerUpsController.PurchaseBundle()` — `POST /api/v1/powerups/purchase-bundle`.
- Associated: `PurchasePowerUpBundleWithCoinsCommand`.

### Weekly quests (partial)

- `WeeklyQuestsController.UpdateProgressBatch()` — `POST /api/v1/weekly-quests/progress/batch`.
- The rest of `WeeklyQuestsController` is alive — quest progress and current-week fetches are still called. Only the batch-progress submission is dead.

## 🟡 Delete after legacy-client window — intentionally-retired stubs

These were kept as error-returning stubs so old clients don't 404. Once
those clients are gone, remove the stubs entirely.

- **`PurchasePremiumCommand`** + handler at `src/SnakeClassic.Application/Features/BattlePass/Commands/PurchasePremium/`. Handler docstring: "Retired path. The Premium battle-pass track is now bundled with the Pro subscription. This handler is kept so the existing route doesn't 404 for old clients; it returns a clear error." Route: `POST /api/v1/battlepass/purchase-premium`.
- **`TestController.SendTestNotification()`** — marked `[Obsolete("Use POST /api/v1/test/send-to-me...")]`. Comment says "keep for one release." Delete after the next release ships.

## Decision needed — admin/notifications routes the dashboard doesn't call

The Next.js dashboard doesn't call these. Could be intentional (curl from
CI / a runbook), could be scaffolded UI that never landed.

- `NotificationsController.SendIndividualNotification()` — `POST /api/v1/notifications/send-individual`.
- `NotificationsController.SendTopicNotification()` — `POST /api/v1/notifications/send-topic`.

If they're for internal ops, document them. Otherwise delete the routes
+ the `SendNotificationCommand` handler (if it ends up uncalled).

---

# Confirmed ALIVE — DO NOT delete

The dead-code agents over-flagged several items. Verified callers exist
for all of these — don't get rid of them.

## Flutter

- `ApiService.getActiveTournaments`, `getTournamentsList`, `getTournament`, `joinTournamentRemote`, `submitTournamentScoreRemote` — all called via `TournamentService`.
- `ApiService.getGlobalLeaderboardPage`, `getWeeklyLeaderboardPage`, `getDailyLeaderboardPage`, `getFriendsLeaderboardPage` — all called via `LeaderboardService`.
- `ApiService.getFriendsList`, `getFriendRequestsList`, `sendFriendRequestRemote`, `acceptFriendRequestRemote`, `rejectFriendRequestRemote` — all called via `SocialService`.
- `OfflineCacheService` — used by `AchievementService` for offline fallback reads.
- `DataSyncService` — still owns `profile`/`preferences`/`fcm_token_register` legacy dataTypes (see the partial-dormancy note above).
- All `GameStatistics` model fields — `currentWinStreak`, `longestWinStreak`, `gamesWithoutWallHit`, `achievementsUnlocked`, `totalAchievements`, `achievementProgress` are all written in `updateWithGameResult` and read by achievement checks.

## Backend

- `UserPreferences` AND `UserGameSettings` entities are both alive (legacy profile updates vs sync target).
- `WebhookService` and `AppleWebhookService` — called by webhook controllers + reconciliation jobs.
- All Hangfire background jobs in `src/SnakeClassic.Infrastructure/Services/BackgroundJobs/` are scheduled by `HangfireJobScheduler.cs`.

---

# Verification after any deletion

```
cd snake_classic && flutter analyze
cd snake-classic-backend && dotnet build snake-classic-backend.sln
```

For the harder cases (🟡 legacy-window deletions):
- Boot the app on a device, sign in, ensure no `/api/v1/daily-bonus/*`, `/api/v1/scores/*`, `/api/v1/achievements/*`, `/api/v1/battlepass/*` calls fire in the Talker logs.
- Watch the dashboard's user-detail page after a sync and confirm stats / battle pass / coins / daily bonus all render.

For the 🟠 multiplayer call: this isn't a deletion problem, it's a
product decision. Talk to the product / design side before either path.
