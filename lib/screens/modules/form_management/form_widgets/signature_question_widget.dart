// lib/screens/modules/form_management/form_widgets/signature_question_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../widgets/signature_pad.dart';

class SignatureQuestionWidget extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function(int questionId, File file) onSignatureCaptured;
  final String? initialSignaturePath;

  const SignatureQuestionWidget({
    Key? key,
    required this.question,
    required this.onSignatureCaptured,
    this.initialSignaturePath,
  }) : super(key: key);

  @override
  SignatureQuestionWidgetState createState() => SignatureQuestionWidgetState();
}

class SignatureQuestionWidgetState extends State<SignatureQuestionWidget> {
  File? _capturedSignatureFile;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 219, 244, 255),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question['text'] ?? 'Please sign below',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 16),
            SignaturePad(
              initialSignaturePath: widget.initialSignaturePath,
              onSignatureCaptured: (file) {
                setState(() {
                  _capturedSignatureFile = file;
                });
                if (file != null) {
                  widget.onSignatureCaptured(widget.question['id'], file);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}