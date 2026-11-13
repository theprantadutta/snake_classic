# AdMob mediation partners

Shared by **every app** the owner publishes: they all sit in one AdMob account
(publisher `ca-app-pub-9242904787767394`), so a partner's account, its
`app-ads.txt` lines and its AdMob bidding source are shared too. Each app still
needs its own placements and ad-unit mappings.

Last updated: 2026-11-13. Snake Classic is the first app being wired up.

## Why this exists

The November 2026 monetization audit (`reports/2026-11-12-monetization-audit/`)
found AdMob Network was the **only bidder** in every mediation group. AppLovin,
Unity Ads and Liftoff showed "Active partnership" under AdMob → Mediation →
Bidding sources, but each had **0 ad-unit mappings for all 18 apps**, so none of
them could bid. With one buyer, ~41–44% of requests came back empty (AdMob match
rate 56–59%). More bidders is the standard fix for no-fill and price.

## Status per partner

### AppLovin: blocked (account disabled)
- 2026-11-13: dashboard login says "Your account is currently disabled. We're not
  able to reactivate it at this time." No email had ever said it was approved,
  under review or disabled. Most likely cause: the account sat idle with no
  integration (0 mappings everywhere). The owner did nothing wrong.
- `support@applovin.com` is **unmonitored** (auto-reply). AppLovin support now runs
  under the **Axon** brand: ticket form `https://ads.axon.ai/support/contact-us`
  (redirects to `ads.applovin.com/support/contact-us`), chatbot at
  `https://support.axon.ai`.
- **Ticket filed 2026-11-13: AppLovin Support request #136960** (applovin.zendesk.com, category "Monetization (non-MAX)", signed in as the owner). Replies go to prantadutta1997@gmail.com.
- Do **not** open a new AppLovin account to get around it; networks treat that as
  evasion.
- In the app: `gma_mediation_applovin` was removed. If reinstated, add it back at
  the version built for the app's `google_mobile_ads` (see its CHANGELOG), map the
  units, and add AppLovin to `app-ads.txt`. AppLovin bids on interstitial, rewarded
  and App Open, **not banner**.

### Unity Ads: in progress
- Account: Unity org `prantadutta1997` (cloud.unity.com, org id 18968547514182).
- Snake Classic: Unity project "Snake Classic" created 2026-11-13. Next: add the
  Android app (Play URL `.../details?id=com.pranta.snakeclassic`; check the store
  lookup shows "Snake Classic: Retro Arcade", it once resolved to the wrong app
  `com.pra`), create **bidding** placements for banner, interstitial and rewarded,
  then map them in AdMob. Waterfall is retired at Unity (Jan 2026), so bidding only.
- Declined Unity's "Developer Data" sharing on purpose; mediation doesn't need it.
- Formats via bidding: banner, interstitial, rewarded (no App Open, no rewarded
  interstitial).
- App side: `gma_mediation_unity`. No Dart code; consent comes from UMP/TCF.

### Liftoff Monetize (formerly Vungle): unknown
- `signin.liftoff.io` is **Liftoff Accelerate** (advertisers): "no active user for
  this email". The publisher dashboard is `publisher.vungle.com`, which refuses to
  load while the browser's ad blocker is on. Whether a Monetize account exists is
  still unknown.
- Formats via bidding: all, including App Open; rewarded interstitial needs
  Liftoff's account manager to enable it.
- App side: `gma_mediation_liftoffmonetize`.

## Setting up a partner for an app (checklist)

1. Partner dashboard: add the app (store URL), create one **bidding** placement per
   format the partner supports, note the IDs (Unity: Game ID + placement IDs;
   Liftoff: App ID + placement reference IDs).
2. AdMob → Mediation → Bidding sources → (partner) → **Ad unit mapping**: map every
   ad unit of the app, Android and iOS.
3. AdMob → Mediation → **Mediation groups**: add the partner as a bidding source in
   each group the app's units are in (groups are shared across apps; the mappings
   decide which apps a partner actually bids for).
4. AdMob → Privacy & messaging: make sure the partner is in the GDPR and US-states
   ad-partner lists.
5. Add the partner's lines to the developer website's `app-ads.txt`.
6. App: add the official `gma_mediation_<partner>` package at the version matching
   the app's `google_mobile_ads`; iOS also needs the partner's SKAdNetwork IDs in
   `Info.plist` and a `pod install` (macOS).
7. Verify with AdMob **Ad Inspector** on a registered test device, then watch AdMob
   → Reports → **Mediation** for a week (per-source requests, win rate, eCPM).

## Snake Classic ad units (AdMob)

| Format | Android | iOS |
|---|---|---|
| App ID | `ca-app-pub-9242904787767394~9115144122` | `ca-app-pub-9242904787767394~3519202517` |
| Banner | `/3016639636` | `/3952271184` |
| Interstitial | `/6572741266` | `/9378033857` |
| Rewarded | `/7829982619` | `/3896430862` |
| Rewarded interstitial | `/8753884101` | `/3391193437` |
| App Open | `/2112367445` | `/9799285770` |

(Unit IDs are `ca-app-pub-9242904787767394` + the suffix; source of truth is
`lib/services/ads/ad_config.dart`.)

## Baseline to measure against (AdMob, 7 days to 2026-11-12)

Revenue $20.23 · match rate 56.38% · eCPM $1.09 (peers $2.17) · banner eCPM
$0.20–0.22.
