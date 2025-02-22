import 'package:flutter/material.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import 'CreateAnswerDialog.dart';

class AnswerSelectionDialog extends StatefulWidget {
  final Function refreshAnswers;
  final int formQuestionId;
  final String questionText;
  final int formId;
  final int questionId;

  const AnswerSelectionDialog({
    Key? key,
    required this.refreshAnswers,
    required this.formQuestionId,
    required this.questionText,
    required this.formId,
    required this.questionId,
  }) : super(key: key);

  @override
  _AnswerSelectionDialogState createState() => _AnswerSelectionDialogState();
}

class _AnswerSelectionDialogState extends State<AnswerSelectionDialog> {
  final AnswerApiService _answerApiService = AnswerApiService();
  bool isLoading = true;
  List<dynamic> availableAnswers = [];
  Set<int> selectedAnswerIds = {};

  @override
  void initState() {
    super.initState();
    _fetchAnswers();
  }

  Future<void> _fetchAnswers() async {
    try {
      setState(() {
        isLoading = true;
      });

      final answers = await _answerApiService.fetchAnswers(context);

      if (mounted) {
        setState(() {
          availableAnswers = answers;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching answers: $e');
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _assignSelectedAnswers() async {
    try {
      // Iterar sobre cada respuesta seleccionada
      for (int answerId in selectedAnswerIds) {
        await _answerApiService.assignAnswerToQuestion(
          context,
          widget.formQuestionId,
          answerId,
        );
      }

      if (!mounted) return;

      // Mostrar mensaje de éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Answers assigned successfully'),
          duration: Duration(milliseconds: 1500),
        ),
      );

      // Actualizar la lista de preguntas/respuestas
      widget.refreshAnswers();

      // Cerrar el diálogo
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error assigning responses: $e'),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.red,
        ),
      );
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Answers for:\n${widget.questionText}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const CircularProgressIndicator()
            else if (availableAnswers.isEmpty)
              Column(
                children: [
                  const Text('No answers available'),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final result = await showDialog(
                        context: context,
                        builder: (context) => CreateAnswerDialog(
                          refreshAnswers: _fetchAnswers,
                        ),
                      );

                      if (result == true) {
                        await _fetchAnswers();
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Create New Answer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                    ),
                  ),
                ],
              )
            else
              Flexible(
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableAnswers.length,
                        itemBuilder: (context, index) {
                          final answer = availableAnswers[index];
                          return CheckboxListTile(
                            title: Text(answer['value'] ?? ''),
                            value: selectedAnswerIds.contains(answer['id']),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  selectedAnswerIds.add(answer['id']);
                                } else {
                                  selectedAnswerIds.remove(answer['id']);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () async {
                        final result = await showDialog(
                          context: context,
                          builder: (context) => CreateAnswerDialog(
                            refreshAnswers: _fetchAnswers,
                          ),
                        );

                        if (result == true) {
                          await _fetchAnswers();
                        }
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Add More Answers'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 34, 118, 186),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
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
                  onPressed:
                      selectedAnswerIds.isEmpty ? null : _assignSelectedAnswers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                  ),
                  child: const Text(
                    'Assign',
                    style: TextStyle(
                      color: Colors.white, // Cambia el color del texto a blanco
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
