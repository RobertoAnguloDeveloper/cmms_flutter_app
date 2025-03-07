import 'package:flutter/material.dart';

// Your other imports
import '../../answer_form_management/AnswerSelectionDialog.dart';
import '../ResponseOptionsManager.dart';
import 'DynamicInputField.dart';
import 'AnswerItemWidget.dart';
import 'PossibleAnswersWidget.dart';
import 'GoogleFormsQuestionControls.dart';
import '../ResponseOptionsManager.dart';



class QuestionsListWidget extends StatefulWidget {
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
  _QuestionsListWidgetState createState() => _QuestionsListWidgetState();
}

class _QuestionsListWidgetState extends State<QuestionsListWidget> {
  /// Example fields for handling validation.
  /// If you have existing validation logic, adapt accordingly.
  bool _validatingForm = false;
  Map<int, bool> _questionValidityMap = {};

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.9,
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
        width: MediaQuery.of(context).size.width * 0.9,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.questions.length,
          itemBuilder: (context, index) {
            final question = widget.questions[index];
            return _buildQuestionCard(question);
          },
        ),
      ),
    );
  }

  /// Builds a single question card with the “Google Forms”–style controls.
  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final int questionId = question['id'];
    // If the question is required from backend or if it ends with '~'
    final bool isRequired = question['is_required'] ?? false;
    final bool isRequiredByTilde = (question['text']?.toString() ?? '').endsWith('~');
    final bool questionIsRequired = isRequired || isRequiredByTilde;

    // Display question text without the trailing '~'
    String displayText = question['text'] ?? 'No question text';
    if (isRequiredByTilde && displayText.endsWith('~')) {
      displayText = displayText.substring(0, displayText.length - 1);
    }

    // Determine if this question is considered invalid (e.g., required but not answered)
    final bool isInvalid = _validatingForm &&
        _questionValidityMap.containsKey(questionId) &&
        !_questionValidityMap[questionId]!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: isInvalid ? Colors.red[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isInvalid
            ? const BorderSide(color: Colors.red, width: 1.0)
            : BorderSide.none,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional colored bar at the top (like your original code).
          Container(
            height: 9,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 1, 116, 209),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row for question text + "Add answers" icon if needed
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (questionIsRequired)
                            const Text(
                              ' *',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                    // If you still want the "Add answers" icon as from original code:
                    if (widget.shouldShowAnswerSelection(
                      question['type']?.toString().toLowerCase() ?? '',
                    ))
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        tooltip: 'Add answers',
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AnswerSelectionDialog(
                                refreshAnswers: widget.fetchFormDetails,
                                formQuestionId: question['form_question_id'],
                                questionText: question['text'],
                                formId: widget.formId,
                                questionId: question['id'],
                              );
                            },
                          );
                        },
                      ),
                  ],
                ),

                // Show an error message if the question is invalid
                if (isInvalid)
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      'This question is required',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 8),

                // The main content of the question (dynamic field or possible answers)
                _buildAnswerField(question),
              ],
            ),
          ),

          // Google Forms–style controls (Required toggle, Duplicate, Delete)
          GoogleFormsQuestionControls(
            isRequired: questionIsRequired,
            onRequiredChanged: (value) {
              // Toggling “Required” adds/removes trailing '~'
              final updatedText = value
                  ? displayText + '~'
                  : (displayText.endsWith('~')
                  ? displayText.substring(0, displayText.length - 1)
                  : displayText);

              _updateQuestionText(questionId, updatedText, value);
            },
            onDuplicate: () {
              _duplicateQuestion(question);
            },
            onDelete: () =>
                widget.deleteFormQuestion(context, question['form_question_id']),
          ),
        ],
      ),
    );
  }

  /// Builds the main area displaying how answers or fields are rendered.
  Widget _buildAnswerField(Map<String, dynamic> question) {
    final String questionType = question['type']?.toString().toLowerCase() ?? '';

    // If it's a textual/datetime type, show dynamic input
    if (['date', 'datetime', 'text', 'user'].contains(questionType)) {
      return DynamicInputField(questionType: questionType);
    }
    // Otherwise, if it has possible_answers, show them
    else if (question['possible_answers']?.isNotEmpty ?? false) {
      return PossibleAnswersWidget(
        question: question,
        questionType: questionType,
        buildAnswerItem: (answer, questionType) => AnswerItemWidget(
          answer: answer,
          questionType: questionType,
          onEdit: () => widget.showEditAnswerDialog(
            answer['value'],
            {
              'answer': answer,
              'remarks': answer['remarks'],
            },
          ),
          onDelete: () => widget.deleteAnswer(answer['form_answer_id']),
        ),
      );
    }
    // If the question type is multiple_choice, checkbox, or dropdown, use ResponseOptionsManager
    else if (['multiple_choice', 'checkbox', 'dropdown'].contains(questionType.toLowerCase())) {
      return ResponseOptionsManager(
        options: question['possible_answers']?.map<String>((a) => a['value'].toString())?.toList() ?? [],
        onOptionsChanged: (updatedOptions) {
          // Local state updates if needed
        },
        questionType: questionType,
        formQuestionId: question['form_question_id'], // Pass the form_question_id
      );
    }

    // If none of the above, return an empty container
    return Container();
  }

  /// Example placeholder for updating question text/“required” state in your backend.
  void _updateQuestionText(int questionId, String newText, bool isRequired) {
    // Print for debugging
    print('Updating question $questionId: "$newText" (required: $isRequired)');

    // TODO: Replace with your real API call, e.g.:
    // _formQuestionApiService.updateQuestion(
    //   context,
    //   questionId,
    //   {
    //     'text': newText,
    //     'is_required': isRequired,
    //   },
    // ).then((_) => widget.fetchFormDetails());

    // For now, just call fetch to refresh or update state
    widget.fetchFormDetails();
  }

  /// Example placeholder for duplicating a question.
  void _duplicateQuestion(Map<String, dynamic> questionToDuplicate) {
    print('Duplicating question: ${questionToDuplicate['text']}');

    // TODO: Replace with your real API call logic, e.g.:
    // final newQuestion = Map<String, dynamic>.from(questionToDuplicate);
    // newQuestion.remove('id');
    // newQuestion.remove('form_question_id');
    // _formQuestionApiService.createQuestion(context, newQuestion).then((newQ) {
    //   return _formQuestionApiService.assignQuestionToForm(
    //     context,
    //     widget.formId,
    //     newQ['question']['id'],
    //     widget.questions.length + 1,
    //   );
    // }).then((_) => widget.fetchFormDetails());

    widget.fetchFormDetails();
  }
}