import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';

/// A thin A-Z index rail for fast-scrolling long alphabetical lists.
/// Tap or drag anywhere on it to jump straight to that letter.
class AlphabetRail extends StatefulWidget {
  final ValueChanged<String> onLetterSelected;

  const AlphabetRail({super.key, required this.onLetterSelected});

  static const letters = [
    '#', 'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
    'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z',
  ];

  @override
  State<AlphabetRail> createState() => _AlphabetRailState();
}

class _AlphabetRailState extends State<AlphabetRail> {
  int? _activeIndex;

  void _handleTouch(double localY, double height) {
    final index = (localY / height * AlphabetRail.letters.length)
        .floor()
        .clamp(0, AlphabetRail.letters.length - 1);
    if (index != _activeIndex) {
      setState(() => _activeIndex = index);
      widget.onLetterSelected(AlphabetRail.letters[index]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onVerticalDragStart: (d) =>
              _handleTouch(d.localPosition.dy, constraints.maxHeight),
          onVerticalDragUpdate: (d) =>
              _handleTouch(d.localPosition.dy, constraints.maxHeight),
          onVerticalDragEnd: (_) => setState(() => _activeIndex = null),
          onTapUp: (d) =>
              _handleTouch(d.localPosition.dy, constraints.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (var i = 0; i < AlphabetRail.letters.length; i++)
                Text(
                  AlphabetRail.letters[i],
                  style: AppFonts.inter(
                    fontSize: 9,
                    fontWeight:
                        _activeIndex == i ? FontWeight.w600 : FontWeight.w400,
                    color: Colors.white.withValues(
                        alpha: _activeIndex == i ? 0.9 : 0.35),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
