import 'package:dio/dio.dart';
import '../../models/answer_submitted.dart';
import 'api_client.dart';

class AnswerSubmittedService {
  final ApiClient _apiClient;

  const AnswerSubmittedService(this._apiClient);

  Future<AnswerSubmitted> createAnswerSubmitted({
    required int formSubmissionId,
    required String questionText,
    required String answerText,
    required String questionType,
    bool isSignature = false,
    MultipartFile? signatureFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'form_submission_id': formSubmissionId,
        'question_text': questionText,
        'answer_text': answerText,
        'question_type': questionType,
        if (isSignature) 'is_signature': isSignature.toString(),
        if (signatureFile != null) 'signature': signatureFile,
      });

      final response = await _apiClient.post(
        '/api/answers-submitted',
        data: formData,
      );
      return AnswerSubmitted.fromJson(response.data['answer_submitted'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<AnswerSubmitted>> bulkCreateAnswersSubmitted({
    required int formSubmissionId,
    required List<Map<String, dynamic>> submissions,
    Map<String, MultipartFile>? signatureFiles,
  }) async {
    try {
      final formData = FormData.fromMap({
        'form_submission_id': formSubmissionId.toString(),
        'submissions': submissions,
      });

      if (signatureFiles != null) {
        for (final entry in signatureFiles.entries) {
          formData.files.add(MapEntry('signature_${entry.key}', entry.value));
        }
      }

      final response = await _apiClient.post(
        '/api/answers-submitted/bulk',
        data: formData,
      );
      return (response.data['submissions'] as List)
          .map((json) => AnswerSubmitted.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<AnswerSubmitted>> getAllAnswersSubmitted({
    int? formSubmissionId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        if (formSubmissionId != null) 'form_submission_id': formSubmissionId,
        if (startDate != null) 'start_date': startDate.toIso8601String(),
        if (endDate != null) 'end_date': endDate.toIso8601String(),
      };

      final response = await _apiClient.get(
        '/api/answers-submitted',
        queryParameters: queryParameters,
      );

      return (response.data['answers'] as List)
          .map((json) => AnswerSubmitted.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AnswerSubmitted> getAnswerSubmitted(int answerSubmittedId) async {
    try {
      final response = await _apiClient.get('/api/answers-submitted/$answerSubmittedId');
      return AnswerSubmitted.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<AnswerSubmitted>> getAnswersBySubmission(int submissionId) async {
    try {
      final response = await _apiClient.get('/api/answers-submitted/submission/$submissionId');
      return (response.data['answers'] as List)
          .map((json) => AnswerSubmitted.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<AnswerSubmitted> updateAnswerSubmitted(
      int answerSubmittedId, {
        required String answerText,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/answers-submitted/$answerSubmittedId',
        data: {'answer_text': answerText},
      );
      return AnswerSubmitted.fromJson(response.data['answer_submitted'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteAnswerSubmitted(int answerSubmittedId) async {
    try {
      await _apiClient.delete('/api/answers-submitted/$answerSubmittedId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return NotFoundException('Answer submission not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['error'] as String? ?? 'Bad request';
      return BadRequestException(message);
    }
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access');
    }
    return ApiException('Failed to complete answer submission operation: ${e.message}');
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