import 'package:flutter/material.dart';

class AnswerItemWidget extends StatelessWidget {
  final dynamic answer;
  final String questionType;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AnswerItemWidget({
    Key? key,
    required this.answer,
    required this.questionType,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget leadingIcon;
    switch (questionType) {
      case 'radio':
        leadingIcon = const Icon(
          Icons.radio_button_unchecked,
          size: 20,
          color: Colors.grey,
        );
        break;
      case 'checkbox':
        leadingIcon = const Icon(
          Icons.check_box_outline_blank,
          size: 20,
          color: Colors.grey,
        );
        break;
      default:
        leadingIcon = const Icon(
          Icons.circle,
          size: 8,
          color: Colors.grey,
        );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          leadingIcon,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              answer['value'],
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: onEdit,
            tooltip: 'Edit answer',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 20),
            onPressed: onDelete,
            color: Colors.red,
            tooltip: 'Delete answer',
          ),
        ],
      ),
    );
  }
}
