import 'package:dio/dio.dart';
import '../../models/form_answer.dart';
import 'api_client.dart';

class FormAnswerService {
  final ApiClient _apiClient;

  const FormAnswerService(this._apiClient);

  Future<FormAnswer> createFormAnswer({
    required int formQuestionId,
    required int answerId,
    String? remarks,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/form-answers',
        data: {
          'form_question_id': formQuestionId,
          'answer_id': answerId,
          if (remarks != null) 'remarks': remarks,
        },
      );
      return FormAnswer.fromJson(response.data['form_answer'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<FormAnswer>> bulkCreateFormAnswers(
      List<Map<String, dynamic>> formAnswers,
      ) async {
    try {
      final response = await _apiClient.post(
        '/api/form-answers/bulk',
        data: {'form_answers': formAnswers},
      );
      return (response.data['form_answers'] as List)
          .map((json) => FormAnswer.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<FormAnswer>> getAllFormAnswers() async {
    try {
      final response = await _apiClient.get('/api/form-answers');
      return (response.data as List)
          .map((json) => FormAnswer.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<FormAnswer>> getAnswersByQuestion(int formQuestionId) async {
    try {
      final response = await _apiClient.get('/api/form-answers/question/$formQuestionId');
      return (response.data as List)
          .map((json) => FormAnswer.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FormAnswer> getFormAnswer(int formAnswerId) async {
    try {
      final response = await _apiClient.get('/api/form-answers/$formAnswerId');
      return FormAnswer.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<FormAnswer> updateFormAnswer(
      int formAnswerId, {
        int? answerId,
        int? formQuestionId,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/form-answers/$formAnswerId',
        data: {
          if (answerId != null) 'answer_id': answerId,
          if (formQuestionId != null) 'form_question_id': formQuestionId,
        },
      );
      return FormAnswer.fromJson(response.data['form_answer'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteFormAnswer(int formAnswerId) async {
    try {
      await _apiClient.delete('/api/form-answers/$formAnswerId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return NotFoundException('Form answer not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['error'] as String? ?? 'Bad request';
      return BadRequestException(message);
    }
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access');
    }
    return ApiException('Failed to complete form answer operation: ${e.message}');
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