import 'api_client.dart';
import '../../models/form_submission.dart';
import 'package:dio/dio.dart';

class FormSubmissionService {
  final ApiClient _apiClient;

  FormSubmissionService(this._apiClient);

  Future<FormSubmission> createSubmission({
    required int formId,
    required List<Map<String, dynamic>> answers,
    List<MultipartFile>? files,
  }) async {
    try {
      // Create form data for multipart request
      final formData = FormData.fromMap({
        'form_id': formId,
        'answers': answers,
        if (files != null)
          ...files.asMap().map((i, file) => MapEntry('file$i', file)),
      });

      final response = await _apiClient.post(
        '/api/form-submissions',
        data: formData,
      );
      return FormSubmission.fromJson(response.data['submission']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FormSubmission>> getSubmissions({
    int? formId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/form-submissions',
        queryParameters: {
          if (formId != null) 'form_id': formId,
          if (startDate != null) 'start_date': startDate.toIso8601String(),
          if (endDate != null) 'end_date': endDate.toIso8601String(),
        },
      );
      return (response.data as List)
          .map((json) => FormSubmission.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSubmission(int submissionId) async {
    try {
      await _apiClient.delete('/api/form-submissions/$submissionId');
    } catch (e) {
      rethrow;
    }
  }
}