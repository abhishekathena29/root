import 'package:flutter/material.dart';
import '../utils/app_fonts.dart';
import 'package:installed_apps/app_info.dart';


import '../providers/theme_provider.dart';
import '../utils/app_launcher.dart';

class TypographyStyle extends StatelessWidget {
  final List<AppInfo> apps;
  final ThemeProvider themeProvider;

  const TypographyStyle({Key? key, required this.apps, required this.themeProvider}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Only show a few apps on the home screen as favorites, or let the user scroll through all
    // To keep it minimal, let's show all but tightly packed or let them scroll.
    // The prompt says "4-6 words in a vertical list" for Home Screen, swipe left for full.
    // We'll implement a simple vertical scroll for all apps for now, as selecting favorites requires persistence.
    // We can simulate favorites by taking the first 6 apps.

    final favoriteApps = apps.take(6).toList();

    return PageView(
      children: [
        // Home Screen
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: favoriteApps.map((app) {
              return InkWell(
                onTap: () => AppLauncher.launch(context, app, themeProvider),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                  child: Text(
                    app.name.toLowerCase(),
                    style: AppFonts.inter(
                      fontSize: 22,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        // All Apps List
        ListView.builder(
          padding: const EdgeInsets.fromLTRB(32.0, 140.0, 32.0, 32.0),
          itemCount: apps.length,
          itemBuilder: (context, index) {
            final app = apps[index];
            return InkWell(
              onTap: () => AppLauncher.launch(context, app, themeProvider),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  app.name.toLowerCase(),
                  style: AppFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
