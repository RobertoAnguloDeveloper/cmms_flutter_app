// 📂 lib/gui/components/custom_button.dart

import 'package:flutter/material.dart';
import '../../constants/gui_constants/app_spacing.dart';

enum ButtonVariant {
  primary,
  secondary,
  outline,
  text,
  danger,
  upload,
  reload
}

enum ButtonSize {
  smallest,
  small,
  medium,
  large
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool isLoading;
  final Widget? icon;
  final bool disabled;
  final bool fullWidth;

  const CustomButton({
    super.key,
    this.text = "",
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.icon,
    this.disabled = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Define size-based padding
    EdgeInsets getPadding() {
      switch (size) {
        case ButtonSize.smallest:
          return const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.xxs,
          );
        case ButtonSize.small:
          return const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          );
        case ButtonSize.large:
          return const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          );
        default:
          return const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          );
      }
    }

    // Define variant-based styling
    ButtonStyle getStyle() {
      switch (variant) {
        case ButtonVariant.secondary:
          return ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
          );
        case ButtonVariant.outline:
          return OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          );
        case ButtonVariant.danger:
          return ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          );
        case ButtonVariant.upload:
          return ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          );
        case ButtonVariant.reload:
          return ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          );
        case ButtonVariant.text:
          return TextButton.styleFrom(
            foregroundColor: theme.colorScheme.primary,
          );
        default:
          return ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          );
      }
    }

    // Build button content
    Widget buildContent() {
      if (isLoading) {
        return SizedBox(
          height: size == ButtonSize.small ? 16 : 20,
          width: size == ButtonSize.small ? 16 : 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              variant == ButtonVariant.outline || variant == ButtonVariant.text
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onPrimary,
            ),
          ),
        );
      }

      List<Widget> children = [];

      if (icon != null) {
        children.add(icon!);
        children.add(const SizedBox(width: AppSpacing.sm));
      }

      children.add(Text(text));

      return Row(
        mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      );
    }

    // Build button based on variant
    Widget buildButton() {
      final buttonStyle = getStyle().copyWith(
        padding: MaterialStatePropertyAll(getPadding()),
      );

      switch (variant) {
        case ButtonVariant.outline:
          return OutlinedButton(
            onPressed: disabled || isLoading ? null : onPressed,
            style: buttonStyle,
            child: buildContent(),
          );
        case ButtonVariant.text:
          return TextButton(
            onPressed: disabled || isLoading ? null : onPressed,
            style: buttonStyle,
            child: buildContent(),
          );
        default:
          return ElevatedButton(
            onPressed: disabled || isLoading ? null : onPressed,
            style: buttonStyle,
            child: buildContent(),
          );
      }
    }

    return Container(
      width: fullWidth ? double.infinity : null,
      child: buildButton(),
    );
  }
}