/*import 'package:flutter/material.dart';

class DynamicInputField extends StatelessWidget {
  final String questionType;

  const DynamicInputField({
    Key? key,
    required this.questionType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (questionType) {
      case 'user':
        return _buildUserSelectionField();
      case 'date':
        return Container(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () {}, // Preview only
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Color.fromARGB(255, 34, 118, 186)),
                  const SizedBox(width: 8),
                  Text(
                    'Select Date (DD/MM/YYYY)',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );

      case 'datetime':
        return Container(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () {}, // Preview only
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time,
                      color: Color.fromARGB(255, 34, 118, 186)),
                  const SizedBox(width: 8),
                  Text(
                    'Select Date and Time',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );

      case 'text':
        return Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            enabled: false, // Preview only
            decoration: InputDecoration(
              hintText: 'Text input field',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.text_fields,
                color: Color.fromARGB(255, 34, 118, 186),
              ),
            ),
          ),
        );

      default:
        return Container();
    }
  }

  Widget _buildUserSelectionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Select User',
          border: OutlineInputBorder(),
        ),
        items: const [
          // Replace this with actual user data

        ],
        onChanged: (value) {
          // Handle user selection
          print('Selected user ID: $value');
        },
      ),
    );
  }
}*/

import 'package:flutter/material.dart';

class DynamicInputField extends StatelessWidget {
  final String questionType;

  const DynamicInputField({
    Key? key,
    required this.questionType,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (questionType) {
      case 'user':
        return _buildUserSelectionField();
      case 'date':
        return Container(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () {}, // Preview only
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today,
                      color: Color.fromARGB(255, 34, 118, 186)),
                  const SizedBox(width: 8),
                  Text(
                    'Select Date (DD/MM/YYYY)',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );

      case 'datetime':
        return Container(
          padding: const EdgeInsets.all(16),
          child: InkWell(
            onTap: () {}, // Preview only
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  const Icon(Icons.access_time,
                      color: Color.fromARGB(255, 34, 118, 186)),
                  const SizedBox(width: 8),
                  Text(
                    'Select Date and Time',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
        );

      case 'text':
        return Container(
          padding: const EdgeInsets.all(16),
          child: TextField(
            enabled: false, // Preview only
            decoration: InputDecoration(
              hintText: 'Text input field',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.text_fields,
                color: Color.fromARGB(255, 34, 118, 186),
              ),
            ),
          ),
        );

      case 'Signature':
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Signature Field',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              SignaturePad(
                backgroundColor: Colors.grey[50]!,
                strokeColor: const Color.fromARGB(255, 34, 118, 186),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      // Add clear signature functionality here
                    },
                    icon: const Icon(Icons.clear),
                    label: const Text('Clear'),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );

      default:
        return Container();
    }
  }

  Widget _buildUserSelectionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Select User',
          border: OutlineInputBorder(),
        ),
        items: const [
          // Replace this with actual user data
        ],
        onChanged: (value) {
          // Handle user selection
          print('Selected user ID: $value');
        },
      ),
    );
  }
}

class SignaturePad extends StatelessWidget {
  final Color backgroundColor;
  final Color strokeColor;

  const SignaturePad({
    Key? key,
    required this.backgroundColor,
    required this.strokeColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: backgroundColor,
        border: Border.all(color: strokeColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Signature pad (not implemented)',
          style: TextStyle(color: Colors.grey[600]),
        ),
      ),
    );
  }
}

