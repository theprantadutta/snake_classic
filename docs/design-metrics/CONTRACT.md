# Design metrics — client/server contract (v1)

Why: the app got a full UI redesign ("living_board"). The previous UI ("classic")
stays shippable from the `classic` branch (tag `pre-living-board` + this
telemetry). Release plan: ship classic + telemetry to everyone (baseline), then
roll the redesign out as a Play staged rollout; the staged-out users are the
control group. Every number the dashboard compares must be recorded the same
way on both designs. Nothing here may change gameplay, ads, purchases or sync.

## Identity

| Field | Source | Notes |
|---|---|---|
| `install_id` | UUID v4 generated on first launch, stored device-locally, never synced, never cleared on logout | The unit of analysis. Guests have no Firebase user; they still have an install id. |
| `user_id` | from the JWT when the request is authenticated | Optional; links an install to an account. |
| `design` | `"living_board"` or `"classic"` — one compile-time constant per branch (`lib/config/ui_design.dart`, `const String kUiDesign`) | |
| `app_version`, `build` | package_info (`6.8.0`, `60`) | |
| `platform` | `"android"` / `"ios"` | |

### Headers on EVERY API request (authenticated or not)

```
X-Install-Id: <uuid>
X-App-Version: 6.8.0
X-App-Build: 60
X-Platform: android
X-UI-Design: living_board
```

Server: optional on every endpoint (absent on old builds). Only the telemetry
endpoint requires `X-Install-Id`.

## Endpoint

`POST /api/v1/telemetry/batch` — `[AllowAnonymous]`; if a valid JWT is present the
user id is attached. Rate limit: 30 requests / 10 min per install id (fallback: per IP).
Body ≤ 256 KB. Max 50 sessions + 20 feedback per batch. Idempotent: the client may
resend the same session many times as it grows (and after a failed upload).

Request (snake_case JSON, like the rest of the API):

```json
{
  "install_id": "8f3c…",
  "app_version": "6.8.0",
  "build": 60,
  "platform": "android",
  "design": "living_board",
  "locale": "en",
  "installed_at": "2026-10-03T09:12:00Z",
  "sessions": [
    {
      "session_id": "uuid",
      "design": "living_board",
      "app_version": "6.8.0",
      "build": 60,
      "started_at": "2026-10-03T09:12:05Z",
      "ended_at": "2026-10-03T09:31:40Z",
      "local_day": "2026-10-03",
      "foreground_ms": 1175000,
      "runs_started": 9,
      "runs_finished": 8,
      "runs_again": 6,
      "best_score": 340,
      "total_score": 1820,
      "run_ms": 905000,
      "multiplayer_matches": 1,
      "ad_impressions_banner": 14,
      "ad_impressions_interstitial": 2,
      "ad_impressions_rewarded": 1,
      "ad_impressions_app_open": 0,
      "rewarded_completed": 1,
      "rewarded_abandoned": 0,
      "ad_revenue_micros": 2140,
      "purchases_started": 1,
      "purchases_completed": 0,
      "store_views": 2,
      "abnormal_end": false
    }
  ],
  "feedback": [
    {
      "feedback_id": "uuid",
      "design": "living_board",
      "app_version": "6.8.0",
      "rating": 4,
      "comment": "optional, ≤ 500 chars",
      "trigger": "after_runs",
      "created_at": "2026-10-03T09:30:00Z"
    }
  ]
}
```

Response `200`: `{ "accepted_sessions": 1, "accepted_feedback": 1 }`.
`400` on malformed body (bad uuid, rating outside 1–5, too many items). Unknown
fields ignored.

### Semantics

- A **session** starts when the app comes to the foreground after ≥ 30 min in the
  background (or on cold start) and ends when it goes to the background; a quick
  background/foreground within 30 min continues the same session.
  `foreground_ms` excludes background time.
- **runs_again**: a single-player run started ≤ 60 s after the previous run's game over,
  in the same session (the "AGAIN" decision, whichever button started it).
- **abnormal_end**: set on the NEXT launch for the previous session if the app never
  recorded its end (process killed / crash). Crash-free rate proper comes from Sentry
  per release; this is the backend-side proxy.
- `local_day` = the device's local calendar day at session start (retention is by
  the player's day, not UTC).
- Counters are cumulative for the session; the server keeps the **max** of each
  counter across resends (never decreases), and the latest non-null `ended_at`.

## Server storage (Postgres, snake_case)

- `telemetry_installs` — `install_id` PK, `user_id` null, `platform`, `first_seen_at`,
  `first_app_version`, `first_design`, `last_seen_at`, `last_app_version`, `last_design`,
  `locale`, `created_at`, `updated_at`.
- `telemetry_sessions` — `session_id` PK, `install_id` (indexed), `user_id` null,
  `design`, `app_version`, `build`, `platform`, `started_at` (indexed), `ended_at`,
  `local_day` (date, indexed), every counter above, `created_at`, `updated_at`.
- `telemetry_activity_days` — PK (`install_id`, `day`), `design`, `app_version`,
  `user_id` null. Upserted from each session (`day = local_day`). Retention cohorts
  are computed from this table.
- `design_feedback` — `feedback_id` PK, `install_id`, `user_id` null, `design`,
  `app_version`, `rating` (smallint 1–5), `comment` (≤ 500), `trigger`, `created_at`.

## Client storage

Drift tables `telemetry_sessions` and `telemetry_feedback` (local), each row with an
`uploaded_at` / `dirty` flag. A dedicated uploader (not the SyncEngine: that drains
only for authenticated users, and guests are exactly who the funnel loses) flushes
dirty rows on app start, on background, on connectivity regained, and every 5 min
while foregrounded. Uploaded rows older than 14 days are pruned. Telemetry is
append-only device data — it never overwrites user state.

## In-app feedback

One neutral question on BOTH designs so they compare: "How's the game feeling?"
1–5 + optional comment. Shown once, after the 5th finished run AND ≥ 2 days after
install, never during a run, never to someone who dismissed it twice. Styled in the
branch's own design.
