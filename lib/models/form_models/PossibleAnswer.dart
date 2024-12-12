class PossibleAnswer {
  final int id;
  final int formAnswerId;
  final String value;

  PossibleAnswer({
    required this.id,
    required this.formAnswerId,
    required this.value,
  });

  factory PossibleAnswer.fromJson(Map<String, dynamic> json) {
    return PossibleAnswer(
      id: json['id'] as int,
      formAnswerId: json['form_answer_id'] as int,
      value: json['value'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'form_answer_id': formAnswerId,
      'value': value,
    };
  }
}
