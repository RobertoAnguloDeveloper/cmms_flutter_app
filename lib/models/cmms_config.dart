// 📂 lib/models/cmms_config.dart

import 'base_model.dart';

class CmmsConfig extends BaseModel {
  final String filename;
  final String path;
  final int size;
  final String contentHash;
  final Map<String, dynamic> content;
  final DateTime modifiedAt;

  const CmmsConfig({
    required this.filename,
    required this.path,
    required this.size,
    required this.contentHash,
    required this.content,
    required this.modifiedAt,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory CmmsConfig.fromJson(Map<String, dynamic> json) {
    return CmmsConfig(
      filename: json['filename'] as String,
      path: json['path'] as String,
      size: json['size'] as int,
      contentHash: json['content_hash'] as String,
      content: json['content'] as Map<String, dynamic>,
      modifiedAt: DateTime.parse(json['modified_at'] as String),
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
      'filename': filename,
      'path': path,
      'size': size,
      'content_hash': contentHash,
      'content': content,
      'modified_at': modifiedAt.toIso8601String(),
    };
  }

  CmmsConfig copyWith({
    String? filename,
    String? path,
    int? size,
    String? contentHash,
    Map<String, dynamic>? content,
    DateTime? modifiedAt,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
    bool? isDeleted,
    DateTime? Function()? deletedAt,
  }) {
    return CmmsConfig(
      filename: filename ?? this.filename,
      path: path ?? this.path,
      size: size ?? this.size,
      contentHash: contentHash ?? this.contentHash,
      content: content ?? this.content,
      modifiedAt: modifiedAt ?? this.modifiedAt,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}