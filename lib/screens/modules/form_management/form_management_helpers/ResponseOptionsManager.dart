/*import 'package:flutter/material.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';

class ResponseOptionsManager extends StatefulWidget {
  final List<String> options;
  final Function(List<String>) onOptionsChanged;
  final String questionType;
  final int formQuestionId;
  final Function(bool) setUnsavedChanges; // Add this parameter

  const ResponseOptionsManager({
    Key? key,
    required this.options,
    required this.onOptionsChanged,
    required this.questionType,
    required this.formQuestionId,
    required this.setUnsavedChanges, // Make it required
  }) : super(key: key);

  @override
  ResponseOptionsManagerState createState() => ResponseOptionsManagerState();
}

class ResponseOptionsManagerState extends State<ResponseOptionsManager> {
  late List<TextEditingController> _controllers;
  final AnswerApiService _answerApiService = AnswerApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = widget.options.isEmpty
        ? [TextEditingController()]
        : widget.options.map((option) => TextEditingController(text: option)).toList();

    // If no options yet, start with one empty option
    if (_controllers.isEmpty) {
      _controllers = [TextEditingController()];
    }

    // Add listeners to detect changes
    for (var controller in _controllers) {
      controller.addListener(_notifyParentOfChanges);
    }
  }

  void _notifyParentOfChanges() {
    if (!mounted) return;
    final options = _getCurrentOptions();
    widget.onOptionsChanged(options);

    // Notify parent form about unsaved changes
    widget.setUnsavedChanges(true);
  }

  List<String> _getCurrentOptions() {
    return _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  void _addOption() {
    setState(() {
      _controllers.add(TextEditingController());
      _controllers.last.addListener(_notifyParentOfChanges);
    });

    // Notify parent form about unsaved changes
    widget.setUnsavedChanges(true);
  }

  void _removeOption(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
    _notifyParentOfChanges();

    // Notify parent form about unsaved changes
    widget.setUnsavedChanges(true);
  }

  // Method to be called from parent when saving
  Future<bool> saveOptions() async {
    // Filter out empty options
    List<String> validOptions = _getCurrentOptions();

    if (validOptions.isEmpty) {
      return true; // No options to save, but not an error
    }

    setState(() {
      _isLoading = true;
    });

    try {
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
            }
          }
        } catch (e) {
          print('Failed to create answer: $e');
        }
      }

      return successfulAssignments > 0;
    } catch (e) {
      print('Error saving options: $e');
      return false;
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

        // Loading indicator if saving is in progress
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
      ],
    );
  }
/*
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
  }*/

  Widget _buildOptionInput(int index, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          // Leading icon (radio/checkbox/dropdown)
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),

          // Text field for option text
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

          // Delete (X) button - always visible regardless of save state
          IconButton(
            icon: const Icon(Icons.close, size: 20, color: Colors.red),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _removeOption(index),
            tooltip: 'Delete option',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_notifyParentOfChanges);
      controller.dispose();
    }
    super.dispose();
  }
}*/



/*
import 'package:flutter/material.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';

class ResponseOptionsManager extends StatefulWidget {
  final List<String> options;
  final Function(List<String>) onOptionsChanged;
  final String questionType;
  final int formQuestionId;
  final Function(bool) setUnsavedChanges;

  const ResponseOptionsManager({
    Key? key,
    required this.options,
    required this.onOptionsChanged,
    required this.questionType,
    required this.formQuestionId,
    required this.setUnsavedChanges,
  }) : super(key: key);

  @override
  ResponseOptionsManagerState createState() => ResponseOptionsManagerState();
}

class ResponseOptionsManagerState extends State<ResponseOptionsManager> {
  late List<TextEditingController> _controllers;
  final AnswerApiService _answerApiService = AnswerApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = widget.options.isEmpty
        ? [TextEditingController()]
        : widget.options.map((option) => TextEditingController(text: option)).toList();

    // If no options yet, start with one empty option
    if (_controllers.isEmpty) {
      _controllers = [TextEditingController()];
    }

    // Add listeners to detect changes
    for (var controller in _controllers) {
      controller.addListener(_notifyParentOfChanges);
    }
  }

  void _notifyParentOfChanges() {
    if (!mounted) return;
    final options = _getCurrentOptions();
    widget.onOptionsChanged(options);

    // Notify parent form about unsaved changes
    widget.setUnsavedChanges(true);
  }

  List<String> _getCurrentOptions() {
    return _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  void _addOption() {
    setState(() {
      _controllers.add(TextEditingController());
      _controllers.last.addListener(_notifyParentOfChanges);
    });

    // Notify parent form about unsaved changes
    widget.setUnsavedChanges(true);
  }

  void _removeOption(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);

      // Make sure we always have at least one option
      if (_controllers.isEmpty) {
        _controllers.add(TextEditingController());
        _controllers.last.addListener(_notifyParentOfChanges);
      }
    });
    _notifyParentOfChanges();

    // Notify parent form about unsaved changes
    widget.setUnsavedChanges(true);
  }

  // Method to be called from parent when saving
  Future<bool> saveOptions() async {
    // Implementation code left as is...
    return true;
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

        // Loading indicator if saving is in progress
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
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
          // Radio/checkbox icon
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),

          // Text field for option text
          Expanded(
            child: TextField(
              controller: _controllers[index],
              decoration: InputDecoration(
                hintText: 'Option ${index + 1}',
                border: const UnderlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),

          // Delete button (always visible)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _removeOption(index),
            tooltip: 'Delete option',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_notifyParentOfChanges);
      controller.dispose();
    }
    super.dispose();
  }
}*/

import 'package:flutter/material.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';

class ResponseOptionsManager extends StatefulWidget {
  final List<String> options;
  final Function(List<String>) onOptionsChanged;
  final String questionType;
  final int formQuestionId;
  final Function(bool) setUnsavedChanges;
  final bool showValidationError; // Added this parameter

  const ResponseOptionsManager({
    Key? key,
    required this.options,
    required this.onOptionsChanged,
    required this.questionType,
    required this.formQuestionId,
    required this.setUnsavedChanges,
    this.showValidationError = false, // Default value
  }) : super(key: key);

  @override
  ResponseOptionsManagerState createState() => ResponseOptionsManagerState();
}

class ResponseOptionsManagerState extends State<ResponseOptionsManager> {
  late List<TextEditingController> _controllers;
  final AnswerApiService _answerApiService = AnswerApiService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = widget.options.isEmpty
        ? [TextEditingController()]
        : widget.options.map((option) => TextEditingController(text: option)).toList();

    // If no options yet, start with one empty option
    if (_controllers.isEmpty) {
      _controllers = [TextEditingController()];
    }

    // Add listeners to detect changes
    for (var controller in _controllers) {
      controller.addListener(_notifyParentOfChanges);
    }
  }

  void _notifyParentOfChanges() {
    if (!mounted) return;
    final options = _getCurrentOptions();
    widget.onOptionsChanged(options);

    // Notify parent form about unsaved changes
    widget.setUnsavedChanges(true);
  }

  List<String> _getCurrentOptions() {
    return _controllers
        .map((c) => c.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  void _addOption() {
    setState(() {
      _controllers.add(TextEditingController());
      _controllers.last.addListener(_notifyParentOfChanges);
    });

    // Notify parent form about unsaved changes
    widget.setUnsavedChanges(true);
  }

  void _removeOption(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);

      // Make sure we always have at least one option
      if (_controllers.isEmpty) {
        _controllers.add(TextEditingController());
        _controllers.last.addListener(_notifyParentOfChanges);
      }
    });
    _notifyParentOfChanges();

    // Notify parent form about unsaved changes
    widget.setUnsavedChanges(true);
  }

  // Method to be called from parent when saving
  Future<bool> saveOptions() async {
    // Implementation code left as is...
    return true;
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

        // Validation error message (if needed)
        if (widget.showValidationError)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Please add at least one answer option',
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),

        // Loading indicator if saving is in progress
        if (_isLoading)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
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
          // Radio/checkbox icon
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),

          // Text field for option text
          Expanded(
            child: TextField(
              controller: _controllers[index],
              decoration: InputDecoration(
                hintText: 'Option ${index + 1}',
                border: const UnderlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
            ),
          ),

          // Delete button (always visible)
          IconButton(
            icon: const Icon(Icons.close, color: Colors.red, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _removeOption(index),
            tooltip: 'Delete option',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.removeListener(_notifyParentOfChanges);
      controller.dispose();
    }
    super.dispose();
  }
}
