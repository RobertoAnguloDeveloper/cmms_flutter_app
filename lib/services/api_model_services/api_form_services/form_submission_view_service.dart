// 📂 lib/services/api_model_services/api_form_services/form_submission_view_service.dart

import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// Import models
import '../../../models/form_submission/answer_view.dart';
import '../../../models/form_submission/form_submission_view.dart';
import '../../../models/attachment/attachment.dart';

// Import services
import '../../api_session_client_services/ApiResponseHandler.dart';
import '../../api_session_client_services/Http.dart';
import '../../api_session_client_services/SessionManager.dart';
import 'AttachmentService.dart';

// Navigator key for context access
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class FormSubmissionViewService {
  final Http _http = Http();
  late final Dio _dio;
  late final AttachmentService _attachmentService;

  FormSubmissionViewService() {
    _dio = Dio(BaseOptions(
      baseUrl: _http.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) => status != null && status < 500,
    ));

    // Add retry logic for better reliability
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: print,
        retries: 3,
        retryDelays: const [
          Duration(seconds: 1),
          Duration(seconds: 2),
          Duration(seconds: 3),
        ],
      ),
    );

    // Add authorization interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add authorization header to every request
          final token = await SessionManager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            options.headers['Content-Type'] = 'application/json';
          }
          print('Request: ${options.method} ${options.path}');
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Log error details for debugging
          print('Request error: ${error.requestOptions.path}');
          print('Status code: ${error.response?.statusCode}');
          return handler.next(error);
        },
      ),
    );

    // Initialize attachment service
    _attachmentService = AttachmentService();
  }

  // Añadir al FormSubmissionViewService.dart
  Future<Uint8List> getAttachmentBytes(int attachmentId) async {
    try {
      final response = await _dio.get<List<int>>(
        '/api/attachments/$attachmentId',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': '*/*',
          },
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data!);
      } else if (response.statusCode == 401) {
        // No podemos usar context aquí porque no lo tenemos como parámetro
        // Mejor lanzar la excepción y dejar que el widget que usa este método lo maneje
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load attachment: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Error downloading attachment: ${e.message}');
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Deletes a form submission
  /// Route: DELETE /forms/{submissionId}
  // Modificar este método en FormSubmissionViewService
// Ubicación: form_submission_view_service.dart

  Future<void> deleteFormSubmission(
      BuildContext context,
      int submissionId,
      ) async {
    try {
      print('[DEBUG-DELETE] Attempting to delete submission: $submissionId');

      String? token = await SessionManager.getToken();
      final url = Uri.parse('${_http.baseUrl}/api/form-submissions/$submissionId');

      print('[DEBUG-DELETE] Request URL: $url');
      print('[DEBUG-DELETE] Token available: ${token != null ? 'Yes' : 'No'}');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('[DEBUG-DELETE] Response status code: ${response.statusCode}');
      print('[DEBUG-DELETE] Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        print('[DEBUG-DELETE] Successfully deleted submission: $submissionId');
        return; // Éxito sin lanzar excepción
      } else if (response.statusCode == 401) {
        print('[DEBUG-DELETE] Authentication error (401)');
        final responseData = json.decode(response.body);
        await ApiResponseHandler.handleExpiredToken(context, responseData);
        throw Exception('Session expired');
      } else if (response.statusCode == 404) {
        print('[DEBUG-DELETE] Submission not found: $submissionId');
        throw Exception('Submission not found');
      } else {
        final responseData = json.decode(response.body);
        print('[DEBUG-DELETE] Failed to delete submission. Status: ${response.statusCode}');
        print('[DEBUG-DELETE] Error message: ${responseData['message'] ?? "No message"}');
        throw Exception(
          'Failed to delete submission: ${responseData['message'] ?? response.statusCode}',
        );
      }
    } catch (e) {
      print('[DEBUG-DELETE] Exception while deleting submission: $e');
      throw Exception('Exception while deleting submission: $e');
    }
  }

  /// Opens an attachment for viewing
  Future<void> openAttachment(BuildContext context, int attachmentId) async {
    await _attachmentService.openAttachment(context, attachmentId);
  }

  /// 1) Gets form submissions for a specific form
  /// Route: GET /api/answers-submitted?form_id=$formId
  /// Returns a list of FormSubmissionView with grouped answers
  /// Modify the getFormSubmissions method in FormSubmissionViewService
  /// Gets form submissions for a specific form
  /// Route: GET /api/answers-submitted?form_id=$formId
  /// Returns a list of FormSubmissionView with grouped answers
  Future<List<FormSubmissionView>> getFormSubmissions(int formId,
      [BuildContext? context]) async {
    try {
      // First get the list of submissions from answers endpoint to identify unique submissions
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/answers-submitted',
        queryParameters: {'form_id': formId},
      );

      print('[getFormSubmissions] Response => ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data!;
        final List<dynamic> data = responseData['answers'] ?? [];

        // Extract unique submission IDs while preserving order
        final List<int> submissionIds = [];
        final Set<int> processedIds = {};

        for (var item in data) {
          final formSubmission = item['form_submission'] ?? {};
          final submissionId = formSubmission['id'] ?? 0;
          if (submissionId > 0 && !processedIds.contains(submissionId)) {
            submissionIds.add(submissionId);
            processedIds.add(submissionId);
          }
        }

        // Create a list to hold the complete submissions
        final List<FormSubmissionView> submissionsList = [];

        // Process submissions sequentially
        for (var submissionId in submissionIds) {
          try {
            final detailResponse = await _dio.get<Map<String, dynamic>>(
              '/api/form-submissions/$submissionId',
            );

            if (detailResponse.statusCode == 200 &&
                detailResponse.data != null) {
              final submissionData = detailResponse.data!;

              // Extract basic submission info
              final formData = submissionData['form'] ?? {};
              final formTitle = formData['title'] ?? '';
              final submittedBy = submissionData['submitted_by'] ?? '';
              final submittedAtStr = submissionData['submitted_at'] ?? '';

              DateTime parsedDate = DateTime.now();
              if (submittedAtStr.isNotEmpty) {
                try {
                  parsedDate = DateTime.parse(submittedAtStr);
                } catch (e) {
                  print('Error parsing date: $e');
                }
              }

              // Extract answers in the correct order
              final List<dynamic> answersData = submissionData['answers'] ?? [];
              final List<AnswerView> answers = answersData
                  .map((answerJson) => AnswerView(
                        question: answerJson['question'] ?? '',
                        questionType: answerJson['question_type'] ?? '',
                        answer: answerJson['answer'] ?? '',
                      ))
                  .toList();

              // Extract attachments
              final List<dynamic> attachmentsList =
                  submissionData['attachments'] ?? [];
              final List<Attachment> attachments = attachmentsList
                  .map((attachmentJson) => Attachment.fromJson(attachmentJson))
                  .toList();

              // Create the submission view with ordered data
              final submissionView = FormSubmissionView(
                submissionId: submissionId,
                formTitle: formTitle,
                submittedBy: submittedBy,
                submittedAt: parsedDate,
                answers: answers,
                attachments: attachments,
              );

              submissionsList.add(submissionView);
              print(
                  'Processed submission $submissionId with ${answers.length} answers and ${attachments.length} attachments');
            } else if (detailResponse.statusCode == 401 &&
                context != null &&
                context.mounted) {
              await ApiResponseHandler.handleExpiredToken(
                  context, detailResponse.data as Map<String, dynamic>);
              throw Exception('Session expired');
            }
          } catch (e) {
            print('Error fetching details for submission $submissionId: $e');
          }
        }

        // Sort submissions by date - newest first
        submissionsList.sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

        return submissionsList;
      } else if (response.statusCode == 401) {
        if (context != null && context.mounted) {
          await ApiResponseHandler.handleExpiredToken(
              context, response.data as Map<String, dynamic>);
        }
        throw Exception('Session expired');
      } else {
        throw Exception(
          'Failed to fetch form submissions. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error fetching form submissions: $e');
      throw Exception('Failed to load form submissions: $e');
    }
  }

  /// 2) Gets all submissions
  /// Route: GET /api/answers-submitted
  Future<Map<String, dynamic>> getAllSubmissions(BuildContext context) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/answers-submitted',
      );

      print('[getAllSubmissions] Response => ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data!;
        return {
          'answers': responseData['answers'] ?? [],
          'total_count': responseData['total_count'] ?? 0,
          'filters_applied': responseData['filters_applied'] ?? {},
        };
      } else if (response.statusCode == 401) {
        if (context.mounted) {
          await ApiResponseHandler.handleExpiredToken(
              context, response.data as Map<String, dynamic>);
        }
        throw Exception('Session expired');
      } else {
        throw Exception(
          'Failed to load submissions. Status: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error in getAllSubmissions: $e');
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// 3) Gets submissions from alternative endpoint
  /// Route: GET /api/form-submissions/all
  Future<List<dynamic>> getAllSubmissionsAlternative(
      BuildContext context) async {
    try {
      final response = await _dio.get<List<dynamic>>(
        '/api/form-submissions/all',
      );

      print(
          '[getAllSubmissionsAlternative] Response => ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      } else if (response.statusCode == 404) {
        throw Exception('Endpoint /api/form-submissions/all not found (404). '
            'Check if this endpoint exists on your backend.');
      } else if (response.statusCode == 401) {
        if (context.mounted) {
          await ApiResponseHandler.handleExpiredToken(context, {
            'message': 'Session expired'
          } // Crear un mapa básico si la respuesta no es un map
              );
        }
        throw Exception('Session expired');
      } else {
        throw Exception('Failed to load submissions: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error fetching submissions: $e');
      throw Exception('Error fetching submissions: $e');
    }
  }

  /// 4) Gets detailed information for a specific submission
  /// Route: GET /api/form-submissions/$submissionId/details
  Future<Map<String, dynamic>> getSubmissionDetails(
    BuildContext context,
    int submissionId,
  ) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/form-submissions/$submissionId/details',
      );

      print('[getSubmissionDetails] Response => ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        return response.data!;
      } else if (response.statusCode == 401) {
        if (context.mounted) {
          await ApiResponseHandler.handleExpiredToken(
              context, response.data as Map<String, dynamic>);
        }
        throw Exception('Session expired');
      } else if (response.statusCode == 404) {
        throw Exception(
            'Endpoint not found (404). Check the route on your backend.');
      } else {
        throw Exception(
            'Failed to load submission details: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DioException: ${e.message}');
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      print('Error fetching submission details: $e');
      throw Exception('Error fetching submission details: $e');
    }
  }

  /// 5) Test method to check available endpoints
  Future<void> testEndpoints(BuildContext context) async {
    final endpoints = [
      '/api/answers-submitted',
      '/api/form-submissions',
      '/api/submissions',
      '/api/attachments/1', // Test the problematic endpoint
    ];

    for (var endpoint in endpoints) {
      try {
        final response = await _dio.get(
          endpoint,
          options: Options(validateStatus: (status) => true),
        );
        print('Response for $endpoint: ${response.statusCode}');
      } catch (e) {
        print('Error testing endpoint $endpoint: $e');
      }
    }
  }
}
