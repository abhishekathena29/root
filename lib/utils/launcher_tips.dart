import '../providers/theme_provider.dart';

/// A short "how to use" blurb for a theme (or for gestures that work
/// everywhere), shared between the per-theme tip sheet and the walkthrough.
class ThemeTip {
  final String title;
  final List<String> bullets;

  const ThemeTip({required this.title, required this.bullets});
}

const Map<LauncherThemeType, ThemeTip> kThemeTips = {
  LauncherThemeType.typography: ThemeTip(
    title: 'list & typography',
    bullets: [
      'tap an app to open it',
      'long-press an app on "all apps" to pin it to your home screen',
      'drag pinned apps on the home screen to arrange them however you like',
      'swipe left or right to move between home and all apps',
      'type to search, or drag the a-z rail on the right edge',
    ],
  ),
  LauncherThemeType.bauhaus: ThemeTip(
    title: 'bauhaus geometric',
    bullets: [
      'tap a shape to open its app',
      'long-press an app in the grid to pin it to the dock up top',
      'drag dock apps to arrange them however you like',
      'change grid density (3-5 columns) in settings',
    ],
  ),
  LauncherThemeType.terminal: ThemeTip(
    title: 'terminal / command',
    bullets: [
      'start typing to filter apps instantly',
      'try commands: call, msg, note, calc, search, sys',
      'type help anytime for the full command list',
    ],
  ),
};

const kUniversalTips = ThemeTip(
  title: 'everywhere',
  bullets: [
    'long-press the clock to switch between typography, bauhaus and terminal',
    'double-tap anywhere to lock the screen',
    'open settings (gear icon) to toggle the intent wall, icons, status strip and wallpaper',
  ],
);
