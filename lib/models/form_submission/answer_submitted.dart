class AnswerSubmitted {
  final int? id;
  final String question;
  final String questionType;
  final String answer;
  final int formSubmissionId;

  AnswerSubmitted({
    this.id,
    required this.question,
    required this.questionType,
    required this.answer,
    required this.formSubmissionId,
  });

  Map<String, dynamic> toJson() => {
    'question': question,
    'question_type': questionType,
    'answer': answer,
    'form_submission_id': formSubmissionId,
  };
}
