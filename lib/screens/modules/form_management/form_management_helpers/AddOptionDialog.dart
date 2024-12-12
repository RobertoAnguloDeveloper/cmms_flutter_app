import 'package:flutter/material.dart';

class AddOptionsDialog extends StatelessWidget {
  final VoidCallback onAddQuestion;
  final VoidCallback onSelectQuestions;

  const AddOptionsDialog({
    Key? key,
    required this.onAddQuestion,
    required this.onSelectQuestions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Bordes más grandes
      ),
      backgroundColor: Colors.white, // Fondo blanco
      child: Padding(
        padding: const EdgeInsets.all(32), // Espacio dentro del diálogo
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Question Options',
              style: TextStyle(
                fontSize: 28, // Texto más grande
                fontWeight: FontWeight.bold, // Más prominente
                color: Colors.black, // Color del texto
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32), // Espacio debajo del título
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100], // Fondo del cuadro
                borderRadius: BorderRadius.circular(16), // Bordes redondeados
                border: Border.all(
                  color: Colors.grey[300]!, // Borde del cuadro
                  width: 2,
                ),
              ),
              padding: const EdgeInsets.all(16), // Espacio dentro del cuadro
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onAddQuestion();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // Bordes más grandes
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20, // Botones más altos
                        horizontal: 16, // Más ancho
                      ),
                    ),
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white,
                      size: 36, // Íconos más grandes
                    ),
                    label: const Text(
                      'Create Question',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20, // Texto más grande
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24), // Espacio entre botones
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onSelectQuestions();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16), // Bordes más grandes
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 20, // Botones más altos
                        horizontal: 16, // Más ancho
                      ),
                    ),
                    icon: const Icon(
                      Icons.playlist_add_check,
                      color: Colors.white,
                      size: 36, // Íconos más grandes
                    ),
                    label: const Text(
                      'Assign Question',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20, // Texto más grande
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
