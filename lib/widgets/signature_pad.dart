// lib/widgets/signature_pad.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../services/signature_utils_service.dart';

class SignaturePad extends StatefulWidget {
  final Function(File? file) onSignatureCaptured;
  final double height;
  final bool showActions;
  final String? initialSignaturePath;

  const SignaturePad({
    Key? key,
    required this.onSignatureCaptured,
    this.height = 200,
    this.showActions = true,
    this.initialSignaturePath,
  }) : super(key: key);

  @override
  SignaturePadState createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  final GlobalKey _signatureKey = GlobalKey();
  final List<List<Offset>> _strokes = <List<Offset>>[];
  List<Offset>? _currentStroke;
  String? _savedSignaturePath;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _savedSignaturePath = widget.initialSignaturePath;
  }

  bool get isEmpty => _strokes.isEmpty;

  Future<void> captureAndSaveSignature() async {
    if (_strokes.isEmpty) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final fileName = SignatureUtilsService.generateSignatureFileName();
      final file = await SignatureUtilsService.saveSignature(_signatureKey, fileName);

      if (file != null) {
        setState(() {
          _savedSignaturePath = file.path;
        });

        widget.onSignatureCaptured(file);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void clear() {
    setState(() {
      _strokes.clear();
      _currentStroke = null;
      _savedSignaturePath = null;
    });
    widget.onSignatureCaptured(null);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          RepaintBoundary(
            key: _signatureKey,
            child: Container(
              height: widget.height,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: GestureDetector(
                onPanDown: (DragDownDetails details) {
                  setState(() {
                    _currentStroke = [details.localPosition];
                    _strokes.add(_currentStroke!);
                  });
                },
                onPanUpdate: (DragUpdateDetails details) {
                  setState(() {
                    _currentStroke?.add(details.localPosition);
                    _strokes.last = List.from(_currentStroke!);
                  });
                },
                onPanEnd: (DragEndDetails details) {
                  _currentStroke = null;
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CustomPaint(
                    painter: SignaturePainter(strokes: _strokes),
                    size: Size.infinite,
                  ),
                ),
              ),
            ),
          ),

        if (widget.showActions) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: clear,
                icon: const Icon(Icons.refresh),
                label: const Text('Clear'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[700],
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: _strokes.isEmpty ? null : captureAndSaveSignature,
                icon: const Icon(Icons.save),
                label: const Text('Save Signature'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],

        // Show the saved signature if available
        if (_savedSignaturePath != null) ...[
          const SizedBox(height: 16),
          const Text('Saved Signature:', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Container(
            height: 100,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Image.file(
                File(_savedSignaturePath!),
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  SignaturePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (final List<Offset> stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}