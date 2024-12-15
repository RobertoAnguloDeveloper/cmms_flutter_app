import 'base_model.dart';
import 'form.dart';
import 'answer_submitted.dart';
import 'attachment.dart';

class FormSubmission extends BaseModel {
  final int id;
  final int formId;
  final String submittedBy;
  final DateTime submittedAt;
  final Form? form;
  final List<AnswerSubmitted>? answers;
  final List<Attachment>? attachments;

  FormSubmission({
    required this.id,
    required this.formId,
    required this.submittedBy,
    required this.submittedAt,
    this.form,
    this.answers,
    this.attachments,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory FormSubmission.fromJson(Map<String, dynamic> json) {
    return FormSubmission(
      id: json['id'],
      formId: json['form_id'],
      submittedBy: json['submitted_by'],
      submittedAt: DateTime.parse(json['submitted_at']),
      form: json['form'] != null ? Form.fromJson(json['form']) : null,
      answers: json['answers'] != null
          ? (json['answers'] as List).map((a) => AnswerSubmitted.fromJson(a)).toList()
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List).map((a) => Attachment.fromJson(a)).toList()
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
      'form_id': formId,
      'submitted_by': submittedBy,
      'submitted_at': submittedAt.toIso8601String(),
      'form': form?.toJson(),
      'answers': answers?.map((a) => a.toJson()).toList(),
      'attachments': attachments?.map((a) => a.toJson()).toList(),
    });
    return data;
  }
}