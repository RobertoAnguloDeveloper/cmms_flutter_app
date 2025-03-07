import 'package:flutter/material.dart';
import '../ResponseOptionsManager.dart';

class QuestionCreationCard extends StatelessWidget {
  final TextEditingController questionTextController;
  final int? selectedQuestionTypeId;
  final bool isRequired;
  final bool isLoadingQuestionTypes;
  final List<dynamic> questionTypes;
  final VoidCallback onCancel;
  final ValueChanged<int?> onTypeChanged;
  final ValueChanged<bool> onRequiredChanged;
  final bool showValidationError;
  final int questionId; // Added questionId parameter

  const QuestionCreationCard({
    Key? key,
    required this.questionTextController,
    required this.selectedQuestionTypeId,
    required this.isRequired,
    required this.isLoadingQuestionTypes,
    required this.questionTypes,
    required this.onCancel,
    required this.onTypeChanged,
    required this.onRequiredChanged,
    required this.questionId, // Ensure it's required
    this.showValidationError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final dropdownWidth = isPortrait
        ? mediaQuery.size.width * 0.4
        : mediaQuery.size.width * 0.25;

    final bool requiresOptions = selectedQuestionTypeId != null &&
        questionTypes
            .firstWhere(
              (type) => type['id'] == selectedQuestionTypeId,
          orElse: () => {'type': ''},
        )['type']
            .toString()
            .toLowerCase()
            .contains(RegExp(r'multiple_choice|checkbox|dropdown'));

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: TextField(
                        controller: questionTextController,
                        decoration: InputDecoration(
                          hintText: 'Question title',
                          border: UnderlineInputBorder(),
                          hintStyle: const TextStyle(fontSize: 16),
                          errorText: showValidationError &&
                              questionTextController.text.isEmpty
                              ? 'Question text is required'
                              : null,
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: dropdownWidth,
                      child: isLoadingQuestionTypes
                          ? const Center(child: CircularProgressIndicator())
                          : DropdownButtonFormField<int>(
                        value: selectedQuestionTypeId,
                        isDense: true,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          errorText: showValidationError && selectedQuestionTypeId == null
                              ? 'Question type is required'
                              : null,
                        ),
                        dropdownColor: Colors.white,
                        hint: const Text('Type'),
                        items: questionTypes.map((type) {
                          final String questionTypeString =
                          (type['type'] ?? '').toString().toLowerCase();

                          IconData icon;
                          switch (questionTypeString) {
                            case 'multiple_choices':
                              icon = Icons.radio_button_checked;
                              break;
                            case 'checkbox':
                              icon = Icons.check_box;
                              break;
                            case 'date':
                              icon = Icons.calendar_today;
                              break;
                            case 'datetime':
                              icon = Icons.access_time;
                              break;
                            case 'text':
                              icon = Icons.short_text;
                              break;
                            case 'user':
                              icon = Icons.person;
                              break;
                            case 'signature':
                              icon = Icons.draw;
                              break;
                            default:
                              icon = Icons.question_answer;
                          }

                          return DropdownMenuItem<int>(
                            value: type['id'] as int?,
                            child: Row(
                              children: [
                                Icon(icon, size: 20, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    (type['type'] ?? '').toString(),
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: false,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: onTypeChanged,
                      ),
                    ),
                  ],
                ),

                if (requiresOptions) ...[
                  const SizedBox(height: 16),
                  ResponseOptionsManager(
                    options: const [],
                    onOptionsChanged: (updatedOptions) {
                      print('Options updated: $updatedOptions');
                    },
                    questionType: questionTypes
                        .firstWhere(
                          (type) => type['id'] == selectedQuestionTypeId,
                      orElse: () => {'type': ''},
                    )['type']
                        .toString(),
                    // Use positive temporary ID for new questions to avoid API issues
                    formQuestionId: questionId < 0 ? 0 : questionId,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
