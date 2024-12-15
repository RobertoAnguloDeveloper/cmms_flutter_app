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

  Form({
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
    super.isDeleted,
    super.deletedAt,
  });

  factory Form.fromJson(Map<String, dynamic> json) {
    return Form(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      userId: json['user_id'],
      isPublic: json['is_public'] ?? false,
      creator: json['created_by'] != null ? User.fromJson(json['created_by']) : null,
      questions: json['questions'] != null
          ? (json['questions'] as List).map((q) => FormQuestion.fromJson(q)).toList()
          : null,
      submissionsCount: json['submissions_count'],
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
      'title': title,
      'description': description,
      'user_id': userId,
      'is_public': isPublic,
      'created_by': creator?.toJson(),
      'questions': questions?.map((q) => q.toJson()).toList(),
    });
    return data;
  }
}