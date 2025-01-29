// lib/models/form_submission/form_submission_view.dart
import 'answer_view.dart';

class FormSubmissionView {
  final int id;
  final String submittedBy;
  final DateTime submittedAt;
  final List<AnswerView> answers;

  FormSubmissionView({
    required this.id,
    required this.submittedBy,
    required this.submittedAt,
    required this.answers,
  });

  factory FormSubmissionView.fromJson(Map<String, dynamic> json) {
    return FormSubmissionView(
      id: json['id'] ?? 0,
      submittedBy: json['submitted_by'] ?? '',
      submittedAt: DateTime.parse(json['submitted_at'] ?? DateTime.now().toIso8601String()),
      answers: (json['answers'] as List<dynamic>? ?? [])
          .map((answer) => AnswerView.fromJson(answer))
          .toList(),
    );
  }
}