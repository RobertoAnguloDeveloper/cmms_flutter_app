// 📂 lib/gui/components/color_picker_dialog.dart

import 'package:flutter/material.dart';
import '../../constants/gui_constants/app_spacing.dart';
import '../../constants/gui_constants/app_typography.dart';

class ColorPickerDialog extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onColorSelected;

  const ColorPickerDialog({
    super.key,
    required this.initialColor,
    required this.onColorSelected,
  });

  @override
  State<ColorPickerDialog> createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  late Color _selectedColor;
  final List<Color> _presetColors = [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
    Colors.black,
    Colors.white,
  ];

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.initialColor;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Choose Color', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.md),
            // Color preview
            Container(
              width: double.infinity,
              height: 60,
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Preset colors grid
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: _presetColors.map((color) {
                return InkWell(
                  onTap: () {
                    setState(() => _selectedColor = color);
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _selectedColor == color
                            ? Theme.of(context).primaryColor
                            : Colors.grey,
                        width: _selectedColor == color ? 2 : 1,
                      ),
                    ),
                    child: _selectedColor == color
                        ? Icon(
                      Icons.check,
                      color: _getContrastColor(color),
                      size: 24,
                    )
                        : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            // RGB Sliders
            _buildColorSlider(
              'Red',
              Colors.red,
              _selectedColor.r.toDouble(),
                  (value) {
                setState(() {
                  _selectedColor = _selectedColor.withRed(value.toInt());
                });
              },
            ),
            _buildColorSlider(
              'Green',
              Colors.green,
              _selectedColor.g.toDouble(),
                  (value) {
                setState(() {
                  _selectedColor = _selectedColor.withGreen(value.toInt());
                });
              },
            ),
            _buildColorSlider(
              'Blue',
              Colors.blue,
              _selectedColor.b.toDouble(),
                  (value) {
                setState(() {
                  _selectedColor = _selectedColor.withBlue(value.toInt());
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Opacity Slider
            _buildColorSlider(
              'Opacity',
              Colors.grey,
              _selectedColor.a * 255,
                  (value) {
                setState(() {
                  _selectedColor = _selectedColor.withOpacity(value / 255);
                });
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: AppSpacing.md),
                ElevatedButton(
                  onPressed: () {
                    widget.onColorSelected(_selectedColor);
                    Navigator.of(context).pop();
                  },
                  child: const Text('Select'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSlider(
      String label,
      Color trackColor,
      double value,
      ValueChanged<double> onChanged,
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTypography.body),
            Text(value.round().toString(), style: AppTypography.body),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: trackColor,
            inactiveTrackColor: trackColor.withOpacity(0.3),
            thumbColor: trackColor,
          ),
          child: Slider(
            value: value,
            min: 0,
            max: 255,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Color _getContrastColor(Color backgroundColor) {
    if (backgroundColor == Colors.transparent) return Colors.black;

    double luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}