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

  const FormQuestion({
    required this.id,
    required this.formId,
    required this.questionId,
    required this.orderNumber,
    this.form,
    this.question,
    this.possibleAnswers,
    super.createdAt,
    super.updatedAt,
    super.isDeleted = false,
    super.deletedAt,
  });

  factory FormQuestion.fromJson(Map<String, dynamic> json) {
    return FormQuestion(
      id: json['id'] as int? ?? 0,
      formId: json['form_id'] as int? ?? 0,
      questionId: json['question_id'] as int? ?? 0,
      orderNumber: json['order_number'] as int? ?? 0,
      form: json['form'] != null ? Form.fromJson(json['form'] as Map<String, dynamic>) : null,
      question: json['question'] != null ? Question.fromJson(json['question'] as Map<String, dynamic>) : null,
      possibleAnswers: json['possible_answers'] != null
          ? (json['possible_answers'] as List)
          .map((a) => FormAnswer.fromJson(a as Map<String, dynamic>))
          .toList()
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
      'form_id': formId,
      'question_id': questionId,
      'order_number': orderNumber,
      if (form != null) 'form': form?.toJson(),
      if (question != null) 'question': question?.toJson(),
      if (possibleAnswers != null) 'possible_answers': possibleAnswers?.map((a) => a.toJson()).toList(),
    };
  }

  FormQuestion copyWith({
    int? id,
    int? formId,
    int? questionId,
    int? orderNumber,
    Form? Function()? form,
    Question? Function()? question,
    List<FormAnswer>? Function()? possibleAnswers,
    DateTime? Function()? createdAt,
    DateTime? Function()? updatedAt,
    bool? isDeleted,
    DateTime? Function()? deletedAt,
  }) {
    return FormQuestion(
      id: id ?? this.id,
      formId: formId ?? this.formId,
      questionId: questionId ?? this.questionId,
      orderNumber: orderNumber ?? this.orderNumber,
      form: form != null ? form() : this.form,
      question: question != null ? question() : this.question,
      possibleAnswers: possibleAnswers != null ? possibleAnswers() : this.possibleAnswers,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt != null ? deletedAt() : this.deletedAt,
    );
  }
}