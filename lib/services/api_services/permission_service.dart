import 'api_client.dart';
import '../../models/permission.dart';

class PermissionService {
  final ApiClient _apiClient;

  PermissionService(this._apiClient);

  Future<List<Permission>> getAllPermissions() async {
    try {
      final response = await _apiClient.get('/api/permissions');
      return (response.data as List)
          .map((json) => Permission.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Permission> createPermission({
    required String name,
    String? description,
  }) async {
    try {
      final response = await _apiClient.post('/api/permissions',
          data: {
            'name': name,
            'description': description,
          });
      return Permission.fromJson(response.data['permission']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Permission> updatePermission(
      int permissionId, {
        String? name,
        String? description,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/permissions/$permissionId',
        data: {
          if (name != null) 'name': name,
          if (description != null) 'description': description,
        },
      );
      return Permission.fromJson(response.data['permission']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deletePermission(int permissionId) async {
    try {
      await _apiClient.delete('/api/permissions/$permissionId');
    } catch (e) {
      rethrow;
    }
  }
}