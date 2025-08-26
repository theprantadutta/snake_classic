import 'package:flutter/foundation.dart';
import 'package:snake_classic/utils/constants.dart';
import 'package:snake_classic/services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  GameTheme _currentTheme = GameTheme.classic;
  final StorageService _storageService = StorageService();
  bool _initialized = false;

  GameTheme get currentTheme => _currentTheme;
  bool get isInitialized => _initialized;

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _currentTheme = await _storageService.getSelectedTheme();
    _initialized = true;
    notifyListeners();
  }

  Future<void> setTheme(GameTheme theme) async {
    if (_currentTheme != theme) {
      _currentTheme = theme;
      await _storageService.saveSelectedTheme(theme);
      notifyListeners();
    }
  }

  void cycleTheme() {
    final themes = GameTheme.values;
    final currentIndex = themes.indexOf(_currentTheme);
    final nextIndex = (currentIndex + 1) % themes.length;
    setTheme(themes[nextIndex]);
  }
}