import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class DigitalGrain extends StatelessWidget {
  final Widget child;
  final double opacity;

  const DigitalGrain({Key? key, required this.child, this.opacity = 0.05}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity,
              child: CustomPaint(
                painter: GrainPainter(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class GrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    final random = Random(42); // Static seed so it doesn't animate/flicker and kill performance
    final width = size.width.toInt();
    final height = size.height.toInt();

    // Draw random points
    // To avoid massive performance hits, we only draw a fraction of points
    final int pointsCount = (width * height * 0.1).toInt(); 
    final points = <Offset>[];
    for (int i = 0; i < pointsCount; i++) {
      points.add(Offset(
        random.nextInt(width).toDouble(),
        random.nextInt(height).toDouble(),
      ));
    }
    
    // drawPoints is more efficient than individual drawRects
    canvas.drawPoints(PointMode.points, points, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
