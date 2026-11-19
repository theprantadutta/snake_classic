# Snake Classic motion spec

One rhythm for the whole game. Tokens: `lib/design/lb_motion.dart` (`LBMotion`).
Never hard-code a duration or curve in a widget; add a token if one is missing.

## Principles
- LED-board identity: things *light up cell by cell*, digits *roll*, rewards *pop* in gold.
- Choreography inside screens beats fancy route transitions.
- 60 fps on a Galaxy A24 is the budget. No blur/saveLayer on anything that animates
  (draw glows once via `LBGlowCache` / cached images), animate through a Listenable into
  a painter or a small subtree, wrap independently animating parts in `RepaintBoundary`.
- Reduce motion (`LBMotion.reduced`, the OS flag) falls back to a ~140 ms fade or an instant swap.

## Tokens
| Token | Value | Use |
|---|---|---|
| instant | 120 ms | press down, tiny state flips |
| quick | 180 ms | small fades, icon swaps |
| base | 280 ms | most transitions, toggles |
| gentle | 400 ms | sheets, toasts, list entrances |
| slow | 600 ms | rewards, progress fills |
| lingering | 900 ms | count-ups, chart draw-in |
| stagger | 45 ms | per list item / tile |
| cellStagger | 18 ms | per LED cell lighting |

Curves: `easeOutSoft` (arrivals), `standard` (in place), `springSoft` (press release,
toggles), `springPop` (rewards, badges, pickups), `dropIn`, `exit`, `travel` (flying coins).

## Interaction table
| Interaction | Motion | Reduced |
|---|---|---|
| Press any block | scale 0.97 in `pressDown`/easeOutSoft, release `pressRelease`/springSoft | no scale |
| Primary button idle | soft glow pulse (cached glow), 2.4 s loop | static glow |
| Toggle | knob/cells slide `base`/springSoft, cells light with `cellStagger` | instant |
| Number change (score, best, coins, XP, rank, timers) | odometer roll per digit, `base`/easeOutSoft, up when increasing | instant |
| Screen open | rows/tiles fade+rise 8 dp, `gentle`/easeOutSoft, `stagger` each, max ~8 staggered | fade only |
| Progress bar | cells light in order, `cellStagger`; newly filled cell pops `slow`/springPop | instant |
| Reward / coins | coins fly to the counter (`slow`/travel), counter rolls, gold spark | counter only |
| Game over | beat sheet (see game_over_screen) — tap skips to the end state | everything at once |
| In game: eat | food pop + gold spark, head flash | none |
| In game: grow | ripple along the body | none |
| In game: combo | badge pops `gentle`/springPop, grows per step, fades after idle | fade |
| In game: level up | level wall cells light in sequence | instant |
| Route | short fade / existing zoom; no heavy transitions | instant |
