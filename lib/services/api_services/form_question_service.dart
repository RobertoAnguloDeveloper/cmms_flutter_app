import 'package:dio/dio.dart';
import '../../models/form_question.dart';
import 'api_client.dart';

class FormQuestionService {
  final ApiClient _apiClient;

  const FormQuestionService(this._apiClient);

  Future<List<FormQuestion>> getAllFormQuestions({
    bool includeRelations = true,
    int? page,
    int? perPage,
    int? formId,
  }) async {
    try {
      final queryParameters = {
        'include_relations': includeRelations,
        if (page != null) 'page': page,
        if (perPage != null) 'per_page': perPage,
        if (formId != null) 'form_id': formId,
      };

      final response = await _apiClient.get(
        '/api/form-questions',
        queryParameters: queryParameters,
      );
      return (response.data['items'] as List)
          .map((json) => FormQuestion.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FormQuestion> createFormQuestion({
    required int formId,
    required int questionId,
    int? orderNumber,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/form-questions',
        data: {
          'form_id': formId,
          'question_id': questionId,
          if (orderNumber != null) 'order_number': orderNumber,
        },
      );
      return FormQuestion.fromJson(response.data['form_question'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<FormQuestion>> bulkCreateFormQuestions({
    required int formId,
    required List<Map<String, dynamic>> questions,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/form-questions/bulk',
        data: {
          'form_id': formId,
          'questions': questions,
        },
      );
      return (response.data['form_questions'] as List)
          .map((json) => FormQuestion.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FormQuestion> getFormQuestion(int formQuestionId) async {
    try {
      final response = await _apiClient.get('/api/form-questions/$formQuestionId');
      return FormQuestion.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<FormQuestion>> getQuestionsByForm(int formId) async {
    try {
      final response = await _apiClient.get('/api/form-questions/form/$formId');
      return (response.data['questions'] as List)
          .map((json) => FormQuestion.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FormQuestion> updateFormQuestion(
      int formQuestionId, {
        int? questionId,
        int? orderNumber,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/form-questions/$formQuestionId',
        data: {
          if (questionId != null) 'question_id': questionId,
          if (orderNumber != null) 'order_number': orderNumber,
        },
      );
      return FormQuestion.fromJson(response.data['form_question'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteFormQuestion(int formQuestionId) async {
    try {
      await _apiClient.delete('/api/form-questions/$formQuestionId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return NotFoundException('Form question not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['error'] as String? ?? 'Bad request';
      return BadRequestException(message);
    }
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access');
    }
    return ApiException('Failed to complete form question operation: ${e.message}');
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