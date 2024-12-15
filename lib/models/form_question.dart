import 'base_model.dart';
import 'form.dart';
import 'question.dart';
import 'form_answer.dart';

class FormQuestion extends BaseModel {
  final int id;
  final int formId;
  final int questionId;
  final int orderNumber;
  final Form? form;
  final Question? question;
  final List<FormAnswer>? possibleAnswers;

  FormQuestion({
    required this.id,
    required this.formId,
    required this.questionId,
    required this.orderNumber,
    this.form,
    this.question,
    this.possibleAnswers,
    super.createdAt,
    super.updatedAt,
    super.isDeleted,
    super.deletedAt,
  });

  factory FormQuestion.fromJson(Map<String, dynamic> json) {
    return FormQuestion(
      id: json['id'],
      formId: json['form_id'],
      questionId: json['question_id'],
      orderNumber: json['order_number'] ?? 0,
      form: json['form'] != null ? Form.fromJson(json['form']) : null,
      question: json['question'] != null ? Question.fromJson(json['question']) : null,
      possibleAnswers: json['possible_answers'] != null
          ? (json['possible_answers'] as List).map((a) => FormAnswer.fromJson(a)).toList()
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
      'form_id': formId,
      'question_id': questionId,
      'order_number': orderNumber,
      'form': form?.toJson(),
      'question': question?.toJson(),
      'possible_answers': possibleAnswers?.map((a) => a.toJson()).toList(),
    });
    return data;
  }
}