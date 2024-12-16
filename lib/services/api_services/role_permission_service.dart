import 'api_client.dart';
import '../../models/role.dart';
import '../../models/permission.dart';

class RolePermissionService {
  final ApiClient _apiClient;

  RolePermissionService(this._apiClient);

  /// Get all roles with their associated permissions
  Future<Map<String, List<Permission>>> getRolesWithPermissions() async {
    try {
      final response = await _apiClient.get('/api/role-permissions/roles_with_permissions');
      final Map<String, List<Permission>> rolesWithPermissions = {};

      final data = response.data as Map<String, dynamic>;
      data.forEach((roleKey, permissions) {
        rolesWithPermissions[roleKey] = (permissions as List)
            .map((json) => Permission.fromJson(json))
            .toList();
      });

      return rolesWithPermissions;
    } catch (e) {
      rethrow;
    }
  }

  /// Get permissions for a specific role
  Future<List<Permission>> getPermissionsByRole(int roleId) async {
    try {
      final response = await _apiClient.get('/api/role-permissions/role/$roleId/permissions');
      final data = response.data;
      return (data['permissions'] as List)
          .map((json) => Permission.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Get roles that have a specific permission
  Future<List<Role>> getRolesByPermission(int permissionId) async {
    try {
      final response = await _apiClient.get('/api/role-permissions/permission/$permissionId/roles');
      return (response.data['roles'] as List)
          .map((json) => Role.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  /// Assign a permission to a role
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

  /// Remove a permission from a role
  Future<void> removePermissionFromRole(int roleId, int permissionId) async {
    try {
      await _apiClient.delete('/api/role-permissions/$roleId/permissions/$permissionId');
    } catch (e) {
      rethrow;
    }
  }

  /// Bulk assign permissions to a role
  Future<void> bulkAssignPermissions({
    required int roleId,
    required List<int> permissionIds,
  }) async {
    try {
      await _apiClient.post('/api/role-permissions/bulk-assign',
          data: {
            'role_id': roleId,
            'permission_ids': permissionIds,
          });
    } catch (e) {
      rethrow;
    }
  }
}