// lib/services/api_model_services/api_form_services/form_submission_view_service.dart


import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../models/form_submission/form_submission_view.dart';
import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class FormSubmissionViewService {
  final Http _http = Http();

  /// Obtiene las submissions de un formulario específico [formId].
  Future<List<FormSubmissionView>> getFormSubmissions(int formId) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${_http.baseUrl}/api/form-submissions/$formId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to fetch form submissions. Status: ${response.statusCode}');
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FormSubmissionView.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching form submissions: $e');
      throw Exception('Failed to load form submissions');
    }
  }

  /// Obtiene todas las submissions desde /api/answers-submitted (ruta ajustada).
  /// Retorna un Map<String, dynamic> con la clave principal "answers".
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      // Ajusta a la ruta real que maneje tu servidor.
      // Si NO usas "/api", entonces cambia a '/answers-submitted'.
      final url = '${_http.baseUrl}/api/answers-submitted';
      print('[getAllSubmissions] GET => $url'); // LOG de debug

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[getAllSubmissions] Response Code => ${response.statusCode}');
      print('[getAllSubmissions] Response Body => ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load submissions. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllSubmissions: $e');
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// Obtiene todas las submissions desde /api/form-submissions/all (opcional).
  /// Si no la necesitas, puedes omitir este método.
  Future<List<dynamic>> getAllSubmissionsAlternative(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final url = '${_http.baseUrl}/api/form-submissions/all';
      print('[getAllSubmissionsAlternative] GET => $url'); // LOG de debug

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[getAllSubmissionsAlternative] Response => ${response.statusCode}');
      print('[getAllSubmissionsAlternative] Body => ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load submissions');
      }
    } catch (e) {
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// Obtiene los detalles de una submission [submissionId].
  Future<Map<String, dynamic>> getSubmissionDetails(
      BuildContext context,
      int submissionId,
      ) async {
    try {
      String? token = await SessionManager.getToken();
      final url = '${_http.baseUrl}/api/form-submissions/$submissionId/details';
      print('[getSubmissionDetails] GET => $url'); // LOG de debug

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[getSubmissionDetails] Response => ${response.statusCode}');
      print('[getSubmissionDetails] Body => ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load submission details');
      }
    } catch (e) {
      throw Exception('Error fetching submission details: $e');
    }
  }
}



