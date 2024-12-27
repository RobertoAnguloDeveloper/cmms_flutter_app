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

  @override
  Widget build(BuildContext context) {
    final questionType = widget.question['type']?.toString().toLowerCase() ?? '';

    switch (questionType) {
      case 'checkbox':
        return _buildCheckboxInput();
      case 'multiple_choice':
      case 'multiple_choices': // Add this case
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
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        child: Text(
          widget.currentValue != null
              ? DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.currentValue))
              : 'Select date',
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
      child: Center(
        child: Text('Signature pad will be implemented here'),
      ),
    );
  }

  Widget _buildFileUploadInput() {
    return ElevatedButton.icon(
      onPressed: () {
        // Implement file upload logic
      },
      icon: Icon(Icons.upload_file),
      label: Text('Upload File'),
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
      decoration: InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter your answer',
      ),
      onChanged: widget.onAnswerChanged,
      maxLines: widget.question['type'] == 'paragraph' ? 3 : 1,
    );
  }
}