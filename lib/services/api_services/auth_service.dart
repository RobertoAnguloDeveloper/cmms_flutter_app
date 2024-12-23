import 'api_client.dart';
import '../../models/user.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _apiClient.post(
        '/api/users/login',
        data: {
          'username': username,
          'password': password,
        },
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

  Future<User> updateCurrentUser({
    String? firstName,
    String? lastName,
    String? email,
    String? contactNumber,
  }) async {
    try {
      final response = await _apiClient.put(
        '/api/users/current',
        data: {
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (email != null) 'email': email,
          if (contactNumber != null) 'contact_number': contactNumber,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          response.data['error'] ?? 'Failed to update user',
          response.statusCode,
        );
      }

      return User.fromJson(response.data['user']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/users/change-password',
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          response.data['error'] ?? 'Failed to change password',
          response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> requestPasswordReset(String email) async {
    try {
      final response = await _apiClient.post(
        '/api/users/reset-password',
        data: {
          'email': email,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          response.data['error'] ?? 'Failed to request password reset',
          response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> verifyPasswordResetToken(String token) async {
    try {
      final response = await _apiClient.get(
        '/api/users/verify-reset-token/$token',
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _apiClient.post(
        '/api/users/reset-password/$token',
        data: {
          'new_password': newPassword,
        },
      );

      if (response.statusCode != 200) {
        throw ApiException(
          response.data['error'] ?? 'Failed to reset password',
          response.statusCode,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}