import 'package:dio/dio.dart';
import '../../models/form_submission.dart';
import 'api_client.dart';

class FormSubmissionService {
  final ApiClient _apiClient;

  const FormSubmissionService(this._apiClient);

  Future<FormSubmission> createSubmission({
    required int formId,
    required List<Map<String, dynamic>> answers,
    Map<String, MultipartFile>? signatureFiles,
  }) async {
    try {
      final formData = FormData.fromMap({
        'form_id': formId.toString(),
        'answers': answers,
      });

      if (signatureFiles != null) {
        signatureFiles.forEach((questionId, file) {
          formData.files.add(MapEntry('signature_$questionId', file));
        });
      }

      final response = await _apiClient.post(
        '/api/form-submissions',
        data: formData,
      );
      return FormSubmission.fromJson(response.data['submission'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<FormSubmission>> getAllSubmissions({
    int? formId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (formId != null) 'form_id': formId,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiClient.get(
        '/api/form-submissions',
        queryParameters: queryParameters,
      );
      return (response.data['submissions'] as List)
          .map((json) => FormSubmission.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FormSubmission> getSubmission(int submissionId) async {
    try {
      final response = await _apiClient.get('/api/form-submissions/$submissionId');
      return FormSubmission.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<FormSubmission>> getMySubmissions({
    int? formId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (formId != null) 'form_id': formId,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiClient.get(
        '/api/form-submissions/my-submissions',
        queryParameters: queryParameters,
      );
      return (response.data['submissions'] as List)
          .map((json) => FormSubmission.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteSubmission(int submissionId) async {
    try {
      await _apiClient.delete('/api/form-submissions/$submissionId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return NotFoundException('Form submission not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['error'] as String? ?? 'Bad request';
      return BadRequestException(message);
    }
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access');
    }
    return ApiException('Failed to complete form submission operation: ${e.message}');
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