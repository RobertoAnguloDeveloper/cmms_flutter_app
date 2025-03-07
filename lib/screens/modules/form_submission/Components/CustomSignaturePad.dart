/*
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// A callback function that provides the [file] of the signature
/// plus optional [author] and [position] metadata
typedef SignatureCallback = void Function(
    File? file, {
    String? author,
    String? position,
    });

class CustomSignaturePad extends StatefulWidget {
  /// The callback that fires whenever the user saves a signature.
  /// It provides the [File] plus optional metadata fields.
  final SignatureCallback onSignatureCaptured;

  /// If there's an existing signature file path, you can show it as a background.
  final String? initialSignaturePath;

  /// Optional initial metadata (if you want to show it in the text fields).
  final String? signatureAuthor;
  final String? signaturePosition;

  const CustomSignaturePad({
    Key? key,
    required this.onSignatureCaptured,
    this.initialSignaturePath,
    this.signatureAuthor,
    this.signaturePosition,
  }) : super(key: key);

  @override
  CustomSignaturePadState createState() => CustomSignaturePadState();
}

class CustomSignaturePadState extends State<CustomSignaturePad> {
  List<List<Offset>> _strokes = <List<Offset>>[];
  List<Offset>? _currentStroke;
  bool _hasSignature = false;

  /// Controllers for user-editable metadata
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set the initial author/position text if provided
    if (widget.signatureAuthor != null) {
      _authorController.text = widget.signatureAuthor!;
    }
    if (widget.signaturePosition != null) {
      _positionController.text = widget.signaturePosition!;
    }

    // If there's an existing signature file path, flag that we already have a signature
    if (widget.initialSignaturePath != null) {
      _hasSignature = true;
    }
  }

  @override
  void dispose() {
    _authorController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === Signature drawing area ===
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // If there's an existing signature image, show it
              if (widget.initialSignaturePath != null && _hasSignature)
                Center(
                  child: Image.file(
                    File(widget.initialSignaturePath!),
                    fit: BoxFit.contain,
                  ),
                ),

              // Otherwise, show the signature pad for drawing
              if (widget.initialSignaturePath == null || !_hasSignature)
                GestureDetector(
                  onPanDown: (details) {
                    setState(() {
                      _currentStroke = [details.localPosition];
                      _strokes.add(_currentStroke!);
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _currentStroke?.add(details.localPosition);
                      _strokes.last = List.from(_currentStroke!);
                    });
                  },
                  onPanEnd: (details) {
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // === Optional text fields for signature metadata (author/position) ===
        TextField(
          controller: _authorController,
          decoration: const InputDecoration(
            labelText: 'Signature Author',
            hintText: 'Enter the signer’s name',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _positionController,
          decoration: const InputDecoration(
            labelText: 'Signature Position',
            hintText: 'e.g. Manager, Client, or Form Signature',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        // === Buttons ===
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _clearSignature,
              icon: const Icon(Icons.clear, color: Colors.red),
              label: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _saveSignature,
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
    );
  }

  void _clearSignature() {
    setState(() {
      _strokes = <List<Offset>>[];
      _currentStroke = null;
      _hasSignature = false;
      // Notify parent that there's no valid signature now
      widget.onSignatureCaptured(null);
    });
  }

  Future<void> _saveSignature() async {
    // If we have no strokes and no initial signature, user hasn’t drawn anything yet.
    if (_strokes.isEmpty && widget.initialSignaturePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw a signature first')),
      );
      return;
    }

    // If the user left the author field blank, optionally warn them.
    // (Remove this check if not required in your flow)
    if (_authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the name of the signer')),
      );
      return;
    }

    try {
      // If there's an existing signature path and we haven't cleared/drawn over it,
      // just return that existing file.
      if (widget.initialSignaturePath != null && _hasSignature) {
        widget.onSignatureCaptured(
          File(widget.initialSignaturePath!),
          author: _authorController.text.trim(),
          position: _positionController.text.trim(),
        );
        return;
      }

      // Otherwise, create a new signature image from the user's drawing
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // For final image dimensions, tweak as needed
      const Size size = Size(400, 200);

      // Fill the background with white
      final Paint paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      // Draw the signature lines in black
      paint
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.0;

      for (final List<Offset> stroke in _strokes) {
        for (int i = 0; i < stroke.length - 1; i++) {
          canvas.drawLine(stroke[i], stroke[i + 1], paint);
        }
      }

      // Optional: embed the metadata (author/position) onto the signature itself
      final String authorText = 'Signed by: ${_authorController.text.trim()}';
      final String positionText = _positionController.text.trim().isNotEmpty
          ? 'Position: ${_positionController.text.trim()}'
          : '';

      final TextPainter authorPainter = TextPainter(
        text: TextSpan(
          text: authorText,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final TextPainter positionPainter = TextPainter(
        text: TextSpan(
          text: positionText,
          style: const TextStyle(color: Colors.black, fontSize: 12),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      // Paint author near the bottom-left
      const double padding = 5;
      final double yForAuthor = size.height - authorPainter.height - padding;
      authorPainter.paint(canvas, Offset(10, yForAuthor));

      // Paint the position above the author's name (if not empty)
      if (positionText.isNotEmpty) {
        final double yForPosition = yForAuthor - positionPainter.height - 2;
        positionPainter.paint(canvas, Offset(10, yForPosition));
      }

      // Wrap up the drawing into a Picture
      final picture = recorder.endRecording();

      // Convert that Picture to an Image
      final ui.Image img = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );

      // Convert to PNG bytes
      final ByteData? pngBytes = await img.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final buffer = pngBytes!.buffer.asUint8List();

      // Save to a temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/signature_$timestamp.png');
      await file.writeAsBytes(buffer);

      // Notify the parent widget with the newly created signature file + metadata
      widget.onSignatureCaptured(
        file,
        author: _authorController.text.trim(),
        position: _positionController.text.trim(),
      );

      setState(() {
        _hasSignature = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signature saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving signature: $e')),
      );
    }
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  SignaturePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}
*/

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

/// A callback function that provides the [file] of the signature
/// plus optional [author] and [position] metadata
typedef SignatureCallback = void Function(
    File? file, {
    String? author,
    String? position,
    });

class CustomSignaturePad extends StatefulWidget {
  /// The callback that fires whenever the user saves a signature.
  /// It provides the [File] plus optional metadata fields.
  final SignatureCallback onSignatureCaptured;

  /// If there's an existing signature file path, you can show it as a background.
  final String? initialSignaturePath;

  /// Optional initial metadata (if you want to show it in the text fields).
  final String? signatureAuthor;
  final String? signaturePosition;

  const CustomSignaturePad({
    Key? key,
    required this.onSignatureCaptured,
    this.initialSignaturePath,
    this.signatureAuthor,
    this.signaturePosition,
  }) : super(key: key);

  @override
  CustomSignaturePadState createState() => CustomSignaturePadState();
}

class CustomSignaturePadState extends State<CustomSignaturePad> {
  List<List<Offset>> _strokes = <List<Offset>>[];
  List<Offset>? _currentStroke;
  bool _hasSignature = false;

  /// Controllers for user-editable metadata
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    // Set the initial author/position text if provided
    if (widget.signatureAuthor != null) {
      _authorController.text = widget.signatureAuthor!;
    }
    if (widget.signaturePosition != null) {
      _positionController.text = widget.signaturePosition!;
    }

    // If there's an existing signature file path, flag that we already have a signature
    if (widget.initialSignaturePath != null) {
      _hasSignature = true;
    }
  }

  @override
  void dispose() {
    _authorController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === Signature drawing area ===
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              // If there's an existing signature image, show it
              if (widget.initialSignaturePath != null && _hasSignature)
                Center(
                  child: Image.file(
                    File(widget.initialSignaturePath!),
                    fit: BoxFit.contain,
                  ),
                ),

              // Otherwise, show the signature pad for drawing
              if (widget.initialSignaturePath == null || !_hasSignature)
                GestureDetector(
                  onPanDown: (details) {
                    setState(() {
                      _currentStroke = [details.localPosition];
                      _strokes.add(_currentStroke!);
                    });
                  },
                  onPanUpdate: (details) {
                    setState(() {
                      _currentStroke?.add(details.localPosition);
                      _strokes.last = List.from(_currentStroke!);
                    });
                  },
                  onPanEnd: (details) {
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
            ],
          ),
        ),

        const SizedBox(height: 16),

        // === Optional text fields for signature metadata (author/position) ===
        TextField(
          controller: _authorController,
          decoration: const InputDecoration(
            labelText: 'Signature Author',
            hintText: 'Enter the signer’s name',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _positionController,
          decoration: const InputDecoration(
            labelText: 'Signature Position',
            hintText: 'e.g. Manager, Client, or Form Signature',
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        const SizedBox(height: 16),

        // === Buttons ===
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _clearSignature,
              icon: const Icon(Icons.clear, color: Colors.red),
              label: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _saveSignature,
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
    );
  }

  void _clearSignature() {
    setState(() {
      _strokes = <List<Offset>>[];
      _currentStroke = null;
      _hasSignature = false;
      // Notify parent that there's no valid signature now
      widget.onSignatureCaptured(null);
    });
  }

  Future<void> _saveSignature() async {
    // If we have no strokes and no initial signature, user hasn’t drawn anything yet.
    if (_strokes.isEmpty && widget.initialSignaturePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw a signature first')),
      );
      return;
    }

    // If the user left the author field blank, optionally warn them.
    // (Remove this check if not required in your flow)
    if (_authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the name of the signer')),
      );
      return;
    }

    try {
      // If there's an existing signature path and we haven't cleared/drawn over it,
      // just return that existing file.
      if (widget.initialSignaturePath != null && _hasSignature) {
        widget.onSignatureCaptured(
          File(widget.initialSignaturePath!),
          author: _authorController.text.trim(),
          position: _positionController.text.trim(),
        );
        return;
      }

      // Otherwise, create a new signature image from the user's drawing
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // For final image dimensions, tweak as needed
      const Size size = Size(400, 200);

      // Fill the background with white
      final Paint paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

      // Draw the signature lines in black
      paint
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.0;

      for (final List<Offset> stroke in _strokes) {
        for (int i = 0; i < stroke.length - 1; i++) {
          canvas.drawLine(stroke[i], stroke[i + 1], paint);
        }
      }

      // Wrap up the drawing into a Picture
      final picture = recorder.endRecording();

      // Convert that Picture to an Image
      final ui.Image img = await picture.toImage(
        size.width.toInt(),
        size.height.toInt(),
      );

      // Convert to PNG bytes
      final ByteData? pngBytes = await img.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final buffer = pngBytes!.buffer.asUint8List();

      // Save to a temporary file
      final tempDir = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${tempDir.path}/signature_$timestamp.png');
      await file.writeAsBytes(buffer);

      // Notify the parent widget with the newly created signature file + metadata
      widget.onSignatureCaptured(
        file,
        author: _authorController.text.trim(),
        position: _positionController.text.trim(),
      );

      setState(() {
        _hasSignature = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signature saved successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving signature: $e')),
      );
    }
  }
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;

  SignaturePainter({required this.strokes});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    for (final stroke in strokes) {
      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}