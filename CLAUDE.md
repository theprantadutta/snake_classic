# Snake Classic - Flutter Game Project

## Project Requirements

### Core Objective
Create a classic Snake game in Flutter with premium game-quality UI/UX, running at 60FPS smoothly.

### Technical Requirements
- **Framework**: Flutter
- **Performance**: 60FPS smooth gameplay
- **Platform**: Multi-platform support (Android, iOS, Web, Desktop)
- **UI Quality**: Professional game-level UI, not placeholder/basic interfaces
- **Assets**: Generate custom images, audio, and visual effects as needed

### Game Features
- Classic snake gameplay mechanics
- Grid-based movement (20x20 tiles)
- Swipe/tap controls for direction changes
- Snake growth mechanics
- Collision detection (walls & self)
- Score system with high score persistence
- Sound effects and visual feedback
- Particle effects and animations
- Multiple themes/visual styles
- Pause/resume functionality
- Game over screen with animations

### Development Approach
- Complete creative freedom for implementation
- Use modern Flutter best practices
- Choose appropriate libraries for audio, animations, storage
- Focus on smooth performance and responsive controls
- No tests required for this project

### Store Layout
The unified store screen (`lib/screens/store_screen.dart`) has exactly 6 tabs in this order: **Pro / Coins / Themes / Skins / Trails / Power-Ups**. Modes and Boards are NOT sold as standalone products — both modes and board sizes are uniformly free (every `BoardSize` in `GameConstants.availableBoardSizes` is selectable by anyone; the `isPremium` flag on the model is retained for compatibility but is `false` everywhere). See `STORE_SETUP.md` for the full Play Store catalog (37 products). The cosmetic bundles, championship/VIP tournament entries, bronze tournament entry, and the battle-pass IAP were removed from the store (App Store cleanup): the Battle Pass remains a gameplay feature earned via XP, and bronze (daily) tournament entries are still earned via rewarded ad / Pro — they're just no longer sold.

### Offline-First Sync Architecture (LOAD-BEARING)

**Every user-mutable piece of state writes to Drift first, and the SyncEngine pushes it to the backend.** The app must remain fully functional offline — playing a game, earning coins, claiming a challenge, picking a cosmetic, changing settings — and any state that changes during the offline window must converge to the server on the next online tick.

**Single source of truth per piece of data.** Pick exactly ONE storage layer per data point:
- **Drift** — anything the backend cares about, anything that should travel with the user across devices (coin balance, high score, statistics, owned cosmetics, claim history, etc.). Cubits / services hydrate FROM Drift, write THROUGH Drift, and SyncEngine pushes from Drift outbox rows.
- **SharedPreferences** — device-only state that never travels. First-run flags (`hasSeenGameModePicker`, `hasAcceptedPrivacyPolicy`), UI preferences (`lastSelectedTabIndex`), debug toggles, FCM token cache, JWT — things the user re-picks if they switch devices.

The rule is **strictly mutually exclusive**: a given piece of data lives in ONE of those two storage layers, not both. Loading the same value from SharedPreferences in one place and Drift in another guarantees drift, which guarantees mismatched dashboard / device displays, which is the bug class we keep hitting.

The rule, applied to every new code path:

1. **Write through Drift.** No `SharedPreferences`-only writes for state the server cares about. SharedPreferences is fine for ephemeral UI state (toast preferences, last-tab-index), but anything the dashboard or another device should see goes into a Drift table.

2. **Enqueue a sync_outbox row in the same transaction.** Drift DAOs that mutate a synced table must call `attachedDatabase.enqueueSyncOutbox(dataType: ..., entityKey: ...)` inside the same `transaction { ... }` block. If the row write succeeds but the outbox enqueue fails, the sync engine never learns about the change. See `GameDao.upsertWeeklyQuest`, `StoreDao.addCoins`, `GameDao.updateStatisticsFromJson` for the pattern.

3. **SyncEngine is the single pusher.** No service-level direct `api.postX(...)` calls for stateful writes. The SyncEngine drains the outbox, dispatches to the matching `ApiService.syncX(...)` method, and handles retries / failure buckets. A direct `unawaited(api.claim...)` "fast path" is only acceptable as a duplicate signal on top of the sync (the canonical claim still goes through Drift + outbox).

4. **Cubits hydrate from Drift on cold start, then optionally refresh from the server.** `initialize()` should set up usable in-memory state from Drift before any network call. Background refresh from the server is fine but never blocking. See `WeeklyQuestService.initialize`, `DailyChallengeService.refreshChallenges`.

5. **Backend client-mirror tables are what the dashboard reads.** `UserCoinBalance`, `UserBattlePassSnapshot`, `UserDailyChallengeClaim`, `UserWeeklyQuestClaim`, `UserStatistics.ModelJson` — these are the targets of the sync endpoints, and `GetUserDetailQueryHandler` reads from them (NOT the canonical `User.Coins` / `UserBattlePassProgress` / `UserDailyChallenge` gameplay tables). The operator wants to see what the client believes.

6. **Sync handlers must accept the client snapshot as authoritative for client-mirror state.** Reject-on-stale-timestamp is the wrong reconciliation strategy for any field the client owns — the client's local clock is the only place that fully captures offline writes. Per-field absorbing merges (MAX for monotonic counters, OR for absorbing-true flags) are the correct pattern for shared-write fields like achievements; pure last-write-wins is correct for client-owned fields like coin balance, settings, statistics.

### Anti-patterns to refuse
- Adding a service method that writes to a Drift table without enqueueing a sync_outbox row.
- Adding a cubit method that writes to `SharedPreferences` for state the dashboard or another device should see.
- Calling `ApiService.x()` from a service for a stateful mutation when a sync handler exists for that data type.
- A backend sync handler that silently rejects a client push because `server.UpdatedAt > client.UpdatedAt`. Either accept it (last-write-wins) or do a per-field merge — never drop on the floor.
- Storing replays on the backend. Replays are phone-only — they live in the Drift `replays` table and never enter the sync surface (no outbox row, no API endpoint, no DTO). Do not add a `GameReplay` entity or any cloud-side storage for them.

### Development Commands
- `flutter pub get` - Install dependencies
- `flutter run` - Run the app (ask user for platform preference first)
- `flutter run -d android` - Run on Android device/emulator
- `flutter run -d chrome` - Run on web browser
- `flutter build` - Build for production
- `flutter analyze` - Static analysis (run regularly during development)
- `flutter clean` - Clean build cache

### Development Workflow
- Run `flutter analyze` regularly to catch issues early
- Always ask user before running the project on specific platforms
- Prefer Android for testing unless user specifies otherwise

### Libraries to Consider
- **Audio**: `audioplayers` or `just_audio` for sound effects
- **Storage**: `shared_preferences` for high scores
- **Animations**: Flutter's built-in animation framework
- **State Management**: `provider` or `riverpod`
- **Particle Effects**: Custom implementation or `flame` particles

### Asset Structure
```
assets/
  audio/
    - background_music.mp3
    - eat_sound.wav
    - game_over.wav
    - click.wav
  images/
    - snake_head.png
    - snake_body.png
    - food_apple.png
    - background_textures/
  fonts/
    - game_font.ttf
```

### Performance Targets
- Maintain consistent 60FPS during gameplay
- Smooth animations and transitions
- Responsive touch controls (<50ms latency)
- Fast game state updates
- Efficient memory usage

## In-App Purchase Setup (RTDN)

### Google Play RTDN Setup
1. Create a Google Cloud service account with Android Publisher API access
2. Download the service account JSON and place it at `snake-classic-backend/google-play-service-account.json`
3. In Google Cloud Console:
   - Enable Cloud Pub/Sub API
   - Create a Pub/Sub topic (e.g., `snake-classic-rtdn`)
   - Create a push subscription pointing to: `https://snakeclassic.pranta.dev/api/v1/purchases/webhook/google-play?token=YOUR_TOKEN`
4. In Google Play Console:
   - Go to Monetization setup > Real-time developer notifications
   - Set the topic to the Pub/Sub topic created above
5. Set environment variables in backend `.env`:
   - `GOOGLE_PLAY_SERVICE_ACCOUNT_PATH`
   - `GOOGLE_PLAY_PACKAGE_NAME=com.pranta.snakeclassic`
   - `GOOGLE_PLAY_PUBSUB_VERIFICATION_TOKEN`

### Apple App Store Server Notifications V2
1. In App Store Connect:
   - Go to App > App Information > App Store Server Notifications
   - Set Production URL: `https://snakeclassic.pranta.dev/api/v1/purchases/webhook/app-store`
   - Set Sandbox URL: same but with sandbox backend
2. Generate App Store Connect API key and set in backend `.env`:
   - `APPLE_KEY_ID`, `APPLE_ISSUER_ID`, `APPLE_PRIVATE_KEY`, `APPLE_BUNDLE_ID`

### Testing
- Use Google Play Console test tracks for subscription testing
- Use sandbox Apple ID for iOS testing
- Monitor Hangfire dashboard at `/hangfire` for background job status
- Check subscription events via `GET /api/v1/subscription/history`