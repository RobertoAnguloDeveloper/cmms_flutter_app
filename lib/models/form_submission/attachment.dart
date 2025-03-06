// lib/models/form_submission/attachment.dart
class Attachment {
  final int? id;
  final int formSubmissionId;
  final String fileType;
  final String filePath;
  final bool isSignature;
  final String? signatureAuthor;    // Nuevo campo
  final String? signaturePosition;  // Nuevo campo

  Attachment({
    this.id,
    required this.formSubmissionId,
    required this.fileType,
    required this.filePath,
    this.isSignature = false,
    this.signatureAuthor,           // Nuevo campo
    this.signaturePosition,         // Nuevo campo
  });

  Map<String, dynamic> toJson() => {
    'form_submission_id': formSubmissionId,
    'file_type': fileType,
    'file_path': filePath,
    'is_signature': isSignature,
    'signature_author': signatureAuthor,
    'signature_position': signaturePosition,
  };

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      formSubmissionId: json['form_submission_id'] ?? 0,
      fileType: json['file_type'] ?? '',
      filePath: json['file_path'] ?? '',
      isSignature: json['is_signature'] ?? false,
      signatureAuthor: json['signature_author'],
      signaturePosition: json['signature_position'],
    );
  }
}