import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'package:installed_apps/app_info.dart';

import '../providers/theme_provider.dart';
import '../utils/app_launcher.dart';
import '../widgets/alphabet_rail.dart';
import '../widgets/tap_scale_tile.dart';

const double _kRowExtent = 56.0;
const double _kSearchListGap = 64.0;

class TypographyStyle extends StatefulWidget {
  final List<AppInfo> apps;
  final ThemeProvider themeProvider;
  final double contentTopPadding;

  const TypographyStyle({
    super.key,
    required this.apps,
    required this.themeProvider,
    required this.contentTopPadding,
  });

  @override
  State<TypographyStyle> createState() => _TypographyStyleState();
}

class _TypographyStyleState extends State<TypographyStyle> {
  final PageController _pageController = PageController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  int _page = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _page) setState(() => _page = page);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<AppInfo> get _pinnedApps {
    final byPackage = {for (final a in widget.apps) a.packageName: a};
    return widget.themeProvider.pinnedApps
        .map((pkg) => byPackage[pkg])
        .whereType<AppInfo>()
        .toList();
  }

  List<AppInfo> get _filteredApps {
    if (_query.isEmpty) return widget.apps;
    final q = _query.toLowerCase();
    return widget.apps.where((a) => a.name.toLowerCase().contains(q)).toList();
  }

  void _jumpToLetter(String letter) {
    if (_query.isNotEmpty || !_scrollController.hasClients) return;
    final list = _filteredApps;
    final index = letter == '#'
        ? list.indexWhere((a) => !RegExp(r'^[a-zA-Z]').hasMatch(a.name))
        : list.indexWhere((a) => a.name.toLowerCase().startsWith(letter));
    if (index == -1) return;
    final target = (index * _kRowExtent)
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  Widget _buildFavoritesPage() {
    final pinned = _pinnedApps;

    return Padding(
      padding: EdgeInsets.only(top: widget.contentTopPadding),
      child: Center(
        child: pinned.isEmpty
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'long-press an app on "all apps" to pin it here for quick access, then drag to arrange',
                  textAlign: TextAlign.center,
                  style: AppFonts.inter(
                    color: Colors.white.withValues(alpha: 0.35),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              )
            : ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorderItem: widget.themeProvider.reorderPinned,
                children: [for (final app in pinned) _buildFavoriteRow(app)],
              ),
      ),
    );
  }

  Widget _buildFavoriteRow(AppInfo app) {
    return Padding(
      key: ValueKey(app.packageName),
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => AppLauncher.launch(context, app, widget.themeProvider),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  app.name.toLowerCase(),
                  style: AppFonts.inter(
                    fontSize: 22,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 10),
                InkWell(
                  onTap: () => widget.themeProvider.togglePinned(app.packageName),
                  child: Icon(Icons.close,
                      size: 14, color: Colors.white.withValues(alpha: 0.25)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAllAppsRow(AppInfo app) {
    final isPinned = widget.themeProvider.isPinned(app.packageName);
    return TapScaleTile(
      onTap: () => AppLauncher.launch(context, app, widget.themeProvider),
      onLongPress: () => widget.themeProvider.togglePinned(app.packageName),
      child: SizedBox(
        height: _kRowExtent,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.themeProvider.isIconsEnabled && app.icon != null) ...[
                _GrayscaleIcon(bytes: app.icon!, size: 20),
                const SizedBox(width: 12),
              ],
              Text(
                app.name.toLowerCase(),
                style: AppFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              if (isPinned) ...[
                const SizedBox(width: 8),
                Icon(Icons.circle,
                    size: 4, color: Colors.white.withValues(alpha: 0.5)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final searchTop = widget.contentTopPadding;
    final listTop = widget.contentTopPadding + _kSearchListGap;

    return Stack(
      children: [
        PageView(
          controller: _pageController,
          children: [
            _buildFavoritesPage(),
            // All apps: searchable, alphabet-indexed list
            Stack(
              children: [
                ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.fromLTRB(32.0, listTop, 48.0, 32.0),
                  itemExtent: _kRowExtent,
                  itemCount: _filteredApps.length,
                  itemBuilder: (context, index) => _buildAllAppsRow(_filteredApps[index]),
                ),
                if (_query.isEmpty)
                  Positioned(
                    top: listTop,
                    bottom: 24,
                    right: 8,
                    child: AlphabetRail(onLetterSelected: _jumpToLetter),
                  ),
                Positioned(
                  top: searchTop,
                  left: 32,
                  right: 48,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    style: AppFonts.inter(color: Colors.white, fontSize: 16),
                    cursorColor: Colors.white.withValues(alpha: 0.6),
                    decoration: InputDecoration(
                      isDense: true,
                      hintText: 'search',
                      hintStyle: AppFonts.inter(
                          color: Colors.white.withValues(alpha: 0.3), fontSize: 16),
                      enabledBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white.withValues(alpha: 0.15)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.white.withValues(alpha: 0.4)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          bottom: 28,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(2, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: active ? 14 : 5,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: active ? 0.7 : 0.25),
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _GrayscaleIcon extends StatelessWidget {
  final Uint8List bytes;
  final double size;

  const _GrayscaleIcon({required this.bytes, required this.size});

  static const _grayscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
      child: Image.memory(bytes, width: size, height: size, fit: BoxFit.contain),
    );
  }
}
