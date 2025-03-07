/*

// lib/screens/modules/form_management/form_management_helpers/QuestionCreationManager.dart

import 'package:flutter/material.dart';

class QuestionCreationManager {
  // Singleton pattern to ensure consistent state
  static final QuestionCreationManager _instance = QuestionCreationManager._internal();
  factory QuestionCreationManager() => _instance;
  QuestionCreationManager._internal();

  // Callback type for question type selection
  typedef QuestionTypeSelectedCallback = void Function(int typeId);

  // Show question type selection dropdown immediately after adding a question
  void showQuestionTypeSelection(
      BuildContext context,
      List<dynamic> questionTypes,
      QuestionTypeSelectedCallback onTypeSelected,
      ) {
    // Use a post-frame callback to ensure the UI is built before showing the dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTypeSelectionBottomSheet(context, questionTypes, onTypeSelected);
    });
  }

  // Bottom sheet for question type selection
  void _showTypeSelectionBottomSheet(
      BuildContext context,
      List<dynamic> questionTypes,
      QuestionTypeSelectedCallback onTypeSelected,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 16),
              child: Text(
                'Choose question type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: questionTypes.length,
                itemBuilder: (context, index) {
                  final type = questionTypes[index];
                  final String questionTypeString =
                  (type['type'] ?? '').toString();

                  IconData icon;
                  switch (questionTypeString.toLowerCase()) {
                    case 'multiple_choice':
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
                    case 'short_text':
                      icon = Icons.short_text;
                      break;
                    case 'paragraph':
                      icon = Icons.subject;
                      break;
                    case 'user':
                      icon = Icons.person;
                      break;
                    case 'signature':
                      icon = Icons.draw;
                      break;
                    case 'dropdown':
                      icon = Icons.arrow_drop_down_circle;
                      break;
                    case 'file_upload':
                      icon = Icons.upload_file;
                      break;
                    case 'linear_scale':
                      icon = Icons.linear_scale;
                      break;
                    default:
                      icon = Icons.question_answer;
                  }

                  return ListTile(
                    leading: Icon(icon, color: const Color(0xFF673AB7)), // Google Forms purple
                    title: Text(questionTypeString),
                    onTap: () {
                      // Close the sheet and notify about selection
                      Navigator.of(context).pop();
                      onTypeSelected(type['id']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}



 */


// lib/screens/modules/form_management/form_management_helpers/QuestionCreationManager.dart

import 'package:flutter/material.dart';

// Move the typedef outside the class to the file level
typedef QuestionTypeSelectedCallback = void Function(int typeId);

class QuestionCreationManager {
  // Singleton pattern to ensure consistent state
  static final QuestionCreationManager _instance = QuestionCreationManager._internal();
  factory QuestionCreationManager() => _instance;
  QuestionCreationManager._internal();

  // Show question type selection dropdown immediately after adding a question
  void showQuestionTypeSelection(
      BuildContext context,
      List<dynamic> questionTypes,
      QuestionTypeSelectedCallback onTypeSelected,
      ) {
    // Use a post-frame callback to ensure the UI is built before showing the dropdown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showTypeSelectionBottomSheet(context, questionTypes, onTypeSelected);
    });
  }

  // Bottom sheet for question type selection
 /* void _showTypeSelectionBottomSheet(
      BuildContext context,
      List<dynamic> questionTypes,
      QuestionTypeSelectedCallback onTypeSelected,
      ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true, // Allow the sheet to be taller
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6, // Set fixed height
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 16),
              child: Text(
                'Choose question type',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: questionTypes.length,
                itemBuilder: (context, index) {
                  final type = questionTypes[index];
                  final String questionTypeString =
                  (type['type'] ?? '').toString();

                  IconData icon;
                  switch (questionTypeString.toLowerCase()) {
                    case 'multiple_choice':
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
                    case 'short_text':
                      icon = Icons.short_text;
                      break;
                    case 'paragraph':
                      icon = Icons.subject;
                      break;
                    case 'user':
                      icon = Icons.person;
                      break;
                    case 'signature':
                      icon = Icons.draw;
                      break;
                    case 'dropdown':
                      icon = Icons.arrow_drop_down_circle;
                      break;
                    case 'file_upload':
                      icon = Icons.upload_file;
                      break;
                    case 'linear_scale':
                      icon = Icons.linear_scale;
                      break;
                    default:
                      icon = Icons.question_answer;
                  }

                  return ListTile(
                    leading: Icon(icon, color: const Color(0xFF673AB7)), // Google Forms purple
                    title: Text(questionTypeString),
                    onTap: () {
                      // Close the sheet and notify about selection
                      Navigator.of(context).pop();
                      onTypeSelected(type['id']);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }*/


// Replace the _showTypeSelectionBottomSheet method in QuestionCreationManager.dart

  void _showTypeSelectionBottomSheet(
      BuildContext context,
      List<dynamic> questionTypes,
      QuestionTypeSelectedCallback onTypeSelected,
      ) {
    // Use Dialog instead of BottomSheet for better sizing control
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400,
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choose question type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: questionTypes.length,
                      itemBuilder: (context, index) {
                        final type = questionTypes[index];
                        final String questionTypeString =
                        (type['type'] ?? '').toString();

                        IconData icon;
                        // Your existing icon selection switch case...
                        switch (questionTypeString.toLowerCase()) {
                          case 'multiple_choice':
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
                          case 'short_text':
                            icon = Icons.short_text;
                            break;
                          case 'paragraph':
                            icon = Icons.subject;
                            break;
                          case 'user':
                            icon = Icons.person;
                            break;
                          case 'signature':
                            icon = Icons.draw;
                            break;
                          case 'dropdown':
                            icon = Icons.arrow_drop_down_circle;
                            break;
                          case 'file_upload':
                            icon = Icons.upload_file;
                            break;
                          case 'linear_scale':
                            icon = Icons.linear_scale;
                            break;
                          default:
                            icon = Icons.question_answer;
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.of(context).pop();
                            onTypeSelected(type['id']);
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 8,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  icon,
                                  color: const Color(0xFF673AB7),
                                  size: 24,
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  questionTypeString,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}