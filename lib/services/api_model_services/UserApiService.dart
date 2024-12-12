import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../api_session_client_services/ApiResponseHandler.dart';
import '../api_session_client_services/Http.dart';
import '../api_session_client_services/SessionManager.dart';

class UserApiService {
  //GET ALL USERS
  Future<List<dynamic>> fetchUsers(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/users'),
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
      throw Exception('Exception while retrieving users: $e');
    }
  }

  Future<List<dynamic>> fetchAllUsers(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/users?include_deleted=true'),
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
      throw Exception('Exception while retrieving users: $e');
    }
  }

//GET USERS BY ENVIRONMENT
  Future<List<dynamic>> fetchUsersByEnvironment(
    BuildContext context,
    int environmentId,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/users/byEnvironment/$environmentId'),
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
        return [];
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error fetching users by environment: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching users by environment: $e');
    }
  }

  // REGISTER USER
  Future<Map<String, dynamic>> registerUser(
      BuildContext context, dynamic data) async {
    try {
      String? token = await SessionManager.getToken();

      final url = Uri.parse('${Http().baseUrl}/api/users/register');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(data),
      );

      print('Status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        responseData['status'] = response.statusCode;
        return responseData;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);

        if (responseData['error'] == 'Username already exists') {
          return {'status': 400, 'error': 'Username already exists'};
        } else if (responseData['error'] == 'Email already exists') {
          return {'status': 400, 'error': 'Email already exists'};
        } else {
          throw Exception(
              'Error register users: ${responseData['message'] ?? response.statusCode}');
        }
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error register users: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception while registering user: $e');
    }
  }

  //DELETE USER
  Future<void> deleteUser(BuildContext context, int userId) async {
    try {
      String? token = await SessionManager.getToken();
      final url = Uri.parse('${Http().baseUrl}/api/users/$userId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('User deleted successfully.');
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error delete users: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception while deleting user: $e');
    }
  }

  //UPDATE USER
  Future<Map<String, dynamic>> updateUser(BuildContext context, int userId,
      Map<String, dynamic> updatedData) async {
    try {
      String? token = await SessionManager.getToken();

      final url = Uri.parse('${Http().baseUrl}/api/users/$userId');
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updatedData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        responseData['status'] = response.statusCode;
        return responseData;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);

        if (responseData['error'] ==
            'Error: Username or email already exists') {
          return {
            'status': 400,
            'error': 'Error: Username or email already exists'
          };
        } else {
          throw Exception(
              'Error register users: ${responseData['message'] ?? response.statusCode}');
        }
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error updating users: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception while updating user: $e');
    }
  }
}
