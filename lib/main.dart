// 📂 lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gui/theme/app_theme_provider.dart';
import 'gui/screens/ui_config/ui_config_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AppThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'Theme Demo',
          theme: themeProvider.currentTheme,
          themeMode: themeProvider.themeMode,
          home: UIConfigScreen(
            themeMode: themeProvider.themeMode,
            onThemeChanged: (isDark) {
              themeProvider.setThemeMode(
                isDark ? ThemeMode.dark : ThemeMode.light,
              );
            },
          ),
        );
      },
    );
  }
}