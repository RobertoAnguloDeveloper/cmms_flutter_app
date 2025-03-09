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
  String? _errorMessage;

  final List<String> _alignmentOptions = ['left', 'center', 'right'];
  final List<String> _signatureAlignmentOptions = ['vertical', 'horizontal'];

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _headerImage = image;
      });
    }
  }

  Future<void> _generatePdf() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_headerImage == null) {
        setState(() {
          _errorMessage = 'Please select a header image';
        });
        return;
      }

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
                                SnackBar(content: Text('Error opening PDF: ${result.message}')),
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
            String responseBody = String.fromCharCodes(responseBytes);
            try {
              Map<String, dynamic> jsonResponse = {};
              if (responseBody.isNotEmpty) {
                jsonResponse = {'message': 'Session expired'};
              }
              await ApiResponseHandler.handleExpiredToken(context, jsonResponse);
            } catch (e) {
              print('Error parsing JSON: $e');
            }
            setState(() {
              _isLoading = false;
              _errorMessage = 'Session expired. Please log in again.';
            });
          }
        } else {
          String errorMsg = String.fromCharCodes(responseBytes);
          try {
            final jsonResponse = {'message': errorMsg};
            errorMsg = jsonResponse['message'] ?? 'Failed to generate PDF';
          } catch (e) {
            // Use the raw response if not valid JSON
          }

          setState(() {
            _isLoading = false;
            _errorMessage = 'Error: $errorMsg';
          });
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Error: $e';
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
          SnackBar(content: Text('Error opening PDF: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
                const Text(
                  'Header Image',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),

                // Image picker
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[400]!),
                    ),
                    child: _headerImage != null
                        ? ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(_headerImage!.path),
                        fit: BoxFit.cover,
                      ),
                    )
                        : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Click to select header image'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header Opacity
                const Text('Header Opacity (%)'),
                Slider(
                  value: _headerOpacity,
                  min: 0,
                  max: 100,
                  divisions: 100,
                  label: _headerOpacity.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _headerOpacity = value;
                    });
                  },
                ),

                // Header Size
                const Text('Header Size (%)'),
                Slider(
                  value: _headerSize,
                  min: 1,
                  max: 100,
                  divisions: 100,
                  label: _headerSize.round().toString(),
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
                const Text('Signatures Size (%)'),
                Slider(
                  value: _signaturesSize,
                  min: 1,
                  max: 200,
                  divisions: 200,
                  label: _signaturesSize.round().toString(),
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