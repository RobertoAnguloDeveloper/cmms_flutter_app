// lib/models/form_submission/answer_view.dart
class AnswerView {
  final String question;
  final String questionType;
  final String answer;

  AnswerView({
    required this.question,
    required this.questionType,
    required this.answer,
  });

  factory AnswerView.fromJson(Map<String, dynamic> json) {
    return AnswerView(
      question: json['question'] ?? '',
      questionType: json['question_type'] ?? '',
      answer: json['answer'] ?? '',
    );
  }
}