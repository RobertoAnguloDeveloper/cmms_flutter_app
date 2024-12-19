import 'base_model.dart';
import 'question_type.dart';

class Question extends BaseModel {
  final int id;
  final String text;
  final int questionTypeId;
  final bool isSignature;
  final String? remarks;
  final QuestionType? questionType;

  const Question({
    required this.id,
    required this.text,
    required this.questionTypeId,
    this.isSignature = false,
    this.remarks,
    this.questionType,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as int,
      text: json['text'] as String,
      questionTypeId: json['question_type_id'] as int,
      isSignature: json['is_signature'] as bool? ?? false,
      remarks: json['remarks'] as String?,
      questionType: json['question_type'] != null
          ? QuestionType.fromJson(json['question_type'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] != null ? DateTime.parse(json['deleted_at'] as String) : null,
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
      if (remarks != null) 'remarks': remarks,
      if (questionType != null) 'question_type': questionType!.toJson(),
    });
    return data;
  }

  Question copyWith({
    int? id,
    String? text,
    int? questionTypeId,
    bool? isSignature,
    String? remarks,
    QuestionType? questionType,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    DateTime? deletedAt,
  }) {
    return Question(
      id: id ?? this.id,
      text: text ?? this.text,
      questionTypeId: questionTypeId ?? this.questionTypeId,
      isSignature: isSignature ?? this.isSignature,
      remarks: remarks ?? this.remarks,
      questionType: questionType ?? this.questionType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}