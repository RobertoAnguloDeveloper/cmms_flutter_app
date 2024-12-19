import 'package:flutter/material.dart';
import '../../constants/gui_constants/app_colors.dart';
import '../../constants/gui_constants/app_components.dart';
import '../../constants/gui_constants/app_spacing.dart';
import '../../constants/gui_constants/app_typography.dart';
import '../../constants/gui_constants/theme_constants.dart';

class ThemeConfig {
  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ThemeConstants.lightColorScheme,
    primaryColor: AppColors.primaryLight,
    scaffoldBackgroundColor: AppColors.backgroundLight,

    // Card Theme
    cardTheme: AppComponents.lightCardTheme.copyWith(
      margin: const EdgeInsets.all(AppSpacing.md),
      elevation: AppComponents.cardElevationLight,
    ),

    // Button Theme
    elevatedButtonTheme: AppComponents.lightButtonTheme,

    // Input Theme
    inputDecorationTheme: AppComponents.lightInputTheme,

    // Text Theme
    textTheme: TextTheme(
      headlineLarge: AppTypography.h1,
      headlineMedium: AppTypography.h2,
      headlineSmall: AppTypography.h3,
      bodyLarge: AppTypography.body,
      bodyMedium: AppTypography.body,
      bodySmall: AppTypography.caption,
    ),

    // General Theme Settings
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ThemeConstants.darkColorScheme,
    primaryColor: AppColors.primaryDark,
    scaffoldBackgroundColor: AppColors.backgroundDark,

    // Card Theme
    cardTheme: AppComponents.darkCardTheme.copyWith(
      margin: const EdgeInsets.all(AppSpacing.md),
      elevation: AppComponents.cardElevationDark,
    ),

    // Button Theme
    elevatedButtonTheme: AppComponents.darkButtonTheme,

    // Input Theme
    inputDecorationTheme: AppComponents.darkInputTheme,

    // Text Theme
    textTheme: TextTheme(
      headlineLarge: AppTypography.h1.copyWith(color: AppColors.textDark),
      headlineMedium: AppTypography.h2.copyWith(color: AppColors.textDark),
      headlineSmall: AppTypography.h3.copyWith(color: AppColors.textDark),
      bodyLarge: AppTypography.body.copyWith(color: AppColors.textDark),
      bodyMedium: AppTypography.body.copyWith(color: AppColors.textDark),
      bodySmall: AppTypography.caption.copyWith(color: AppColors.textDark),
    ),

    // General Theme Settings
    useMaterial3: true,
    visualDensity: VisualDensity.adaptivePlatformDensity,
  );

  // Animation duration for theme switching
  static const Duration themeAnimationDuration = ThemeConstants.themeSwitchDuration;

  // Default shadow configuration
  static const List<BoxShadow> defaultShadow = ThemeConstants.defaultShadow;

  // Default transitions
  static const Duration defaultTransitionDuration = ThemeConstants.defaultTransitionDuration;
  static const Curve defaultTransitionCurve = ThemeConstants.defaultTransitionCurve;
}