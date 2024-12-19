import 'base_model.dart';
import 'form_submission.dart';

class AnswerSubmitted extends BaseModel {
  final int id;
  final String question;
  final String questionType;
  final String answer;
  final int formSubmissionId;
  final FormSubmission? formSubmission;

  const AnswerSubmitted({
    required this.id,
    required this.question,
    required this.questionType,
    required this.answer,
    required this.formSubmissionId,
    this.formSubmission,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory AnswerSubmitted.fromJson(Map<String, dynamic> json) {
    return AnswerSubmitted(
      id: json['id'] as int? ?? 0,
      question: json['question'] as String? ?? '',
      questionType: json['question_type'] as String? ?? '',
      answer: json['answer'] as String? ?? '',
      formSubmissionId: json['form_submission_id'] as int? ?? 0,
      formSubmission: json['form_submission'] != null
          ? FormSubmission.fromJson(json['form_submission'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      ...super.toJson(),
      'id': id,
      'question': question,
      'question_type': questionType,
      'answer': answer,
      'form_submission_id': formSubmissionId,
      if (formSubmission != null) 'form_submission': formSubmission?.toJson(),
    };
  }

  AnswerSubmitted copyWith({
    int? id,
    String? question,
    String? questionType,
    String? answer,
    int? formSubmissionId,
    FormSubmission? Function()? formSubmission,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
    bool? isDeleted,
    DateTime? Function()? deletedAt,
  }) {
    return AnswerSubmitted(
      id: id ?? this.id,
      question: question ?? this.question,
      questionType: questionType ?? this.questionType,
      answer: answer ?? this.answer,
      formSubmissionId: formSubmissionId ?? this.formSubmissionId,
      formSubmission: formSubmission != null ? formSubmission() : this.formSubmission,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}