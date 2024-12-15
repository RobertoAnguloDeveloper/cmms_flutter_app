import 'base_model.dart';
import 'question_type.dart';

class Question extends BaseModel {
  final int id;
  final String text;
  final int questionTypeId;
  final bool isSignature;
  final String? remarks;
  final QuestionType? questionType;

  Question({
    required this.id,
    required this.text,
    required this.questionTypeId,
    this.isSignature = false,
    this.remarks,
    this.questionType,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      questionTypeId: json['question_type_id'],
      isSignature: json['is_signature'] ?? false,
      remarks: json['remarks'],
      questionType: json['question_type'] != null
          ? QuestionType.fromJson(json['question_type'])
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
      'text': text,
      'question_type_id': questionTypeId,
      'is_signature': isSignature,
      'remarks': remarks,
      'question_type': questionType?.toJson(),
    });
    return data;
  }
}