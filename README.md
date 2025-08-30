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
- **Three premium themes**:
  - **Classic** - Traditional retro style
  - **Modern** - Sleek contemporary design  
  - **Neon** - Cyberpunk-inspired visuals
- **Smooth animations** throughout the UI
- **Custom particle effects** for special events
- **Gradient buttons** with haptic feedback
- **Animated snake logo** on home screen

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

### 💾 Persistence
- **High score tracking** with local storage
- **Settings persistence** for user preferences
- **Theme selection memory**

## 🏗️ Architecture

### 📁 Project Structure
```
lib/
├── models/           # Game data models
│   ├── food.dart
│   ├── game_state.dart
│   ├── position.dart
│   └── snake.dart
├── providers/        # State management
│   ├── game_provider.dart
│   └── theme_provider.dart
├── screens/          # UI screens
│   ├── game_over_screen.dart
│   ├── game_screen.dart
│   ├── home_screen.dart
│   └── settings_screen.dart
├── services/         # Business logic
│   ├── audio_service.dart
│   └── storage_service.dart
├── utils/           # Utilities
│   ├── constants.dart
│   └── direction.dart
└── widgets/         # Reusable components
    ├── animated_snake_logo.dart
    ├── game_board.dart
    ├── game_hud.dart
    ├── gradient_button.dart
    ├── instructions_dialog.dart
    ├── pause_overlay.dart
    ├── particle_effect.dart
    ├── swipe_detector.dart
    └── crash_feedback_overlay.dart
```

### 🛠️ Technical Stack
- **Flutter** - Cross-platform UI framework
- **Provider** - State management
- **AudioPlayers** - Audio system with AssetSource
- **SharedPreferences** - Local storage
- **FlutterAnimate** - Animations and effects
- **VectorMath** - Game calculations

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
The game features three distinct visual themes:
- Access via Settings → Visual Theme
- Each theme has unique color schemes and visual effects
- Theme selection is automatically saved

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

### Latest Updates
- ✅ **Crash feedback system** - 5-second modal explaining game over reasons
- ✅ **Visual food improvements** - apple-shaped normal food with proper proportions
- ✅ **Responsive layout fixes** - all screens adapt to different screen sizes
- ✅ **Enhanced gesture controls** - full-screen swipe detection with visual feedback
- ✅ **Home screen performance** - optimized animations and reduced jank
- ✅ **Game instructions accuracy** - icons now match actual rendered food types
- ✅ **Layout optimization** - removed fixed heights, added RepaintBoundary isolation
- ✅ **Constants refactoring** - configurable timing for easy maintenance
- ✅ Complete audio system implementation
- ✅ Premium UI with three themes
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

## 🎯 Future Enhancements

- [ ] Online leaderboards
- [ ] Achievement system  
- [ ] More visual themes
- [ ] Multiplayer mode
- [ ] Custom game board sizes
- [ ] Power-ups and special abilities
- [ ] Crash replay system
- [ ] Customizable crash feedback duration

---

**Built with ❤️ using Flutter**

*A modern take on the timeless classic that started it all.*