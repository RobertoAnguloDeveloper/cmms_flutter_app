// 📂 lib/gui/theme/app_theme_provider.dart

import 'package:flutter/material.dart';
import '../../constants/gui_constants/theme_constants.dart';
import '../configs/theme_config.dart';
import '../../constants/gui_constants/app_colors.dart';

class AppThemeProvider extends ChangeNotifier {
  // Theme mode state
  ThemeMode _themeMode = ThemeConstants.defaultThemeMode;

  // Font family state
  String _fontFamily = ThemeConstants.defaultFontFamily;

  // Color states for light theme
  Color _primaryColorLight = AppColors.primaryLight;
  Color _secondaryColorLight = AppColors.secondaryLight;
  Color _backgroundColorLight = AppColors.backgroundLight;
  Color _textColorLight = AppColors.textLight;

  // Color states for dark theme
  Color _primaryColorDark = AppColors.primaryDark;
  Color _secondaryColorDark = AppColors.secondaryDark;
  Color _backgroundColorDark = AppColors.backgroundDark;
  Color _textColorDark = AppColors.textDark;

  // Getters
  ThemeMode get themeMode => _themeMode;
  String get fontFamily => _fontFamily;
  Color get primaryColor => _themeMode == ThemeMode.dark ? _primaryColorDark : _primaryColorLight;
  Color get secondaryColor => _themeMode == ThemeMode.dark ? _secondaryColorDark : _secondaryColorLight;
  Color get backgroundColor => _themeMode == ThemeMode.dark ? _backgroundColorDark : _backgroundColorLight;
  Color get textColor => _themeMode == ThemeMode.dark ? _textColorDark : _textColorLight;

  // Setters
  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void setFontFamily(String fontFamily) {
    _fontFamily = fontFamily;
    notifyListeners();
  }

  void setPrimaryColor(Color color) {
    if (_themeMode == ThemeMode.dark) {
      _primaryColorDark = color;
    } else {
      _primaryColorLight = color;
    }
    notifyListeners();
  }

  void setSecondaryColor(Color color) {
    if (_themeMode == ThemeMode.dark) {
      _secondaryColorDark = color;
    } else {
      _secondaryColorLight = color;
    }
    notifyListeners();
  }

  void setBackgroundColor(Color color) {
    if (_themeMode == ThemeMode.dark) {
      _backgroundColorDark = color;
    } else {
      _backgroundColorLight = color;
    }
    notifyListeners();
  }

  void setTextColor(Color color) {
    if (_themeMode == ThemeMode.dark) {
      _textColorDark = color;
    } else {
      _textColorLight = color;
    }
    notifyListeners();
  }

  // Reset to defaults
  void resetToDefaults() {
    _primaryColorLight = AppColors.primaryLight;
    _secondaryColorLight = AppColors.secondaryLight;
    _backgroundColorLight = AppColors.backgroundLight;
    _textColorLight = AppColors.textLight;

    _primaryColorDark = AppColors.primaryDark;
    _secondaryColorDark = AppColors.secondaryDark;
    _backgroundColorDark = AppColors.backgroundDark;
    _textColorDark = AppColors.textDark;

    _fontFamily = ThemeConstants.defaultFontFamily;

    notifyListeners();
  }

  // Helper method for contrast
  Color _getContrastColor(Color backgroundColor) {
    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  // Current theme getter
  ThemeData get currentTheme {
    final isDark = _themeMode == ThemeMode.dark;
    final baseTheme = isDark ? ThemeConfig.darkTheme : ThemeConfig.lightTheme;

    return baseTheme.copyWith(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,

      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        onPrimary: _getContrastColor(primaryColor),
        onSecondary: _getContrastColor(secondaryColor),
        onSurface: textColor,
        error: isDark ? AppColors.errorDark : AppColors.errorLight,
        onError: Colors.white,
      ),

      textTheme: baseTheme.textTheme.apply(
        fontFamily: _fontFamily,
        bodyColor: textColor,
        displayColor: textColor,
      ),

      cardTheme: CardTheme(
        color: backgroundColor,
        shadowColor: textColor.withOpacity(0.2),
      ),

      appBarTheme: AppBarTheme(
        backgroundColor: primaryColor,
        foregroundColor: _getContrastColor(primaryColor),
        titleTextStyle: TextStyle(
          fontFamily: _fontFamily,
          color: _getContrastColor(primaryColor),
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: _getContrastColor(primaryColor),
          textStyle: TextStyle(fontFamily: _fontFamily),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: TextStyle(fontFamily: _fontFamily),
          side: BorderSide(color: secondaryColor),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: secondaryColor,
          textStyle: TextStyle(fontFamily: _fontFamily),
        ),
      ),
    );
  }

  // Persistence methods
  Future<void> saveThemePreferences() async {
    // TODO: Implement persistence using SharedPreferences
  }

  Future<void> loadThemePreferences() async {
    // TODO: Implement loading using SharedPreferences
  }
}