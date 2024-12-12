import 'package:flutter/material.dart';

import '../../../../../components/SnackBarUtil.dart';
import '../../../../../services/api_model_services/EnvironmentApiService.dart';

class RegisterEnvironment extends StatefulWidget {
  const RegisterEnvironment({Key? key}) : super(key: key);

  @override
  _RegisterEnvironmentState createState() => _RegisterEnvironmentState();
}

class _RegisterEnvironmentState extends State<RegisterEnvironment> {
  final TextEditingController controllerName = TextEditingController();
  final TextEditingController controllerDescription = TextEditingController();

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final EnvironmentApiService environmentController = EnvironmentApiService();

  void _saveEnvironment() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> environmentData = {
        "name": controllerName.text,
        "description": controllerDescription.text,
      };

      try {
        await environmentController.registerEnvironment(
          context,
          environmentData,
          (successMessage) {
            SnackBarUtil.showCustomSnackBar(
              context: context,
              message: successMessage,
              duration: const Duration(milliseconds: 500),
            );

            Navigator.of(context).pop(true);
          },
          (errorMessage) {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  title: const Text(
                    'Error',
                    style: TextStyle(fontSize: 22),
                  ),
                  content: Text(
                    errorMessage,
                    style: const TextStyle(fontSize: 18),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'OK',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      } catch (e) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text(
                'Unexpected Error',
                style: TextStyle(fontSize: 22),
              ),
              content: Text(
                'An unexpected error occurred: $e',
                style: const TextStyle(fontSize: 18),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            );
          },
        );
      }
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Please fill out all required fields.')),
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
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        width: 400,
        height: 396,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: controllerName,
                  decoration: InputDecoration(
                    labelText: 'Environment Name',
                    labelStyle: const TextStyle(fontSize: 18),
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 18.0),
                  ),
                  style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the environment name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: controllerDescription,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    labelStyle: const TextStyle(fontSize: 18),
                    border: OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 15.0, horizontal: 18.0),
                  ),
                  maxLines: 3,
                    style: const TextStyle(fontSize: 16),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveEnvironment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 22.0,
                      horizontal: 32.0,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.save),
                      SizedBox(width: 8),
                      Text('Save Environment'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
