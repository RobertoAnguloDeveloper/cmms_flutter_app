import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class QuestionApiService {
  // CREATE QUESTION
  Future<Map<String, dynamic>> createQuestion(
      BuildContext context, Map<String, dynamic> questionData) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/questions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(questionData),
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
          'Error creating question: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while creating question: $e');
    }
  }

  // GET QUESTION TYPES
  Future<List<dynamic>> fetchQuestionTypes(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/question-types'),
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
          'Error retrieving question types: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while retrieving question types: $e');
    }
  }

  // FETCH ALL QUESTIONS
  Future<List<dynamic>> fetchQuestions(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/questions'),
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
          'Error retrieving questions: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while retrieving questions: $e');
    }
  }

  // ASSIGN QUESTION TO FORM
  Future<Map<String, dynamic>> assignQuestionToForm(
    BuildContext context,
    int formId,
    int questionId,
    int orderNumber,
  ) async {
    try {
      String? token = await SessionManager.getToken();

      final assignData = {
        'form_id': formId,
        'question_id': questionId,
        'order_number': orderNumber,
      };

      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/form-questions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(assignData),
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
          'Error assigning question to form: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while assigning question to form: $e');
    }
  }

  // BATCH ASSIGN QUESTIONS TO FORM
  Future<Map<String, dynamic>> batchAssignQuestionsToForm(
    BuildContext context,
    int formId,
    List<Map<String, dynamic>> questionsData,
  ) async {
    try {
      String? token = await SessionManager.getToken();

      final assignData = {
        'form_id': formId,
        'questions': questionsData,
      };

      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/form-questions/batch'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(assignData),
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
          'Error batch assigning questions to form: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while batch assigning questions to form: $e');
    }
  }

  // GET FORM QUESTIONS
  Future<List<dynamic>> getFormQuestions(
    BuildContext context,
    int formId,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/form-questions/$formId'),
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
          'Error retrieving form questions: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while retrieving form questions: $e');
    }
  }

  // UPDATE QUESTION
  Future<Map<String, dynamic>> updateQuestion(
    BuildContext context,
    int questionId,
    Map<String, dynamic> questionData,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.put(
        Uri.parse('${Http().baseUrl}/api/questions/$questionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(questionData),
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
          'Error updating question: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while updating question: $e');
    }
  }

  Future<Map<String, dynamic>> deleteQuestionFromForm(
    BuildContext context,
    int formQuestionId,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      print('Attempting to delete form question ID: $formQuestionId');

      final response = await http.delete(
        Uri.parse('${Http().baseUrl}/api/form-questions/$formQuestionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'status': response.statusCode,
          'message': 'Question deleted successfully'
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return {'status': 401, 'error': 'Session expired'};
      } else {
        try {
          final errorBody = json.decode(response.body);
          return {
            'status': response.statusCode,
            'error': errorBody['error'] ?? 'Error deleting question'
          };
        } catch (e) {
          return {
            'status': response.statusCode,
            'error': 'Error deleting question'
          };
        }
      }
    } catch (e) {
      print('Error in deleteQuestionFromForm: $e');
      return {'status': 500, 'error': e.toString()};
    }
  }

  Future<Map<String, dynamic>> deleteFormQuestion(
    BuildContext context,
    int formQuestionId,
  ) async {
    try {
      String? token = await SessionManager.getToken();

      print('Attempting to delete form question ID: $formQuestionId');

      final response = await http.delete(
        Uri.parse('${Http().baseUrl}/api/form-questions/$formQuestionId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'status': response.statusCode,
          'message': 'Question deleted successfully'
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else if (response.statusCode == 404) {
        throw Exception('Question not found');
      } else {
        throw Exception('Error deleting question: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteFormQuestion: $e');
      throw e;
    }
  }
}
