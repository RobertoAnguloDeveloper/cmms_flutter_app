import 'api_client.dart';
import '../../models/answer_submitted.dart';
import 'package:dio/dio.dart';

class AnswerSubmittedService {
  final ApiClient _apiClient;

  AnswerSubmittedService(this._apiClient);

  Future<AnswerSubmitted> createAnswerSubmitted({
    required int formSubmissionId,
    required String questionText,
    required String questionType,
    required String answerText,
    bool isSignature = false,
    MultipartFile? signatureFile,
  }) async {
    try {
      final formData = FormData.fromMap({
        'form_submission_id': formSubmissionId,
        'question_text': questionText,
        'question_type': questionType,
        'answer_text': answerText,
        'is_signature': isSignature,
        if (signatureFile != null) 'signature': signatureFile,
      });

      final response = await _apiClient.post(
        '/api/answers-submitted',
        data: formData,
      );
      return AnswerSubmitted.fromJson(response.data['answer_submitted']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AnswerSubmitted>> getAllAnswersSubmitted({
    Map<String, dynamic>? filters,
  }) async {
    try {
      final response = await _apiClient.get(
        '/api/answers-submitted',
        queryParameters: filters,
      );
      return (response.data as List)
          .map((json) => AnswerSubmitted.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<AnswerSubmitted>> getAnswersBySubmission(int submissionId) async {
    try {
      final response = await _apiClient.get(
          '/api/answers-submitted/submission/$submissionId');
      return (response.data as List)
          .map((json) => AnswerSubmitted.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAnswerSubmitted(int answerSubmittedId) async {
    try {
      await _apiClient.delete('/api/answers-submitted/$answerSubmittedId');
    } catch (e) {
      rethrow;
    }
  }
}