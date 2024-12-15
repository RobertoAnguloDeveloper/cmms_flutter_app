import 'api_client.dart';
import '../../models/form_question.dart';

class FormQuestionService {
  final ApiClient _apiClient;

  FormQuestionService(this._apiClient);

  Future<List<FormQuestion>> getAllFormQuestions({bool includeRelations = true}) async {
    try {
      final response = await _apiClient.get('/api/form-questions',
          queryParameters: {'include_relations': includeRelations});
      return (response.data['items'] as List)
          .map((json) => FormQuestion.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<FormQuestion> createFormQuestion({
    required int formId,
    required int questionId,
    int? orderNumber,
  }) async {
    try {
      final response = await _apiClient.post('/api/form-questions',
          data: {
            'form_id': formId,
            'question_id': questionId,
            'order_number': orderNumber,
          });
      return FormQuestion.fromJson(response.data['form_question']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FormQuestion>> getQuestionsByForm(int formId) async {
    try {
      final response = await _apiClient.get('/api/form-questions/form/$formId');
      return (response.data['questions'] as List)
          .map((json) => FormQuestion.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<FormQuestion> updateFormQuestion(
      int formQuestionId, {
        int? orderNumber,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/form-questions/$formQuestionId',
        data: {
          if (orderNumber != null) 'order_number': orderNumber,
        },
      );
      return FormQuestion.fromJson(response.data['form_question']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFormQuestion(int formQuestionId) async {
    try {
      await _apiClient.delete('/api/form-questions/$formQuestionId');
    } catch (e) {
      rethrow;
    }
  }
}
