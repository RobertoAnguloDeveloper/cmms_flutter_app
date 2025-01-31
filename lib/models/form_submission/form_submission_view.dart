// lib/models/form_submission/form_submission_view.dart
/*

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
}*/


import 'answer_view.dart';

class FormSubmissionView {
  final int submissionId;       // <--- ID of the submission
  final String submittedBy;     // <--- Who sent the form
  final DateTime submittedAt;   // <--- When it was sent
  final String formTitle;       // <--- Name of the form
  final List<AnswerView> answers;

  FormSubmissionView({
    required this.submissionId,
    required this.submittedBy,
    required this.submittedAt,
    required this.formTitle,
    required this.answers,
  });

  // We create fromJson assuming each "answer" item looks like the JSON above.
  factory FormSubmissionView.fromJson(Map<String, dynamic> json) {
    final formSubmission = json['form_submission'] ?? {};
    final formInfo = formSubmission['form'] ?? {};

    return FormSubmissionView(
      submissionId: formSubmission['id'] ?? 0,
      submittedBy: formSubmission['submitted_by'] ?? '',
      submittedAt: DateTime.parse(
        formSubmission['submitted_at'] ??
            DateTime.now().toIso8601String(),
      ),
      formTitle: formInfo['title'] ?? '',

      // Build a single AnswerView from the "question" / "answer" / "question_type".
      // If you need to group multiple answers together, you'll need extra logic
      // because the backend is returning each "answer" in a separate JSON item.
      answers: [
        AnswerView(
          question: json['question'] ?? '',
          questionType: json['question_type'] ?? '',
          answer: json['answer'] ?? '',
        )
      ],
    );
  }
}
