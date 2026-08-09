# Known test gaps

Logged rather than left implied. Both are places where the code shipped
without the coverage it deserves, and where the reason is a real obstacle
rather than an oversight.

---

## 1. Cross-account restore orchestration is untested

**What is covered:** the merge *rules* are unit-tested on both sides —
`statistics_merge_test.dart`, `CompetitivePeriodTests`,
`SyncBattlePassMergeTests`, and the shared contract fixture.

**What is not:** the orchestration around them, in `SyncEngine`:

- selective queue clearing — that `clearSyncQueueExcept` preserves event-typed
  rows (scores, coin transactions, unlocked items) while dropping snapshot
  pointers;
- cross-account detection via `sync_engine_last_synced_user_id` — the
  same-UID-link vs different-UID-sign-in distinction the whole coin ownership
  rule rests on;
- the cross-account coin branch adopting the cloud balance and dropping guest
  coin rows;
- per-item score settlement in `_drainScoreGroup`: accepted vs duplicate vs
  retryable vs permanent vs no-verdict.

**Why it is not done:** these need a Drift database and a fake `ApiService`.
Drift in tests needs a native SQLite binary, which is not currently wired up
in this project, and `SyncEngine` reaches for `GetIt` singletons that would
need to be registered per test. That is a test-harness project, not an
afternoon.

**What it would take:** an in-memory Drift `AppDatabase`
(`NativeDatabase.memory()` plus `sqlite3_flutter_libs` for the test target), a
scripted `ApiService` double returning canned `SyncOutcome`s, and a `GetIt`
scope per test. Once that exists, the four bullets above are straightforward
table-driven tests.

**Risk while it is open:** these paths run **once per install** on first
sign-in. A regression would not show up in day-to-day use and would only be
visible as players quietly losing progress. Until the harness exists, section
B of [`DEVICE_QA_CHECKLIST.md`](DEVICE_QA_CHECKLIST.md) is the only thing
standing behind them.

---

## 2. `BatchSubmitScores` has no handler test

**What is not covered:** the per-item result contract the client now depends
on — that each result echoes its `IdempotencyKey`, that validation failures
are marked `Retryable: false` and unexpected faults `Retryable: true`, and
that duplicates report `WasDuplicate` rather than a fresh insert. Also
untested: the `ClampPlayedAt` future-timestamp clamp.

**Why it is not done:** the handler runs raw SQL
(`ExecuteSqlInterpolatedAsync`) inside a `CreateExecutionStrategy` transaction
to apply user aggregates atomically. The EF in-memory provider cannot execute
raw SQL or real transactions, so the existing
`DashboardSourceFixture` approach does not reach this handler.

**How to close it — with a real database, not by weakening the handler.**
Do **not** refactor the raw SQL out to make it testable in memory: that SQL is
there because it is the concurrency-safe way to apply five aggregates at once,
and it was written to fix a real `User.Version` concurrency crash. The test
should meet the code where it is:

- Testcontainers for .NET spinning up a Postgres instance, or a disposable
  local database created per test class;
- run the real EF migrations against it;
- exercise the handler end to end: a valid score, a validation-failing score,
  a duplicate idempotency key, and a future `played_at`.

That fixture would also unlock handler-level tests for the other sync
commands, which are currently only tested through their extracted pure
helpers.

**Risk while it is open:** moderate. The classification logic is simple and
the client treats an unknown verdict conservatively (leaves the row queued
rather than deleting it), so the failure mode is a stuck queue rather than a
lost score. Section B8 of the device checklist covers it manually.
