import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  /// Optional initial position/title from question title.
  final String? signaturePosition;

  /// The question title that will be used as the signature position
  final String questionTitle;

  /// Whether to show the position field (defaults to false)
  final bool showPositionField;

  const CustomSignaturePad({
    Key? key,
    required this.onSignatureCaptured,
    this.initialSignaturePath,
    this.signatureAuthor,
    this.signaturePosition,
    required this.questionTitle,
    this.showPositionField = false,
  }) : super(key: key);

  @override
  CustomSignaturePadState createState() => CustomSignaturePadState();
}

class CustomSignaturePadState extends State<CustomSignaturePad> {
  List<List<Offset>> _strokes = <List<Offset>>[];
  List<Offset>? _currentStroke;
  bool _hasSignature = false;
  bool _isProcessing = false;
  bool _isExpanded = false;

  /// Controllers for user-editable metadata
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _positionController = TextEditingController();

  // Key for the drawing area used for capturing
  final GlobalKey _signatureKey = GlobalKey();

  // Overlay entry for expanded signature view
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();

    // Set the initial author text if provided
    if (widget.signatureAuthor != null) {
      _authorController.text = widget.signatureAuthor!;
    }

    // Set the position to the question title or passed position if provided
    if (widget.signaturePosition != null && widget.signaturePosition!.isNotEmpty) {
      _positionController.text = widget.signaturePosition!;
    } else if (widget.questionTitle.isNotEmpty) {
      _positionController.text = widget.questionTitle;
    } else {
      _positionController.text = "Form Signature"; // Default fallback
    }

    // If there's an existing signature file path, flag that we already have a signature
    if (widget.initialSignaturePath != null) {
      _hasSignature = true;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _authorController.dispose();
    _positionController.dispose();
    super.dispose();
  }

  // Remove overlay if it exists
  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // === Signature drawing area ===
        _isProcessing
            ? Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        )
            : GestureDetector(
          onTap: _showExpandedSignatureView,
          child: RepaintBoundary(
            key: _signatureKey,
            child: Container(
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

                  // Otherwise, show the signature pad for drawing in non-expanded view
                  if ((widget.initialSignaturePath == null || !_hasSignature) && !_isExpanded)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: CustomPaint(
                        painter: SignaturePainter(strokes: _strokes),
                        size: Size.infinite,
                      ),
                    ),

                  // Add an instruction overlay for better UX
                  if (!_hasSignature && _strokes.isEmpty)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.touch_app, size: 32, color: Colors.grey[400]),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to sign',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Signature will be limited to white area',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Signature Author field (always shown)
        TextField(
          controller: _authorController,
          decoration: const InputDecoration(
            labelText: 'Signature Author',
            hintText: "Enter the signer's name",
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),

        // Only show position field if explicitly enabled (hidden by default)
        if (widget.showPositionField) ...[
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
        ],

        const SizedBox(height: 16),

        // === Buttons ===
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton.icon(
              onPressed: _isProcessing ? null : _clearSignature,
              icon: const Icon(Icons.clear, color: Colors.red),
              label: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
            ElevatedButton.icon(
              onPressed: _isProcessing
                  ? null
                  : (_strokes.isEmpty && widget.initialSignaturePath == null)
                  ? null
                  : _saveSignature,
              icon: _isProcessing
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
                  : const Icon(Icons.save),
              label: Text(_isProcessing ? 'Processing...' : 'Save Signature'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showExpandedSignatureView() {
    // Lock orientation to portrait for better signing experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Remove existing overlay if there is one
    _removeOverlay();

    // Get the original signature pad size to maintain aspect ratio
    final RenderBox renderBox = _signatureKey.currentContext?.findRenderObject() as RenderBox;
    final originalSize = renderBox.size;
    final originalAspectRatio = originalSize.width / originalSize.height;

    // Create a new overlay entry
    _overlayEntry = OverlayEntry(
      builder: (context) {
        // Calculate dimensions for the expanded signature area
        final screenSize = MediaQuery.of(context).size;
        final availableWidth = screenSize.width * 0.9;
        final availableHeight = screenSize.height * 0.7;

        // Calculate the signature area size while maintaining the original aspect ratio
        double signatureWidth = availableWidth;
        double signatureHeight = availableWidth / originalAspectRatio;

        // Adjust if the calculated height exceeds available height
        if (signatureHeight > availableHeight * 0.8) {
          signatureHeight = availableHeight * 0.8;
          signatureWidth = signatureHeight * originalAspectRatio;
        }

        return Material(
          color: Colors.black54,
          child: Stack(
            children: [
              // Full screen touch detector to close when clicking outside
              Positioned.fill(
                child: GestureDetector(
                  onTap: () {
                    _hideExpandedSignatureView();
                  },
                  behavior: HitTestBehavior.opaque,
                ),
              ),

              // Centered signature pad
              Center(
                child: Container(
                  width: availableWidth,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          color: Colors.blue,
                          child: Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Sign',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.clear, color: Colors.white),
                                onPressed: _clearExpandedSignature,
                                tooltip: 'Clear signature',
                              ),
                              IconButton(
                                icon: const Icon(Icons.check, color: Colors.white),
                                onPressed: _saveExpandedSignature,
                                tooltip: 'Confirm signature',
                              ),
                            ],
                          ),
                        ),

                        // Signature drawing area with maintained aspect ratio
                        Stack(
                          children: [
                            // Visible boundary indicator
                            Container(
                              width: signatureWidth,
                              height: signatureHeight,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.blue.shade300,
                                  width: 2.0,
                                ),
                              ),
                            ),

                            // Actual drawing area - exactly matches the visible area
                            SizedBox(
                              width: signatureWidth,
                              height: signatureHeight,
                              child: ClipRect(
                                child: Listener(
                                  behavior: HitTestBehavior.opaque,
                                  onPointerDown: (PointerDownEvent event) {
                                    // Extra strict bounds checking
                                    final padding = 2.0; // Account for the border width
                                    if (event.localPosition.dx >= padding &&
                                        event.localPosition.dx <= signatureWidth - padding &&
                                        event.localPosition.dy >= padding &&
                                        event.localPosition.dy <= signatureHeight - padding) {

                                      // Calculate the scale factor between original and expanded views
                                      final double scaleX = originalSize.width / signatureWidth;
                                      final double scaleY = originalSize.height / signatureHeight;

                                      // Scale the point to match the original coordinates
                                      final scaledPosition = Offset(
                                        event.localPosition.dx * scaleX,
                                        event.localPosition.dy * scaleY,
                                      );

                                      setState(() {
                                        _currentStroke = [scaledPosition];
                                        _strokes.add(_currentStroke!);
                                        _overlayEntry?.markNeedsBuild();
                                      });
                                    }
                                  },
                                  onPointerMove: (PointerMoveEvent event) {
                                    // Only process if we have a current stroke
                                    if (_currentStroke != null) {
                                      // Calculate exact border boundaries with a small buffer
                                      final double padding = 2.0; // Account for the border width

                                      // Strict boundary enforcement - clamp coordinates to stay within
                                      // the visible signature area
                                      double clampedX = event.localPosition.dx;
                                      double clampedY = event.localPosition.dy;

                                      // Horizontal constraint
                                      if (clampedX < padding) {
                                        clampedX = padding;
                                      } else if (clampedX > signatureWidth - padding) {
                                        clampedX = signatureWidth - padding;
                                      }

                                      // Vertical constraint
                                      if (clampedY < padding) {
                                        clampedY = padding;
                                      } else if (clampedY > signatureHeight - padding) {
                                        clampedY = signatureHeight - padding;
                                      }

                                      // Apply scaling to maintain proportion with original pad
                                      final double scaleX = originalSize.width / signatureWidth;
                                      final double scaleY = originalSize.height / signatureHeight;

                                      final scaledPosition = Offset(
                                        clampedX * scaleX,
                                        clampedY * scaleY,
                                      );

                                      setState(() {
                                        _currentStroke?.add(scaledPosition);
                                        _strokes.last = List.from(_currentStroke!);
                                        _overlayEntry?.markNeedsBuild();
                                      });
                                    }
                                  },
                                  onPointerUp: (PointerUpEvent event) {
                                    _currentStroke = null;
                                  },
                                  child: CustomPaint(
                                    size: Size(signatureWidth, signatureHeight),
                                    painter: SignaturePainter(
                                      strokes: _strokes,
                                      scaleX: signatureWidth / originalSize.width,
                                      scaleY: signatureHeight / originalSize.height,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Instructions
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          color: Colors.grey[100],
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.blue, size: 20),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sign with your finger or stylus. Tap outside to cancel.',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );

    // Insert the overlay
    Overlay.of(context).insert(_overlayEntry!);

    // Update state
    setState(() {
      _isExpanded = true;
    });
  }

  void _hideExpandedSignatureView() {
    _removeOverlay();
    setState(() {
      _isExpanded = false;
    });

    // Reset orientation settings
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Refresh the main widget to show the current state of the signature
    setState(() {});
  }

  void _clearExpandedSignature() {
    setState(() {
      _strokes = <List<Offset>>[];
      _currentStroke = null;
      _hasSignature = false;

      // Rebuild overlay
      _overlayEntry?.markNeedsBuild();

      // Notify parent that there's no valid signature now
      widget.onSignatureCaptured(null);
    });
  }

  void _saveExpandedSignature() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, dibuja una firma primero')),
      );
      return;
    }

    // Hide expanded view first
    _hideExpandedSignatureView();

    // Then save the signature
    await _saveSignature();
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
    // If we have no strokes and no initial signature, user hasn't drawn anything yet.
    if (_strokes.isEmpty && widget.initialSignaturePath == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please draw a signature first')),
      );
      return;
    }

    // If the user left the author field blank, optionally warn them.
    if (_authorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the name of the signer')),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // If there's an existing signature path and we haven't cleared/drawn over it,
      // just return that existing file.
      if (widget.initialSignaturePath != null && _hasSignature) {
        widget.onSignatureCaptured(
          File(widget.initialSignaturePath!),
          author: _authorController.text.trim(),
          position: _positionController.text.trim(),
        );
        setState(() {
          _isProcessing = false;
        });
        return;
      }

      // Get original signature pad size
      final RenderBox renderBox = _signatureKey.currentContext?.findRenderObject() as RenderBox;
      final originalSize = renderBox.size;

      // Use exact dimensions of the signature pad for the image
      final double width = originalSize.width;
      final double height = originalSize.height;

      // Create a new signature image
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      // Fill the background with white
      final Paint paint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      canvas.drawRect(Rect.fromLTWH(0, 0, width, height), paint);

      // Draw the signature lines in black
      paint
        ..color = Colors.black
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 3.0;

      // Draw all strokes - no scaling needed as we already stored them in the original coordinate space
      for (final List<Offset> stroke in _strokes) {
        for (int i = 0; i < stroke.length - 1; i++) {
          if (stroke[i] != null && stroke[i+1] != null) {
            canvas.drawLine(stroke[i], stroke[i+1], paint);
          }
        }
      }

      // Wrap up the drawing into a Picture
      final picture = recorder.endRecording();

      // Convert that Picture to an Image with the exact dimensions of the signature pad
      final ui.Image img = await picture.toImage(
        width.toInt(),
        height.toInt(),
      );

      // Convert to PNG bytes
      final ByteData? pngBytes = await img.toByteData(
        format: ui.ImageByteFormat.png,
      );

      if (pngBytes == null) {
        throw Exception("Failed to convert signature to image");
      }

      final buffer = pngBytes.buffer.asUint8List();

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
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  /// Calculate the bounding box of the signature
  Rect? _calculateSignatureBounds() {
    if (_strokes.isEmpty) {
      return null;
    }

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    // Find the min and max points to determine the bounding box
    for (final stroke in _strokes) {
      for (final point in stroke) {
        minX = point.dx < minX ? point.dx : minX;
        minY = point.dy < minY ? point.dy : minY;
        maxX = point.dx > maxX ? point.dx : maxX;
        maxY = point.dy > maxY ? point.dy : maxY;
      }
    }

    // Return the bounding rectangle
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 0.5;

    // Draw horizontal grid lines
    const double gridSpacing = 20.0;
    for (double y = gridSpacing; y < size.height; y += gridSpacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw vertical grid lines
    for (double x = gridSpacing; x < size.width; x += gridSpacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SignaturePainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final double scaleX;
  final double scaleY;

  SignaturePainter({
    required this.strokes,
    this.scaleX = 1.0,
    this.scaleY = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3.0;

    // Apply scale transform to ensure the signature looks
    // the same in both the small and expanded views
    canvas.scale(scaleX, scaleY);

    for (final stroke in strokes) {
      if (stroke.length < 2) continue; // Skip strokes with only one point

      for (int i = 0; i < stroke.length - 1; i++) {
        canvas.drawLine(stroke[i], stroke[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(SignaturePainter oldDelegate) => true;
}