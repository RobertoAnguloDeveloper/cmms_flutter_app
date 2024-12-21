// 📂 lib/gui/components/app_drawer.dart

import 'package:flutter/material.dart';
import '../../constants/gui_constants/app_spacing.dart';

class DrawerItem {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final bool selected;
  final List<DrawerItem>? subItems;

  const DrawerItem({
    required this.title,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.subItems,
  });
}

class AppDrawer extends StatelessWidget {
  final String? headerTitle;
  final Widget? headerWidget;
  final List<DrawerItem> items;
  final Widget? footer;
  final double width;

  const AppDrawer({
    super.key,
    this.headerTitle,
    this.headerWidget,
    required this.items,
    this.footer,
    this.width = 300,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: width,
      child: Drawer(
        child: Column(
          children: [
            // Header
            if (headerWidget != null)
              headerWidget!
            else if (headerTitle != null)
              DrawerHeader(
                decoration: BoxDecoration(
                  color: theme.primaryColor,
                ),
                child: Center(
                  child: Text(
                    headerTitle!,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),

            // Items
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: items.length,
                itemBuilder: (context, index) => _buildDrawerItem(
                  context,
                  items[index],
                ),
              ),
            ),

            // Footer
            if (footer != null) ...[
              const Divider(),
              footer!,
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, DrawerItem item) {
    final theme = Theme.of(context);

    Widget listTile = ListTile(
      leading: Icon(
        item.icon,
        color: item.selected ? theme.primaryColor : null,
      ),
      title: Text(
        item.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: item.selected ? theme.primaryColor : null,
          fontWeight: item.selected ? FontWeight.w600 : null,
        ),
      ),
      selected: item.selected,
      onTap: item.onTap,
    );

    if (item.subItems != null && item.subItems!.isNotEmpty) {
      return ExpansionTile(
        leading: Icon(item.icon),
        title: Text(item.title),
        children: item.subItems!
            .map((subItem) => _buildDrawerItem(context, subItem))
            .toList(),
      );
    }

    return listTile;
  }
}