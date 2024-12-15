// lib/services/api_services/user_service.dart
import 'api_client.dart';
import '../../models/user.dart';

class UserService {
  final ApiClient _apiClient;

  UserService(this._apiClient);

  Future<List<User>> getAllUsers({bool includeDeleted = false}) async {
    try {
      final response = await _apiClient.get('/api/users',
          queryParameters: {'include_deleted': includeDeleted});
      return (response.data as List)
          .map((json) => User.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<User> createUser(Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.post('/api/users/register',
          data: userData);
      return User.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<User> updateUser(int userId, Map<String, dynamic> userData) async {
    try {
      final response = await _apiClient.put('/api/users/$userId',
          data: userData);
      return User.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _apiClient.delete('/api/users/$userId');
    } catch (e) {
      rethrow;
    }
  }
}