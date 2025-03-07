// lib/screens/modules/form_management/form_management_helpers/ResponseOptionsManager.dart

import 'package:flutter/material.dart';

class ResponseOptionsManager extends StatefulWidget {
  final List<String> options;
  final Function(List<String>) onOptionsChanged;
  final String questionType; // multiple_choice, checkbox, or dropdown

  const ResponseOptionsManager({
    Key? key,
    required this.options,
    required this.onOptionsChanged,
    required this.questionType,
  }) : super(key: key);

  @override
  State<ResponseOptionsManager> createState() => _ResponseOptionsManagerState();
}

class _ResponseOptionsManagerState extends State<ResponseOptionsManager> {
  late List<TextEditingController> _controllers;
  late List<FocusNode> _focusNodes;

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

    setState(() {
      _controllers[index].dispose();
      _focusNodes[index].dispose();
      _controllers.removeAt(index);
      _focusNodes.removeAt(index);
    });

    _updateOptions();
  }

  void _updateOptions() {
    widget.onOptionsChanged(_controllers.map((c) => c.text.trim()).where((text) => text.isNotEmpty).toList());
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
}