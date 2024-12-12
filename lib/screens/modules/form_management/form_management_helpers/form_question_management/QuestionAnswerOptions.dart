import 'package:flutter/material.dart';

import '../../../../../models/form_models/question_type.dart';

class QuestionAnswerOptions extends StatefulWidget {
  final QuestionType questionType;
  final List<String> options;
  final Function(List<String>) onOptionsChanged;

  const QuestionAnswerOptions({
    Key? key,
    required this.questionType,
    required this.options,
    required this.onOptionsChanged,
  }) : super(key: key);

  @override
  _QuestionAnswerOptionsState createState() => _QuestionAnswerOptionsState();
}

class _QuestionAnswerOptionsState extends State<QuestionAnswerOptions> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _controllers = widget.options.isEmpty
        ? [TextEditingController()]
        : widget.options.map((option) => TextEditingController(text: option)).toList();
  }

  void _addOption() {
    setState(() {
      _controllers.add(TextEditingController());
    });
    _updateOptions();
  }

  void _removeOption(int index) {
    setState(() {
      _controllers[index].dispose();
      _controllers.removeAt(index);
    });
    _updateOptions();
  }

  void _updateOptions() {
    widget.onOptionsChanged(_controllers.map((c) => c.text).toList());
  }

  Widget _buildOptionInput(int index) {
    final controller = _controllers[index];
    final icon = widget.questionType == QuestionType.checkbox
        ? Icons.check_box_outline_blank
        : widget.questionType == QuestionType.multiple_choice
            ? Icons.radio_button_unchecked
            : Icons.arrow_drop_down;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Opción ${index + 1}',
                border: const UnderlineInputBorder(),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              ),
              onChanged: (value) => _updateOptions(),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _controllers.length > 1 ? () => _removeOption(index) : null,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildDateInput() {
    return const Text('Campo de tipo fecha');
  }

  Widget _buildTextInput() {
    return TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'El usuario podrá escribir su respuesta aquí',
        enabled: false,
      ),
      maxLines: widget.questionType == QuestionType.paragraph ? 3 : 1,
      enabled: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.questionType.requiresOptions) {
      if (widget.questionType == QuestionType.date) {
        return _buildDateInput();
      }
      return _buildTextInput();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(
          _controllers.length,
          (index) => _buildOptionInput(index),
        ),
        TextButton.icon(
          onPressed: _addOption,
          icon: const Icon(Icons.add),
          label: const Text('Agregar opción'),
        ),
        if (widget.questionType == QuestionType.multiple_choice ||
            widget.questionType == QuestionType.checkbox)
          TextButton.icon(
            onPressed: () => _addOption(),
            icon: const Icon(Icons.add),
            label: const Text('o agregar "Otro"'),
          ),
      ],
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
}