import 'base_model.dart';
import 'form_submission.dart';

class Attachment extends BaseModel {
  final int id;
  final int formSubmissionId;
  final String fileType;
  final String filePath;
  final bool isSignature;
  final FormSubmission? formSubmission;

  Attachment({
    required this.id,
    required this.formSubmissionId,
    required this.fileType,
    required this.filePath,
    this.isSignature = false,
    this.formSubmission,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      formSubmissionId: json['form_submission_id'],
      fileType: json['file_type'],
      filePath: json['file_path'],
      isSignature: json['is_signature'] ?? false,
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
      'form_submission_id': formSubmissionId,
      'file_type': fileType,
      'file_path': filePath,
      'is_signature': isSignature,
      'form_submission': formSubmission?.toJson(),
    });
    return data;
  }
}