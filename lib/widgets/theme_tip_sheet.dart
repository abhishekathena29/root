import 'package:flutter/material.dart';
import '../providers/theme_provider.dart';
import '../utils/app_fonts.dart';
import '../utils/launcher_tips.dart';

/// Shows a short "how to use this theme" bottom sheet. Used the first time
/// a theme is selected in Settings, and reusable anytime after.
Future<void> showThemeTipSheet(BuildContext context, LauncherThemeType theme) {
  final tip = kThemeTips[theme]!;
  return showModalBottomSheet(
    context: context,
    backgroundColor: const Color(0xFF141414),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'how to use ${tip.title}',
              style: AppFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            for (final bullet in tip.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('·  ',
                        style: AppFonts.inter(
                            color: Colors.white.withValues(alpha: 0.5), fontSize: 14)),
                    Expanded(
                      child: Text(
                        bullet,
                        style: AppFonts.inter(
                          color: Colors.white.withValues(alpha: 0.75),
                          fontSize: 14,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('got it',
                    style: AppFonts.inter(color: Colors.white.withValues(alpha: 0.8))),
              ),
            ),
          ],
        ),
      );
    },
  );
}
