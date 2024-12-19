import 'base_model.dart';
import 'form_submission.dart';

class Attachment extends BaseModel {
  final int id;
  final int formSubmissionId;
  final String fileType;
  final String filePath;
  final bool isSignature;
  final FormSubmission? formSubmission;

  const Attachment({
    required this.id,
    required this.formSubmissionId,
    required this.fileType,
    required this.filePath,
    this.isSignature = false,
    this.formSubmission,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'] as int? ?? 0,
      formSubmissionId: json['form_submission_id'] as int? ?? 0,
      fileType: json['file_type'] as String? ?? '',
      filePath: json['file_path'] as String? ?? '',
      isSignature: json['is_signature'] as bool? ?? false,
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
      'form_submission_id': formSubmissionId,
      'file_type': fileType,
      'file_path': filePath,
      'is_signature': isSignature,
      if (formSubmission != null) 'form_submission': formSubmission?.toJson(),
    };
  }

  Attachment copyWith({
    int? id,
    int? formSubmissionId,
    String? fileType,
    String? filePath,
    bool? isSignature,
    FormSubmission? Function()? formSubmission,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
    bool? isDeleted,
    DateTime? Function()? deletedAt,
  }) {
    return Attachment(
      id: id ?? this.id,
      formSubmissionId: formSubmissionId ?? this.formSubmissionId,
      fileType: fileType ?? this.fileType,
      filePath: filePath ?? this.filePath,
      isSignature: isSignature ?? this.isSignature,
      formSubmission: formSubmission != null ? formSubmission() : this.formSubmission,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}