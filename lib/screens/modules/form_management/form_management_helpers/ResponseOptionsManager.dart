// lib/screens/modules/form_management/form_management_helpers/ResponseOptionsManager.dart


import 'package:flutter/material.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';


class ResponseOptionsManager extends StatefulWidget {
  final List<String> options;
  final Function(List<String>) onOptionsChanged;
  final String questionType;
  final int formQuestionId;

  const ResponseOptionsManager({
    Key? key,
    required this.options,
    required this.onOptionsChanged,
    required this.questionType,
    required this.formQuestionId,
  }) : super(key: key);

  @override
  _ResponseOptionsManagerState createState() => _ResponseOptionsManagerState();
}

class _ResponseOptionsManagerState extends State<ResponseOptionsManager> {
  late List<TextEditingController> _controllers;
  final AnswerApiService _answerApiService = AnswerApiService();
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = widget.options.isEmpty
        ? [TextEditingController()]
        : widget.options.map((option) => TextEditingController(text: option)).toList();

    // If no options yet, start with 2 empty options for user convenience
    if (_controllers.isEmpty) {
      _controllers = [TextEditingController(), TextEditingController()];
    }

    // Add listeners to detect changes
    for (var controller in _controllers) {
      controller.addListener(_detectChanges);
    }
  }

  void _detectChanges() {
    if (!mounted) return;

    setState(() {
      _hasChanges = true;
    });

    // Update parent with current values
    _updateOptions();
  }

  void _addOption() {
    setState(() {
      _controllers.add(TextEditingController());
      _controllers.last.addListener(_detectChanges);
      _hasChanges = true;
    });
  }

  void _removeOption(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
      _hasChanges = true;
    });
    _updateOptions();
  }

  void _updateOptions() {
    List<String> currentOptions = _controllers.map((c) => c.text).toList();
    widget.onOptionsChanged(currentOptions);
  }


  /*
  Future<void> _saveOptions() async {
    if (!_hasChanges) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Filter out empty options
      List<String> validOptions = _controllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (validOptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one option')),
        );
        return;
      }

      // Create and assign each option to the question
      for (String optionText in validOptions) {
        // First create the answer
        final answerData = {'value': optionText};
        final createdAnswer = await _answerApiService.createAnswer(
          context,
          answerData,
        );

        // Then assign it to the question
        if (createdAnswer['status'] == 200 || createdAnswer['status'] == 201) {
          final int answerId = createdAnswer['answer']['id'];
          await _answerApiService.assignAnswerToQuestion(
            context,
            widget.formQuestionId,
            answerId,
          );
        }
      }

      setState(() {
        _hasChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Options saved successfully'),
          duration: Duration(seconds: 1),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving options: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }*/

  Future<void> _saveOptions() async {
    if (!_hasChanges) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Filter out empty options
      List<String> validOptions = _controllers
          .map((c) => c.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      if (validOptions.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add at least one option')),
        );
        return;
      }

      // Track successful assignments
      int successfulAssignments = 0;

      // Create and assign each option to the question
      for (String optionText in validOptions) {
        try {
          // First create the answer
          final answerData = {'value': optionText};
          final createdAnswer = await _answerApiService.createAnswer(
            context,
            answerData,
          );

          // Then assign it to the question
          if (createdAnswer['status'] == 200 || createdAnswer['status'] == 201) {
            final int answerId = createdAnswer['answer']['id'];
            try {
              await _answerApiService.assignAnswerToQuestion(
                context,
                widget.formQuestionId,
                answerId,
              );
              successfulAssignments++;
            } catch (e) {
              print('Failed to assign answer: $e');
              // Continue with the next option instead of throwing
            }
          }
        } catch (e) {
          print('Failed to create answer: $e');
          // Continue with the next option instead of throwing
        }
      }

      setState(() {
        _hasChanges = false;
      });

      // Show appropriate message based on success
      if (successfulAssignments > 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Successfully saved $successfulAssignments options'),
            duration: Duration(seconds: 1),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save options. Please try again.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving options: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = widget.questionType.toLowerCase().contains('checkbox')
        ? Icons.check_box_outline_blank
        : widget.questionType.toLowerCase().contains('multiple_choice')
        ? Icons.radio_button_unchecked
        : Icons.arrow_drop_down;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Options list
        ...List.generate(
          _controllers.length,
              (index) => _buildOptionInput(index, icon),
        ),

        // Add option button
        TextButton.icon(
          onPressed: _addOption,
          icon: const Icon(Icons.add, size: 20),
          label: const Text('Add option'),
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF673AB7),
            padding: const EdgeInsets.symmetric(vertical: 4),
          ),
        ),

        // Save button - only show when there are changes
        if (_hasChanges)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _saveOptions,
              icon: _isLoading
                  ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.save),
              label: Text(_isLoading ? 'Saving...' : 'Save Options'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF673AB7),
                foregroundColor: Colors.white,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOptionInput(int index, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextFormField(
              controller: _controllers[index],
              decoration: InputDecoration(
                hintText: 'Option ${index + 1}',
                border: const UnderlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _controllers.length > 1 ? () => _removeOption(index) : null,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_detectChanges);
      controller.dispose();
    }
    super.dispose();
  }
}


/*
import 'package:flutter/material.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';

class ResponseOptionsManager extends StatefulWidget {
  final List<String> options;
  final Function(List<String>) onOptionsChanged;
  final String questionType;
  final int formQuestionId; // Add this parameter to identify the question

  const ResponseOptionsManager({
    Key? key,
    required this.options,
    required this.onOptionsChanged,
    required this.questionType,
    required this.formQuestionId, // Required to link answers to this question
  }) : super(key: key);

  @override
  State<ResponseOptionsManager> createState() => _ResponseOptionsManagerState();
}

class _ResponseOptionsManagerState extends State<ResponseOptionsManager> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;
  final AnswerApiService _answerApiService = AnswerApiService();
  List<Map<String, dynamic>> _savedAnswers = []; // Track existing saved answers

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    // Create controllers and focus nodes for existing options or initialize with one empty option
    _controllers = widget.options.isEmpty
        ? [TextEditingController()]
        : widget.options.map((option) => TextEditingController(text: option)).toList();

    _focusNodes = List.generate(_controllers.length, (_) => FocusNode());

    // Add listener to each controller to detect when to add a new option
    for (int i = 0; i < _controllers.length; i++) {
      _controllers[i].addListener(() {
        _checkForNewOptionNeeded(i);
      });
    }
  }

  void _checkForNewOptionNeeded(int index) {
    // If text is entered in the last field, add a new empty option field
    if (index == _controllers.length - 1 && _controllers[index].text.isNotEmpty) {
      setState(() {
        _controllers.add(TextEditingController());
        _focusNodes.add(FocusNode());

        // Add listener to the new controller
        _controllers.last.addListener(() {
          _checkForNewOptionNeeded(_controllers.length - 1);
        });
      });

      _updateOptions();
    }
  }

  void _removeOption(int index) {
    if (_controllers.length <= 1) return; // Keep at least one option

    final removedText = _controllers[index].text;

    setState(() {
      _controllers[index].dispose();
      _focusNodes[index].dispose();
      _controllers.removeAt(index);
      _focusNodes.removeAt(index);
    });

    _updateOptions();

    // If this option was saved to the API, we should remove it
    // This would require tracking which options are saved and their IDs
    final matchedSavedAnswer = _savedAnswers.firstWhere(
          (answer) => answer['value'] == removedText,
      orElse: () => {},
    );

    if (matchedSavedAnswer.isNotEmpty && matchedSavedAnswer.containsKey('id')) {
      _deleteAnswer(matchedSavedAnswer['form_answer_id']);
    }
  }

  Future<void> _deleteAnswer(int formAnswerId) async {
    try {
      await _answerApiService.deleteAnswerFromQuestion(
        context,
        formAnswerId,
      );

      // Update our list of saved answers
      setState(() {
        _savedAnswers.removeWhere((answer) => answer['form_answer_id'] == formAnswerId);
      });
    } catch (e) {
      print('Error deleting answer: $e');
      // Optionally show an error message
    }
  }

  // This method creates and assigns answers
  Future<void> _saveOptionToAPI(String optionText) async {
    if (optionText.isEmpty) return;

    try {
      // Check if this option was already saved (to avoid duplicates)
      final alreadySaved = _savedAnswers.any((answer) => answer['value'] == optionText);
      if (alreadySaved) return;

      // Create the answer
      final answerData = {
        'value': optionText,
      };

      final createdAnswer = await _answerApiService.createAnswer(
        context,
        answerData,
      );

      // Now assign it to the question
      final assignResult = await _answerApiService.assignAnswerToQuestion(
        context,
        widget.formQuestionId,
        createdAnswer['answer']['id'],
      );

      // Track this saved answer for future reference
      setState(() {
        _savedAnswers.add({
          'id': createdAnswer['answer']['id'],
          'form_answer_id': assignResult['form_answer']['id'],
          'value': optionText,
        });
      });
    } catch (e) {
      print('Error saving option: $e');
      // Optionally show an error message
    }
  }

  void _updateOptions() {
    // Get non-empty options
    final nonEmptyOptions = _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    // Call the callback with updated options
    widget.onOptionsChanged(nonEmptyOptions);

    // Delay actual API saving slightly to avoid excessive API calls while typing
    Future.delayed(const Duration(milliseconds: 500), () {
      // If the component is still mounted, proceed with saving
      if (mounted) {
        for (final option in nonEmptyOptions) {
          _saveOptionToAPI(option);
        }
      }
    });
  }

  IconData _getOptionIcon() {
    switch (widget.questionType.toLowerCase()) {
      case 'multiple_choice':
      case 'multiple_choices':
        return Icons.radio_button_unchecked;
      case 'checkbox':
        return Icons.check_box_outline_blank;
      case 'dropdown':
        return Icons.arrow_drop_down_circle_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Option fields
        ...List.generate(_controllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                // Option icon based on question type
                Icon(_getOptionIcon(), size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),

                // Option text field
                Expanded(
                  child: TextField(
                    controller: _controllers[index],
                    focusNode: _focusNodes[index],
                    decoration: InputDecoration(
                      hintText: 'Option ${index + 1}',
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    onChanged: (_) => _updateOptions(),
                    onSubmitted: (_) {
                      // Focus next field or add a new one if this is the last
                      if (index < _controllers.length - 1) {
                        FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                      }
                    },
                  ),
                ),

                // Remove option button
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  color: Colors.grey[600],
                  splashRadius: 20,
                  visualDensity: VisualDensity.compact,
                  onPressed: _controllers.length > 1 ? () => _removeOption(index) : null,
                ),
              ],
            ),
          );
        }),

        // "Add 'Other'" option
        Padding(
          padding: const EdgeInsets.only(left: 28, top: 8),
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                final otherIndex = _controllers.length;
                _controllers.add(TextEditingController(text: 'Other'));
                _focusNodes.add(FocusNode());

                // Focus the newly added "Other" option
                Future.microtask(() {
                  FocusScope.of(context).requestFocus(_focusNodes[otherIndex]);
                });

                _updateOptions();
              });
            },
            icon: const Icon(
              Icons.add,
              size: 18,
              color: Color(0xFF673AB7), // Google Forms purple
            ),
            label: Text(
              'Add "Other"',
              style: TextStyle(
                color: const Color(0xFF673AB7),
                fontSize: 14,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }
}*/


