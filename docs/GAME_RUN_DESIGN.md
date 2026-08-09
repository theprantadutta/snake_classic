# GameRun: a single durable record per completed game

**Status:** design, not implemented. The shape is settled — see
[§12](#12-decisions) — but nothing here should be built until the
reconciliation tolerance is confirmed and the Phase 1 observability in
[§11](#11-rollback-and-observability) exists.

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
| `source` | enum | `gameplay` or `legacy_score_backfill`. |
| `is_synthetic` | bool | True only for backfilled rows; see [§10](#10-rollout). |
| `verified` | bool | Server-set. False for runs that failed plausibility checks. |

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

### 6.1 Runs that fail validation

A run refused by the plausibility checks is recorded, not erased.

* The **device keeps it** in local history and the player's own stat view. The
  score does not vanish from under them, and an honest player caught by a
  false-positive validator is not punished for it.
* It is marked `verified: false` and grants **nothing**: no coins, no
  battle-pass XP, no achievements, no streak credit, no leaderboard
  eligibility, and no contribution to any server-derived aggregate.
* The rollback is **not** silent and the validator detail is **not** shown.
  Nothing about the failure surfaces to the player, and nothing is quietly
  taken away either.
* The server records the rejection with its reason. Since the server is the
  one refusing, it is the natural place to count from — client-side
  dead-lettering (already shipped for scores) reports what the device
  believes, but only the server sees the whole population and can spot a
  validator misfiring across many users.

The consequence is deliberate: local totals and server-derived totals may
differ, but **only** by rejected runs. That is tolerable precisely because the
number should be near zero — and if it ever isn't, the rejection counter is
what says so.

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

**There is no transfer escape hatch, and there will not be one.** A "claim my
guest progress" migration weakens the one-owner rule to a default and reopens
the reward and progression inflation it exists to prevent — farm as a guest,
sign in, reinstall, repeat. A once-ever guard would then be the only thing
standing between the rule and the exploit, which is not a position worth
being in.

### 9.1 Making the switch visible instead

The rule is defensible only if the player is told before it applies. Signing
into an existing account must therefore be an explicit, cancellable choice:

> Signing into this existing account restores its progress. Guest runs,
> rewards and stats stay on this device's guest identity.

And the upgrade path should be steered, not just permitted: a guest who wants
to keep what they have should be pushed toward **linking a credential to their
current identity** rather than signing into a separate existing one. Linking
preserves the Firebase UID, so nothing moves and nothing is lost — the
migration problem simply does not arise.

That framing changes what the account surfaces should offer. "Sign in" is two
different operations wearing one label:

| Intent | Mechanism | Outcome |
|---|---|---|
| Keep playing as me, but safely | Link credential to current UID | Nothing moves |
| I already have an account | Sign in to that UID | This device's guest history stays behind |

**This applies before GameRun ships.** The cross-account coin rule is already
live, so a player signing into an existing account today already loses their
guest coins — silently. The confirmation above is worth adding to the current
`connectAccountWith*` paths independently of this design.

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

The gate, both conditions required:

1. Pre-GameRun clients are below **5% of authenticated active users over a
   rolling 28-day window**, measured server-side by app version against active
   identity, and published on the dashboard so the number is watchable rather
   than asserted.
2. Reconciliation between legacy snapshots and derived aggregates has been
   **clean for one full season**, with drift alerting already in place — the
   alert has to predate the gate, or "clean" only means nobody looked.

Once the gate opens, remaining legacy clients get a clear **update-required**
notice. Silently accepting gameplay that no longer contributes anything is
the same class of dishonesty as the dashboards this whole effort started with.

### 10.1 Backfill

Every historical `Scores` row becomes an immutable synthetic run, marked
`source: legacy_score_backfill`, `is_synthetic: true`, retaining its original
score timestamp.

**Backfill grants nothing.** No coins, no XP, no achievements, no progression.
These runs already paid out when they were first submitted; re-deriving
rewards from them would pay twice.

After cutover, runs are the **sole** source for all-time score, leaderboard
and aggregate reads.

**The backfill is not a complete history, and must not be presented as one.**
Easy and zero-score games were never submitted, so they do not exist to
recover. Pre-cutover activity and game-count metrics are labelled
*legacy score-submission-derived*, or the chart shows an explicit cutover
boundary. They are never blended into true completed-run counts — that would
reintroduce, in the reporting layer, exactly the two-definitions problem this
design removes from the data layer.

**Migration requirements:** idempotent (safe to re-run), batched, resumable,
and reconciled against `Scores` row counts and checksums **before** any read
switches over.

---

## 11. Rollback and observability

**Rollback.** Phases 1–3 are reversible: runs are additive, and the old paths
still work. Phase 4 is the one-way door, and should not be crossed until
Phase 2 has been clean for a full season. If run derivation is wrong after
Phase 4, the only recovery is re-derivation from the run table — which is why
runs must be immutable and completely stored, including rejected ones.

**Signals to have in place before Phase 1 ships:**

- accepted / duplicate / rejected run counts, by reason, **server-side**;
- share of authenticated active users on pre-GameRun clients, by app version,
  over a rolling 28-day window — this is the Phase 4 gate, so it has to exist
  and be trusted long before the gate is considered;
- reconciliation drift between legacy snapshots and derived aggregates, **with
  alerting**, as a Phase 4 precondition;
- pending-run age distribution (a rising tail means the outbox is not
  draining);
- runs rejected for staleness or future timestamps;
- dead-letter volume.

### 11.1 Reconciliation tolerance

Tolerance is decided **field by field, during Phase 2** — not as one global
number agreed in advance. A single threshold would have to be loose enough for
the loosest field, which would then silently permit divergence in the fields
where none is acceptable.

Two categories, and they are not negotiable against each other:

**Zero tolerated divergence.** Any difference is a hard stop and blocks the
Phase 4 gate:

- rewards granted (coins, XP, achievements, battle-pass tier);
- coin balance;
- settled run count, and the presence of any individual run;
- leaderboard eligibility for any run.

These are entitlements and competitive outcomes. A player either earned a
thing or did not, and "close enough" is not a state either of those can be in.
A run present on one side and absent on the other is a hard stop regardless of
its effect on any total.

**Eventual-sync fields get a settling window, not a fuzzy allowance.** For
fields that legitimately lag — aggregate counters mid-drain, statistics
snapshots from a device that has not synced yet — the question is *"has it
settled?"*, not *"is it close?"*. So the tolerance is expressed in **time**:
compare only records whose last sync is older than the window, and require an
exact match on those.

A numeric allowance would be the wrong instrument here. It cannot distinguish
"still draining" from "derivation is wrong by a small amount", and the second
is exactly what Phase 2 exists to detect. A window separates them: outside it,
any difference is a bug.

Divergence is judged **per user, worst case** — never as a fleet average. An
average hides compensating errors, which is precisely the failure mode worth
catching: two users wrong in opposite directions net to zero and look perfect.

The specific window per eventual field is set in Phase 2 against observed
drain latency, once there is real data to set it from.

**Tests, per the audit:**

- game end → durable row → app restart → eventual settlement;
- Easy, zero-score, ranked and offline runs against their dashboard definitions;
- two devices, 10 + 1 each, must yield 12;
- guest → existing account under the [§9](#9-cross-account-ownership) rule;
- batch partial rejection preserving accepted and surfacing rejected;
- duplicate `run_id` granting rewards exactly once.

---

## 12. Decisions

Settled 2026-08-09. Recorded here so the reasoning survives the conversation.

| # | Decision | Where |
|---|---|---|
| 1 | Runs are permanently owned by the identity that produced them. **No** transfer escape hatch. The switch is made explicit and cancellable in the UI, and guests wanting to keep progress are steered toward credential linking instead. | [§9](#9-cross-account-ownership) |
| 2 | Backfill **every** historical `Scores` row as an immutable synthetic run granting no rewards. Runs become the sole read source after cutover; pre-cutover metrics are labelled legacy-derived rather than blended. | [§10.1](#101-backfill) |
| 3 | Phase 4 gates on pre-GameRun clients below **5% of authenticated active users over 28 rolling days** *and* one clean season of reconciliation with drift alerting already live. Remaining legacy clients then get an update-required notice. | [§10](#10-rollout) |
| 4 | A rejected run stays in the player's local history, marked unverified, granting nothing server-side. No silent rollback, no validator details exposed. Server counts rejections so false positives are detectable. | [§6.1](#61-runs-that-fail-validation) |

| 5 | Reconciliation tolerance is set **per field during Phase 2**, not as one global number. Rewards, coins, settled runs and leaderboard eligibility tolerate **zero** divergence; eventual-sync fields get a **time-based settling window** rather than a fuzzy numeric allowance. | [§11.1](#111-reconciliation-tolerance) |

### Carried out of this design — now shipped

The confirmation in [§9.1](#91-making-the-switch-visible-instead) was not gated
on GameRun: the cross-account coin rule is already live, so a player signing
into an existing account was already losing their guest coins with no warning.

Implemented in `lib/widgets/account_switch_confirmation.dart` and wired into
the Google, Apple and email connect paths. It fires at the two moments a
switch can happen — an offline guest signing in (destination unknowable in
advance) and an anonymous user whose link is refused with
`credential-already-in-use` (destination known for certain) — defaults to
cancel, and is skipped when the player has no progress to lose.
