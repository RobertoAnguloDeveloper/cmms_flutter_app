import 'package:flutter/material.dart';

import '../../../../services/api_model_services/api_form_services/FormApiService.dart';

class FormUpdateDialog extends StatefulWidget {
  final Map<String, dynamic> form;
  final Function refreshForms;

  const FormUpdateDialog({
    Key? key,
    required this.form,
    required this.refreshForms,
  }) : super(key: key);

  @override
  _FormUpdateDialogState createState() => _FormUpdateDialogState();
}

class _FormUpdateDialogState extends State<FormUpdateDialog> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FormApiService formApiService = FormApiService();
  bool isPublic = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    titleController.text = widget.form['title'] ?? '';
    descriptionController.text = widget.form['description'] ?? '';
    isPublic = widget.form['is_public'] ?? false;
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final scaffoldContext = Navigator.of(context).context;
    ScaffoldMessenger.of(scaffoldContext).hideCurrentSnackBar();

    ScaffoldMessenger.of(scaffoldContext).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  Future<void> _handleUpdate() async {
    if (!formKey.currentState!.validate()) return;

    try {
      final formData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'is_public': isPublic,
      };

      await formApiService.updateForm(
        context,
        widget.form['id'],
        formData,
      );

      if (!mounted) return;

      _showMessage('Form updated successfully');
      Navigator.pop(context);
      widget.refreshForms();
    } catch (e) {
      if (!mounted) return;
      _showMessage('Error updating form: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      elevation: 10,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Update Form',
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
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      title: const Text('Public Form'),
                      value: isPublic,
                      onChanged: (bool? value) {
                        setState(() {
                          isPublic = value ?? false;
                        });
                      },
                      activeColor: Color.fromARGB(
                          255, 34, 118, 186), // Cambia el color activo a azul
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
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _handleUpdate,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                    ),
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.white),
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
}
