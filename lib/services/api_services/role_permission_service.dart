import 'package:dio/dio.dart';
import '../../models/role.dart';
import '../../models/permission.dart';
import '../../models/role_permission.dart';
import 'api_client.dart';

class RolePermissionService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/role-permissions';

  const RolePermissionService(this._apiClient);

  Future<List<RolePermission>> getAllRolePermissions() async {
    try {
      final response = await _apiClient.get(_basePath);
      return (response.data as List)
          .map((json) => RolePermission.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<Role>> getRolesWithPermissions() async {
    try {
      final response = await _apiClient.get('$_basePath/roles_with_permissions');
      return (response.data as List)
          .map((json) => Role.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> getPermissionsByRole(int roleId) async {
    try {
      final response = await _apiClient.get('$_basePath/role/$roleId/permissions');
      return {
        'role': Role.fromJson(response.data['role'] as Map<String, dynamic>),
        'permissions': (response.data['permissions'] as List)
            .map((json) => Permission.fromJson(json as Map<String, dynamic>))
            .toList(),
      };
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> getRolesByPermission(int permissionId) async {
    try {
      final response = await _apiClient.get('$_basePath/permission/$permissionId/roles');
      return {
        'permission': Permission.fromJson(response.data['permission'] as Map<String, dynamic>),
        'roles': (response.data['roles'] as List)
            .map((json) => Role.fromJson(json as Map<String, dynamic>))
            .toList(),
      };
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<RolePermission> assignPermissionToRole(int roleId, int permissionId) async {
    try {
      final response = await _apiClient.post(
        _basePath,
        data: {
          'role_id': roleId,
          'permission_id': permissionId,
        },
      );
      return RolePermission.fromJson(response.data['role_permission'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<List<RolePermission>> bulkAssignPermissions({
    required int roleId,
    required List<int> permissionIds,
  }) async {
    try {
      final response = await _apiClient.post(
        '$_basePath/bulk-assign',
        data: {
          'role_id': roleId,
          'permission_ids': permissionIds,
        },
      );
      return (response.data['role_permissions'] as List)
          .map((json) => RolePermission.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> updateRolePermission(
      int rolePermissionId, {
        int? roleId,
        int? permissionId,
        bool? isDeleted,
      }) async {
    try {
      await _apiClient.put(
        '$_basePath/$rolePermissionId',
        data: {
          if (roleId != null) 'role_id': roleId,
          if (permissionId != null) 'permission_id': permissionId,
          if (isDeleted != null) 'is_deleted': isDeleted,
        },
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> removePermissionFromRole(int rolePermissionId) async {
    try {
      await _apiClient.delete('$_basePath/$rolePermissionId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access to role permission operation');
    }
    if (e.response?.data != null && e.response?.data['error'] != null) {
      return ApiException(e.response?.data['error'] as String);
    }
    return ApiException('Failed to process role permission operation: ${e.message}');
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