import 'package:flutter/material.dart';

class ApiTestButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;

  const ApiTestButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(title),
      ),
    );
  }
}