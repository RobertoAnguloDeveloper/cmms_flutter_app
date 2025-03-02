// 📂 lib/services/api_model_services/api_form_services/attachment_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:photo_view/photo_view.dart';
import 'package:open_filex/open_filex.dart';
import 'package:universal_html/html.dart' as universal_html;

import '../../../models/attachment/attachment.dart';
import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class AttachmentException implements Exception {
  final String message;
  final int? statusCode;

  AttachmentException(this.message, [this.statusCode]);

  @override
  String toString() => statusCode != null
      ? 'AttachmentException: $message (Status: $statusCode)'
      : 'AttachmentException: $message';
}

class AttachmentService {
  static const int maxFileSize = 16 * 1024 * 1024; // 16MB
  static const Set<String> allowedExtensions = {
    'pdf',
    'png',
    'jpg',
    'jpeg',
    'gif',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'txt'
  };

  final Http _http = Http();
  final _cache = DefaultCacheManager();
  late final Dio _dio;

  AttachmentService() {
    _dio = Dio(BaseOptions(
      baseUrl: _http.baseUrl,
      connectTimeout: const Duration(seconds: 60),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(seconds: 60),
      validateStatus: (status) => status != null && status < 500,
      responseType: ResponseType.bytes,
    ));

    // Add retry interceptor for better reliability
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: print,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 2),
          Duration(seconds: 4),
          Duration(seconds: 8),
        ],
      ),
    );

    // Add authorization interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization header to every request
          final token = await SessionManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          print('Dio error: ${error.message}');
          print('Response: ${error.response?.data}');
          print('Status code: ${error.response?.statusCode}');
          return handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: false, // Don't log binary responses
        error: true,
        requestHeader: true,
        responseHeader: true,
      ));
    }
  }

  // Create single attachment
  Future<Map<String, dynamic>> createAttachment(
    BuildContext context,
    int formSubmissionId,
    File file,
    bool isSignature,
  ) async {
    try {
      // Validate file
      final validationError = _validateFile(file);
      if (validationError != null) {
        throw Exception(validationError);
      }

      String? token = await SessionManager.getToken();
      var uri = Uri.parse('${_http.baseUrl}/api/attachments');

      // Create multipart request
      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['form_submission_id'] = formSubmissionId.toString()
        ..fields['is_signature'] = isSignature.toString();

      // Add file with content type
      final mimeType = _getMimeType(file.path);
      final stream = http.ByteStream(file.openRead());
      final length = await file.length();

      var multipartFile = http.MultipartFile(
        'file',
        stream,
        length,
        filename: path.basename(file.path),
        contentType: MediaType.parse(mimeType),
      );
      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw AttachmentException('Authentication error', 401);
      } else {
        final responseData = json.decode(response.body);
        throw AttachmentException(
          'Error creating attachment: ${responseData['message'] ?? response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AttachmentException) rethrow;
      throw AttachmentException('Exception while creating attachment: $e');
    }
  }

  // Bulk create attachments
  Future<Map<String, dynamic>> bulkCreateAttachments(
    BuildContext context,
    int formSubmissionId,
    List<Map<String, dynamic>> filesData,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      var uri = Uri.parse('${_http.baseUrl}/api/attachments/bulk');

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['form_submission_id'] = formSubmissionId.toString();

      for (var i = 0; i < filesData.length; i++) {
        var fileData = filesData[i];
        File file = fileData['file'];
        bool isSignature = fileData['is_signature'] ?? false;

        final validationError = _validateFile(file);
        if (validationError != null) {
          throw AttachmentException('File ${i + 1}: $validationError');
        }

        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final mimeType = _getMimeType(file.path);

        request.files.add(
          http.MultipartFile(
            'file$i',
            stream,
            length,
            filename: path.basename(file.path),
            contentType: MediaType.parse(mimeType),
          ),
        );
        request.fields['is_signature$i'] = isSignature.toString();
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return responseData;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw AttachmentException('Authentication error', 401);
      } else {
        final responseData = json.decode(response.body);
        throw AttachmentException(
          'Error creating attachments: ${responseData['message'] ?? response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AttachmentException) rethrow;
      throw AttachmentException('Exception while creating attachments: $e');
    }
  }

  // Fetch attachments with filters
  Future<Map<String, dynamic>> fetchAttachments(
    BuildContext context, {
    Map<String, dynamic>? filters,
  }) async {
    try {
      String? token = await SessionManager.getToken();

      var uri = Uri.parse('${_http.baseUrl}/api/attachments');
      if (filters != null && filters.isNotEmpty) {
        uri = uri.replace(
            queryParameters:
                filters.map((key, value) => MapEntry(key, value.toString())));
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw AttachmentException('Authentication error', 401);
      } else {
        final responseData = json.decode(response.body);
        throw AttachmentException(
          'Error fetching attachments: ${responseData['message'] ?? response.statusCode}',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AttachmentException) rethrow;
      throw AttachmentException('Exception while fetching attachments: $e');
    }
  }

  // Get attachments for a submission
  Future<List<Attachment>> getSubmissionAttachments(
    BuildContext context,
    int submissionId,
  ) async {
    try {
      final response = await _dio.get<dynamic>(
        '/api/attachments/submission/$submissionId',
        options: Options(responseType: ResponseType.json),
      );

      if (response.statusCode == 200) {
        final data = response.data as Map<String, dynamic>;
        final List<dynamic> attachmentsList = data['attachments'] ?? [];

        return attachmentsList
            .map((attachmentJson) => Attachment.fromJson(attachmentJson))
            .toList();
      } else if (response.statusCode == 401) {
        if (context.mounted) {
          await ApiResponseHandler.handleExpiredToken(
              context, response.data as Map<String, dynamic>);
        }
        throw AttachmentException('Authentication error', 401);
      } else {
        throw AttachmentException(
          'Failed to fetch submission attachments: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AttachmentException) rethrow;
      throw AttachmentException('Error fetching submission attachments: $e');
    }
  }

  /// Opens an attachment for viewing
  Future<void> openAttachment(BuildContext context, int attachmentId) async {
    print('🔍 Attempting to open attachment: $attachmentId');

    // Show loading dialog immediately
    final loadingDialog = showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return const AlertDialog(
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Loading attachment...'),
            ],
          ),
        );
      },
    );

    try {
      final token = await SessionManager.getToken();
      print('🔐 Token retrieved: ${token != null}');

      final attachmentUrl = '/api/attachments/$attachmentId';
      print('🌐 Attachment URL: $attachmentUrl');

      // Create a dedicated Dio instance for this download with extended timeout
      final downloadDio = Dio(BaseOptions(
        baseUrl: _http.baseUrl,
        connectTimeout: const Duration(seconds: 90),  // Further increased timeout
        receiveTimeout: const Duration(minutes: 10),  // Significantly extended receive timeout
        sendTimeout: const Duration(seconds: 90),
        responseType: ResponseType.bytes,
      ));

      // Add comprehensive logging interceptor
      downloadDio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) {
          print('📤 Download Request: ${options.path}');
          options.headers['Authorization'] = 'Bearer $token';
          options.headers['Accept'] = 'image/*, */*';  // Explicitly accept image types
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('📥 Download Response: Status ${response.statusCode}, Data Length: ${response.data?.length}');
          print('Response Headers: ${response.headers}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          print('❌ Download Error Details:');
          print('Message: ${e.message}');
          print('Error Type: ${e.type}');
          print('Response Status Code: ${e.response?.statusCode}');
          print('Response Data: ${e.response?.data}');
          return handler.next(e);
        },
      ));

      final response = await downloadDio.get(
        attachmentUrl,
        options: Options(
          headers: {
            'Accept': 'image/*, */*',
            'Connection': 'keep-alive',
            'Cache-Control': 'no-cache',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print('📊 Download Progress: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      // Close loading dialog
      Navigator.of(context).pop();

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data);
        String contentType = response.headers.value('content-type') ?? 'application/octet-stream';

        print('✅ Successfully downloaded attachment: ${bytes.length} bytes');
        print('📄 Content Type: $contentType');

        // Validate image if it's an image type
        if (contentType.contains('image/')) {
          try {
            // Attempt to decode the image to verify it's a valid image
            final image = await decodeImageFromList(bytes);

            if (context.mounted) {
              _showImageViewer(context, bytes, contentType, attachmentId);
            }
          } catch (e) {
            print('❌ Invalid image file decoding error: $e');
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Unable to display image: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          // Handle non-image files
          if (context.mounted) {
            _showNonImageFileViewer(context, bytes, contentType, attachmentId);
          }
        }
      } else {
        throw Exception('Failed to download attachment. Status: ${response.statusCode}');
      }
    } on DioException catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();

      print('❌ Dio Attachment Download Error Details:');
      print('Message: ${e.message}');
      print('Error Type: ${e.type}');
      print('Response Status Code: ${e.response?.statusCode}');
      print('Response Data: ${e.response?.data}');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: ${e.message}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      Navigator.of(context).pop();

      print('❌ Unexpected Attachment Download Error: $e');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNonImageFileViewer(BuildContext context, Uint8List bytes, String contentType, int attachmentId) {
    print('📄 Showing Non-Image File Viewer');
    print('Content Type: $contentType');
    print('Bytes Length: ${bytes.length}');

    try {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('File Details'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getIconForMimeType(contentType),
                  size: 64,
                  color: _getColorForMimeType(contentType),
                ),
                const SizedBox(height: 16),
                Text('File type: ${contentType.split('/').last}'),
                Text('Size: ${(bytes.length / 1024).toStringAsFixed(2)} KB'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () => _saveAttachment(context, bytes, contentType, attachmentId),
                child: const Text('Download'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      print('❌ Error in _showNonImageFileViewer: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to view file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showImageViewer(BuildContext context, Uint8List bytes, String contentType, int attachmentId) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
                title: const Text('Attachment Preview', style: TextStyle(color: Colors.black)),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.black),
                    onPressed: () => _saveAttachment(context, bytes, contentType, attachmentId),
                  ),
                ],
              ),
              Expanded(
                child: InteractiveViewer(
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('Image loading error: $error');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error, color: Colors.red, size: 50),
                            const SizedBox(height: 16),
                            Text(
                              'Failed to load image',
                              style: TextStyle(color: Colors.red),
                            ),
                            Text(
                              'Error: $error',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Delete attachment
  Future<Map<String, dynamic>> deleteAttachment(
    BuildContext context,
    int attachmentId,
  ) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await _dio.delete(
        '/api/attachments/$attachmentId',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.json,
        ),
      );

      if (response.statusCode == 200) {
        // Clear from cache if exists
        await _cache.removeFile('attachment_$attachmentId');
        return response.data as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        if (context.mounted) {
          await ApiResponseHandler.handleExpiredToken(
              context, response.data as Map<String, dynamic>);
        }
        throw AttachmentException('Authentication error', 401);
      } else {
        throw AttachmentException(
          'Error deleting attachment: ${response.statusCode}',
          response.statusCode,
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      if (e is AttachmentException) rethrow;
      throw AttachmentException('Exception while deleting attachment: $e');
    }
  }

  // Private helper methods

  // Validate file
  String? _validateFile(File file) {
    try {
      final size = file.lengthSync();
      if (size > maxFileSize) {
        return 'File size exceeds maximum limit of ${maxFileSize / (1024 * 1024)}MB';
      }

      final extension =
          path.extension(file.path).toLowerCase().replaceAll('.', '');
      if (!allowedExtensions.contains(extension)) {
        return 'File type not allowed. Allowed types: ${allowedExtensions.join(", ")}';
      }

      return null;
    } catch (e) {
      return 'Error validating file: $e';
    }
  }

  // Get MIME type from file extension
  String _getMimeType(String filepath) {
    final ext = path.extension(filepath).toLowerCase();
    switch (ext) {
      case '.pdf':
        return 'application/pdf';
      case '.png':
        return 'image/png';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.gif':
        return 'image/gif';
      case '.doc':
        return 'application/msword';
      case '.docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls':
        return 'application/vnd.ms-excel';
      case '.xlsx':
        return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  // Get file extension from MIME type
  String _getExtensionFromMime(String mimeType) {
    switch (mimeType) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'application/pdf':
        return 'pdf';
      case 'application/msword':
      case 'application/vnd.openxmlformats-officedocument.wordprocessingml.document':
        return 'docx';
      case 'application/vnd.ms-excel':
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
        return 'xlsx';
      default:
        return 'bin';
    }
  }

  // Show file viewer based on content type
  void _showFileViewer(BuildContext context, Uint8List bytes,
      String contentType, int attachmentId) {
    print('🖼️ Showing File Viewer');
    print('Content Type: $contentType');
    print('Bytes Length: ${bytes.length}');

    try {
      if (contentType.contains('image/')) {
        showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              insetPadding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: IconButton(
                      icon: const Icon(Icons.close, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                    title: const Text('Attachment Preview',
                        style: TextStyle(color: Colors.black)),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.download, color: Colors.black),
                        onPressed: () => _saveAttachment(
                            context, bytes, contentType, attachmentId),
                      ),
                    ],
                  ),
                  // Wrap PhotoView with error handling
                  Expanded(
                    child: PhotoView(
                      imageProvider: MemoryImage(bytes),
                      backgroundDecoration:
                          const BoxDecoration(color: Colors.white),
                      loadingBuilder: (context, event) => const Center(
                        child: CircularProgressIndicator(),
                      ),
                      errorBuilder: (context, error, stackTrace) {
                        print('❌ PhotoView Error: $error');
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error,
                                  color: Colors.red, size: 50),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.red),
                              ),
                              Text(
                                'Error: $error',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      } else {
        // Existing non-image file handling
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('File Details'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getIconForMimeType(contentType),
                    size: 64,
                    color: _getColorForMimeType(contentType),
                  ),
                  const SizedBox(height: 16),
                  Text('File type: ${contentType.split('/').last}'),
                  Text('Size: ${(bytes.length / 1024).toStringAsFixed(2)} KB'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () => _saveAttachment(
                      context, bytes, contentType, attachmentId),
                  child: const Text('Download'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      print('❌ Error in _showFileViewer: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to view attachment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Save attachment to device
  void _saveAttachment(BuildContext context, Uint8List bytes, String contentType, int attachmentId) async {
    try {
      if (kIsWeb) {
        // Web-specific download
        _downloadFileWeb(bytes, _getExtensionFromMime(contentType));
        return;
      }

      // Mobile/Desktop platform file saving
      final directory = await getApplicationDocumentsDirectory();

      // Determine the correct extension based on content type
      String extension = _getExtensionFromMime(contentType);

      // If content type is text/plain, use .txt instead of .bin
      if (contentType.contains('text/plain')) {
        extension = 'txt';
      }

      final fileName = 'attachment_${attachmentId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
      final filePath = '${directory.path}/$fileName';

      print('📁 Attempting to save file:');
      print('Path: $filePath');
      print('File Size: ${bytes.length} bytes');
      print('Content Type: $contentType');
      print('Extension: $extension');

      try {
        final file = File(filePath);
        await file.writeAsBytes(bytes, flush: true);

        print('✅ File saved successfully');

        if (context.mounted) {
          // Automatically try to open the file
          final result = await OpenFilex.open(filePath);

          // Check the result of opening the file
          switch (result.type) {
            case ResultType.done:
              print('File opened successfully');
              break;
            case ResultType.noAppToOpen:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('No app found to open this file type'),
                  action: SnackBarAction(
                    label: 'Save',
                    onPressed: () {
                      // Provide option to just save the file
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('File saved to $filePath'),
                        ),
                      );
                    },
                  ),
                ),
              );
              break;
            case ResultType.permissionDenied:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Permission denied to open file'),
                ),
              );
              break;
            case ResultType.error:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error opening file: ${result.message}'),
                ),
              );
              break;
            case ResultType.fileNotFound:
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('File not found'),
                ),
              );
              break;
          }
        }
      } catch (writeError) {
        print('❌ File write error: $writeError');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving file: $writeError'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Attachment save error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving attachment: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // For web, you'll need to add the universal_html package
  void _downloadFileWeb(Uint8List bytes, String extension) {
    if (!kIsWeb) return;

    try {
      final blob = universal_html.Blob([bytes]);
      final url = universal_html.Url.createObjectUrlFromBlob(blob);
      final anchor = universal_html.AnchorElement(href: url)
        ..setAttribute('download', 'attachment_${DateTime.now().millisecondsSinceEpoch}.$extension');

      universal_html.document.body?.append(anchor);
      anchor.click();
      universal_html.document.body?.children.remove(anchor);
      universal_html.Url.revokeObjectUrl(url);
    } catch (e) {
      print('Web download error: $e');
    }
  }

  // Helper method to get icon for MIME type
  IconData _getIconForMimeType(String mimeType) {
    if (mimeType.contains('image/')) {
      return Icons.image;
    } else if (mimeType.contains('pdf')) {
      return Icons.picture_as_pdf;
    } else if (mimeType.contains('word') ||
        mimeType.contains('msword') ||
        mimeType.contains('document')) {
      return Icons.description;
    } else if (mimeType.contains('excel') || mimeType.contains('sheet')) {
      return Icons.table_chart;
    } else {
      return Icons.insert_drive_file;
    }
  }

  // Helper method to get color for MIME type
  Color _getColorForMimeType(String mimeType) {
    if (mimeType.contains('image/')) {
      return Colors.blue;
    } else if (mimeType.contains('pdf')) {
      return Colors.red;
    } else if (mimeType.contains('word') ||
        mimeType.contains('msword') ||
        mimeType.contains('document')) {
      return Colors.blue.shade800;
    } else if (mimeType.contains('excel') || mimeType.contains('sheet')) {
      return Colors.green;
    } else {
      return Colors.grey;
    }
  }

  // Handle Dio errors and convert to AttachmentException
  AttachmentException _handleDioError(DioException e) {
    String errorMessage;
    int? statusCode = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        errorMessage = 'Connection timeout';
        break;
      case DioExceptionType.sendTimeout:
        errorMessage = 'Send timeout';
        break;
      case DioExceptionType.receiveTimeout:
        errorMessage = 'Download timeout';
        break;
      case DioExceptionType.badResponse:
        switch (statusCode) {
          case 401:
            errorMessage = 'Unauthorized access';
            break;
          case 403:
            errorMessage = 'Forbidden';
            break;
          case 404:
            errorMessage = 'Attachment not found';
            break;
          default:
            errorMessage = 'Server error (${statusCode ?? "unknown"})';
        }
        break;
      case DioExceptionType.cancel:
        errorMessage = 'Request cancelled';
        break;
      default:
        errorMessage = 'Network error: ${e.message}';
    }

    return AttachmentException(errorMessage, statusCode);
  }
}
