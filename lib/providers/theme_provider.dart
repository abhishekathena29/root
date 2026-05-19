import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LauncherThemeType { typography, bauhaus, terminal }

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'launcher_theme';
  static const _intentWallKey = 'intent_wall_enabled';

  LauncherThemeType _currentTheme = LauncherThemeType.terminal;
  bool _isIntentWallEnabled = true;
  bool _initialized = false;

  LauncherThemeType get currentTheme => _currentTheme;
  bool get isIntentWallEnabled => _isIntentWallEnabled;
  bool get isInitialized => _initialized;

  /// Load saved preferences from disk. Call once at app startup.
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    final themeIndex = prefs.getInt(_themeKey);
    if (themeIndex != null &&
        themeIndex >= 0 &&
        themeIndex < LauncherThemeType.values.length) {
      _currentTheme = LauncherThemeType.values[themeIndex];
    }

    _isIntentWallEnabled = prefs.getBool(_intentWallKey) ?? true;
    _initialized = true;
    notifyListeners();
  }

  void setTheme(LauncherThemeType theme) {
    _currentTheme = theme;
    notifyListeners();
    _save();
  }

  void nextTheme() {
    final nextIndex = (_currentTheme.index + 1) % LauncherThemeType.values.length;
    _currentTheme = LauncherThemeType.values[nextIndex];
    notifyListeners();
    _save();
  }

  void toggleIntentWall(bool value) {
    _isIntentWallEnabled = value;
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _currentTheme.index);
    await prefs.setBool(_intentWallKey, _isIntentWallEnabled);
  }
}
