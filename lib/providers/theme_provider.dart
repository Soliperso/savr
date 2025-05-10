import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_theme.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  SharedPreferences? _prefs;
  ThemeMode _themeMode = ThemeMode.system;
  bool _initialized = false;

  ThemeProvider() {
    _initializeTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  bool get isInitialized => _initialized;

  /// Initialize the theme provider
  Future<void> _initializeTheme() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadThemeMode();
    } catch (e) {
      debugPrint('Error initializing theme: $e');
      _themeMode = ThemeMode.system;
    } finally {
      _initialized = true;
      notifyListeners();
    }
  }

  /// Load the saved theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final savedThemeMode = _prefs?.getString(_themeKey);
      if (savedThemeMode != null) {
        _themeMode = _themeModeFromString(savedThemeMode);
      }
    } catch (e) {
      debugPrint('Error loading theme mode: $e');
      _themeMode = ThemeMode.system;
    }
  }

  /// Convert a string to ThemeMode enum
  ThemeMode _themeModeFromString(String themeMode) {
    try {
      return ThemeMode.values.firstWhere(
        (mode) => mode.toString() == themeMode,
        orElse: () => ThemeMode.system,
      );
    } catch (e) {
      debugPrint('Error parsing theme mode: $e');
      return ThemeMode.system;
    }
  }

  /// Toggle between light and dark theme
  Future<void> toggleTheme() async {
    if (!_initialized) {
      debugPrint('Theme provider not initialized');
      return;
    }

    try {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      await _prefs?.setString(_themeKey, _themeMode.toString());
      notifyListeners();
    } catch (e) {
      debugPrint('Error toggling theme: $e');
      // Revert the change if saving fails
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    }
  }

  /// Set a specific theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    if (!_initialized) {
      debugPrint('Theme provider not initialized');
      return;
    }

    if (_themeMode == mode) return;

    try {
      _themeMode = mode;
      await _prefs?.setString(_themeKey, mode.toString());
      notifyListeners();
    } catch (e) {
      debugPrint('Error setting theme mode: $e');
      // Revert the change if saving fails
      _themeMode = ThemeMode.system;
      notifyListeners();
    }
  }

  /// Get the current theme based on the theme mode
  ThemeData get theme {
    if (!_initialized) {
      return AppTheme.lightTheme;
    }

    switch (_themeMode) {
      case ThemeMode.dark:
        return AppTheme.darkTheme;
      case ThemeMode.light:
        return AppTheme.lightTheme;
      case ThemeMode.system:
        final brightness =
            WidgetsBinding.instance.platformDispatcher.platformBrightness;
        return brightness == Brightness.dark
            ? AppTheme.darkTheme
            : AppTheme.lightTheme;
    }
  }
}
