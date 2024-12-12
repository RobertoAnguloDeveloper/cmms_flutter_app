import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../api_session_client_services/ApiResponseHandler.dart';
import '../api_session_client_services/Http.dart';
import '../api_session_client_services/SessionManager.dart';

class RoleApiService {
  //GET ALL ROLES
  Future<List<dynamic>> fetchRoles(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/roles'),
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
      throw Exception('Exception while retrieving roles: $e');
    }
  }

  Future<List<dynamic>> fetchAllRoles(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/roles?include_deleted=true'),
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
      throw Exception('Exception while retrieving roles: $e');
    }
  }

  //REGISTER ROLE
  Future<void> registerRole(
    BuildContext context,
    Map<String, dynamic> roleData,
    Function(String) onSuccess,
    Function(String) onError,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/roles'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(roleData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess('Role registered successfully');
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('error')) {
          String errorMessage = responseData['error'];

          if (errorMessage.contains('roles_name_key') ||
              errorMessage.contains('Ya existe la llave')) {
            errorMessage =
                'This role already exists. Please try with a different role.';
          }

          onError(errorMessage);
        } else {
          onError('Error: ${response.body}');
        }
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        onError('Session expired. Redirecting to login.');
      } else {
        onError('Unexpected error occurred.');
      }
    } catch (e) {
      onError('Error: $e');
    }
  }

  //UPDATE ROLE
  Future<Map<String, dynamic>> updateRole(
    BuildContext context,
    int roleId,
    Map<String, dynamic> roleData,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.put(
        Uri.parse('${Http().baseUrl}/api/roles/$roleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(roleData),
      );

      if (response.statusCode == 200) {
        return {
          "status": response.statusCode,
          "message": "Role updated successfully"
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired. Redirecting to login.');
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);

        if (responseData['error'] == 'A role with this name already exists') {
          return {
            'status': 400,
            'error': 'A role with this name already exists'
          };
        } else {
          throw Exception(
              'Error register users: ${responseData['message'] ?? response.statusCode}');
        }
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error updating role: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating role: $e');
    }
  }

  //DELETE ROLE
  Future<Map<String, dynamic>> deleteRole(
      BuildContext context, int roleId) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.delete(
        Uri.parse('${Http().baseUrl}/api/roles/$roleId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'status': response.statusCode,
          'message': 'Role deleted successfully'
        };
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('error') &&
            responseData['error'] == 'Cannot delete role with active users') {
          return {
            'status': 400,
            'error': responseData['error'],
            'active_users': responseData['active_users'],
            'suggestion': responseData['suggestion'],
            'role': responseData['role'],
          };
        } else {
          // Otros errores
          throw Exception(
              'Error deleting role: ${responseData['message'] ?? response.statusCode}');
        }
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired. Redirecting to login.');
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error deleting role: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting role: $e');
    }
  }
}
