import 'package:flutter/material.dart';

class FormAnswerDialog extends StatefulWidget {
  final Map<String, dynamic> form;

  const FormAnswerDialog({
    Key? key,
    required this.form,
  }) : super(key: key);

  @override
  _FormAnswerDialogState createState() => _FormAnswerDialogState();
}

class _FormAnswerDialogState extends State<FormAnswerDialog> {
  Map<int, dynamic> answers = {};

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Answer form',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.form['title'],
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      widget.form['description'] ?? 'No description',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const Divider(),
                    _buildQuestionFields(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: const Size(180, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.send, color: Colors.white, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionFields() {
    final questions = widget.form['questions'] as List? ?? [];
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ListView.builder(
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          return _buildQuestionField(question);
        },
      ),
    );
  }

  Widget _buildQuestionField(Map<String, dynamic> question) {
    switch (question['type']) {
      case 'checkbox':
        return _buildCheckboxQuestion(question);
      default:
        return _buildTextQuestion(question);
    }
  }

  Widget _buildCheckboxQuestion(Map<String, dynamic> question) {
    final answers = question['possible_answers'] as List? ?? [];
    return Card(
      color: Color.fromARGB(255, 219, 244, 255),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            ...answers.map((answer) => CheckboxListTile(
                  title: Text(
                    answer['value'],
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  value: this.answers[question['id']] == answer['id'],
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        this.answers[question['id']] = answer['id'];
                      } else {
                        this.answers.remove(question['id']);
                      }
                    });
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildTextQuestion(Map<String, dynamic> question) {
    return Card(
      color: Color.fromARGB(255, 219, 244, 255),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter your answer',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20)),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                answers[question['id']] = value;
              },
            ),
          ],
        ),
      ),
    );
  }
}
