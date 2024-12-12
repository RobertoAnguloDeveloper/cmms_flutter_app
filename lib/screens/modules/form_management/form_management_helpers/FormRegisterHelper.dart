import 'package:flutter/material.dart';

import '../../../../components/SnackBarUtil.dart';
import '../../../../services/api_model_services/api_form_services/FormApiService.dart';

class FormRegisterHelper {
  static void showFormDialog(BuildContext context, Function refreshForms) {
    final TextEditingController titleController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    final FormApiService formApiService = FormApiService();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10,
          child: Container(
            padding: const EdgeInsets.all(16.0),
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Create New Form',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12.0,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 12.0,
                          ),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            final formData = {
                              'title': titleController.text,
                              'description': descriptionController.text,
                            };

                            await formApiService.RegisterForm(
                                context, formData);

                            if (context.mounted) {
                              SnackBarUtil.showCustomSnackBar(
                                context: context,
                                message: 'Form created successfully',
                                duration: const Duration(milliseconds: 500),
                              );

                              Navigator.pop(context);
                              refreshForms();
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error creating form: $e'),
                                  duration: const Duration(milliseconds: 500),
                                ),
                              );
                            }
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color.fromARGB(255, 34, 118, 186),
                      ),
                      child: const Text(
                        'Create',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
