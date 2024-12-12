import 'package:flutter/material.dart';

import '../../../../../services/api_model_services/api_form_services/QuestionApiService.dart';

class QuestionSelectionDialog extends StatefulWidget {
  final Function refreshQuestions;
  final int formId;

  const QuestionSelectionDialog({
    Key? key,
    required this.refreshQuestions,
    required this.formId,
  }) : super(key: key);

  @override
  _QuestionSelectionDialogState createState() =>
      _QuestionSelectionDialogState();
}

class _QuestionSelectionDialogState extends State<QuestionSelectionDialog> {
  final QuestionApiService _formApiService = QuestionApiService();
  bool isLoading = true;
  List<dynamic> availableQuestions = [];
  List<dynamic> filteredQuestions = [];
  Set<int> selectedQuestionIds = {};
  String searchQuery = '';
  String? selectedQuestionType; // Tipo de pregunta seleccionado
  List<String> questionTypes = []; // Tipos de preguntas disponibles

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      final questions = await _formApiService.fetchQuestions(context);
      setState(() {
        availableQuestions = questions;
        filteredQuestions = questions;
        questionTypes = questions
            .map((q) => q['question_type']['type'] as String)
            .toSet()
            .toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching questions: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _filterQuestions() {
    setState(() {
      filteredQuestions = availableQuestions.where((question) {
        final matchesQuery = question['text']
            .toString()
            .toLowerCase()
            .contains(searchQuery.toLowerCase());
        final matchesType = selectedQuestionType == null ||
            question['question_type']['type'] == selectedQuestionType;
        return matchesQuery && matchesType;
      }).toList();
    });
  }

  Future<void> _assignSelectedQuestions() async {
    try {
      int startOrder = 1;

      for (int questionId in selectedQuestionIds) {
        await _formApiService.assignQuestionToForm(
          context,
          widget.formId,
          questionId,
          startOrder++,
        );
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Preguntas asignadas exitosamente'),
            duration: const Duration(milliseconds: 500),
          ),
        );

        widget.refreshQuestions();
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al asignar preguntas: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
          maxWidth: MediaQuery.of(context).size.width * 0.9,
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Questions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Search question',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                prefixIcon: const Icon(Icons.search),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(
                    color: const Color.fromARGB(255, 34, 118, 186), // Azul
                    width: 2.0,
                  ),
                ),
              ),
              onChanged: (query) {
                searchQuery = query;
                _filterQuestions();
              },
            ),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: selectedQuestionType,
              hint: const Text('Filter by question type'),
              isExpanded: true,
              items: questionTypes
                  .map((type) => DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedQuestionType = value;
                  _filterQuestions();
                });
              },
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (filteredQuestions.isEmpty)
              const Center(
                child: Text('There are no questions available'),
              )
            else
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: filteredQuestions.map((question) {
                      final questionId = question['id'] as int;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: CheckboxListTile(
                          title: Text(question['text']),
                          subtitle: Text(
                            'Tipo: ${question['question_type']['type']}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          activeColor:
                              const Color.fromARGB(255, 34, 118, 186), // Azul
                          value: selectedQuestionIds.contains(questionId),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedQuestionIds.add(questionId);
                              } else {
                                selectedQuestionIds.remove(questionId);
                              }
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: selectedQuestionIds.isEmpty
                      ? null
                      : () => _assignSelectedQuestions(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0, // Altura del botón
                      horizontal: 32.0, // Ancho del botón
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(20), // Bordes redondeados
                    ),
                  ),
                  child: const Text(
                    'Assign',
                    style: TextStyle(
                      color: Colors.white, // Texto blanco
                      fontSize: 16.0, // Tamaño del texto
                      fontWeight:
                          FontWeight.bold, // Negrita para mejor visibilidad
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
