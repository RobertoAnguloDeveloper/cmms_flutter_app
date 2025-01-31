/*



// lib/services/api_model_services/api_form_services/form_submission_view_service.dart

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Ajusta estos imports según tu estructura real de archivos
import '../../../models/form_submission/form_submission_view.dart';
import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class FormSubmissionViewService {
  final Http _http = Http();

  /// 1) Obtiene submissions de un formulario específico
  ///    Ruta: GET /api/answers-submitted?form_id=$formId
  ///    Devuelve List<FormSubmissionView>.
  Future<List<FormSubmissionView>> getFormSubmissions(int formId) async {
    try {
      // Asegúrate de usar un formId válido (> 0).
      String? token = await SessionManager.getToken();

      final url = '${_http.baseUrl}/api/answers-submitted?form_id=$formId';
      print('[getFormSubmissions] GET => $url');
      print('[getFormSubmissions] Token => $token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[getFormSubmissions] Response => ${response.statusCode}');
      print('[getFormSubmissions] Body => ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['answers'] ?? [];

        return data
            .map((item) => FormSubmissionView.fromJson(item))
            .toList();
      } else {
        throw Exception(
          'Failed to fetch form submissions. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching form submissions: $e');
      throw Exception('Failed to load form submissions: $e');
    }
  }

  /// 2) Obtiene TODAS las submissions usando GET /api/answers-submitted
  ///    Retorna un Map con 'answers', 'total_count', 'filters_applied'.
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      final url = '${_http.baseUrl}/api/answers-submitted';
      print('[getAllSubmissions] GET => $url');
      print('[getAllSubmissions] Token => $token');

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
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'answers': responseData['answers'] ?? [],
          'total_count': responseData['total_count'] ?? 0,
          'filters_applied': responseData['filters_applied'] ?? {},
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else {
        throw Exception(
          'Failed to load submissions. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getAllSubmissions: $e');
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// 3) Obtiene submissions desde /api/form-submissions/all (si tu backend lo define)
  Future<List<dynamic>> getAllSubmissionsAlternative(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final url = '${_http.baseUrl}/api/form-submissions/all';
      print('[getAllSubmissionsAlternative] GET => $url');

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
      } else if (response.statusCode == 404) {
        throw Exception(
            'Endpoint /api/form-submissions/all no encontrado (404). '
                'Si no existe esa ruta, elimínalo o ajusta la URL.'
        );
      } else {
        throw Exception('Failed to load submissions');
      }
    } catch (e) {
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// 4) Obtiene los detalles de una submission en /api/form-submissions/$submissionId/details
  ///    Mantén /api si tu backend realmente lo requiere.
  Future<Map<String, dynamic>> getSubmissionDetails(
      BuildContext context,
      int submissionId,
      ) async {
    try {
      String? token = await SessionManager.getToken();
      final url = '${_http.baseUrl}/api/form-submissions/$submissionId/details';
      print('[getSubmissionDetails] GET => $url');

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
      } else if (response.statusCode == 404) {
        throw Exception(
            'Endpoint no encontrado (404). Verifica la ruta en tu backend.');
      } else {
        throw Exception('Failed to load submission details');
      }
    } catch (e) {
      throw Exception('Error fetching submission details: $e');
    }
  }

  /// 5) Método para probar endpoints y ver sus status codes
  ///    Ajusta si en verdad tienes esas rutas en tu backend
  Future<void> testEndpoint(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      // Prueba distintos endpoints para ver cuál regresa 200.
      final endpoints = [
        '/api/answers-submitted',
        '/api/form-submissions',
        '/api/submissions',
      ];

      for (var endpoint in endpoints) {
        final url = '${_http.baseUrl}$endpoint';
        print('Testing endpoint: $url');

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('Response for $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      print('Error testing endpoints: $e');
    }
  }
}




 */



// lib/services/api_model_services/api_form_services/form_submission_view_service.dart

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Ajusta estos imports según tu estructura
import '../../../models/form_submission/answer_view.dart';
import '../../../models/form_submission/form_submission_view.dart';
import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class FormSubmissionViewService {
  final Http _http = Http();

  /// 1) Obtiene submissions de un formulario específico
  ///    Ruta: GET /api/answers-submitted?form_id=$formId
  ///    Retorna una lista de FormSubmissionView, con respuestas agrupadas.
  Future<List<FormSubmissionView>> getFormSubmissions(int formId) async {
    try {
      String? token = await SessionManager.getToken();

      final url = '${_http.baseUrl}/api/answers-submitted?form_id=$formId';
      print('[getFormSubmissions] GET => $url');
      print('[getFormSubmissions] Token => $token');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[getFormSubmissions] Response => ${response.statusCode}');
      print('[getFormSubmissions] Body => ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> data = responseData['answers'] ?? [];

        // Mapa para agrupar por submissionId
        final Map<int, FormSubmissionView> submissionsMap = {};

        // Recorremos cada "answer item"
        for (var item in data) {
          // Estructura esperada de "item":
          // {
          //   "id": 13,
          //   "answer": "3",
          //   "question": "Example",
          //   "question_type": "checkbox",
          //   "form_submission": {
          //     "id": 53,
          //     "submitted_at": "...",
          //     "submitted_by": "admin",
          //     "form": {
          //       "id": 5,
          //       "title": "FormTest"
          //     }
          //   }
          //   ...
          // }

          final formSubmission = item['form_submission'] ?? {};
          final submissionId = formSubmission['id'] ?? 0;
          final submittedBy = formSubmission['submitted_by'] ?? '';
          final submittedAtStr = formSubmission['submitted_at'] ?? '';
          final formData = formSubmission['form'] ?? {};
          final formTitle = formData['title'] ?? '';

          // Parseamos fecha
          DateTime parsedDate = DateTime.now();
          if (submittedAtStr.isNotEmpty) {
            parsedDate = DateTime.parse(submittedAtStr);
          }

          // Si no existe todavía, lo creamos
          if (!submissionsMap.containsKey(submissionId)) {
            submissionsMap[submissionId] = FormSubmissionView(
              submissionId: submissionId,
              formTitle: formTitle,
              submittedBy: submittedBy,
              submittedAt: parsedDate,
              answers: [],
            );
          }

          // Construimos un AnswerView
          final answerView = AnswerView(
            question: item['question'] ?? '',
            questionType: item['question_type'] ?? '',
            answer: item['answer'] ?? '',
          );

          // Agregamos la respuesta a la lista de answers
          submissionsMap[submissionId]!.answers.add(answerView);
        }

        // Convertimos el map en una lista final
        return submissionsMap.values.toList();
      } else {
        throw Exception(
          'Failed to fetch form submissions. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error fetching form submissions: $e');
      throw Exception('Failed to load form submissions: $e');
    }
  }

  /// 2) Obtiene TODAS las submissions usando GET /api/answers-submitted
  ///    Retorna un Map con 'answers', 'total_count', 'filters_applied'.
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      final url = '${_http.baseUrl}/api/answers-submitted';
      print('[getAllSubmissions] GET => $url');
      print('[getAllSubmissions] Token => $token');

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
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'answers': responseData['answers'] ?? [],
          'total_count': responseData['total_count'] ?? 0,
          'filters_applied': responseData['filters_applied'] ?? {},
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else {
        throw Exception(
          'Failed to load submissions. Status: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in getAllSubmissions: $e');
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// 3) Obtiene submissions desde /api/form-submissions/all (si tu backend lo define)
  Future<List<dynamic>> getAllSubmissionsAlternative(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final url = '${_http.baseUrl}/api/form-submissions/all';
      print('[getAllSubmissionsAlternative] GET => $url');

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
      } else if (response.statusCode == 404) {
        throw Exception(
            'Endpoint /api/form-submissions/all no encontrado (404). '
                'Si no existe esa ruta, elimínalo o ajústala en tu backend.'
        );
      } else {
        throw Exception('Failed to load submissions');
      }
    } catch (e) {
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// 4) Obtiene los detalles de una submission en /api/form-submissions/$submissionId/details
  Future<Map<String, dynamic>> getSubmissionDetails(
      BuildContext context,
      int submissionId,
      ) async {
    try {
      String? token = await SessionManager.getToken();
      final url = '${_http.baseUrl}/api/form-submissions/$submissionId/details';
      print('[getSubmissionDetails] GET => $url');

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
      } else if (response.statusCode == 404) {
        throw Exception(
            'Endpoint no encontrado (404). Verifica la ruta en tu backend.');
      } else {
        throw Exception('Failed to load submission details');
      }
    } catch (e) {
      throw Exception('Error fetching submission details: $e');
    }
  }

  /// 5) Método para probar endpoints y ver sus status codes
  Future<void> testEndpoint(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      final endpoints = [
        '/api/answers-submitted',
        '/api/form-submissions',
        '/api/submissions',
      ];

      for (var endpoint in endpoints) {
        final url = '${_http.baseUrl}$endpoint';
        print('Testing endpoint: $url');

        final response = await http.get(
          Uri.parse(url),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        print('Response for $endpoint: ${response.statusCode}');
      }
    } catch (e) {
      print('Error testing endpoints: $e');
    }
  }
}
