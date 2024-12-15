import 'api_client.dart';
import '../../models/question_type.dart';

class QuestionTypeService {
  final ApiClient _apiClient;

  QuestionTypeService(this._apiClient);

  Future<List<QuestionType>> getAllQuestionTypes() async {
    try {
      final response = await _apiClient.get('/api/question-types');
      return (response.data as List)
          .map((json) => QuestionType.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<QuestionType> createQuestionType({
    required String type,
  }) async {
    try {
      final response = await _apiClient.post('/api/question-types',
          data: {'type': type});
      return QuestionType.fromJson(response.data['question_type']);
    } catch (e) {
      rethrow;
    }
  }

  Future<QuestionType> updateQuestionType(
      int typeId, {
        required String type,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/question-types/$typeId',
        data: {'type': type},
      );
      return QuestionType.fromJson(response.data['question_type']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteQuestionType(int typeId) async {
    try {
      await _apiClient.delete('/api/question-types/$typeId');
    } catch (e) {
      rethrow;
    }
  }
}