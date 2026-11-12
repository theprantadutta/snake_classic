# 03 — Mediation: The Auction Has One Buyer

## 3.1 Plain-English explainer (for the owner)

Every time the app asks for an ad, AdMob runs an **auction** to decide who fills it.

- **Bidding sources** are ad networks that bid live in that auction (real-time bidding). More
  bidders means more competition, which means higher prices and fewer empty slots.
- **Waterfall sources** are networks asked one by one, in a fixed eCPM order, when bidding doesn't
  fill. Older approach; useful as a backstop.
- **Mediation groups** decide *which* sources compete for *which* ad units (by format, platform,
  country). An ad unit that matches no group goes to the default "AdMob" group.
- **Ad unit mapping** is the link between your AdMob ad unit and the partner network's own
  placement ID. **A partner with no mapping can't bid**, even when the partnership is "Active".

## 3.2 What is configured today

### Bidding sources (`admob-07/08/09-…jpg`, raw-data §A5)

| Source | Relationship | Partnership | Ad unit mappings (Snake Classic Android / iOS) | Mappings for any other app |
|---|---|---|---|---|
| AppLovin | Direct | **Active** | **0 / 0** | 0 for every app viewed (18 apps) |
| Liftoff Monetize (BETA) | Direct | **Active** | **0 / 0** | 0 for every app viewed |
| Unity Ads | Direct | **Active** | **0 / 0** | 0 for every app viewed |
| AdMob Network | — | 407 authorized buyers | not required | — |

### Waterfall sources (`admob-05-waterfall-sources-empty.jpg`)

> "Ad sources will appear here when you add a third party ad network." — **empty.**

### Mediation groups (`admob-04-mediation-groups.jpg`, raw-data §A5)

| Priority | Group | Status | Est. earnings (7 d) | Impressions (7 d) | A/B test |
|---|---|---|---:|---:|---|
| 1 | `rewarded_ad` | Enabled | $10.28 (−12.79%) | 1.25K (+3.30%) | none |
| 2 | `banner_ad` | Enabled | $3.23 (−5.22%) | 16K (+11.10%) | none |
| 3 | `interestitial` *(typo in name)* | Enabled | $1.03 (+38.16%) | 202 (+27.85%) | none |
| 4 | `app_open_ad` | Enabled | **$0.00** | **0** | none |
| 5 | (fifth group, off-screen — likely rewarded interstitial) | — | — | — | — |

Groups are **shared across apps**. Example — `rewarded_ad` (ID `1015880624`, Rewarded, Android, all
countries) contains: `daily_limit_rewarded` (AI Persona), `rewarded_ad` (Odyssey), `rewarded_ad`
(Snake Classic), all with eCPM floor "Google optimized (All prices)".
**Its only bidding source is AdMob Network; its waterfall is empty** (`admob-06-…jpg`).

Note: AdMob shows 44 App Open impressions in 7 days on the home page, but the `app_open_ad` group
shows 0 — so App Open traffic is not matching that group (probably served by the default AdMob
group). Worth checking the group's platform / ad-unit list.

## 3.3 Why this matters

- With one bidder, AdMob Network wins every auction at whatever price it chooses — no competition.
- About **41–44% of requests come back empty** at AdMob level (match rate 56–59%), and the app's
  own telemetry shows "No fill." as the single biggest named failure (17K events, 3.9K users — `04`).
  More demand sources are the standard fix for no-fill.
- India + Brazil are ~35% of users. Networks like **Pangle, Mintegral, Meta Audience Network** and
  **InMobi** are often strong there; consider them after the three already-partnered networks.

## 3.4 What turning it on involves (outline — full steps in `07-action-plan.md` → Task 1)

1. **Partner dashboards** (owner): make sure each network has the app and placements per format;
   collect the IDs (AppLovin SDK key; Unity Game ID + placement IDs; Liftoff app ID + placement refs).
2. **AdMob → Bidding sources → (network) → Ad unit mapping** (owner): map each Snake Classic ad unit
   (banner, interstitial, rewarded, rewarded interstitial, app open; Android **and** iOS).
3. **AdMob → Mediation groups** (owner): add each network as a *bidding* source in every group.
4. **App code** (agent): add the official Google mediation adapter packages for Flutter
   (`gma_mediation_applovin`, `gma_mediation_unity`, `gma_mediation_liftoffmonetize` — verify the
   current names and latest versions on pub.dev and read changelogs; match the `google_mobile_ads`
   major, currently `^9.0.0`), plus native platform requirements (iOS `SKAdNetworkItems`, Android
   gradle repos if required), and confirm consent (UMP/TCF) is forwarded to each adapter.
5. **app-ads.txt** (owner): add each partner's lines to the developer-website `app-ads.txt`
   (AdMob → Apps → app-ads.txt shows the status). Without them, partner demand gets discounted.
6. **Verify** with AdMob Ad Inspector on a test device, then watch AdMob → Reports → Mediation
   for a week (per-source requests / match rate / eCPM).
