// 📂 lib/gui/screens/logo_crop_screen.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../components/screen_scaffold.dart';
import '../components/custom_button.dart';
import '../components/color_picker_dialog.dart';
import '../../constants/gui_constants/app_spacing.dart';

class LogoTransformData {
  final double scale;
  final Offset position;
  final Color? backgroundColor;

  LogoTransformData({
    required this.scale,
    required this.position,
    this.backgroundColor,
  });

  Map<String, dynamic> toJson() => {
    'scale': scale,
    'position': {
      'x': position.dx,
      'y': position.dy,
    },
    if (backgroundColor != null)
      'background_color': '#${backgroundColor!.value.toRadixString(16).padLeft(8, '0').substring(2)}',
  };

  factory LogoTransformData.fromJson(Map<String, dynamic> json) {
    final position = json['position'] as Map<String, dynamic>;
    String? bgColor = json['background_color'] as String?;

    return LogoTransformData(
      scale: json['scale'] as double,
      position: Offset(
        position['x'] as double,
        position['y'] as double,
      ),
      backgroundColor: bgColor != null ?
      Color(int.parse('FF${bgColor.replaceFirst('#', '')}', radix: 16)) :
      null,
    );
  }
}

class LogoCropScreen extends StatefulWidget {
  final String filename;
  final Uint8List logoBytes;
  final LogoTransformData? initialTransform;
  final Function(LogoTransformData) onSave;
  final Map<String, dynamic>? logoTransform;

  const LogoCropScreen({
    super.key,
    required this.filename,
    required this.logoBytes,
    this.initialTransform,
    required this.onSave,
    this.logoTransform
  });

  @override
  State<LogoCropScreen> createState() => _LogoCropScreenState();
}

class _LogoCropScreenState extends State<LogoCropScreen> {
  late double _scale;
  late Offset _position;
  Color? _backgroundColor;
  bool _isDragging = false;
  Offset? _startPosition;
  Offset? _startDragPosition;

  static const double maxScale = 4.0;
  static const double containerSize = 200.0; // Preview circle size
  static const double maxDragDistance = containerSize / 2;

  @override
  void initState() {
    super.initState();
    _scale = widget.initialTransform?.scale ?? 1.0;
    _position = widget.initialTransform?.position ?? Offset.zero;
    _backgroundColor = widget.initialTransform?.backgroundColor;
  }

  void _handleDragStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
      _startPosition = _position;
      _startDragPosition = details.localPosition;
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isDragging || _startPosition == null || _startDragPosition == null) return;

    setState(() {
      final dx = details.localPosition.dx - _startDragPosition!.dx;
      final dy = details.localPosition.dy - _startDragPosition!.dy;

      // Calculate position relative to center
      _position = Offset(
        (_startPosition!.dx + dx / _scale).clamp(-maxDragDistance, maxDragDistance),
        (_startPosition!.dy + dy / _scale).clamp(-maxDragDistance, maxDragDistance),
      );
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    setState(() {
      _isDragging = false;
      _startPosition = null;
      _startDragPosition = null;
    });
  }

  void _handleSelectBackground() {
    showDialog(
      context: context,
      builder: (context) => ColorPickerDialog(
        initialColor: _backgroundColor ?? Colors.white,
        onColorSelected: (color) {
          setState(() => _backgroundColor = color);
        },
      ),
    );
  }

  void _handleClearBackground() {
    setState(() => _backgroundColor = null);
  }

  void _handleSave() {
    final transformData = LogoTransformData(
      scale: _scale,
      position: _position,
      backgroundColor: _backgroundColor,
    );
    widget.onSave(transformData);
    Navigator.of(context).pop();
  }

  void _handleReset() {
    setState(() {
      _scale = 1.0;
      _position = Offset.zero;
      _backgroundColor = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ScreenScaffold(
      title: 'Adjust Logo',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Drag to adjust position',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Background color controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Background:', style: theme.textTheme.titleMedium),
                const SizedBox(width: AppSpacing.md),
                InkWell(
                  onTap: _handleSelectBackground,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _backgroundColor ?? Colors.transparent,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _backgroundColor == null
                        ? const Icon(Icons.add, color: Colors.grey)
                        : null,
                  ),
                ),
                if (_backgroundColor != null) ...[
                  const SizedBox(width: AppSpacing.md),
                  IconButton(
                    onPressed: _handleClearBackground,
                    icon: const Icon(Icons.clear),
                    tooltip: 'Clear background',
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Logo preview area
            Center(
              child: Container(
                width: containerSize,
                height: containerSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                  color: _backgroundColor,
                ),
                clipBehavior: Clip.antiAlias,
                child: GestureDetector(
                  onPanStart: _handleDragStart,
                  onPanUpdate: _handleDragUpdate,
                  onPanEnd: _handleDragEnd,
                  child: Transform.scale(
                    scale: _scale,
                    child: Transform.translate(
                      offset: _position,
                      child: Center(
                        child: Image.memory(
                          widget.logoBytes,
                          width: containerSize,
                          height: containerSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Scale slider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  Text(
                    'Zoom: ${(_scale * 100).toStringAsFixed(0)}%',
                    style: theme.textTheme.titleMedium,
                  ),
                  Slider(
                    value: _scale,
                    min: 0.5,
                    max: maxScale, // Use higher max scale
                    divisions: 35, // Increased divisions for finer control
                    label: '${(_scale * 100).toStringAsFixed(0)}%',
                    onChanged: (value) {
                      setState(() {
                        _scale = value;
                        // Adjust position constraints when scale changes
                        final maxOffset = maxDragDistance / _scale;
                        _position = Offset(
                          _position.dx.clamp(-maxOffset, maxOffset),
                          _position.dy.clamp(-maxOffset, maxOffset),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: 'Reset',
                  onPressed: _handleReset,
                  variant: ButtonVariant.outline,
                ),
                const SizedBox(width: AppSpacing.lg),
                CustomButton(
                  text: 'Save',
                  onPressed: _handleSave,
                  variant: ButtonVariant.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}