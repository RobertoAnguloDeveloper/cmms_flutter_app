import 'package:dio/dio.dart';
import '../../models/answer.dart';
import 'api_client.dart';

class AnswerService {
  final ApiClient _apiClient;

  const AnswerService(this._apiClient);

  Future<List<Answer>> getAllAnswers() async {
    try {
      final response = await _apiClient.get('/api/answers');
      return (response.data as List)
          .map((json) => Answer.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Answer> createAnswer({
    required String value,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/answers',
        data: {
          'value': value,
          if (remarks != null) 'remarks': remarks,
        },
      );
      return Answer.fromJson(response.data['answer'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Answer>> bulkCreateAnswers(List<Map<String, dynamic>> answers) async {
    try {
      final response = await _apiClient.post(
        '/api/answers/bulk',
        data: {'answers': answers},
      );
      return (response.data['answers'] as List)
          .map((json) => Answer.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Answer> getAnswer(int answerId) async {
    try {
      final response = await _apiClient.get('/api/answers/$answerId');
      return Answer.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Answer>> getAnswersByForm(int formId) async {
    try {
      final response = await _apiClient.get('/api/answers/form/$formId');
      return (response.data as List)
          .map((json) => Answer.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
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
      return Answer.fromJson(response.data['answer'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteAnswer(int answerId) async {
    try {
      await _apiClient.delete('/api/answers/$answerId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return NotFoundException('Answer not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['error'] as String? ?? 'Bad request';
      return BadRequestException(message);
    }
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access');
    }
    return ApiException('Failed to complete answer operation: ${e.message}');
  }
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class NotFoundException extends ApiException {
  NotFoundException(super.message);
}

class BadRequestException extends ApiException {
  BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(super.message);
}