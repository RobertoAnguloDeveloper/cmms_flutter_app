import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class FormSubmissionService {
  final Http _http = Http();

  String formatAnswerValue(dynamic value, String questionType) {
    if (value is List) {
      return value.isEmpty ? '' : value.join(',');
    } else if (questionType == 'date') {
      try {
        // Si la fecha ya está en formato dd/MM/yyyy, no la cambiamos
        if (value.toString().contains('/')) {
          return value.toString();
        }

        // Asegurar formato de fecha adecuado, convirtiendo de yyyy-MM-dd a dd/MM/yyyy si es necesario
        DateTime date = DateTime.parse(value.toString());
        return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
      } catch (e) {
        print('Error formatting date: $e');
        return value?.toString() ?? '';
      }
    }
    return value?.toString() ?? '';
  }

  // Path: lib/services/api_model_services/form_submission_service.dart
// Modificar el método submitFormWithAnswers para ordenar las respuestas según el orden de las preguntas

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
      final submissionData = {'form_id': formId};

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

      if (submissionResponse.statusCode == 401) {
        await ApiResponseHandler.handleExpiredToken(
            context, json.decode(submissionResponse.body));
        throw Exception('Token expired. Please log in again.');
      }

      print('Form submission response: ${submissionResponse.body}');

      if (submissionResponse.statusCode != 201) {
        throw Exception(
            'Failed to create form submission: ${submissionResponse.body}');
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

      // 2. Ordenar preguntas por order_number (si existe) o por el número en el texto de la pregunta
      List<dynamic> orderedQuestions = List.from(questions);

      // Primero intentamos ordenar por order_number
      orderedQuestions.sort((a, b) {
        int orderA = a['order_number'] ?? 0;
        int orderB = b['order_number'] ?? 0;
        return orderA.compareTo(orderB);
      });

      // Si las preguntas tienen un prefijo numérico (como "1 TEXT", "2 CHOICE", etc.),
      // usamos eso como respaldo para el orden
      if (orderedQuestions.first['order_number'] == null ||
          orderedQuestions.first['order_number'] == 0) {
        orderedQuestions.sort((a, b) {
          // Intentamos extraer el número del inicio del texto de la pregunta
          RegExp regExp = RegExp(r'^(\d+)');
          String textA = a['text'] ?? '';
          String textB = b['text'] ?? '';

          Match? matchA = regExp.firstMatch(textA);
          Match? matchB = regExp.firstMatch(textB);

          int orderA = matchA != null ? int.tryParse(matchA.group(1) ?? '0') ?? 0 : 0;
          int orderB = matchB != null ? int.tryParse(matchB.group(1) ?? '0') ?? 0 : 0;

          return orderA.compareTo(orderB);
        });
      }

      // 3. Submit answers in the order of questions
      var answersUri = Uri.parse('${_http.baseUrl}/api/answers-submitted');

      for (var question in orderedQuestions) {
        int questionId = question['id'];

        // Skip questions that don't have an answer
        if (!answers.containsKey(questionId)) {
          continue;
        }

        String formattedAnswer = formatAnswerValue(answers[questionId], question['type']);

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

      // 4. Handle attachments
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
            var responseBody =
            await http.Response.fromStream(attachmentResponse);
            throw Exception(
                'Failed to upload attachment: ${responseBody.body}');
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

  Future<Map<String, dynamic>> createFormSubmission({
    required BuildContext context,
    required int formId,
  }) async {
    try {
      String? token = await SessionManager.getToken();

      final submissionData = {'form_id': formId};

      print(
          'Creating form submission with data: ${json.encode(submissionData)}');

      var submissionUri = Uri.parse('${_http.baseUrl}/api/form-submissions');
      var submissionResponse = await http.post(
        submissionUri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(submissionData),
      );

      if (submissionResponse.statusCode == 401) {
        await ApiResponseHandler.handleExpiredToken(
            context, json.decode(submissionResponse.body));
        throw Exception('Token expired. Please log in again.');
      }

      print('Form submission response: ${submissionResponse.body}');

      if (submissionResponse.statusCode != 201) {
        throw Exception(
            'Failed to create form submission: ${submissionResponse.body}');
      }

      final submissionResult = json.decode(submissionResponse.body);

      if (submissionResult == null ||
          !submissionResult.containsKey('submission') ||
          submissionResult['submission'] == null ||
          !submissionResult['submission'].containsKey('id')) {
        print('Invalid response structure: $submissionResult');
        throw Exception('Invalid response structure from server');
      }

      final submissionId = submissionResult['submission']['id'];

      return {
        'status': 'success',
        'submission_id': submissionId,
        'message': 'Form submission created successfully'
      };
    } catch (e, stackTrace) {
      print('Error in createFormSubmission: $e');
      print('Stack trace: $stackTrace');
      throw Exception('Failed to create form submission: $e');
    }
  }
}
