
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DynamicQuestionInput extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(dynamic) onAnswerChanged;
  final dynamic currentValue;

  const DynamicQuestionInput({
    Key? key,
    required this.question,
    required this.onAnswerChanged,
    this.currentValue,
  }) : super(key: key);

  @override
  _DynamicQuestionInputState createState() => _DynamicQuestionInputState();
}

class _DynamicQuestionInputState extends State<DynamicQuestionInput> {
  late TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.currentValue?.toString());
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  bool get isRequired => widget.question['is_required'] ?? true; // Default to true

  @override
  Widget build(BuildContext context) {
    final questionType = widget.question['type']?.toString().toLowerCase() ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isRequired)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Optional',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        const SizedBox(height: 8),
        _buildInputByType(questionType),
      ],
    );
  }

  Widget _buildInputByType(String questionType) {
    switch (questionType) {
      case 'checkbox':
        return _buildCheckboxInput();
      case 'multiple_choice':
      case 'multiple_choices':
        return _buildMultipleChoiceInput();
      case 'radio':
        return _buildMultipleChoiceInput();
      case 'date':
        return _buildDateInput();
      case 'signature':
        return _buildSignatureInput();
      case 'file_upload':
        return _buildFileUploadInput();
      case 'linear_scale':
        return _buildLinearScaleInput();
      default:
        return _buildTextInput();
    }
  }

  Widget _buildCheckboxInput() {
    final options = widget.question['possible_answers'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        final bool isSelected = widget.currentValue?.contains(option['id']) ?? false;
        return CheckboxListTile(
          title: Text(option['value']),
          value: isSelected,
          onChanged: (bool? value) {
            List<int> currentSelections = List<int>.from(widget.currentValue ?? []);
            if (value == true) {
              currentSelections.add(option['id']);
            } else {
              currentSelections.remove(option['id']);
            }
            widget.onAnswerChanged(currentSelections);
          },
        );
      }).toList(),
    );
  }

  Widget _buildMultipleChoiceInput() {
    final options = widget.question['possible_answers'] as List? ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: options.map((option) {
        return RadioListTile<int>(
          title: Text(option['value']),
          value: option['id'],
          groupValue: widget.currentValue,
          onChanged: (value) {
            widget.onAnswerChanged(value);
          },
        );
      }).toList(),
    );
  }

  Widget _buildDateInput() {
    return InkWell(
      onTap: () async {
        final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: widget.currentValue != null
              ? DateTime.parse(widget.currentValue)
              : DateTime.now(),
          firstDate: DateTime(1900),
          lastDate: DateTime(2100),
        );
        if (picked != null) {
          widget.onAnswerChanged(DateFormat('yyyy-MM-dd').format(picked));
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
          hintText: 'Select date',
          filled: true,
          fillColor: Colors.white,
        ),
        child: Text(
          widget.currentValue != null
              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.currentValue))
              : 'Select date',
          style: TextStyle(
            color: widget.currentValue != null ? Colors.black : Colors.grey[600],
          ),
        ),
      ),
    );
  }

  Widget _buildSignatureInput() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Signature pad will be implemented here'),
      ),
    );
  }

  Widget _buildFileUploadInput() {
    return ElevatedButton.icon(
      onPressed: () {
        // Implement file upload logic
      },
      icon: const Icon(Icons.upload_file),
      label: const Text('Upload File'),
    );
  }

  Widget _buildLinearScaleInput() {
    return Slider(
      value: (widget.currentValue ?? 0).toDouble(),
      min: 0,
      max: 10,
      divisions: 10,
      label: widget.currentValue?.toString() ?? '0',
      onChanged: (value) {
        widget.onAnswerChanged(value.round());
      },
    );
  }

  Widget _buildTextInput() {
    return TextField(
      controller: _textController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter your answer',
        filled: true,
        fillColor: Colors.white,
      ),
      onChanged: widget.onAnswerChanged,
      maxLines: widget.question['type'] == 'paragraph' ? 3 : 1,
    );
  }
}