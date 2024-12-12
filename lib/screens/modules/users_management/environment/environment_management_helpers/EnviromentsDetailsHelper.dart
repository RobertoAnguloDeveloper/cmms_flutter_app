import 'package:flutter/material.dart';

import '../../../../../components/SnackBarUtil.dart';
import '../../../../../services/api_model_services/EnvironmentApiService.dart';

class EnvironmentDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> environment;

  const EnvironmentDetailsScreen({Key? key, required this.environment})
      : super(key: key);

  @override
  _EnvironmentDetailsScreenState createState() =>
      _EnvironmentDetailsScreenState();
}

class _EnvironmentDetailsScreenState extends State<EnvironmentDetailsScreen> {
  late TextEditingController controllerName;
  late TextEditingController controllerDescription;
  String? nameErrorText;
  String? descriptionErrorText;
  final EnvironmentApiService environmentController = EnvironmentApiService();

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text: widget.environment['name']);
    controllerDescription =
        TextEditingController(text: widget.environment['description']);
  }

  void _updateEnvironment() async {
    final name = controllerName.text.trim();
    final description = controllerDescription.text.trim();

    setState(() {
      nameErrorText = name.isEmpty ? 'Environment name cannot be empty' : null;
      descriptionErrorText =
          description.isEmpty ? 'Description cannot be empty' : null;
    });

    if (name.isEmpty || description.isEmpty) {
      return;
    }

    Map<String, dynamic> updatedData = {
      "name": controllerName.text,
      "description": controllerDescription.text,
    };

    try {
      final response = await environmentController.updateEnvironment(
        context,
        widget.environment['id'],
        updatedData,
      );

      if (response['status'] == 200) {
        SnackBarUtil.showCustomSnackBar(
          context: context,
          message: 'Environment updated successfully',
          duration: const Duration(milliseconds: 500),
        );

        Navigator.of(context).pop();
      } else if (response['status'] == 400 && response.containsKey('error')) {
        if (response['error'] ==
            'An environment with this name already exists') {
          setState(() {
            nameErrorText = 'An environment with this name already exists';
          });
        } else {
          // SnackBarUtil.showCustomSnackBar(
          //   context: context,
          //   message: 'Error: ${response['message']}',
          //   duration: const Duration(milliseconds: 1500),
          // );
        }
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error: ${response['message']}')),
        // );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
    }
  }

  void _deleteEnvironment() async {
    try {
      final response = await environmentController.deleteEnvironment(
        context,
        widget.environment['id'],
      );

      if (response['status'] == 200 || response['status'] == 204) {
        SnackBarUtil.showCustomSnackBar(
          context: context,
          message: 'Environment deleted successfully',
          duration: const Duration(milliseconds: 500),
        );

        Navigator.of(context).pop();
      } else {
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error deleting environment: ${response['message']}')),
        // );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('Error: $e')),
      // );
    }
  }

  @override
  void dispose() {
    controllerName.dispose();
    controllerDescription.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        width: 400,
        height: 380,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: controllerName,
                decoration: InputDecoration(
                  labelText: 'Environment Name',
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 18.0),
                  errorText: nameErrorText,
                ),
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  if (nameErrorText != null) {
                    setState(() {
                      nameErrorText = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: controllerDescription,
                decoration: InputDecoration(
                  labelText: 'Description',
                  labelStyle: TextStyle(fontSize: 18),
                  border: OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 18.0),
                  errorText: descriptionErrorText,
                ),
                maxLines: 3,
                style: const TextStyle(fontSize: 16),
                onChanged: (value) {
                  if (descriptionErrorText != null) {
                    setState(() {
                      descriptionErrorText = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _confirmDeleteEnvironment(context, widget.environment);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.delete, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Delete',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _updateEnvironment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                      padding: const EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 30.0),
                      textStyle: const TextStyle(fontSize: 18),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.save, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text('Save',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDeleteEnvironment(
      BuildContext outerContext, Map<String, dynamic> environment) {
    final environmentName = environment['name'] ?? 'Entorno';

    showDialog(
      context: outerContext,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm deletion'),
          content: Text(
              'Are you sure you want to delete the environment? "$environmentName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteEnvironment();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
