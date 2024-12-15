import 'PossibleAnswer.dart';

class FormQuestion {
  final int id;
  final int formQuestionId;
  final int orderNumber;
  final String text;
  final String type;
  final bool is_signature;
  final String? remarks;
  final List<PossibleAnswer> possibleAnswers;

  FormQuestion({
    required this.id,
    required this.formQuestionId,
    required this.orderNumber,
    required this.text,
    required this.type,
    required this.is_signature,
    this.remarks,
    required this.possibleAnswers,
  });

  factory FormQuestion.fromJson(Map<String, dynamic> json) {
    return FormQuestion(
      id: json['id'] as int,
      formQuestionId: json['form_question_id'] as int,
      orderNumber: json['order_number'] as int,
      text: json['text'] as String,
      type: json['type'] as String,
      is_signature: json['is_signature'] as bool,
      remarks: json['remarks'] as String?,
      possibleAnswers: (json['possible_answers'] as List<dynamic>?)
              ?.map((a) => PossibleAnswer.fromJson(a))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'form_question_id': formQuestionId,
      'order_number': orderNumber,
      'text': text,
      'type': type,
      'is_signature': is_signature,
      'remarks': remarks,
      'possible_answers': possibleAnswers.map((a) => a.toJson()).toList(),
    };
  }
}