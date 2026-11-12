# 04 — Ad Delivery Diagnostics: Why Most Requests Fail

Source: the app's own **`ad_load_stats`** event (one event per format per session, sent on
background; see CLAUDE.md "Ad Load Diagnostics" and `lib/services/ads/ad_load_stats.dart`).
GA4 → Reports → Engagement → Events → `ad_load_stats`, last 28 days (Oct 15 – Nov 11).
Screenshots `ga-11/12/13-…jpg`; verbatim tables in raw-data §C5.

## 4.1 Headline numbers (averages per `ad_load_stats` event)

| Metric (custom definition) | Avg per event | Change vs previous period |
|---|---:|---:|
| `ad_requests` | **3.9** | +33.1% |
| `ad_filled` | **0.92** | +18.4% |
| `ad_failed` | **2.9** | −37.8% |
| `ad_refresh_ok` | 0.20 | +54.1% |
| `ad_refresh_failed` | 0.11 | +13.9% |

Event count 83K from 7.3K users; 3.3 events per session.

**SDK-level fill ≈ 0.92 / 3.9 ≈ 24%.** AdMob reports a 56–59% match rate for the same period. The two
measure different things (AdMob counts banner auto-refreshes and server-side matches; the app counts
every load attempt including retries), so **reconciling them is task 2.4 in the action plan**.

**Good news in the trend:** `ad_failed` per event fell from ~5 to ~2 around **Oct 26–28**
(`ga-11-…jpg`), which lines up with the 7.4.0–7.4.3 releases (all bumped Oct 27). Something in that
release train already cut failures sharply.

## 4.2 Load attempts by format (event counts)

| `app_ad_format` | Events | Users |
|---|---:|---:|
| banner | 24K | 7.2K |
| **app_open** | **17K** | **6.9K** |
| rewarded_interstitial | 17K | 6.9K |
| rewarded | 17K | 7.0K |
| interstitial | 9.2K | 2.7K |

**App Open is loaded in ~17K sessions but AdMob shows only ~44 App Open impressions per week.**
The app preloads it on startup (`lib/main.dart:665 getIt<AdService>().preloadAppOpen()`), but the
show rule is strict (`ad_service.dart:74-76`: 4 h expiry, 30 min min gap, 30 min min away), so almost
every loaded App Open ad expires unshown. That costs requests, data and battery, and drags the
match rate down.

The strict rule is **deliberate** (comment at `ad_service.dart:61-73`): the September 2026 audit found
App Open had a 17–30% CTR — mostly players tapping at the game they'd just switched back to — while
earning ~$1.30/month. So the fix is **not** "show more App Open ads"; it's "don't request one you
almost never show" (load only when a show is actually possible), or drop the format.

## 4.3 Why loads fail — `ad_last_error` (top rows, event counts)

| Error | Events | Users | Meaning / fixable? |
|---|---:|---:|---|
| (not set) | 47K | 6.2K | No failure in that session (normal) |
| **No fill.** | **17K** | **3.9K** | No buyer. **Fixed by more demand → mediation (`03`).** |
| **Unable to obtain a JavascriptEngine.** | **6.2K** | 818 | Device's Android System WebView missing / disabled / updating. Can't fix the device; **stop retrying** for the session after this error. |
| Error while connecting to ad server: Unable to resolve host "googleads.g.doubleclick.net" | 4.6K | 1.1K | DNS blocked (Private-DNS ad blockers, network filters). Note: Russia also has exactly 4.6K `ad_load_stats` events — **verify the overlap**. Not fixable; **stop retrying**. |
| Network error. | 2.4K | 396 | Flaky connectivity. Back off. |
| (not set) *(second bucket)* | 1.8K | 414 | — |
| Internal error. | 1.5K | 489 | SDK code 0. |
| Received error HTTP response code: 400 | 444 | 51 | Bad request from our side, few users — inspect. |
| Error while connecting… connection closed / reset / abort | ~600 | ~150 | Network |
| Unable to resolve host "mediation.goog" | 249 | 45 | DNS block |
| **Error building request URL: Too many recently failed requests for ad unit ID: ca-app-pub-9242904787767… ** | **205** | **162** | **The SDK is throttling us because we retry a failing unit too often.** Fix the backoff. |
| Request Error: No ad to show. | 77 | 13 | iOS no-fill |
| **Error building request URL: Ad size will not fit on screen. a_w=800, a_h=90, s_w=360, s_h=725** (also a_w=780 on s_w=360) | 18 | 3 | **Real bug:** banner size requested wider than the screen. See `lib/widgets/ads/banner_ad_widget.dart:105-180`. |
| Publisher data not found | 3 | 1 | — |
| Ad request doesn't meet size requirements | 1 | 1 | — |

The long tail is dozens of "Failed to connect to googleads.g.doubleclick.net/<ip>" variants (network).

## 4.4 Failure codes — `ad_failure_codes` (`code:count` per session; top rows)

`3` = no fill (demand), `2` = network, `1` = invalid request, `0` = internal.

| Value | Events | Users |
|---|---:|---:|
| 0:1 | 3.2K | 914 |
| 3:1 | 2.5K | 1.1K |
| 3:4 | 2.3K | 1.1K |
| 3:3 | 2.2K | 1.0K |
| 3:2 | 2.2K | 931 |
| 3:5 | 2.0K | 914 |
| 0:4 | 1.7K | 623 |
| 0:2 | 1.6K | 583 |
| 0:3 | 1.4K | 552 |
| 0:5 | 1.3K | 557 |
| 3:6 | 1.0K | 553 |
| 2:1 | 889 | 261 |

Sessions with **10–30+ consecutive no-fills** for one format are common in the tail (e.g. `3:20,1:2`,
`3:31,1:2`, `0:47`) — evidence of repeated retries against a unit that isn't going to fill.
Also note `1:x` (invalid request) appears alongside high `3:x` counts (`3:12,1:4`, `3:14,1:2`) — probably
the SDK's "too many recently failed requests" throttle surfacing as code 1.

## 4.5 Game-over full-screen ads: designed vs actual

Current rule (`lib/services/ads/game_over_ad_gate.dart` + `ad_service.dart:45-59`):
- never on the first game-over of an install;
- every **2nd** game-over (`_interstitialEveryNGames = 2`);
- ≥ **90 s** since the last interstitial, ≥ **2 min** since any full-screen ad;
- prefer a loaded **rewarded interstitial** (with the required intro screen), else interstitial.

Actual (last 7 days): interstitial **213** + rewarded interstitial **866** = **1,079** full-screen ads
at game-over, against **~10,860 game-overs per week** (`game_over` 43,442 in 28 d).
→ **~1 in 10 game-overs**, vs a design ceiling near 1 in 2.

Plausible causes (not yet measured — instrument first, see task 3):
1. **Revive watches consume the slot (likely the biggest factor).** The code comment at
   `ad_service.dart:53-58` says "A revive is offered on nearly every crash", and any rewarded watch
   starts the **2-minute shared full-screen gap**. With games averaging well under 2 minutes, a revive
   watch usually blocks the following game-over ad. This is by design (anti-"ad ambush"), but it
   means revive revenue and game-over revenue trade off against each other.
2. Rewarded-interstitial **intro is skipped** by many players (it must be skippable by policy).
3. **Not loaded** in time (no fill / failures above).
4. **Pro users** and **first game-over** excluded.
5. Players with very short sessions never reach the cadence (the code comment at
   `ad_service.dart:40-44` notes only ~22% of players ever reach a fifth game).

Do **not** raise frequency until you know which of these dominates; retention is already weak.

## 4.6 Rewarded behaviour

- `rewarded_ad_completed` **4,651** (1,542 users) vs `rewarded_ad_abandoned` **1,932** (745 users)
  → **29% of started rewarded ads are abandoned.**
- `ad_reward` 4,837 (1,630 users) → only **~13% of users** earn a rewarded reward in 28 days.
- Existing rewarded placements: named constants `free_coins` (25 coins), `free_powerup`, `bp_xp`,
  `tournament_entry` (`ad_service.dart:1576-1582`), **plus revive and time-bonus** placements in the
  game flow (`lib/widgets/revive_overlay.dart`, `lib/widgets/game_over_continue_sheet.dart`,
  `lib/widgets/time_bonus_overlay.dart`; "revive/time-bonus once per run", `ad_service.dart:1569`).
  So a revive already exists — the opportunity is *more reasons to watch* outside the run
  (e.g. double the run's coins at game-over, daily-bonus ×2, store "free item"), not another revive.
- History in code comments: a **September 2026 AdMob audit** found 91K rewarded requests for 8K
  impressions (show rate ~8–11%), which is why `_rewardedBufferTarget` was cut to 1 (`ad_service.dart:91-97`).

## 4.7 Clicks

`ad_click` 2,308 events (851 users) vs `ad_impression` 67,976 → **3.4% of impressions are clicked**.
That includes full-screen formats (which click more — App Open historically 17–30% per the code
comment above), but it's high for a banner-heavy mix. The
gameplay banner sits at the **top** of the game screen (`lib/screens/game_screen.dart:715`,
`LBBannerSlot(topGap: 12, atTop: true)`), away from the D-pad. Still worth splitting clicks by format
(AdMob report: Format × Clicks / CTR) to rule out accidental taps — AdMob treats unusual CTR as an
invalid-traffic risk.
