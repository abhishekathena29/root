import 'dart:typed_data';

import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'package:installed_apps/app_info.dart';

import '../providers/theme_provider.dart';
import '../services/usage_tracker.dart';
import '../utils/app_launcher.dart';
import '../widgets/tap_scale_tile.dart';

/// Muted Bauhaus primaries, restrained for a dark canvas.
const List<Color> _kBauhausPalette = [
  Colors.white,
  Color(0xFFE0575B), // red
  Color(0xFF4C7A9E), // blue
  Color(0xFFE9B44C), // mustard
];

class BauhausStyle extends StatefulWidget {
  final List<AppInfo> apps;
  final ThemeProvider themeProvider;
  final double contentTopPadding;

  const BauhausStyle({
    super.key,
    required this.apps,
    required this.themeProvider,
    required this.contentTopPadding,
  });

  @override
  State<BauhausStyle> createState() => _BauhausStyleState();
}

class _BauhausStyleState extends State<BauhausStyle>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  @override
  void initState() {
    super.initState();
    UsageTracker.preload().then((_) {
      if (mounted) setState(() {});
    });
    _entrance.forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  (int, int) _shapeAndColorFor(AppInfo app) {
    final hash = app.packageName.hashCode.abs();
    return (hash % 4, (hash ~/ 4) % 4);
  }

  bool _filledFor(AppInfo app) {
    final hash = app.packageName.hashCode.abs();
    return (hash ~/ 16) % 3 == 0;
  }

  List<AppInfo> get _pinnedApps {
    final byPackage = {for (final a in widget.apps) a.packageName: a};
    return widget.themeProvider.pinnedApps
        .map((pkg) => byPackage[pkg])
        .whereType<AppInfo>()
        .toList();
  }

  Widget _buildShape(AppInfo app, double size) {
    final (shapeType, colorIndex) = _shapeAndColorFor(app);
    final color = _kBauhausPalette[colorIndex];
    final filled = _filledFor(app);
    return CustomPaint(
      size: Size(size, size),
      painter: _ShapePainter(shapeType, color, filled),
    );
  }

  Widget _buildDock() {
    final pinned = _pinnedApps;

    return SizedBox(
      height: 92,
      child: pinned.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'long-press a shape below to pin it to your quick-access dock, then drag to arrange',
                  textAlign: TextAlign.center,
                  style: AppFonts.outfit(
                      color: Colors.white.withValues(alpha: 0.3), fontSize: 11),
                ),
              ),
            )
          : ReorderableListView(
              scrollDirection: Axis.horizontal,
              onReorderItem: widget.themeProvider.reorderPinned,
              children: [for (final app in pinned) _buildDockTile(app)],
            ),
    );
  }

  Widget _buildDockTile(AppInfo app) {
    return Padding(
      key: ValueKey(app.packageName),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: InkWell(
        onTap: () => AppLauncher.launch(context, app, widget.themeProvider),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                _buildShape(app, 36),
                Positioned(
                  top: -6,
                  right: -6,
                  child: InkWell(
                    onTap: () => widget.themeProvider.togglePinned(app.packageName),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Icon(Icons.close,
                          size: 10, color: Colors.white.withValues(alpha: 0.6)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 56,
              child: Text(
                app.name.toLowerCase(),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppFonts.outfit(
                  fontSize: 9,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF222222), // Soft charcoal
      child: Column(
        children: [
          SizedBox(height: widget.contentTopPadding),
          _buildDock(),
          const SizedBox(height: 8),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 24.0),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.themeProvider.bauhausColumns,
                mainAxisSpacing: 64.0,
                crossAxisSpacing: 48.0,
              ),
              itemCount: widget.apps.length,
              itemBuilder: (context, index) {
                final app = widget.apps[index];
                final total = widget.apps.length;
                final start =
                    total == 0 ? 0.0 : (index / total * 0.6).clamp(0.0, 1.0);
                final end = (start + 0.4).clamp(0.0, 1.0);
                final curved = CurvedAnimation(
                  parent: _entrance,
                  curve: Interval(start, end, curve: Curves.easeOut),
                );

                final usage = UsageTracker.countOf(app.packageName);
                final size = 40.0 + (usage.clamp(0, 4) * 4.0);
                final isPinned = widget.themeProvider.isPinned(app.packageName);

                return AnimatedBuilder(
                  animation: curved,
                  builder: (context, child) => Opacity(
                    opacity: curved.value,
                    child: Transform.scale(
                        scale: 0.85 + 0.15 * curved.value, child: child),
                  ),
                  child: TapScaleTile(
                    onTap: () => AppLauncher.launch(context, app, widget.themeProvider),
                    onLongPress: () => widget.themeProvider.togglePinned(app.packageName),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  _buildShape(app, size),
                                  if (widget.themeProvider.isIconsEnabled &&
                                      app.icon != null)
                                    _GrayscaleIcon(bytes: app.icon!, size: 22),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                app.name.toLowerCase(),
                                style: AppFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (isPinned) ...[
                              const SizedBox(width: 4),
                              Icon(Icons.circle,
                                  size: 3, color: Colors.white.withValues(alpha: 0.5)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final int shapeType;
  final Color color;
  final bool filled;

  _ShapePainter(this.shapeType, this.color, this.filled);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = filled ? color.withValues(alpha: 0.85) : color.withValues(alpha: 0.9)
      ..style = filled ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);

    switch (shapeType) {
      case 0:
        canvas.drawCircle(center, size.width / 2, paint);
        break;
      case 1:
        canvas.drawRect(
            Rect.fromCenter(center: center, width: size.width, height: size.height), paint);
        break;
      case 2:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, paint);
        break;
      case 3:
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();
        canvas.drawPath(path, paint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) =>
      oldDelegate.shapeType != shapeType ||
      oldDelegate.color != color ||
      oldDelegate.filled != filled;
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
