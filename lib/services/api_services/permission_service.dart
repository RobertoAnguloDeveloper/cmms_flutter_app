import 'package:dio/dio.dart';
import '../../models/permission.dart';
import 'api_client.dart';

class PermissionService {
  final ApiClient _apiClient;
  static const _baseUrl = '/api/permissions';

  PermissionService(this._apiClient);

  Future<List<Permission>> getAllPermissions() async {
    final response = await _apiClient.get(_baseUrl);
    return (response.data as List).map((json) => Permission.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Permission> getPermission(int id) async {
    final response = await _apiClient.get('$_baseUrl/$id');
    return Permission.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Permission> createPermission({
    required String name,
    String? description,
  }) async {
    final response = await _apiClient.post(
      _baseUrl,
      data: {
        'name': name,
        'description': description,
      },
    );
    return Permission.fromJson(response.data['permission'] as Map<String, dynamic>);
  }

  Future<Permission> updatePermission(
      int id, {
        String? name,
        String? description,
      }) async {
    final response = await _apiClient.put(
      '$_baseUrl/$id',
      data: {
        if (name != null) 'name': name,
        if (description != null) 'description': description,
      },
    );
    return Permission.fromJson(response.data['permission'] as Map<String, dynamic>);
  }

  Future<void> deletePermission(int id) async {
    await _apiClient.delete('$_baseUrl/$id');
  }

  Future<List<Permission>> getRolePermissions(int roleId) async {
    final response = await _apiClient.get('/api/role-permissions/role/$roleId/permissions');
    return (response.data['permissions'] as List)
        .map((json) => Permission.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<bool> checkUserPermission(int userId, String permissionName) async {
    final response = await _apiClient.get('$_baseUrl/check/$userId/$permissionName');
    return response.data['has_permission'] as bool;
  }
}