/*// lib/services/api_model_services/api_form_services/form_submission_view_service.dart


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

*/

// lib/services/api_model_services/api_form_services/form_submission_view_service.dart


/*
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
*/



/*
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
        throw Exception(
          'Failed to fetch form submissions. Status: ${response.statusCode}',
        );
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
  /// Ajusta la ruta si tu servidor no utiliza "/api".
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      // Verifica que el baseUrl no contenga ya /api y que la ruta exista en tu backend.
      final url = '${_http.baseUrl}/api/answers-submitted';
      print('[getAllSubmissions] GET => $url'); // Log de debug

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
        // Asegúrate de que la respuesta sea un objeto JSON
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map<String, dynamic>) {
          // Si necesitas que contenga una clave "answers", la validas aquí
          // Ejemplo rápido:
          // if (!decodedResponse.containsKey('answers')) {
          //   throw Exception('No se encontró la clave "answers" en la respuesta.');
          // }
          return decodedResponse;
        } else {
          throw Exception(
            'La respuesta no es un objeto JSON válido. Verifica el formato en el backend.',
          );
        }
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else if (response.statusCode == 404) {
        throw Exception(
          'Endpoint no encontrado (404). Verifica la URL en tu backend o la configuración de baseUrl.',
        );
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
      print('[getAllSubmissionsAlternative] GET => $url'); // Log de debug

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
        throw Exception('Endpoint /api/form-submissions/all no encontrado (404).');
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
      print('[getSubmissionDetails] GET => $url'); // Log de debug

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
        throw Exception('Endpoint no encontrado (404). Verifica la ruta en tu backend.');
      } else {
        throw Exception('Failed to load submission details');
      }
    } catch (e) {
      throw Exception('Error fetching submission details: $e');
    }
  }
}*/


/*
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
        throw Exception(
          'Failed to fetch form submissions. Status: ${response.statusCode}',
        );
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FormSubmissionView.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching form submissions: $e');
      throw Exception('Failed to load form submissions');
    }
  }

  /// Obtiene todas las submissions desde /api/answers-submitted.
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      final url = '${_http.baseUrl}/api/answers-submitted';
      print('[getAllSubmissions] GET => $url'); // Log de debug

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
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map<String, dynamic>) {
          return decodedResponse;
        } else {
          throw Exception(
            'La respuesta no es un objeto JSON válido. Verifica el formato en el backend.',
          );
        }
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else if (response.statusCode == 404) {
        throw Exception(
          'Endpoint no encontrado (404). Verifica la URL en tu backend o la configuración de baseUrl.',
        );
      } else {
        throw Exception('Failed to load submissions. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllSubmissions: $e');
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// Obtiene todas las submissions desde /api/form-submissions/all.
  Future<List<dynamic>> getAllSubmissionsAlternative(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final url = '${_http.baseUrl}/api/form-submissions/all';
      print('[getAllSubmissionsAlternative] GET => $url'); // Log de debug

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
        throw Exception('Endpoint /api/form-submissions/all no encontrado (404).');
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
      print('[getSubmissionDetails] GET => $url'); // Log de debug

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
        throw Exception('Endpoint no encontrado (404). Verifica la ruta en tu backend.');
      } else {
        throw Exception('Failed to load submission details');
      }
    } catch (e) {
      throw Exception('Error fetching submission details: $e');
    }
  }
}*/











/*
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../models/form_submission/form_submission_view.dart';
import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';
import 'dart:convert';

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
        throw Exception(
          'Failed to fetch form submissions. Status: ${response.statusCode}',
        );
      }

      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => FormSubmissionView.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching form submissions: $e');
      throw Exception('Failed to load form submissions');
    }
  }
/*
  /// Obtiene todas las submissions desde /api/answers-submitted.
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      //final url = '${_http.baseUrl}/api/answers-submitted';
      final url = '${_http.baseUrl}/answers-submitted';
      print('[getAllSubmissions] GET => $url'); // Log de debug

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
        final decodedResponse = json.decode(response.body);

        if (decodedResponse is Map<String, dynamic>) {
          return decodedResponse;
        } else {
          throw Exception(
            'La respuesta no es un objeto JSON válido. Verifica el formato en el backend.',
          );
        }
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else if (response.statusCode == 404) {
        throw Exception(
          'Endpoint no encontrado (404). Verifica la URL en tu backend o la configuración de baseUrl.',
        );
      } else {
        throw Exception('Failed to load submissions. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getAllSubmissions: $e');
      throw Exception('Error fetching submissions: $e');
    }
  }*/

/*
  /// Obtiene todas las submissions desde /answers-submitted.
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      // 1. Use the correct endpoint without /api prefix
      final url = '${_http.baseUrl}/answers-submitted';
      print('[getAllSubmissions] GET => $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[getAllSubmissions] Response Code => ${response.statusCode}');
      print('[getAllSubmissions] Response Body => ${response.body}');

      // 2. Handle different response statuses
      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        // 3. Validate response structure contains 'answers'
        if (decodedResponse is Map<String, dynamic> &&
            decodedResponse.containsKey('answers')) {
          return decodedResponse;
        } else {
          throw FormatException(
              'Invalid response format. Missing "answers" key. '
                  'Full response: ${response.body}'
          );
        }
      }
      else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired. Please login again.');
      }
      else if (response.statusCode == 404) {
        throw Exception(
            'Endpoint not found (404). Verify the URL is correct: $url\n'
                'Ensure your backend has the /answers-submitted endpoint configured.'
        );
      }
      else {
        throw Exception(
            'Failed to load submissions. '
                'Status: ${response.statusCode}\n'
                'Body: ${response.body}'
        );
      }
    }
    catch (e, stackTrace) {
      print('Error in getAllSubmissions: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to load submissions: ${e.toString()}');
    }
  }
*/

  /// Get all submissions from /answers-submitted
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final url = '${_http.baseUrl}/answers-submitted';
      print('[getAllSubmissions] GET => $url');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('[getAllSubmissions] Response Code: ${response.statusCode}');
      print('[getAllSubmissions] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        if (decoded is Map<String, dynamic> && decoded.containsKey('answers')) {
          return decoded;
        }
        throw FormatException('Invalid response format');
      }

      throw Exception('Failed to load submissions: ${response.statusCode}');
    } catch (e) {
      print('Error in getAllSubmissions: $e');
      throw Exception('Failed to load submissions: ${e.toString().replaceAll("Exception: ", "")}');
    }
  }


  /// Obtiene todas las submissions desde /api/form-submissions/all.
  Future<List<dynamic>> getAllSubmissionsAlternative(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final url = '${_http.baseUrl}/api/form-submissions/all';
      print('[getAllSubmissionsAlternative] GET => $url'); // Log de debug

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
        throw Exception('Endpoint /api/form-submissions/all no encontrado (404).');
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
      print('[getSubmissionDetails] GET => $url'); // Log de debug

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
        throw Exception('Endpoint no encontrado (404). Verifica la ruta en tu backend.');
      } else {
        throw Exception('Failed to load submission details');
      }
    } catch (e) {
      throw Exception('Error fetching submission details: $e');
    }
  }

  /// Método para probar distintos endpoints y ver sus respuestas.
  Future<void> testEndpoint(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      // Endpoints que queremos probar
      final endpoints = [
        '/api/answers-submitted',
        '/api/form-submissions',
        '/api/submissions'
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


/*
// lib/services/api_model_services/api_form_services/form_submission_view_service.dart

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '../../../models/form_submission/form_submission_view.dart';
import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';
import 'dart:convert';

class FormSubmissionViewService {
  final Http _http = Http();

  /// Get submissions for a specific form from the `/api/answers-submitted` endpoint,
  /// returning a typed List<FormSubmissionView>.
  Future<List<FormSubmissionView>> getFormSubmissions(int formId) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.get(
        Uri.parse('${_http.baseUrl}/answers-submitted?form_id=$formId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        // IMPORTANT: We assume each element in responseData['answers']
        // has this shape: {
        //    "id": <int>,
        //    "submitted_by": <string>,
        //    "submitted_at": <date string>,
        //    "answers": [ {...}, {...} ]
        // }
        //
        // If your backend actually returns single-answer objects,
        // you MUST adjust the structure or group them by submission_id.

        final List<dynamic> data = responseData['answers'] ?? [];

        // Convert each dynamic map into a FormSubmissionView
        return data
            .map((item) => FormSubmissionView.fromJson(item))
            .toList();
      } else {
        throw Exception(
            'Failed to fetch form submissions. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching form submissions: $e');
      throw Exception('Failed to load form submissions: $e');
    }
  }

  /// Get all submissions from the `/api/answers-submitted` endpoint
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      final url = '${_http.baseUrl}/api/answers-submitted';
      print('[getAllSubmissions] GET => $url');

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

  /// Obtiene todas las submissions desde /api/form-submissions/all.
  Future<List<dynamic>> getAllSubmissionsAlternative(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final url = '${_http.baseUrl}/api/form-submissions/all';
      print('[getAllSubmissionsAlternative] GET => $url'); // Log de debug

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print(
          '[getAllSubmissionsAlternative] Response => ${response.statusCode}');
      print('[getAllSubmissionsAlternative] Body => ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 404) {
        throw Exception(
            'Endpoint /api/form-submissions/all no encontrado (404).');
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
      print('[getSubmissionDetails] GET => $url'); // Log de debug

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

  /// Método para probar distintos endpoints y ver sus respuestas.
  Future<void> testEndpoint(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      // Endpoints que queremos probar
      final endpoints = [
        '/api/answers-submitted',
        '/api/form-submissions',
        '/api/submissions'
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



/*
// lib/services/api_model_services/api_form_services/form_submission_view_service.dart

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Ajusta estos imports según tu estructura real:
import '../../../models/form_submission/form_submission_view.dart';
import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class FormSubmissionViewService {
  final Http _http = Http();

  /// 1) Obtiene submissions de un formulario específico, usando:
  ///    GET /answers-submitted?form_id=$formId
  ///
  ///    Retorna una lista tipada de FormSubmissionView.
  Future<List<FormSubmissionView>> getFormSubmissions(int formId) async {
    try {
      String? token = await SessionManager.getToken();

      // Importante: Sin "/api", dado que en Postman llamas /answers-submitted.
      final url = '${_http.baseUrl}/answers-submitted?form_id=$formId';
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

        // Convertir cada elemento a FormSubmissionView
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

  /// 2) Obtiene TODAS las submissions desde la ruta GET /answers-submitted (sin /api).
  ///    Retorna un Map con keys: 'answers', 'total_count', 'filters_applied'.
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      // De nuevo, SIN /api para que coincida con tu Postman: /answers-submitted
      final url = '${_http.baseUrl}/answers-submitted';
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

  /// 3) Obtiene todas las submissions desde /api/form-submissions/all.
  ///    SOLO conserva este método si realmente tu backend define /api/form-submissions/all.
  ///
  ///    De lo contrario, quita /api o elimina el método.
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
                'Si tu server no tiene esa ruta, quita /api o elimina este método.'
        );
      } else {
        throw Exception('Failed to load submissions');
      }
    } catch (e) {
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// 4) Obtiene detalles de un submission en /api/form-submissions/$submissionId/details.
  ///    Mantén o elimina el "/api" según tu backend.
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

  /// 5) Método de prueba para distintos endpoints y verificar respuestas.
  ///    Ajusta según cuáles existan realmente en tu backend.
  Future<void> testEndpoint(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();

      // Prueba varias rutas para ver cuáles responden 200 vs 404/401, etc.
      final endpoints = [
        '/answers-submitted',
        '/api/answers-submitted',
        '/api/form-submissions',
        '/api/submissions'
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
