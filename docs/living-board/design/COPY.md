# Snake Classic: Living Board copy deck

**Voice:** deadpan arcade. Short, a little rude, never mean. The game teases the player, never the brand or other players. Jokes go in the *secondary* line. The primary line is always plain and clear (so it translates and so players never miss information).

Rules
- Primary labels: UPPERCASE, 1–3 words (`PLAY`, `CLAIM`, `WATCH AD · FREE`).
- Secondary lines: sentence case, under ~45 characters, one joke max.
- Never joke on: purchases, prices, account/sign-in, privacy, or anything with money attached. Plain copy only there.
- Ad copy states the reward and the skip plainly (AdMob policy). The joke is optional and goes after.
- Every string is ARB-ready. Suggested keys are below (prefix `lb`). English only; the 9 locales need translation.

## Global
| Key | EN |
|---|---|
| lbHomeGreeting | Hey, {name}. Apples missed you. |
| lbHomeHint | STEER INTO A BLOCK. OR TAP. WE DON'T JUDGE. |
| lbDailyNag | DAILY {done}/{total} · ONE MORE SNACK, PLEASE |
| lbModeRow | MODE {i}/{n} · {mode} |
| lbBanner | (no copy, the adaptive banner renders itself) |

## Splash tips (rotate one per launch)
- The wall doesn't move. You do.
- Combos decay after 6 seconds. Keep chewing.
- Zen mode has no walls. It still has you.
- Easy runs stay off the leaderboard. No shame.
- Bonus food is worth 25. Special is 50. Greed is free.
- Swipe early. The snake doesn't do sudden.
- Perfect Game: never step on the same cell twice. Good luck.
- Pro players revive free. Just saying.
- Status line: `WARMING UP THE APPLES… {pct}%` · footer `v{version} · NO SNAKES WERE HARMED`

## Mode one-liners (Run setup)
| Mode | Line |
|---|---|
| Classic | Walls bite. |
| Zen | No walls. Just vibes. |
| Speed Challenge | Fast. Then faster. |
| Multi-Food | The buffet is open. |
| Survival | 3 lives. Spend wisely. |
| Time Attack | 3 minutes. Eat it all. |
| Power-Up Madness | Power-ups. So many. |
| Perfect Game | Never step twice. |
Difficulty: Easy `practice · unranked` · Normal `the classic pace` · Hard `for show-offs`.
Setup subtitle: `Pick your poison. Every mode is free. Forever.`

## In-run
| Event | Copy |
|---|---|
| Combo ×2 | ×2 WARM |
| Combo ×3 | ×3 HOT · KEEP EATING |
| Combo ×5+ | ×5 ON FIRE |
| Combo about to decay (last 1.5s) | EAT SOMETHING. NOW. |
| Combo broken | combo dropped. it happens. |
| Level up | LV {n} · FASTER NOW |
| Invincibility | INVINCIBLE · {s}s: walls are more of a suggestion |
| Speed boost | SPEED · {s}s: hold on |
| Slow motion | SLOW-MO · {s}s: savor it |
| Score ×2 | 2× SCORE · {s}s |
| Power-up ending (last 5s) | {NAME} ENDING · {s} |
| Time Attack last 10s | 10 SECONDS. PANIC RESPONSIBLY. |
| Survival life lost | 1 LIFE DOWN · {left} TO GO |
| Pause title / line | PAUSED · The apple will wait. Probably. |
| Resume | 3 · 2 · 1, THEN GO |
| Quit | QUIT TO MENU · run ends here |

## Crash headlines (by end reason; pick one at random per reason)
**wall**: `BONK!` · You kissed the wall at length {len}. · THE WALL: 1 · YOU: 0 / The wall was there first. / Walls: undefeated since forever.
**self**: `OUCH.` · You bit yourself. Why? / Tail: delicious, apparently. / Self-snack detected.
**timeout** (Time Attack): `TIME!` · Out of time. The apples got away. / Three minutes, {food} apples. Respect.
**perfect-game revisit**: `STEPPED.` · You walked on your own path. Perfect Game is not forgiving.
**quit**: `BAILED.` · Run ended by you. We saw nothing.
Game over header format: `× {LINE IN CAPS}` (e.g. `× YOU BIT YOURSELF. WHY?`).

## Revive (rewarded / coins / Pro)
- Title: `SECOND CHANCE?` · countdown `{s}s`
- Line: `Keep length {len} and all {score} points.`
- Buttons: `WATCH AD · FREE` · `PAY 50¢` (sub: `you have {coins}`)
- Decline: `NAH, SHOW ME MY SCORE`
- Pro (free revive): `REVIVE · FREE WITH PRO`
- Free-user hint: `Pro players revive free. Just saying.`

## Game over
| Slot | Copy |
|---|---|
| Score label | SCORE |
| Best delta < 0 | −{gap} · so close. (not really.) |
| Best delta ≥ 0 (new best) | NEW BEST! · Frame this one. |
| Chart title | YOUR RUN, UNCOILED · {food} FOOD · PEAK ×{combo} |
| Chart caption | 1 COLUMN = 1 FOOD · TALLER = TASTIER |
| Primary | AGAIN · {MODE} · {BOARD} |
| Continue | CONTINUE · 50¢ or ad · keep len {len} |
| Rewards | +{coins}¢ EARNED · {n} daily ready · +{c}¢ · +{xp} XP · CLAIM → |
| 2× coins (rewarded) | 2× COINS · AD |
| Replay | WATCH REPLAY |

## Daily / weekly
- Subtitle: `Three snacks a day. Doctor's orders.`
- Progress: `{done} OF {total} DONE` · `streak: {d} days · resets in {h}h {m}m`
- Claim all ×2 (rewarded): `CLAIM ALL ×2` · `one short ad, double the loot`
- Weekly teaser: `WEEKLY QUESTS · {done}/{total}` · `the big loot drops Sunday`
- Challenge descriptions keep their current server text. Optional flavor suffix: Hungry Snake `Nom nom, etc.` · Zen Master `Breathe in. Eat.`
- Empty / all claimed: `ALL FED. COME BACK TOMORROW.`

## Trophies
- Subtitle: `{unlocked} of {total}. The other {locked} are judging you.`
- Locked secret: name visible, icon locked. Status `CLAIMED` · `+{coins}¢` (claim button) · `{progress}/{target}`

## Season
- Subtitle: `{season} · {days} days left. Make them count.`
- Next reward: `NEXT UP · TIER {n} · FREE` · `{n} tier away. Eat faster.`
- XP ad: `+50 XP · WATCH AD`
- Current tier marker: `YOU ARE HERE`

## Ranks
- Subtitle: `Ranked by your best single run. No pressure.`
- Pinned self row: `#{rank} · YOU · {name}` · `{gap} behind {leader}. Snack harder.`
- Easy-only player: `Easy runs don't rank. Normal is waiting.`
- Offline: `Ranks need the internet. Your snake doesn't.`

## Profile
- Subtitle: `Your snake, by the numbers.`
- Fun facts (rotate): `{apples} apples eaten. That's about {pies} pies.` (pies = apples/10) · `{minutes} minutes of slithering. Hydrate.` · `{powerups} power-ups grabbed. Greedy, love it.`
- Sync: `PROGRESS SYNCED` · `Offline? Play anyway. We'll catch up later.`
- Guest: `PLAYING AS GUEST` · `Link an account to keep this snake forever.` (no joke: account copy)

## Store (plain, no jokes on prices)
- Subtitle Pro: `No ads. All the drip. Your call.` · Skins: `Same snake. Way more drip.` · Themes: `New board, same bad habits.` · Trails: `Leave a mark.` · Coins: `Coins for the impatient.` · Power-ups: `Tiny cheats. Fully legal.`
- Pro perks: `No ads. Not one. Ever.` · `A free revive, every single run` · `All 6 premium themes` · `All 11 skins + all 11 trails` · `2× coins from every run`
- Footer: `Prices come from your app store. Cancel anytime.` · `RESTORE PURCHASES`
- Free coins (rewarded): `+25¢ FREE · watch a short ad`
- Skin taglines: Golden `Rich. Famous. A little smug.` · Fire `Hot to the touch.` · Ice `Cool under pressure.` · Electric `Shockingly fast.` · Rainbow `All of them. At once.` · Neon `Visible from space.` · Shadow `Now you see it.` · Galaxy `Contains multitudes.` · Crystal `Handle with care.` · Cosmic `Big universe energy.` · Dragon `Legally not a dragon.`

## Settings
- Subtitle: `Tweak it till it feels right.`
- Controls: SWIPE `anywhere` · D-PAD `4 arrows` · TURN `left · right` · STICK `floating`
- Swipe feel `lazy ←→ twitchy` · Crash replay `how long we rub it in` · Sound FX `crunchy, as intended` · Haptics `tiny buzz on every bite` · 120 Hz `smooth like butter (if your phone is)`

## Versus
- Lobby subtitle: `Real people. Real snakes. Real beef.`
- Quick match: `1v1 Classic. We find you a rival in seconds.` · searching: `SNIFFING OUT A RIVAL… {s}s`
- Code: `GOT A CODE?` · `Six letters. Case doesn't matter. Friendship might.`
- Create: `Invite a friend. Or a frenemy.`
- House opponent: `Nobody brave online? The house snake joins after 30s. It doesn't trash talk.`
- Room: `Share the code. Wait nervously.` · you waiting `WAITING · tap ready, hero` · them ready `READY · stretching menacingly`
- Match: `{rival} is {gap} points ahead. Rude.` / `You're {gap} ahead. Don't get cocky.`
- Result: VICTORY `You out-snaked {rival}.` · DEFEAT `Both snakes crashed. Their score decided it.` + `{rival} will be insufferable now.` · DRAW `Perfectly balanced. Rematch?`
- Footer: `Every loss is just a rematch waiting to happen.`
- Tournaments tile: `TOURNAMENTS · LIVE` · `Bronze free · Silver & Gold entries`

## Ads (policy-plain first)
- Rewarded interstitial intro: `AD BREAK` · `A short ad. 25 coins for you.` · `Fair trade? Your call either way.` · `STARTS IN {s} · OR SKIP, NO HARD FEELINGS` · buttons `WATCH NOW` / `NO THANKS` (equal size and contrast) · `The back gesture counts as no thanks, too.` · upsell `GO PRO · and never see this screen again.`
- Interstitial curtain (0.7s): `AD STARTING…`
- Rewarded not filled: `No ad right now. Try again in a sec.`

## Errors and empty states
- Offline: `NO SIGNAL. Single-player still works.`
- Server down: `Our servers bonked. Your progress is safe on this phone.`
- Purchase failed (plain): `Purchase didn't go through. You weren't charged.`
- Matchmaking timeout: `No rival found. The house snake is warming up.`
