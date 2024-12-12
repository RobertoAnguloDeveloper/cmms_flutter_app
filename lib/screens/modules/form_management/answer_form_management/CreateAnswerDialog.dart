import 'package:flutter/material.dart';

import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';

class CreateAnswerDialog extends StatefulWidget {
  final Function refreshAnswers;

  const CreateAnswerDialog({
    Key? key,
    required this.refreshAnswers,
  }) : super(key: key);

  @override
  _CreateAnswerDialogState createState() => _CreateAnswerDialogState();
}

class _CreateAnswerDialogState extends State<CreateAnswerDialog> {
  final List<TextEditingController> _answerControllers = [];
  final AnswerApiService _answerApiService = AnswerApiService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Iniciar con un campo de respuesta
    _addNewAnswerField();
  }

  @override
  void dispose() {
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addNewAnswerField() {
    setState(() {
      _answerControllers.add(TextEditingController());
    });
  }

  void _removeAnswerField(int index) {
    setState(() {
      _answerControllers[index].dispose();
      _answerControllers.removeAt(index);
    });
  }

  Future<void> _createAnswers() async {
    // Filtrar campos vacíos
    final nonEmptyAnswers = _answerControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();

    if (nonEmptyAnswers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingrese al menos una respuesta')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Crear cada respuesta
      for (String answerText in nonEmptyAnswers) {
        final answerData = {
          'value': answerText,
        };

        await _answerApiService.createAnswer(context, answerData);
      }

      if (!mounted) return;

      widget.refreshAnswers();
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('${nonEmptyAnswers.length} Answers created successfully')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating answers: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
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
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Create Answers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: _answerControllers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _answerControllers[index],
                            decoration: InputDecoration(
                              labelText: 'Answer ${index + 1}',
                              border: const OutlineInputBorder(),
                              hintText: 'Enter the answer',
                            ),
                          ),
                        ),
                        if (_answerControllers.length > 1)
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline,
                                color: Colors.red),
                            onPressed: () => _removeAnswerField(index),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _addNewAnswerField,
              icon: const Icon(Icons.add),
              label: const Text('Add another answer'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : _createAnswers,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Answers',
                          style: TextStyle(
                            color: Colors
                                .white, // Establece el color del texto en blanco
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
