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

  const FormSubmission({
    required this.id,
    required this.formId,
    required this.submittedBy,
    required this.submittedAt,
    this.form,
    this.answers,
    this.attachments,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory FormSubmission.fromJson(Map<String, dynamic> json) {
    return FormSubmission(
      id: json['id'] as int? ?? 0,
      formId: json['form_id'] as int? ?? 0,
      submittedBy: json['submitted_by'] as String? ?? '',
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : DateTime.now(),
      form: json['form'] != null
          ? Form.fromJson(json['form'] as Map<String, dynamic>)
          : null,
      answers: json['answers'] != null
          ? (json['answers'] as List)
          .map((a) => AnswerSubmitted.fromJson(a as Map<String, dynamic>))
          .toList()
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
          .map((a) => Attachment.fromJson(a as Map<String, dynamic>))
          .toList()
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
      'form_id': formId,
      'submitted_by': submittedBy,
      'submitted_at': submittedAt.toIso8601String(),
      if (form != null) 'form': form?.toJson(),
      if (answers != null) 'answers': answers?.map((a) => a.toJson()).toList(),
      if (attachments != null) 'attachments': attachments?.map((a) => a.toJson()).toList(),
    };
  }

  FormSubmission copyWith({
    int? id,
    int? formId,
    String? submittedBy,
    DateTime? submittedAt,
    Form? Function()? form,
    List<AnswerSubmitted>? Function()? answers,
    List<Attachment>? Function()? attachments,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
    bool? isDeleted,
    DateTime? Function()? deletedAt,
  }) {
    return FormSubmission(
      id: id ?? this.id,
      formId: formId ?? this.formId,
      submittedBy: submittedBy ?? this.submittedBy,
      submittedAt: submittedAt ?? this.submittedAt,
      form: form != null ? form() : this.form,
      answers: answers != null ? answers() : this.answers,
      attachments: attachments != null ? attachments() : this.attachments,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}