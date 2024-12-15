import 'api_client.dart';
import '../../models/role.dart';
import '../../models/permission.dart';

class RolePermissionService {
  final ApiClient _apiClient;

  RolePermissionService(this._apiClient);

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

  Future<void> removePermissionFromRole(int roleId, int permissionId) async {
    try {
      await _apiClient.delete('/api/role-permissions/$roleId/permissions/$permissionId');
    } catch (e) {
      rethrow;
    }
  }

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