import 'package:cmms_app/services/api_session_client_services/ApiResponseHandler.dart';
import 'package:cmms_app/services/api_session_client_services/Http.dart';
import 'package:cmms_app/services/api_session_client_services/SessionManager.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AnswerSubmittedService {
  // Create answer submissions
  Future<Map<String, dynamic>> createAnswerSubmitted(
      BuildContext context,
      int submissionId,
      List<Map<String, dynamic>> answers,
      ) async {
    try {
      // Format the request body according to the API specification
      final Map<String, dynamic> requestBody = {
        'form_submission_id': submissionId,
        'submissions': answers,
      };

      print('Sending request body: ${json.encode(requestBody)}');

      String? token = await SessionManager.getToken();
      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/answers-submitted/bulk'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

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

  // Fetch submitted answers
  Future<Map<String, dynamic>> fetchSubmittedAnswers(
      BuildContext context, {
        Map<String, dynamic>? filters,
      }) async {
    try {
      String? token = await SessionManager.getToken();

      // Build URL with query parameters if filters are provided
      var uri = Uri.parse('${Http().baseUrl}/api/answers-submitted');
      if (filters != null && filters.isNotEmpty) {
        uri = uri.replace(queryParameters: filters.map(
                (key, value) => MapEntry(key, value.toString())
        ));
      }

      final response = await http.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return {
          'answers': responseData['answers'] as List<dynamic>,
          'total_count': responseData['total_count'] as int,
          'filters_applied': responseData['filters_applied'] as Map<String, dynamic>,
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error fetching answers: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while fetching answers: $e');
    }
  }

  // Fetch single submitted answer by ID
  Future<Map<String, dynamic>> fetchSubmittedAnswerById(
      BuildContext context,
      int answerId,
      ) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/answers-submitted/$answerId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return _parseAnswerData(responseData);
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error fetching answer: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while fetching answer: $e');
    }
  }

  // Update submitted answer
  Future<Map<String, dynamic>> updateSubmittedAnswer(
      BuildContext context,
      int answerId,
      String newAnswer,
      ) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.put(
        Uri.parse('${Http().baseUrl}/api/answers-submitted/$answerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'text_answered': newAnswer,
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'message': responseData['message'],
          'answer_submitted': _parseAnswerData(responseData['answer_submitted']),
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error updating answer: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while updating answer: $e');
    }
  }

  // Delete submitted answer
  Future<Map<String, dynamic>> deleteSubmittedAnswer(
      BuildContext context,
      int answerId,
      ) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.delete(
        Uri.parse('${Http().baseUrl}/api/answers-submitted/$answerId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'message': responseData['message'],
          'deleted_id': responseData['deleted_id'],
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        final responseData = json.decode(response.body);
        throw Exception(
          'Error deleting answer: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while deleting answer: $e');
    }
  }

  // Helper method to parse the response data
  Map<String, dynamic> _parseAnswerData(Map<String, dynamic> data) {
    return {
      'id': data['id'],
      'question': data['question'],
      'question_type': data['question_type'],
      'answer': data['answer'],
      'created_at': data['created_at'],
      'updated_at': data['updated_at'],
      'form_submission': {
        'id': data['form_submission']['id'],
        'form': {
          'id': data['form_submission']['form']['id'],
          'title': data['form_submission']['form']['title'],
        },
        'submitted_at': data['form_submission']['submitted_at'],
        'submitted_by': data['form_submission']['submitted_by'],
      },
    };
  }
}