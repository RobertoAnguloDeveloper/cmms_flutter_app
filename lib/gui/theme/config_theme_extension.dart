// 📂 lib/gui/theme/config_theme_extension.dart

import 'package:flutter/material.dart';
import '../../models/cmms_config.dart';
import '../../constants/gui_constants/theme_constants.dart';

extension ConfigThemeExtension on ThemeData {
  static ThemeData fromConfig(CmmsConfig config, {required bool isDark}) {
    final themeData = config.content['theme'] as Map<String, dynamic>;

    // Parse colors from hex strings
    final primaryColor = Color(
      int.parse(themeData['primary_color'].substring(1), radix: 16) + 0xFF000000,
    );
    final secondaryColor = Color(
      int.parse(themeData['secondary_color'].substring(1), radix: 16) + 0xFF000000,
    );
    final backgroundColor = Color(
      int.parse(themeData['background_color'].substring(1), radix: 16) + 0xFF000000,
    );
    final textColor = Color(
      int.parse(themeData['text_color'].substring(1), radix: 16) + 0xFF000000,
    );

    final String fontFamily = themeData['font_family'] as String;
    final double fontSizeScale = themeData['font_size_scale'] as double;

    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: primaryColor,
      colorScheme: ColorScheme(
        brightness: isDark ? Brightness.dark : Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: backgroundColor,
        onPrimary: _getContrastColor(primaryColor),
        onSecondary: _getContrastColor(secondaryColor),
        onSurface: textColor,
        error: isDark ? Colors.red.shade300 : Colors.red.shade700,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundColor,
      textTheme: (isDark ? ThemeData.dark() : ThemeData.light()).textTheme.apply(
        fontFamily: fontFamily,
        bodyColor: textColor,
        displayColor: textColor,
        fontSizeFactor: fontSizeScale,
      ),
      fontFamily: fontFamily,
      useMaterial3: true,
    );
  }

  static Color _getContrastColor(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.light
        ? Colors.black
        : Colors.white;
  }

  static ThemeData getDefaultTheme({required bool isDark}) {
    return ThemeData(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primaryColor: isDark ? Colors.blue.shade300 : Colors.blue,
      useMaterial3: true,
      fontFamily: ThemeConstants.defaultFontFamily,
    );
  }
}