// 📂 lib/gui/components/signature_pad.dart

import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  final double width;
  final double height;
  final Color backgroundColor;
  final Color strokeColor;
  final double strokeWidth;
  final String? placeholder;
  final Function(List<List<Offset>>)? onChanged;
  final BorderRadius? borderRadius;
  final Function(ui.Image)? onSaved;

  const SignaturePad({
    super.key,
    this.width = double.infinity,
    this.height = 200,
    this.backgroundColor = Colors.white,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
    this.placeholder,
    this.onChanged,
    this.borderRadius,
    this.onSaved,
  });

  @override
  State<SignaturePad> createState() => _SignaturePadState();
}

class _SignaturePadState extends State<SignaturePad> {
  List<List<Offset>> _strokes = [];
  List<Offset>? _currentStroke;
  bool _isDrawing = false;

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDrawing = true;
      _currentStroke = [details.localPosition];
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (!_isDrawing) return;

    setState(() {
      _currentStroke?.add(details.localPosition);
    });
    widget.onChanged?.call([..._strokes, if (_currentStroke != null) _currentStroke!]);
  }

  void _onPanEnd(DragEndDetails details) {
    if (!_isDrawing) return;

    setState(() {
      if (_currentStroke != null) {
        _strokes.add(_currentStroke!);
      }
      _currentStroke = null;
      _isDrawing = false;
    });
  }

  void clear() {
    setState(() {
      _strokes = [];
      _currentStroke = null;
      _isDrawing = false;
    });
    widget.onChanged?.call(_strokes);
  }

  void undo() {
    if (_strokes.isEmpty) return;

    setState(() {
      _strokes.removeLast();
    });
    widget.onChanged?.call(_strokes);
  }

  Future<ui.Image> exportImage() async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()
      ..color = widget.strokeColor
      ..strokeWidth = widget.strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, widget.width, widget.height),
      Paint()..color = widget.backgroundColor,
    );

    // Draw all strokes
    for (final stroke in _strokes) {
      if (stroke.length < 2) continue;

      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);

      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }

      canvas.drawPath(path, paint);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(
      widget.width.toInt(),
      widget.height.toInt(),
    );

    return image;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: widget.borderRadius,
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            children: [
              // Placeholder text
              if (_strokes.isEmpty && widget.placeholder != null)
                Center(
                  child: Text(
                    widget.placeholder!,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),

              // Signature canvas
              GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: CustomPaint(
                  size: Size(widget.width, widget.height),
                  painter: _SignaturePainter(
                    strokes: _strokes,
                    currentStroke: _currentStroke,
                    strokeColor: widget.strokeColor,
                    strokeWidth: widget.strokeWidth,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),

        // Control buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            IconButton(
              icon: const Icon(Icons.undo),
              onPressed: _strokes.isEmpty ? null : undo,
              tooltip: 'Undo',
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _strokes.isEmpty ? null : clear,
              tooltip: 'Clear',
            ),
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _strokes.isEmpty ? null : () async {
                final image = await exportImage();
                widget.onSaved?.call(image);
              },
              tooltip: 'Save',
            ),
          ],
        ),
      ],
    );
  }
}

class _SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset>? currentStroke;
  final Color strokeColor;
  final double strokeWidth;

  _SignaturePainter({
    required this.strokes,
    this.currentStroke,
    required this.strokeColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Draw completed strokes
    for (final stroke in strokes) {
      if (stroke.length < 2) continue;

      final path = Path();
      path.moveTo(stroke[0].dx, stroke[0].dy);

      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }

      canvas.drawPath(path, paint);
    }

    // Draw current stroke
    if (currentStroke != null && currentStroke!.length >= 2) {
      final path = Path();
      path.moveTo(currentStroke![0].dx, currentStroke![0].dy);

      for (int i = 1; i < currentStroke!.length; i++) {
        path.lineTo(currentStroke![i].dx, currentStroke![i].dy);
      }

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}