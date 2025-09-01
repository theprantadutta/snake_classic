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
Consider adding Crashlytics for production:
```yaml
dependencies:
  firebase_crashlytics: ^latest_version
```

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