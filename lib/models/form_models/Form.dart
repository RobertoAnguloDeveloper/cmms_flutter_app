import 'FormQuestion.dart';
import 'FormUser.dart';

class Form {
  final int id;
  final String title;
  final String description;
  final bool isPublic;
  final DateTime createdAt;
  final DateTime updatedAt;
  final FormUser createdBy;
  final List<FormQuestion> questions;
  final int submissionsCount;

  Form({
    required this.id,
    required this.title,
    required this.description,
    required this.isPublic,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    required this.questions,
    required this.submissionsCount,
  });

  factory Form.fromJson(Map<String, dynamic> json) {
    return Form(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      isPublic: json['is_public'] as bool,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      createdBy: FormUser.fromJson(json['created_by']),
      questions: (json['questions'] as List<dynamic>)
          .map((q) => FormQuestion.fromJson(q))
          .toList(),
      submissionsCount: json['submissions_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'is_public': isPublic,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'created_by': createdBy.toJson(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'submissions_count': submissionsCount,
    };
  }
}
