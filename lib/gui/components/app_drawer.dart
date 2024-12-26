// 📂 lib/gui/components/app_drawer.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_services/cmms_config_provider.dart';
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

class AppDrawer extends StatefulWidget {
  final String? headerTitle;
  final Widget? headerWidget;
  final List<DrawerItem> items;
  final Widget? footer;
  final double width;
  final String? userName;
  final String? userEmail;
  final String? userInitials;
  final String? logoFile;

  const AppDrawer({
    super.key,
    this.headerTitle,
    this.headerWidget,
    required this.items,
    this.footer,
    this.width = 300,
    this.userName,
    this.userEmail,
    this.userInitials,
    this.logoFile,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Uint8List? _logoBytes;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.logoFile != null) {
      Future.microtask(() => _loadLogo());
    }
  }

  @override
  void didUpdateWidget(AppDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logoFile != widget.logoFile) {
      Future.microtask(() {
        if (widget.logoFile != null) {
          _loadLogo();
        } else {
          setState(() => _logoBytes = null);
        }
      });
    }
  }

  Future<void> _loadLogo() async {
    if (widget.logoFile == null) {
      setState(() => _logoBytes = null);
      return;
    }

    if (_isLoading) return; // Prevent multiple simultaneous loads

    try {
      setState(() => _isLoading = true);
      print('Loading logo: ${widget.logoFile}');

      final configProvider =
          Provider.of<CmmsConfigProvider>(context, listen: false);
      final bytes = await configProvider.downloadConfig(widget.logoFile!);
      print('Received bytes length: ${bytes.length}');

      if (mounted) {
        setState(() {
          _logoBytes = bytes;
          _isLoading = false;
          print('Logo bytes set in state. Length: ${_logoBytes?.length}');
        });
      }
    } catch (e) {
      print('Error loading logo: $e');
      if (mounted) {
        setState(() {
          _logoBytes = null;
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildDefaultHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Increase size significantly for the logo container
    final double containerSize = 75; // Increased from 120 to 160

    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            Color.fromARGB(
              0xDD,
              colorScheme.primary.r.toInt(),
              colorScheme.primary.g.toInt(),
              colorScheme.primary.b.toInt(),
            ),
          ],
        ),
      ),
      margin: EdgeInsets.zero,
      // Increase the header height to accommodate larger logo
      currentAccountPictureSize: Size(containerSize, containerSize),
      accountName: Padding(
        padding: const EdgeInsets.only(top: 9.0),
        child: Text(
          widget.userName ?? '',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                offset: const Offset(1.0, 1.0),
                blurRadius: 3.0,
                color: Color.fromARGB(0x80, 0, 0, 0),
              ),
            ],
          ),
        ),
      ),
      accountEmail: Text(
        widget.userEmail ?? '',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onPrimary,
          shadows: [
            Shadow(
              offset: const Offset(0.5, 1.0),
              blurRadius: 3.0,
              color: Color.fromARGB(0x80, 0, 0, 0),
            ),
          ],
        ),
      ),
      currentAccountPicture: Container(
        width: containerSize,
        height: containerSize,
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: colorScheme.onPrimary,
            width: 2.0,
          ),
          color: Colors.white,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              Color.fromARGB(
                0xDD,
                colorScheme.primary.r.toInt(),
                colorScheme.primary.g.toInt(),
                colorScheme.primary.b.toInt(),
              ),
            ],
          ),
        ),
        child: ClipOval(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _logoBytes != null
                  ? Image.memory(
                      _logoBytes!,
                      fit: BoxFit.contain,
                      width: containerSize,
                      height: containerSize,
                    )
                  : Center(
                      child: Text(
                        widget.userInitials?.toUpperCase() ?? 'U',
                        style: TextStyle(
                          color: colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 30, // Increased font size for initials
                        ),
                      ),
                    ),
        ),
      ),
      otherAccountsPictures: null,
    );
  }

  Widget _buildDrawerItem(BuildContext context, DrawerItem item) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    Widget listTile = ListTile(
      dense: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.xs),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      selectedTileColor: Color.fromARGB(
        0x19,
        colorScheme.primaryContainer.r.toInt(),
        colorScheme.primaryContainer.g.toInt(),
        colorScheme.primaryContainer.b.toInt(),
      ),
      leading: Icon(
        item.icon,
        color:
            item.selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        size: 40,
      ),
      title: Text(
        item.title,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: item.selected ? colorScheme.primary : colorScheme.onSurface,
          fontWeight: item.selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: item.selected,
      onTap: item.onTap,
    );

    if (item.subItems != null && item.subItems!.isNotEmpty) {
      return Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          leading: Icon(
            item.icon,
            color: colorScheme.onSurfaceVariant,
            size: 24,
          ),
          title: Text(
            item.title,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface,
            ),
          ),
          children: item.subItems!.map((subItem) {
            return Padding(
              padding: const EdgeInsets.only(left: AppSpacing.md),
              child: _buildDrawerItem(context, subItem),
            );
          }).toList(),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: listTile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: widget.width,
      child: Drawer(
        backgroundColor: colorScheme.surface,
        child: Column(
          children: [
            if (widget.headerWidget != null)
              widget.headerWidget!
            else if (widget.headerTitle != null)
              _buildDefaultHeader(context)
            else
              _buildDefaultHeader(context),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                itemCount: widget.items.length,
                itemBuilder: (context, index) => _buildDrawerItem(
                  context,
                  widget.items[index],
                ),
              ),
            ),
            if (widget.footer != null) ...[
              const Divider(height: 1),
              widget.footer!,
              const SizedBox(height: AppSpacing.md),
            ],
          ],
        ),
      ),
    );
  }
}
