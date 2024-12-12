import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../api_session_client_services/ApiResponseHandler.dart';
import '../api_session_client_services/Http.dart';
import '../api_session_client_services/SessionManager.dart';

class EnvironmentApiService {
  //GET ALL ENVIRONMENT
  Future<List<dynamic>> fetchEnvironment(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/environments'),
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
            'Error retrieving environments: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception while retrieving environments: $e');
    }
  }

  Future<List<dynamic>> fetchAllEnvironment(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/environments?include_deleted=true'),
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
            'Error retrieving environments: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Exception while retrieving environments: $e');
    }
  }

  //REGISTER ENVIRONMENT
  Future<void> registerEnvironment(
    BuildContext context,
    Map<String, dynamic> environmentData,
    Function(String) onSuccess,
    Function(String) onError,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/environments'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(environmentData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        onSuccess('Environment registered successfully');
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);

        if (responseData.containsKey('error')) {
          String errorMessage = responseData['error'];

          if (errorMessage.contains('environments_name_key') ||
              errorMessage.contains('Ya existe la llave')) {
            errorMessage =
                'This environment already exists. Please try with a different environment.';
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
      onError('Exception while saving environment: $e');
    }
  }

  //UPDATE ENVIRONMENT
  Future<Map<String, dynamic>> updateEnvironment(BuildContext context,
      int environmentId, Map<String, dynamic> environmentData) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.put(
        Uri.parse('${Http().baseUrl}/api/environments/$environmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(environmentData),
      );

      if (response.statusCode == 200) {
        return {
          "status": response.statusCode,
          "message": "Environment updated successfully"
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired. Redirecting to login.');
      } else if (response.statusCode == 400) {
        final responseData = json.decode(response.body);

        if (responseData['error'] ==
            'An environment with this name already exists') {
          return {
            'status': 400,
            'error': 'An environment with this name already exists'
          };
        } else {
          throw Exception(
              'Error register users: ${responseData['message'] ?? response.statusCode}');
        }
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error updating environment: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating environment: $e');
    }
  }

  //DELETE ENVIRONMENT
  Future<Map<String, dynamic>> deleteEnvironment(
      BuildContext context, int environmentId) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.delete(
        Uri.parse('${Http().baseUrl}/api/environments/$environmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('Environment deleted successfully.');
        return {
          'status': response.statusCode,
          'message': 'Environment deleted successfully'
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);

        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired. Redirecting to login.');
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
            'Error deleting environment: ${responseData['message'] ?? response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting environment: $e');
    }
  }
}
