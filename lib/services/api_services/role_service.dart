// lib/services/api_services/role_service.dart
import '../../models/role.dart';
import '../../models/permission.dart';
import 'api_client.dart';

class RoleService {
  final ApiClient _apiClient;

  RoleService(this._apiClient);

  Future<List<Role>> getAllRoles() async {
    try {
      final response = await _apiClient.get('/api/roles');
      return (response.data as List)
          .map((json) => Role.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Role> createRole({
    required String name,
    String? description,
    bool isSuperUser = false,
  }) async {
    try {
      final response = await _apiClient.post('/api/roles',
          data: {
            'name': name,
            'description': description,
            'is_super_user': isSuperUser,
          });
      return Role.fromJson(response.data['role']);
    } catch (e) {
      rethrow;
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
        '/api/roles/$roleId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
          if (isSuperUser != null) 'is_super_user': isSuperUser,
        },
      );
      return Role.fromJson(response.data['role']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRole(int roleId) async {
    try {
      await _apiClient.delete('/api/roles/$roleId');
    } catch (e) {
      rethrow;
    }
  }

  Future<void> assignPermissionToRole(int roleId, int permissionId) async {
    try {
      await _apiClient.post('/api/role-permissions',
          data: {
            'role_id': roleId,
            'permission_id': permissionId,
          });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removePermissionFromRole(
      int roleId,
      int permissionId,
      ) async {
    try {
      await _apiClient.delete('/api/roles/$roleId/permissions/$permissionId');
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Permission>> getRolePermissions(int roleId) async {
    try {
      final response = await _apiClient.get('/api/roles/$roleId/permissions');
      return (response.data['permissions'] as List)
          .map((json) => Permission.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }
}