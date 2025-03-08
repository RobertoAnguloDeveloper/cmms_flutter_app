import 'package:flutter/material.dart';

class QuestionFieldLabel extends StatelessWidget {
  final String questionType;
  final String defaultLabel;

  const QuestionFieldLabel({
    Key? key,
    required this.questionType,
    this.defaultLabel = 'Question title',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String displayLabel;

    // Determine label based on question type
    if (questionType.toLowerCase() == 'signature') {
      displayLabel = 'Position of the person signing';
    } else {
      displayLabel = defaultLabel;
    }

    return Text(
      displayLabel,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}