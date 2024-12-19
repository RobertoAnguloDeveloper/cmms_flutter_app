// lib/services/api_services/auth_service.dart
import 'api_client.dart';
import '../../models/user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiClient.post('/api/users/login',
          data: {
            'username': username,
            'password': password,
          }
      );

      // Handle raw response for login
      if (response.statusCode == 200) {
        return response.data;
      } else {
        throw ApiException(
          response.data['error'] ?? 'Login failed',
          response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('/api/users/current');
      return User.fromJson(response.data);
    } catch (e) {
      rethrow;
    }
  }
}