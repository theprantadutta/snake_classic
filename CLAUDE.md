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