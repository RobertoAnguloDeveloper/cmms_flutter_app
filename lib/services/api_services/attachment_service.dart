import 'api_client.dart';
import '../../models/attachment.dart';
import 'package:dio/dio.dart';

class AttachmentService {
  final ApiClient _apiClient;

  AttachmentService(this._apiClient);

  Future<Attachment> createAttachment({
    required int formSubmissionId,
    required MultipartFile file,
    bool isSignature = false,
  }) async {
    try {
      final formData = FormData.fromMap({
        'form_submission_id': formSubmissionId,
        'file': file,
        'is_signature': isSignature,
      });

      final response = await _apiClient.post(
        '/api/attachments',
        data: formData,
      );
      return Attachment.fromJson(response.data['attachment']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Attachment>> getSubmissionAttachments(int submissionId) async {
    try {
      final response = await _apiClient.get(
          '/api/attachments/submission/$submissionId');
      return (response.data as List)
          .map((json) => Attachment.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAttachment(int attachmentId) async {
    try {
      await _apiClient.delete('/api/attachments/$attachmentId');
    } catch (e) {
      rethrow;
    }
  }
}