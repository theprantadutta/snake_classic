# Notifications — testing & ground truth

When you "don't see any notifications," the answer is almost always one of:
1. The OS permission is denied / undetermined
2. The event you expected to trigger one isn't actually wired
3. The event is wired but only fires at a specific time you haven't hit yet

Use the **TEST NOTIFICATIONS** section in Settings to isolate which.

---

## What actually fires and when

### Local notifications (no backend involved)

| Event | Trigger | Cadence |
|---|---|---|
| Daily player ping | `scheduleSmartDailyReminder` on app launch + after each game | First fire ~24h after schedule call (RepeatInterval.daily, inexactAllowWhileIdle) |
| Test local notification | Settings → **SEND LOCAL TEST** | Immediate |

That's it. Achievement unlocks, level-ups, combo milestones, etc. are **in-app overlays** (`AchievementNotification.show`), not OS notifications — by design, the user is in the app so they'd be redundant.

### Push notifications (backend → FCM → device)

Backend Hangfire jobs that send notifications, with their exact schedule from `Program.cs`:

| Job | When | Audience | Topic / Target |
|---|---|---|---|
| Weekly leaderboard update | Sundays 14:00 UTC | All subscribed | topic `leaderboard_updates` |
| Tournament lifecycle events | Every 5 min when state changes | Tournament participants | topic `tournament_{id}` |
| Tournament prize distribution | Every 15 min | Winners | multicast to tokens |
| Daily challenge generation | Midnight UTC | (DB only, no push) | — |
| Monthly winback | 14:00 UTC daily | Users idle 30-90 days | multicast to tokens |
| Subscription expiration | 00:30 UTC daily | (DB cleanup only) | — |
| Test push via backend | Settings → **SEND PUSH VIA BACKEND** | You | direct to your FCM token |

### Not wired (known gaps, intentional or deferred)

- **Friend request received** → no push. Would need either a backend trigger on friend-request creation, or a client poll that detects new requests and fires a local notification.
- **Achievement unlock** → in-app overlay only; no OS notification. Intentional.
- **New high score on friend's leaderboard** → not implemented.
- **Daily challenge evening reminder** → `SendEveningReminder()` exists in `DailyChallengeJobService.cs` but is NOT scheduled in `Program.cs`. Intentional — the daily reminder lives on the device's local scheduler now so it's timezone-aware.

---

## Three-button triage

### 1. SEND LOCAL TEST

**What it tests**: OS permission + Android notification channel + display path.

**If you see it**: The OS-level plumbing is fine. Local notifications work. Move on to test 2.

**If you DON'T see it**:
- Check Settings → Apps → Snake Classic → Notifications. Is it ON?
- Check the notification channel "Snake Classic Notifications" — is the channel ON?
- Are you in DND mode?
- Did you see a permission prompt on first launch? If you dismissed it, you may need to re-enable in OS settings.
- On Android 13+, kill the app from recents, reinstall, accept the permission prompt this time.

### 2. SEND PUSH VIA BACKEND

**What it tests**: FCM token registered with backend + backend Firebase Admin SDK + FCM cloud delivery + device receive.

**Prereq**: SEND LOCAL TEST must work first (this test depends on the same display path).

**If you see it**: Entire push pipeline works. Any "missing notifications" are because the **triggering event** hasn't happened (e.g. you're not in a tournament that's about to start, it's not Sunday 14:00 UTC for the weekly leaderboard, etc.).

**If you DON'T see it but local works**:
- Check the button label: if it reads "NO FCM TOKEN", the device never registered. Common causes:
  - Auth not ready when token came in (retry queue should handle it — restart app)
  - The user is fully offline (token will register when connectivity returns)
- If the button is active but the push doesn't arrive:
  - Check backend `/hangfire` dashboard for failed jobs
  - Check backend logs for `Failed to send message to token`
  - Verify `firebase-admin-sdk.json` matches the client's Firebase project

### 3. COPY FCM TOKEN (debug builds only)

**What it tests**: Bypass the backend entirely. Paste the token into Firebase Console → Cloud Messaging → Send test message.

**If THAT works**: Your client + Firebase project are fine. The backend is where the break is.

**If THAT doesn't work**: Either the token isn't valid (rare — usually firebase_messaging emits a fresh one) or the device's Firebase project mismatch.

---

## What about iOS?

iOS push is not yet fully wired. Two pre-launch tasks:
- `ios/Runner/Info.plist` needs `UIBackgroundModes` array with `remote-notification`
- `ios/Runner/AppDelegate.swift` needs `UNUserNotificationCenter` delegate methods

These are tracked in Phase 3 and don't affect Android testing.

---

## Permission notes (Android 13+)

`firebase_messaging.requestPermission()` does **not** reliably trigger the Android 13+ POST_NOTIFICATIONS dialog. The fix in `NotificationService._initializeLocalNotifications` adds an explicit `flutter_local_notifications` permission request as the actual source-of-truth path. Permission is requested once per install — if the user denied, they have to re-enable in OS settings (Settings → Apps → Snake Classic → Notifications).
