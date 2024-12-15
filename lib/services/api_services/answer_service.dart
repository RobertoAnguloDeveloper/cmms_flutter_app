import 'api_client.dart';
import '../../models/answer.dart';

class AnswerService {
  final ApiClient _apiClient;

  AnswerService(this._apiClient);

  Future<List<Answer>> getAllAnswers({bool includeDeleted = false}) async {
    try {
      final response = await _apiClient.get('/api/answers',
          queryParameters: {'include_deleted': includeDeleted});
      return (response.data as List)
          .map((json) => Answer.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Answer> createAnswer({
    required String value,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post('/api/answers',
          data: {
            'value': value,
            'remarks': remarks,
          });
      return Answer.fromJson(response.data['answer']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Answer> updateAnswer(
      int answerId, {
        String? value,
        String? remarks,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/answers/$answerId',
        data: {
          if (value != null) 'value': value,
          if (remarks != null) 'remarks': remarks,
        },
      );
      return Answer.fromJson(response.data['answer']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteAnswer(int answerId) async {
    try {
      await _apiClient.delete('/api/answers/$answerId');
    } catch (e) {
      rethrow;
    }
  }
}