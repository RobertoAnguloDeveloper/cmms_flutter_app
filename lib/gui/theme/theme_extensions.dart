import 'dart:ui';

import 'package:flutter/material.dart';
import '../../constants/gui_constants/app_colors.dart';
import '../../constants/gui_constants/app_spacing.dart';
import '../../constants/gui_constants/app_typography.dart';
import '../../constants/gui_constants/app_components.dart';

@immutable
class AppColorExtension extends ThemeExtension<AppColorExtension> {
  final Color primary;
  final Color secondary;
  final Color background;
  final Color surface;
  final Color error;
  final Color text;

  const AppColorExtension({
    required this.primary,
    required this.secondary,
    required this.background,
    required this.surface,
    required this.error,
    required this.text,
  });

  static const light = AppColorExtension(
    primary: AppColors.primaryLight,
    secondary: AppColors.secondaryLight,
    background: AppColors.backgroundLight,
    surface: AppColors.surfaceLight,
    error: AppColors.errorLight,
    text: AppColors.textLight,
  );

  static const dark = AppColorExtension(
    primary: AppColors.primaryDark,
    secondary: AppColors.secondaryDark,
    background: AppColors.backgroundDark,
    surface: AppColors.surfaceDark,
    error: AppColors.errorDark,
    text: AppColors.textDark,
  );

  @override
  ThemeExtension<AppColorExtension> copyWith({
    Color? primary,
    Color? secondary,
    Color? background,
    Color? surface,
    Color? error,
    Color? text,
  }) {
    return AppColorExtension(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      error: error ?? this.error,
      text: text ?? this.text,
    );
  }

  @override
  ThemeExtension<AppColorExtension> lerp(
      covariant ThemeExtension<AppColorExtension>? other,
      double t,
      ) {
    if (other is! AppColorExtension) {
      return this;
    }
    return AppColorExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      error: Color.lerp(error, other.error, t)!,
      text: Color.lerp(text, other.text, t)!,
    );
  }
}

@immutable
class AppSpacingExtension extends ThemeExtension<AppSpacingExtension> {
  final double xs;
  final double sm;
  final double md;
  final double lg;
  final double xl;

  const AppSpacingExtension({
    required this.xs,
    required this.sm,
    required this.md,
    required this.lg,
    required this.xl,
  });

  static const standard = AppSpacingExtension(
    xs: AppSpacing.xs,
    sm: AppSpacing.sm,
    md: AppSpacing.md,
    lg: AppSpacing.lg,
    xl: AppSpacing.xl,
  );

  @override
  ThemeExtension<AppSpacingExtension> copyWith({
    double? xs,
    double? sm,
    double? md,
    double? lg,
    double? xl,
  }) {
    return AppSpacingExtension(
      xs: xs ?? this.xs,
      sm: sm ?? this.sm,
      md: md ?? this.md,
      lg: lg ?? this.lg,
      xl: xl ?? this.xl,
    );
  }

  @override
  ThemeExtension<AppSpacingExtension> lerp(
      covariant ThemeExtension<AppSpacingExtension>? other,
      double t,
      ) {
    if (other is! AppSpacingExtension) {
      return this;
    }
    return AppSpacingExtension(
      xs: lerpDouble(xs, other.xs, t)!,
      sm: lerpDouble(sm, other.sm, t)!,
      md: lerpDouble(md, other.md, t)!,
      lg: lerpDouble(lg, other.lg, t)!,
      xl: lerpDouble(xl, other.xl, t)!,
    );
  }
}

@immutable
class AppTypographyExtension extends ThemeExtension<AppTypographyExtension> {
  final TextStyle h1;
  final TextStyle h2;
  final TextStyle h3;
  final TextStyle body;
  final TextStyle caption;

  const AppTypographyExtension({
    required this.h1,
    required this.h2,
    required this.h3,
    required this.body,
    required this.caption,
  });

  static const standard = AppTypographyExtension(
    h1: AppTypography.h1,
    h2: AppTypography.h2,
    h3: AppTypography.h3,
    body: AppTypography.body,
    caption: AppTypography.caption,
  );

  @override
  ThemeExtension<AppTypographyExtension> copyWith({
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? body,
    TextStyle? caption,
  }) {
    return AppTypographyExtension(
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      body: body ?? this.body,
      caption: caption ?? this.caption,
    );
  }

  @override
  ThemeExtension<AppTypographyExtension> lerp(
      covariant ThemeExtension<AppTypographyExtension>? other,
      double t,
      ) {
    if (other is! AppTypographyExtension) {
      return this;
    }
    return AppTypographyExtension(
      h1: TextStyle.lerp(h1, other.h1, t)!,
      h2: TextStyle.lerp(h2, other.h2, t)!,
      h3: TextStyle.lerp(h3, other.h3, t)!,
      body: TextStyle.lerp(body, other.body, t)!,
      caption: TextStyle.lerp(caption, other.caption, t)!,
    );
  }
}

@immutable
class AppComponentsExtension extends ThemeExtension<AppComponentsExtension> {
  final ButtonStyle primaryButton;
  final ButtonStyle secondaryButton;
  final CardTheme cardTheme;
  final InputDecorationTheme inputTheme;

  static WidgetStatePropertyAll<Color> _createColor(Color color) {
    return WidgetStatePropertyAll<Color>(color);
  }

  static WidgetStatePropertyAll<EdgeInsetsGeometry> _createEdgeInsets(EdgeInsetsGeometry edgeInsets) {
    return WidgetStatePropertyAll<EdgeInsetsGeometry>(edgeInsets);
  }

  static WidgetStatePropertyAll<OutlinedBorder> _createShape(OutlinedBorder shape) {
    return WidgetStatePropertyAll<OutlinedBorder>(shape);
  }

  const AppComponentsExtension({
    required this.primaryButton,
    required this.secondaryButton,
    required this.cardTheme,
    required this.inputTheme,
  });

  static final light = AppComponentsExtension(
    primaryButton: ButtonStyle(
      backgroundColor: _createColor(AppColors.primaryLight),
      foregroundColor: _createColor(AppColors.textDark),
      padding: _createEdgeInsets(AppComponents.buttonPadding),
      shape: _createShape(AppComponents.buttonShape),
    ),
    secondaryButton: ButtonStyle(
      backgroundColor: _createColor(Colors.transparent),
      foregroundColor: _createColor(AppColors.primaryLight),
      padding: _createEdgeInsets(AppComponents.buttonPadding),
      shape: _createShape(AppComponents.buttonShape),
    ),
    cardTheme: AppComponents.lightCardTheme,
    inputTheme: AppComponents.lightInputTheme,
  );

  static final dark = AppComponentsExtension(
    primaryButton: ButtonStyle(
      backgroundColor: _createColor(AppColors.primaryDark),
      foregroundColor: _createColor(AppColors.textLight),
      padding: _createEdgeInsets(AppComponents.buttonPadding),
      shape: _createShape(AppComponents.buttonShape),
    ),
    secondaryButton: ButtonStyle(
      backgroundColor: _createColor(Colors.transparent),
      foregroundColor: _createColor(AppColors.primaryDark),
      padding: _createEdgeInsets(AppComponents.buttonPadding),
      shape: _createShape(AppComponents.buttonShape),
    ),
    cardTheme: AppComponents.darkCardTheme,
    inputTheme: AppComponents.darkInputTheme,
  );

  @override
  ThemeExtension<AppComponentsExtension> copyWith({
    ButtonStyle? primaryButton,
    ButtonStyle? secondaryButton,
    CardTheme? cardTheme,
    InputDecorationTheme? inputTheme,
  }) {
    return AppComponentsExtension(
      primaryButton: primaryButton ?? this.primaryButton,
      secondaryButton: secondaryButton ?? this.secondaryButton,
      cardTheme: cardTheme ?? this.cardTheme,
      inputTheme: inputTheme ?? this.inputTheme,
    );
  }

  @override
  ThemeExtension<AppComponentsExtension> lerp(
      covariant ThemeExtension<AppComponentsExtension>? other,
      double t,
      ) {
    if (other is! AppComponentsExtension) {
      return this;
    }
    return this;
  }
}