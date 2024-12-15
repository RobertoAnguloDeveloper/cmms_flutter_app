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

  FormAnswer({
    required this.id,
    required this.formQuestionId,
    required this.answerId,
    this.remarks,
    this.formQuestion,
    this.answer,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory FormAnswer.fromJson(Map<String, dynamic> json) {
    return FormAnswer(
      id: json['id'],
      formQuestionId: json['form_question_id'],
      answerId: json['answer_id'],
      remarks: json['remarks'],
      formQuestion: json['form_question'] != null
          ? FormQuestion.fromJson(json['form_question'])
          : null,
      answer: json['answer'] != null
          ? Answer.fromJson(json['answer'])
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
      'form_question_id': formQuestionId,
      'answer_id': answerId,
      'remarks': remarks,
      'form_question': formQuestion?.toJson(),
      'answer': answer?.toJson(),
    });
    return data;
  }
}