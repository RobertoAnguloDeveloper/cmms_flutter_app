import 'package:flutter/material.dart';

class DraftsScreen extends StatelessWidget {
  const DraftsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Drafts"),
      ),
      body: Container(
        // Fondo claro, similar a tu pantalla principal
        color: const Color.fromARGB(255, 211, 234, 248),
        padding: const EdgeInsets.all(16.0),
        child: Card(
          // Tarjeta con un color suave de fondo
          color: const Color.fromARGB(255, 237, 231, 253),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: const Text(
              "The form has been saved.",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: const Text(
              "A draft or reference of the completed form is displayed.",
            ),
            trailing: const Icon(Icons.check_circle_outline, color: Colors.green),
          ),
        ),
      ),
    );
  }
}
