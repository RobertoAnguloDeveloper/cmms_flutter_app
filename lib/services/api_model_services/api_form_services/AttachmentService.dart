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
import 'package:open_file/open_file.dart';
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

  /// Opens an attachment using a more robust download strategy specifically for emulator testing
  /// Downloads attachment with special handling for emulator connections
  /// Downloads attachment with storage permission handling
  /// Downloads attachment using HTTP range requests for more reliable downloads in emulators
  Future<void> openAttachment(BuildContext context, int attachmentId) async {
    print('🔍 Attempting to open attachment with range requests: $attachmentId');

    // Mostrar el diálogo de carga inmediatamente
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext ctx) {
          return const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text('Preparing attachment...'),
              ],
            ),
          );
        },
      );
    }

    try {
      String? token = await SessionManager.getToken();

      if (token == null) {
        throw Exception('Authentication token is null. Please log in again.');
      }

      // Construir la URL del adjunto
      final attachmentUrl = '${_http.baseUrl}/api/attachments/$attachmentId';
      print('🌐 Attachment URL: $attachmentUrl');

      // Realizar una solicitud HEAD para verificar la autorización
      final response = await http.head(
        Uri.parse(attachmentUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      // Manejar token expirado
      if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return; // Salir de la función para evitar continuar con un token inválido
      }

      // Cerrar el diálogo de carga
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      // Mostrar opciones de descarga al usuario
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text('Download Attachment'),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Would you like to download this attachment?'),
                SizedBox(height: 20),
                Icon(Icons.download_rounded, size: 48, color: Colors.blue),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _downloadWithRangeRequests(
                      context, attachmentId, attachmentUrl, token);
                },
                child: const Text('Download'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('❌ Error preparing download: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Downloads file using HTTP range requests in small chunks
  Future<void> _downloadWithRangeRequests(
    BuildContext context,
    int attachmentId,
    String url,
    String token,
  ) async {
    // Show download progress dialog
    double progress = 0.0;
    late BuildContext dialogContext;

    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          dialogContext = ctx;
          return AlertDialog(
            title: const Text('Downloading...'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                LinearProgressIndicator(value: progress),
                const SizedBox(height: 10),
                Text('${(progress * 100).toStringAsFixed(0)}%'),
              ],
            ),
          );
        },
      );
    }

    // Function to update progress dialog
    void updateProgress(double newProgress) {
      progress = newProgress;
      if (context.mounted) {
        // Force rebuild of progress dialog
        Navigator.of(context).pop();
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            dialogContext = ctx;
            return AlertDialog(
              title: const Text('Downloading...'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 10),
                  Text('${(progress * 100).toStringAsFixed(0)}%'),
                ],
              ),
            );
          },
        );
      }
    }

    try {
      // Get app's private documents directory
      final directory = await getApplicationDocumentsDirectory();

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFilename = 'attachment_${attachmentId}_$timestamp.download';
      final tempFilePath = '${directory.path}/$tempFilename';

      print('📁 Will save to: $tempFilePath');

      // Create a temporary file to write the chunks
      final outputFile = File(tempFilePath);
      final raf = await outputFile.open(mode: FileMode.write);

      // First, make a HEAD request to get file size and content type
      final headResponse = await http.head(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );

      String contentType = 'application/octet-stream';
      int fileSize = 0;
      String finalFilename = 'attachment_$attachmentId$timestamp';

      if (headResponse.statusCode == 200) {
        contentType = headResponse.headers['content-type'] ?? contentType;
        final contentLengthStr = headResponse.headers['content-length'];
        if (contentLengthStr != null) {
          fileSize = int.tryParse(contentLengthStr) ?? 0;
        }

        // Try to get filename from content-disposition
        final contentDisposition =
            headResponse.headers['content-disposition'] ?? '';
        final filenameMatch =
            RegExp(r'filename=([^;]*)').firstMatch(contentDisposition);
        if (filenameMatch != null && filenameMatch.group(1) != null) {
          finalFilename = filenameMatch.group(1)!.trim();
        } else {
          // Add extension based on content type
          final extension = _getExtensionFromMime(contentType);
          finalFilename = 'attachment_${attachmentId}_$timestamp.$extension';
        }
      } else {
        print('⚠️ HEAD request failed, using default values');
      }

      print(
          '📄 Content type: $contentType, Size: $fileSize, Filename: $finalFilename');

      // If the server doesn't support HEAD or didn't return a size, use a default
      if (fileSize <= 0) {
        fileSize = 1024 * 1024; // Assume 1MB as fallback
      }

      // Define chunk size (16KB is reliable for emulators)
      const chunkSize = 16 * 1024; // 16KB chunks

      // Track overall progress
      int totalBytesDownloaded = 0;
      int currentPosition = 0;
      int retryCount = 0;
      const maxRetries = 5;

      // Download in chunks
      while (currentPosition < fileSize && retryCount < maxRetries) {
        try {
          // Calculate end position for this chunk
          final endPosition = currentPosition + chunkSize - 1;
          // Don't request beyond the file size
          final adjustedEndPosition =
              endPosition < fileSize ? endPosition : fileSize - 1;

          print('🔄 Downloading range: $currentPosition-$adjustedEndPosition');

          // Make a range request for this chunk
          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Range': 'bytes=$currentPosition-$adjustedEndPosition',
            },
          );

          // Check if we got the expected response
          if (response.statusCode == 206 || response.statusCode == 200) {
            // 206 Partial Content or 200 OK
            final chunkData = response.bodyBytes;

            // Write chunk to file at the correct position
            await raf.setPosition(currentPosition);
            await raf.writeFrom(chunkData);

            // Update progress
            final bytesDownloaded = chunkData.length;
            totalBytesDownloaded += bytesDownloaded;
            currentPosition += bytesDownloaded;

            // Calculate and update progress
            final downloadProgress =
                fileSize > 0 ? totalBytesDownloaded / fileSize : 0.0;
            print(
                '📊 Progress: ${(downloadProgress * 100).toStringAsFixed(0)}%, Downloaded: $totalBytesDownloaded/$fileSize bytes');

            // Update UI progress
            updateProgress(downloadProgress);

            // Reset retry counter on success
            retryCount = 0;
          } else {
            print('⚠️ Range request failed: ${response.statusCode}');
            retryCount++;
            await Future.delayed(Duration(
                milliseconds: 500 * retryCount)); // Exponential backoff
          }
        } catch (e) {
          print('⚠️ Error downloading chunk: $e');
          retryCount++;
          await Future.delayed(
              Duration(milliseconds: 500 * retryCount)); // Exponential backoff
        }
      }

      // Close the file
      await raf.close();

      // Check if we downloaded the complete file
      if (totalBytesDownloaded >= fileSize * 0.9) {
        // Consider it successful if we got at least 90%
        print('✅ Download completed: $totalBytesDownloaded/$fileSize bytes');

        // Rename the file to add proper extension
        final finalFilePath = '${directory.path}/$finalFilename';
        await outputFile.rename(finalFilePath);

        // Close progress dialog
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        // Show success dialog
        if (context.mounted) {
          _showSuccessDialog(context, finalFilePath, contentType);
        }
      } else {
        // If we didn't download enough, consider it failed
        print('❌ Download incomplete: $totalBytesDownloaded/$fileSize bytes');
        // Delete the incomplete file
        await outputFile.delete();

        // Close progress dialog
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        throw Exception('Download incomplete after $maxRetries retries');
      }
    } catch (e) {
      // Close progress dialog if open
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('❌ Download error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

// Show success dialog with options to open the file
  void _showSuccessDialog(
      BuildContext context, String filePath, String contentType) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Download Complete'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('The file has been downloaded successfully.'),
            const SizedBox(height: 10),
            // Show file type icon based on content type
            Center(
              child: Icon(
                _getIconForMimeType(contentType),
                size: 48,
                color: _getColorForMimeType(contentType),
              ),
            ),
            const SizedBox(height: 10),
            const Text('File location:'),
            Text(
              filePath,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _openFile(context, filePath);
            },
            child: const Text('Open File'),
          ),
        ],
      ),
    );
  }

// Open file with error handling
  Future<void> _openFile(BuildContext context, String filePath) async {
    try {
      final result = await OpenFile.open(filePath);

      if (result.type != ResultType.done && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Cannot open file: ${result.message}'),
          ),
        );
      }
    } catch (e) {
      print('❌ Error opening file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Helper method to get icon for MIME type

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
    } else if (mimeType.contains('text/')) {
      return Colors.orange;
    } else {
      return Colors.grey;
    }
  }

  /// Downloads file to app's private directory (no special permissions needed)
  Future<void> _downloadToAppDirectory(
    BuildContext context,
    int attachmentId,
    String url,
    String token,
  ) async {
    // Show progress dialog
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => const AlertDialog(
          title: Text('Downloading...'),
          content: LinearProgressIndicator(),
        ),
      );
    }

    try {
      // Get app's private documents directory (no permissions needed)
      final directory = await getApplicationDocumentsDirectory();

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'attachment_${attachmentId}_$timestamp.bin';
      final file = File('${directory.path}/$filename');

      print('📁 Will save to app directory: ${file.path}');

      // Create a buffer to store the downloaded data
      final bytes = <int>[];
      bool downloadComplete = false;

      // Function to try downloading with different methods
      Future<void> tryDownload() async {
        // Method 1: Use HttpClient with chunked transfer
        try {
          final httpClient = HttpClient();
          httpClient.connectionTimeout = const Duration(seconds: 30);

          final request = await httpClient.getUrl(Uri.parse(url));
          request.headers.add('Authorization', 'Bearer $token');

          final response = await request.close();

          if (response.statusCode == 200) {
            // Get content type from headers
            final contentType = response.headers.value('content-type') ??
                'application/octet-stream';
            final contentDisposition =
                response.headers.value('content-disposition') ?? '';

            // Try to extract filename from content-disposition if available
            String filenameWithExt = filename;
            final filenameMatch =
                RegExp(r'filename=([^;]*)').firstMatch(contentDisposition);
            if (filenameMatch != null && filenameMatch.group(1) != null) {
              filenameWithExt = filenameMatch.group(1)!.trim();
            } else {
              // Determine extension from content type
              final extension = _getExtensionFromMime(contentType);
              filenameWithExt =
                  'attachment_${attachmentId}_$timestamp.$extension';
            }

            // Update file path with proper extension
            final fileWithExt = File('${directory.path}/$filenameWithExt');

            // Collect data in chunks
            final output = fileWithExt.openWrite();
            int totalBytes = 0;

            await for (var chunk in response) {
              output.add(chunk);
              totalBytes += chunk.length;
              print('📊 Downloaded: $totalBytes bytes');
            }

            await output.close();
            print('✅ File saved to: ${fileWithExt.path}');

            // File successfully downloaded
            downloadComplete = true;

            // Close progress dialog
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            // Show success dialog
            if (context.mounted) {
              _showSuccessDialog(context, fileWithExt.path, contentType);
            }
          } else {
            print('❌ Download failed with status: ${response.statusCode}');
          }

          httpClient.close();
        } catch (e) {
          print('❌ Method 1 download error: $e');
          // Will try next method if this fails
        }

        // If first method failed, try Method 2: http package with basic auth
        if (!downloadComplete) {
          try {
            print('🔄 Trying alternate download method');

            final response = await http.get(
              Uri.parse(url),
              headers: {
                'Authorization': 'Bearer $token',
              },
            );

            if (response.statusCode == 200) {
              // Get content type from headers
              final contentType = response.headers['content-type'] ??
                  'application/octet-stream';

              // Determine extension from content type
              final extension = _getExtensionFromMime(contentType);
              final fileWithExt = File(
                  '${directory.path}/attachment_${attachmentId}_$timestamp.$extension');

              // Write file synchronously to avoid streaming issues
              await fileWithExt.writeAsBytes(response.bodyBytes);
              print(
                  '✅ File saved via alternate method to: ${fileWithExt.path}');

              // Close progress dialog
              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }

              // Show success dialog
              if (context.mounted) {
                _showSuccessDialog(context, fileWithExt.path, contentType);
              }

              downloadComplete = true;
            } else {
              print(
                  '❌ Alternate download failed with status: ${response.statusCode}');
            }
          } catch (e) {
            print('❌ Method 2 download error: $e');
          }
        }
      }

      // Try the download
      await tryDownload();

      // If all download methods failed
      if (!downloadComplete) {
        // Close progress dialog if still open
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        throw Exception('All download methods failed.');
      }
    } catch (e) {
      // Close progress dialog if still open
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('❌ Download error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Helper method to get color for MIME type

  /// Downloads file using platform-specific external download manager
  Future<void> _downloadWithExternalMethod(
      BuildContext context,
      int attachmentId,
      String url,
      String token, // Now non-nullable since we check before calling
      String filename,
      String contentType) async {
    try {
      if (Platform.isAndroid) {
        // On Android, we'll use the DownloadManager
        // First, we need to get a directory that's accessible by the DownloadManager
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Could not access external storage');
        }

        // Create a file in the external storage
        final file = File('${directory.path}/$filename');

        // Show progress dialog
        if (context.mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const AlertDialog(
              title: Text('Downloading...'),
              content: LinearProgressIndicator(),
            ),
          );
        }

        // Use a technique that makes multiple short requests instead of one long one
        final httpClient = HttpClient();
        httpClient.connectionTimeout = const Duration(seconds: 30);

        // Create request
        final request = await httpClient.getUrl(Uri.parse(url));
        request.headers.add('Authorization', 'Bearer $token');

        // Get response
        final response = await request.close();

        if (response.statusCode == 200) {
          // Open file for writing
          final fileOutput = file.openWrite();

          // Set up buffer size and tracking variables
          const bufferSize = 64 * 1024; // 64KB chunks
          var bytesReceived = 0;

          // Loop to read data in small chunks
          try {
            await for (var data in response.transform(
              StreamTransformer<List<int>, List<int>>.fromHandlers(
                handleData: (data, sink) {
                  // Process data in smaller chunks
                  int offset = 0;
                  while (offset < data.length) {
                    final end = offset + bufferSize < data.length
                        ? offset + bufferSize
                        : data.length;
                    sink.add(data.sublist(offset, end));
                    offset = end;
                  }
                },
              ),
            )) {
              // Add chunk to file
              fileOutput.add(data);
              bytesReceived += data.length;
              print('📊 Received: $bytesReceived bytes');
            }

            // Close file handle
            await fileOutput.close();
            print('✅ File successfully written to ${file.path}');

            // Close progress dialog
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            // Show success dialog
            if (context.mounted) {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Download Complete'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('The file has been downloaded successfully.'),
                      const SizedBox(height: 10),
                      Text('Location: ${file.path}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Close'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        OpenFile.open(file.path);
                      },
                      child: const Text('Open File'),
                    ),
                  ],
                ),
              );
            }
          } catch (e) {
            print('❌ Error during file write: $e');
            await fileOutput.close();

            // Close progress dialog
            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            // Show error
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Download failed: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          // Close progress dialog
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          throw Exception('Server returned status code ${response.statusCode}');
        }

        httpClient.close();
      } else {
        // For iOS, macOS, etc.
        // Try more basic approach
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;

          // Get documents directory
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$filename');

          // Write file
          await file.writeAsBytes(bytes);

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('File saved to ${file.path}'),
                action: SnackBarAction(
                  label: 'Open',
                  onPressed: () => OpenFile.open(file.path),
                ),
              ),
            );
          }
        } else {
          throw Exception(
              'Download failed with status: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Download error: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Download error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

// Make sure to add this import
  Future<Directory?> getExternalStorageDirectory() async {
    if (Platform.isAndroid) {
      try {
        // First try with Download directory
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          return downloadsDir;
        }

        // Fallback to app's external files directory
        return await getApplicationDocumentsDirectory();
      } catch (e) {
        print('Error getting external storage directory: $e');
      }
    }

    // Default to app's documents directory for iOS and other platforms
    return await getApplicationDocumentsDirectory();
  }

// Helper method to save file directly without attempting to preview
  Future<bool> _directlySaveFile(BuildContext context, Uint8List bytes,
      String contentType, int attachmentId) async {
    try {
      // For emulator testing, use a more reliable directory
      final directory = await getApplicationDocumentsDirectory();

      // Determine file extension
      String extension = _getExtensionFromMime(contentType);

      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'attachment_${attachmentId}_$timestamp.$extension';
      final filePath = '${directory.path}/$fileName';

      print('📄 Saving file to: $filePath');

      // Write file
      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      print('✅ File saved: $filePath');

      // Show success dialog with file path
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('File Saved'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('The file has been saved successfully.'),
                const SizedBox(height: 10),
                Text('Location: $filePath',
                    style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    OpenFile.open(filePath).then((result) {
                      if (result.type != ResultType.done && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content:
                                  Text('Cannot open file: ${result.message}')),
                        );
                      }
                    });
                  },
                  child: const Text('Open File'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }

      return true;
    } catch (e) {
      print('❌ Error saving file: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

// Show dialog when save fails
  void _showSaveFailedDialog(BuildContext context, Uint8List bytes,
      String contentType, int attachmentId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Failed'),
        content: const Text(
            'Could not save the file automatically. Would you like to try an alternative method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _tryAlternativeSave(context, bytes, contentType, attachmentId);
            },
            child: const Text('Try Alternative'),
          ),
        ],
      ),
    );
  }

// Try alternative save method for stubborn files
  Future<void> _tryAlternativeSave(BuildContext context, Uint8List bytes,
      String contentType, int attachmentId) async {
    try {
      // For testing in emulator, use temp directory as it's more reliable
      final directory = await getTemporaryDirectory();

      // Determine file extension
      String extension = _getExtensionFromMime(contentType);

      // Create unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'attachment_${attachmentId}_$timestamp.$extension';
      final filePath = '${directory.path}/$fileName';

      print('📄 Trying alternative save to: $filePath');

      // Write file using different method
      final file = File(filePath);
      final raf = await file.open(mode: FileMode.write);
      await raf.writeFrom(bytes);
      await raf.close();

      print('✅ File saved via alternative method: $filePath');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('File saved to: $filePath'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Open',
              onPressed: () {
                OpenFile.open(filePath);
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Alternative save method failed: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('All save methods failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showNonImageFileViewer(BuildContext context, Uint8List bytes,
      String contentType, int attachmentId) {
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
                onPressed: () =>
                    _saveAttachment(context, bytes, contentType, attachmentId),
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

  void _showImageViewer(BuildContext context, Uint8List bytes,
      String contentType, int attachmentId) {
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
      case 'application/docx': // Maneja el caso del servidor
        return 'docx';
      case 'application/vnd.ms-excel':
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      case 'application/xlsx':
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
  void _saveAttachment(BuildContext context, Uint8List bytes,
      String contentType, int attachmentId) async {
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

      final fileName =
          'attachment_${attachmentId}_${DateTime.now().millisecondsSinceEpoch}.$extension';
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
          final result = await OpenFile.open(filePath);

          // Check the result of opening the file
          switch (result.type) {
            case ResultType.done:
              print('File opened successfully');
              break;
            case ResultType.noAppToOpen:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'File downloaded, but no app found to open it.'),
                  //action: SnackBarAction(
                  //  label: 'Save',
                  //  onPressed: () {
                  //    // Provide option to just save the file
                  //    ScaffoldMessenger.of(context).showSnackBar(
                  //      SnackBar(
                  //        content: Text('File saved to $filePath'),
                  //      ),
                  //    );
                  //  },
                  //),
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
        ..setAttribute('download',
            'attachment_${DateTime.now().millisecondsSinceEpoch}.$extension');

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
