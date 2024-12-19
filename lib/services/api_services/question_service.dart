import 'package:dio/dio.dart';
import '../../models/question.dart';
import 'api_client.dart';

class QuestionService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/questions';

  const QuestionService(this._apiClient);

  Future<List<Question>> getAllQuestions() async {
    try {
      final response = await _apiClient.get(_basePath);
      return (response.data as List)
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<Question>> getQuestionsByType(int typeId) async {
    try {
      final response = await _apiClient.get('$_basePath/by-type/$typeId');
      return (response.data as List)
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Question> getQuestion(int id) async {
    try {
      final response = await _apiClient.get('$_basePath/$id');
      return Question.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Question> createQuestion({
    required String text,
    required int questionTypeId,
    bool isSignature = false,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post(
        _basePath,
        data: {
          'text': text,
          'question_type_id': questionTypeId,
          'is_signature': isSignature,
          if (remarks != null) 'remarks': remarks,
        },
      );
      return Question.fromJson(response.data['question'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<Question>> searchQuestions({
    String? text,
    String? remarks,
    int? typeId,
  }) async {
    try {
      final response = await _apiClient.get(
        '$_basePath/search',
        queryParameters: {
          if (text != null) 'text': text,
          if (remarks != null) 'remarks': remarks,
          if (typeId != null) 'type_id': typeId,
        },
      );
      return (response.data['results'] as List)
          .map((json) => Question.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
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
        '$_basePath/$questionId',
        data: {
          if (text != null) 'text': text,
          if (questionTypeId != null) 'question_type_id': questionTypeId,
          if (isSignature != null) 'is_signature': isSignature,
          if (remarks != null) 'remarks': remarks,
        },
      );
      return Question.fromJson(response.data['question'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteQuestion(int questionId) async {
    try {
      await _apiClient.delete('$_basePath/$questionId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access to question operation');
    }
    if (e.response?.data != null && e.response?.data['error'] != null) {
      return ApiException(e.response?.data['error'] as String);
    }
    return ApiException('Failed to process question operation: ${e.message}');
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}