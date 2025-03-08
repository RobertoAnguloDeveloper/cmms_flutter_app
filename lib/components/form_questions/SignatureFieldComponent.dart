import 'package:flutter/material.dart';

class SignatureFieldComponent extends StatelessWidget {
  final TextEditingController textController;
  final Function(String) onChanged;
  final String label;
  final String? initialValue;

  const SignatureFieldComponent({
    Key? key,
    required this.textController,
    required this.onChanged,
    this.label = 'Position of the person signing',
    this.initialValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: textController,
          decoration: InputDecoration(
            hintText: 'Enter the position of the signer',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          onChanged: onChanged,
          initialValue: initialValue,
        ),
        const SizedBox(height: 16),
        const Text(
          'This field will appear below the signature and will be stored with the signed document.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 12,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }
}