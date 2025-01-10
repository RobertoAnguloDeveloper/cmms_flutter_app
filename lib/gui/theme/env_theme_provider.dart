// 📂 lib/gui/theme/env_theme_provider.dart

import 'package:flutter/material.dart';
import '../../services/api_services/api_client.dart';
import '../../services/api_services/cmms_config_provider.dart';
import '../../models/cmms_config.dart';
import 'config_theme_extension.dart';

class EnvThemeProvider with ChangeNotifier {
  final CmmsConfigProvider _configProvider;
  final ApiClient _apiClient;
  ThemeMode _themeMode;
  CmmsConfig? _themeConfig;
  bool _isLoading = false;
  String? _error;
  ThemeData? _currentTheme;

  EnvThemeProvider({required ApiClient apiClient})
      : _apiClient = apiClient,
        _configProvider = CmmsConfigProvider(apiClient: apiClient),
        _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Color _colorFromHex(String hexString) {
    final hex = hexString.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  Future<void> loadDefaultTheme() async {
    if (_isLoading) return;

    try {
      _isLoading = true;

      try {
        await _configProvider.loadConfig('config.json');
        _themeConfig = _configProvider.currentConfig;

        if (_themeConfig?.content['environments'] != null) {
          final environments = _themeConfig!.content['environments'] as List;
          if (environments.isNotEmpty) {
            final defaultTheme = environments[0]['parameters']['theme_settings'];
            _applyThemeWithoutNotification(defaultTheme);
          }
        }
      } catch (e) {
        print('Error loading config: $e');
        _useDefaultTheme();
      }
    } catch (e) {
      print('Error in loadDefaultTheme: $e');
      _useDefaultTheme();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadThemeForCurrentUser() async {
    if (_isLoading) return;

    try {
      _isLoading = true;

      // Load config.json
      await _configProvider.loadConfig('config.json');
      _themeConfig = _configProvider.currentConfig;

      if (_themeConfig?.content['environments'] != null) {
        final environments = _themeConfig!.content['environments'] as List;

        // Get current user environment
        final response = await _apiClient.get('/api/users/current');
        final userData = response.data;
        final environmentId = userData['environment']['id'] as int;

        print('Loading theme for environment ID: $environmentId');

        final envConfig = environments.firstWhere(
              (env) => env['parameters']['environment_id'] == environmentId,
          orElse: () => environments[0],
        );

        if (envConfig['parameters'] != null &&
            envConfig['parameters']['theme_settings'] != null) {
          print('Applying theme settings for environment: ${envConfig['parameters']['environment_name']}');
          _applyThemeWithoutNotification(envConfig['parameters']['theme_settings']);
          _error = null;
        }
      }
    } catch (e) {
      print('Error in loadThemeForCurrentUser: $e');
      _error = e.toString();
      _useDefaultTheme();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _applyThemeWithoutNotification(Map<String, dynamic> themeSettings) {
    try {
      print('Applying theme settings: $themeSettings');
      _currentTheme = _createThemeData(themeSettings);
      print('Theme applied successfully');
    } catch (e) {
      print('Error applying theme: $e');
      _useDefaultTheme();
    }
  }

  ThemeData _createThemeData(Map<String, dynamic> themeSettings) {
    final double fontSizeScale = themeSettings['font_size_scale'] is int ?
    (themeSettings['font_size_scale'] as int).toDouble() :
    (themeSettings['font_size_scale'] as double?) ?? 1.0;
    return ThemeData(
      primaryColor: _colorFromHex(themeSettings['primary_color']),
      colorScheme: ColorScheme(
        brightness: _themeMode == ThemeMode.dark ? Brightness.dark : Brightness.light,
        primary: _colorFromHex(themeSettings['primary_color']),
        secondary: _colorFromHex(themeSettings['secondary_color']),
        surface: _colorFromHex(themeSettings['background_color']),
        background: _colorFromHex(themeSettings['background_color']),
        onPrimary: _getContrastColor(_colorFromHex(themeSettings['primary_color'])),
        onSecondary: _getContrastColor(_colorFromHex(themeSettings['secondary_color'])),
        onSurface: _colorFromHex(themeSettings['text_color']),
        onBackground: _colorFromHex(themeSettings['text_color']),
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
        fontSizeFactor: fontSizeScale,
      ),
      fontFamily: themeSettings['font_family'],
      useMaterial3: true,

      appBarTheme: AppBarTheme(
        backgroundColor: _colorFromHex(themeSettings['primary_color']),
        foregroundColor: _getContrastColor(_colorFromHex(themeSettings['primary_color'])),
        elevation: 0,
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _colorFromHex(themeSettings['primary_color']),
          foregroundColor: _getContrastColor(_colorFromHex(themeSettings['primary_color'])),
        ),
      ),

      cardTheme: CardTheme(
        color: _colorFromHex(themeSettings['background_color']),
        elevation: 2,
      ),

      iconTheme: IconThemeData(
        color: _colorFromHex(themeSettings['primary_color']),
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: _colorFromHex(themeSettings['primary_color']),
        foregroundColor: _getContrastColor(_colorFromHex(themeSettings['primary_color'])),
      ),
    );
  }

  ThemeData get currentTheme {
    print('Getting current theme: ${_currentTheme != null ? "Custom" : "Default"}');
    if (_currentTheme != null) {
      return _currentTheme!;
    }
    return _useDefaultTheme();
  }

  ThemeData _useDefaultTheme() {
    try {
      _currentTheme = ThemeData(
        primaryColor: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: Colors.blue,
          secondary: Colors.blueAccent,
          background: Colors.white,
          surface: Colors.white,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onBackground: Colors.black,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Roboto',
        useMaterial3: true,
      );
      return _currentTheme!;
    } catch (e) {
      print('Error applying default theme: $e');
      return ThemeData.light();
    }
  }

  Color _getContrastColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.light
        ? Colors.black
        : Colors.white;
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    if (_themeConfig != null) {
      loadThemeForCurrentUser();
    } else {
      _useDefaultTheme();
      notifyListeners();
    }
  }

  void toggleThemeMode() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    if (_themeConfig != null) {
      loadThemeForCurrentUser();
    } else {
      _useDefaultTheme();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void resetTheme() {
    _currentTheme = null;
    _themeConfig = null;
    _useDefaultTheme();
    notifyListeners();
  }
}