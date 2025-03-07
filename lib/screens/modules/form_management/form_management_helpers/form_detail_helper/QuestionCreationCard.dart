/*// lib/screens/modules/form_management/form_detail_helper/QuestionCreationCard.dart
import 'package:flutter/material.dart';

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
    this.showValidationError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final dropdownWidth = isPortrait
        ? mediaQuery.size.width * 0.4
        : mediaQuery.size.width * 0.25;

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
            child: Row(
              children: [
                // Question text field
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: questionTextController,
                    decoration: InputDecoration(
                      hintText: 'Question title',
                      border: UnderlineInputBorder(),
                      hintStyle: TextStyle(fontSize: 16),
                      errorText: showValidationError && questionTextController.text.isEmpty
                          ? 'Question text is required'
                          : null,
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                // Question type dropdown
                Container(
                  width: dropdownWidth,
                  child: isLoadingQuestionTypes
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
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
          ),
          const SizedBox(height: 16),
          // Bottom bar with required toggle and cancel button
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Required toggle with label indicating current state
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isRequired ? 'Required' : 'Optional',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isRequired ? Colors.black : Colors.grey[600],
                          ),
                        ),
                        Switch(
                          value: isRequired,
                          onChanged: onRequiredChanged,
                          activeColor: const Color.fromARGB(255, 9, 68, 196),
                        ),
                      ],
                    ),
                    if (isRequired)
                      Text(
                        '~ will be added to required questions',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.delete_outlined,
                      color: Color.fromARGB(255, 110, 110, 110)),
                  iconSize: 32.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/


/*
// lib/screens/modules/form_management/form_detail_helper/QuestionCreationCard.dart

import 'package:flutter/material.dart';
// Add this import for the new controls
import 'GoogleFormsQuestionControls.dart';

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
    this.showValidationError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final dropdownWidth = isPortrait
        ? mediaQuery.size.width * 0.4
        : mediaQuery.size.width * 0.25;

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
            child: Row(
              children: [
                // Question text field
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
                // Question type dropdown
                Container(
                  width: dropdownWidth,
                  child: isLoadingQuestionTypes
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : DropdownButtonFormField<int>(
                    value: selectedQuestionTypeId,
                    isDense: true,
                    isExpanded: true,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                        const BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide:
                        const BorderSide(color: Colors.grey),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      errorText: showValidationError &&
                          selectedQuestionTypeId == null
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
                            Icon(icon,
                                size: 20, color: Colors.grey[700]),
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
          ),

          // Replace the bottom bar with our GoogleFormsQuestionControls
          GoogleFormsQuestionControls(
            isRequired: isRequired,
            onRequiredChanged: onRequiredChanged,
            onDuplicate: () {
              // No duplication logic here for new questions
            },
            onDelete: onCancel,
          ),
        ],
      ),
    );
  }
}
*/

// lib/screens/modules/form_management/form_detail_helper/QuestionCreationCard.dart

import 'package:flutter/material.dart';
// Add this import at the top
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
    this.showValidationError = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final dropdownWidth = isPortrait
        ? mediaQuery.size.width * 0.4
        : mediaQuery.size.width * 0.25;

    // Check if the question type requires options
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
                    // Question text field
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
                    // Question type dropdown
                    Container(
                      width: dropdownWidth,
                      child: isLoadingQuestionTypes
                          ? const Center(
                        child: CircularProgressIndicator(),
                      )
                          : DropdownButtonFormField<int>(
                        value: selectedQuestionTypeId,
                        isDense: true,
                        isExpanded: true,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                            const BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                            const BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          errorText: showValidationError &&
                              selectedQuestionTypeId == null
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
                                Icon(icon,
                                    size: 20, color: Colors.grey[700]),
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

                // Add ResponseOptionsManager if the question type requires options
                if (requiresOptions) ...[
                  const SizedBox(height: 16),
                  ResponseOptionsManager(
                    options: const [], // Start with empty options
                    onOptionsChanged: (updatedOptions) {
                      // Store or handle the updated options for this question
                      print('Options updated: $updatedOptions');
                    },
                    questionType: questionTypes
                        .firstWhere(
                          (type) => type['id'] == selectedQuestionTypeId,
                      orElse: () => {'type': ''},
                    )['type']
                        .toString(),
                  ),
                ],
              ],
            ),
          ),

          // Bottom bar with Required toggle and actions
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Required toggle with label
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          isRequired ? 'Required' : 'Optional',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isRequired ? Colors.black : Colors.grey[600],
                          ),
                        ),
                        Switch(
                          value: isRequired,
                          onChanged: onRequiredChanged,
                          activeColor: const Color(0xFF673AB7), // Google Forms purple
                        ),
                      ],
                    ),
                    if (isRequired)
                      Text(
                        '~ will be added to required questions',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(
                    Icons.delete_outlined,
                    color: Color.fromARGB(255, 110, 110, 110),
                  ),
                  iconSize: 32.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
