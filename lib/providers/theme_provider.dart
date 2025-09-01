import 'package:flutter/material.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/services/storage_service.dart';
import 'package:snake_classic/widgets/theme_transition_system.dart';

class ThemeProvider extends ChangeNotifier {
  GameTheme _currentTheme = GameTheme.classic;
  final StorageService _storageService = StorageService();
  bool _initialized = false;
  bool _trailSystemEnabled = false; // Default to false
  
  ThemeTransitionController? _transitionController;

  GameTheme get currentTheme => _currentTheme;
  bool get isInitialized => _initialized;
  bool get isTrailSystemEnabled => _trailSystemEnabled;

  ThemeProvider() {
    _loadTheme();
  }
  
  ThemeTransitionController? get transitionController => _transitionController;
  
  void initializeTransitions(TickerProvider vsync) {
    _transitionController ??= ThemeTransitionController(vsync: vsync);
  }

  Future<void> _loadTheme() async {
    _currentTheme = await _storageService.getSelectedTheme();
    _trailSystemEnabled = await _storageService.isTrailSystemEnabled();
    _initialized = true;
    notifyListeners();
  }

  Future<void> setTheme(GameTheme theme, {
    TransitionType transitionType = TransitionType.fade,
    Duration? duration,
  }) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      
      // Trigger theme transition if available
      if (_transitionController != null) {
        await _transitionController!.transitionToTheme(
          theme,
          type: transitionType,
          duration: duration,
        );
      }
      
      await _storageService.saveSelectedTheme(theme);
      notifyListeners();
    }
  }

  void cycleTheme() {
    final themes = GameTheme.values;
    final currentIndex = themes.indexOf(_currentTheme);
    final nextIndex = (currentIndex + 1) % themes.length;
    final nextTheme = themes[nextIndex];
    
    // Use theme-specific transition
    final preferredTransition = ThemeTransitionPresets.getPreferredTransition(nextTheme);
    setTheme(nextTheme, transitionType: preferredTransition);
  }

  Future<void> setTrailSystemEnabled(bool enabled) async {
    if (_trailSystemEnabled != enabled) {
      _trailSystemEnabled = enabled;
      await _storageService.setTrailSystemEnabled(enabled);
      notifyListeners();
    }
  }
  
  @override
  void dispose() {
    _transitionController?.dispose();
    super.dispose();
  }
}