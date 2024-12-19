import 'package:dio/dio.dart';
import '../../models/environment.dart';
import '../../models/user.dart';
import '../../models/form.dart';
import 'api_client.dart';

class EnvironmentService {
  final ApiClient _apiClient;

  const EnvironmentService(this._apiClient);

  Future<List<Environment>> getAllEnvironments({bool includeDeleted = false}) async {
    try {
      final response = await _apiClient.get(
        '/api/environments',
        queryParameters: {
          'include_deleted': includeDeleted.toString(),
        },
      );
      return (response.data as List)
          .map((json) => Environment.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Environment> getEnvironment(int environmentId) async {
    try {
      final response = await _apiClient.get('/api/environments/$environmentId');
      return Environment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Environment> getEnvironmentByName(String name) async {
    try {
      final response = await _apiClient.get('/api/environments/name/$name');
      return Environment.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Environment> createEnvironment({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/environments',
        data: {
          'name': name,
          if (description != null) 'description': description,
        },
      );
      return Environment.fromJson(response.data['environment'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Environment> updateEnvironment(
      int environmentId, {
        String? name,
        String? description,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/environments/$environmentId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );
      return Environment.fromJson(response.data['environment'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteEnvironment(int environmentId) async {
    try {
      await _apiClient.delete('/api/environments/$environmentId');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<User>> getEnvironmentUsers(int environmentId) async {
    try {
      final response = await _apiClient.get('/api/environments/$environmentId/users');
      return (response.data as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Form>> getEnvironmentForms(int environmentId) async {
    try {
      final response = await _apiClient.get('/api/environments/$environmentId/forms');
      return (response.data as List)
          .map((json) => Form.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      return NotFoundException('Environment not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['error'] as String? ?? 'Bad request';
      return BadRequestException(message);
    }
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access');
    }
    return ApiException('Failed to complete environment operation: ${e.message}');
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