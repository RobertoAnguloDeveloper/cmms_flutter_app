import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class FormApiService {
  // GET ALL FORMS
  Future<List<dynamic>> fetchForms(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/forms'),
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
          'Error retrieving forms: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while retrieving forms: $e');
    }
  }

  // GET FORMS BY ENVIRONMENT ID
  Future<List<dynamic>> fetchFormsByEnvironment(
      BuildContext context, int environmentId) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/forms/environment/$environmentId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        // Extraer la lista de formularios desde la clave "forms"
        if (responseData is Map<String, dynamic> &&
            responseData.containsKey('forms')) {
          return responseData['forms'] as List<dynamic>;
        }

        throw Exception('Unexpected response format');
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return [];
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error retrieving forms by environment: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while retrieving forms by environment: $e');
    }
  }

  // GET FORM BY ID
  Future<Map<String, dynamic>> fetchFormById(
      BuildContext context, int formId) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/forms/$formId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error retrieving form: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while retrieving form: $e');
    }
  }

  // REGISTER FORM
  Future<Map<String, dynamic>> RegisterForm(
      BuildContext context, Map<String, dynamic> formData) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/forms'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(formData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        responseData['status'] = response.statusCode;
        return responseData;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error creating form: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while creating form: $e');
    }
  }

  // UPDATE FORM
  Future<Map<String, dynamic>> updateForm(
    BuildContext context,
    int formId,
    Map<String, dynamic> formData,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.put(
        Uri.parse('${Http().baseUrl}/api/forms/$formId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(formData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        responseData['status'] = response.statusCode;
        return responseData;
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error updating form: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while updating form: $e');
    }
  }

  Future<Map<String, dynamic>> softDeleteForm(
    BuildContext context,
    int formId,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.delete(
        Uri.parse('${Http().baseUrl}/api/forms/$formId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        try {
          final responseData = json.decode(response.body);
          responseData['status'] = response.statusCode;
          return responseData;
        } catch (e) {
          return {
            'status': response.statusCode,
            'message': 'Form deleted successfully'
          };
        }
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else if (response.statusCode == 404) {
        throw Exception('Form not found');
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error deleting form: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      print('Error in softDeleteForm: $e');
      throw Exception('Exception while deleting form: $e');
    }
  }


/*
    // EXPORT FORM AS PDF
  Future<void> exportFormAsPDF(
    BuildContext context,
    int formId, {
    required int signatureCount,
    required Map<String, String> signatureDetails,
  }) async {
    try {
      String? token = await SessionManager.getToken();

      // Construir los parámetros del endpoint
      final queryParams = {
        'format': 'pdf',
        'signature_count': signatureCount.toString(),
        ...signatureDetails, // Agregar los detalles de las firmas dinámicamente
        'signature_space_before': '1',
        'signature_space_between': '8',
        'signature_space_date': '1',
        'signature_space_after': '0',
      };

      // Crear la URL con los parámetros
      final queryString = Uri(queryParameters: queryParams).query;
      final url = '${Http().baseUrl}/api/export/form/$formId?$queryString';

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Aquí podrías manejar la descarga del PDF, dependiendo de cómo desees implementarlo
        print('PDF exported successfully.');
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error exporting form as PDF: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while exporting form as PDF: $e');
    }
  }*/


  Future<void> exportFormAsPDF(
      BuildContext context,
      int formId, {
        required int signatureCount,
        required Map<String, String> signatureDetails,
      }) async {
    try {
      // No need for MANAGE_EXTERNAL_STORAGE here
      // Just ensure you have normal storage permission if required (on older Android versions)

      String? token = await SessionManager.getToken();

      final queryParams = {
        'format': 'pdf',
        'signature_count': signatureCount.toString(),
        'signature_space_before': '1',
        'signature_space_between': '8',
        'signature_space_date': '1',
        'signature_space_after': '0',
        ...signatureDetails,
      };

      final url = Uri.parse('${Http().baseUrl}/api/export/form/$formId')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      );

      if (response.statusCode == 200) {
        // Use app-specific external storage directory
        final directory = await getExternalStorageDirectory();
        if (directory == null) {
          throw Exception('No external storage directory found');
        }

        // Create a subdirectory for Downloads inside app external directory
        final downloadDir = Directory('${directory.path}/Download');
        if (!await downloadDir.exists()) {
          await downloadDir.create(recursive: true);
        }

        final fileName =
            'form_${formId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
        final filePath = '${downloadDir.path}/$fileName';
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        if (!context.mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved at: $filePath'),
            duration: const Duration(seconds: 3),
          ),
        );

        // Attempt to open the file
        final openResult = await OpenFile.open(filePath);
        if (openResult.type != ResultType.done) {
          // If it fails, let the user know
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Could not open PDF. Please install a PDF viewer.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Download error: ${response.statusCode}');
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error exporting PDF: $e'),
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showSaveDialog(BuildContext context, String filePath) async {
    try {
      await OpenFile.open(filePath);
      return true;
    } catch (e) {
      if (!context.mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al abrir el archivo: $e'),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }






}