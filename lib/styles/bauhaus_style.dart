
import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'package:installed_apps/app_info.dart';


import '../providers/theme_provider.dart';
import '../utils/app_launcher.dart';

class BauhausStyle extends StatelessWidget {
  final List<AppInfo> apps;
  final ThemeProvider themeProvider;

  const BauhausStyle({Key? key, required this.apps, required this.themeProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF222222), // Soft charcoal
      child: GridView.builder(
        padding: const EdgeInsets.fromLTRB(24.0, 140.0, 24.0, 24.0),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 64.0,
          crossAxisSpacing: 48.0,
        ),
        itemCount: apps.length,
        itemBuilder: (context, index) {
          final app = apps[index];
          return InkWell(
            onTap: () => AppLauncher.launch(context, app, themeProvider),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Center(
                    child: _buildGeometricShape(app.packageName),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildGeometricShape(String identifier) {
    final hash = identifier.hashCode;
    final shapeType = hash % 4; // 0: Circle, 1: Square, 2: Triangle, 3: Line

    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    return CustomPaint(
      size: const Size(40, 40),
      painter: _ShapePainter(shapeType, paint),
    );
  }
}

class _ShapePainter extends CustomPainter {
  final int shapeType;
  final Paint shapePaint;

  _ShapePainter(this.shapeType, this.shapePaint);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    switch (shapeType) {
      case 0:
        // Circle
        canvas.drawCircle(center, size.width / 2, shapePaint);
        break;
      case 1:
        // Square
        canvas.drawRect(Rect.fromCenter(center: center, width: size.width, height: size.height), shapePaint);
        break;
      case 2:
        // Triangle
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height)
          ..lineTo(0, size.height)
          ..close();
        canvas.drawPath(path, shapePaint);
        break;
      case 3:
        // Diamond
        final path = Path()
          ..moveTo(size.width / 2, 0)
          ..lineTo(size.width, size.height / 2)
          ..lineTo(size.width / 2, size.height)
          ..lineTo(0, size.height / 2)
          ..close();
        canvas.drawPath(path, shapePaint);
        break;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
