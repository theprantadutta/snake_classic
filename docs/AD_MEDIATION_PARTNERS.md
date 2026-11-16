# AdMob mediation partners

Shared by **every app** the owner publishes: they all sit in one AdMob account
(publisher `ca-app-pub-9242904787767394`), so a partner's account, its
`app-ads.txt` lines and its AdMob bidding source are shared too. Each app still
needs its own placements and ad-unit mappings.

Last updated: 2026-11-16. Snake Classic is the first app being wired up.

**Any agent picking this up:** read the quick status below, then the section for
the partner you are touching. Before changing anything, check Gmail
(`from:(applovin OR axon OR unity OR liftoff OR vungle OR indexexchange OR magnite) newer_than:14d`)
and ask the owner for news; partners answer by email. The owner's Chrome runs an
ad blocker that breaks these dashboards and sign-up forms: ask them to turn it
off for the site rather than working around it. Partner agreements, terms
checkboxes and COPPA / child-directed declarations are signed by the **owner**,
never by an agent.

## Quick status (2026-11-16)

| Partner | Kind | Status | App code needed |
|---|---|---|---|
| AdMob Network | Google | Live everywhere | — |
| Unity Ads | SDK bidding | **Live** Snake Android; iOS set up | `gma_mediation_unity` |
| Liftoff Monetize | SDK bidding | **Live** Snake Android; iOS set up | `gma_mediation_liftoffmonetize` |
| AppLovin | SDK bidding | **Closed**: account disabled, reactivation refused 2026-11-16 | don't add |
| Index Exchange | Open Bidding (no SDK) | **Applied 2026-11-16** (redone via AdMob View & sign; now listed in AdMob) | none |
| Magnite DV+ | Open Bidding (no SDK) | **Applied + acknowledged 2026-11-16**, pending Magnite review (1–2 weeks) | none |
| OpenX | Open Bidding (no SDK) | **Applied + acknowledged 2026-11-16** (13 apps; Gridwell iOS rejected) | none |
| PubMatic | Open Bidding (no SDK) | **Applied + contract signed 2026-11-16** (14 apps) | none |
| Verve Group | Open Bidding (no SDK) | **Applied 2026-11-16** | none |
| Smaato | Open Bidding (no SDK) | **Applied 2026-11-16** | none |
| InMobi Exchange | Open Bidding (no SDK) | **Accepted 2026-11-16**, listed in AdMob | none |
| Equativ | Open Bidding (no SDK) | **Submitted 2026-11-16**; not yet listed in AdMob (see note) | none |
| Other Open Bidding exchanges | Open Bidding (no SDK) | Not started; see the list below | none |
| Meta Audience Network, Mintegral, Pangle | SDK bidding | **Planned next** (owner agreed 2026-11-16) | one adapter each |

## Why this exists

The November 2026 monetization audit (`reports/2026-11-12-monetization-audit/`)
found AdMob Network was the **only bidder** in every mediation group. AppLovin,
Unity Ads and Liftoff showed "Active partnership" under AdMob → Mediation →
Bidding sources, but each had **0 ad-unit mappings for all 18 apps**, so none of
them could bid. With one buyer, ~41–44% of requests came back empty (AdMob match
rate 56–59%). More bidders is the standard fix for no-fill and price.

## Status per partner

### AppLovin: closed (account disabled, reactivation refused 2026-11-16)
- 2026-11-13: dashboard login says "Your account is currently disabled. We're not
  able to reactivate it at this time." No email had ever said it was approved,
  under review or disabled. Most likely cause: the account sat idle with no
  integration (0 mappings everywhere). The owner did nothing wrong.
- `support@applovin.com` is **unmonitored** (auto-reply). AppLovin support now runs
  under the **Axon** brand: ticket form `https://ads.axon.ai/support/contact-us`
  (redirects to `ads.applovin.com/support/contact-us`), chatbot at
  `https://support.axon.ai`.
- **Ticket filed 2026-11-13: AppLovin Support request #136960** (applovin.zendesk.com, category "Monetization (non-MAX)", signed in as the owner). Replies go to prantadutta1997@gmail.com.
- **Answer, 2026-11-16 (ticket #136960):** AppLovin is "not accepting new MAX account
  registrations or reactivating previously disabled accounts", with no timeline;
  "check back periodically". No reason was given for the disabling. Treat AppLovin as
  unavailable for every app; Unity and Liftoff cover mediation. Maybe ask again in a
  few months.
- Do **not** open a new AppLovin account to get around it; networks treat that as
  evasion.
- In the app: `gma_mediation_applovin` was removed. If reinstated, add it back at
  the version built for the app's `google_mobile_ads` (see its CHANGELOG), map the
  units, and add AppLovin to `app-ads.txt`. AppLovin bids on interstitial, rewarded
  and App Open, **not banner**.

### Unity Ads: LIVE for Snake Classic Android (2026-11-13)
- Account: Unity org `prantadutta1997` (cloud.unity.com, org id 18968547514182).
- Snake Classic Android, done 2026-11-13: Unity project "Snake Classic", app
  "Snake Classic: Retro Arcade" (Google Play, not child-directed, matching Play
  Console's 13+ target age). **Game ID `800436806`**. Bidding placements
  `BP_Banner_Android`, `BP_Interstitial_Android`, `BP_Rewarded_Android`, mapped in
  AdMob to `banner_ad`, `interstitial_ad`, `rewarded_ad` and added to the
  `banner_ad`, `interestitial`, `rewarded_ad` mediation groups (all green).
- Snake Classic iOS, done 2026-11-13: app "Snake Classic: Retro Arcade" (App Store
  id 6779621362, not child-directed). **Game ID `800436843`**. Placements
  `BP_Banner_iOS`, `BP_Interstitial_iOS`, `BP_Rewarded_iOS`, mapped to the iOS
  `banner_ad`, `interstitial_ad`, `rewarded_ad` units. The account had no iOS
  mediation groups at all, so three were created: `banner_ad_ios`,
  `interstitial_ios`, `rewarded_ad_ios` (AdMob Network + Unity Ads bidding).
  iOS only starts using them once an iOS build with the adapters ships.
- Unity's "Developer website" (Monetization > Settings > Organization) is
  `https://pranta.dev`; on 2026-11-14 Unity reported the app-ads.txt at
  https://pranta.dev/app-ads.txt as up to date.
- `app-ads.txt`: the full Unity block (unity.com, 162886020, DIRECT plus 162
  resellers, exactly as the dashboard lists them) is in Snake's backend
  `wwwroot/app-ads.txt` (snakeclassic.pranta.dev) and the portfolio
  `static/app-ads.txt` (pranta.dev). Live once both are redeployed.
- Waterfall is retired at Unity (Jan 2026), so bidding only.
- Declined Unity's "Developer Data" sharing on purpose; mediation doesn't need it.
- Formats via bidding: banner, interstitial, rewarded (no App Open, no rewarded
  interstitial).
- App side: `gma_mediation_unity`. No Dart code; consent comes from UMP/TCF.

### Liftoff Monetize (formerly Vungle): LIVE for Snake Classic Android, set up for iOS (2026-11-13)
- `signin.liftoff.io` is **Liftoff Accelerate** (advertisers): "no active user for
  this email". The publisher dashboard is `publisher.vungle.com`, which refuses to
  load while the browser's ad blocker is on. With it off, it redirects to the
  **sign-up** page for prantadutta1997@gmail.com: no Monetize account exists. On
  2026-11-13 the sign-up form was filled in (Android, com.pranta.snakeclassic,
  company Pranta Dutta, pranta.dev, Bangladesh); the owner sets the password and
  submitted it; the account was approved the same day.
- Snake Classic Android: Liftoff **App ID `6af6ab95b828b7d5f62ccd4b`**, In-App
  Bidding placements (reference IDs): banner `SNAKE_BANNER_BIDDING-2700000`,
  interstitial `SNAKE_INTERSTITIAL_BIDDING-9402391`, rewarded
  `SNAKE_REWARDED_BIDDING-7710171`, App Open `SNAKE_APPOPEN_BIDDING-4045837`.
  (Liftoff also auto-created a `default` interstitial, `DEFAULT-2190977`,
  bidding off; it is unused.) All four are mapped in AdMob and added to the
  `banner_ad`, `interestitial`, `rewarded_ad`, `app_open_ad` groups.
- Adding App Open put Snake's App Open unit into the `app_open_ad` group for the
  first time: it had never been in it (the audit's "app_open_ad group shows 0"),
  so App Open had been served by AdMob's default group.
- Rewarded interstitial is not offered for self-serve; ask Liftoff
  (monetize@liftoff.io) to enable it, then map `rewarded_interstitial_ad`.
- app-ads.txt line: `vungle.com, 6af6a1a0efb36623c25ff32e, DIRECT, c107d686becd2d77`
  (Liftoff validates it on pranta.dev before serving). In both app-ads.txt files.
- Snake Classic iOS, done 2026-11-13: "Snake Classic iOS" (App Store id
  6779621362), Liftoff **App ID `6af6bd699b6208a5310feaed`**, In-App Bidding
  placements: banner `SNAKE_BANNER_BIDDING-9645199`, interstitial
  `SNAKE_INTERSTITIAL_BIDDING-9147400`, rewarded `SNAKE_REWARDED_BIDDING-5585743`,
  App Open `SNAKE_APPOPEN_BIDDING-4437907` (plus an unused auto-created `default`,
  `DEFAULT-3584867`, bidding off). All four are mapped to the iOS units and added to
  `banner_ad_ios`, `interstitial_ios`, `rewarded_ad_ios` and a new **`app_open_ios`**
  group (3160260662; AdMob Network + Liftoff). The Snake iOS App Open unit is named
  "Snake Classic Android — App Open" in AdMob even though it belongs to the iOS app;
  rename it in AdMob → Apps if that confuses anyone. Live only once an iOS build
  with the adapter ships (see CLAUDE.md, macOS checklist).
- Adding an app in Liftoff asks for a COPPA (child-directed) declaration; the owner
  answers that one personally.
- Formats via bidding: all, including App Open; rewarded interstitial needs
  Liftoff's account manager to enable it.
- App side: `gma_mediation_liftoffmonetize`.

## iOS verification on macOS (2026-11-13, for 7.6.0+74)

The CLAUDE.md macOS checklist, step by step:

1. **Sync:** both repos pulled; Flutter 3.50.0 (Dart 3.14.0); `flutter clean` +
   `flutter pub get` OK.
2. **Dependencies:** there is no CocoaPods here. The iOS project uses Swift Package
   Manager, and both adapters resolve through it on the first build:
   `googleads-mobile-ios-mediation-unity` (with `unity-ads-swift-package`) and
   `vungleadssdk-swiftpackagemanager`. The release app bundles
   `UnityAdapter`, `UnityAds`, `LiftoffMonetizeAdapter` and `VungleAdsSDK`.
   The two `Package.resolved` files are committed. Deployment target 15.0.
3. **SKAdNetwork IDs:** all 76 of Unity's and all 50 of Google's were already in
   `Info.plist`. Liftoff's list (its official XML,
   `vungle-static-assets.s3.amazonaws.com/dashboard/admin/prod/skadnetworkids.xml`,
   dated 2026-02-02, linked from the iOS integration page) had 15 more; added, now
   171, no duplicates, `plutil -lint` OK. Liftoff's file also lists 2
   AdAttributionKit IDs (`AdNetworkIdentifiers` key); not added, optional.
4. **Build:** `flutter build ios --release` OK, no adapter or version errors.
   On the iOS simulator (debug) Unity logs "Initializing SDK 4.21.0 with game id
   800436843 ... Initialized successfully"; startup, home, a game, game over and
   the menu all ran with no errors. `flutter analyze` clean, 949 tests pass.
5. **Real-device Ad Inspector check:** not done. No iPhone was connected, and the
   owner chose to ship 7.6.0+74 without it. Do it on the next macOS session with a
   device, and meanwhile watch AdMob → Reports → Mediation (iOS) for Unity and
   Liftoff requests once 7.6.0 is live: zero requests after a few days points at
   a mapping or adapter problem.
6. **Consent (UMP) check:** not done, same reason.
7. **Ship:** `./tools/release_ios.sh` built 7.6.0+74 (171 SKAdNetwork IDs and all
   four adapter frameworks in the IPA, Apple Distribution signature valid) and
   uploaded its Dart symbols and dSYMs to Sentry.

## Open Bidding exchanges (no SDK, no app update)

AdMob lists 42 bidding sources under Mediation → Bidding sources → **Set up ad
source**. About half are "Open Bidding" exchanges: they buy through Google's
servers, so they need no adapter, no app release and no extra download size, and
they are paid out **by Google** with the normal AdMob payment. Because the account
is shared, one approval covers every app listed in the application.

### How to add one
1. AdMob → Mediation → Bidding sources → **Set up ad source** → pick the exchange →
   **Next**. The dialog has two steps.
2. **Sign partnership agreement** → **View & sign** opens the exchange's own
   sign-up page in a new tab. Keep the AdMob tab open, and the ad blocker off.
   Fill in the form (details below); the **owner** ticks the terms boxes and
   submits, since it is a contract in their name.
3. The exchange reviews it, which takes days, and some decline small publishers.
   The approval arrives by email.
4. Back in the same AdMob dialog: **Acknowledge bidding agreement**.
5. Add the exchange to the mediation groups as a bidding source, and add any
   `app-ads.txt` line it asks for to pranta.dev and to each app's own site.
6. Watch AdMob → Reports → Mediation (Ad source) for its requests and wins.

### What the forms ask for
- Contact: Pranta Dutta, owner, prantadutta1997@gmail.com. Phone and postal address
  (Chattogram, Bangladesh) come from the owner; don't commit them here.
- Company "Pranta Dutta" (sole developer), website https://pranta.dev, country
  Bangladesh, privacy policy https://legal.pranta.dev/privacy.
- Google Publisher ID `pub-9242904787767394` (AdMob, not Ad Manager; no GAM
  network code).
- Apps: the 14 apps that have a store listing (table below). Android uses the
  package name; iOS uses the numeric App Store ID, with store URL
  `https://apps.apple.com/app/id<ID>`.
- Some forms ask for monthly ad requests per app. Use AdMob → Reports → Ads
  Activity → Mediation, last 30 days, by app.

### App inventory for these forms (2026-11-16)

Monthly requests = AdMob requests over the 30 days to 2026-11-16.

| App | Platform | Store ID | Monthly requests |
|---|---|---|---|
| Snake Classic: Retro Arcade | Android | com.pranta.snakeclassic | 370,592 |
| Snake Classic: Retro Arcade | iOS | 6779621362 | 4,025 |
| AI Persona: Character Chat | Android | com.pranta.aipersona | 635 |
| Cosmo Strike | Android | com.pranta.cosmostrike | 4 |
| Cosmo Strike | iOS | 6824382793 | 60 |
| Gridwell: Nonogram Puzzles | iOS | 6834377123 | 3 |
| Odyssey Trip Planner & Journal | Android | com.pranta.odyssey | 13 |
| Odyssey: Travel Journal | iOS | 6789549164 | 0 |
| Pourfect: Ball Sort Puzzle | Android | com.pranta.pourfect | 258 |
| Pourfect: Ball Sort Puzzle | iOS | 6824137375 | 94 |
| Screw Out | Android | com.pranta.screwout | 1,730 |
| Sunstone: Maya Temple Runner | Android | com.pranta.sunstone | 344 |
| The Accountant: Money Manager | Android | com.pranta.theaccountant | 1 |
| The Accountant: Money Manager | iOS | 6794265000 | 0 |

Left out because AdMob shows them "Requires review" with no store linked: AI Persona
iOS, Gridwell Android, Jadewell Android + iOS, Screw Out iOS, SunStone iOS. Add
them to each exchange once they are live in their stores.

### Status per exchange
- **Index Exchange** (signup.indexexchange.com): applied 2026-11-16 with all 14
  apps. The IX page showed success, but no email came, and IX is still in AdMob's
  "Set up ad source" list (Magnite left it once its agreement registered). The
  form was submitted from a plain signup.indexexchange.com tab, not the one AdMob's
  "View & sign" opened, so the link may not have registered. If IX stays listed
  for a few days, redo it through AdMob's View & sign. IX says activation can
  take ~48 h.
- **OpenX** (contracts.openx.com): form filled 2026-11-16 (company, website, email;
  account type and publisher ID come prefilled from AdMob). Bundles go in as a
  one-column CSV with no header, one bundle per row. OpenX rejected Gridwell iOS
  (6834377123, "bundle does not exist") although it is live on the App Store
  (newly released, probably not in OpenX's catalog yet), so it went in with 13;
  add Gridwell later. The
  owner ticks the terms box and submits.
- **Magnite DV+** (cta.magnite.com): **submitted and acknowledged in AdMob
  2026-11-16**; AdMob shows "Pending partnership". Magnite's email says review
  takes ~1–2 weeks; support obsupport@magnite.com (quote the publisher ID).
  app-ads.txt line `rubiconproject.com, 22884, DIRECT, 0bfd66d529a55807` is on
  pranta.dev (portfolio b477c89) and snakeclassic.pranta.dev (backend de1f576);
  **each other app's own site still needs it** (cosmo-strike, Gridwell, odyssey,
  Pourfect, screw-out, Sunstone, the-accountant backends' `wwwroot/app-ads.txt`).
  The Unity block already has `rubiconproject.com` RESELLER lines; Magnite's own
  DIRECT line is separate, so add it even if rubiconproject is present.
  Form filled with all 14 apps
  (category Arts & Entertainment; Odyssey = Travel; The Accountant = Personal
  Finance; formats Display, Interstitial Display, Interstitial Video, and
  Outstream Rewarded for apps with rewarded ads). The owner ticks the terms box
  and submits. Odyssey iOS was entered as 1 monthly request (real number 0).
  Form quirks: **Add App** does nothing until every field above it is filled;
  each app is saved by clicking Add App, which is slow, so wait ~6 s between
  apps; values set by script alone are lost, so use real input events.
- **OpenX:** submitted and acknowledged 2026-11-16 (see above).
- **PubMatic** (onboarding.pubmatic.com): **submitted 2026-11-16**. Blocked by the ad
  blocker until the owner turned it off. Two pages: an application (rep assisting:
  **No**; the radio defaults to Yes and a click on the tiny input doesn't register,
  so click the "No" label text; region APAC; inventory Both; monthly impressions
  "> 10,000"; top geographies all four regions; app-ads.txt URLs pranta.dev and
  snakeclassic.pranta.dev; apps as full store URLs, one per line), then a 12-month
  service order (Google pays; PubMatic may claw back "Charged Adjustments"
  directly). The owner signs it. Support: admobsupport@pubmatic.zendesk.com.
- **Verve Group** (c2a.verve.com): **submitted 2026-11-16**. Same form shape as
  Smaato: name, address split over two lines, email, app-ads.txt link
  (https://pranta.dev/app-ads.txt), publisher ID (prefilled), store URLs one per
  line, monthly active users **11000** (Firebase, Snake Classic, 30 days to
  2026-11-15: 11K; 7 days 3.2K; 1 day 680). The owner ticks the declarations
  (accept AdMob contract, will add their app-ads.txt lines, GDPR TCF v2 via UMP)
  and does the reCAPTCHA. Verve sends its app-ads.txt lines once live.
- **Smaato** (smaato.com/request-page): form filled 2026-11-16 the same way, plus a
  "Smaato DPA contract" checkbox for the owner. Cookie banner: Reject All.
- **Smaato:** submitted 2026-11-16 (owner ticked the declarations and DPA).
- **InMobi Exchange** (inmobi.com/google-open-bidding): sign-up creates a free InMobi
  SSP account (publisher.inmobi.com, account "Pranta Dutta"; the owner set the
  login). Form: name, email, company, country Bangladesh, industry Gaming,
  "Number of App Installs" Yes/No. After sign-up AdMob did not list InMobi as a
  bidding source yet; check again in a few days, and redo View & sign if it is
  still missing. The dashboard's Quick Start (add inventory, payment details, SDK)
  is for InMobi's own SDK/oRTB business; Open Bidding is paid by Google, so skip
  it unless InMobi asks. app-ads.txt line (Inventory > app-ads.txt, "Only InMobi"):
  `inmobi.com, 85403fc616154ee1b41247e0388c1af0, DIRECT, 83e75a7ae333ca9d`, added
  to pranta.dev (portfolio 2922455) and snakeclassic.pranta.dev (backend fa22568);
  other apps' sites still need it.
- **Index Exchange retry (2026-11-16):** the first application (plain tab) never
  registered in AdMob. Redone from AdMob's own View & sign link; it then appeared
  in AdMob's bidding sources at once. **Lesson: always submit these forms from the
  tab AdMob opens**, never a re-typed URL.
- **Equativ** (equativ.com/ob-onlineonboarding): the form is a Pardot iframe
  (go.smartadserver.com/l/311061/2021-12-08/2mkfcxv) that the ad blocker hides.
  It was filled by opening the iframe URL directly, which may have cut the link to
  AdMob (like the first IX attempt): after submit Equativ showed its FAQ, but AdMob
  did not list Equativ. If it is still missing in a day or two, redo it from AdMob's
  View & sign and fill the form **inside** the equativ.com page. Fields: contact,
  address in one box, HQ country, publisher ID, app-ads.txt URLs, formats (Banner,
  Video, Rewarded), monthly requests per region (free text), bundles one per line,
  rep assisting No, then the owner ticks the RTB + Services Agreement and privacy
  boxes. Review takes ~7 days. app-ads.txt lines (both added: portfolio 6449320,
  backend e6e10c8): `smartadserver.com, 4194-OB, RESELLER, 060d053dcf45cbf3` and
  `smartadserver.com, 4194, RESELLER, 060d053dcf45cbf3` (the -OB stays upper case).
- **After an exchange shows "Active partnership":** add it as a bidding source to
  the mediation groups (banner_ad, interestitial, rewarded_ad, app_open_ad and the
  _ios groups); until then it is not in any auction.
- **Next, in order:**
  Equativ, Media.net, TripleLift. Then optionally Adagio, Bidease, EMX, Improve
  Digital, MobFox, Nexxen, OneTag, Rise, Sonobi, Yieldmo, Chocolate Platform.
  Japan-focused, skip: Ad Generation, Fluct, YieldOne.

## SDK networks: plan for the next app release

Each needs its own account (the owner signs up and answers the COPPA question),
an app in its dashboard with bidding placements, AdMob ad-unit mapping, its
`app-ads.txt` lines, its `gma_mediation_<network>` package at the version matching
`google_mobile_ads`, and its SKAdNetwork IDs on iOS. Each also adds roughly
5–15 MB and more startup code, so add them in one release and stop at three.

| Network | Formats (bidding) | Why |
|---|---|---|
| Meta Audience Network | banner, interstitial, rewarded, rewarded interstitial, native | Usually the strongest after AdMob; needs a Meta Business account + app review |
| Mintegral | app open, banner, interstitial, rewarded, native | Strong for games; one of few that bid on App Open |
| Pangle (TikTok) | app open, banner, interstitial, rewarded, native | Strong for games, especially Asia; large SDK |

Second tier if those disappoint: InMobi (SDK), DT Exchange, ironSource Ads
(separate account from Unity Ads). Not worth it: Moloco (waterfall only for
Flutter), Chartboost / myTarget / Vpon (waterfall only), maio / i-mobile / Zucks
(Japan only). Source: developers.google.com/admob/flutter/choose-networks.

Wait for the 2026-11-20 week-over-week check (Unity + Liftoff vs the baseline at
the bottom) before adding SDK networks, so their effect is measurable.

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
   `Info.plist`. The iOS adapters come in through Swift Package Manager on the next
   `flutter build ios` (no `pod install`); commit the updated `Package.resolved`.
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
