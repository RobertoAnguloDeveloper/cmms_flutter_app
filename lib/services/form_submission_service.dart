// lib/services/api_model_services/form_submission_service.dart
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../services/api_session_client_services/Http.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ========================= MODELS =========================

class FormSubmission {
  final int submissionId;
  final String formTitle;
  final String submittedBy;
  final DateTime submittedAt;
  final List<SubmissionAnswer> answers;
  final List<SubmissionAttachment> attachments;

  FormSubmission({
    required this.submissionId,
    required this.formTitle,
    required this.submittedBy,
    required this.submittedAt,
    this.answers = const [],
    this.attachments = const [],
  });

  factory FormSubmission.fromJson(Map<String, dynamic> json) {
    return FormSubmission(
      submissionId: json['id'] ?? json['submission_id'] ?? 0,
      formTitle: json['form_title'] ?? '',
      submittedBy: json['submitted_by'] ?? '',
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : DateTime.now(),
      answers: json['answers'] != null
          ? (json['answers'] as List).map((a) => SubmissionAnswer.fromJson(a)).toList()
          : [],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List).map((a) => SubmissionAttachment.fromJson(a)).toList()
          : [],
    );
  }
}

class SubmissionAnswer {
  final int id;
  final String question;
  final String questionType;
  final String answer;

  SubmissionAnswer({
    required this.id,
    required this.question,
    required this.questionType,
    required this.answer,
  });

  factory SubmissionAnswer.fromJson(Map<String, dynamic> json) {
    return SubmissionAnswer(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      questionType: json['question_type'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}

class SubmissionAttachment {
  final int? id;
  final String filePath;
  final bool isSignature;
  final String? signatureAuthor;
  final String? signaturePosition;

  SubmissionAttachment({
    this.id,
    required this.filePath,
    this.isSignature = false,
    this.signatureAuthor,
    this.signaturePosition,
  });

  factory SubmissionAttachment.fromJson(Map<String, dynamic> json) {
    return SubmissionAttachment(
      id: json['id'],
      filePath: json['file_path'] ?? '',
      isSignature: json['is_signature'] ?? false,
      signatureAuthor: json['signature_author'],
      signaturePosition: json['signature_position'],
    );
  }
}

// ========================= SERVICE =========================

class FormSubmissionService {
  final Http _http = Http();

  // Get token from shared preferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Get all submissions for a form
  Future<List<FormSubmission>> getFormSubmissions(int formId, BuildContext context) async {
    try {
      final token = await _getToken();
      final response = await _http.get('/api/form-submissions?form_id=$formId', token);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final submissionsJson = decodedData['submissions'] as List;
        return submissionsJson.map((json) => FormSubmission.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load submissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get user's own submissions
  Future<List<FormSubmission>> getUserSubmissions({
    int? formId,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final token = await _getToken();
      String endpoint = '/api/form-submissions/my-submissions';

      // Add query parameters if provided
      List<String> queryParams = [];
      if (formId != null) queryParams.add('form_id=$formId');
      if (startDate != null) queryParams.add('start_date=$startDate');
      if (endDate != null) queryParams.add('end_date=$endDate');

      if (queryParams.isNotEmpty) {
        endpoint += '?' + queryParams.join('&');
      }

      final response = await _http.get(endpoint, token);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final submissionsJson = decodedData['submissions'] as List;
        return submissionsJson.map((json) => FormSubmission.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load user submissions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get a specific submission with its answers
  Future<FormSubmission> getSubmission(int submissionId) async {
    try {
      final token = await _getToken();
      final response = await _http.get('/api/form-submissions/$submissionId', token);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        return FormSubmission.fromJson(decodedData);
      } else {
        throw Exception('Failed to load submission: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get submission answers
  Future<List<SubmissionAnswer>> getSubmissionAnswers(int submissionId) async {
    try {
      final token = await _getToken();
      final response = await _http.get('/api/form-submissions/$submissionId/answers', token);

      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        final answersJson = decodedData['answers'] as List;
        return answersJson.map((json) => SubmissionAnswer.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load submission answers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Delete a submission
  Future<bool> deleteSubmission(BuildContext context, int submissionId) async {
    try {
      final token = await _getToken();
      final response = await _http.delete('/api/form-submissions/$submissionId', token);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Failed to delete submission: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Get attachment bytes (for signatures, images, etc.)
  Future<Uint8List> getAttachmentBytes(int attachmentId) async {
    try {
      final token = await _getToken();
      final response = await _http.get('/api/attachments/$attachmentId', token);

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to load attachment: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error loading attachment: $e');
    }
  }

  // Open attachment in device viewer
  Future<void> openAttachment(BuildContext context, int attachmentId) async {
    try {
      final bytes = await getAttachmentBytes(attachmentId);
      // Code to open the attachment would go here
      // For simplicity, we'll just show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Opening attachment #$attachmentId')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening attachment: $e')),
      );
    }
  }
}