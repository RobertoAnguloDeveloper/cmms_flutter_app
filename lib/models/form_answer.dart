import 'base_model.dart';
import 'form_question.dart';
import 'answer.dart';

class FormAnswer extends BaseModel {
  final int id;
  final int formQuestionId;
  final int answerId;
  final String? remarks;
  final FormQuestion? formQuestion;
  final Answer? answer;

  const FormAnswer({
    required this.id,
    required this.formQuestionId,
    required this.answerId,
    this.remarks,
    this.formQuestion,
    this.answer,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory FormAnswer.fromJson(Map<String, dynamic> json) {
    return FormAnswer(
      id: json['id'] as int? ?? 0,
      formQuestionId: json['form_question_id'] as int? ?? 0,
      answerId: json['answer_id'] as int? ?? 0,
      remarks: json['remarks'] as String?,
      formQuestion: json['form_question'] != null
          ? FormQuestion.fromJson(json['form_question'] as Map<String, dynamic>)
          : null,
      answer: json['answer'] != null
          ? Answer.fromJson(json['answer'] as Map<String, dynamic>)
          : null,
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
      'form_question_id': formQuestionId,
      'answer_id': answerId,
      if (remarks != null) 'remarks': remarks,
      if (formQuestion != null) 'form_question': formQuestion?.toJson(),
      if (answer != null) 'answer': answer?.toJson(),
    };
  }

  FormAnswer copyWith({
    int? id,
    int? formQuestionId,
    int? answerId,
    String? Function()? remarks,
    FormQuestion? Function()? formQuestion,
    Answer? Function()? answer,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
    bool? isDeleted,
    DateTime? Function()? deletedAt,
  }) {
    return FormAnswer(
      id: id ?? this.id,
      formQuestionId: formQuestionId ?? this.formQuestionId,
      answerId: answerId ?? this.answerId,
      remarks: remarks != null ? remarks() : this.remarks,
      formQuestion: formQuestion != null ? formQuestion() : this.formQuestion,
      answer: answer != null ? answer() : this.answer,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}