# GameRun: a single durable record per completed game

**Status:** design, not implemented. Nothing in this document should be built
until the open questions in [§12](#12-open-questions--decisions-needed) are
answered.

**Supersedes:** the aggregate-snapshot model for gameplay history.

---

## 1. Why

A completed run currently fans out into two incompatible records:

| Record | Contains | Owner |
|---|---|---|
| `GameStatistics` JSON snapshot | **every** completed run | client |
| `Scores` row | only positive, leaderboard-eligible runs | server |

They do not contain the same games, do not use the same clock, and do not
merge by the same rules. Four consequences:

1. **Aggregates disagree by design.** `Users.TotalGamesPlayed` counts accepted
   score events; the statistics blob counts all runs. A player practising on
   Easy raises one and not the other, and no dashboard label says so.
2. **Cross-device progress is silently lost.** Snapshots merge by `MAX`, which
   cannot distinguish a duplicate from two independent increments. Two devices
   each playing one game from a base of 10 produce 11, not 12.
3. **A finished game can vanish.** `GameCubit` emits game-over and starts
   `_postGameSync` unawaited; the first durable write happens inside that
   background task. A process kill between the two loses the run locally *and*
   remotely, with nothing left for the next launch to recover.
4. **Rewards are client-asserted.** Coins, achievements, battle-pass tier and
   challenge progress are all decided on device and accepted by the server, so
   dashboard numbers cannot be used for entitlement or fraud decisions.

One immutable event per completed run, settled by the server, collapses all
four into one mechanism.

---

## 2. Principles

1. **The run is the fact. Everything else is derived.** Aggregates, ranks,
   rewards and dashboards are projections of accepted runs, never independent
   sources of truth.
2. **The client owns capture; the server owns settlement.** Flutter records
   what happened and renders it optimistically. The server decides what it is
   worth.
3. **Durable before visible.** A run is written to disk before the UI presents
   it as finished. Game-over must not wait on the network — but it must not
   precede the local write either.
4. **Exactly once, under retry.** Every path is keyed by a client-generated
   run id, so a retry, a duplicate drain or a crash mid-flight cannot double
   count.
5. **Nothing disappears silently.** A run is accepted, retried, or recorded as
   rejected with a reason. There is no fourth outcome.

---

## 3. The event

Written once, never updated. A correction is a new run, not an edit.

| Field | Type | Notes |
|---|---|---|
| `run_id` | UUID v4 | Client-generated. **The idempotency key** everywhere. |
| `played_at` | UTC instant | Server-clamped; see [§7](#7-time-and-competitive-eligibility). |
| `duration_ms` | int | Wall-clock length of the run. |
| `game_mode` | enum wire name | Pinned by existing payload tests. |
| `difficulty` | enum wire name | |
| `score` | int | May be 0. Zero-score runs are real runs. |
| `foods_eaten` | int | |
| `max_snake_length` | int | |
| `end_reason` | enum | `wall`, `self`, `quit`, `timeout`. |
| `rank_eligible` | bool | Client's *proposal*; the server re-derives it. |
| `client_version` | string | For triaging a bad release. |
| `schema_version` | int | Lets the server accept old clients during rollout. |

**`rank_eligible` is advisory.** The client computes it so it can render
optimistically, but the server recomputes from the same rule and its answer
wins. A modified client cannot promote its own runs onto a leaderboard.

**Not in the event:** coins earned, XP granted, achievements unlocked,
challenge progress. Those are *outcomes of settlement*, not properties of the
run — see [§6](#6-settlement-and-rewards).

---

## 4. Client: capture and journal

### 4.1 The durability fix

Today:

```
game over → emit gameOver → (unawaited) _postGameSync → … → first durable write
```

Proposed:

```
game over → write GameRun + outbox row in ONE Drift transaction
          → emit gameOver
          → (unawaited) rewards, progression, UI extras
```

The transaction is local, small and takes no locks the render thread needs, so
this does not make the game-over screen wait on anything meaningful. It only
moves the durable write to *before* the moment the player is told the game
finished.

A `runs` table holds the event plus a settlement state:

| State | Meaning |
|---|---|
| `pending` | Written locally, not yet accepted. |
| `settled` | Server accepted it and returned outcomes. |
| `rejected` | Server permanently refused it; reason recorded. |

This mirrors the score dead-letter store shipped in
`fix/dashboard-data-sources`, and that store should fold into this table when
runs land rather than remaining a parallel mechanism.

### 4.2 Optimistic rendering

The client keeps its local aggregates for instant UI. They become a *cache of
projected runs*, not an authority: on settlement the server's outcome
overwrites the optimistic value. Where they disagree, the server wins and the
difference is logged — a persistent gap is a bug worth seeing.

---

## 5. Sync

`POST /runs/batch`, drained by the existing outbox engine, reusing the
per-item settlement introduced for scores: correlate by `run_id`, delete only
accepted and duplicate, retry only transient failures, dead-letter permanent
rejections.

Response per item:

```
run_id, accepted | duplicate | rejected, retryable, reason?, outcomes?
```

`outcomes` carries what the server actually granted — see below.

**Duplicate is success.** A `run_id` already known returns the *original*
outcomes, so a retry after a lost response converges instead of double
granting.

---

## 6. Settlement and rewards

Server-side, in one transaction per run:

1. Validate (plausibility ceilings, as `BatchSubmitScores` already does).
2. Insert the run, keyed unique on `(user_id, run_id)`.
3. Derive and apply, in the same transaction:
   - aggregate counters (`total_games_played`, `total_score`, play time);
   - `high_score` via `GREATEST`;
   - achievement evaluation — the batch path currently skips
     `AchievementAutoEvaluator`, which is why achievements are client-asserted;
   - daily challenge and weekly quest progress;
   - battle-pass XP;
   - coin grants, written to an **immutable ledger** with the `run_id` as the
     source event id.
4. Return the resulting balances and progress.

Exactly-once falls out of the unique key: the insert either succeeds and the
grants apply, or conflicts and no grant runs. There is no window where a run
counts twice.

**Coins become derived.** The balance is `SUM(ledger)` server-side, not a
client-asserted number. `SyncCoinBalanceCommandHandler`'s last-write-wins
overwrite of both `UserCoinBalance.Balance` and `Users.Coins` is retired.

---

## 7. Time and competitive eligibility

Already implemented for scores in `CompetitivePeriod`, and runs adopt it
unchanged: UTC calendar periods derived server-side, ranked by `played_at`,
admitted only if the period was still open at receipt, no more than 48h stale,
never claiming a play time after receipt, ties broken on server receipt.

`received_at` (server) and `played_at` (client, clamped) are both stored and
never conflated.

---

## 8. Aggregates and dashboards

Every gameplay number derives from accepted runs, and each metric gets a name
that says what it counts:

| Metric | Definition |
|---|---|
| `all_completed_runs` | Every accepted run. |
| `ranked_submissions` | Accepted runs with server-derived `rank_eligible`. |
| `active_players` | Distinct users with an accepted run in the window. |

The three dashboard surfaces currently reading client mirrors
(`UserStatistics.ModelJson`, `UserDailyChallengeClaims`,
`UserBattlePassSnapshots`) move to run-derived aggregates. Until they do, they
stay labelled as client-reported — that labelling is P0 work and independent
of this design.

The `MAX`-merge statistics snapshot is retired. Summing accepted runs makes
the two-device case correct by construction: 10 + 1 + 1 = 12, because there
are twelve run rows.

---

## 9. Cross-account ownership

The rule, stated once and applied to **all** gameplay data — not coins alone.

| Transition | Firebase UID | Rule |
|---|---|---|
| Guest → **new** credential account | unchanged / first | Runs transfer. The account is being created for this player; their history is theirs. |
| Anonymous → linked credential | **unchanged** | Nothing moves. Same UID, same backend row, same runs. |
| Guest/anonymous → **existing** account | **different** | Runs do **not** transfer. |

The third case is the one that matters. Signing into an account that already
exists is not a migration, it is a *switch*: the destination account has its
own history, and importing unverified pre-login runs would inflate its
aggregates and leaderboard standing. Local pending runs are dropped with a
recorded reason, exactly as guest coin rows already are.

This makes the coin rule already shipped a special case of one general rule,
rather than a policy that applies to coins and nothing else.

**Open:** whether to offer an explicit, audited, one-time "claim my guest
progress" migration for the third case. It is defensible for a player who
genuinely played before remembering their account — but it is also the exact
shape of the inflation vector, so it would need server-side transfer with a
per-account once-ever guard. Deliberately excluded from v1.

---

## 10. Rollout

Compatibility is the hard part; the model change is not.

**Phase 1 — write both.** Ship the local journal and `/runs/batch`. The server
accepts runs *and* keeps the existing score and snapshot paths. Runs are
recorded but nothing derives from them yet. Deploy the backend first — the
client depends on the endpoint, never the reverse.

**Phase 2 — reconcile.** With both streams live, compare run-derived
aggregates against the existing ones for the same users. Any systematic
divergence is a bug in the derivation, and this is the only phase where it is
cheap to find. Do not proceed while the two disagree beyond a stated
tolerance.

**Phase 3 — cut over reads.** Dashboards and player-facing aggregates switch
to run-derived values. Snapshot pushes still accepted, still ignored.

**Phase 4 — retire.** Stop accepting statistics and coin-balance snapshots.
Old clients keep working: their pushes are accepted and dropped, and they
continue to read server-returned values.

**Backfill.** Historical `Scores` rows become synthetic runs
(`schema_version: 0`, `rank_eligible` from their original acceptance). They
cannot be reconstructed for Easy or zero-score games — those were never sent —
so pre-cutover `all_completed_runs` is understated and must be labelled as
such rather than silently blended with post-cutover numbers.

---

## 11. Rollback and observability

**Rollback.** Phases 1–3 are reversible: runs are additive, and the old paths
still work. Phase 4 is the one-way door, and should not be crossed until
Phase 2 has been clean for a full season. If run derivation is wrong after
Phase 4, the only recovery is re-derivation from the run table — which is why
runs must be immutable and completely stored, including rejected ones.

**Signals to have in place before Phase 1 ships:**

- accepted / duplicate / rejected run counts, by reason;
- pending-run age distribution (a rising tail means the outbox is not
  draining);
- optimistic-vs-settled divergence rate per outcome type;
- runs rejected for staleness or future timestamps;
- dead-letter volume.

**Tests, per the audit:**

- game end → durable row → app restart → eventual settlement;
- Easy, zero-score, ranked and offline runs against their dashboard definitions;
- two devices, 10 + 1 each, must yield 12;
- guest → existing account under the [§9](#9-cross-account-ownership) rule;
- batch partial rejection preserving accepted and surfacing rejected;
- duplicate `run_id` granting rewards exactly once.

---

## 12. Open questions — decisions needed

1. **Guest migration.** Ship the one-time audited transfer described in §9, or
   hold at "runs stay with the identity that produced them"?
2. **Backfill depth.** Synthesise runs from all historical `Scores`, or only
   from a cutoff date? Full history is more complete but permanently mixes two
   definitions of "games played".
3. **Phase 4 timing.** Is retiring snapshot writes acceptable while a
   meaningful share of installs are on old clients, given they keep working
   but stop contributing new data?
4. **Reconciliation tolerance.** What divergence between old and new
   aggregates is small enough to proceed on in Phase 2?
5. **Rejected-run visibility.** Should a player ever see that a run was
   refused, or does it stay operator-only?
