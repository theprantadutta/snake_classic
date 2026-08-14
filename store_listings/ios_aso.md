# App Store (iOS) ASO — strategy

## Why iOS ≠ Play

On Google Play the full 4000-char description **is** indexed — that's why `en.md` ranks
there. On the App Store the description is **not indexed at all**. Apple only indexes:

| Field | Limit | Weight |
|---|---|---|
| App Name (title) | 30 | highest |
| Subtitle | 30 | high |
| Keyword field | 100 | medium |
| Developer name | — | low |
| In-App Purchase display names | 30 each | low |
| In-App Event name + descriptions | 30 / 50 / 120 | medium |

`store_listings/README.md` says the App Store "uses the same copy" as Play. That's the
bug. It leaves us with `Snake Classic` (13 of 30 chars) plus a subtitle trimmed from the
Play short description, and an **empty keyword field** — because Play has no equivalent
field, so nobody ever wrote one. ~15 indexed characters competing for "snake" against
apps using all 160.

Apple auto-generates keyword **combinations** across name + subtitle + keywords, so never
repeat a word between the three fields — a repeat is wasted space.

**Each localization has its own independent keyword field.** Nine localizations = nine
separate 100-char keyword fields, each serving its own storefronts. This is the single
biggest lever we have and it currently sits at zero.

---

## Which locales actually matter (GA4, Jul 10 – Aug 6 2026, 5,623 active users / 166 countries)

| # | Country | Active users | Share | Revenue share | Locale |
|---|---|---|---|---|---|
| 1 | India | 1,161 | 20.65% | 4.7% | en-GB (+ Hindi) |
| 2 | Brazil | 580 | 10.31% | 14.0% | pt-BR |
| 3 | Russia | 330 | 5.87% | 0% | ru |
| 4 | Mexico | 171 | 3.04% | 4.3% | es-MX |
| 5 | Pakistan | 157 | 2.79% | 0.3% | en-GB |
| 6 | Poland | 148 | 2.63% | 10.0% | pl |
| 7 | Türkiye | 141 | 2.51% | 2.1% | tr |
| 8 | France | 135 | 2.40% | 3.1% | fr |
| 9 | **United States** | **125** | **2.22%** | 9.0% | en-US |
| 10 | Italy | 114 | 2.03% | 1.9% | it |

Platform split confirms the problem: `snake_classic (android)` **99.9%**,
`snake_classic (ios)` **0.0%** (down 100%).

### What this data changes

1. **en-GB is the priority localization, not en-US.** India + Pakistan alone are 23.4% of
   users; the US is 2.22%. Under the standard Apple mapping, `English (U.K.)` serves the
   UK, Ireland, **India**, **Pakistan**, Singapore, Malaysia, Philippines, South Africa,
   Nigeria and UAE, while `English (U.S.)` serves only the US storefront (plus acting as
   the global fallback when no better localization exists). Verify the exact list against
   the localization dropdown in App Store Connect before you rely on it — but the
   *ordering* is not in doubt.

2. **Do not spend es-MX on English keyword overflow.** There's a known trick where the US
   storefront indexes both `English (U.S.)` and `Spanish (Mexico)`, so you can stuff es-MX
   with extra English terms to get 200 chars of US keywords. Given the US is 2.22% of our
   users and Mexico is 3.04%, that trade is not worth making here. es-MX gets real
   Spanish, aimed at the Mexico storefront.

3. **Türkiye has no listing at all.** `store_listings/` has ar, en, es, fr, hi, it, pl,
   pt, ru — no `tr`, despite Türkiye being #7. That's a missing locale, not just a missing
   keyword field.

4. **Poland and Brazil punch above their weight on revenue.** Poland is 10% of revenue on
   2.63% of users, with by far the best engagement in the table (18m 22s vs a 9m 01s
   average). Brazil is 14% of revenue on 10.31% of users. Both justify careful keyword
   work rather than a machine translation.

5. **Russia is worth confirming before you invest.** It's #3 by users but $0.00 revenue,
   and Apple's App Store operations in Russia have been restricted since 2022. Check
   whether the app is even distributable there before spending effort on `ru`.

Ready-to-paste metadata for every locale above is in **`ios_metadata.md`**.

---

## Beyond keywords

**In-App Events** appear directly in App Store search results and their name/short/long
description fields are indexed. We already run daily and weekly tournaments and
battle-pass seasons — exactly the content Apple built this for. Up to 10 events, 5
published at once. Zero engineering work; pure App Store Connect metadata.

**IAP display names** are indexed. Renaming e.g. `Coins Pack` → `Snake Coins Booster
Pack` adds indexed surface for free.

**Category.** Primary `Games > Arcade`, secondary `Games > Casual`. Category drives browse
placement and top-chart eligibility, which is a discovery path independent of search.

---

## App Store Connect gotchas (learned the hard way, 2026-08-07)

**1. Add the locale in App Information FIRST, not on the version page.**
Selecting a new language from the *version* page's language dropdown appears to work — the
fields render and Save lights up — but Save fails with a silent error icon and no message.
The underlying call is `POST /iris/v1/appStoreVersionLocalizations` → **409 Conflict**, and
nothing persists. The fix:

1. **App Information** → language dropdown → pick the locale → set **Name** + **Subtitle** → Save.
2. Return to the **version** page. The locale is now under *Localized* and its version
   fields (Description, Keywords, Promotional Text, What's New, Support URL) are editable
   and save normally.

Doing it in the other order silently loses everything you typed.

**2. Emoji are rejected in version metadata.** `What's New in This Version` refuses
non-BMP characters with "This field contains one or more invalid characters." The emoji in
`release_notes.md` (🎮 💾 🐍 🔔 🎁) all fail; `⚡` happens to be BMP but isn't worth the
risk. Use `•` bullets for the App Store and keep the emoji version for Play, which accepts
them. Em-dashes and accented Latin characters are fine.

**3. Support URL does not inherit.** Each new locale starts with empty Support URL and
Marketing URL. Support URL is required, so it must be re-entered per locale:
`https://snakeclassic.pranta.dev/support` and `https://snakeclassic.pranta.dev/marketing`.

## Constraint: how these ship

App Name, Subtitle, and Keywords can **only be changed by submitting a new app version**.
They are not editable on a live listing. (`Promotional Text`, 170 chars, is the only
always-editable field, and it is *not* indexed.) So batch every locale below into one
version submission.

## Verify before you build on this

In App Store Connect → App Analytics, filter source = App Store Search and read
**Impressions** and **Product Page Views**:

- Impressions ~0 → ranking/indexing problem → this document is the fix.
- Impressions healthy, Page Views ~0 → icon and first two screenshots are the problem.
- Page Views healthy, installs ~0 → conversion problem (screenshots, rating count).

Everything here assumes the first case, which the 0.0% iOS share makes overwhelmingly
likely — but it's a five-minute check and it's free.

## The cold-start problem

App Store ranking is downloads-velocity and ratings driven, so 0 installs stays 0
installs. Two ways out:

1. **Apple Search Ads.** Paid installs feed organic ranking, so this buys rank, not just
   clicks. Run it on the **India and Brazil** storefronts, not the US — CPT is far lower
   and that's where the demand demonstrably is.
2. **Ratings.** Under ~10 ratings an app reads as abandoned. Trigger
   `SKStoreReviewController` right after a new personal best; Apple caps it at 3 prompts
   per 365 days, so spend them at the highest-emotion moment.
