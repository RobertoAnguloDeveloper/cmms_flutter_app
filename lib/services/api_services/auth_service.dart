// lib/services/api_services/auth_service.dart
import 'api_client.dart';
import '../../models/user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<String> login(String username, String password) async {
    try {
      final response = await _apiClient.post('/api/login', data: {
        'username': username,
        'password': password,
      });
      return response.data['access_token'];
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