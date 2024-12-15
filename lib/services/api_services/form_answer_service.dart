import 'api_client.dart';
import '../../models/form_answer.dart';

class FormAnswerService {
  final ApiClient _apiClient;

  FormAnswerService(this._apiClient);

  Future<FormAnswer> createFormAnswer({
    required int formQuestionId,
    required int answerId,
  }) async {
    try {
      final response = await _apiClient.post('/api/form-answers',
          data: {
            'form_question_id': formQuestionId,
            'answer_id': answerId,
          });
      return FormAnswer.fromJson(response.data['form_answer']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FormAnswer>> getAnswersByQuestion(int formQuestionId) async {
    try {
      final response = await _apiClient.get('/api/form-answers/question/$formQuestionId');
      return (response.data as List)
          .map((json) => FormAnswer.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFormAnswer(int formAnswerId) async {
    try {
      await _apiClient.delete('/api/form-answers/$formAnswerId');
    } catch (e) {
      rethrow;
    }
  }
}