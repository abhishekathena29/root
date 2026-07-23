import 'package:flutter/material.dart';

/// Wraps any tile in a brief press-scale micro-interaction before firing
/// [onTap], so launching an app always has a moment of tactile feedback
/// instead of an instant, jarring cut to the Intent Wall / target app.
class TapScaleTile extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;

  const TapScaleTile({
    super.key,
    required this.child,
    required this.onTap,
    this.onLongPress,
    this.borderRadius,
  });

  @override
  State<TapScaleTile> createState() => _TapScaleTileState();
}

class _TapScaleTileState extends State<TapScaleTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 100),
    reverseDuration: const Duration(milliseconds: 150),
  );
  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.93)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleTap() async {
    await _controller.forward();
    await _controller.reverse();
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: widget.borderRadius,
      onTap: _handleTap,
      onLongPress: widget.onLongPress,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}
