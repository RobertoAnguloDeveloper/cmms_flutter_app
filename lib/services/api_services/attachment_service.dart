import 'package:dio/dio.dart';
import '../../models/attachment.dart';
import 'api_client.dart';

class AttachmentService {
  final ApiClient _apiClient;

  const AttachmentService(this._apiClient);

  Future<Attachment> createAttachment({
    required int formSubmissionId,
    required MultipartFile file,
    bool isSignature = false,
  }) async {
    try {
      final formData = FormData.fromMap({
        'form_submission_id': formSubmissionId.toString(),
        'file': file,
        'is_signature': isSignature.toString(),
      });

      final response = await _apiClient.post(
        '/api/attachments',
        data: formData,
      );
      return Attachment.fromJson(response.data['attachment'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Attachment>> bulkCreateAttachments({
    required int formSubmissionId,
    required List<MapEntry<MultipartFile, bool>> files,
  }) async {
    try {
      final formData = FormData.fromMap({
        'form_submission_id': formSubmissionId.toString(),
      });

      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        formData.files.add(MapEntry('file$i', file.key));
        formData.fields.add(MapEntry('is_signature$i', file.value.toString()));
      }

      final response = await _apiClient.post(
        '/api/attachments/bulk',
        data: formData,
      );
      return (response.data['attachments'] as List)
          .map((json) => Attachment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Attachment>> getAllAttachments({
    int? formSubmissionId,
    bool? isSignature,
    String? fileType,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (formSubmissionId != null) 'form_submission_id': formSubmissionId,
        if (isSignature != null) 'is_signature': isSignature,
        if (fileType != null) 'file_type': fileType,
      };

      final response = await _apiClient.get(
        '/api/attachments',
        queryParameters: queryParameters,
      );
      return (response.data['attachments'] as List)
          .map((json) => Attachment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Attachment>> getSubmissionAttachments(int submissionId) async {
    try {
      final response = await _apiClient.get('/api/attachments/submission/$submissionId');
      return (response.data['attachments'] as List)
          .map((json) => Attachment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteAttachment(int attachmentId) async {
    try {
      await _apiClient.delete('/api/attachments/$attachmentId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return NotFoundException('Attachment not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['error'] as String? ?? 'Bad request';
      return BadRequestException(message);
    }
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access');
    }
    return ApiException('Failed to complete attachment operation: ${e.message}');
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

class BadRequestException extends ApiException {
  const BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}