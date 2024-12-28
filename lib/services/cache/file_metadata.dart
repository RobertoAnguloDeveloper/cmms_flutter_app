// 📂 lib/services/cache/file_metadata.dart

class FileMetadata {
  final String filename;
  final String modifiedAt;
  final int size;
  final String mimeType;

  FileMetadata({
    required this.filename,
    required this.modifiedAt,
    required this.size,
    required this.mimeType,
  });

  factory FileMetadata.fromJson(Map<String, dynamic> json) {
    return FileMetadata(
      filename: json['filename'],
      modifiedAt: json['modified_at'],
      size: json['size'],
      mimeType: json['mime_type'],
    );
  }

  Map<String, dynamic> toJson() => {
    'filename': filename,
    'modified_at': modifiedAt,
    'size': size,
    'mime_type': mimeType,
  };
}