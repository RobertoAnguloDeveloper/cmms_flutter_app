/*import 'package:flutter/material.dart';

class ExportFormDialog extends StatefulWidget {
  final Function(int) onExport;

  const ExportFormDialog({Key? key, required this.onExport}) : super(key: key);

  @override
  _ExportFormDialogState createState() => _ExportFormDialogState();
}

class _ExportFormDialogState extends State<ExportFormDialog> {
  int _signatureCount = 1; // Valor inicial por defecto

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Form as PDF'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How many signatures do you want to include?'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _signatureCount > 1
                    ? () {
                        setState(() {
                          _signatureCount--;
                        });
                      }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                _signatureCount.toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _signatureCount++;
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onExport(_signatureCount);
            Navigator.pop(context);
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}
*/

import 'package:flutter/material.dart';

class ExportFormDialog extends StatefulWidget {
  final Function(int) onExport;

  const ExportFormDialog({Key? key, required this.onExport}) : super(key: key);

  @override
  _ExportFormDialogState createState() => _ExportFormDialogState();
}

class _ExportFormDialogState extends State<ExportFormDialog> {
  int _signatureCount = 1; // Valor inicial por defecto

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Export Form as PDF'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('How many signatures do you want to include?'),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: _signatureCount > 1
                    ? () {
                  setState(() {
                    _signatureCount--;
                  });
                }
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
              Text(
                _signatureCount.toString(),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _signatureCount++;
                  });
                },
                icon: const Icon(Icons.add_circle_outline),
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onExport(_signatureCount);
            Navigator.pop(context);
          },
          child: const Text('Export'),
        ),
      ],
    );
  }
}
