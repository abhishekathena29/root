import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LauncherThemeType { typography, bauhaus, terminal }

class ThemeProvider extends ChangeNotifier {
  static const _themeKey = 'launcher_theme';
  static const _intentWallKey = 'intent_wall_enabled';
  static const _pinnedAppsKey = 'pinned_apps';
  static const _iconsEnabledKey = 'icons_enabled';
  static const _statusStripKey = 'status_strip_enabled';
  static const _bauhausColumnsKey = 'bauhaus_columns';
  static const _walkthroughKey = 'has_seen_walkthrough';
  static const _seenThemeTipsKey = 'seen_theme_tips';

  LauncherThemeType _currentTheme = LauncherThemeType.terminal;
  bool _isIntentWallEnabled = true;
  bool _isIconsEnabled = false;
  bool _isStatusStripEnabled = true;
  int _bauhausColumns = 3;
  List<String> _pinnedApps = [];
  bool _hasSeenWalkthrough = false;
  Set<String> _seenThemeTips = {};
  bool _initialized = false;

  LauncherThemeType get currentTheme => _currentTheme;
  bool get isIntentWallEnabled => _isIntentWallEnabled;
  bool get isIconsEnabled => _isIconsEnabled;
  bool get isStatusStripEnabled => _isStatusStripEnabled;
  int get bauhausColumns => _bauhausColumns;
  List<String> get pinnedApps => List.unmodifiable(_pinnedApps);
  bool get hasSeenWalkthrough => _hasSeenWalkthrough;
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
    _isIconsEnabled = prefs.getBool(_iconsEnabledKey) ?? false;
    _isStatusStripEnabled = prefs.getBool(_statusStripKey) ?? true;
    _bauhausColumns = prefs.getInt(_bauhausColumnsKey) ?? 3;
    _pinnedApps = prefs.getStringList(_pinnedAppsKey) ?? [];
    _hasSeenWalkthrough = prefs.getBool(_walkthroughKey) ?? false;
    _seenThemeTips = (prefs.getStringList(_seenThemeTipsKey) ?? []).toSet();

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

  void toggleIcons(bool value) {
    _isIconsEnabled = value;
    notifyListeners();
    _save();
  }

  void toggleStatusStrip(bool value) {
    _isStatusStripEnabled = value;
    notifyListeners();
    _save();
  }

  void setBauhausColumns(int columns) {
    _bauhausColumns = columns;
    notifyListeners();
    _save();
  }

  bool isPinned(String packageName) => _pinnedApps.contains(packageName);

  /// Pins (or unpins) an app to the theme's quick-access surface
  /// (Typography's home page / Bauhaus's dock).
  void togglePinned(String packageName) {
    final updated = List<String>.of(_pinnedApps);
    if (!updated.remove(packageName)) {
      updated.add(packageName);
    }
    _pinnedApps = updated;
    notifyListeners();
    _save();
  }

  /// Moves a pinned app from [oldIndex] to [newIndex] (already adjusted for
  /// the removed item, per [ReorderableListView.onReorderItem]), letting the
  /// user arrange their quick-access apps in whatever order they like.
  void reorderPinned(int oldIndex, int newIndex) {
    final updated = List<String>.of(_pinnedApps);
    final moved = updated.removeAt(oldIndex);
    updated.insert(newIndex, moved);
    _pinnedApps = updated;
    notifyListeners();
    _save();
  }

  bool hasSeenThemeTip(LauncherThemeType theme) => _seenThemeTips.contains(theme.name);

  void markThemeTipSeen(LauncherThemeType theme) {
    _seenThemeTips = Set<String>.of(_seenThemeTips)..add(theme.name);
    notifyListeners();
    _save();
  }

  void markWalkthroughSeen() {
    _hasSeenWalkthrough = true;
    notifyListeners();
    _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_themeKey, _currentTheme.index);
    await prefs.setBool(_intentWallKey, _isIntentWallEnabled);
    await prefs.setBool(_iconsEnabledKey, _isIconsEnabled);
    await prefs.setBool(_statusStripKey, _isStatusStripEnabled);
    await prefs.setInt(_bauhausColumnsKey, _bauhausColumns);
    await prefs.setStringList(_pinnedAppsKey, _pinnedApps);
    await prefs.setBool(_walkthroughKey, _hasSeenWalkthrough);
    await prefs.setStringList(_seenThemeTipsKey, _seenThemeTips.toList());
  }
}
