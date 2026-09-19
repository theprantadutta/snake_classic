# 🚀 Snake Classic - Deployment Setup Instructions

## Firebase Setup

### 1. Deploy Firestore Security Rules
```bash
# Navigate to your project directory
cd snake_classic

# Deploy the rules
firebase deploy --only firestore:rules
```

### 2. Create Required Firestore Indexes

Run these commands in your Firebase project console or use the Firebase CLI:

```bash
# Create composite index for user search
firebase firestore:indexes

# Or create manually in Firebase Console:
```

**Manual Index Creation:**
1. Go to Firebase Console → Firestore → Indexes
2. Create these composite indexes:

**Index 1: User Search**
- Collection ID: `users`
- Fields:
  - `username` (Ascending)
  - `isPublic` (Ascending)

**Index 2: Leaderboards**  
- Collection ID: `users`
- Fields:
  - `highScore` (Descending) 
  - `isPublic` (Ascending)

**Index 3: Friend Requests**
- Collection ID: `friendRequests`
- Fields:
  - `toUserId` (Ascending)
  - `createdAt` (Descending)

### 3. Authentication Setup

Ensure these are enabled in Firebase Console → Authentication → Sign-in methods:
- [ ] Google Sign-In
- [ ] Anonymous Authentication (optional)

## Application Configuration

### 1. Dependencies Check
Ensure all required packages are in `pubspec.yaml`:
```yaml
dependencies:
  uuid: ^4.5.1
  shared_preferences: ^2.2.3
  firebase_core: ^4.0.0
  firebase_auth: ^6.0.1
  cloud_firestore: ^6.0.0
  google_sign_in: ^7.1.1
```

### 2. Platform-Specific Setup

**Android:**
- Ensure `google-services.json` is in `android/app/`
- Check `android/app/build.gradle` for proper configuration

**iOS:**
- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Check `ios/Runner/Info.plist` for URL schemes

**Web:**
- Ensure Firebase config is in `web/index.html`
- Check CORS settings for Firebase domains

## Testing Checklist

### Pre-Deployment Testing
- [ ] Guest user creation works
- [ ] Username generation is unique
- [ ] Username validation works
- [ ] Authentication migration preserves data
- [ ] Settings username change works
- [ ] Leaderboards show usernames
- [ ] Social features work with usernames

### Production Testing
- [ ] Firebase rules prevent unauthorized access
- [ ] Username uniqueness is enforced
- [ ] Migration works with real Firebase
- [ ] Performance is acceptable
- [ ] Error handling works properly

## Launch Commands

### Development Testing
```bash
flutter run -d chrome  # Web testing
flutter run -d android # Android testing
flutter run -d ios     # iOS testing
```

### Production Build
```bash
# Web
flutter build web

# Android
flutter build apk --release
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Monitoring Setup

### Firebase Analytics
The app includes Firebase Analytics tracking for:
- User creation events
- Username changes
- Authentication events
- Game completion events

### Error Monitoring
Already wired, via Sentry — see `lib/core/observability/`, and `SENTRY.md`
in the workspace root alongside this repo (it covers the backend too).

**Build Play releases with `./tools/release_android.sh`, not `flutter build`
directly.** The script builds with the obfuscation / split-debug-info flags
and uploads the symbols in one step, and refuses to finish quietly if
`SENTRY_AUTH_TOKEN` is unset:

Put the auth token in **`.sentry-auth-token`** at the repo root — just the
token, nothing else. It is gitignored, and both scripts read it
automatically, so a release is a single command:

```bash
./tools/release_android.sh     # Git Bash / macOS / Linux
```

```powershell
.\tools\release_android.ps1    # Windows PowerShell
```

Releases are cut from Windows, so both exist and must stay in step. If you
change one, change the other. `SENTRY_AUTH_TOKEN` in the environment still
wins if it is already set, which is what CI would use.

> ⚠️ **Never put the token in `.env`.** That file is declared as a Flutter
> asset (`- .env` under `assets:` in pubspec.yaml), so it is packed into the
> APK/AAB — verified: a built bundle contains
> `base/assets/flutter_assets/.env`. Anyone who downloads the app from Play
> can unzip it and read the file. Public client ids there are fine; a Sentry
> write credential is not. Both scripts **refuse to build** if they find a
> non-empty `SENTRY_AUTH_TOKEN` in `.env`, because the mistake is otherwise
> completely silent — the build would succeed and the upload would work.

This is not a style preference. 6.6.0+56 was built with a plain
`flutter build appbundle` and no upload, and the first crash Play's
pre-launch check produced came back with `<unknown>` where our frames should
have been. Nothing failed and nothing warned — the build succeeded and the
symbols simply never existed.

Symbols must come from the **same** build you upload. Rebuilding afterwards
produces a different binary, and the debug IDs no longer match.

**The script uploads in two passes and only the second one is fatal.**
`sentry_dart_plugin` crashes on Windows with a `PathNotFoundException` on a
path ending in a literal `*` — it hands a glob to a directory listing, which
Unix expands and Windows does not — and it does so *after* its uploads
succeed. So its exit code is ignored, and the script then uploads
`build/debug-info` (the three per-ABI Dart debug companions) with
`sentry-cli` directly and fails only if that fails.

That second pass is not belt-and-braces. On 6.6.1+57 the plugin crashed
mid-walk having uploaded arm64 and x86_64 but not armeabi-v7a, so every
32-bit device would have reported unreadable traces with nothing saying why.

**The scripts refuse to rebuild a version that has already been released.**
Forgetting to bump `version:` otherwise costs a full build before Play
rejects the duplicate version code. Two signals: Sentry (which knows a
release once events arrive from it, and needs no local state) and
`.released-versions` (a gitignored local ledger, appended after each
successful upload, covering versions shipped but not yet run by anyone).
Pass `--force` / `-Force` to rebuild deliberately.

### iOS — `tools/release_ios.sh` (UNVERIFIED)

> ⚠️ **This script has never been run.** It was written on Windows with no
> macOS and no Xcode, by translating the Android script and applying the
> documented iOS differences. The Android logic in it is proven; the
> iOS-specific parts are reasoned-about, not observed. Treat the first run
> as a test of the script, not of your release — there is a FIRST RUN
> CHECKLIST at the bottom of the file.

```bash
./tools/release_ios.sh          # macOS only; refuses to run elsewhere
```

Three things differ from Android and are worth knowing before you run it:

- **dSYMs are a third upload pass with no Android counterpart.** Without
  them, a native iOS crash (the engine, a plugin's Swift/ObjC, a signal)
  symbolicates to hex. The Dart debug companions do not cover that. Their
  location has moved between Xcode versions, so the script tries several
  and warns loudly if it finds none.
- **The already-released guard will false-positive across platforms.** iOS
  and Android build from the same pubspec version, and Sentry's release id
  does not distinguish them, so shipping Android first makes the iOS build
  of that same version look already-released. Use `--force` for whichever
  you build second, or split the version streams.
- **The DWARF/strip behaviour is unchecked on iOS.** On Android, Gradle's
  `stripReleaseDebugSymbols` removes the debug info before packaging —
  verified against a real bundle. There is no equivalent verification for
  the iOS path yet.

## Security Verification

### Test Security Rules
```javascript
// Test in Firebase Console → Firestore → Rules
// Simulate reads/writes with different user contexts
```

### Username Uniqueness Test
1. Create two test accounts
2. Try to set same username
3. Verify second attempt fails
4. Check username lookup collection

## Performance Optimization

### Recommended Settings
- Enable offline persistence: `FirebaseFirestore.instance.enablePersistence()`
- Use proper indexing for all queries
- Implement pagination for large datasets
- Cache frequently accessed data

### Production Optimizations
```dart
// In main.dart, add:
FirebaseFirestore.instance.settings = Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

## Rollout Strategy

### Phase 1: Beta Testing
- Deploy to limited test users
- Monitor user creation patterns
- Test authentication flows
- Verify username system works

### Phase 2: Soft Launch
- Release to 10% of users
- Monitor Firebase usage
- Check performance metrics
- Gather user feedback

### Phase 3: Full Launch
- Deploy to all users
- Monitor system performance
- Track user engagement
- Implement feedback

## Support & Maintenance

### Regular Tasks
- Monitor Firebase usage/costs
- Review security rules
- Update dependencies
- Check analytics data
- Backup user data

### Emergency Procedures
- How to disable user registration
- How to migrate user data
- How to rollback changes
- Contact information for support

---

## 🎯 Quick Start

For immediate deployment:

1. `firebase deploy --only firestore:rules`
2. Create indexes in Firebase Console
3. Test authentication flows
4. Deploy to your platform
5. Monitor user creation

Your Snake Classic app is ready for production with a complete user system! 🐍✨