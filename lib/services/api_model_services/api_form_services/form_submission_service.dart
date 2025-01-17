/*// lib/services/api_model_services/api_form_services/form_submission_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class FormSubmissionService {
  final Http _http = Http();

  Future<Map<String, dynamic>> submitFormWithAnswers({
    required BuildContext context,
    required int formId,
    required Map<int, dynamic> answers,
    required List<String> attachmentPaths,
    required List<dynamic> questions,
    required int userId,
  }) async {
    try {
      String? token = await SessionManager.getToken();

      print('Preparing form submission:');
      print('Form ID: $formId');
      print('User ID: $userId');
      print('Number of answers: ${answers.length}');

      // First, create the form submission
      var submissionUri = Uri.parse('${_http.baseUrl}/api/form-submissions');
      var submissionResponse = await http.post(
        submissionUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'form_id': formId,
          'submitted_by': userId,  // Use the passed userId
        }),
      );

      if (submissionResponse.statusCode != 201) {
        throw Exception('Failed to create form submission: ${submissionResponse.body}');
      }

      final submissionData = json.decode(submissionResponse.body);
      final submissionId = submissionData['id'];

      // Now submit each answer
      var answersUri = Uri.parse('${_http.baseUrl}/answers-submitted');

      for (var entry in answers.entries) {
        var question = questions.firstWhere(
              (q) => q['id'] == entry.key,
          orElse: () => null,
        );

        if (question == null) continue;

        var answerResponse = await http.post(
          answersUri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode({
            'form_submission_id': submissionId,
            'question_text': question['text'],
            'answer_text': entry.value.toString(),
          }),
        );

        if (answerResponse.statusCode != 201) {
          print('Failed to submit answer: ${answerResponse.body}');
        }
      }

      // Handle attachments if any
      if (attachmentPaths.isNotEmpty) {
        var attachmentsUri = Uri.parse('${_http.baseUrl}/api/attachments');

        for (var filePath in attachmentPaths) {
          var request = http.MultipartRequest('POST', attachmentsUri);
          request.headers['Authorization'] = 'Bearer $token';

          request.fields['form_submission_id'] = submissionId.toString();

          File file = File(filePath);
          String fileName = filePath.split('/').last;

          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              filePath,
              filename: fileName,
            ),
          );

          var attachmentResponse = await request.send();
          if (attachmentResponse.statusCode != 201) {
            print('Failed to upload attachment: $fileName');
          }
        }
      }

      return {'status': 'success', 'submission_id': submissionId};
    } catch (e, stackTrace) {
      print('Error in submitFormWithAnswers: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to submit form: $e');
    }
  }


}

*/


/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class FormSubmissionService {
  final Http _http = Http();

  Future<Map<String, dynamic>> submitFormWithAnswers({
    required BuildContext context,
    required int formId,
    required Map<int, dynamic> answers,
    required List<String> attachmentPaths,
    required List<dynamic> questions,
    required int userId,
  }) async {
    try {
      String? token = await SessionManager.getToken();

      // 1. Create form submission
      final submissionData = {
        'form_id': formId,
        'submitted_by': userId,
        'submitted_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
      };

      var submissionUri = Uri.parse('${_http.baseUrl}/api/form-submissions');
      var submissionResponse = await http.post(
        submissionUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(submissionData),
      );

      if (submissionResponse.statusCode != 201) {
        throw Exception('Failed to create form submission: ${submissionResponse.body}');
      }

      final submissionResult = json.decode(submissionResponse.body);
      final submissionId = submissionResult['id'];

      // 2. Submit answers
      var answersUri = Uri.parse('${_http.baseUrl}/api/answers-submitted');

      for (var entry in answers.entries) {
        var question = questions.firstWhere(
              (q) => q['id'] == entry.key,
          orElse: () => null,
        );

        if (question == null) continue;

        final answerData = {
          'form_submission_id': submissionId,
          'question': question['text'],
          'question_type': question['type'],
          'answer': entry.value.toString(),
        };

        var answerResponse = await http.post(
          answersUri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(answerData),
        );

        if (answerResponse.statusCode != 201) {
          throw Exception('Failed to submit answer: ${answerResponse.body}');
        }
      }

      // 3. Handle attachments
      if (attachmentPaths.isNotEmpty) {
        var attachmentsUri = Uri.parse('${_http.baseUrl}/api/attachments');

        for (var filePath in attachmentPaths) {
          if (!await File(filePath).exists()) {
            print('Warning: File not found - $filePath');
            continue;
          }

          var request = http.MultipartRequest('POST', attachmentsUri);
          request.headers['Authorization'] = 'Bearer $token';

          String fileName = filePath.split('/').last;
          String fileType = fileName.split('.').last.toLowerCase();

          request.fields.addAll({
            'form_submission_id': submissionId.toString(),
            'file_type': fileType,
            'file_path': fileName,
            'is_signature': (fileType == 'sig').toString(),
          });

          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              filePath,
              filename: fileName,
            ),
          );

          var attachmentResponse = await request.send();
          var responseBody = await http.Response.fromStream(attachmentResponse);

          if (attachmentResponse.statusCode != 201) {
            throw Exception('Failed to upload attachment: ${responseBody.body}');
          }
        }
      }

      return {
        'status': 'success',
        'submission_id': submissionId,
        'message': 'Form submitted successfully'
      };

    } catch (e, stackTrace) {
      print('Error in submitFormWithAnswers: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to submit form: $e');
    }
  }
}*/

/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class FormSubmissionService {
  final Http _http = Http();

  Future<Map<String, dynamic>> submitFormWithAnswers({
    required BuildContext context,
    required int formId,
    required Map<int, dynamic> answers,
    required List<String> attachmentPaths,
    required List<dynamic> questions,
    required int userId,
  }) async {
    try {
      String? token = await SessionManager.getToken();

      // 1. Create form submission
      final submissionData = {
        'form_id': formId,
        'submitted_by': userId,
        'submitted_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
      };

      var submissionUri = Uri.parse('${_http.baseUrl}/api/form-submissions');
      var submissionResponse = await http.post(
        submissionUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(submissionData),
      );

      if (submissionResponse.statusCode != 201) {
        throw Exception('Failed to create form submission: ${submissionResponse.body}');
      }

      final submissionResult = json.decode(submissionResponse.body);
      final submissionId = submissionResult['id'];

      // 2. Submit answers
      var answersUri = Uri.parse('${_http.baseUrl}/api/answers-submitted');

      for (var entry in answers.entries) {
        var question = questions.firstWhere(
              (q) => q['id'] == entry.key,
          orElse: () => null,
        );

        if (question == null) continue;

        // Use the exact field names required by the API
        final answerData = {
          'form_submission_id': submissionId,
          'question_text': question['text'],
          'question_type_text': question['type'],
          'answer_text': entry.value.toString()
        };

        var answerResponse = await http.post(
          answersUri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(answerData),
        );

        if (answerResponse.statusCode != 201) {
          throw Exception('Failed to submit answer: ${answerResponse.body}');
        }
      }

      // 3. Handle attachments
      if (attachmentPaths.isNotEmpty) {
        var attachmentsUri = Uri.parse('${_http.baseUrl}/api/attachments');

        for (var filePath in attachmentPaths) {
          if (!await File(filePath).exists()) {
            print('Warning: File not found - $filePath');
            continue;
          }

          var request = http.MultipartRequest('POST', attachmentsUri);
          request.headers['Authorization'] = 'Bearer $token';

          String fileName = filePath.split('/').last;
          String fileType = fileName.split('.').last.toLowerCase();

          request.fields.addAll({
            'form_submission_id': submissionId.toString(),
            'file_type': fileType,
            'file_path': fileName,
            'is_signature': (fileType == 'sig').toString(),
          });

          request.files.add(
            await http.MultipartFile.fromPath(
              'file',
              filePath,
              filename: fileName,
            ),
          );

          var attachmentResponse = await request.send();
          var responseBody = await http.Response.fromStream(attachmentResponse);

          if (attachmentResponse.statusCode != 201) {
            throw Exception('Failed to upload attachment: ${responseBody.body}');
          }
        }
      }

      return {
        'status': 'success',
        'submission_id': submissionId,
        'message': 'Form submitted successfully'
      };

    } catch (e, stackTrace) {
      print('Error in submitFormWithAnswers: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to submit form: $e');
    }
  }
}*/



/*
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class FormSubmissionService {
  final Http _http = Http();

  /// Formatea el valor de la respuesta antes de enviarla
  /// - Si es una lista, la convierte a string separado por comas (si está vacía, retorna '')
  /// - En caso contrario, lo convierte a string (si es null, retorna cadena vacía)
  String formatAnswerValue(dynamic value, String questionType) {
    if (value is List) {
      // Convierte valores de lista a string y maneja listas vacías
      return value.isEmpty ? '' : value.join(',');
    }
    return value?.toString() ?? '';
  }

  Future<Map<String, dynamic>> submitFormWithAnswers({
    required BuildContext context,
    required int formId,
    required Map<int, dynamic> answers,
    required List<String> attachmentPaths,
    required List<dynamic> questions,
    required int userId,
  }) async {
    try {
      String? token = await SessionManager.getToken();

      // 1. Crear el "form submission"
      final submissionData = {
        'form_id': formId,
        'submitted_by': userId,
        'submitted_at': DateTime.now().toIso8601String(),
        'is_deleted': false,
      };

      var submissionUri = Uri.parse('${_http.baseUrl}/api/form-submissions');
      var submissionResponse = await http.post(
        submissionUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(submissionData),
      );

      if (submissionResponse.statusCode != 201) {
        throw Exception('Failed to create form submission: ${submissionResponse.body}');
      }

      final submissionResult = json.decode(submissionResponse.body);

      // Extraer y validar correctamente el ID de la submission
      // En algunos casos viene dentro de 'data' y en otros como 'id' directamente
      final submissionId = submissionResult['data']?['id'] ?? submissionResult['id'];
      if (submissionId == null) {
        throw Exception('Invalid submission ID in response: ${submissionResponse.body}');
      }

      // 2. Enviar las respuestas
      var answersUri = Uri.parse('${_http.baseUrl}/api/answers-submitted');

      for (var entry in answers.entries) {
        var question = questions.firstWhere(
              (q) => q['id'] == entry.key,
          orElse: () => null,
        );

        if (question == null) {
          print('Warning: Question not found for ID ${entry.key}');
          continue;
        }

        // Formateo de la respuesta en función del tipo de pregunta
        String formattedAnswer = formatAnswerValue(entry.value, question['type']);

        final answerData = {
          'form_submission_id': submissionId.toString(), // Convertir a String
          'question_text': question['text'] ?? '',
          'question_type_text': question['type'] ?? '',
          'answer_text': formattedAnswer,
        };

        print('Submitting answer with payload: ${json.encode(answerData)}');

        var answerResponse = await http.post(
          answersUri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(answerData),
        );

        if (answerResponse.statusCode != 201) {
          print('Failed answer submission response: ${answerResponse.body}');
          throw Exception('Failed to submit answer: ${answerResponse.body}');
        }
      }

      // 3. Manejar los archivos adjuntos
      if (attachmentPaths.isNotEmpty) {
        var attachmentsUri = Uri.parse('${_http.baseUrl}/api/attachments');

        for (var filePath in attachmentPaths) {
          if (!await File(filePath).exists()) {
            print('Warning: File not found - $filePath');
            continue;
          }

          var request = http.MultipartRequest('POST', attachmentsUri);
          request.headers['Authorization'] = 'Bearer $token';

          request.fields['form_submission_id'] = submissionId.toString();
          request.fields['file_type'] = filePath.split('.').last.toLowerCase();
          request.fields['file_path'] = filePath.split('/').last;

          // Agregar el archivo adjunto
          request.files.add(
            await http.MultipartFile.fromPath('file', filePath),
          );

          var attachmentResponse = await request.send();
          if (attachmentResponse.statusCode != 201) {
            var responseBody = await http.Response.fromStream(attachmentResponse);
            throw Exception('Failed to upload attachment: ${responseBody.body}');
          }
        }
      }

      return {
        'status': 'success',
        'submission_id': submissionId,
        'message': 'Form submitted successfully'
      };

    } catch (e, stackTrace) {
      print('Error in submitFormWithAnswers: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to submit form: $e');
    }
  }
}*/

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class FormSubmissionService {
  final Http _http = Http();

  String formatAnswerValue(dynamic value, String questionType) {
    if (value is List) {
      return value.isEmpty ? '' : value.join(',');
    } else if (questionType == 'date') {
      try {
        // Ensure proper date formatting
        DateTime date = DateTime.parse(value.toString());
        return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
      } catch (e) {
        print('Error formatting date: $e');
        return value?.toString() ?? '';
      }
    }
    return value?.toString() ?? '';
  }

  Future<Map<String, dynamic>> submitFormWithAnswers({
    required BuildContext context,
    required int formId,
    required Map<int, dynamic> answers,
    required List<String> attachmentPaths,
    required List<dynamic> questions,
    required int userId,
  }) async {
    try {
      String? token = await SessionManager.getToken();

      // 1. Create form submission
      final submissionData = {
        'form_id': formId,
        'submitted_by': userId,
      };

      print('Creating form submission with data: ${json.encode(submissionData)}');

      var submissionUri = Uri.parse('${_http.baseUrl}/api/form-submissions');
      var submissionResponse = await http.post(
        submissionUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(submissionData),
      );

      print('Form submission response: ${submissionResponse.body}');

      if (submissionResponse.statusCode != 201) {
        throw Exception('Failed to create form submission: ${submissionResponse.body}');
      }

      final submissionResult = json.decode(submissionResponse.body);
      int? submissionId;

      // Handle different response structures
      if (submissionResult is Map) {
        submissionId = submissionResult['id'] ??
            submissionResult['data']?['id'] ??
            submissionResult['submission']?['id'];
      }

      if (submissionId == null) {
        throw Exception('Invalid submission ID in response');
      }

      // 2. Submit answers
      var answersUri = Uri.parse('${_http.baseUrl}/api/answers-submitted');

      for (var entry in answers.entries) {
        var question = questions.firstWhere(
              (q) => q['id'] == entry.key,
          orElse: () => null,
        );

        if (question == null) continue;

        String formattedAnswer = formatAnswerValue(entry.value, question['type']);

        final answerData = {
          'form_submission_id': submissionId,
          'question_text': question['text'],
          'question_type_text': question['type'],
          'answer_text': formattedAnswer
        };

        print('Submitting answer: ${json.encode(answerData)}');

        var answerResponse = await http.post(
          answersUri,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
          body: json.encode(answerData),
        );

        print('Answer submission response: ${answerResponse.body}');

        if (answerResponse.statusCode != 201) {
          throw Exception('Failed to submit answer: ${answerResponse.body}');
        }
      }

      // 3. Handle attachments
      if (attachmentPaths.isNotEmpty) {
        var attachmentsUri = Uri.parse('${_http.baseUrl}/api/attachments');

        for (var filePath in attachmentPaths) {
          if (!await File(filePath).exists()) {
            print('Warning: File not found - $filePath');
            continue;
          }

          var request = http.MultipartRequest('POST', attachmentsUri);
          request.headers['Authorization'] = 'Bearer $token';

          request.fields['form_submission_id'] = submissionId.toString();
          String fileName = filePath.split('/').last;
          request.fields['file_type'] = fileName.split('.').last.toLowerCase();
          request.fields['file_path'] = fileName;

          request.files.add(
            await http.MultipartFile.fromPath('file', filePath),
          );

          var attachmentResponse = await request.send();
          if (attachmentResponse.statusCode != 201) {
            var responseBody = await http.Response.fromStream(attachmentResponse);
            throw Exception('Failed to upload attachment: ${responseBody.body}');
          }
        }
      }

      return {
        'status': 'success',
        'submission_id': submissionId,
        'message': 'Form submitted successfully'
      };

    } catch (e, stackTrace) {
      print('Error in submitFormWithAnswers: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to submit form: $e');
    }
  }
}



