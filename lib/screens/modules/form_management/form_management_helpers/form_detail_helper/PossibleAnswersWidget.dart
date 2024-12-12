import 'package:flutter/material.dart';

class PossibleAnswersWidget extends StatelessWidget {
  final Map<String, dynamic> question;
  final String questionType;
  final Widget Function(dynamic answer, String questionType) buildAnswerItem;

  const PossibleAnswersWidget({
    Key? key,
    required this.question,
    required this.questionType,
    required this.buildAnswerItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const Text(
            'Possible Answers:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          ...question['possible_answers'].map<Widget>((answer) {
            return buildAnswerItem(answer, questionType);
          }).toList(),
        ],
      ),
    );
  }
}
