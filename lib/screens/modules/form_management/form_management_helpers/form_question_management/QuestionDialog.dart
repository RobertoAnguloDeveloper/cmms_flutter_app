/*import 'package:cmms/services/api_model_services/api_form_services/QuestionApiService.dart';
import 'package:flutter/material.dart';

class QuestionDialog extends StatefulWidget {
  final Function refreshQuestions;

  const QuestionDialog({
    Key? key,
    required this.refreshQuestions,
  }) : super(key: key);

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final TextEditingController _questionTextController = TextEditingController();
  final QuestionApiService _formApiService = QuestionApiService();
  int? selectedQuestionTypeId;
  List<dynamic> questionTypes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestionTypes();
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        padding: const EdgeInsets.all(20.0), // Increased padding
        width: 350, // Slightly larger width
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Add Question',
              style: TextStyle(
                fontSize: 22, // Larger text size
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20), // Increased spacing
            TextField(
              controller: _questionTextController,
              decoration: const InputDecoration(
                labelText: 'Question Text',
                border: OutlineInputBorder(),
              ),
              style: const TextStyle(fontSize: 16), // Larger text size
              maxLines: 2,
            ),
            const SizedBox(height: 20), // Increased spacing
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
                    child: Text(
                      type['type'],
                      style: const TextStyle(fontSize: 16), // Larger text size
                    ),
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
                  child: const Text(
                    'Cancel',
                    style: TextStyle(fontSize: 16), // Larger button text
                  ),
                ),
                const SizedBox(width: 12), // Increased spacing
                ElevatedButton.icon(
                  onPressed: selectedQuestionTypeId == null
                      ? null
                      : () => _createQuestion(context),
                  icon: const Icon(Icons.save,
                      color: Colors.white, size: 20), // Larger icon
                  label: const Text(
                    'Create',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16), // Larger text
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 20,
                    ), // Increased padding
                    backgroundColor: const Color(0xFF2276BA),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createQuestion(BuildContext context) async {
    if (_questionTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
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

      await _formApiService.createQuestion(context, questionData);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question created successfully'),
            duration: Duration(milliseconds: 500),
          ),
        );
        widget.refreshQuestions();
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating question: $e'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }
}
*/


import 'package:flutter/material.dart';

import '../../../../../services/api_model_services/api_form_services/QuestionApiService.dart';

class QuestionDialog extends StatefulWidget {
  final Function refreshQuestions;

  const QuestionDialog({
    Key? key,
    required this.refreshQuestions,
  }) : super(key: key);

  @override
  _QuestionDialogState createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  final TextEditingController _questionTextController = TextEditingController();
  final QuestionApiService _formApiService = QuestionApiService();
  int? selectedQuestionTypeId;
  List<dynamic> questionTypes = [];
  bool isLoading = true;
  bool isRequired = false;

  @override
  void initState() {
    super.initState();
    _fetchQuestionTypes();
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Card container for question .... IMPORTANTE para generar metodo de generacion
            Card(
              elevation: 1,
              margin: EdgeInsets.zero,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question input field
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextField(
                      controller: _questionTextController,
                      decoration: const InputDecoration(
                        hintText: 'Pregunta sin título',
                        border: UnderlineInputBorder(),
                        hintStyle: TextStyle(fontSize: 16),
                      ),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  // Question type selector
                  if (!isLoading)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: DropdownButtonFormField<int>(
                        value: selectedQuestionTypeId,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        hint: const Text('Seleccionar tipo de pregunta'),
                        items: questionTypes.map((type) {
                          IconData icon;
                          switch(type['type'].toString().toLowerCase()) {
                            case 'multiple_choices':
                              icon = Icons.radio_button_checked;
                              break;
                            case 'checkbox':
                              icon = Icons.check_box;
                              break;
                            case 'date':
                              icon = Icons.calendar_today;
                              break;
                            case 'datetime':
                              icon = Icons.access_time;
                              break;
                            case 'text':
                              icon = Icons.short_text;
                              break;
                            case 'user':
                              icon = Icons.person;
                              break;
                            case 'signature':
                              icon = Icons.draw;
                              break;
                            default:
                              icon = Icons.question_answer;
                          }
                          
                          return DropdownMenuItem<int>(
                            value: type['id'],
                            child: Row(
                              children: [
                                Icon(icon, size: 20, color: Colors.grey[700]),
                                const SizedBox(width: 8),
                                Text(type['type']),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedQuestionTypeId = value;
                          });
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
            
            // Bottom actions
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(8)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Required toggle
                  Row(
                    children: [
                      const Text('Obligatorio'),
                      Switch(
                        value: isRequired,
                        onChanged: (value) {
                          setState(() {
                            isRequired = value;
                          });
                        },
                        activeColor: const Color(0xFF673AB7),
                      ),
                    ],
                  ),
                  // Action buttons
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: selectedQuestionTypeId == null ? null : _createQuestion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF673AB7),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Crear'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

    // Llamar metodo directamente para recibir la card 
  Future<void> _createQuestion() async {
    if (_questionTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese el texto de la pregunta'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final questionData = {
        'text': _questionTextController.text,
        'question_type_id': selectedQuestionTypeId,
        'is_required': isRequired,
      };

      await _formApiService.createQuestion(context, questionData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pregunta creada exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );
      
      widget.refreshQuestions();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creando la pregunta: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }


Future<void> _createDefaultQuestion() async {
    if (_questionTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese el texto de la pregunta'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final questionData = {
        'text': _questionTextController.text,
        'question_type_id': selectedQuestionTypeId,
        'is_required': isRequired,
      };

      await _formApiService.createQuestion(context, questionData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pregunta creada exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );
      
      widget.refreshQuestions();
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creando la pregunta: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }



  @override
  void dispose() {
    _questionTextController.dispose();
    super.dispose();
  }
}