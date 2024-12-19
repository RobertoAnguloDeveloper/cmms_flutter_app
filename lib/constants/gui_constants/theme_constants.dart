import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_components.dart';
import 'app_spacing.dart';
import 'app_typography.dart';

class ThemeConstants {
  // Theme Mode
  static const defaultThemeMode = ThemeMode.light;

  // Animation Durations
  static const themeSwitchDuration = Duration(milliseconds: 300);

  // Light Theme Colors
  static final ColorScheme lightColorScheme = ColorScheme.light(
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    surface: AppColors.surfaceLight,
    error: AppColors.errorLight,
    onPrimary: AppColors.textDark,
    onSecondary: AppColors.textLight,
    onSurface: AppColors.textLight,
    onError: AppColors.textDark,
  );

  static const List<String> availableFontFamilies = [
    'Roboto',
    'Poppins',
    'NotoSans'
  ];

  // Dark Theme Colors
  static final ColorScheme darkColorScheme = ColorScheme.dark(
    primary: AppColors.primaryDark,
    secondary: AppColors.secondaryDark,
    surface: AppColors.surfaceDark,
    error: AppColors.errorDark,
    onPrimary: AppColors.textLight,
    onSecondary: AppColors.textDark,
    onSurface: AppColors.textDark,
    onError: AppColors.textLight,
  );

  // Default Shadow
  static const List<BoxShadow> defaultShadow = [
    BoxShadow(
      color: Colors.black12,
      offset: Offset(0, 2),
      blurRadius: 4,
    ),
  ];

  // Font Family
  static const String defaultFontFamily = 'Roboto';

  // Default Transitions
  static const defaultTransitionDuration = Duration(milliseconds: 200);
  static const defaultTransitionCurve = Curves.easeInOut;
}