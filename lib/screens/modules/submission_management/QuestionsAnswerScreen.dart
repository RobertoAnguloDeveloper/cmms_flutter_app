import 'package:cmms_app/components/drawer_menu/DrawerMenu.dart';
import 'package:cmms_app/models/Permission_set.dart';
import 'package:flutter/material.dart';
import '../../../services/api_model_services/api_form_services/AnswerApiService.dart';

class QuestionsAnswerScreen extends StatefulWidget {
  final int formId; // ID del formulario
  final String formTitle; // Título del formulario
  final String? formDescription; // Descripción del formulario
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const QuestionsAnswerScreen({
    Key? key,
    required this.formId,
    required this.formTitle,
    this.formDescription,
       required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _QuestionsAnswerScreenState createState() => _QuestionsAnswerScreenState();
}

class _QuestionsAnswerScreenState extends State<QuestionsAnswerScreen> {
  final AnswerApiService _answerApiService = AnswerApiService();
  bool isLoading = true;
  List<dynamic> questions = [];
  Map<int, dynamic> answers = {}; // Mapa para almacenar las respuestas ingresadas

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      setState(() {
        isLoading = true;
      });

      final formData = await _answerApiService.getFormWithQuestions(
        context,
        widget.formId,
      );

      setState(() {
        questions = formData['questions'] ?? [];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    }
  }

  void _submitAnswers() async {
    try {
      // Validar respuestas antes de enviar
      for (var question in questions) {
        if (question['is_required'] && !answers.containsKey(question['id'])) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Please answer the question: ${question['text']}'),
            ),
          );
          return;
        }
      }

      // Simular el envío de respuestas
      for (var entry in answers.entries) {
        print('Question ID: ${entry.key}, Answer: ${entry.value}');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answers submitted successfully')),
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting answers: $e')),
      );
    }
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
    final possibleAnswers = question['possible_answers'] as List? ?? [];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...possibleAnswers.map((answer) {
              final isSelected = answers[question['id']] == answer['id'];
              return CheckboxListTile(
                title: Text(answer['value']),
                value: isSelected,
                onChanged: (bool? selected) {
                  setState(() {
                    if (selected == true) {
                      answers[question['id']] = answer['id'];
                    } else {
                      answers.remove(question['id']);
                    }
                  });
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextQuestion(Map<String, dynamic> question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Enter your answer',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  answers[question['id']] = value.trim();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      /*appBar: AppBar(
        title: Text(widget.formTitle),
        backgroundColor: Colors.blue,
      ),*/

         appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      drawer: DrawerMenu(
        onItemTapped: (index) {
          Navigator.pop(context);
        },
        parentContext: context,
        permissionSet: widget.permissionSet,
        sessionData: widget.sessionData,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (widget.formDescription != null)
                  Text(
                    widget.formDescription!,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                const SizedBox(height: 16),
                ...questions.map((question) => _buildQuestionField(question)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _submitAnswers,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blue,
                  ),
                  child: const Text(
                    'Submit Answers',
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
    );
  }
}