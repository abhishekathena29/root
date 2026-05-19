import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'package:intl/intl.dart';

class MinimalClock extends StatefulWidget {
  final bool isTerminal;

  const MinimalClock({Key? key, this.isTerminal = false}) : super(key: key);

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
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
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
