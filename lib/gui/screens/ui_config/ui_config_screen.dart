// 📂 lib/gui/screens/ui_config/ui_config_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../constants/gui_constants/app_colors.dart';
import '../../../constants/gui_constants/app_spacing.dart';
import '../../../constants/gui_constants/app_typography.dart';
import '../../../constants/gui_constants/theme_constants.dart';
import '../../components/color_picker_dialog.dart';
import '../../theme/app_theme_provider.dart';

class UIConfigScreen extends StatefulWidget {
  final ThemeMode themeMode;
  final Function(bool) onThemeChanged;

  const UIConfigScreen({
    super.key,
    required this.themeMode,
    required this.onThemeChanged,
  });

  @override
  State<UIConfigScreen> createState() => _UIConfigScreenState();
}

class _UIConfigScreenState extends State<UIConfigScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double _fontSize = 16;
  double _spacing = 8;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('UI Configuration'),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            Provider.of<AppThemeProvider>(context, listen: false).resetToDefaults();
          },
          tooltip: 'Reset to Defaults',
        ),
        Switch(
          value: widget.themeMode == ThemeMode.dark,
          onChanged: widget.onThemeChanged,
        ),
        const SizedBox(width: AppSpacing.md),
      ],
    );
  }

  Widget _buildBody() {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildConfigPanel(),
        ),
        Expanded(
          child: _buildPreviewPanel(),
        ),
      ],
    );
  }

  Widget _buildConfigPanel() {
    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Colors'),
              Tab(text: 'Typography'),
              Tab(text: 'Spacing'),
              Tab(text: 'Components'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildColorsTab(),
                _buildTypographyTab(),
                _buildSpacingTab(),
                _buildComponentsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsTab() {
    final themeProvider = Provider.of<AppThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        _ColorPickerField(
          label: 'Primary Color',
          color: themeProvider.primaryColor,
          onColorChanged: (color) => themeProvider.setPrimaryColor(color),
        ),
        const SizedBox(height: AppSpacing.md),
        _ColorPickerField(
          label: 'Secondary Color',
          color: themeProvider.secondaryColor,
          onColorChanged: (color) => themeProvider.setSecondaryColor(color),
        ),
        const SizedBox(height: AppSpacing.md),
        _ColorPickerField(
          label: 'Background Color',
          color: themeProvider.backgroundColor,
          onColorChanged: (color) => themeProvider.setBackgroundColor(color),
        ),
        const SizedBox(height: AppSpacing.md),
        _ColorPickerField(
          label: 'Text Color',
          color: themeProvider.textColor,
          onColorChanged: (color) => themeProvider.setTextColor(color),
        ),
      ],
    );
  }

  Widget _buildTypographyTab() {
    final themeProvider = Provider.of<AppThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Font Family', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: DropdownButtonFormField<String>(
              value: themeProvider.fontFamily,
              decoration: const InputDecoration(
                labelText: 'Select Font Family',
                border: InputBorder.none,
              ),
              items: ThemeConstants.availableFontFamilies.map((String family) {
                return DropdownMenuItem<String>(
                  value: family,
                  child: Text(family, style: TextStyle(fontFamily: family)),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  themeProvider.setFontFamily(newValue);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Base Font Size', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                Slider(
                  value: _fontSize,
                  min: 12,
                  max: 24,
                  divisions: 12,
                  label: '${_fontSize.round()}px',
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                    });
                  },
                ),
                Text('${_fontSize.round()}px', style: AppTypography.body),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Typography Preview', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heading 1',
                  style: TextStyle(
                    fontSize: _fontSize * 2,
                    fontFamily: themeProvider.fontFamily,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Heading 2',
                  style: TextStyle(
                    fontSize: _fontSize * 1.5,
                    fontFamily: themeProvider.fontFamily,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Body Text',
                  style: TextStyle(
                    fontSize: _fontSize,
                    fontFamily: themeProvider.fontFamily,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpacingTab() {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Base Spacing Unit', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.sm),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Column(
              children: [
                Slider(
                  value: _spacing,
                  min: 4,
                  max: 16,
                  divisions: 6,
                  label: '${_spacing.round()}px',
                  onChanged: (value) {
                    setState(() {
                      _spacing = value;
                    });
                  },
                ),
                Text('${_spacing.round()}px', style: AppTypography.body),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Spacing Preview', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: _SpacingPreview(spacing: _spacing),
          ),
        ),
      ],
    );
  }

  Widget _buildComponentsTab() {
    final themeProvider = Provider.of<AppThemeProvider>(context);

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        Text('Buttons', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Buttons', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.md),
                SingleChildScrollView(  // Add horizontal scrolling capability
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.md,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        child: const Text('Primary Button'),
                      ),
                      OutlinedButton(
                        onPressed: () {},
                        child: const Text('Secondary Button'),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text('Text Button'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text('Cards', style: AppTypography.h3),
        const SizedBox(height: AppSpacing.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Card Title', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.sm),
                Text('Card content example', style: AppTypography.body),
              ],
            ),
          ),
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Interactive Elements', style: AppTypography.h3),
                const SizedBox(height: AppSpacing.md),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Text Input',
                    hintText: 'Enter text...',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                CheckboxListTile(
                  title: const Text('Checkbox'),
                  value: true,
                  onChanged: (_) {},
                ),
                SwitchListTile(
                  title: const Text('Switch'),
                  value: true,
                  onChanged: (_) {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewPanel() {
    final themeProvider = Provider.of<AppThemeProvider>(context);

    return Card(
      margin: const EdgeInsets.all(AppSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Live Preview',
              style: AppTypography.h2.copyWith(
                color: themeProvider.textColor,
                fontFamily: themeProvider.fontFamily,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(_spacing),
                decoration: BoxDecoration(
                  color: themeProvider.backgroundColor,
                  border: Border.all(color: themeProvider.primaryColor),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Preview Title',
                      style: TextStyle(
                        fontSize: _fontSize * 1.5,
                        color: themeProvider.textColor,
                        fontFamily: themeProvider.fontFamily,
                      ),
                    ),
                    SizedBox(height: _spacing),
                    Text(
                      'This is a preview of how your content will look with the current settings.',
                      style: TextStyle(
                        fontSize: _fontSize,
                        color: themeProvider.textColor,
                        fontFamily: themeProvider.fontFamily,
                      ),
                    ),
                    const Spacer(),
                    Wrap(  // Replace Row with Wrap
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.md,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          child: const Text('Primary Button'),
                        ),
                        OutlinedButton(
                          onPressed: () {},
                          child: const Text('Secondary Button'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPickerField extends StatelessWidget {
  final String label;
  final Color color;
  final ValueChanged<Color> onColorChanged;

  const _ColorPickerField({
    required this.label,
    required this.color,
    required this.onColorChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.body),
        const SizedBox(height: AppSpacing.sm),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ColorPickerDialog(
                initialColor: color,
                onColorSelected: onColorChanged,
              ),
            );
          },
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpacingPreview extends StatelessWidget {
  final double spacing;

  const _SpacingPreview({required this.spacing});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SpacingBlock(label: 'XS', size: spacing * 0.5),
        _SpacingBlock(label: 'SM', size: spacing),
        _SpacingBlock(label: 'MD', size: spacing * 2),
        _SpacingBlock(label: 'LG', size: spacing * 3),
        _SpacingBlock(label: 'XL', size: spacing * 4),
      ],
    );
  }
}

class _SpacingBlock extends StatelessWidget {
  final String label;
  final double size;

  const _SpacingBlock({
    required this.label,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<AppThemeProvider>(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: size,
            height: 20,
            decoration: BoxDecoration(
              color: themeProvider.primaryColor,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(  // Add Expanded here
            child: Text(
              '$label (${size.round()}px)',
              style: TextStyle(
                fontFamily: themeProvider.fontFamily,
                color: themeProvider.textColor,
              ),
              overflow: TextOverflow.ellipsis,  // Add ellipsis for long text
            ),
          ),
          const SizedBox(width: AppSpacing.sm),  // Add some spacing
          Text(
            '${size.round()}px',
            style: TextStyle(
              color: themeProvider.textColor.withOpacity(0.6),
              fontFamily: themeProvider.fontFamily,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}