import 'package:dio/dio.dart';
import '../../models/form.dart';
import '../../models/form_submission.dart';
import 'api_client.dart';

class FormService {
  final ApiClient _apiClient;

  const FormService(this._apiClient);

  Future<List<Form>> getAllForms() async {
    try {
      final response = await _apiClient.get('/api/forms');
      return (response.data as List)
          .map((json) => Form.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Form> getForm(int formId) async {
    try {
      final response = await _apiClient.get('/api/forms/$formId');
      return Form.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Form>> getFormsByEnvironment(int environmentId) async {
    try {
      final response = await _apiClient.get('/api/forms/environment/$environmentId');
      return (response.data['forms'] as List)
          .map((json) => Form.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Form>> getPublicForms() async {
    try {
      final response = await _apiClient.get('/api/forms/public');
      return (response.data as List)
          .map((json) => Form.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Form>> getFormsByCreator(String username) async {
    try {
      final response = await _apiClient.get('/api/forms/creator/$username');
      return (response.data as List)
          .map((json) => Form.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Form> createForm({
    required String title,
    String? description,
    bool isPublic = false,
    int? userId,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/forms',
        data: {
          'title': title,
          if (description != null) 'description': description,
          'is_public': isPublic,
          if (userId != null) 'user_id': userId,
        },
      );
      return Form.fromJson(response.data['form'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Form> updateForm(
      int formId, {
        String? title,
        String? description,
        bool? isPublic,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/forms/$formId',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (isPublic != null) 'is_public': isPublic,
        },
      );
      return Form.fromJson(response.data['form'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteForm(int formId) async {
    try {
      await _apiClient.delete('/api/forms/$formId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getFormStatistics(int formId) async {
    try {
      final response = await _apiClient.get('/api/forms/$formId/statistics');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return NotFoundException('Form not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['error'] as String? ?? 'Bad request';
      return BadRequestException(message);
    }
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access');
    }
    return ApiException('Failed to complete form operation: ${e.message}');
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