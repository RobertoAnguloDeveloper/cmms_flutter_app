// 📂 lib/gui/theme/env_theme_provider.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_services/cmms_config_provider.dart';
import '../../services/api_services/auth_provider.dart';
import '../../models/environment.dart';
import '../../models/cmms_config.dart';
import '../../configs/api_config.dart';
import 'config_theme_extension.dart';

class EnvThemeProvider with ChangeNotifier {
  final CmmsConfigProvider _configProvider;
  late BuildContext _context;
  ThemeMode _themeMode;
  CmmsConfig? _themeConfig;
  bool _isLoading = false;
  String? _error;

  EnvThemeProvider()
      : _configProvider = CmmsConfigProvider(),
        _themeMode = ThemeMode.light;

  void updateContext(BuildContext context) {
    _context = context;
  }

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Color _colorFromHex(String hexString) {
    final hex = hexString.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Future<void> loadThemeForCurrentUser() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Get the current user's environment from AuthProvider
      final authProvider = Provider.of<AuthProvider>(_context, listen: false);
      final currentUser = authProvider.currentUser;

      if (currentUser?.environment != null) {
        final environmentId = currentUser!.environment!.id;

        try {
          await _configProvider.loadConfig('env_theme_$environmentId.json');
          _themeConfig = _configProvider.currentConfig;
          _error = null;
        } catch (e) {
          print('Theme config not found for environment $environmentId, using defaults');
          _themeConfig = null;
        }
      }
    } catch (e) {
      _error = e.toString();
      _themeConfig = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ThemeData get currentTheme {
    // If we have a theme config, use it
    if (_themeConfig != null && _themeConfig!.content.containsKey('parameters')) {
      final parameters = _themeConfig!.content['parameters'] as Map<String, dynamic>;
      if (parameters.containsKey('theme_settings')) {
        final themeSettings = parameters['theme_settings'] as Map<String, dynamic>;

        return ThemeData(
          primaryColor: _colorFromHex(themeSettings['primary_color']),
          colorScheme: ColorScheme(
            brightness: _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
            primary: _colorFromHex(themeSettings['primary_color']),
            secondary: _colorFromHex(themeSettings['secondary_color']),
            surface: _colorFromHex(themeSettings['background_color']),
            onPrimary: _getContrastColor(_colorFromHex(themeSettings['primary_color'])),
            onSecondary: _getContrastColor(_colorFromHex(themeSettings['secondary_color'])),
            onSurface: _colorFromHex(themeSettings['text_color']),
            error: _themeMode == ThemeMode.dark ? Colors.red.shade300 : Colors.red.shade700,
            onError: Colors.white,
          ),
          scaffoldBackgroundColor: _colorFromHex(themeSettings['background_color']),
          textTheme: (_themeMode == ThemeMode.dark ? ThemeData.dark() : ThemeData.light())
              .textTheme
              .apply(
            fontFamily: themeSettings['font_family'],
            bodyColor: _colorFromHex(themeSettings['text_color']),
            displayColor: _colorFromHex(themeSettings['text_color']),
            fontSizeFactor: themeSettings['font_size_scale'],
          ),
          fontFamily: themeSettings['font_family'],
          useMaterial3: true,
        );
      }
    }

    // Otherwise return default theme
    return ConfigThemeExtension.getDefaultTheme(
      isDark: _themeMode == ThemeMode.dark,
    );
  }

  Color _getContrastColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.light
        ? Colors.black
        : Colors.white;
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}