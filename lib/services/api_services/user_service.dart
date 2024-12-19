import 'package:dio/dio.dart';
import '../../models/user.dart';
import 'api_client.dart';

class UserService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/users';

  const UserService(this._apiClient);

  Future<List<User>> getAllUsers({bool includeDeleted = false}) async {
    try {
      final response = await _apiClient.get(
        _basePath,
        queryParameters: {
          if (includeDeleted) 'include_deleted': 'true',
        },
      );
      return (response.data as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<User>> getUsersByRole(int roleId) async {
    try {
      final response = await _apiClient.get('$_basePath/byRole/$roleId');

      // Ensure we're working with a List and handle the response properly
      final List<dynamic> dataList = response.data is List ? response.data : [response.data];

      return dataList.map((json) {
        // Convert to Map<String, dynamic> if needed
        final Map<String, dynamic> userMap = json is Map<String, dynamic>
            ? json
            : Map<String, dynamic>.from(json as Map);

        return User.fromJson(userMap);
      }).toList();
    } catch (e, stackTrace) {
      print('Error in getUsersByRole: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<List<User>> getUsersByEnvironment(int environmentId) async {
    try {
      final response = await _apiClient.get('$_basePath/byEnvironment/$environmentId');
      return (response.data as List)
          .map((json) => User.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _apiClient.get('$_basePath/current');
      return User.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<User> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required String contactNumber,
    required String username,
    required String password,
    required int roleId,
    required int environmentId,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_basePath/register',
        data: {
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'contact_number': contactNumber,
          'username': username,
          'password': password,
          'role_id': roleId,
          'environment_id': environmentId,
        },
      );
      return User.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<User> updateUser(
      int userId, {
        String? firstName,
        String? lastName,
        String? email,
        String? contactNumber,
        String? username,
        String? password,
        int? roleId,
        int? environmentId,
      }) async {
    try {
      final response = await _apiClient.put(
        '$_basePath/$userId',
        data: {
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (email != null) 'email': email,
          if (contactNumber != null) 'contact_number': contactNumber,
          if (username != null) 'username': username,
          if (password != null) 'password': password,
          if (roleId != null) 'role_id': roleId,
          if (environmentId != null) 'environment_id': environmentId,
        },
      );
      return User.fromJson(response.data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteUser(int userId) async {
    try {
      await _apiClient.delete('$_basePath/$userId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    print('Error response: ${e.response?.data}'); // Add logging for debugging
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access to user operation');
    }
    if (e.response?.data != null && e.response?.data['error'] != null) {
      return ApiException(e.response?.data['error'] as String);
    }
    return ApiException('Failed to process user operation: ${e.message}');
  }
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
  @override
  String toString() => message;
}

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}