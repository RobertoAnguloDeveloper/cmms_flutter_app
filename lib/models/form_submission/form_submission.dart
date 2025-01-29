import 'answer_submitted.dart';
import 'attachment.dart';

class FormSubmission {
  final int? id;
  final int formId;
  final String submittedBy;
  final DateTime submittedAt;
  final bool isDeleted;
  final List<AnswerSubmitted> answers;
  final List<Attachment> attachments;

  FormSubmission({
    this.id,
    required this.formId,
    required this.submittedBy,
    DateTime? submittedAt,
    this.isDeleted = false,
    this.answers = const [],
    this.attachments = const [],
  }) : this.submittedAt = submittedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'form_id': formId,
    'submitted_by': submittedBy,
    'submitted_at': submittedAt.toIso8601String(),
    'is_deleted': isDeleted,
  };
}
