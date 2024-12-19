import 'base_model.dart';
import 'user.dart';
import 'form_question.dart';

class Form extends BaseModel {
  final int id;
  final String title;
  final String? description;
  final int userId;
  final bool isPublic;
  final User? creator;
  final List<FormQuestion>? questions;
  final int? submissionsCount;

  const Form({
    required this.id,
    required this.title,
    this.description,
    required this.userId,
    this.isPublic = false,
    this.creator,
    this.questions,
    this.submissionsCount,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory Form.fromJson(Map<String, dynamic> json) {
    return Form(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      userId: json['created_by']?['id'] as int? ?? 0,
      isPublic: json['is_public'] as bool? ?? false,
      creator: json['created_by'] != null
          ? User.fromJson(json['created_by'] as Map<String, dynamic>)
          : null,
      questions: json['questions'] != null
          ? (json['questions'] as List)
          .map((q) => FormQuestion.fromJson(q as Map<String, dynamic>))
          .toList()
          : null,
      submissionsCount: json['submissions_count'] as int?,
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
      'title': title,
      if (description != null) 'description': description,
      'is_public': isPublic,
      if (creator != null) 'created_by': creator?.toJson(),
      if (questions != null) 'questions': questions?.map((q) => q.toJson()).toList(),
      if (submissionsCount != null) 'submissions_count': submissionsCount,
    };
  }

  Form copyWith({
    int? id,
    String? title,
    String? Function()? description,
    int? userId,
    bool? isPublic,
    User? Function()? creator,
    List<FormQuestion>? Function()? questions,
    int? Function()? submissionsCount,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
    bool? isDeleted,
    DateTime? Function()? deletedAt,
  }) {
    return Form(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description != null ? description() : this.description,
      userId: userId ?? this.userId,
      isPublic: isPublic ?? this.isPublic,
      creator: creator != null ? creator() : this.creator,
      questions: questions != null ? questions() : this.questions,
      submissionsCount: submissionsCount != null ? submissionsCount() : this.submissionsCount,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}