import 'package:flutter/material.dart';
import '../ResponseOptionsManager.dart';

class QuestionCreationCard extends StatefulWidget {
  final TextEditingController questionTextController;
  final int? selectedQuestionTypeId;
  final bool isRequired;
  final bool isLoadingQuestionTypes;
  final List<dynamic> questionTypes;
  final VoidCallback onCancel;
  final ValueChanged<int?> onTypeChanged;
  final ValueChanged<bool> onRequiredChanged;
  final bool showValidationError;
  final int questionId;
  final Function(bool) setUnsavedChanges;
  final Function(List<String>)? onOptionsChanged;

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
    required this.questionId,
    required this.setUnsavedChanges,
    this.onOptionsChanged,
    this.showValidationError = false,
  }) : super(key: key);

  @override
  QuestionCreationCardState createState() => QuestionCreationCardState();
}

class QuestionCreationCardState extends State<QuestionCreationCard> {
  List<String> _currentOptions = [];
  static const int minQuestionTextLength = 3;

  String _getQuestionFieldLabel() {
    // Check if signature type is selected
    if (widget.selectedQuestionTypeId != null) {
      final selectedType = widget.questionTypes
          .firstWhere(
            (type) => type['id'] == widget.selectedQuestionTypeId,
        orElse: () => {'type': ''},
      )['type']
          .toString()
          .toLowerCase();

      if (selectedType == 'signature') {
        return 'Position of the person signing';
      }
    }

    // Default label for other question types
    return 'Question title (Min 3 Characters)';
  }

  // Method to set current options for editing
  void setOptions(List<String> options) {
    setState(() {
      _currentOptions = options;
    });
  }

  // Method to focus the text field (useful when initializing for edit)
  void focusTextField() {
    FocusScope.of(context).requestFocus(FocusNode());
    Future.delayed(const Duration(milliseconds: 100), () {
      FocusScope.of(context).requestFocus(FocusNode());
      widget.questionTextController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: widget.questionTextController.text.length,
      );
    });
  }

  bool _isTextValid() {
    return widget.questionTextController.text.length >= minQuestionTextLength;
  }

  String? _getErrorText() {
    if (!widget.showValidationError) {
      return null;
    }

    if (widget.questionTextController.text.isEmpty) {
      if (widget.selectedQuestionTypeId != null &&
          widget.questionTypes
              .firstWhere(
                (type) => type['id'] == widget.selectedQuestionTypeId,
            orElse: () => {'type': ''},
          )['type']
              .toString()
              .toLowerCase() == 'signature') {
        return 'Position information is required';
      }
      return 'Question text is required';
    } else if (!_isTextValid()) {
      return 'Question text must be at least $minQuestionTextLength characters';
    }

    return null;
  }

  bool _areOptionsValid() {
    final bool requiresOptions = widget.selectedQuestionTypeId != null &&
        widget.questionTypes
            .firstWhere(
              (type) => type['id'] == widget.selectedQuestionTypeId,
          orElse: () => {'type': ''},
        )['type']
            .toString()
            .toLowerCase()
            .contains(RegExp(r'multiple_choice|checkbox|dropdown'));

    if (!requiresOptions) {
      return true;
    }

    // Check if we have at least one non-empty option
    return _currentOptions.isNotEmpty &&
        _currentOptions.any((option) => option.trim().isNotEmpty);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isPortrait = mediaQuery.orientation == Orientation.portrait;
    final dropdownWidth = isPortrait
        ? mediaQuery.size.width * 0.4
        : mediaQuery.size.width * 0.25;

    final bool requiresOptions = widget.selectedQuestionTypeId != null &&
        widget.questionTypes
            .firstWhere(
              (type) => type['id'] == widget.selectedQuestionTypeId,
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
                        controller: widget.questionTextController,
                        decoration: InputDecoration(
                          hintText: _getQuestionFieldLabel(),
                          border: UnderlineInputBorder(),
                          hintStyle: const TextStyle(fontSize: 16),
                          errorText: _getErrorText(),
                        ),
                        style: const TextStyle(fontSize: 16),
                        onChanged: (value) {
                          // Notify parent form of changes
                          widget.setUnsavedChanges(true);

                          // Force rebuild to update validation state
                          if (widget.showValidationError) {
                            setState(() {});
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Container(
                      width: dropdownWidth,
                      child: widget.isLoadingQuestionTypes
                          ? const Center(child: CircularProgressIndicator())
                          : (() {
                        // Crear una copia ordenada de los tipos de preguntas
                        List<dynamic> sortedQuestionTypes = List.from(widget.questionTypes);
                        // Ordenar para que Signature siempre sea el último
                        sortedQuestionTypes.sort((a, b) {
                          String typeA = (a['type'] ?? '').toString().toLowerCase();
                          String typeB = (b['type'] ?? '').toString().toLowerCase();
                          if (typeA == 'signature') return 1;
                          if (typeB == 'signature') return -1;
                          return 0;
                        });

                        return DropdownButtonFormField<int>(
                          value: widget.selectedQuestionTypeId,
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
                            errorText: widget.showValidationError && widget.selectedQuestionTypeId == null
                                ? 'Question type is required'
                                : null,
                          ),
                          dropdownColor: Colors.white,
                          hint: const Text('Type'),
                          items: sortedQuestionTypes.map((type) {
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
                          onChanged: widget.onTypeChanged,
                        );
                      })(),
                    ),
                    // Add the delete button here
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: widget.onCancel,
                      tooltip: 'Delete question',
                    ),
                  ],
                ),

                if (requiresOptions) ...[
                  const SizedBox(height: 16),
                  ResponseOptionsManager(
                    options: _currentOptions,
                    onOptionsChanged: (updatedOptions) {
                      setState(() {
                        _currentOptions = updatedOptions;
                      });

                      // Notify parent about options change
                      if (widget.onOptionsChanged != null) {
                        widget.onOptionsChanged!(updatedOptions);
                      }

                      // Notify parent form of changes
                      widget.setUnsavedChanges(true);
                    },
                    questionType: widget.questionTypes
                        .firstWhere(
                          (type) => type['id'] == widget.selectedQuestionTypeId,
                      orElse: () => {'type': ''},
                    )['type']
                        .toString(),
                    // Use positive temporary ID for new questions to avoid API issues
                    formQuestionId: widget.questionId < 0 ? 0 : widget.questionId,
                    setUnsavedChanges: widget.setUnsavedChanges,
                    showValidationError: widget.showValidationError && requiresOptions && !_areOptionsValid(),
                  ),
                ],
              ],
            ),
          ),
          // Include the controls with delete button
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Required toggle
                Row(
                  children: [
                    Text(
                      'Required',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: widget.isRequired,
                        onChanged: widget.onRequiredChanged,
                        activeColor: const Color(0xFF673AB7),
                        activeTrackColor: const Color(0xFFD1C4E9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Method to get current options - can be called by parent
  List<String> getCurrentOptions() {
    return _currentOptions;
  }

  // Method to validate the entire question card
  bool isValid() {
    if (!_isTextValid()) {
      return false;
    }

    if (widget.selectedQuestionTypeId == null) {
      return false;
    }

    // Check if options are required and valid
    final bool requiresOptions = widget.selectedQuestionTypeId != null &&
        widget.questionTypes
            .firstWhere(
              (type) => type['id'] == widget.selectedQuestionTypeId,
          orElse: () => {'type': ''},
        )['type']
            .toString()
            .toLowerCase()
            .contains(RegExp(r'multiple_choice|checkbox|dropdown'));

    if (requiresOptions && !_areOptionsValid()) {
      return false;
    }

    return true;
  }
}