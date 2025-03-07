// attachment.dart
class Attachment {
  final int? id;
  final int formSubmissionId;
  final String fileType;
  final String filePath;
  final bool isSignature;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? signatureAuthor;  // Nuevo campo
  final String? signaturePosition;  // Nuevo campo

  Attachment({
    this.id,
    required this.formSubmissionId,
    required this.fileType,
    required this.filePath,
    this.isSignature = false,
    this.createdAt,
    this.updatedAt,
    this.signatureAuthor,  // Añadido
    this.signaturePosition,  // Añadido
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      id: json['id'],
      formSubmissionId: json['form_submission_id'],
      fileType: json['file_type'],
      filePath: json['file_path'],
      isSignature: json['is_signature'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      signatureAuthor: json['signature_author'],  // Añadido
      signaturePosition: json['signature_position'],  // Añadido
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'form_submission_id': formSubmissionId,
    'file_type': fileType,
    'file_path': filePath,
    'is_signature': isSignature,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'signature_author': signatureAuthor,  // Añadido
    'signature_position': signaturePosition,  // Añadido
  };
}