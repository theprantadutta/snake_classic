# 06 — Other Findings

## 6.1 Push notifications: high volume, almost no opens

GA, 28 days (`ga-01…`, `ga-04…`, raw-data §C2):

| Event | Events | Users | Per user |
|---|---:|---:|---:|
| `notification_receive` | **88,219** | 6,754 | **28.75** (≈ 1 per day) |
| `notification_dismiss` | 9,019 | 1,034 | 22.05 |
| `notification_open` | **224** | 157 | 1.48 |
| `notification_foreground` | 171 | 68 | 3.11 |

- **Open rate ≈ 0.25%** (224 / 88,219). Game push open rates are typically 3–8%.
- **Firebase Messaging has no console campaigns** ("Create your first campaign") — every push comes
  from the backend (Hangfire jobs). Candidates in `snake-classic-backend`:
  `src/SnakeClassic.Api/Hangfire/HangfireJobScheduler.cs` (all recurring schedules),
  `src/SnakeClassic.Infrastructure/Services/BackgroundJobs/NotificationJobService.cs`,
  `DailyChallengeJobService.cs`, `WeeklyQuestJobService.cs`, `TournamentManagementJobService.cs`,
  `PromoJobs.cs` (`SendPromoReminderJob`), sender `Services/FirebaseMessagingService.cs`,
  history `Services/NotificationHistoryRecorder.cs`.
- Daily pushes with near-zero opens correlate with uninstalls and notification opt-outs.
- Note: GA's `notification_receive` only fires for FCM *notification* messages, so this is user-visible push.

## 6.2 In-app purchases

| Event | Events | Users |
|---|---:|---:|
| `store_tab_viewed` | 1,142 | **183** (1.5% of users) |
| `purchase_initiated` | 44 | 24 |
| `purchase_cancelled` | 21 | 18 |
| `purchase_failed` | **17** | 13 |
| `item_purchased` | **3** | 3 |

- 17 of 44 initiated purchases **failed** (39%). Could be declined payment methods (common in India /
  Brazil), billing-client errors, or app-side errors. `purchase_failed` logs `error=<code>` (see
  `lib/services/analytics/firebase_analytics_client.dart:267` and `lib/services/purchase_service.dart`
  status paths at lines ~320/382/451/466/572) — pull the error codes from GA.
- **GA shows $0 IAP revenue**: total revenue $79.56 is 100% `ad_impression`. There is no `purchase` /
  `in_app_purchase` event at all. Either Google Play isn't linked to Firebase, or Pro/subscription
  success isn't logged with value. Check whether a successful Pro subscription fires any event.
- Store discovery is tiny: only 183 users opened the store in 28 days.

## 6.3 Multiplayer funnel

| Event | Events | Users |
|---|---:|---:|
| `home_versus_cta_tapped` / `multiplayer_lobby_opened` | 2,661 | 1,696 |
| `multiplayer_queue_joined` | 3,238 | 762 |
| `multiplayer_game_started` | **238** | **71** |
| `multiplayer_game_ended` | 2,445 | 407 |

- 45% of lobby openers (by users) join the queue; ~53% of queuers finish a match. The planned human-disguised bot
  fallback (owner memory: `project_multiplayer_rebuild.md`) should lift queue→match.
- **Tracking bug:** `multiplayer_game_started` (71 users) is far below `multiplayer_game_ended`
  (407 users) — "started" only fires on some paths. Code: `firebase_analytics_client.dart:161`,
  logger `logger_analytics_client.dart:122`; find the call sites.

## 6.4 Crashlytics vs Sentry

- Firebase overview shows **Crash-free 100%** (Android/iOS). The Crashlytics page lists
  **"Latest release 6.5.0 (55)"**, 96.67% crash-free users from ~1 user, and one old issue
  (`SqliteException … duplicate column name: stats_applied` on 6.0.0–6.4.1).
- The app **replaced Crashlytics with Sentry** (`lib/core/observability/sentry_bootstrap.dart:1`
  "Sentry wiring for the app. Replaced Firebase Crashlytics."). The Firebase card is stale and
  should be ignored. **Stability must be checked in Sentry** (not covered here) — also Play Console
  Android Vitals (ANR / crash rate) since Play ranking depends on them.
- `app_exception` GA event: 11 events / 4 users (28 d).

## 6.5 Other apps in the AdMob account (not Snake Classic — FYI)

- **AI Persona: Character Chat (Android)** — *Restricted ad serving*, issue "Ads in private
  communications", 222 requests/7 d, reported Sep 27, 2026 (`admob-10-policy-center.jpg`).
- Several **iOS apps show "Requires review / Limited ad serving — Add store to lift limit"**
  (e.g. AI Persona iOS, Cosmo Strike iOS) — link their App Store listings in AdMob.
- AdMob "Apps" nav shows a red badge: **"Apps to confirm: 1"**.
- Gridwell, Pourfect, Screw Out each earned < $0.10 in 7 days.

## 6.6 Firebase project notes

- Plan: **Spark** (free). Apps registered: Android, iOS, **web (0 users)**.
- Top screens are `MainActivity` (Flutter) and `AdActivity` (ads). `PlayCoreDialogWrapperActivity`
  48 views/7 d = in-app review dialog.
