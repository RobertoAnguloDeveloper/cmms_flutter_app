// 📂 lib/gui/components/app_drawer.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_services/cmms_config_provider.dart';
import '../../constants/gui_constants/app_spacing.dart';
import '../screens/logo_crop_screen.dart';

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
  final Map<String, dynamic>? logoTransform;

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
    this.logoTransform,
  });

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  Uint8List? _logoBytes;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    if (widget.logoFile != null) {
      _loadLogo();
    }
  }

  @override
  void didUpdateWidget(AppDrawer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.logoFile != widget.logoFile) {
      if (widget.logoFile != null) {
        _loadLogo();
      } else {
        setState(() {
          _logoBytes = null;
          _hasError = false;
        });
      }
    }
  }

  Future<void> _loadLogo() async {
    if (widget.logoFile == null || _isLoading) return;

    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      // Try to load from cache first
      final configProvider = Provider.of<CmmsConfigProvider>(context, listen: false);
      final bytes = await configProvider.downloadConfig(widget.logoFile!);

      if (mounted) {
        setState(() {
          _logoBytes = bytes;
          _isLoading = false;
          _hasError = bytes == null;
        });
      }
    } catch (e) {
      print('Error loading logo: $e');
      if (mounted) {
        setState(() {
          _logoBytes = null;
          _isLoading = false;
          _hasError = true;
        });
      }
    }
  }

  Widget _buildDefaultAvatar(ColorScheme colorScheme) {
    return Center(
      child: Text(
        widget.userInitials?.toUpperCase() ?? 'U',
        style: TextStyle(
          color: colorScheme.inversePrimary,
          fontWeight: FontWeight.bold,
          fontSize: 30,
        ),
      ),
    );
  }

  Widget _buildLogoContent(ColorScheme colorScheme, double containerSize) {
    if (_isLoading) {
      return const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_logoBytes != null) {
      final cropScreenSize = 200.0;
      final scaleRatio = containerSize / cropScreenSize;

      final transform = widget.logoTransform != null ?
      LogoTransformData.fromJson(widget.logoTransform!) : null;

      return Container(
        width: containerSize,
        height: containerSize,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: transform?.backgroundColor,
        ),
        child: SizedBox.expand(
          child: OverflowBox(
            maxWidth: cropScreenSize-cropScreenSize*0.1,
            maxHeight: cropScreenSize-cropScreenSize*0.1,
            child: Transform.scale(
              scale: scaleRatio * (transform?.scale ?? 1.0),
              child: Transform.translate(
                offset: transform?.position ?? Offset.zero,
                child: Image.memory(
                  _logoBytes!,
                  width: cropScreenSize,
                  height: cropScreenSize,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    print('Error displaying logo: $error');
                    return _buildDefaultAvatar(colorScheme);
                  },
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (_hasError) {
      return IconButton(
        icon: const Icon(Icons.refresh),
        onPressed: _loadLogo,
        tooltip: 'Retry loading logo',
      );
    }

    return _buildDefaultAvatar(colorScheme);
  }

  Widget _buildDefaultHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final double containerSize = 75;

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
          child: _buildLogoContent(colorScheme, containerSize),
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
        color: item.selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
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