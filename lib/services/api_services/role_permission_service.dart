import 'package:dio/dio.dart';
import '../../models/role.dart';
import '../../models/permission.dart';
import '../../models/role_permission.dart';
import 'api_client.dart';

// Custom exceptions
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

class RolePermissionService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/role-permissions';

  const RolePermissionService(this._apiClient);

  Future<RolePermission> assignPermissionToRole(int roleId, int permissionId) async {
    try {
      final response = await _apiClient.post(
        _basePath,
        data: {
          'role_id': roleId,
          'permission_id': permissionId,
        },
      );

      // Check if we have an error response
      if (response.statusCode == 403) {
        final errorMsg = response.data['error'] as String? ?? 'Unauthorized access';
        throw UnauthorizedException(errorMsg);
      }

      // Check if we have the expected data structure
      if (response.data == null || !response.data.containsKey('role_permission')) {
        throw ApiException('Invalid response format');
      }

      return RolePermission.fromJson(response.data['role_permission'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<RolePermission>> getAllRolePermissions() async {
    try {
      final response = await _apiClient.get(_basePath);
      return (response.data as List)
          .map((json) => RolePermission.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<List<Role>> getRolesWithPermissions() async {
    try {
      final response = await _apiClient.get('$_basePath/roles_with_permissions');
      return (response.data as List)
          .map((json) => Role.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> getPermissionsByRole(int roleId) async {
    try {
      final response = await _apiClient.get('$_basePath/role/$roleId/permissions');
      if (response.data == null) {
        throw ApiException('Invalid response format');
      }
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> removePermissionFromRole(int rolePermissionId) async {
    try {
      final response = await _apiClient.delete('$_basePath/$rolePermissionId');
      if (response.statusCode == 403) {
        final errorMsg = response.data['error'] as String? ?? 'Unauthorized access';
        throw UnauthorizedException(errorMsg);
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    if (e.response?.statusCode == 403) {
      final errorMsg = e.response?.data?['error'] as String? ?? 'Unauthorized access';
      return UnauthorizedException(errorMsg);
    }
    if (e.response?.statusCode == 404) {
      return NotFoundException('Resource not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data?['error'] as String? ?? 'Bad request';
      return BadRequestException(message);
    }
    return ApiException('Failed to complete role permission operation: ${e.message}');
  }
}