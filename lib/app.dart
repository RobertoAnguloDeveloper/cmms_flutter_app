// 📂 lib/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'configs/api_config.dart';
import 'gui/components/splash_screen.dart';
import 'gui/screens/home_screen.dart';
import 'gui/theme/env_theme_provider.dart';
import 'gui/screens/auth/login_screen.dart';
import 'gui/theme/app_theme_provider.dart';
import 'services/api_services/api_client.dart';
import 'services/api_services/auth_provider.dart';
import 'services/api_services/cmms_config_provider.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Create global navigator key for handling navigation from anywhere
    final navigatorKey = GlobalKey<NavigatorState>();

    // Initialize API client
    final apiClient = ApiClient(baseUrl: ApiConfig.baseUrl);

    return MultiProvider(
      providers: [
        // Theme providers
        ChangeNotifierProvider(
          create: (_) => EnvThemeProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => AppThemeProvider(),
        ),

        // Auth provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider(navigatorKey: navigatorKey),
        ),

        // Config provider
        ChangeNotifierProvider(
          create: (_) => CmmsConfigProvider(apiClient: apiClient),
        ),
      ],
      child: AppView(navigatorKey: navigatorKey),
    );
  }
}

class AppView extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const AppView({
    super.key,
    required this.navigatorKey,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<EnvThemeProvider, AuthProvider>(
      builder: (context, themeProvider, authProvider, _) {
        return MaterialApp(
          // Navigation
          navigatorKey: navigatorKey,

          // App information
          title: 'CMMS App',
          debugShowCheckedModeBanner: false,

          // Theme configuration
          theme: themeProvider.currentTheme,
          themeMode: themeProvider.themeMode,

          // Error handling
          builder: (context, child) {
            return ScrollConfiguration(
              behavior: const ScrollBehavior().copyWith(
                physics: const BouncingScrollPhysics(),
              ),
              child: child!,
            );
          },

          // Initial route handling
          home: const AuthenticationFlow(),
        );
      },
    );
  }
}

class AuthenticationFlow extends StatefulWidget {
  const AuthenticationFlow({Key? key}) : super(key: key);

  @override
  State<AuthenticationFlow> createState() => _AuthenticationFlowState();
}

class _AuthenticationFlowState extends State<AuthenticationFlow> {
  late final EnvThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    final themeProvider = Provider.of<EnvThemeProvider>(context, listen: false);
    // Load default theme after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      themeProvider.loadDefaultTheme();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, EnvThemeProvider>(
      builder: (context, authProvider, themeProvider, _) {
        return SplashScreen(
          onInit: () async {
            // Add delay for splash screen visibility
            await Future.delayed(const Duration(seconds: 2));

            // Check authentication status
            await authProvider.checkAuthStatus();

            // Only load theme if authenticated
            if (authProvider.isAuthenticated) {
              await themeProvider.loadThemeForCurrentUser();
            }
          },
          onInitComplete: () {
            // Navigate based on authentication status
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
          loadingText: 'Loading application...',
        );
      },
    );
  }
}

/// Extension for global theme access
extension AppTheme on BuildContext {
  ThemeData get theme => Theme.of(this);
}

/// Extension for checking screen sizes
extension ScreenSize on BuildContext {
  Size get screenSize => MediaQuery.of(this).size;
  bool get isSmallScreen => screenSize.width < 600;
  bool get isMediumScreen => screenSize.width >= 600 && screenSize.width < 1200;
  bool get isLargeScreen => screenSize.width >= 1200;
}

/// Extension for responsive padding
extension ResponsivePadding on BuildContext {
  EdgeInsets get screenPadding {
    if (isLargeScreen) {
      return const EdgeInsets.all(32.0);
    } else if (isMediumScreen) {
      return const EdgeInsets.all(24.0);
    } else {
      return const EdgeInsets.all(16.0);
    }
  }
}

/// Extension for easy access to providers
extension AppProviders on BuildContext {
  AuthProvider get authProvider => read<AuthProvider>();
  EnvThemeProvider get themeProvider => read<EnvThemeProvider>();
  AppThemeProvider get appThemeProvider => read<AppThemeProvider>();
}

/// Extension for snackbar display
extension SnackBarHelper on BuildContext {
  void showErrorSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(this).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}