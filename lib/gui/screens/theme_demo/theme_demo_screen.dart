import 'package:flutter/material.dart';
import '../../theme/theme_extensions.dart';

class ThemeDemoScreen extends StatelessWidget {
  const ThemeDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Access theme extensions
    final colors = Theme.of(context).extension<AppColorExtension>()!;
    final spacing = Theme.of(context).extension<AppSpacingExtension>()!;
    final typography = Theme.of(context).extension<AppTypographyExtension>()!;
    final components = Theme.of(context).extension<AppComponentsExtension>()!;

    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Demo', style: typography.h2),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(spacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colors Section
            Text('Colors', style: typography.h1),
            SizedBox(height: spacing.md),
            _ColorPalette(colors: colors),
            SizedBox(height: spacing.lg),

            // Typography Section
            Text('Typography', style: typography.h1),
            SizedBox(height: spacing.md),
            Text('Heading 1', style: typography.h1),
            Text('Heading 2', style: typography.h2),
            Text('Heading 3', style: typography.h3),
            Text('Body Text', style: typography.body),
            Text('Caption Text', style: typography.caption),
            SizedBox(height: spacing.lg),

            // Spacing Section
            Text('Spacing', style: typography.h1),
            SizedBox(height: spacing.md),
            _SpacingDemo(spacing: spacing),
            SizedBox(height: spacing.lg),

            // Components Section
            Text('Components', style: typography.h1),
            SizedBox(height: spacing.md),

            // Buttons
            Row(
              children: [
                ElevatedButton(
                  style: components.primaryButton,
                  onPressed: () {},
                  child: const Text('Primary Button'),
                ),
                SizedBox(width: spacing.md),
                ElevatedButton(
                  style: components.secondaryButton,
                  onPressed: () {},
                  child: const Text('Secondary Button'),
                ),
              ],
            ),
            SizedBox(height: spacing.md),

            // Card
            Card(
              elevation: components.cardTheme.elevation,
              margin: components.cardTheme.margin,
              shape: components.cardTheme.shape,
              child: Padding(
                padding: EdgeInsets.all(spacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Card Title', style: typography.h3),
                    SizedBox(height: spacing.sm),
                    Text(
                      'This is a card component with themed styling.',
                      style: typography.body,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: spacing.md),

            // Input Field
            TextField(
              decoration: InputDecoration(
                labelText: 'Themed Input Field',
                hintText: 'Type something...',
                border: components.inputTheme.border,
                contentPadding: components.inputTheme.contentPadding,
                fillColor: components.inputTheme.fillColor,
                filled: components.inputTheme.filled,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Toggle theme example
          final brightness = Theme.of(context).brightness;
          final mode = brightness == Brightness.light ? ThemeMode.dark : ThemeMode.light;

          // You would typically use a state management solution here
          // For this demo, you can implement theme switching in your app's root
        },
        child: Icon(
          Theme.of(context).brightness == Brightness.light
              ? Icons.dark_mode
              : Icons.light_mode,
          color: colors.text,
        ),
      ),
    );
  }
}

class _ColorPalette extends StatelessWidget {
  final AppColorExtension colors;

  const _ColorPalette({required this.colors});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _ColorBox(color: colors.primary, name: 'Primary'),
        _ColorBox(color: colors.secondary, name: 'Secondary'),
        _ColorBox(color: colors.background, name: 'Background'),
        _ColorBox(color: colors.surface, name: 'Surface'),
        _ColorBox(color: colors.error, name: 'Error'),
        _ColorBox(color: colors.text, name: 'Text'),
      ],
    );
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final String name;

  const _ColorBox({required this.color, required this.name});

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyExtension>()!;

    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).dividerColor,
              width: 1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(name, style: typography.caption),
      ],
    );
  }
}

class _SpacingDemo extends StatelessWidget {
  final AppSpacingExtension spacing;

  const _SpacingDemo({required this.spacing});

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyExtension>()!;
    final colors = Theme.of(context).extension<AppColorExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SpacingItem(size: spacing.xs, name: 'XS (${spacing.xs})', colors: colors),
        _SpacingItem(size: spacing.sm, name: 'SM (${spacing.sm})', colors: colors),
        _SpacingItem(size: spacing.md, name: 'MD (${spacing.md})', colors: colors),
        _SpacingItem(size: spacing.lg, name: 'LG (${spacing.lg})', colors: colors),
        _SpacingItem(size: spacing.xl, name: 'XL (${spacing.xl})', colors: colors),
      ],
    );
  }
}

class _SpacingItem extends StatelessWidget {
  final double size;
  final String name;
  final AppColorExtension colors;

  const _SpacingItem({
    required this.size,
    required this.name,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final typography = Theme.of(context).extension<AppTypographyExtension>()!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: size,
            height: 20,
            color: colors.primary,
          ),
          const SizedBox(width: 16),
          Text(name, style: typography.body),
        ],
      ),
    );
  }
}