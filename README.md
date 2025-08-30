# 🐍 Snake Classic - Flutter Game

A premium, modern implementation of the classic Snake game built with Flutter, featuring stunning visuals, smooth 60FPS gameplay, and immersive audio experience.

## 📸 Screenshots

<!-- TODO: Add screenshots here -->
*Screenshots will be added here showcasing the game's premium UI and different themes.*

## ✨ Features

### 🎮 Core Gameplay
- **Classic Snake mechanics** with modern enhancements
- **60FPS smooth gameplay** with optimized rendering
- **Grid-based movement** on 20x20 game board
- **Progressive difficulty** - speed increases with level
- **Enhanced crash feedback** - 5-second modal explaining why game ended
- **Multiple food types** with accurate visual representations:
  - 🍎 Apple Food (10 points) - red apple with stem and leaf
  - ✨ Bonus Food (25 points, expires in 15s) - glowing circle with sparkles
  - ⭐ Special Food (50 points) - 8-pointed pulsing star

### 🎨 Visual Experience
- **Six premium themes**:
  - **Classic** - Traditional retro green monochrome
  - **Modern** - Sleek contemporary blue design  
  - **Neon** - Electric cyberpunk with glowing effects
  - **Retro** - Warm earth tones with vintage gaming feel
  - **Space** - Cosmic purple hues for interstellar adventures
  - **Ocean** - Deep sea blues with coral accents
- **Smooth animations** throughout the UI
- **Custom particle effects** for special events
- **Gradient buttons** with haptic feedback
- **Animated snake logo** on home screen
- **Theme selector screen** with live previews and descriptions

### 🌐 Online Features
- **Google Sign-In Authentication** with Firebase integration
- **Anonymous sign-in option** for guest players
- **Global leaderboards** with real-time updates and user rankings
- **Weekly leaderboards** showcasing recent achievements
- **User profiles** with comprehensive statistics and progress tracking
- **Cross-platform synchronization** of scores and achievements
- **Secure data persistence** with Firebase Firestore

### 🏆 Achievement System
- **16 unique achievements** across multiple categories:
  - **Score Achievements**: First Bite, Century Club, High Roller, Snake Master, Legendary Serpent
  - **Games Played**: Getting Started, Persistent Player, Dedicated Gamer, Snake Addict
  - **Survival Challenges**: Survivor, Endurance Master
  - **Special Feats**: Wall Avoider, Speedster, Perfectionist, Gourmet
- **Rarity system** (Common, Rare, Epic, Legendary) with unique visual indicators
- **Progress tracking** for locked achievements with completion percentages
- **Animated notifications** for newly unlocked achievements
- **Achievement browser** with filtering and detailed statistics

### 🎵 Audio System
- **Complete sound effects**:
  - Food consumption sounds
  - Game over alerts
  - Level up celebrations
  - Button click feedback
  - High score achievements
- **Background music** with volume controls
- **System sound fallbacks** for reliability

### 🎯 Controls & UX
- **Enhanced swipe detection** with full-screen responsive gestures
- **Visual gesture feedback** with bottom-left direction indicator
- **Haptic feedback** for all interactions
- **Crash feedback system** with detailed explanation modals:
  - 🧱 Wall collision warnings
  - 🐍 Self-collision alerts
  - 5-second auto-continue or tap to skip
- **Comprehensive on-screen instructions** matching actual food visuals
- **Pause/resume functionality**
- **Fully responsive layout** adapting to all screen sizes

### 💾 Persistence & Storage
- **Dual storage system** with local and cloud backup
- **High score synchronization** across devices (when signed in)
- **Achievement progress** saved locally and in Firebase
- **User preferences** including theme selection and audio settings
- **Cross-platform compatibility** with automatic data migration
- **Offline support** with local storage fallback for guest users

## 🏗️ Architecture

### 📁 Project Structure
```
lib/
├── models/           # Game data models
│   ├── achievement.dart        # Achievement system models
│   ├── food.dart
│   ├── game_state.dart
│   ├── position.dart
│   └── snake.dart
├── providers/        # State management
│   ├── game_provider.dart
│   ├── theme_provider.dart
│   └── user_provider.dart      # User authentication state
├── screens/          # UI screens
│   ├── achievements_screen.dart # Achievement browser
│   ├── game_over_screen.dart
│   ├── game_screen.dart
│   ├── home_screen.dart
│   ├── leaderboard_screen.dart # Global and weekly leaderboards
│   ├── profile_screen.dart     # User profile and sign-in
│   ├── settings_screen.dart
│   └── theme_selector_screen.dart # Visual theme browser
├── services/         # Business logic
│   ├── achievement_service.dart # Achievement tracking
│   ├── auth_service.dart       # Firebase authentication
│   ├── audio_service.dart
│   ├── leaderboard_service.dart # Firestore leaderboards
│   └── storage_service.dart
├── utils/           # Utilities
│   ├── constants.dart          # Enhanced with 6 themes
│   └── direction.dart
└── widgets/         # Reusable components
    ├── achievement_notification.dart # Achievement popups
    ├── animated_snake_logo.dart
    ├── crash_feedback_overlay.dart
    ├── game_board.dart         # Enhanced theme rendering
    ├── game_hud.dart
    ├── gradient_button.dart
    ├── instructions_dialog.dart
    ├── particle_effect.dart
    ├── pause_overlay.dart
    └── swipe_detector.dart
```

### 🛠️ Technical Stack
- **Flutter** - Cross-platform UI framework
- **Provider** - State management for game state and user data
- **Firebase Core** - Backend infrastructure and authentication
- **Firebase Auth** - User authentication and profile management
- **Cloud Firestore** - Real-time database for leaderboards and achievements
- **Google Sign-In** - Authentication provider integration
- **AudioPlayers** - Audio system with AssetSource
- **SharedPreferences** - Local storage and offline support
- **FlutterAnimate** - Smooth animations and visual effects
- **VectorMath** - Game physics and calculations

## 🎯 Performance Features

- **Custom painting** for 60FPS game board rendering with RepaintBoundary optimization
- **Efficient collision detection** with specific crash reason tracking
- **Memory-optimized** audio management with proper disposal
- **Smooth animations** with home screen performance improvements
- **Responsive gesture recognition** with full-screen detection
- **Square food rendering** preventing visual distortion across different screen ratios
- **Configurable timing constants** for easy maintenance

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.9.0)
- Dart SDK
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd snake_classic
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Development Commands
```bash
flutter pub get          # Install dependencies
flutter run              # Run on default device
flutter run -d android   # Run on Android
flutter run -d chrome    # Run on web browser
flutter analyze          # Static analysis
flutter build            # Build for production
flutter clean            # Clean build cache
```

## 🎮 How to Play

### Controls
- **Swipe Up/Down/Left/Right** - Change snake direction
- **Tap Screen** - Pause/Resume game
- **Arrow Keys / WASD** - Change direction (Desktop)
- **Spacebar** - Pause/Resume (Desktop)

### Gameplay
1. Control the snake to eat food and grow
2. Avoid hitting walls or the snake's own body
3. Collect different food types for bonus points
4. Try to achieve the highest score possible
5. Game speed increases with each level

## 🎨 Customization

### Themes
The game features six distinct visual themes:
- Access via Settings → Visual Theme → Browse Themes
- Each theme has unique color schemes and visual effects
- Theme selection is automatically saved
- Live previews available in theme selector

### Game Settings
- **Board Size**: Choose from Small (15x15), Classic (20x20), Large (25x25), or Huge (30x30)
- **Crash Feedback Duration**: Customize timing from 2-10 seconds
- **Visual Theme**: Select from 6 premium themes with live previews

### Audio Settings
- Toggle sound effects on/off
- Control background music
- Individual volume controls
- Settings persist between sessions

## 🔧 Development Notes

### Code Quality
- **Flutter analyze** passes with minimal warnings
- **Modern Flutter patterns** throughout codebase
- **Proper error handling** with graceful fallbacks
- **Comprehensive documentation** in code

### Performance Optimizations
- Custom `GameBoardPainter` for efficient rendering
- Proper widget lifecycle management
- Optimized collision detection algorithms
- Memory-conscious audio service

### Cross-Platform Support
- **Android** - Primary target platform
- **iOS** - Fully supported
- **Web** - Compatible with responsive design
- **Desktop** - Windows/macOS/Linux support

## 📝 Changelog

### 🚀 Major Feature Updates (Latest Release)
- ✅ **Google Sign-In Authentication** - Full Firebase integration with user profiles
- ✅ **Online Leaderboards** - Global and weekly leaderboards with real-time sync
- ✅ **Comprehensive Achievement System** - 16 achievements across 4 categories with rarity levels
- ✅ **Enhanced Visual Themes** - 6 premium themes (Classic, Modern, Neon, Retro, Space, Ocean)
- ✅ **Theme Selector Screen** - Beautiful theme browser with live previews
- ✅ **Firebase Integration** - Complete backend infrastructure for online features
- ✅ **User Profile System** - Profile screen with statistics and sign-in/out functionality
- ✅ **Achievement Notifications** - Animated popups for unlocked achievements
- ✅ **Advanced Theme Effects** - Theme-specific visual effects and rendering enhancements
- ✅ **Custom Game Board Sizes** - Four size options with visual selector and persistence
- ✅ **Customizable Crash Feedback Duration** - User-configurable timing (2-10 seconds)
- ✅ **Enhanced Home Screen Layout** - Scrollable interface with optimized spacing

### Previous Updates
- ✅ **Crash feedback system** - 5-second modal explaining game over reasons
- ✅ **Visual food improvements** - apple-shaped normal food with proper proportions
- ✅ **Responsive layout fixes** - all screens adapt to different screen sizes
- ✅ **Enhanced gesture controls** - full-screen swipe detection with visual feedback
- ✅ **Home screen performance** - optimized animations and reduced jank
- ✅ **Game instructions accuracy** - icons now match actual rendered food types
- ✅ **Layout optimization** - removed fixed heights, added RepaintBoundary isolation
- ✅ **Constants refactoring** - configurable timing for easy maintenance
- ✅ Complete audio system implementation
- ✅ Premium UI with original three themes
- ✅ Particle effects and animations
- ✅ High score persistence

## 🤝 Contributing

This project follows conventional commit standards:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation updates
- `style:` - Code formatting
- `refactor:` - Code refactoring
- `perf:` - Performance improvements

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 🎯 Development Roadmap

### ✅ Completed Features
- [x] **Online leaderboards** - Global and weekly leaderboards with Firebase
- [x] **Achievement system** - 16 achievements with rarity levels and progress tracking
- [x] **More visual themes** - Added Retro, Space, and Ocean themes (6 total)
- [x] **User authentication** - Google Sign-In and anonymous options
- [x] **Firebase integration** - Complete backend infrastructure
- [x] **Advanced UI/UX** - Theme selector, profile screen, achievement notifications
- [x] **Custom game board sizes** - Four size options (15x15, 20x20, 25x25, 30x30) with visual selector
- [x] **Customizable crash feedback duration** - User-configurable timing (2-10 seconds)
- [x] **Enhanced home screen layout** - Scrollable interface with optimized spacing

### 🚧 Upcoming Features
- [ ] **Multiplayer mode** - Real-time multiplayer with Firebase sync
- [ ] **Power-ups and special abilities** - Temporary boosts and special effects
- [ ] **Crash replay system** - Analyze and replay game over moments
- [ ] **Social features** - Friend systems and private leaderboards
- [ ] **Tournament mode** - Competitive events and challenges
- [ ] **Advanced statistics** - Detailed gameplay analytics and insights

---

**Built with ❤️ using Flutter**

*A modern take on the timeless classic that started it all.*