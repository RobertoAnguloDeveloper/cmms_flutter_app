import 'package:flutter/material.dart';

import '../../../../../services/api_model_services/api_form_services/QuestionApiService.dart';

class QuestionEditDialog extends StatefulWidget {
  final Map<String, dynamic> question;
  final Function refreshQuestions;

  const QuestionEditDialog({
    Key? key,
    required this.question,
    required this.refreshQuestions,
  }) : super(key: key);

  @override
  _QuestionEditDialogState createState() => _QuestionEditDialogState();
}

class _QuestionEditDialogState extends State<QuestionEditDialog> {
  final TextEditingController _questionTextController = TextEditingController();
  final QuestionApiService _formApiService = QuestionApiService();
  int? selectedQuestionTypeId;
  List<dynamic> questionTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _questionTextController.text = widget.question['text'] ?? '';
    selectedQuestionTypeId = widget.question['question_type']['id'];
    _fetchQuestionTypes();
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestionTypes() async {
    try {
      final types = await _formApiService.fetchQuestionTypes(context);
      setState(() {
        questionTypes = types;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching question types: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _updateQuestion(BuildContext context) async {
    if (_questionTextController.text.isEmpty) {
      final scaffoldContext = ScaffoldMessenger.of(context);
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text('Please enter question text'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final questionData = {
        'text': _questionTextController.text,
        'question_type_id': selectedQuestionTypeId,
      };

      await _formApiService.updateQuestion(
        context,
        widget.question['id'],
        questionData,
      );
      
      if (!mounted) return;

      final scaffoldContext = ScaffoldMessenger.of(context);
      scaffoldContext.showSnackBar(
        const SnackBar(
          content: Text('Question updated successfully'),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      widget.refreshQuestions();
      
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      final scaffoldContext = ScaffoldMessenger.of(context);
      scaffoldContext.showSnackBar(
        SnackBar(
          content: Text('Error updating question: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Question',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _questionTextController,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const CircularProgressIndicator()
            else
              DropdownButtonFormField<int>(
                value: selectedQuestionTypeId,
                decoration: const InputDecoration(
                  labelText: 'Question Type',
                  border: OutlineInputBorder(),
                ),
                items: questionTypes.map((type) {
                  return DropdownMenuItem<int>(
                    value: type['id'],
                    child: Text(type['type']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedQuestionTypeId = value;
                  });
                },
              ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _updateQuestion(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                  ),
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}