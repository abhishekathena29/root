import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import '../services/launcher_service.dart';

/// A single unobtrusive line of ambient status (battery, network, next
/// calendar event) for themes that don't already surface it (Terminal has
/// its own `sys` command). Purely informational, never interactive.
class StatusStrip extends StatefulWidget {
  final bool useMonoFont;

  const StatusStrip({super.key, this.useMonoFont = false});

  @override
  State<StatusStrip> createState() => _StatusStripState();
}

class _StatusStripState extends State<StatusStrip> {
  final Battery _battery = Battery();
  String _text = '';
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) => _refresh());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    int batteryLevel = -1;
    Map<String, dynamic> sysInfo = {};
    try {
      batteryLevel = await _battery.batteryLevel;
    } catch (_) {}
    try {
      sysInfo = await LauncherService.getSystemInfo();
    } catch (_) {}

    final networkType = sysInfo['networkType'] as String? ?? 'unknown';
    final nextEventTitle = sysInfo['nextEventTitle'] as String?;
    final nextEventTime = sysInfo['nextEventTime'] as String?;

    final parts = <String>[];
    if (batteryLevel >= 0) parts.add('$batteryLevel%');
    parts.add(networkType);
    if (nextEventTitle != null && nextEventTime != null) {
      parts.add('$nextEventTime · ${nextEventTitle.toLowerCase()}');
    }

    if (!mounted) return;
    setState(() => _text = parts.join('  ·  '));
  }

  @override
  Widget build(BuildContext context) {
    if (_text.isEmpty) return const SizedBox.shrink();
    return Text(
      _text,
      style: widget.useMonoFont
          ? AppFonts.jetBrainsMono(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.35),
            )
          : AppFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: Colors.white.withValues(alpha: 0.4),
              letterSpacing: 0.3,
            ),
    );
  }
}
