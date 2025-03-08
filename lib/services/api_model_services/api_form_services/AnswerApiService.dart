import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';

class AnswerApiService {
  // FETCH ALL ANSWERS
  Future<List<dynamic>> fetchAnswers(BuildContext context) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/answers'),
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
          'Error retrieving answers: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Exception while retrieving answers: $e');
    }
  }

  // CREATE ANSWER
  Future<Map<String, dynamic>> createAnswer(
    BuildContext context,
    Map<String, dynamic> answerData,
  ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/answers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(answerData),
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



  Future<Map<String, dynamic>> assignAnswerToQuestion(
      BuildContext context,
      int formQuestionId,
      int answerId,
      ) async {
    try {
      // Skip duplicate check for new questions (negative IDs)
      if (formQuestionId > 0) {
        try {
          // Check if this answer is already assigned to avoid duplicates
          final existingAnswers = await getAnswersForQuestion(context, formQuestionId);
          final alreadyAssigned = existingAnswers.any((answer) => answer['id'] == answerId);

          if (alreadyAssigned) {
            // Return success without making the API call
            return {
              'message': 'Answer already assigned to this question',
              'status': 200,
            };
          }
        } catch (e) {
          // Log the error but continue with the assignment
          print('Warning: Unable to check for duplicate answers: $e');
          // Don't re-throw here - just proceed with the attempt to assign
        }
      }

      final requestBody = {
        'form_question_id': formQuestionId.abs(), // Use absolute value to handle negative IDs
        'answer_id': answerId
      };

      String? token = await SessionManager.getToken();
      final response = await http.post(
        Uri.parse('${Http().baseUrl}/api/form-answers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else {
        final responseData = json.decode(response.body);
        throw Exception(responseData['error'] ?? 'Failed to assign answer');
      }
    } catch (e) {
      print('Error in assignAnswerToQuestion: $e');
      throw e;
    }
  }

// Add this helper method to get all answers for a specific question
  Future<List<dynamic>> getAnswersForQuestion(
      BuildContext context,
      int formQuestionId
      ) async {
    try {
      String? token = await SessionManager.getToken();
      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/form-questions/$formQuestionId/answers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['answers'] ?? [];
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to get answers for question');
      }
    } catch (e) {
      print('Error getting answers for question: $e');
      throw e;
    }
  }



  Future<Map<String, dynamic>> getFormWithQuestions(
    BuildContext context,
    int formId,
  ) async {
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
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        return responseData;
      } else {
        throw Exception('Failed to get form data');
      }
    } catch (e) {
      print('Error getting form data: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> deleteAnswerFromQuestion(
    BuildContext context,
    int formAnswerId,
  ) async {
    try {
      String? token = await SessionManager.getToken();

      print('Attempting to delete form answer ID: $formAnswerId');

      final response = await http.delete(
        Uri.parse('${Http().baseUrl}/api/form-answers/$formAnswerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Delete response status: ${response.statusCode}');
      print('Delete response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'status': response.statusCode,
          'message': 'Answer deleted successfully',
          'deleted_items': responseData['deleted_items']
        };
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else {
        throw Exception('Error deleting answer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in deleteAnswerFromQuestion: $e');
      throw e;
    }
  }

  Future<Map<String, dynamic>> updateAnswer(
    BuildContext context,
    Map<String, dynamic> answerData,
    int answerId,
  ) async {
    try {
      String? token = await SessionManager.getToken();

      print('Attempting to update answer ID: $answerId');
      print('Update data: $answerData');

      final response = await http.put(
        Uri.parse('${Http().baseUrl}/api/answers/$answerId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(answerData),
      );

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else {
        throw Exception('Error updating answer: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in updateAnswer: $e');
      throw e;
    }
  }


  // nueva modoficiacion para construir el form submission

  Future<Map<String, dynamic>> submitFormAnswers(
      BuildContext context,
      int formId,
      List<Map<String, dynamic>> answers,
      ) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.post(
        Uri.parse('${Http().baseUrl}/form-answers'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'form_id': formId,
          'answers': answers
        }),
      );

      if (response.statusCode == 201) {
        return json.decode(response.body);
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to submit answers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error submitting answers: $e');
    }
  }




  Future<List<Map<String, dynamic>>> getFormSubmissions(
      BuildContext context,
      int formId,
      ) async {
    try {
      String? token = await SessionManager.getToken();

      final response = await http.get(
        Uri.parse('${Http().baseUrl}/api/form-submissions/$formId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else if (response.statusCode == 401) {
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else {
        throw Exception('Error fetching form submissions');
      }
    } catch (e) {
      throw Exception('Exception while fetching form submissions: $e');
    }
  }
}

