// 📂 lib/gui/components/screen_scaffold.dart

import 'package:flutter/material.dart';
import '../../constants/gui_constants/app_spacing.dart';

class ScreenScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;
  final PreferredSizeWidget? bottom;
  final Widget? drawer;
  final Widget? endDrawer;
  final bool extendBody;
  final bool resizeToAvoidBottomInset;

  const ScreenScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.bottom,
    this.drawer,
    this.endDrawer,
    this.extendBody = false,
    this.resizeToAvoidBottomInset = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      backgroundColor: backgroundColor ?? theme.scaffoldBackgroundColor,
      appBar: title != null || actions != null || (showBackButton && canPop)
          ? AppBar(
        title: title != null ? Text(title!) : null,
        centerTitle: true,
        leading: leading ?? (showBackButton && canPop
            ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        )
            : null),
        actions: actions,
        bottom: bottom,
      )
          : null,
      body: SafeArea(
        child: body,
      ),
      drawer: drawer,
      endDrawer: endDrawer,
      floatingActionButton: floatingActionButton,
      extendBody: extendBody,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
    );
  }
}