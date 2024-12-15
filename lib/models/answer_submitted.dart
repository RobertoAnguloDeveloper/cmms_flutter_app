import 'base_model.dart';
import 'form_submission.dart';

class AnswerSubmitted extends BaseModel {
  final int id;
  final String question;
  final String questionType;
  final String answer;
  final int formSubmissionId;
  final FormSubmission? formSubmission;

  AnswerSubmitted({
    required this.id,
    required this.question,
    required this.questionType,
    required this.answer,
    required this.formSubmissionId,
    this.formSubmission,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory AnswerSubmitted.fromJson(Map<String, dynamic> json) {
    return AnswerSubmitted(
      id: json['id'],
      question: json['question'],
      questionType: json['question_type'],
      answer: json['answer'],
      formSubmissionId: json['form_submission_id'],
      formSubmission: json['form_submission'] != null
          ? FormSubmission.fromJson(json['form_submission'])
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      isDeleted: json['is_deleted'] ?? false,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at']) : null,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = super.toJson();
    data.addAll({
      'id': id,
      'question': question,
      'question_type': questionType,
      'answer': answer,
      'form_submission_id': formSubmissionId,
      'form_submission': formSubmission?.toJson(),
    });
    return data;
  }
}