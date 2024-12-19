import 'package:dio/dio.dart';
import '../../models/question_type.dart';
import 'api_client.dart';

class QuestionTypeService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/question-types';

  const QuestionTypeService(this._apiClient);

  Future<List<QuestionType>> getAllQuestionTypes() async {
    try {
      final response = await _apiClient.get(_basePath);
      return (response.data as List)
          .map((json) => QuestionType.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<QuestionType> getQuestionType(int id) async {
    try {
      final response = await _apiClient.get('$_basePath/$id');
      return QuestionType.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<QuestionType> createQuestionType({
    required String type,
  }) async {
    try {
      final response = await _apiClient.post(
        _basePath,
        data: {'type': type.trim()},
      );
      return QuestionType.fromJson(response.data['question_type'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<QuestionType> updateQuestionType(
      int typeId, {
        required String type,
      }) async {
    try {
      final response = await _apiClient.put(
        '$_basePath/$typeId',
        data: {'type': type.trim()},
      );
      return QuestionType.fromJson(response.data['question_type'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteQuestionType(int typeId) async {
    try {
      await _apiClient.delete('$_basePath/$typeId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access to question type operation');
    }
    if (e.response?.data != null && e.response?.data['error'] != null) {
      return ApiException(e.response?.data['error'] as String);
    }
    return ApiException('Failed to process question type operation: ${e.message}');
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