import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../components/SnackBarUtil.dart';
import '../../models/user_management_models/Role.dart';
import '../api_session_client_services/ApiResponseHandler.dart';
import '../api_session_client_services/Http.dart';
import '../api_session_client_services/SessionManager.dart';

class PermissionApiService {
  //GET ALL PERMISSIONS
  Future<List<dynamic>> fetchPermissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/permissions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as List<dynamic>;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error retrieving users: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception while retrieving permissions: $e');
    }
  }

  //REGISTER PERMISSION
  Future<void> registerPermission(
    BuildContext context,
    Map<String, dynamic> permissionData,
    Function(String) onSuccess,
    Function(String) onError,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/permissions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(permissionData),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess('Role registered successfully');
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        onError('Session expired. Redirecting to login.');
      } else {
        onError('Unexpected error occurred.');
      }
    } catch (e) {
      throw Exception('Exception while registering permission: $e');
    }
  }

  //UPDATE PERMISSIONS
  Future<Map<String, dynamic>> updatePermission(
    BuildContext context,
    int permissionId,
    Map<String, dynamic> permissionData,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.put(
        Uri.parse('${Http().baseUrl}/api/permissions/$permissionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(permissionData),
      );

      if (response.statusCode == 200) {
        return {
          "status": response.statusCode,
          "message": "Permission updated successfully"
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired. Redirecting to login.');
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error updating permission: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating permission: $e');
    }
  }

  // DELETE PERMISSION
Future<Map<String, dynamic>> deletePermission(
    BuildContext context, int permissionId) async {
  try {
    String? token = await SessionManager.getToken();
    final response = await http.delete(
      Uri.parse('${Http().baseUrl}/api/permissions/$permissionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200 || response.statusCode == 204) {
      print('Permission deleted successfully.');
      return {
        'status': response.statusCode,
        'message': 'Permission deleted successfully',
      };
    } else if (response.statusCode == 400) {
      final responseData = json.decode(response.body);
      if (responseData['error'] != null &&
          responseData['error'].contains('Cannot delete permission')) {
        // Retornar el error dinámico
        return {
          'status': response.statusCode,
          'error': responseData['error'],
        };
      } else {
        return {
          'status': response.statusCode,
          'error': 'An unexpected error occurred while deleting the permission',
        };
      }
    } else if (response.statusCode == 401) {
      final responseData = json.decode(response.body);

      // Manejo del token expirado
      await ApiResponseHandler.handleExpiredToken(context, responseData);
      throw Exception('Session expired. Redirecting to login.');
    } else {
      final responseData = json.decode(response.body);
      throw Exception(
          'Error deleting permission: ${responseData['message'] ?? response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error deleting permission: $e');
  }
}


  //  GET PERMISSIONS BY ROLE
  Future<Map<String, dynamic>> fetchPermissionsByRole(
      BuildContext context, int roleId) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.get(
        Uri.parse(
            '${Http().baseUrl}/api/role-permissions/role/$roleId/permissions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        final role = Role.fromJson(jsonResponse['role']);
        final permissions = (jsonResponse['permissions'] as List)
            .map((permissionJson) => {
                  'id': permissionJson['id'],
                  'name': permissionJson['name'],
                  'description': permissionJson['description'],
                  'role_permission_id': permissionJson['role_permission_id'],
                })
            .toList();

        return {
          'role': role,
          'permissions': permissions,
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired. Redirecting to login.');
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error retrieving permissions: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception while retrieving permissions: $e');
    }
  }

  // ASSIGN PERMISSIONS
  Future<Map<String, dynamic>> bulkAssignPermissions(
      BuildContext context, int roleId, List<int> permissionIds) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/role-permissions/bulk-assign'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'role_id': roleId,
          'permission_ids': permissionIds,
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired. Redirecting to login.');
      } else {
        throw Exception('Error assigning permissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception while assigning permissions: $e');
    }
  }

  // DELETE PERMISSIIONS FOR ROLE
  Future<bool> removePermissionFromRole(
      BuildContext context, int rolePermissionId) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.delete(
        Uri.parse('${Http().baseUrl}/api/role-permissions/$rolePermissionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        SnackBarUtil.showCustomSnackBar(
          context: context,
          message: result['message'] ?? 'Permission removed successfully',
          duration: const Duration(milliseconds: 500),
        );

        return true;
      } else if (response.statusCode == 401) {
        // Manejo del token expirado
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired. Redirecting to login.');
      } else {
        final error = json.decode(response.body);
        _showErrorSnackBar(
            context, error['error'] ?? 'Failed to remove permission');
        return false;
      }
    } catch (e) {
      if (!e.toString().contains('Session expired')) {
        _showErrorSnackBar(context, 'Exception while removing permission: $e');
      }
      return false;
    }
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text(message)),
    // );
  }
}
