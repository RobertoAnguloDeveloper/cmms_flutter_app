import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:universal_html/html.dart' as universal_html;

import '../../../services/api_session_client_services/ApiResponseHandler.dart';
import '../../../services/api_session_client_services/Http.dart';
import '../../../services/api_session_client_services/SessionManager.dart';

class PdfExportDialog extends StatefulWidget {
  final int submissionId;

  const PdfExportDialog({
    Key? key,
    required this.submissionId,
  }) : super(key: key);

  @override
  _PdfExportDialogState createState() => _PdfExportDialogState();
}

class _PdfExportDialogState extends State<PdfExportDialog> {
  final _formKey = GlobalKey<FormState>();

  // Image for header
  XFile? _headerImage;

  // Form fields
  double _headerOpacity = 100;
  double _headerSize = 20;
  String _headerAlignment = 'left';
  double _signaturesSize = 100;
  String _signaturesAlignment = 'horizontal';
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _errorMessage;

  final List<String> _alignmentOptions = ['left', 'center', 'right'];
  final List<String> _signatureAlignmentOptions = ['vertical', 'horizontal'];

  @override
  void initState() {
    super.initState();
    // Load saved preferences when dialog opens
    _loadSavedPreferences();
  }

  Future<void> _loadSavedPreferences() async {
    try {
      final prefs = await SessionManager.getPdfExportPreferences();

      if (mounted) {
        setState(() {
          _headerOpacity = prefs['headerOpacity'];
          _headerSize = prefs['headerSize'];
          _headerAlignment = prefs['headerAlignment'];
          _signaturesSize = prefs['signaturesSize'];
          _signaturesAlignment = prefs['signaturesAlignment'];

          // Load saved image if it exists
          String? savedImagePath = prefs['headerImagePath'];
          if (savedImagePath != null) {
            // Add this check to ensure the file exists
            if (File(savedImagePath).existsSync()) {
              _headerImage = XFile(savedImagePath);
            } else {
              print('Saved image file not found: $savedImagePath');
              // Don't set _headerImage if file doesn't exist
            }
          }

          _isInitialized = true;
        });
      }
    } catch (e) {
      print('Error loading PDF preferences: $e');
      // Continue with default values
      if (mounted) {
        setState(() {
          _isInitialized = true; // Mark as initialized even on error
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _headerImage = image;
      });

      // Save the new image path to preferences
      await SessionManager.savePdfExportPreferences(
        headerOpacity: _headerOpacity,
        headerSize: _headerSize,
        headerAlignment: _headerAlignment,
        signaturesSize: _signaturesSize,
        signaturesAlignment: _signaturesAlignment,
        headerImagePath: image.path,
      );
    }
  }

  Future<void> _generatePdf() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      // User-friendly validation
      if (_headerImage == null) {
        setState(() {
          _errorMessage = 'Please select a header image';
        });
        return;
      }

      // Save current preferences before generating PDF
      await SessionManager.savePdfExportPreferences(
        headerOpacity: _headerOpacity,
        headerSize: _headerSize,
        headerAlignment: _headerAlignment,
        signaturesSize: _signaturesSize,
        signaturesAlignment: _signaturesAlignment,
        headerImagePath: _headerImage!.path,
      );

      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      try {
        final token = await SessionManager.getToken();
        final uri = Uri.parse('${Http().baseUrl}/api/export_submissions/${widget.submissionId}/pdf/logo');

        // Create multipart request
        var request = http.MultipartRequest('POST', uri);

        // Add authorization header
        request.headers['Authorization'] = 'Bearer $token';

        // Add form fields
        request.fields['header_opacity'] = _headerOpacity.toString();
        request.fields['header_size'] = _headerSize.toString();
        request.fields['header_alignment'] = _headerAlignment;
        request.fields['signatures_size'] = _signaturesSize.toString();
        request.fields['signatures_alignment'] = _signaturesAlignment;

        // Add header image
        final bytes = await File(_headerImage!.path).readAsBytes();
        final filename = _headerImage!.path.split('/').last;
        request.files.add(http.MultipartFile.fromBytes(
          'header_image',
          bytes,
          filename: filename,
        ));

        // Send request
        final response = await request.send();
        final responseBytes = await response.stream.toBytes();

        if (response.statusCode == 200) {
          // Success - handle PDF viewing
          if (mounted) {
            Navigator.of(context).pop(true); // Close dialog with success result

            if (kIsWeb) {
              // For web, use universal_html to open/download PDF
              _openPdfInBrowser(responseBytes);
            } else {
              // For mobile, save and open PDF
              final directory = await getApplicationDocumentsDirectory();
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final filePath = '${directory.path}/submission_${widget.submissionId}_$timestamp.pdf';

              await File(filePath).writeAsBytes(responseBytes);

              // Show download success dialog with options
              if (context.mounted) {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('PDF Generated Successfully'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.picture_as_pdf, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text('Your PDF has been generated successfully.'),
                        const SizedBox(height: 8),
                        Text(
                          'Saved to: $filePath',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Close'),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open PDF'),
                        onPressed: () {
                          Navigator.pop(ctx);
                          OpenFile.open(filePath).then((result) {
                            if (result.type != ResultType.done && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Could not open the PDF file')),
                              );
                            }
                          });
                        },
                      ),
                    ],
                  ),
                );
              }
            }
          }
        } else if (response.statusCode == 401) {
          if (mounted) {
            // For authentication errors, we can be more specific
            String responseBody = String.fromCharCodes(responseBytes);
            try {
              Map<String, dynamic> jsonResponse = {};
              if (responseBody.isNotEmpty) {
                jsonResponse = {'message': 'Session expired'};
              }
              await ApiResponseHandler.handleExpiredToken(context, jsonResponse);
            } catch (e) {
              print('Error parsing JSON during auth error: $e');
            }
            setState(() {
              _isLoading = false;
              _errorMessage = 'Your session has expired. Please log in again.';
            });
          }
        } else {
          // For other HTTP errors, log details but show generic message
          String errorMsg = String.fromCharCodes(responseBytes);
          print('PDF Generation Error (HTTP ${response.statusCode}): $errorMsg');

          setState(() {
            _isLoading = false;
            _errorMessage = 'Unable to generate PDF. Please try again later.';
          });
        }
      } catch (e) {
        // For any other exceptions, log details but show generic message
        print('Exception during PDF generation: $e');

        setState(() {
          _isLoading = false;
          _errorMessage = 'Unable to generate PDF. Please try again later.';
        });
      }
    }
  }

  void _openPdfInBrowser(Uint8List bytes) {
    try {
      final blob = universal_html.Blob([bytes], 'application/pdf');
      final url = universal_html.Url.createObjectUrlFromBlob(blob);

      // Use window.open to open PDF in a new tab
      universal_html.window.open(url, '_blank');

      // Also provide a download option
      final downloadTimestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'submission_${widget.submissionId}_$downloadTimestamp.pdf';

      // Create a hidden download link
      final anchor = universal_html.AnchorElement(href: url)
        ..download = filename
        ..style.display = 'none';

      // Add to document, trigger click, and remove
      universal_html.document.body?.children.add(anchor);

      // Show a confirmation dialog for download
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF opened in new tab'),
            action: SnackBarAction(
              label: 'Download',
              onPressed: () {
                anchor.click();
              },
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }

      // Clean up after a delay
      Future.delayed(const Duration(minutes: 1), () {
        if (universal_html.document.body?.contains(anchor) ?? false) {
          anchor.remove();
        }
        universal_html.Url.revokeObjectUrl(url);
      });
    } catch (e) {
      print('Error opening PDF in browser: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error opening PDF')),
        );
      }
    }
  }

  Widget _buildHeaderPreview() {
    if (_headerImage == null) {
      return Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
            SizedBox(height: 8),
            Text('Click to select header image'),
          ],
        ),
      );
    }

    // Convert opacity from percentage (0-100) to decimal (0.0-1.0)
    final double opacity = _headerOpacity / 100;

    // Get container width to calculate maximum image size
    final double containerWidth = MediaQuery.of(context).size.width - 40; // accounting for padding

    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white, // White background to simulate PDF
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Container to simulate PDF page with light grey guidelines
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
            child: Center(
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.description, size: 64, color: Colors.grey),
              ),
            ),
          ),

          // Header image with applied settings
          Align(
            alignment: _getAlignmentFromString(_headerAlignment),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Calculate image width based on container width and header size percentage
                final double maxWidth = constraints.maxWidth;
                final double imageWidth = maxWidth * (_headerSize / 100);

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    width: imageWidth,
                    child: Opacity(
                      opacity: opacity,
                      child: Image.file(
                        File(_headerImage!.path),
                        fit: BoxFit.fitWidth, // Make sure image scales properly
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Information overlay
          Positioned(
            bottom: 4,
            right: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.preview, size: 14, color: Colors.white),
                  SizedBox(width: 4),
                  Text(
                    'Preview',
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ],
              ),
            ),
          ),

          // Header size indicator
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Size: ${_headerSize.round()}%',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),

          // Opacity indicator
          Positioned(
            top: 4,
            right: 4,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Opacity: ${_headerOpacity.round()}%',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }

// Helper method to convert string alignment to Flutter's Alignment
  Alignment _getAlignmentFromString(String align) {
    switch (align) {
      case 'left':
        return Alignment.topLeft;
      case 'center':
        return Alignment.topCenter;
      case 'right':
        return Alignment.topRight;
      default:
        return Alignment.topCenter;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return Dialog(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading preferences...'),
            ],
          ),
        ),
      );
    }

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Export to PDF',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                // Header Image Section
                Row(
                  children: [
                    const Text(
                      'Header Image',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    if (_headerImage != null)
                      TextButton.icon(
                        icon: Icon(Icons.refresh, size: 18),
                        label: Text('Change'),
                        onPressed: _pickImage,
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Image preview with live updates
                InkWell(
                  onTap: _headerImage == null ? _pickImage : null,
                  child: _buildHeaderPreview(),
                ),

                const SizedBox(height: 16),

                // Header Opacity with label showing percentage
                Row(
                  children: [
                    const Text('Header Opacity'),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_headerOpacity.round()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _headerOpacity,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.blue.shade100,
                  onChanged: (double value) {
                    setState(() {
                      _headerOpacity = value;
                    });
                  },
                ),

                // Header Size with label showing percentage
                Row(
                  children: [
                    const Text('Header Size'),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_headerSize.round()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _headerSize,
                  min: 1,
                  max: 100,
                  divisions: 100,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.blue.shade100,
                  onChanged: (double value) {
                    setState(() {
                      _headerSize = value;
                    });
                  },
                ),

                // Header Alignment
                const Text('Header Alignment'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: _headerAlignment,
                  items: _alignmentOptions.map((String alignment) {
                    return DropdownMenuItem<String>(
                      value: alignment,
                      child: Text(alignment[0].toUpperCase() + alignment.substring(1)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _headerAlignment = newValue;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Signatures Section
                const Text(
                  'Signatures',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                // Signatures Size
                Row(
                  children: [
                    const Text('Signatures Size'),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${_signaturesSize.round()}%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: _signaturesSize,
                  min: 1,
                  max: 200,
                  divisions: 200,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.blue.shade100,
                  onChanged: (double value) {
                    setState(() {
                      _signaturesSize = value;
                    });
                  },
                ),

                // Signatures Alignment
                const Text('Signatures Alignment'),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  value: _signaturesAlignment,
                  items: _signatureAlignmentOptions.map((String alignment) {
                    return DropdownMenuItem<String>(
                      value: alignment,
                      child: Text(alignment[0].toUpperCase() + alignment.substring(1)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _signaturesAlignment = newValue;
                      });
                    }
                  },
                ),

                // Error message
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.red[300]!),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[700]),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _generatePdf,
                      icon: _isLoading
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(Icons.download, color: Colors.white),
                      label: Text(_isLoading ? 'Generating...' : 'Generate PDF'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}