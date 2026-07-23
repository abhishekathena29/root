import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'package:intl/intl.dart';

class MinimalClock extends StatefulWidget {
  final bool isTerminal;
  final bool isBauhaus;

  const MinimalClock({
    super.key,
    this.isTerminal = false,
    this.isBauhaus = false,
  });

  @override
  State<MinimalClock> createState() => _MinimalClockState();
}

class _MinimalClockState extends State<MinimalClock> {
  late String _timeString;
  late String _dateString;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer t) => _updateTime(),
    );
  }

  void _updateTime() {
    final now = DateTime.now();
    setState(() {
      _timeString = DateFormat('HH:mm').format(now);
      _dateString = DateFormat('EEEE, MMMM d').format(now).toLowerCase();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isTerminal) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '[SYS] TIME: $_timeString',
            style: AppFonts.jetBrainsMono(
              color: Colors.green.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          Text(
            '[SYS] DATE: $_dateString',
            style: AppFonts.jetBrainsMono(
              color: Colors.green.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      );
    }

    if (widget.isBauhaus) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 3,
            height: 46,
            color: const Color(0xFFE9B44C).withValues(alpha: 0.85),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _timeString,
                style: AppFonts.outfit(
                  fontSize: 48,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withValues(alpha: 0.95),
                  letterSpacing: -1,
                ),
              ),
              Text(
                _dateString,
                style: AppFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: Colors.white.withValues(alpha: 0.55),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _timeString,
          style: AppFonts.inter(
            fontSize: 72,
            fontWeight: FontWeight.w200,
            color: Colors.white.withValues(alpha: 0.9),
            letterSpacing: -2,
          ),
        ),
        Text(
          _dateString,
          style: AppFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w300,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }
}
