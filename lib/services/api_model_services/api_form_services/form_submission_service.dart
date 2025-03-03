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

        String formattedAnswer =
            formatAnswerValue(entry.value, question['type']);

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
