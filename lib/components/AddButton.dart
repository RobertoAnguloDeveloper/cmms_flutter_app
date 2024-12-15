import 'package:flutter/material.dart';

class AddButton extends StatelessWidget {
  final VoidCallback onPressed;

  const AddButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70.0, // BUTTON SIZE
      height: 70.0, // BUTTON SIZE
      child: FloatingActionButton(
        onPressed: onPressed,
        child: const Icon(Icons.add, size: 44, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 34, 118, 186),
        shape: const CircleBorder(),
        elevation: 6,
        tooltip: 'Add',
      ),
    );
  }
}
