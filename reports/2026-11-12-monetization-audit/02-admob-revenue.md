# 02 — AdMob Revenue: Where the Money Comes From

## 2.1 Account totals

| | Value | Proof |
|---|---|---|
| Today so far (Nov 12, partial) | $6.07 | `admob-01-home-earnings.jpg` |
| Yesterday | $3.52 | same |
| This month so far | $37.11 | same |
| Last month (October) | $73.68 | same |
| Last 7 days | $20.23 (prev 7 d $21.02, −3.79%) | `admob-02-…jpg`, raw-data §A1 |

Snake Classic Android earned **$19.98** of the $20.23 (18.4K impressions); Snake Classic iOS **$0.12**
(143 impressions). The other apps in the account earn ~$0.13 combined. **This is effectively a one-app
business.** (`admob-03-home-app-performance.jpg`)

## 2.2 Revenue by format (last 7 days, AdMob Network)

| Format | Impressions | eCPM | Revenue (imps × eCPM) | Share of revenue | Share of impressions |
|---|---:|---:|---:|---:|---:|
| Banner | 16,100 | $0.20 | ≈ $3.22 | 16% | 87% |
| Rewarded | 1,270 | $8.23 | ≈ $10.45 | 52% | 7% |
| Rewarded interstitial | 866 | $6.05 | ≈ $5.24 | 26% | 5% |
| Interstitial | 213 | $5.10 | ≈ $1.09 | 5% | 1% |
| App open | 44 | $4.79 | ≈ $0.21 | 1% | 0.2% |
| **Total** | **18,531** | **$1.09** | **≈ $20.21** (AdMob: $20.23) | | |

Other 7-day totals: requests **79,047**, match rate **56.38%** (59.35% on the networks card, which
counts 75,090 requests). Source: raw-data §A1, `admob-01/02`.

**Reading:** banners fill the screen and earn little; full-screen formats earn 84% of the money but
are shown ~2,400 times a week to ~650 daily users (≈ 0.5 full-screen ads per DAU per day).

## 2.3 Your eCPM vs peers (last 14 days)

Peer set: **12,286 Android apps, category Action Games only.** Source: AdMob → Reports → eCPM Trends
(`admob-11-…`, `admob-12-…`, raw-data §A4).

| Format | You | Peers | Verdict |
|---|---:|---:|---|
| **Overall** | **$1.26** | **$2.17** | Below — because of mix |
| Rewarded | $9.94 | $7.76 | **Above** (+28%) |
| Rewarded interstitial | $6.40 | $1.07 | **Above** |
| Interstitial | $5.65 | $3.08 | **Above** (+83%) |
| App open | $3.59 | — (hidden) | — |
| Banner | $0.22 | $0.30 | Below (−27%) |
| Native advanced | — (not used) | $1.41 | — |

Daily overall eCPM (yours) ranged $0.83 → $2.63 over the 14 days; peers were flat at ~$2.10–2.17.

**Conclusion:** pricing per format is healthy. The overall gap comes from (a) banner-heavy mix and
(b) banner eCPM below peers — both improve with more bidders (`03`) and fewer wasted requests (`04`).

## 2.4 Users and value by country (last 30 days, User Activity report)

Totals: **9,228 active users, 5,944 ad viewers (60.20%), $78.95 earnings, ARPU $0.008,
6.48 impressions / user, 2.59 sessions / user.** (`admob-13/14/15`, raw-data §A3)

| Country | Active users | Ad viewers | Ad-viewer rate | ARPU (30 d) | ≈ Revenue | Imps/AU |
|---|---:|---:|---:|---:|---:|---:|
| India | 2,005 | 1,421 | 66.9% | $0.002 | ≈ $4.0 | 4.77 |
| Brazil | 1,215 | 1,088 | 83.7% | $0.007 | ≈ $8.5 | 10.57 |
| **United States** | 404 | 344 | 77.7% | **$0.035** | ≈ **$14.1** | 11.48 |
| Russia | 325 | — | — | $0.000 | $0 | — |
| **United Kingdom** | 275 | 153 | 52.4% | **$0.025** | ≈ $6.9 | 8.06 |
| Mexico | 251 | 172 | 64.9% | $0.008 | ≈ $2.0 | 9.74 |
| Türkiye | 244 | 195 | 75.0% | $0.005 | ≈ $1.2 | 6.00 |
| **Germany** | 212 | 103 | **43.9%** | **$0.023** | ≈ $4.9 | 5.04 |
| South Africa | 204 | 126 | 57.8% | $0.007 | ≈ $1.4 | 7.16 |
| **France** | 201 | 79 | **36.3%** | $0.013 | ≈ $2.6 | 5.43 |
| Pakistan | 185 | 103 | 51.4% | $0.001 | ≈ $0.2 | 1.95 |
| Poland | 183 | 108 | 54.6% | $0.005 | ≈ $0.9 | 6.87 |
| Philippines | 156 | 115 | 68.0% | $0.002 | ≈ $0.3 | 8.76 |
| Indonesia | 147 | 94 | 60.5% | $0.001 | ≈ $0.1 | 3.35 |
| **Italy** | 147 | 65 | **41.5%** | $0.006 | ≈ $0.9 | 5.44 |

(176 countries total; "≈ Revenue" = AU × ARPU, rounded.)

Key observations:
- **US + UK + DE ≈ 9.7% of users but ≈ 33% of revenue.** A US user is worth ~17× an Indian user.
- **Russia: 325 users, zero ads.** AdMob does not serve in Russia. These users can only monetize via IAP.
- **EU ad-viewer rates are low (FR 36%, IT 42%, DE 44%)** vs Brazil 84% / US 78%. Most likely cause:
  users declining the GDPR consent form (UMP) → limited/no ads. Needs the AdMob *Privacy & messaging*
  report to confirm (not captured).

## 2.5 Per-format user metrics (last 30 days)

| Format | ARPV (revenue per ad viewer) | Impressions per ad viewer |
|---|---:|---:|
| Banner | $0.002 | 10.2 |
| Rewarded | $0.019 | 2.07 |
| Rewarded interstitial | $0.022 | 3.13 |
| Interstitial | $0.011 | 2.14 |
| App open | $0.005 | 1.41 |

Rewarded viewers average only ~2 rewarded ads per month → there are few opportunities to watch one.

## 2.6 Daily trend (User Activity, last 30 days — excerpt)

| Date | AU | AV | AV rate | ARPU | Imps/AU | Sessions/AU |
|---|---:|---:|---:|---:|---:|---:|
| 11/09 | 666 | 322 | 48.35% | $0.003 | 3.65 | 1.47 |
| 11/08 | 677 | 363 | 53.62% | $0.005 | 5.01 | 1.51 |
| 11/07 | 677 | 343 | 50.66% | $0.004 | 4.05 | 1.54 |
| 11/06 | 651 | 334 | 51.31% | $0.006 | 4.43 | 1.54 |
| 11/05 | 658 | 295 | 44.83% | $0.002 | 3.34 | 1.46 |
| 11/04 | 581 | 243 | 41.82% | $0.003 | 2.64 | 1.54 |
| 11/03 | 621 | 280 | 45.09% | $0.003 | 3.98 | 1.47 |
| 11/02 | 612 | 318 | 51.96% | $0.007 | 6.17 | 1.48 |
| 11/01 | 650 | 337 | 51.85% | $0.004 | 3.68 | 1.46 |
| 10/31 | 627 | 325 | 51.83% | $0.006 | 3.51 | 1.48 |
| 10/30 | 608 | 297 | 48.85% | $0.005 | 3.10 | 1.50 |

Daily ad-viewer rate is only **42–54%**: about half the people who open the app on a given day see no ad at all.
