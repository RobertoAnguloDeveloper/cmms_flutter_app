import 'package:dio/dio.dart';
import '../../models/role.dart';
import '../../models/permission.dart';
import 'api_client.dart';

class RoleService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/roles';

  const RoleService(this._apiClient);

  Future<List<Role>> getAllRoles() async {
    try {
      final response = await _apiClient.get(_basePath);
      return (response.data as List)
          .map((json) => Role.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Role> getRole(int id) async {
    try {
      final response = await _apiClient.get('$_basePath/$id');
      return Role.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Role> createRole({
    required String name,
    String? description,
    bool isSuperUser = false,
  }) async {
    try {
      final response = await _apiClient.post(
        _basePath,
        data: {
          'name': name,
          if (description != null) 'description': description,
          'is_super_user': isSuperUser,
        },
      );
      return Role.fromJson(response.data['role'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Role> updateRole(
      int roleId, {
        String? name,
        String? description,
        bool? isSuperUser,
      }) async {
    try {
      final response = await _apiClient.put(
        '$_basePath/$roleId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (isSuperUser != null) 'is_super_user': isSuperUser,
        },
      );
      return Role.fromJson(response.data['role'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> deleteRole(int roleId) async {
    try {
      await _apiClient.delete('$_basePath/$roleId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> removePermissionFromRole(int roleId, int permissionId) async {
    try {
      await _apiClient.delete('$_basePath/$roleId/permissions/$permissionId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access to role operation');
    }
    if (e.response?.data != null && e.response?.data['error'] != null) {
      return ApiException(e.response?.data['error'] as String);
    }
    return ApiException('Failed to process role operation: ${e.message}');
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