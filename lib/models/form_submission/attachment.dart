// lib/models/form_submission/attachment.dart
class Attachment {
  final int? id;
  final int formSubmissionId;
  final String fileType;
  final String filePath;
  final bool isSignature;

  Attachment({
    this.id,
    required this.formSubmissionId,
    required this.fileType,
    required this.filePath,
    this.isSignature = false,
  });

  Map<String, dynamic> toJson() => {
    'form_submission_id': formSubmissionId,
    'file_type': fileType,
    'file_path': filePath,
    'is_signature': isSignature,
  };
}