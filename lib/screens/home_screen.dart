import 'package:flutter/material.dart';
import 'package:installed_apps/app_info.dart';
import 'package:installed_apps/installed_apps.dart';

import '../providers/theme_provider.dart';
import '../services/launcher_service.dart';
import '../styles/bauhaus_style.dart';
import '../styles/terminal_style.dart';
import '../styles/typography_style.dart';
import '../widgets/digital_grain.dart';
import '../widgets/minimal_clock.dart';
import '../widgets/status_strip.dart';
import 'settings_screen.dart';
import 'walkthrough_screen.dart';

class HomeScreen extends StatefulWidget {
  final ThemeProvider themeProvider;

  const HomeScreen({super.key, required this.themeProvider});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  List<AppInfo> _apps = [];
  bool _loading = true;
  bool _isDefaultLauncher = false;
  bool _checkingLauncher = true;
  bool _userSkippedSetup = false;
  bool? _iconsEnabledSnapshot;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.themeProvider.addListener(_handleThemeProviderChange);
    _iconsEnabledSnapshot = widget.themeProvider.isIconsEnabled;
    _checkLauncherStatus();
    _loadApps();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.themeProvider.removeListener(_handleThemeProviderChange);
    super.dispose();
  }

  void _handleThemeProviderChange() {
    final iconsEnabled = widget.themeProvider.isIconsEnabled;
    if (_iconsEnabledSnapshot != iconsEnabled) {
      _iconsEnabledSnapshot = iconsEnabled;
      _loadApps();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLauncherStatus();
    }
  }

  Future<void> _checkLauncherStatus() async {
    setState(() {
      _checkingLauncher = true;
    });
    final isDefault = await LauncherService.isDefaultLauncher();
    setState(() {
      _isDefaultLauncher = isDefault;
      _checkingLauncher = false;
    });
  }

  Future<void> _loadApps() async {
    try {
      final apps = await InstalledApps.getInstalledApps(
        excludeSystemApps: false,
        withIcon: widget.themeProvider.isIconsEnabled,
      );
      apps.sort(
          (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      setState(() {
        _apps = apps;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingLauncher) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white54)),
      );
    }

    if (!_isDefaultLauncher && !_userSkippedSetup) {
      return _buildSetupScreen();
    }

    if (!widget.themeProvider.hasSeenWalkthrough) {
      return WalkthroughScreen(
        themeProvider: widget.themeProvider,
        onDone: () => setState(() {}),
      );
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: DigitalGrain(
          opacity: 0.08,
          child: SafeArea(
            child: ListenableBuilder(
              listenable: widget.themeProvider,
              builder: (context, _) {
                return GestureDetector(
                  onDoubleTap: () => LauncherService.lockScreen(),
                  behavior: HitTestBehavior.translucent,
                  child: Stack(
                    children: [
                      _buildCurrentStyle(),

                      // Top overlay for clock and settings
                      Positioned(
                      top: 16,
                      left: 24,
                      right: 24,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: GestureDetector(
                              onLongPress: () => widget.themeProvider.nextTheme(),
                              behavior: HitTestBehavior.opaque,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  MinimalClock(
                                    isTerminal:
                                        widget.themeProvider.currentTheme ==
                                            LauncherThemeType.terminal,
                                    isBauhaus:
                                        widget.themeProvider.currentTheme ==
                                            LauncherThemeType.bauhaus,
                                  ),
                                  if (widget.themeProvider.isStatusStripEnabled &&
                                      widget.themeProvider.currentTheme !=
                                          LauncherThemeType.terminal) ...[
                                    const SizedBox(height: 10),
                                    const StatusStrip(),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.help_outline,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                tooltip: 'How to use',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => WalkthroughScreen(
                                        themeProvider: widget.themeProvider,
                                        onDone: () => Navigator.of(context).pop(),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  Icons.settings_outlined,
                                  color: Colors.white.withValues(alpha: 0.5),
                                ),
                                tooltip: 'Settings',
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => SettingsScreen(
                                          themeProvider: widget.themeProvider),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    if (_loading)
                      const Center(
                        child:
                            CircularProgressIndicator(color: Colors.white54),
                      ),
                  ],
                ),
              );
            },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSetupScreen() {
    return Scaffold(
      backgroundColor: Colors.black,
      body: DigitalGrain(
        opacity: 0.08,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.phone_android, color: Colors.white,
                    size: 64),
                const SizedBox(height: 24),
                const Text(
                  'enable\nminimalist\nphone',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontWeight: FontWeight.w200,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'to transform your ui into a distraction-free experience, you need to set this app as your default launcher.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 48),
                InkWell(
                  onTap: () {
                    LauncherService.openLauncherSettings();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white54),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'turn on launcher',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _userSkippedSetup = true;
                    });
                  },
                  child: Text(
                    'skip for now',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Space the clock overlay (and, when enabled, the status strip beneath
  /// it) actually occupies, so per-theme content never collides with it.
  double _contentTopPadding() {
    const overlayTop = 16.0;
    final isBauhaus = widget.themeProvider.currentTheme == LauncherThemeType.bauhaus;
    final clockHeight = isBauhaus ? 70.0 : 130.0;
    final statusStripHeight = widget.themeProvider.isStatusStripEnabled &&
            widget.themeProvider.currentTheme != LauncherThemeType.terminal
        ? 30.0
        : 0.0;
    const bottomBuffer = 24.0;
    return overlayTop + clockHeight + statusStripHeight + bottomBuffer;
  }

  Widget _buildCurrentStyle() {
    if (_loading) return const SizedBox.shrink();

    switch (widget.themeProvider.currentTheme) {
      case LauncherThemeType.typography:
        return TypographyStyle(
          apps: _apps,
          themeProvider: widget.themeProvider,
          contentTopPadding: _contentTopPadding(),
        );
      case LauncherThemeType.bauhaus:
        return BauhausStyle(
          apps: _apps,
          themeProvider: widget.themeProvider,
          contentTopPadding: _contentTopPadding(),
        );
      case LauncherThemeType.terminal:
        return TerminalStyle(
            apps: _apps, themeProvider: widget.themeProvider);
    }
  }
}
