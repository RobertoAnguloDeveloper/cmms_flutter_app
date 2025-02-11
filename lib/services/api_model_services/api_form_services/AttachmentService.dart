import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:http_parser/http_parser.dart';
import '../../../models/attachment/attachment.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';
import '../../api_session_client_services/ApiResponseHandler.dart';

class AttachmentService {
  static const int maxFileSize = 16 * 1024 * 1024; // 16MB
  static const Set<String> allowedExtensions = {
    'pdf', 'png', 'jpg', 'jpeg', 'gif', 'doc', 'docx', 'xls', 'xlsx', 'txt'
  };

  final Http _http = Http();

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
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error creating attachment: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while creating attachment: $e');
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
          throw Exception('File ${i + 1}: $validationError');
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
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error creating attachments: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while creating attachments: $e');
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
        uri = uri.replace(queryParameters: filters.map(
                (key, value) => MapEntry(key, value.toString())
        ));
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
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error fetching attachments: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while fetching attachments: $e');
    }
  }

  // Download attachment
  Future<File> downloadAttachment(
      BuildContext context,
      int attachmentId,
      String localPath,
      ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${_http.baseUrl}/api/attachments/$attachmentId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final file = File(localPath);
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Authentication error');
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error downloading attachment: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while downloading attachment: $e');
    }
  }

  // Delete attachment
  Future<Map<String, dynamic>> deleteAttachment(
      BuildContext context,
      int attachmentId,
      ) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.delete(
        Uri.parse('${_http.baseUrl}/api/attachments/$attachmentId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error deleting attachment: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while deleting attachment: $e');
    }
  }

  // Validate file
  String? _validateFile(File file) {
    final size = file.lengthSync();
    if (size > maxFileSize) {
      return 'File size exceeds maximum limit of ${maxFileSize / (1024 * 1024)}MB';
    }

    final extension = path.extension(file.path).toLowerCase().replaceAll('.', '');
    if (!allowedExtensions.contains(extension)) {
      return 'File type not allowed. Allowed types: ${allowedExtensions.join(", ")}';
    }

    return null;
  }

  // Get MIME type
  String _getMimeType(String filepath) {
    final ext = path.extension(filepath).toLowerCase();
    switch (ext) {
      case '.pdf': return 'application/pdf';
      case '.png': return 'image/png';
      case '.jpg':
      case '.jpeg': return 'image/jpeg';
      case '.gif': return 'image/gif';
      case '.doc': return 'application/msword';
      case '.docx': return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case '.xls': return 'application/vnd.ms-excel';
      case '.xlsx': return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
      case '.txt': return 'text/plain';
      default: return 'application/octet-stream';
    }
  }
}