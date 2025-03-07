import 'package:flutter/material.dart';
import '../../answer_form_management/AnswerSelectionDialog.dart';
import '../ResponseOptionsManager.dart';
import 'DynamicInputField.dart';
import 'AnswerItemWidget.dart';
import 'PossibleAnswersWidget.dart';
import 'GoogleFormsQuestionControls.dart';

class QuestionsListWidget extends StatefulWidget {
  final List<dynamic> questions;
  final Function(BuildContext, int) deleteFormQuestion;
  final Function(String, dynamic) showEditAnswerDialog;
  final Function(int) deleteAnswer;
  final bool Function(String) shouldShowAnswerSelection;
  final VoidCallback fetchFormDetails;
  final int formId;
  final Function(bool) setUnsavedChanges; // Add this parameter

  const QuestionsListWidget({
    Key? key,
    required this.questions,
    required this.deleteFormQuestion,
    required this.showEditAnswerDialog,
    required this.deleteAnswer,
    required this.shouldShowAnswerSelection,
    required this.fetchFormDetails,
    required this.formId,
    required this.setUnsavedChanges, // Make it required
  }) : super(key: key);

  @override
  QuestionsListWidgetState createState() => QuestionsListWidgetState();
}

class QuestionsListWidgetState extends State<QuestionsListWidget> {
  bool _validatingForm = false;
  final Map<int, bool> _questionValidityMap = {};
  final Map<int, bool> _localRequiredState = {};
  final Map<int, GlobalKey<ResponseOptionsManagerState>> _optionsManagerKeys = {};

  @override
  void initState() {
    super.initState();
    _initializeLocalState();
  }

  @override
  void didUpdateWidget(QuestionsListWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.questions != widget.questions) {
      _initializeLocalState();
    }
  }

  void _initializeLocalState() {
    _localRequiredState.clear();
    for (var question in widget.questions) {
      final int questionId = question['id'];
      final bool isRequired = question['is_required'] ?? false;
      final bool isRequiredByTilde = (question['text']?.toString() ?? '').endsWith('~');
      _localRequiredState[questionId] = isRequired || isRequiredByTilde;
    }
  }

  // Helper method to get or create a key for a specific question
  GlobalKey<ResponseOptionsManagerState> _getOptionsManagerKey(int questionId) {
    if (!_optionsManagerKeys.containsKey(questionId)) {
      _optionsManagerKeys[questionId] = GlobalKey<ResponseOptionsManagerState>();
    }
    return _optionsManagerKeys[questionId]!;
  }

  // Method to save all answer options when the main Save button is clicked
  Future<bool> saveAllAnswerOptions() async {
    bool allSuccessful = true;

    for (var key in _optionsManagerKeys.values) {
      if (key.currentState != null) {
        bool success = await key.currentState!.saveOptions();
        if (!success) {
          allSuccessful = false;
        }
      }
    }

    return allSuccessful;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.questions.isEmpty) {
      return _buildEmptyState();
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widget.questions.length,
          itemBuilder: (context, index) => _buildQuestionCard(widget.questions[index]),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    final int questionId = question['id'];
    final int formQuestionId = question['form_question_id'];

    // Get required state from local state if available
    final bool questionIsRequired = _localRequiredState[questionId] ??
        ((question['is_required'] ?? false) ||
            (question['text']?.toString() ?? '').endsWith('~'));

    // Display question text without the trailing '~'
    String displayText = question['text'] ?? 'No question text';
    if (displayText.endsWith('~')) {
      displayText = displayText.substring(0, displayText.length - 1);
    }

    // Validation state
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
          // Colored top bar
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
                _buildQuestionHeader(question, displayText, questionIsRequired),

                if (isInvalid)
                  const Padding(
                    padding: EdgeInsets.only(top: 4, bottom: 8),
                    child: Text(
                      'This question is required',
                      style: TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),

                const SizedBox(height: 8),
                _buildAnswerField(question),
              ],
            ),
          ),

          // Controls
          GoogleFormsQuestionControls(
            isRequired: questionIsRequired,
            onRequiredChanged: (value) => _handleRequiredToggle(questionId, value),
            onDuplicate: () => _duplicateQuestion(question),
            onDelete: () => widget.deleteFormQuestion(context, formQuestionId),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(Map<String, dynamic> question, String displayText, bool questionIsRequired) {
    final String questionType = question['type']?.toString().toLowerCase() ?? '';

    return Row(
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
        if (widget.shouldShowAnswerSelection(questionType))
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add answers',
            onPressed: () => _showAnswerSelectionDialog(question),
          ),
      ],
    );
  }

  void _showAnswerSelectionDialog(Map<String, dynamic> question) {
    showDialog(
      context: context,
      builder: (context) => AnswerSelectionDialog(
        refreshAnswers: widget.fetchFormDetails,
        formQuestionId: question['form_question_id'],
        questionText: question['text'],
        formId: widget.formId,
        questionId: question['id'],
      ),
    );
  }

  Widget _buildAnswerField(Map<String, dynamic> question) {
    final String questionType = question['type']?.toString().toLowerCase() ?? '';
    final int formQuestionId = question['form_question_id'];

    // Text, date, datetime, user types
    if (['date', 'datetime', 'text', 'user'].contains(questionType)) {
      return DynamicInputField(questionType: questionType);
    }

    // If has existing answers
    else if (question['possible_answers']?.isNotEmpty ?? false) {
      return PossibleAnswersWidget(
        question: question,
        questionType: questionType,
        buildAnswerItem: (answer, type) => AnswerItemWidget(
          answer: answer,
          questionType: type,
          onEdit: () => widget.showEditAnswerDialog(
            answer['value'],
            {'answer': answer, 'remarks': answer['remarks']},
          ),
          onDelete: () => widget.deleteAnswer(answer['form_answer_id']),
        ),
      );
    }

    // Options-based question types
    else if (['multiple_choice', 'checkbox', 'dropdown'].contains(questionType)) {
      return ResponseOptionsManager(
        key: _getOptionsManagerKey(formQuestionId),
        options: question['possible_answers']?.map<String>((a) => a['value'].toString())?.toList() ?? [],
        onOptionsChanged: (_) {
          // We'll handle saving through saveAllAnswerOptions
        },
        questionType: questionType,
        formQuestionId: formQuestionId,
        setUnsavedChanges: widget.setUnsavedChanges, // Pass through the setUnsavedChanges function
      );
    }

    return Container();
  }

  void _handleRequiredToggle(int questionId, bool value) {
    setState(() {
      _localRequiredState[questionId] = value;
    });

    // Notify parent about unsaved changes
    widget.setUnsavedChanges(true);
  }

  void saveAllChanges() {
    for (var question in widget.questions) {
      final int questionId = question['id'];

      // Only process if we have a state for this question
      if (_localRequiredState.containsKey(questionId)) {
        final bool isRequired = _localRequiredState[questionId]!;

        // Get text without tilde
        String displayText = question['text'] ?? 'No question text';
        if (displayText.endsWith('~')) {
          displayText = displayText.substring(0, displayText.length - 1);
        }

        // Add tilde if required
        final String textToSave = isRequired ? displayText + '~' : displayText;

        // Save to API
        _updateQuestionText(questionId, textToSave, isRequired);
      }
    }
  }

  void _updateQuestionText(int questionId, String newText, bool isRequired) {
    // Store in local state for immediate UI updates
    _localRequiredState[questionId] = isRequired;

    // Handle API update by refreshing the form
    widget.fetchFormDetails();
  }

  void _duplicateQuestion(Map<String, dynamic> questionToDuplicate) {
    // Implement question duplication and refresh the form
    widget.fetchFormDetails();
  }
}