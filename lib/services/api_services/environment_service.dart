// lib/services/api_services/environment_service.dart
import '../../models/environment.dart';
import '../../models/user.dart';
import '../../models/form.dart';
import 'api_client.dart';

class EnvironmentService {
  final ApiClient _apiClient;

  EnvironmentService(this._apiClient);

  Future<List<Environment>> getAllEnvironments() async {
    try {
      final response = await _apiClient.get('/api/environments');
      return (response.data as List)
          .map((json) => Environment.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Environment> createEnvironment({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post('/api/environments',
          data: {
            'name': name,
            'description': description,
          });
      return Environment.fromJson(response.data['environment']);
    } catch (e) {
      rethrow;
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
      return Environment.fromJson(response.data['environment']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteEnvironment(int environmentId) async {
    try {
      await _apiClient.delete('/api/environments/$environmentId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<User>> getEnvironmentUsers(int environmentId) async {
    try {
      final response = await _apiClient.get('/api/environments/$environmentId/users');
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Form>> getEnvironmentForms(int environmentId) async {
    try {
      final response = await _apiClient.get('/api/environments/$environmentId/forms');
      return (response.data as List)
          .map((json) => Form.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}