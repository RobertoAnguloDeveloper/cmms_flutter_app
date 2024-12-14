import 'package:flutter/material.dart';

class QuestionCreationCard extends StatelessWidget {
  final TextEditingController questionTextController;
  final int? selectedQuestionTypeId;
  final bool isRequired;
  final bool isLoadingQuestionTypes;
  final List<dynamic> questionTypes;
  final VoidCallback onCancel;
  final ValueChanged<int?> onTypeChanged;
  final ValueChanged<bool> onRequiredChanged;

  const QuestionCreationCard({
    Key? key,
    required this.questionTextController,
    required this.selectedQuestionTypeId,
    required this.isRequired,
    required this.isLoadingQuestionTypes,
    required this.questionTypes,
    required this.onCancel,
    required this.onTypeChanged,
    required this.onRequiredChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      color: Colors.white,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Fila para título y tipo de pregunta
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                // Campo de texto reducido para la pregunta
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: questionTextController,
                    decoration: const InputDecoration(
                      hintText: 'Question title',
                      border: UnderlineInputBorder(),
                      hintStyle: TextStyle(fontSize: 16),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 16),
                // Selector de tipo de pregunta
                Expanded(
                  flex: 1,
                  child: isLoadingQuestionTypes
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : DropdownButtonFormField<int>(
                          value: selectedQuestionTypeId,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            enabledBorder: OutlineInputBorder(
                              //borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Colors.grey),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                          ),
                          dropdownColor: Colors.white,
                          hint: const Text('Type'),
                          items: questionTypes.map((type) {
                            final String questionTypeString =
                                (type['type'] ?? '').toString().toLowerCase();

                            IconData icon;
                            switch (questionTypeString) {
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
                              value: type['id'] as int?,
                              child: Row(
                                children: [
                                  Icon(icon, size: 20, color: Colors.grey[700]),
                                  const SizedBox(width: 8),
                                  Text((type['type'] ?? '').toString()),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: onTypeChanged,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Barra inferior con switch y botón cancelar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Obligatorio
                Row(
                  children: [
                    const Text('Required'),
                    Switch(
                      value: isRequired,
                      onChanged: onRequiredChanged,
                      activeColor: const Color.fromARGB(255, 9, 68, 196),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.delete_outlined,
                      color: Color.fromARGB(255, 110, 110, 110)),
                  iconSize: 32.0,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
