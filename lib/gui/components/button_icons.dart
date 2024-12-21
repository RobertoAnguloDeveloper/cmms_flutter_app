// 📂 lib/gui/components/button_icons.dart

import 'package:flutter/material.dart';

enum IconSize {
  small(16.0),
  medium(24.0),
  large(32.0),
  custom(0.0);

  final double size;
  const IconSize(this.size);
}

class AppIcon extends StatelessWidget {
  final IconData icon;
  final IconSize size;
  final double? customSize;
  final Color? color;
  final bool disabled;
  final VoidCallback? onTap;
  final String? tooltip;

  const AppIcon({
    super.key,
    required this.icon,
    this.size = IconSize.medium,
    this.customSize,
    this.color,
    this.disabled = false,
    this.onTap,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconSize = size == IconSize.custom ? customSize : size.size;
    final effectiveColor = disabled
        ? theme.disabledColor
        : color ?? theme.iconTheme.color;

    Widget iconWidget = Icon(
      icon,
      size: iconSize,
      color: effectiveColor,
    );

    if (tooltip != null) {
      iconWidget = Tooltip(
        message: tooltip!,
        child: iconWidget,
      );
    }

    if (onTap != null && !disabled) {
      iconWidget = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: iconWidget,
        ),
      );
    }

    return iconWidget;
  }
}

class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final IconSize size;
  final String? tooltip;
  final bool disabled;
  final Color? color;
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;
  final double? splashRadius;

  const AppIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = IconSize.medium,
    this.tooltip,
    this.disabled = false,
    this.color,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(8.0),
    this.splashRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return IconButton(
      icon: Icon(icon),
      onPressed: disabled ? null : onPressed,
      tooltip: tooltip,
      iconSize: size.size,
      color: disabled ? theme.disabledColor : color,
      padding: padding,
      splashRadius: splashRadius,
      style: IconButton.styleFrom(
        backgroundColor: backgroundColor,
        disabledBackgroundColor: backgroundColor?.withOpacity(0.12),
      ),
    );
  }
}

/// Common app icons for standardization
class AppIcons {
  // Navigation
  static const IconData back = Icons.arrow_back_rounded;
  static const IconData forward = Icons.arrow_forward_rounded;
  static const IconData menu = Icons.menu_rounded;
  static const IconData close = Icons.close_rounded;

  // Actions
  static const IconData add = Icons.add_rounded;
  static const IconData edit = Icons.edit_rounded;
  static const IconData delete = Icons.delete_rounded;
  static const IconData save = Icons.save_rounded;
  static const IconData refresh = Icons.refresh_rounded;
  static const IconData search = Icons.search_rounded;
  static const IconData filter = Icons.filter_list_rounded;

  // Status
  static const IconData success = Icons.check_circle_outline_rounded;
  static const IconData error = Icons.error_outline_rounded;
  static const IconData warning = Icons.warning_amber_rounded;
  static const IconData info = Icons.info_outline_rounded;

  // Common
  static const IconData calendar = Icons.calendar_today_rounded;
  static const IconData time = Icons.access_time_rounded;
  static const IconData user = Icons.person_rounded;
  static const IconData settings = Icons.settings_rounded;
  static const IconData notification = Icons.notifications_rounded;
  static const IconData upload = Icons.upload_rounded;
  static const IconData download = Icons.download_rounded;
  static const IconData attach = Icons.attach_file_rounded;
  static const IconData copy = Icons.content_copy_rounded;
  static const IconData share = Icons.share_rounded;

  // Form
  static const IconData visible = Icons.visibility_rounded;
  static const IconData invisible = Icons.visibility_off_rounded;
  static const IconData dropdown = Icons.arrow_drop_down_rounded;
  static const IconData clear = Icons.clear_rounded;

  AppIcons._();
}