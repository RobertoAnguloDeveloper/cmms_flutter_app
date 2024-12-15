import 'package:flutter/material.dart';
import '../../answer_form_management/AnswerSelectionDialog.dart';
import 'DynamicInputField.dart';
import 'AnswerItemWidget.dart';
import 'PossibleAnswersWidget.dart';

class QuestionsListWidget extends StatelessWidget {
  final List<dynamic> questions;
  final Function(BuildContext, int) deleteFormQuestion;
  final Function(String, dynamic) showEditAnswerDialog;
  final Function(int) deleteAnswer;
  final bool Function(String) shouldShowAnswerSelection;
  final VoidCallback fetchFormDetails;
  final int formId;

  const QuestionsListWidget({
    Key? key,
    required this.questions,
    required this.deleteFormQuestion,
    required this.showEditAnswerDialog,
    required this.deleteAnswer,
    required this.shouldShowAnswerSelection,
    required this.fetchFormDetails,
    required this.formId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (questions.isEmpty) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width *
              0.9, // Ajustar el ancho al 90%
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Text(
              'No questions available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Container(
        width:
            MediaQuery.of(context).size.width * 0.9, // Ajustar el ancho al 90%
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: questions.length,
          itemBuilder: (context, index) {
            final question = questions[index];
            final String questionType =
                question['type']?.toString().toLowerCase() ?? '';

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.white,
              elevation: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 9,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 1, 116, 209),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            question['text'] ?? 'No question text',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: Color(0xFF72BCE9)),
                          onPressed: () => deleteFormQuestion(
                            context,
                            question['form_question_id'],
                          ),
                          tooltip: 'Delete question',
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Type: ${questionType.toUpperCase()}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (['date', 'datetime', 'text', 'user']
                            .contains(questionType))
                          DynamicInputField(questionType: questionType)
                        else if (question['possible_answers']?.isNotEmpty ??
                            false)
                          PossibleAnswersWidget(
                            question: question,
                            questionType: questionType,
                            buildAnswerItem: (answer, questionType) =>
                                AnswerItemWidget(
                              answer: answer,
                              questionType: questionType,
                              onEdit: () => showEditAnswerDialog(
                                answer['value'],
                                {
                                  'answer': answer,
                                  'remarks': answer['remarks']
                                },
                              ),
                              onDelete: () =>
                                  deleteAnswer(answer['form_answer_id']),
                            ),
                          ),
                      ],
                    ),
                    trailing: shouldShowAnswerSelection(questionType)
                        ? IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AnswerSelectionDialog(
                                    refreshAnswers: fetchFormDetails,
                                    formQuestionId:
                                        question['form_question_id'],
                                    questionText: question['text'],
                                    formId: formId,
                                    questionId: question['id'],
                                  );
                                },
                              );
                            },
                            tooltip: 'Add answers',
                          )
                        : null,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
