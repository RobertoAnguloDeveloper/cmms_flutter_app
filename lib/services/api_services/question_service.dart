import 'api_client.dart';
import '../../models/question.dart';

class QuestionService {
  final ApiClient _apiClient;

  QuestionService(this._apiClient);

  Future<List<Question>> getAllQuestions() async {
    try {
      final response = await _apiClient.get('/api/questions');
      return (response.data as List)
          .map((json) => Question.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Question> createQuestion({
    required String text,
    required int questionTypeId,
    bool isSignature = false,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post('/api/questions',
          data: {
            'text': text,
            'question_type_id': questionTypeId,
            'is_signature': isSignature,
            'remarks': remarks,
          });
      return Question.fromJson(response.data['question']);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Question>> searchQuestions({
    String? searchQuery,
    String? remarks,
    int? questionTypeId,
    int? environmentId,
  }) async {
    try {
      final response = await _apiClient.get('/api/questions/search',
          queryParameters: {
            if (searchQuery != null) 'text': searchQuery,
            if (remarks != null) 'remarks': remarks,
            if (questionTypeId != null) 'type_id': questionTypeId,
            if (environmentId != null) 'environment_id': environmentId,
          });
      return (response.data['results'] as List)
          .map((json) => Question.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Question> updateQuestion(
      int questionId, {
        String? text,
        int? questionTypeId,
        bool? isSignature,
        String? remarks,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/questions/$questionId',
        data: {
          if (text != null) 'text': text,
          if (questionTypeId != null) 'question_type_id': questionTypeId,
          if (isSignature != null) 'is_signature': isSignature,
          if (remarks != null) 'remarks': remarks,
        },
      );
      return Question.fromJson(response.data['question']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteQuestion(int questionId) async {
    try {
      await _apiClient.delete('/api/questions/$questionId');
    } catch (e) {
      rethrow;
    }
  }
}