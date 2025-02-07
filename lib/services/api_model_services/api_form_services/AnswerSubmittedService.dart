import 'package:cmms_app/services/api_session_client_services/ApiResponseHandler.dart';
import 'package:cmms_app/services/api_session_client_services/Http.dart';
import 'package:cmms_app/services/api_session_client_services/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnswerSubmittedService {
  Future<Map<String, dynamic>> createAnswerSubmitted(
      BuildContext context,
      int submissionId,
      List<Map<String, dynamic>> answers,
      ) async {
    try {
      // Format the request body according to the API specification
      final Map<String, dynamic> requestBody = {
        'form_submission_id': submissionId,
        'submissions': answers.map((answer) => {
          'question_text': answer['question_text'],
          'question_type_text': answer['question_type'],
          'answer_text': answer['answer_text'],
        }).toList(),
      };

      String? token = await SessionManager.getToken();
      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/answers-submitted/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
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
          'Error creating answer: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while creating answer: $e');
    }
  }
}