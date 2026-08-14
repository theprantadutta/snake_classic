# App Store metadata — ready to paste

## Status in App Store Connect (as of 2026-08-07)

Applied and saved in the open "Prepare for Submission" draft. **Nothing has been
submitted for review** — "Add for Review" was deliberately not touched.

| Locale | App Info (name/subtitle) | Version (desc/keywords/promo/what's-new/URLs) |
|---|---|---|
| en-US | already set by you | ✅ keywords already set by you; **What's New added** |
| pt-BR | ✅ `Snake Classic: Jogo da Cobra` | ✅ |
| en-GB | ✅ `Snake Classic - Retro Arcade` | ✅ |
| pl | ✅ `Snake Classic: Wąż Retro` | ✅ |
| tr | ✅ `Snake Classic - Yılan Oyunu` | ✅ (copy authored — see `tr.md`) |
| es-MX | ✅ `Vibora Snake Classic` | ✅ |
| ar | ✅ `Snake Classic: لعبة الثعبان` | ✅ (copy authored) |
| hi | ✅ `सांप गेम Snake Classic` | ✅ |
| fr | ✅ `Serpent Snake Classic` | ✅ |
| it | ✅ `Serpente Snake Classic` | ✅ |
| ru | ⬜ **deliberately skipped** — confirm Apple distributes in Russia first | ⬜ |

All ten locales verified present after a hard page reload, not just by the "Saved" badge.

### App name collisions — what actually worked

Names rejected as "already being used": `Snake Classic: Retro Arcade` (en-GB, i.e. the
exact en-US name), `Snake Classic: Juego Víbora`, `Snake Classic - Juego Víbora`,
`Snake Classic: Culebra Retro`, `Snake Classic: Jeu Serpent`, `Snake Classic: सांप गेम`.

Separator style is **not** the factor — pt-BR, pl and ar all saved fine with colons. What
reliably worked was **moving the localized word to the front** so the name no longer starts
with the contested `Snake Classic` prefix:

- `Vibora Snake Classic` (es-MX) ✅
- `Serpent Snake Classic` (fr) ✅
- `Serpente Snake Classic` (it) ✅
- `सांप गेम Snake Classic` (hi) ✅

Use that pattern first for any future locale; it saves a round of rejections.

### App name collisions — read before adding more locales

App Store app names must be unique **per locale across the whole App Store**, and
"Snake Classic …" is heavily contested. Rejections come back as *"the app name you
entered is already being used"*, followed by two cascading bullets ("Name/Subtitle
couldn't be saved because another field in this localization is invalid") — those two are
noise; only the first bullet is the real cause.

Confirmed rejected:
- en-GB: `Snake Classic: Retro Arcade` (the exact en-US name) → accepted as
  `Snake Classic - Retro Arcade`
- es-MX: `Snake Classic: Juego Víbora`, `Snake Classic - Juego Víbora`,
  `Snake Classic: Culebra Retro` — **all three rejected.** Separator style is not the
  factor (pt-BR and pl both saved fine with colons), so es-MX needs a distinctly different
  name. Untried ideas: `Vibora Snake Classic`, `Snake Classic Gusano`, `Snake Classic MX`.

**es-MX is the only locale that did not persist at all.** Verify in App Information →
language dropdown: a locale that failed to save silently drops back to *Not Localized*
rather than showing an error on reload.

### Two more App Store Connect behaviours worth knowing

- **Save submits every pending locale at once and reports only the first failure.** If you
  edit three locales and one has a bad name, the others may not commit either. Edit and
  save **one locale at a time**.
- **Switching locale in the dropdown can drop an unsaved edit.** Always Save before
  changing the language selector.


Per-locale App Name / Subtitle / Keywords for App Store Connect. Strategy and the data
behind the locale priority are in [`ios_aso.md`](./ios_aso.md).

**Rules that apply to every locale below:**

- Keyword field: comma-separated, **no space after the comma** (a space costs one of your
  100 characters).
- Never repeat a word between App Name, Subtitle, and Keywords — Apple combines across all
  three, so a repeat is dead space. The sets below are already de-duplicated per locale.
- No trademarks: `nokia`, `slither`, `slitherio`, `worms zone`. Apple rejects on these
  inconsistently and it isn't worth a review round-trip.
- Character counts are noted per field. App Store Connect shows a live counter — trust it
  over my arithmetic, especially for the non-Latin scripts.
- Descriptions are not indexed. Reuse the existing per-locale `full` copy from
  `en.md` / `pt.md` / etc. as-is; it only affects conversion, not ranking.

Priority order for shipping: **en-GB → pt-BR → es-MX → pl → tr → hi → fr → it → en-US → ru**.

---

## en-GB — English (U.K.)  ★ highest priority
Serves India, Pakistan, UK, Ireland, Singapore, Malaysia, Philippines, South Africa,
Nigeria, UAE. This is 23%+ of our audience.

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - Retro Arcade` | 28/30 |
| Subtitle | `Online Multiplayer Worm Game` | 28/30 |

```
io,serpent,offline,1v1,duel,tournament,leaderboard,neon,pixel,casual,reflex,skill,90s,oldschool,eat
```
99/100

## en-US — English (U.S.)
US storefront only (2.22% of users), plus the global fallback for any storefront with no
better localization. Same copy is fine — these are separate indexes, so there's no
duplication penalty.

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - Retro Arcade` | 28/30 |
| Subtitle | `Online Multiplayer Worm Game` | 28/30 |

```
io,serpent,offline,1v1,duel,tournament,leaderboard,neon,pixel,casual,reflex,skill,90s,oldschool,eat
```
99/100

---

## pt-BR — Portuguese (Brazil)  ★ #2 users, #1 revenue

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - Jogo da Cobra` | 29/30 |
| Subtitle | `Minhoca Arcade Online Grátis` | 28/30 |

```
serpente,verme,retro,classico,offline,multijogador,torneio,1v1,pixel,neon,casual,rapido,anos90,comer
```
100/100

## es-MX — Spanish (Mexico)  ★ #4 users
Also indexed for the US storefront, but spend it on real Spanish — see `ios_aso.md`.
`sin internet` is a genuinely high-volume search across LatAm.

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - Juego Víbora` | 28/30 |
| Subtitle | `Serpiente Arcade Multijugador` | 29/30 |

```
culebra,gusano,clasico,retro,offline,sin,internet,torneo,1v1,pixel,neon,casual,gratis,anos90,comer
```
98/100

## pl — Polish  ★ best engagement (18m 22s), 10% of revenue

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - Wąż Retro` | 25/30 |
| Subtitle | `Klasyczna gra arkadowa online` | 29/30 |

```
robak,zmija,offline,turniej,1v1,piksel,neon,zrecznosciowa,rekord,darmowa,lata90,stara,jedzenie,gra
```
98/100

## tr — Turkish  ★ NEW LOCALE — no `tr.md` exists yet
Türkiye is #7 by users with no listing at all. Needs a full `tr.md` (title/short/full) for
Play as well as the iOS fields below.

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - Yılan Oyunu` | 27/30 |
| Subtitle | `Klasik Arcade Çok Oyunculu` | 26/30 |

```
solucan,yilan,retro,klasik,cevrimdisi,turnuva,1v1,piksel,neon,rekor,ucretsiz,90lar,eski,yemek,hizli
```
99/100

## hi — Hindi
India's secondary index, on top of en-GB. Worth adding, but keep expectations calibrated:
a large share of Indian users search the App Store in English regardless of device
language, so **en-GB stays the primary investment for India**.

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - सांप गेम` | verify |
| Subtitle | `क्लासिक आर्केड मल्टीप्लेयर गेम` | verify |

```
सर्प,खेल,ऑफलाइन,मुफ्त,रेट्रो,टूर्नामेंट,पिक्सेल,रिकॉर्ड,पुराना,तेज
```
Devanagari character counts are unreliable to compute offline — paste into App Store
Connect and trim against its live counter.

## fr — French

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - Jeu Serpent` | 27/30 |
| Subtitle | `Arcade rétro en ligne 1v1` | 25/30 |

```
ver,classique,hors,connexion,tournoi,pixel,neon,gratuit,record,annees90,vieux,manger,rapide,vitesse
```
99/100

## it — Italian

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - Gioco Serpente` | 30/30 |
| Subtitle | `Arcade retrò online 1v1` | 23/30 |

```
verme,biscia,classico,offline,torneo,pixel,neon,gratis,record,anni90,vecchio,mangiare,veloce,sfida
```
98/100

## ru — Russian  ⚠ confirm distribution first
#3 by users but $0.00 revenue, and Apple's Russian App Store has been restricted since
2022. Confirm the app is actually distributable there before spending the slot.

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - Змейка` | 22/30 |
| Subtitle | `Классическая аркада онлайн` | 26/30 |

```
червяк,ретро,классика,офлайн,турнир,1v1,пиксель,неон,казуальная,рекорд,бесплатно,90е,старая,игра
```
96/100

## ar — Arabic
No Arabic-majority country in our top 10, but UAE and Saudi are strong iOS revenue
markets and `ar.md` already exists. Low priority — ship it after the list above.

| Field | Value | Chars |
|---|---|---|
| App Name | `Snake Classic - لعبة الثعبان` | verify |
| Subtitle | `أركيد كلاسيكي أونلاين` | verify |

```
ثعبان,حية,دودة,لعبة,كلاسيك,اوفلاين,مجاني,بطولة,ريترو,سريع,قديم,نقاط
```
Verify counts in App Store Connect.

---

## Notes on the keyword choices

- **`io`** — two characters, and it pulls the entire `snake.io` / `.io` game search
  cluster. Best value-per-character term available.
- **`offline` / `sin internet` / `cevrimdisi` / `hors connexion`** — high-volume in India,
  Pakistan, Brazil and Mexico where data cost and connectivity actually drive the search.
  We genuinely are offline-first, so relevance is real, not keyword-stuffing.
- **`1v1`, `tournament`, `leaderboard`** — differentiators. Most snake clones have none of
  this, so these are low-competition terms we can plausibly rank on early.
- **Accents in keyword fields** — I've used unaccented forms (`classico`, `rapido`,
  `anos90`). Apple's diacritic folding is generally reliable but has been inconsistent
  historically; if you have a spare character or two, it's worth testing the accented
  form in a later version.
- **`gratis` / `ucretsiz` / `darmowa`** — Apple's guidelines discourage price claims in
  metadata. These are widely used without rejection, but if a review flags one, drop it
  rather than arguing.
