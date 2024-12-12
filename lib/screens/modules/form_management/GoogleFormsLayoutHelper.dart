import 'package:flutter/material.dart';

import '../../../components/SnackBarUtil.dart';
import '../../../services/api_model_services/api_form_services/FormApiService.dart';

class GoogleFormsLayoutHelper extends StatefulWidget {
  final Function refreshForms;
  final Map<String, dynamic>? initialForm;

  const GoogleFormsLayoutHelper({
    Key? key,
    required this.refreshForms,
    this.initialForm,
  }) : super(key: key);

  @override
  _GoogleFormsLayoutHelperState createState() => _GoogleFormsLayoutHelperState();
}

class _GoogleFormsLayoutHelperState extends State<GoogleFormsLayoutHelper> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final FormApiService formApiService = FormApiService();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isPublic = false;
  
  @override
  void initState() {
    super.initState();
    if (widget.initialForm != null) {
      titleController.text = widget.initialForm!['title'] ?? '';
      descriptionController.text = widget.initialForm!['description'] ?? '';
      isPublic = widget.initialForm!['is_public'] ?? false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBF8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Card
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: Color(0xFF673AB7),
                        width: 8.0,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: titleController,
                            decoration: const InputDecoration(
                              hintText: 'Formulario sin título',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w400,
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a title';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: descriptionController,
                            decoration: const InputDecoration(
                              hintText: 'Descripción del formulario',
                              border: InputBorder.none,
                              hintStyle: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
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
                  ),
                ),
              ),
            ),
            
            // Action Buttons
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      
      // Side Menu
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FloatingActionButton(
            heroTag: 'add_question',
            onPressed: () {
              // Add Question Logic
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_title',
            onPressed: () {
              // Add Title Logic
            },
            child: const Icon(Icons.title),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'add_image',
            onPressed: () {
              // Add Image Logic
            },
            child: const Icon(Icons.image),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Future<void> _handleSave() async {
    if (formKey.currentState!.validate()) {
      try {
        final formData = {
          'title': titleController.text,
          'description': descriptionController.text,
          'is_public': isPublic,
        };

        if (widget.initialForm != null) {
          await formApiService.updateForm(
            context,
            widget.initialForm!['id'],
            formData,
          );
        } else {
          await formApiService.RegisterForm(context, formData);
        }

        if (!mounted) return;

        SnackBarUtil.showCustomSnackBar(
          context: context,
          message: widget.initialForm != null
              ? 'Form updated successfully'
              : 'Form created successfully',
          duration: const Duration(milliseconds: 500),
        );

        widget.refreshForms();
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        SnackBarUtil.showCustomSnackBar(
          context: context,
          message: 'Error: $e',
          duration: const Duration(milliseconds: 1500),
        );
      }
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }
}