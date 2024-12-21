// 📂 lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'gui/components/splash_screen.dart';
import 'gui/screens/home_screen.dart';
import 'gui/theme/app_theme_provider.dart';
import 'gui/screens/auth/login_screen.dart';
import 'services/api_services/auth_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: Consumer<AppThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'CMMS App',
            theme: themeProvider.currentTheme,
            home: const AppFlow(),
          );
        },
      ),
    );
  }
}

class AppFlow extends StatelessWidget {
  const AppFlow({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        return SplashScreen(
          onInit: () async {
            // Initialize any required services or data
            await Future.delayed(const Duration(seconds: 2));
            // Check if user is already logged in
            await authProvider.checkAuthStatus();
          },
          onInitComplete: () {
            // Navigate to appropriate screen based on auth status
            if (authProvider.isAuthenticated) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            } else {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            }
          },
        );
      },
    );
  }
}