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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
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
        responseBody: false,
        error: true,
        requestHeader: true,
        responseHeader: true,
      ));
    }
  }

  Future<Map<String, dynamic>> createAttachment(
      BuildContext context,
      int formSubmissionId,
      File file,
      bool isSignature, {
        String? signatureAuthor,
        String? signaturePosition,
      }) async {
    try {
      final validationError = _validateFile(file);
      if (validationError != null) {
        throw AttachmentException(validationError);
      }

      String? token = await SessionManager.getToken();
      var uri = Uri.parse('${_http.baseUrl}/api/attachments');

      var request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..fields['form_submission_id'] = formSubmissionId.toString()
        ..fields['is_signature'] = isSignature.toString();

      if (isSignature) {
        if (signatureAuthor != null && signatureAuthor.isNotEmpty) {
          request.fields['signature_author'] = signatureAuthor;
        }
        if (signaturePosition != null && signaturePosition.isNotEmpty) {
          request.fields['signature_position'] = signaturePosition;
        }
      }

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
        String? signatureAuthor = fileData['signature_author'];
        String? signaturePosition = fileData['signature_position'];

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

        if (isSignature) {
          if (signatureAuthor != null && signatureAuthor.isNotEmpty) {
            request.fields['signature_author$i'] = signatureAuthor;
          }
          if (signaturePosition != null && signaturePosition.isNotEmpty) {
            request.fields['signature_position$i'] = signaturePosition;
          }
        }
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

  Future<Map<String, dynamic>> uploadSignature(
      BuildContext context,
      int formSubmissionId,
      File file, {
        String? signatureAuthor,
        String? signaturePosition,
      }) async {
    return createAttachment(
      context,
      formSubmissionId,
      file,
      true,
      signatureAuthor: signatureAuthor,
      signaturePosition: signaturePosition,
    );
  }

  Future<Map<String, dynamic>> uploadSignatureAttachment(
      BuildContext context,
      int formSubmissionId,
      File file, {
        String? signatureAuthor,
        String? signaturePosition,
      }) async {
    return createAttachment(
      context,
      formSubmissionId,
      file,
      true,
      signatureAuthor: signatureAuthor,
      signaturePosition: signaturePosition,
    );
  }

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

  Future<void> openAttachment(BuildContext context, int attachmentId) async {
    print('🔍 Attempting to open attachment with range requests: $attachmentId');

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

      final attachmentUrl = '${_http.baseUrl}/api/attachments/$attachmentId';
      print('🌐 Attachment URL: $attachmentUrl');

      final response = await http.head(
        Uri.parse(attachmentUrl),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return;
      }

      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

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

  // 📂 lib/services/api_model_services/api_form_services/attachment_service.dart

  Future<void> _downloadWithRangeRequests(
      BuildContext context,
      int attachmentId,
      String url,
      String token,
      ) async {
    // Initial progress value
    double progress = 0.0;

    // Reference to the dialog context
    late BuildContext dialogContext;

    // Create a dialog with StatefulBuilder to allow updating progress
    if (context.mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (context, setState) {
              dialogContext = context;
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
        },
      );
    }

    // Function to update progress without recreating the dialog
    void updateProgress(double newProgress) {
      if (context.mounted) {
        // Update only the StatefulBuilder state
        (dialogContext as StatefulElement).state.setState(() {
          progress = newProgress;
        });
      }
    }

    try {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final tempFilename = 'attachment_${attachmentId}_$timestamp.download';
      final tempFilePath = '${directory.path}/$tempFilename';

      print('📁 Will save to: $tempFilePath');

      final outputFile = File(tempFilePath);
      final raf = await outputFile.open(mode: FileMode.write);

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

        final contentDisposition =
            headResponse.headers['content-disposition'] ?? '';
        final filenameMatch =
        RegExp(r'filename=([^;]*)').firstMatch(contentDisposition);
        if (filenameMatch != null && filenameMatch.group(1) != null) {
          finalFilename = filenameMatch.group(1)!.trim();
        } else {
          final extension = _getExtensionFromMime(contentType);
          finalFilename = 'attachment_${attachmentId}_$timestamp.$extension';
        }
      } else {
        print('⚠️ HEAD request failed, using default values');
      }

      print(
          '📄 Content type: $contentType, Size: $fileSize, Filename: $finalFilename');

      if (fileSize <= 0) {
        fileSize = 1024 * 1024;
      }

      const chunkSize = 16 * 1024;
      int totalBytesDownloaded = 0;
      int currentPosition = 0;
      int retryCount = 0;
      const maxRetries = 5;

      while (currentPosition < fileSize && retryCount < maxRetries) {
        try {
          final endPosition = currentPosition + chunkSize - 1;
          final adjustedEndPosition =
          endPosition < fileSize ? endPosition : fileSize - 1;

          print('🔄 Downloading range: $currentPosition-$adjustedEndPosition');

          final response = await http.get(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Range': 'bytes=$currentPosition-$adjustedEndPosition',
            },
          );

          if (response.statusCode == 206 || response.statusCode == 200) {
            final chunkData = response.bodyBytes;

            await raf.setPosition(currentPosition);
            await raf.writeFrom(chunkData);

            final bytesDownloaded = chunkData.length;
            totalBytesDownloaded += bytesDownloaded;
            currentPosition += bytesDownloaded;

            final downloadProgress = fileSize > 0 ? totalBytesDownloaded / fileSize : 0.0;
            print('📊 Progress: ${(downloadProgress * 100).toStringAsFixed(0)}%, Downloaded: $totalBytesDownloaded/$fileSize bytes');

            // Update progress without recreating dialog
            updateProgress(downloadProgress);

            retryCount = 0;
          } else {
            print('⚠️ Range request failed: ${response.statusCode}');
            retryCount++;
            await Future.delayed(Duration(milliseconds: 500 * retryCount));
          }
        } catch (e) {
          print('⚠️ Error downloading chunk: $e');
          retryCount++;
          await Future.delayed(Duration(milliseconds: 500 * retryCount));
        }
      }

      await raf.close();

      if (totalBytesDownloaded >= fileSize * 0.9) {
        print('✅ Download completed: $totalBytesDownloaded/$fileSize bytes');

        final finalFilePath = '${directory.path}/$finalFilename';
        await outputFile.rename(finalFilePath);

        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        if (context.mounted) {
          _showSuccessDialog(context, finalFilePath, contentType);
        }
      } else {
        print('❌ Download incomplete: $totalBytesDownloaded/$fileSize bytes');
        await outputFile.delete();

        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        throw Exception('Download incomplete after $maxRetries retries');
      }
    } catch (e) {
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

  Future<void> _downloadToAppDirectory(
      BuildContext context,
      int attachmentId,
      String url,
      String token,
      ) async {
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
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filename = 'attachment_${attachmentId}_$timestamp.bin';
      final file = File('${directory.path}/$filename');

      print('📁 Will save to app directory: ${file.path}');

      final bytes = <int>[];
      bool downloadComplete = false;

      Future<void> tryDownload() async {
        try {
          final httpClient = HttpClient();
          httpClient.connectionTimeout = const Duration(seconds: 30);

          final request = await httpClient.getUrl(Uri.parse(url));
          request.headers.add('Authorization', 'Bearer $token');

          final response = await request.close();

          if (response.statusCode == 200) {
            final contentType = response.headers.value('content-type') ??
                'application/octet-stream';
            final contentDisposition =
                response.headers.value('content-disposition') ?? '';

            String filenameWithExt = filename;
            final filenameMatch =
            RegExp(r'filename=([^;]*)').firstMatch(contentDisposition);
            if (filenameMatch != null && filenameMatch.group(1) != null) {
              filenameWithExt = filenameMatch.group(1)!.trim();
            } else {
              final extension = _getExtensionFromMime(contentType);
              filenameWithExt =
              'attachment_${attachmentId}_$timestamp.$extension';
            }

            final fileWithExt = File('${directory.path}/$filenameWithExt');

            final output = fileWithExt.openWrite();
            int totalBytes = 0;

            await for (var chunk in response) {
              output.add(chunk);
              totalBytes += chunk.length;
              print('📊 Downloaded: $totalBytes bytes');
            }

            await output.close();
            print('✅ File saved to: ${fileWithExt.path}');

            downloadComplete = true;

            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }

            if (context.mounted) {
              _showSuccessDialog(context, fileWithExt.path, contentType);
            }
          } else {
            print('❌ Download failed with status: ${response.statusCode}');
          }

          httpClient.close();
        } catch (e) {
          print('❌ Method 1 download error: $e');
        }

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
              final contentType = response.headers['content-type'] ??
                  'application/octet-stream';

              final extension = _getExtensionFromMime(contentType);
              final fileWithExt = File(
                  '${directory.path}/attachment_${attachmentId}_$timestamp.$extension');

              await fileWithExt.writeAsBytes(response.bodyBytes);
              print(
                  '✅ File saved via alternate method to: ${fileWithExt.path}');

              if (context.mounted) {
                Navigator.of(context, rootNavigator: true).pop();
              }

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

      await tryDownload();

      if (!downloadComplete) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
        }

        throw Exception('All download methods failed.');
      }
    } catch (e) {
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

  Future<void> _downloadWithExternalMethod(
      BuildContext context,
      int attachmentId,
      String url,
      String token,
      String filename,
      String contentType) async {
    try {
      if (Platform.isAndroid) {
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('Could not access external storage');
        }

        final file = File('${directory.path}/$filename');

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

        final httpClient = HttpClient();
        httpClient.connectionTimeout = const Duration(seconds: 30);

        final request = await httpClient.getUrl(Uri.parse(url));
        request.headers.add('Authorization', 'Bearer $token');

        final response = await request.close();

        if (response.statusCode == 200) {
          final fileOutput = file.openWrite();

          const bufferSize = 64 * 1024;
          var bytesReceived = 0;

          try {
            await for (var data in response.transform(
              StreamTransformer<List<int>, List<int>>.fromHandlers(
                handleData: (data, sink) {
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
              fileOutput.add(data);
              bytesReceived += data.length;
              print('📊 Received: $bytesReceived bytes');
            }

            await fileOutput.close();
            print('✅ File successfully written to ${file.path}');

            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }

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

            if (context.mounted) {
              Navigator.of(context, rootNavigator: true).pop();
            }

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
          if (context.mounted) {
            Navigator.of(context, rootNavigator: true).pop();
          }

          throw Exception('Server returned status code ${response.statusCode}');
        }

        httpClient.close();
      } else {
        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final bytes = response.bodyBytes;

          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/$filename');

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

  Future<Directory?> getExternalStorageDirectory() async {
    if (Platform.isAndroid) {
      try {
        final downloadsDir = Directory('/storage/emulated/0/Download');
        if (await downloadsDir.exists()) {
          return downloadsDir;
        }

        return await getApplicationDocumentsDirectory();
      } catch (e) {
        print('Error getting external storage directory: $e');
      }
    }

    return await getApplicationDocumentsDirectory();
  }

  Future<bool> _directlySaveFile(BuildContext context, Uint8List bytes,
      String contentType, int attachmentId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      String extension = _getExtensionFromMime(contentType);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'attachment_${attachmentId}_$timestamp.$extension';
      final filePath = '${directory.path}/$fileName';

      print('📄 Saving file to: $filePath');

      final file = File(filePath);
      await file.writeAsBytes(bytes, flush: true);

      print('✅ File saved: $filePath');

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

  Future<void> _tryAlternativeSave(BuildContext context, Uint8List bytes,
      String contentType, int attachmentId) async {
    try {
      final directory = await getTemporaryDirectory();

      String extension = _getExtensionFromMime(contentType);

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'attachment_${attachmentId}_$timestamp.$extension';
      final filePath = '${directory.path}/$fileName';

      print('📄 Trying alternative save to: $filePath');

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
      case 'application/docx':
        return 'docx';
      case 'application/vnd.ms-excel':
      case 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet':
      case 'application/xlsx':
        return 'xlsx';
      default:
        return 'bin';
    }
  }

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

  void _saveAttachment(BuildContext context, Uint8List bytes,
      String contentType, int attachmentId) async {
    try {
      if (kIsWeb) {
        _downloadFileWeb(bytes, _getExtensionFromMime(contentType));
        return;
      }

      final directory = await getApplicationDocumentsDirectory();

      String extension = _getExtensionFromMime(contentType);

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
          final result = await OpenFile.open(filePath);

          switch (result.type) {
            case ResultType.done:
              print('File opened successfully');
              break;
            case ResultType.noAppToOpen:
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'File downloaded, but no app found to open it.'),
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