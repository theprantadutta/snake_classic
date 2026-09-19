# Device QA: startup reporting and first-sign-in / cross-account restore

Everything below is verified by static analysis and unit tests only. None of
it has run on a device. These are the paths where that gap matters most:
startup failure reporting fires exactly when nothing else works, and the
restore path runs **once per install** — easy to ship broken, hard to notice.

Run on a **release or profile build**. A debug build cannot exercise this:
`AppLogger` is a no-op in release, so debug proves nothing about what a
shipped build actually reports.

Sentry reports from every build, tagged by environment (`production` /
`profile` / `development` — see `sentryEnvironment`), so filter the Issues
view to `environment:production` or `environment:profile` when checking these
off. That is the one thing that changed when Crashlytics was replaced: there
is no longer a build that silently reports nothing.

**Signed-in accounts needed:** one with existing cloud progress ("Account A"),
one never used with this app ("Account B").

---

## A. Startup failure reporting

The bug this closes: the "Snake Classic couldn't start" screen produced an
empty logcat *and* an empty dashboard, because the only report went through
`AppLogger`, which compiles to nothing in release.

Every report below is found in Sentry with `startup_failure:true`; the
`startup` context carries the `reason` and the `fatal` flag.

Forcing a failure needs a temporary local edit — throw from `_bootstrap()`
before `runApp`. Do it on a scratch commit; do not merge it.

| # | Steps | Expected |
|---|---|---|
| A1 | Throw early in `_bootstrap()`. Release build. Launch. | Recovery screen appears. Within a minute Sentry shows a **fatal**-level issue whose `startup` context reads `Failed to initialize Snake Classic`, carrying the real exception and stack. |
| A2 | From A1's recovery screen, tap **Try again**. | Retry fails again. Sentry gains an **error**-level (not fatal) issue reasoned `Startup retry failed` — deliberately not fatal, so repeated taps cannot bury the crash-free rate. |
| A3 | Throw from `_bootstrap()` *after* `Firebase.initializeApp` but before the router is assigned. | Fatal report arrives. Confirms the common case where Firebase is up and only later steps fail. |
| A4 | Throw from `_bootstrap()` **before** `Firebase.initializeApp`. | Recovery screen appears **and the report arrives**. This used to be a documented blind spot — Crashlytics could not report anything from before Firebase came up. Sentry initializes ahead of the whole bootstrap, so this case is now covered like any other; a missing report here is a regression, not the expected result. |
| A5 | Simulate a slow start so the 25s budget trips while the router *does* get assigned. | App launches degraded (no recovery screen). Sentry shows an **error**-level `Startup exceeded 25s`. Fatal here would be wrong: the player got a working app. |
| A6 | Remove the temporary throw. Launch normally, several times. | No `startup_failure:true` issues in Sentry. Guards against reporting on a healthy path. |
| A7 | Inspect any report from A1–A5 in Sentry. | No user id, email or IP attached (`sendDefaultPii` is off). Only error, stack, and the `startup` context. |

---

## B. First sign-in and cross-account restore

Runs once per install, gated on `sync_engine_has_ever_signed_in`. **Every case
below needs a fresh install** (uninstall, not just clear-data, to be certain
SharedPreferences and Drift are both gone).

### B1 — Guest builds progress, signs into a NEW account

| Step | Expected |
|---|---|
| Fresh install. Play 3+ games, earn coins, complete a daily challenge. | Home shows the score and coins. Profile and Settings show the orange **"Not backed up"** notice. |
| Note the exact high score, coin balance and games played. | — |
| Settings → **Sign In** → Google → Account **B** (never used). | No account-switch dialog: nothing is at risk when the account is new. |
| After sign-in completes. | Backend reports `is_new_user` → **no** cloud pull. All local progress survives: high score, coins and games played unchanged. |
| Reopen Profile and Settings. | "Not backed up" notice is gone; account shows as authenticated. |
| Check the backend / dashboard for Account B. | Coins, statistics and score events match the device. |

### B2 — Guest with progress signs into an EXISTING account

The case the confirmation dialog exists for.

| Step | Expected |
|---|---|
| Fresh install. Play until you have a high score and coins. | Note both. |
| Settings → **Sign In** → Google → Account **A** (has cloud progress). | **Account-switch dialog appears.** Cancel is the primary action. |
| Tap **Cancel**. | No sign-in occurs. Still a guest, local progress untouched. |
| Repeat, tap **Sign in anyway**. | Restore overlay runs. Afterwards, coins and stats are **Account A's**, not the device's. The guest coins are gone by design. |
| Check the backend for Account A. | Balance unchanged by the guest's coins — no inflation. |
| Check logcat during restore. | `cross-account restore` logged; guest coin rows dropped rather than pushed. |

### B3 — Anonymous user LINKS a credential (nothing should move)

| Step | Expected |
|---|---|
| Fresh install, online. Play a few games. Wait ~1 min so the FCM bootstrap silently upgrades guest → Firebase anonymous. | — |
| Note high score and coins. | — |
| Sign in with Google Account **B** (never used). | Link path taken: UID preserved. **No dialog** — nothing is being left behind. |
| After completion. | Progress fully intact. Same backend user row as before, now non-anonymous. |

### B4 — Anonymous user signs into an account that already exists

| Step | Expected |
|---|---|
| As B3, but sign in with Account **A**. | Link fails with `credential-already-in-use`. |
| | **Dialog appears** — this is the case where we *know* it is a switch. |
| Cancel. | No sign-in. Still anonymous, progress intact, no "link failed" error shown. |
| Retry and confirm. | Plain sign-in to A. A's cloud progress wins. |

### B5 — Guest with NO progress

| Step | Expected |
|---|---|
| Fresh install. Do **not** play. Settings → Sign In → any account. | **No dialog** — nothing to lose, and friction here would hit the exact conversion step play-first protects. |

### B6 — Offline play, then restore

| Step | Expected |
|---|---|
| Fresh install. Airplane mode. Play several games. | Progress accumulates locally. |
| Still offline, open Settings. | "Not backed up" notice present. Sign-in attempt fails gracefully. |
| Re-enable network. Sign into Account **B** (new). | Queued scores drain. All offline games reach the backend. |
| Compare device stats to the dashboard. | Games played and total score match. |

### B7 — Restore interrupted

| Step | Expected |
|---|---|
| Set up as B2. Kill the app **during** the restore overlay. | — |
| Relaunch. | `sync_engine_has_ever_signed_in` was never set, so the restore runs again. No data loss, no duplicate coin grant. |

### B8 — Score rejection and dead-lettering

Needs a temporary server-side validator tightening, or a crafted payload that
trips an existing plausibility ceiling.

| Step | Expected |
|---|---|
| Produce a score the backend refuses. | Batch returns 2xx with a per-item rejection. |
| Check logcat. | `permanently rejected` logged with the server reason. |
| Inspect Drift `score_dead_letters`. | One row: idempotency key, payload, verbatim reason, timestamp. |
| Play more valid games. | They sync normally — a dead score must not block the queue. |
| Check Firebase Analytics. | A `score_rejected` event with count and top reason. |

---

## C. Regression sweep

Quick passes over what the sync and dashboard changes touched.

| # | Check | Expected |
|---|---|---|
| C1 | Play a game while signed in. | Score appears on the daily leaderboard, attributed to **today**. |
| C2 | Play offline, reconnect the next day. | Score does **not** appear on the new day's board (its period closed), but all-time high score still counts it. |
| C3 | Profile → Statistics, on a **first session after install**. | Numbers render immediately. No infinite spinner — this was the original bug. |
| C4 | Admin dashboard → Daily Challenges. | Participation and completion counts are non-zero for players who actually completed challenges. |
| C5 | Admin dashboard → Battle Pass season. | Participants, tier distribution and leaders are populated. Leaders ranked by tier then XP. |
| C6 | Admin leaderboard, "daily" filter, vs the in-app daily board. | Same players, same order. |
| C7 | Launch the app and watch server logs. | **One** `GET /auth/me` and **one** `POST /users/register-token`, not three of each. |

---

## Sign-off

Do not ship the Flutter branch until A1–A7 and B1–B5 pass. B6–B8 and C are
strongly recommended but can follow if time is short.

**Deploy order is a chain:** the backend must go out first. It carries the
battle-pass XP fix, the dashboard DTO change and the per-item batch result
contract the client now depends on.
