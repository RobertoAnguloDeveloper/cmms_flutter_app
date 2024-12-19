// 📂 lib/constants/gui_constants/app_components.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppComponents {
  // Common border radius value
  static final BorderRadius borderRadius = BorderRadius.circular(8);

  // Button Properties
  static final RoundedRectangleBorder buttonShape = RoundedRectangleBorder(
    borderRadius: borderRadius,
  );

  static const EdgeInsets buttonPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );

  static final ElevatedButtonThemeData lightButtonTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(AppColors.primaryLight),
      foregroundColor: WidgetStateProperty.all(AppColors.textDark),
      padding: WidgetStateProperty.all(buttonPadding),
      shape: WidgetStateProperty.all(buttonShape),
    ),
  );

  static final ElevatedButtonThemeData darkButtonTheme = ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(AppColors.primaryDark),
      foregroundColor: WidgetStateProperty.all(AppColors.textLight),
      padding: WidgetStateProperty.all(buttonPadding),
      shape: WidgetStateProperty.all(buttonShape),
    ),
  );

  // Card Properties
  static const double cardElevationLight = 2;
  static const double cardElevationDark = 4;
  static const EdgeInsets cardPadding = EdgeInsets.all(AppSpacing.md);
  static const EdgeInsets cardMargin = EdgeInsets.all(AppSpacing.sm);

  static final CardTheme lightCardTheme = CardTheme(
    elevation: cardElevationLight,
    margin: cardMargin,
    shape: buttonShape,
    color: AppColors.surfaceLight,
  );

  static final CardTheme darkCardTheme = CardTheme(
    elevation: cardElevationDark,
    margin: cardMargin,
    shape: buttonShape,
    color: AppColors.surfaceDark,
  );

  // Input Properties
  static final OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: borderRadius,
  );

  static const EdgeInsets inputPadding = EdgeInsets.symmetric(
    horizontal: AppSpacing.md,
    vertical: AppSpacing.sm,
  );

  static final InputDecorationTheme lightInputTheme = InputDecorationTheme(
    border: inputBorder,
    enabledBorder: inputBorder.copyWith(
      borderSide: BorderSide(color: AppColors.primaryLight),
    ),
    focusedBorder: inputBorder.copyWith(
      borderSide: BorderSide(color: AppColors.primaryLight, width: 2),
    ),
    contentPadding: inputPadding,
    fillColor: AppColors.surfaceLight,
    filled: true,
  );

  static final InputDecorationTheme darkInputTheme = InputDecorationTheme(
    border: inputBorder,
    enabledBorder: inputBorder.copyWith(
      borderSide: BorderSide(color: AppColors.primaryDark),
    ),
    focusedBorder: inputBorder.copyWith(
      borderSide: BorderSide(color: AppColors.primaryDark, width: 2),
    ),
    contentPadding: inputPadding,
    fillColor: AppColors.surfaceDark,
    filled: true,
  );
}