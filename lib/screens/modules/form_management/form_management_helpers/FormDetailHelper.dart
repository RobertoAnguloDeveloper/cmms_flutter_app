/*import 'package:flutter/material.dart';

import '../../../../services/api_model_services/UserApiService.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../../../services/api_model_services/api_form_services/QuestionApiService.dart';
import 'FormUpdateDialog.dart';
import 'form_detail_helper/QuestionsListWidget.dart';
import 'form_dialogs/ExportFormDialog.dart';
import 'form_dialogs/FormDialogs.dart';
import 'form_question_management/QuestionDialog.dart';
import 'form_question_management/QuestionSelectionDialog.dart';

class FormDetailHelper extends StatefulWidget {
  final Map<String, dynamic> form;
  final VoidCallback? onFormDeleted;

  const FormDetailHelper({
    Key? key,
    required this.form,
    this.onFormDeleted,
  }) : super(key: key);

  @override
  _FormDetailScreenState createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends State<FormDetailHelper> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, dynamic>? formDetails;

  @override
  void initState() {
    super.initState();
    _fetchFormDetails();
  }

  Future<void> _fetchFormDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final details =
          await _formApiService.fetchFormById(context, widget.form['id']);
      if (mounted) {
        setState(() {
          formDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching form details: $e');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final scaffoldContext = ScaffoldMessenger.of(context);
    scaffoldContext.hideCurrentSnackBar();

    scaffoldContext.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() async {
    final confirm = await FormDialogs.showDeleteConfirmationDialog(context);
    if (confirm == true) {
      _deleteForm();
    }
  }

  Future<void> _deleteForm() async {
    setState(() {
      isDeleting = true;
    });

    try {
      await _formApiService.softDeleteForm(
        context,
        widget.form['id'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form deleted'),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      widget.onFormDeleted?.call();

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting form: $e'),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFormQuestion(
      BuildContext context, int formQuestionId) async {
    try {
      final bool? shouldDelete =
          await FormDialogs.showDeleteQuestionDialog(context);

      if (shouldDelete != true) return;

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final questionApiService = QuestionApiService();
      final result = await questionApiService.deleteQuestionFromForm(
        context,
        formQuestionId,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result['status'] == 200 || result['status'] == 204) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Pregunta eliminada exitosamente'),
            duration: const Duration(milliseconds: 1500),
          ),
        );

        await _fetchFormDetails();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al eliminar la pregunta'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Future<void> _deleteAnswer(int formAnswerId) async {
    try {
      final bool? confirm = await FormDialogs.showDeleteAnswerDialog(context);

      if (confirm != true) return;

      final answerApiService = AnswerApiService();
      await answerApiService.deleteAnswerFromQuestion(
        context,
        formAnswerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Respuesta eliminada exitosamente'),
          duration: const Duration(milliseconds: 500),
        ),
      );

      await _fetchFormDetails();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la respuesta: $e'),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditAnswerDialog(String currentValue, dynamic answerData) {
    FormDialogs.showEditAnswerDialog(
      context: context,
      currentValue: currentValue,
      onSave: (updatedValue) async {
        try {
          await _answerApiService.updateAnswer(
            context,
            {
              'value': updatedValue,
              'remarks': answerData['remarks'] ?? null,
            },
            answerData['answer']['id'],
          );
          await _fetchFormDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Respuesta actualizada exitosamente'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar la respuesta: $e'),
              duration: const Duration(milliseconds: 1500),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildUserSelectionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<dynamic>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error loading users: ${snapshot.error}');
          }

          final users = snapshot.data ?? [];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 34, 118, 186),
                  ),
                ),
                hint: Text(
                  'Select User',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                items: users.map<DropdownMenuItem<int>>((user) {
                  return DropdownMenuItem<int>(
                    value: user['id'],
                    child: Text('${user['first_name']} ${user['last_name']}'),
                  );
                }).toList(),
                onChanged: (value) {
                  print('Selected user ID: $value');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchUsers() async {
    try {
      final userApiService = UserApiService();
      final users = await userApiService.fetchUsers(context);
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExportFormDialog(
          onExport: (int signatureCount) async {
            try {
              // Llama al método exportFormAsPDF del servicio
              await _formApiService.exportFormAsPDF(
                context,
                widget.form['id'],
                signatureCount: signatureCount,
                signatureDetails: {}, // Agrega detalles adicionales si es necesario
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export initiated successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error exporting PDF: $e'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

/*
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context, true);
          },
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            width: double.infinity, // Asegura que el fondo cubra todo el ancho
            height:
                double.infinity, // Asegura que el fondo cubra toda la altura
            color: const Color(0xFFE3F2FD), // Fondo azul
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.only(bottom: 100, right: 80),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: Color(0xFFE3F2FD),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    formDetails?['title'] ??
                                        widget.form['title'],
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    formDetails?['description'] ??
                                        'No description',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Questions',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  QuestionsListWidget(
                                    questions:
                                        formDetails?['questions'] as List? ??
                                            [],
                                    deleteFormQuestion: _deleteFormQuestion,
                                    showEditAnswerDialog: _showEditAnswerDialog,
                                    deleteAnswer: _deleteAnswer,
                                    shouldShowAnswerSelection:
                                        _shouldShowAnswerSelection,
                                    fetchFormDetails: _fetchFormDetails,
                                    formId: widget.form['id'],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
          Positioned(
            top: 16,
            right: 16,
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: isDeleting ? null : _showDeleteConfirmation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(18),
                  ),
                  child: isDeleting
                      ? const CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        )
                      : const Icon(
                          Icons.delete,
                          color: Colors.white,
                          size: 26,
                        ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return FormUpdateDialog(
                          form: formDetails ?? widget.form,
                          refreshForms: _fetchFormDetails,
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(18),
                  ),
                  child: const Icon(
                    Icons.edit,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _showExportDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(18),
                  ),
                  child: const Icon(
                    Icons.ios_share_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomCenter,
        child: AddButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AddOptionsDialog(
                  onAddQuestion: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return QuestionDialog(
                          refreshQuestions: _fetchFormDetails,
                        );
                      },
                    );
                  },
                  onSelectQuestions: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return QuestionSelectionDialog(
                          refreshQuestions: _fetchFormDetails,
                          formId: widget.form['id'],
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }*/

  /*appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, color: Colors.grey[700]),
            onPressed: _showExportDialog,
          ),
          if (!isDeleting)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.grey[700]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => FormUpdateDialog(
                  form: formDetails ?? widget.form,
                  refreshForms: _fetchFormDetails,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),*/
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back, color: Colors.grey[700]), // Removed const
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded,
                color: Colors.grey[700]), // Removed const
            onPressed: _showExportDialog,
          ),
          if (!isDeleting)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey[700]), // Removed const
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => FormUpdateDialog(
                  form: formDetails ?? widget.form,
                  refreshForms: _fetchFormDetails,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor:
          const Color(0xFFF0EBF8), // Color de fondo de Google Forms
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de título del formulario estilo Google Forms
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Container(
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Color(
                                0xFF673AB7), // Color morado de Google Forms
                            width: 8.0,
                          ),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formDetails?['title'] ?? widget.form['title'],
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formDetails?['description'] ?? 'No description',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Lista de preguntas con el nuevo estilo
                  QuestionsListWidget(
                    questions: formDetails?['questions'] as List? ?? [],
                    deleteFormQuestion: _deleteFormQuestion,
                    showEditAnswerDialog: _showEditAnswerDialog,
                    deleteAnswer: _deleteAnswer,
                    shouldShowAnswerSelection: _shouldShowAnswerSelection,
                    fetchFormDetails: _fetchFormDetails,
                    formId: widget.form['id'],
                  ),
                ],
              ),
            ),

      // Botones flotantes en el estilo de Google Forms
      // Reemplaza el actual floatingActionButton con este:
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botón de crear pregunta (+)
            FloatingActionButton(
              heroTag: 'add_question',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => QuestionDialog(
                    refreshQuestions: _fetchFormDetails,
                  ),
                );
              },
              backgroundColor: const Color(0xFF673AB7),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            // Botón de asignar preguntas
            FloatingActionButton(
              heroTag: 'assign_question',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => QuestionSelectionDialog(
                    refreshQuestions: _fetchFormDetails,
                    formId: widget.form['id'],
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.assignment,
                color: Color(0xFF673AB7),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

bool _shouldShowAnswerSelection(String questionType) {
  return !['date', 'datetime', 'text', 'user'].contains(questionType);
}
*/


/*
import 'package:flutter/material.dart';

import '../../../../services/api_model_services/UserApiService.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../../../services/api_model_services/api_form_services/QuestionApiService.dart';
import 'FormUpdateDialog.dart';
import 'form_detail_helper/QuestionsListWidget.dart';
import 'form_dialogs/ExportFormDialog.dart';
import 'form_dialogs/FormDialogs.dart';
import 'form_question_management/QuestionSelectionDialog.dart';

class FormDetailHelper extends StatefulWidget {
  final Map<String, dynamic> form;
  final VoidCallback? onFormDeleted;

  const FormDetailHelper({
    Key? key,
    required this.form,
    this.onFormDeleted,
  }) : super(key: key);

  @override
  _FormDetailScreenState createState() => _FormDetailScreenState();
}

class _FormDetailScreenState extends State<FormDetailHelper> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, dynamic>? formDetails;

  // Variables para la creación de preguntas inline
  final TextEditingController _questionTextController = TextEditingController();
  final QuestionApiService _formQuestionApiService = QuestionApiService();
  int? selectedQuestionTypeId;
  List<dynamic> questionTypes = [];
  bool isLoadingQuestionTypes = true;
  bool isRequired = false;
  bool showQuestionCreation = false; // Controla si se muestra el card para crear pregunta



  @override
  void initState() {
    super.initState();
    _fetchFormDetails();
    _fetchQuestionTypes();
  }

  Future<void> _fetchFormDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final details =
          await _formApiService.fetchFormById(context, widget.form['id']);
      if (mounted) {
        setState(() {
          formDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching form details: $e');
    }
  }

  Future<void> _fetchQuestionTypes() async {
    try {
      final types = await _formQuestionApiService.fetchQuestionTypes(context);
      if (mounted) {
        setState(() {
          questionTypes = types;
          isLoadingQuestionTypes = false;
        });
      }
    } catch (e) {
      print('Error fetching question types: $e');
      if (mounted) {
        setState(() {
          isLoadingQuestionTypes = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final scaffoldContext = ScaffoldMessenger.of(context);
    scaffoldContext.hideCurrentSnackBar();

    scaffoldContext.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() async {
    final confirm = await FormDialogs.showDeleteConfirmationDialog(context);
    if (confirm == true) {
      _deleteForm();
    }
  }

  Future<void> _deleteForm() async {
    setState(() {
      isDeleting = true;
    });

    try {
      await _formApiService.softDeleteForm(
        context,
        widget.form['id'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form deleted'),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      widget.onFormDeleted?.call();

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting form: $e'),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFormQuestion(
      BuildContext context, int formQuestionId) async {
    try {
      final bool? shouldDelete =
          await FormDialogs.showDeleteQuestionDialog(context);

      if (shouldDelete != true) return;

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final questionApiService = QuestionApiService();
      final result = await questionApiService.deleteQuestionFromForm(
        context,
        formQuestionId,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result['status'] == 200 || result['status'] == 204) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregunta eliminada exitosamente'),
            duration: Duration(milliseconds: 1500),
          ),
        );

        await _fetchFormDetails();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al eliminar la pregunta'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Future<void> _deleteAnswer(int formAnswerId) async {
    try {
      final bool? confirm = await FormDialogs.showDeleteAnswerDialog(context);

      if (confirm != true) return;

      final answerApiService = AnswerApiService();
      await answerApiService.deleteAnswerFromQuestion(
        context,
        formAnswerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Respuesta eliminada exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      await _fetchFormDetails();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la respuesta: $e'),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditAnswerDialog(String currentValue, dynamic answerData) {
    FormDialogs.showEditAnswerDialog(
      context: context,
      currentValue: currentValue,
      onSave: (updatedValue) async {
        try {
          await _answerApiService.updateAnswer(
            context,
            {
              'value': updatedValue,
              'remarks': answerData['remarks'] ?? null,
            },
            answerData['answer']['id'],
          );
          await _fetchFormDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Respuesta actualizada exitosamente'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar la respuesta: $e'),
              duration: const Duration(milliseconds: 1500),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildUserSelectionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<dynamic>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error loading users: ${snapshot.error}');
          }

          final users = snapshot.data ?? [];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 34, 118, 186),
                  ),
                ),
                hint: Text(
                  'Select User',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                items: users.map<DropdownMenuItem<int>>((user) {
                  // Asegurar que sean Strings:
                  final firstName = (user['first_name'] ?? '').toString();
                  final lastName = (user['last_name'] ?? '').toString();
                  return DropdownMenuItem<int>(
                    value: user['id'] as int?,
                    child: Text('$firstName $lastName'),
                  );
                }).toList(),
                onChanged: (value) {
                  print('Selected user ID: $value');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchUsers() async {
    try {
      final userApiService = UserApiService();
      final users = await userApiService.fetchUsers(context);
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExportFormDialog(
          onExport: (int signatureCount) async {
            try {
              await _formApiService.exportFormAsPDF(
                context,
                widget.form['id'],
                signatureCount: signatureCount,
                signatureDetails: {},
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export initiated successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error exporting PDF: $e'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

  bool _shouldShowAnswerSelection(String questionType) {
    return !['date', 'datetime', 'text', 'user'].contains(questionType);
  }

  // Widget para crear la pregunta inline
  Widget _buildQuestionCreationCard() {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de texto para la pregunta
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _questionTextController,
              decoration: const InputDecoration(
                hintText: 'Pregunta sin título',
                border: UnderlineInputBorder(),
                hintStyle: TextStyle(fontSize: 16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Selector de tipo de pregunta
          if (isLoadingQuestionTypes)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<int>(
                value: selectedQuestionTypeId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Seleccionar tipo de pregunta'),
                items: questionTypes.map((type) {
                  final String questionTypeString = (type['type'] ?? '').toString().toLowerCase();

                  IconData icon;
                  switch (questionTypeString) {
                    case 'multiple_choices':
                      icon = Icons.radio_button_checked;
                      break;
                    case 'checkbox':
                      icon = Icons.check_box;
                      break;
                    case 'date':
                      icon = Icons.calendar_today;
                      break;
                    case 'datetime':
                      icon = Icons.access_time;
                      break;
                    case 'text':
                      icon = Icons.short_text;
                      break;
                    case 'user':
                      icon = Icons.person;
                      break;
                    case 'signature':
                      icon = Icons.draw;
                      break;
                    default:
                      icon = Icons.question_answer;
                  }

                  return DropdownMenuItem<int>(
                    value: type['id'] as int?,
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text((type['type'] ?? '').toString()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedQuestionTypeId = value;
                  });
                },
              ),
            ),
          const SizedBox(height: 16),
          // Barra inferior con switch y botones
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Obligatorio
                Row(
                  children: [
                    const Text('Obligatorio'),
                    Switch(
                      value: isRequired,
                      onChanged: (value) {
                        setState(() {
                          isRequired = value;
                        });
                      },
                      activeColor: const Color(0xFF673AB7),
                    ),
                  ],
                ),
                // Botones de Cancelar y Crear
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          showQuestionCreation = false;
                          _questionTextController.clear();
                          selectedQuestionTypeId = null;
                          isRequired = false;
                        });
                      },
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: selectedQuestionTypeId == null
                          ? null
                          : _createQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Crear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createQuestion() async {
    if (_questionTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese el texto de la pregunta'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final questionData = {
        'text': _questionTextController.text,
        'question_type_id': selectedQuestionTypeId,
        'is_required': isRequired,
      };

      await _formQuestionApiService.createQuestion(context, questionData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pregunta creada exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      await _fetchFormDetails();
      setState(() {
        showQuestionCreation = false;
        _questionTextController.clear();
        selectedQuestionTypeId = null;
        isRequired = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creando la pregunta: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formTitle = (formDetails?['title'] ?? widget.form['title'] ?? 'Untitled Form').toString();
    final formDescription = (formDetails?['description'] ?? 'No description').toString();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded, color: Colors.grey[700]),
            onPressed: _showExportDialog,
          ),
          if (!isDeleting)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey[700]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => FormUpdateDialog(
                  form: formDetails ?? widget.form,
                  refreshForms: _fetchFormDetails,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF0EBF8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de título del formulario estilo Google Forms
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formTitle,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formDescription,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  QuestionsListWidget(
                    questions: formDetails?['questions'] as List? ?? [],
                    deleteFormQuestion: _deleteFormQuestion,
                    showEditAnswerDialog: _showEditAnswerDialog,
                    deleteAnswer: _deleteAnswer,
                    shouldShowAnswerSelection: _shouldShowAnswerSelection,
                    fetchFormDetails: _fetchFormDetails,
                    formId: widget.form['id'],
                  ),

                  // Mostrar el card de creación de pregunta inline si showQuestionCreation es true
                  if (showQuestionCreation) _buildQuestionCreationCard(),
                ],
              ),
            ),
      // Botones flotantes en el estilo de Google Forms
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botón de crear pregunta (+)
            FloatingActionButton(
              heroTag: 'add_question',
              onPressed: () {
                setState(() {
                  showQuestionCreation = true;
                });
              },
              backgroundColor: const Color(0xFF673AB7),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            // Botón de asignar preguntas existentes
            FloatingActionButton(
              heroTag: 'assign_question',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => QuestionSelectionDialog(
                    refreshQuestions: _fetchFormDetails,
                    formId: widget.form['id'],
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.assignment,
                color: Color(0xFF673AB7),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
*/


/*
import 'package:flutter/material.dart';

import '../../../../services/api_model_services/UserApiService.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../../../services/api_model_services/api_form_services/QuestionApiService.dart';
import 'FormUpdateDialog.dart';
import 'form_detail_helper/QuestionsListWidget.dart';
import 'form_dialogs/ExportFormDialog.dart';
import 'form_dialogs/FormDialogs.dart';
import 'form_question_management/QuestionSelectionDialog.dart';

class FormDetailHelper extends StatefulWidget {
  final Map<String, dynamic> form;
  final VoidCallback? onFormDeleted;

  const FormDetailHelper({
    Key? key,
    required this.form,
    this.onFormDeleted,
  }) : super(key: key);

  @override
  _FormDetailScreenState createState() => _FormDetailScreenState();
}

class _QuestionCreationData {
  TextEditingController questionTextController;
  int? selectedQuestionTypeId;
  bool isRequired;

  _QuestionCreationData({
    required this.questionTextController,
    this.selectedQuestionTypeId,
    this.isRequired = false,
  });
}

class _FormDetailScreenState extends State<FormDetailHelper> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  final QuestionApiService _formQuestionApiService = QuestionApiService();
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, dynamic>? formDetails;

  // Antes: bool showQuestionCreation = false;
  // Ahora una lista para manejar múltiples cards
  List<_QuestionCreationData> _questionCreations = [];

  List<dynamic> questionTypes = [];
  bool isLoadingQuestionTypes = true;

  @override
  void initState() {
    super.initState();
    _fetchFormDetails();
    _fetchQuestionTypes();
  }

  Future<void> _fetchFormDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final details =
          await _formApiService.fetchFormById(context, widget.form['id']);
      if (mounted) {
        setState(() {
          formDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching form details: $e');
    }
  }

  Future<void> _fetchQuestionTypes() async {
    try {
      final types = await _formQuestionApiService.fetchQuestionTypes(context);
      if (mounted) {
        setState(() {
          questionTypes = types;
          isLoadingQuestionTypes = false;
        });
      }
    } catch (e) {
      print('Error fetching question types: $e');
      if (mounted) {
        setState(() {
          isLoadingQuestionTypes = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final scaffoldContext = ScaffoldMessenger.of(context);
    scaffoldContext.hideCurrentSnackBar();

    scaffoldContext.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() async {
    final confirm = await FormDialogs.showDeleteConfirmationDialog(context);
    if (confirm == true) {
      _deleteForm();
    }
  }

  Future<void> _deleteForm() async {
    setState(() {
      isDeleting = true;
    });

    try {
      await _formApiService.softDeleteForm(
        context,
        widget.form['id'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form deleted'),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      widget.onFormDeleted?.call();

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting form: $e'),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFormQuestion(
      BuildContext context, int formQuestionId) async {
    try {
      final bool? shouldDelete =
          await FormDialogs.showDeleteQuestionDialog(context);

      if (shouldDelete != true) return;

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final questionApiService = QuestionApiService();
      final result = await questionApiService.deleteQuestionFromForm(
        context,
        formQuestionId,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result['status'] == 200 || result['status'] == 204) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregunta eliminada exitosamente'),
            duration: Duration(milliseconds: 1500),
          ),
        );

        await _fetchFormDetails();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al eliminar la pregunta'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Future<void> _deleteAnswer(int formAnswerId) async {
    try {
      final bool? confirm = await FormDialogs.showDeleteAnswerDialog(context);

      if (confirm != true) return;

      final answerApiService = AnswerApiService();
      await answerApiService.deleteAnswerFromQuestion(
        context,
        formAnswerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Respuesta eliminada exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      await _fetchFormDetails();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la respuesta: $e'),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditAnswerDialog(String currentValue, dynamic answerData) {
    FormDialogs.showEditAnswerDialog(
      context: context,
      currentValue: currentValue,
      onSave: (updatedValue) async {
        try {
          await _answerApiService.updateAnswer(
            context,
            {
              'value': updatedValue,
              'remarks': answerData['remarks'] ?? null,
            },
            answerData['answer']['id'],
          );
          await _fetchFormDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Respuesta actualizada exitosamente'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar la respuesta: $e'),
              duration: const Duration(milliseconds: 1500),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildUserSelectionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<dynamic>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error loading users: ${snapshot.error}');
          }

          final users = snapshot.data ?? [];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 34, 118, 186),
                  ),
                ),
                hint: Text(
                  'Select User',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                items: users.map<DropdownMenuItem<int>>((user) {
                  final firstName = (user['first_name'] ?? '').toString();
                  final lastName = (user['last_name'] ?? '').toString();
                  return DropdownMenuItem<int>(
                    value: user['id'] as int?,
                    child: Text('$firstName $lastName'),
                  );
                }).toList(),
                onChanged: (value) {
                  print('Selected user ID: $value');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchUsers() async {
    try {
      final userApiService = UserApiService();
      final users = await userApiService.fetchUsers(context);
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExportFormDialog(
          onExport: (int signatureCount) async {
            try {
              await _formApiService.exportFormAsPDF(
                context,
                widget.form['id'],
                signatureCount: signatureCount,
                signatureDetails: {},
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export initiated successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error exporting PDF: $e'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

  bool _shouldShowAnswerSelection(String questionType) {
    return !['date', 'datetime', 'text', 'user'].contains(questionType);
  }

  Widget _buildQuestionCreationCard(int index) {
    final data = _questionCreations[index];
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de texto para la pregunta
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: data.questionTextController,
              decoration: const InputDecoration(
                hintText: 'Pregunta sin título',
                border: UnderlineInputBorder(),
                hintStyle: TextStyle(fontSize: 16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Selector de tipo de pregunta
          if (isLoadingQuestionTypes)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<int>(
                value: data.selectedQuestionTypeId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Seleccionar tipo de pregunta'),
                items: questionTypes.map((type) {
                  final String questionTypeString = (type['type'] ?? '').toString().toLowerCase();

                  IconData icon;
                  switch (questionTypeString) {
                    case 'multiple_choices':
                      icon = Icons.radio_button_checked;
                      break;
                    case 'checkbox':
                      icon = Icons.check_box;
                      break;
                    case 'date':
                      icon = Icons.calendar_today;
                      break;
                    case 'datetime':
                      icon = Icons.access_time;
                      break;
                    case 'text':
                      icon = Icons.short_text;
                      break;
                    case 'user':
                      icon = Icons.person;
                      break;
                    case 'signature':
                      icon = Icons.draw;
                      break;
                    default:
                      icon = Icons.question_answer;
                  }

                  return DropdownMenuItem<int>(
                    value: type['id'] as int?,
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text((type['type'] ?? '').toString()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    data.selectedQuestionTypeId = value;
                  });
                },
              ),
            ),
          const SizedBox(height: 16),
          // Barra inferior con switch y botones
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Obligatorio
                Row(
                  children: [
                    const Text('Obligatorio'),
                    Switch(
                      value: data.isRequired,
                      onChanged: (value) {
                        setState(() {
                          data.isRequired = value;
                        });
                      },
                      activeColor: const Color(0xFF673AB7),
                    ),
                  ],
                ),
                // Botones de Cancelar y Crear
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _questionCreations.removeAt(index);
                        });
                      },
                      child: const Text('Cancelar'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: data.selectedQuestionTypeId == null
                          ? null
                          : () => _createQuestion(index),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Crear'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createQuestion(int index) async {
    final data = _questionCreations[index];

    if (data.questionTextController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingrese el texto de la pregunta'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final questionData = {
        'text': data.questionTextController.text,
        'question_type_id': data.selectedQuestionTypeId,
        'is_required': data.isRequired,
      };

      await _formQuestionApiService.createQuestion(context, questionData);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pregunta creada exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      await _fetchFormDetails();
      setState(() {
        _questionCreations.removeAt(index);
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creando la pregunta: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var data in _questionCreations) {
      data.questionTextController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formTitle = (formDetails?['title'] ?? widget.form['title'] ?? 'Untitled Form').toString();
    final formDescription = (formDetails?['description'] ?? 'No description').toString();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded, color: Colors.grey[700]),
            onPressed: _showExportDialog,
          ),
          if (!isDeleting)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey[700]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => FormUpdateDialog(
                  form: formDetails ?? widget.form,
                  refreshForms: _fetchFormDetails,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF0EBF8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tarjeta de título del formulario estilo Google Forms
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              formTitle,
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              formDescription,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  (formDetails?['questions'] as List? ?? []).isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text(
                              'No questions available',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                          ),
                        )
                      : QuestionsListWidget(
                          questions: formDetails?['questions'] as List? ?? [],
                          deleteFormQuestion: _deleteFormQuestion,
                          showEditAnswerDialog: _showEditAnswerDialog,
                          deleteAnswer: _deleteAnswer,
                          shouldShowAnswerSelection: _shouldShowAnswerSelection,
                          fetchFormDetails: _fetchFormDetails,
                          formId: widget.form['id'],
                        ),

                  // Mostrar todas las cards de creación de pregunta
                  for (int i = 0; i < _questionCreations.length; i++)
                    _buildQuestionCreationCard(i),
                ],
              ),
            ),
      // Botones flotantes en el estilo de Google Forms
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botón de crear pregunta (+)
            FloatingActionButton(
              heroTag: 'add_question',
              onPressed: () {
                setState(() {
                  _questionCreations.add(
                    _QuestionCreationData(
                      questionTextController: TextEditingController(),
                    ),
                  );
                });
              },
              backgroundColor: const Color(0xFF673AB7),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            // Botón de asignar preguntas existentes
            FloatingActionButton(
              heroTag: 'assign_question',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => QuestionSelectionDialog(
                    refreshQuestions: _fetchFormDetails,
                    formId: widget.form['id'],
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.assignment,
                color: Color(0xFF673AB7),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
*/

/*
import 'package:flutter/material.dart';

import '../../../../services/api_model_services/UserApiService.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../../../services/api_model_services/api_form_services/QuestionApiService.dart';
import 'FormUpdateDialog.dart';
import 'form_detail_helper/QuestionsListWidget.dart';
import 'form_dialogs/ExportFormDialog.dart';
import 'form_dialogs/FormDialogs.dart';
import 'form_question_management/QuestionSelectionDialog.dart';

class FormDetailHelper extends StatefulWidget {
  final Map<String, dynamic> form;
  final VoidCallback? onFormDeleted;

  const FormDetailHelper({
    Key? key,
    required this.form,
    this.onFormDeleted,
  }) : super(key: key);

  @override
  _FormDetailScreenState createState() => _FormDetailScreenState();
}

class _QuestionCreationData {
  TextEditingController questionTextController;
  int? selectedQuestionTypeId;
  bool isRequired;

  _QuestionCreationData({
    required this.questionTextController,
    this.selectedQuestionTypeId,
    this.isRequired = false,
  });
}

class _FormDetailScreenState extends State<FormDetailHelper> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  final QuestionApiService _formQuestionApiService = QuestionApiService();
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, dynamic>? formDetails;

  List<_QuestionCreationData> _questionCreations = [];
  List<dynamic> questionTypes = [];
  bool isLoadingQuestionTypes = true;

  @override
  void initState() {
    super.initState();
    _fetchFormDetails();
    _fetchQuestionTypes();
  }

  Future<void> _fetchFormDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final details =
          await _formApiService.fetchFormById(context, widget.form['id']);
      if (mounted) {
        setState(() {
          formDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching form details: $e');
    }
  }

  Future<void> _fetchQuestionTypes() async {
    try {
      final types = await _formQuestionApiService.fetchQuestionTypes(context);
      if (mounted) {
        setState(() {
          questionTypes = types;
          isLoadingQuestionTypes = false;
        });
      }
    } catch (e) {
      print('Error fetching question types: $e');
      if (mounted) {
        setState(() {
          isLoadingQuestionTypes = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final scaffoldContext = ScaffoldMessenger.of(context);
    scaffoldContext.hideCurrentSnackBar();

    scaffoldContext.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() async {
    final confirm = await FormDialogs.showDeleteConfirmationDialog(context);
    if (confirm == true) {
      _deleteForm();
    }
  }

  Future<void> _deleteForm() async {
    setState(() {
      isDeleting = true;
    });

    try {
      await _formApiService.softDeleteForm(
        context,
        widget.form['id'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form deleted'),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      widget.onFormDeleted?.call();

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting form: $e'),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFormQuestion(
      BuildContext context, int formQuestionId) async {
    try {
      final bool? shouldDelete =
          await FormDialogs.showDeleteQuestionDialog(context);

      if (shouldDelete != true) return;

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final questionApiService = QuestionApiService();
      final result = await questionApiService.deleteQuestionFromForm(
        context,
        formQuestionId,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result['status'] == 200 || result['status'] == 204) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregunta eliminada exitosamente'),
            duration: Duration(milliseconds: 1500),
          ),
        );

        await _fetchFormDetails();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al eliminar la pregunta'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Future<void> _deleteAnswer(int formAnswerId) async {
    try {
      final bool? confirm = await FormDialogs.showDeleteAnswerDialog(context);

      if (confirm != true) return;

      final answerApiService = AnswerApiService();
      await answerApiService.deleteAnswerFromQuestion(
        context,
        formAnswerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Respuesta eliminada exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      await _fetchFormDetails();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la respuesta: $e'),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditAnswerDialog(String currentValue, dynamic answerData) {
    FormDialogs.showEditAnswerDialog(
      context: context,
      currentValue: currentValue,
      onSave: (updatedValue) async {
        try {
          await _answerApiService.updateAnswer(
            context,
            {
              'value': updatedValue,
              'remarks': answerData['remarks'] ?? null,
            },
            answerData['answer']['id'],
          );
          await _fetchFormDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Respuesta actualizada exitosamente'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar la respuesta: $e'),
              duration: const Duration(milliseconds: 1500),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildUserSelectionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<dynamic>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error loading users: ${snapshot.error}');
          }

          final users = snapshot.data ?? [];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 34, 118, 186),
                  ),
                ),
                hint: Text(
                  'Select User',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                items: users.map<DropdownMenuItem<int>>((user) {
                  final firstName = (user['first_name'] ?? '').toString();
                  final lastName = (user['last_name'] ?? '').toString();
                  return DropdownMenuItem<int>(
                    value: user['id'] as int?,
                    child: Text('$firstName $lastName'),
                  );
                }).toList(),
                onChanged: (value) {
                  print('Selected user ID: $value');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchUsers() async {
    try {
      final userApiService = UserApiService();
      final users = await userApiService.fetchUsers(context);
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExportFormDialog(
          onExport: (int signatureCount) async {
            try {
              await _formApiService.exportFormAsPDF(
                context,
                widget.form['id'],
                signatureCount: signatureCount,
                signatureDetails: {},
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export initiated successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error exporting PDF: $e'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

  bool _shouldShowAnswerSelection(String questionType) {
    return !['date', 'datetime', 'text', 'user'].contains(questionType);
  }

  Widget _buildQuestionCreationCard(int index) {
    final data = _questionCreations[index];
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de texto para la pregunta
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: data.questionTextController,
              decoration: const InputDecoration(
                hintText: 'Pregunta sin título',
                border: UnderlineInputBorder(),
                hintStyle: TextStyle(fontSize: 16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Selector de tipo de pregunta
          if (isLoadingQuestionTypes)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<int>(
                value: data.selectedQuestionTypeId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Seleccionar tipo de pregunta'),
                items: questionTypes.map((type) {
                  final String questionTypeString = (type['type'] ?? '').toString().toLowerCase();

                  IconData icon;
                  switch (questionTypeString) {
                    case 'multiple_choices':
                      icon = Icons.radio_button_checked;
                      break;
                    case 'checkbox':
                      icon = Icons.check_box;
                      break;
                    case 'date':
                      icon = Icons.calendar_today;
                      break;
                    case 'datetime':
                      icon = Icons.access_time;
                      break;
                    case 'text':
                      icon = Icons.short_text;
                      break;
                    case 'user':
                      icon = Icons.person;
                      break;
                    case 'signature':
                      icon = Icons.draw;
                      break;
                    default:
                      icon = Icons.question_answer;
                  }

                  return DropdownMenuItem<int>(
                    value: type['id'] as int?,
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text((type['type'] ?? '').toString()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    data.selectedQuestionTypeId = value;
                  });
                },
              ),
            ),
          const SizedBox(height: 16),
          // Barra inferior con switch y botón cancelar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _questionCreations.removeAt(index);
                    });
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAllQuestions() async {
    // Crear todas las preguntas pendientes
    try {
      for (var data in _questionCreations) {
        if (data.questionTextController.text.isEmpty ||
            data.selectedQuestionTypeId == null) {
          // Si hay alguna pregunta sin texto o sin tipo seleccionado
          // se puede decidir qué hacer, por ejemplo ignorarla o mostrar un error.
          // Aquí mostraremos un error y no seguiremos.
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor complete todas las preguntas antes de guardar.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      // Si todas las preguntas están completas, las creamos
      for (var data in _questionCreations) {
        final questionData = {
          'text': data.questionTextController.text,
          'question_type_id': data.selectedQuestionTypeId,
          'is_required': data.isRequired,
        };

        await _formQuestionApiService.createQuestion(context, questionData);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preguntas creadas exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      // Limpiamos la lista de creación
      setState(() {
        _questionCreations.clear();
      });

      // Refrescamos el listado de preguntas
      await _fetchFormDetails();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creando las preguntas: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var data in _questionCreations) {
      data.questionTextController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formTitle = (formDetails?['title'] ?? widget.form['title'] ?? 'Untitled Form').toString();
    final formDescription = (formDetails?['description'] ?? 'No description').toString();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded, color: Colors.grey[700]),
            onPressed: _showExportDialog,
          ),
          if (!isDeleting)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey[700]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => FormUpdateDialog(
                  form: formDetails ?? widget.form,
                  refreshForms: _fetchFormDetails,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF0EBF8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta de título del formulario estilo Google Forms
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formTitle,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formDescription,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      (formDetails?['questions'] as List? ?? []).isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No questions available',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          : QuestionsListWidget(
                              questions: formDetails?['questions'] as List? ?? [],
                              deleteFormQuestion: _deleteFormQuestion,
                              showEditAnswerDialog: _showEditAnswerDialog,
                              deleteAnswer: _deleteAnswer,
                              shouldShowAnswerSelection: _shouldShowAnswerSelection,
                              fetchFormDetails: _fetchFormDetails,
                              formId: widget.form['id'],
                            ),

                      // Mostrar todas las cards de creación de pregunta
                      for (int i = 0; i < _questionCreations.length; i++)
                        _buildQuestionCreationCard(i),

                      // Espacio extra al final
                      SizedBox(height: _questionCreations.isNotEmpty ? 80 : 16),
                    ],
                  ),
                ),

                // Botón SAVE en la parte inferior si hay preguntas en creación
                if (_questionCreations.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: _saveAllQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('SAVE', style: TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botón de crear pregunta (+)
            FloatingActionButton(
              heroTag: 'add_question',
              onPressed: () {
                setState(() {
                  _questionCreations.add(
                    _QuestionCreationData(
                      questionTextController: TextEditingController(),
                    ),
                  );
                });
              },
              backgroundColor: const Color(0xFF673AB7),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            // Botón de asignar preguntas existentes
            FloatingActionButton(
              heroTag: 'assign_question',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => QuestionSelectionDialog(
                    refreshQuestions: _fetchFormDetails,
                    formId: widget.form['id'],
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.assignment,
                color: Color(0xFF673AB7),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
*/



/*
import 'package:flutter/material.dart';

import '../../../../services/api_model_services/UserApiService.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../../../services/api_model_services/api_form_services/QuestionApiService.dart';
import 'FormUpdateDialog.dart';
import 'form_detail_helper/QuestionsListWidget.dart';
import 'form_dialogs/ExportFormDialog.dart';
import 'form_dialogs/FormDialogs.dart';
import 'form_question_management/QuestionSelectionDialog.dart';

class FormDetailHelper extends StatefulWidget {
  final Map<String, dynamic> form;
  final VoidCallback? onFormDeleted;

  const FormDetailHelper({
    Key? key,
    required this.form,
    this.onFormDeleted,
  }) : super(key: key);

  @override
  _FormDetailScreenState createState() => _FormDetailScreenState();
}

class _QuestionCreationData {
  TextEditingController questionTextController;
  int? selectedQuestionTypeId;
  bool isRequired;

  _QuestionCreationData({
    required this.questionTextController,
    this.selectedQuestionTypeId,
    this.isRequired = false,
  });
}

class _FormDetailScreenState extends State<FormDetailHelper> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  final QuestionApiService _formQuestionApiService = QuestionApiService();
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, dynamic>? formDetails;

  List<_QuestionCreationData> _questionCreations = [];
  List<dynamic> questionTypes = [];
  bool isLoadingQuestionTypes = true;

  @override
  void initState() {
    super.initState();
    _fetchFormDetails();
    _fetchQuestionTypes();
  }

  Future<void> _fetchFormDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final details =
          await _formApiService.fetchFormById(context, widget.form['id']);
      if (mounted) {
        setState(() {
          formDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching form details: $e');
    }
  }

  Future<void> _fetchQuestionTypes() async {
    try {
      final types = await _formQuestionApiService.fetchQuestionTypes(context);
      if (mounted) {
        setState(() {
          questionTypes = types;
          isLoadingQuestionTypes = false;
        });
      }
    } catch (e) {
      print('Error fetching question types: $e');
      if (mounted) {
        setState(() {
          isLoadingQuestionTypes = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final scaffoldContext = ScaffoldMessenger.of(context);
    scaffoldContext.hideCurrentSnackBar();

    scaffoldContext.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() async {
    final confirm = await FormDialogs.showDeleteConfirmationDialog(context);
    if (confirm == true) {
      _deleteForm();
    }
  }

  Future<void> _deleteForm() async {
    setState(() {
      isDeleting = true;
    });

    try {
      await _formApiService.softDeleteForm(
        context,
        widget.form['id'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form deleted'),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      widget.onFormDeleted?.call();

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting form: $e'),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFormQuestion(
      BuildContext context, int formQuestionId) async {
    try {
      final bool? shouldDelete =
          await FormDialogs.showDeleteQuestionDialog(context);

      if (shouldDelete != true) return;

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final questionApiService = QuestionApiService();
      final result = await questionApiService.deleteQuestionFromForm(
        context,
        formQuestionId,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result['status'] == 200 || result['status'] == 204) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregunta eliminada exitosamente'),
            duration: Duration(milliseconds: 1500),
          ),
        );

        await _fetchFormDetails();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al eliminar la pregunta'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Future<void> _deleteAnswer(int formAnswerId) async {
    try {
      final bool? confirm = await FormDialogs.showDeleteAnswerDialog(context);

      if (confirm != true) return;

      final answerApiService = AnswerApiService();
      await answerApiService.deleteAnswerFromQuestion(
        context,
        formAnswerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Respuesta eliminada exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      await _fetchFormDetails();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la respuesta: $e'),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditAnswerDialog(String currentValue, dynamic answerData) {
    FormDialogs.showEditAnswerDialog(
      context: context,
      currentValue: currentValue,
      onSave: (updatedValue) async {
        try {
          await _answerApiService.updateAnswer(
            context,
            {
              'value': updatedValue,
              'remarks': answerData['remarks'] ?? null,
            },
            answerData['answer']['id'],
          );
          await _fetchFormDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Respuesta actualizada exitosamente'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar la respuesta: $e'),
              duration: const Duration(milliseconds: 1500),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildUserSelectionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<dynamic>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error loading users: ${snapshot.error}');
          }

          final users = snapshot.data ?? [];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 34, 118, 186),
                  ),
                ),
                hint: Text(
                  'Select User',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                items: users.map<DropdownMenuItem<int>>((user) {
                  final firstName = (user['first_name'] ?? '').toString();
                  final lastName = (user['last_name'] ?? '').toString();
                  return DropdownMenuItem<int>(
                    value: user['id'] as int?,
                    child: Text('$firstName $lastName'),
                  );
                }).toList(),
                onChanged: (value) {
                  print('Selected user ID: $value');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchUsers() async {
    try {
      final userApiService = UserApiService();
      final users = await userApiService.fetchUsers(context);
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExportFormDialog(
          onExport: (int signatureCount) async {
            try {
              await _formApiService.exportFormAsPDF(
                context,
                widget.form['id'],
                signatureCount: signatureCount,
                signatureDetails: {},
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export initiated successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error exporting PDF: $e'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

  bool _shouldShowAnswerSelection(String questionType) {
    return !['date', 'datetime', 'text', 'user'].contains(questionType);
  }

  Widget _buildQuestionCreationCard(int index) {
    final data = _questionCreations[index];
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de texto para la pregunta
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: data.questionTextController,
              decoration: const InputDecoration(
                hintText: 'Pregunta sin título',
                border: UnderlineInputBorder(),
                hintStyle: TextStyle(fontSize: 16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Selector de tipo de pregunta
          if (isLoadingQuestionTypes)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<int>(
                value: data.selectedQuestionTypeId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Seleccionar tipo de pregunta'),
                items: questionTypes.map((type) {
                  final String questionTypeString = (type['type'] ?? '').toString().toLowerCase();

                  IconData icon;
                  switch (questionTypeString) {
                    case 'multiple_choices':
                      icon = Icons.radio_button_checked;
                      break;
                    case 'checkbox':
                      icon = Icons.check_box;
                      break;
                    case 'date':
                      icon = Icons.calendar_today;
                      break;
                    case 'datetime':
                      icon = Icons.access_time;
                      break;
                    case 'text':
                      icon = Icons.short_text;
                      break;
                    case 'user':
                      icon = Icons.person;
                      break;
                    case 'signature':
                      icon = Icons.draw;
                      break;
                    default:
                      icon = Icons.question_answer;
                  }

                  return DropdownMenuItem<int>(
                    value: type['id'] as int?,
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text((type['type'] ?? '').toString()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    data.selectedQuestionTypeId = value;
                  });
                },
              ),
            ),
          const SizedBox(height: 16),
          // Barra inferior con switch y botón cancelar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Obligatorio
                Expanded(
                  child: Row(
                    children: [
                      const Text('Obligatorio'),
                      Switch(
                        value: data.isRequired,
                        onChanged: (value) {
                          setState(() {
                            data.isRequired = value;
                          });
                        },
                        activeColor: const Color(0xFF673AB7),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _questionCreations.removeAt(index);
                    });
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAllQuestions() async {
    // Crear y asignar todas las preguntas pendientes
    try {
      // Verificar que todas las preguntas tengan texto y tipo
      for (var data in _questionCreations) {
        if (data.questionTextController.text.isEmpty ||
            data.selectedQuestionTypeId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor complete todas las preguntas antes de guardar.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      int order = (formDetails?['questions']?.length ?? 0) + 1;

      // Crear y asignar las preguntas
      for (var data in _questionCreations) {
        final questionData = {
          'text': data.questionTextController.text,
          'question_type_id': data.selectedQuestionTypeId,
          'is_required': data.isRequired,
        };

        // Crear la pregunta
        final createdQuestion = await _formQuestionApiService.createQuestion(context, questionData);

        // Asumimos que createQuestion devuelve un Map con la pregunta creada, incluyendo 'id'
        // Por ejemplo: { 'id': 123, 'text': '...', ... }
        final newQuestionId = createdQuestion['id'];

        // Asignar la pregunta al formulario
        await _formQuestionApiService.assignQuestionToForm(
          context,
          widget.form['id'],
          newQuestionId,
          order++,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preguntas creadas y asignadas exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      // Limpiamos la lista de creación
      setState(() {
        _questionCreations.clear();
      });

      // Refrescamos el listado de preguntas
      await _fetchFormDetails();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creando las preguntas: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var data in _questionCreations) {
      data.questionTextController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formTitle = (formDetails?['title'] ?? widget.form['title'] ?? 'Untitled Form').toString();
    final formDescription = (formDetails?['description'] ?? 'No description').toString();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded, color: Colors.grey[700]),
            onPressed: _showExportDialog,
          ),
          if (!isDeleting)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey[700]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => FormUpdateDialog(
                  form: formDetails ?? widget.form,
                  refreshForms: _fetchFormDetails,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF0EBF8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta de título del formulario estilo Google Forms
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formTitle,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formDescription,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      (formDetails?['questions'] as List? ?? []).isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No questions available',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          : QuestionsListWidget(
                              questions: formDetails?['questions'] as List? ?? [],
                              deleteFormQuestion: _deleteFormQuestion,
                              showEditAnswerDialog: _showEditAnswerDialog,
                              deleteAnswer: _deleteAnswer,
                              shouldShowAnswerSelection: _shouldShowAnswerSelection,
                              fetchFormDetails: _fetchFormDetails,
                              formId: widget.form['id'],
                            ),

                      // Mostrar todas las cards de creación de pregunta
                      for (int i = 0; i < _questionCreations.length; i++)
                        _buildQuestionCreationCard(i),

                      // Espacio extra al final
                      SizedBox(height: _questionCreations.isNotEmpty ? 80 : 16),
                    ],
                  ),
                ),

                // Botón SAVE en la parte inferior si hay preguntas en creación
                if (_questionCreations.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: _saveAllQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('SAVE', style: TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botón de crear pregunta (+)
            FloatingActionButton(
              heroTag: 'add_question',
              onPressed: () {
                setState(() {
                  _questionCreations.add(
                    _QuestionCreationData(
                      questionTextController: TextEditingController(),
                    ),
                  );
                });
              },
              backgroundColor: const Color(0xFF673AB7),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            // Botón de asignar preguntas existentes
            FloatingActionButton(
              heroTag: 'assign_question',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => QuestionSelectionDialog(
                    refreshQuestions: _fetchFormDetails,
                    formId: widget.form['id'],
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.assignment,
                color: Color(0xFF673AB7),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
*/



/*
import 'package:flutter/material.dart';

import '../../../../services/api_model_services/UserApiService.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../../../services/api_model_services/api_form_services/QuestionApiService.dart';
import 'FormUpdateDialog.dart';
import 'form_detail_helper/QuestionsListWidget.dart';
import 'form_dialogs/ExportFormDialog.dart';
import 'form_dialogs/FormDialogs.dart';
import 'form_question_management/QuestionSelectionDialog.dart';

class FormDetailHelper extends StatefulWidget {
  final Map<String, dynamic> form;
  final VoidCallback? onFormDeleted;

  const FormDetailHelper({
    Key? key,
    required this.form,
    this.onFormDeleted,
  }) : super(key: key);

  @override
  _FormDetailScreenState createState() => _FormDetailScreenState();
}

class _QuestionCreationData {
  TextEditingController questionTextController;
  int? selectedQuestionTypeId;
  bool isRequired;

  _QuestionCreationData({
    required this.questionTextController,
    this.selectedQuestionTypeId,
    this.isRequired = false,
  });
}

class _FormDetailScreenState extends State<FormDetailHelper> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  final QuestionApiService _formQuestionApiService = QuestionApiService();
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, dynamic>? formDetails;

  // Lista de preguntas en creación (varias cards)
  List<_QuestionCreationData> _questionCreations = [];
  List<dynamic> questionTypes = [];
  bool isLoadingQuestionTypes = true;

  @override
  void initState() {
    super.initState();
    _fetchFormDetails();
    _fetchQuestionTypes();
  }

  Future<void> _fetchFormDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final details =
          await _formApiService.fetchFormById(context, widget.form['id']);
      if (mounted) {
        setState(() {
          formDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching form details: $e');
    }
  }

  Future<void> _fetchQuestionTypes() async {
    try {
      final types = await _formQuestionApiService.fetchQuestionTypes(context);
      if (mounted) {
        setState(() {
          questionTypes = types;
          isLoadingQuestionTypes = false;
        });
      }
    } catch (e) {
      print('Error fetching question types: $e');
      if (mounted) {
        setState(() {
          isLoadingQuestionTypes = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final scaffoldContext = ScaffoldMessenger.of(context);
    scaffoldContext.hideCurrentSnackBar();

    scaffoldContext.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() async {
    final confirm = await FormDialogs.showDeleteConfirmationDialog(context);
    if (confirm == true) {
      _deleteForm();
    }
  }

  Future<void> _deleteForm() async {
    setState(() {
      isDeleting = true;
    });

    try {
      await _formApiService.softDeleteForm(
        context,
        widget.form['id'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form deleted'),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      widget.onFormDeleted?.call();

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting form: $e'),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFormQuestion(
      BuildContext context, int formQuestionId) async {
    try {
      final bool? shouldDelete =
          await FormDialogs.showDeleteQuestionDialog(context);

      if (shouldDelete != true) return;

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final questionApiService = QuestionApiService();
      final result = await questionApiService.deleteQuestionFromForm(
        context,
        formQuestionId,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result['status'] == 200 || result['status'] == 204) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregunta eliminada exitosamente'),
            duration: Duration(milliseconds: 1500),
          ),
        );

        await _fetchFormDetails();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al eliminar la pregunta'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Future<void> _deleteAnswer(int formAnswerId) async {
    try {
      final bool? confirm = await FormDialogs.showDeleteAnswerDialog(context);

      if (confirm != true) return;

      final answerApiService = AnswerApiService();
      await answerApiService.deleteAnswerFromQuestion(
        context,
        formAnswerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Respuesta eliminada exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      await _fetchFormDetails();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la respuesta: $e'),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditAnswerDialog(String currentValue, dynamic answerData) {
    FormDialogs.showEditAnswerDialog(
      context: context,
      currentValue: currentValue,
      onSave: (updatedValue) async {
        try {
          await _answerApiService.updateAnswer(
            context,
            {
              'value': updatedValue,
              'remarks': answerData['remarks'] ?? null,
            },
            answerData['answer']['id'],
          );
          await _fetchFormDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Respuesta actualizada exitosamente'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar la respuesta: $e'),
              duration: const Duration(milliseconds: 1500),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildUserSelectionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<dynamic>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error loading users: ${snapshot.error}');
          }

          final users = snapshot.data ?? [];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 34, 118, 186),
                  ),
                ),
                hint: Text(
                  'Select User',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                items: users.map<DropdownMenuItem<int>>((user) {
                  final firstName = (user['first_name'] ?? '').toString();
                  final lastName = (user['last_name'] ?? '').toString();
                  return DropdownMenuItem<int>(
                    value: user['id'] as int?,
                    child: Text('$firstName $lastName'),
                  );
                }).toList(),
                onChanged: (value) {
                  print('Selected user ID: $value');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchUsers() async {
    try {
      final userApiService = UserApiService();
      final users = await userApiService.fetchUsers(context);
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExportFormDialog(
          onExport: (int signatureCount) async {
            try {
              await _formApiService.exportFormAsPDF(
                context,
                widget.form['id'],
                signatureCount: signatureCount,
                signatureDetails: {},
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export initiated successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error exporting PDF: $e'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }

  bool _shouldShowAnswerSelection(String questionType) {
    return !['date', 'datetime', 'text', 'user'].contains(questionType);
  }

  Widget _buildQuestionCreationCard(int index) {
    final data = _questionCreations[index];
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de texto para la pregunta
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: data.questionTextController,
              decoration: const InputDecoration(
                hintText: 'Pregunta sin título',
                border: UnderlineInputBorder(),
                hintStyle: TextStyle(fontSize: 16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Selector de tipo de pregunta
          if (isLoadingQuestionTypes)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<int>(
                value: data.selectedQuestionTypeId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Seleccionar tipo de pregunta'),
                items: questionTypes.map((type) {
                  final String questionTypeString =
                      (type['type'] ?? '').toString().toLowerCase();

                  IconData icon;
                  switch (questionTypeString) {
                    case 'multiple_choices':
                      icon = Icons.radio_button_checked;
                      break;
                    case 'checkbox':
                      icon = Icons.check_box;
                      break;
                    case 'date':
                      icon = Icons.calendar_today;
                      break;
                    case 'datetime':
                      icon = Icons.access_time;
                      break;
                    case 'text':
                      icon = Icons.short_text;
                      break;
                    case 'user':
                      icon = Icons.person;
                      break;
                    case 'signature':
                      icon = Icons.draw;
                      break;
                    default:
                      icon = Icons.question_answer;
                  }

                  return DropdownMenuItem<int>(
                    value: type['id'] as int?,
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text((type['type'] ?? '').toString()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    data.selectedQuestionTypeId = value;
                  });
                },
              ),
            ),
          const SizedBox(height: 16),
          // Barra inferior con switch y botón cancelar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Obligatorio
                Row(
                  children: [
                    const Text('Obligatorio'),
                    Switch(
                      value: data.isRequired,
                      onChanged: (value) {
                        setState(() {
                          data.isRequired = value;
                        });
                      },
                      activeColor: const Color(0xFF673AB7),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _questionCreations.removeAt(index);
                    });
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveAllQuestions() async {
    try {
      // Validar que todas las preguntas tengan texto y tipo
      for (var data in _questionCreations) {
        if (data.questionTextController.text.isEmpty ||
            data.selectedQuestionTypeId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor complete todas las preguntas antes de guardar.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      final formId = widget.form['id'];
      if (formId == null || formId is! int) {
        throw Exception("El ID del formulario no es válido.");
      }

      int order = (formDetails?['questions']?.length ?? 0) + 1;

      for (var data in _questionCreations) {
        final questionData = {
          'text': data.questionTextController.text,
          'question_type_id': data.selectedQuestionTypeId,
          'is_required': data.isRequired,
        };

        final createdQuestion = await _formQuestionApiService.createQuestion(context, questionData);
        // Asegurar que createdQuestion contenga un 'id' int
        final newQuestionId = createdQuestion['id'];
        if (newQuestionId == null || newQuestionId is! int) {
          // Si no se obtuvo un ID válido, mostramos error y no asignamos.
          throw Exception("La pregunta creada no retornó un ID válido.");
        }

        await _formQuestionApiService.assignQuestionToForm(
          context,
          formId,
          newQuestionId,
          order++,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preguntas creadas y asignadas exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      setState(() {
        _questionCreations.clear();
      });

      await _fetchFormDetails();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creando las preguntas: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var data in _questionCreations) {
      data.questionTextController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formTitle = (formDetails?['title'] ?? widget.form['title'] ?? 'Untitled Form').toString();
    final formDescription = (formDetails?['description'] ?? 'No description').toString();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded, color: Colors.grey[700]),
            onPressed: _showExportDialog,
          ),
          if (!isDeleting)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey[700]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => FormUpdateDialog(
                  form: formDetails ?? widget.form,
                  refreshForms: _fetchFormDetails,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF0EBF8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta de título del formulario
                      Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formTitle,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formDescription,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      (formDetails?['questions'] as List? ?? []).isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No questions available',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          : QuestionsListWidget(
                              questions: formDetails?['questions'] as List? ?? [],
                              deleteFormQuestion: _deleteFormQuestion,
                              showEditAnswerDialog: _showEditAnswerDialog,
                              deleteAnswer: _deleteAnswer,
                              shouldShowAnswerSelection: _shouldShowAnswerSelection,
                              fetchFormDetails: _fetchFormDetails,
                              formId: widget.form['id'],
                            ),

                      // Mostrar todas las cards de creación de pregunta
                      for (int i = 0; i < _questionCreations.length; i++)
                        _buildQuestionCreationCard(i),

                      // Espacio extra al final
                      SizedBox(height: _questionCreations.isNotEmpty ? 80 : 16),
                    ],
                  ),
                ),

                // Botón SAVE si hay preguntas en creación
                if (_questionCreations.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: _saveAllQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('SAVE', style: TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botón de crear pregunta (+)
            FloatingActionButton(
              heroTag: 'add_question',
              onPressed: () {
                setState(() {
                  _questionCreations.add(
                    _QuestionCreationData(
                      questionTextController: TextEditingController(),
                    ),
                  );
                });
              },
              backgroundColor: const Color(0xFF673AB7),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            // Botón de asignar preguntas existentes
            FloatingActionButton(
              heroTag: 'assign_question',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => QuestionSelectionDialog(
                    refreshQuestions: _fetchFormDetails,
                    formId: widget.form['id'],
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.assignment,
                color: Color(0xFF673AB7),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
*/


import 'package:flutter/material.dart';

import '../../../../services/api_model_services/UserApiService.dart';
import '../../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../../../services/api_model_services/api_form_services/QuestionApiService.dart';
import 'FormUpdateDialog.dart';
import 'form_detail_helper/QuestionsListWidget.dart';
import 'form_dialogs/ExportFormDialog.dart';
import 'form_dialogs/FormDialogs.dart';
import 'form_question_management/QuestionSelectionDialog.dart';

class FormDetailHelper extends StatefulWidget {
  final Map<String, dynamic> form;
  final VoidCallback? onFormDeleted;

  const FormDetailHelper({
    Key? key,
    required this.form,
    this.onFormDeleted,
  }) : super(key: key);

  @override
  _FormDetailScreenState createState() => _FormDetailScreenState();
}

class _QuestionCreationData {
  TextEditingController questionTextController;
  int? selectedQuestionTypeId;
  bool isRequired;

  _QuestionCreationData({
    required this.questionTextController,
    this.selectedQuestionTypeId,
    this.isRequired = false,
  });
}

class _FormDetailScreenState extends State<FormDetailHelper> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  final QuestionApiService _formQuestionApiService = QuestionApiService();
  bool isLoading = true;
  bool isDeleting = false;
  Map<String, dynamic>? formDetails;

  // Lista de preguntas en creación
  List<_QuestionCreationData> _questionCreations = [];
  List<dynamic> questionTypes = [];
  bool isLoadingQuestionTypes = true;

  @override
  void initState() {
    super.initState();
    _fetchFormDetails();
    _fetchQuestionTypes();
  }

  Future<void> _fetchFormDetails() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final details =
          await _formApiService.fetchFormById(context, widget.form['id']);
      if (mounted) {
        setState(() {
          formDetails = details;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching form details: $e');
    }
  }

  Future<void> _fetchQuestionTypes() async {
    try {
      final types = await _formQuestionApiService.fetchQuestionTypes(context);
      if (mounted) {
        setState(() {
          questionTypes = types;
          isLoadingQuestionTypes = false;
        });
      }
    } catch (e) {
      print('Error fetching question types: $e');
      if (mounted) {
        setState(() {
          isLoadingQuestionTypes = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    final scaffoldContext = ScaffoldMessenger.of(context);
    scaffoldContext.hideCurrentSnackBar();

    scaffoldContext.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }

  void _showDeleteConfirmation() async {
    final confirm = await FormDialogs.showDeleteConfirmationDialog(context);
    if (confirm == true) {
      _deleteForm();
    }
  }

  Future<void> _deleteForm() async {
    setState(() {
      isDeleting = true;
    });

    try {
      await _formApiService.softDeleteForm(
        context,
        widget.form['id'],
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form deleted'),
          duration: Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
        ),
      );

      widget.onFormDeleted?.call();

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isDeleting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting form: $e'),
          duration: const Duration(milliseconds: 1500),
          behavior: SnackBarBehavior.fixed,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteFormQuestion(
      BuildContext context, int formQuestionId) async {
    try {
      final bool? shouldDelete =
          await FormDialogs.showDeleteQuestionDialog(context);

      if (shouldDelete != true) return;

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final questionApiService = QuestionApiService();
      final result = await questionApiService.deleteQuestionFromForm(
        context,
        formQuestionId,
      );

      if (!mounted) return;
      Navigator.pop(context);

      if (result['status'] == 200 || result['status'] == 204) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pregunta eliminada exitosamente'),
            duration: Duration(milliseconds: 1500),
          ),
        );

        await _fetchFormDetails();
      } else {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error al eliminar la pregunta'),
            duration: const Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          duration: const Duration(milliseconds: 1500),
        ),
      );
    }
  }

  Future<void> _deleteAnswer(int formAnswerId) async {
    try {
      final bool? confirm = await FormDialogs.showDeleteAnswerDialog(context);

      if (confirm != true) return;

      final answerApiService = AnswerApiService();
      await answerApiService.deleteAnswerFromQuestion(
        context,
        formAnswerId,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Respuesta eliminada exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      await _fetchFormDetails();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar la respuesta: $e'),
          duration: const Duration(milliseconds: 1500),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEditAnswerDialog(String currentValue, dynamic answerData) {
    FormDialogs.showEditAnswerDialog(
      context: context,
      currentValue: currentValue,
      onSave: (updatedValue) async {
        try {
          await _answerApiService.updateAnswer(
            context,
            {
              'value': updatedValue,
              'remarks': answerData['remarks'] ?? null,
            },
            answerData['answer']['id'],
          );
          await _fetchFormDetails();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Respuesta actualizada exitosamente'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al actualizar la respuesta: $e'),
              duration: const Duration(milliseconds: 1500),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
    );
  }

  Widget _buildUserSelectionField() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<List<dynamic>>(
        future: _fetchUsers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Text('Error loading users: ${snapshot.error}');
          }

          final users = snapshot.data ?? [];

          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Color.fromARGB(255, 34, 118, 186),
                  ),
                ),
                hint: Text(
                  'Select User',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                items: users.map<DropdownMenuItem<int>>((user) {
                  final firstName = (user['first_name'] ?? '').toString();
                  final lastName = (user['last_name'] ?? '').toString();
                  return DropdownMenuItem<int>(
                    value: user['id'] as int?,
                    child: Text('$firstName $lastName'),
                  );
                }).toList(),
                onChanged: (value) {
                  print('Selected user ID: $value');
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Future<List<dynamic>> _fetchUsers() async {
    try {
      final userApiService = UserApiService();
      final users = await userApiService.fetchUsers(context);
      return users;
    } catch (e) {
      print('Error fetching users: $e');
      return [];
    }
  }
/*
  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return ExportFormDialog(
          onExport: (int signatureCount) async {
            try {
              await _formApiService.exportFormAsPDF(
                context,
                widget.form['id'],
                signatureCount: signatureCount,
                signatureDetails: {},
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('PDF export initiated successfully'),
                  duration: Duration(seconds: 2),
                ),
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error exporting PDF: $e'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        );
      },
    );
  }*/

void _showExportDialog() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return ExportFormDialog(
        onExport: (int signatureCount) async {
          try {
            await _formApiService.exportFormAsPDF(
              context,
              widget.form['id'],
              signatureCount: signatureCount,
              signatureDetails: {
                'signature1_title': 'Prepared by',
                'signature1_name': 'John Doe',
                'signature1_date': 'true',
              },
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al exportar PDF: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
      );
    },
  );
}




  bool _shouldShowAnswerSelection(String questionType) {
    return !['date', 'datetime', 'text', 'user'].contains(questionType);
  }

  Widget _buildQuestionCreationCard(int index) {
    final data = _questionCreations[index];
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(top: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Campo de texto para la pregunta
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: data.questionTextController,
              decoration: const InputDecoration(
                hintText: 'Pregunta sin título',
                border: UnderlineInputBorder(),
                hintStyle: TextStyle(fontSize: 16),
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
          // Selector de tipo de pregunta
          if (isLoadingQuestionTypes)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: DropdownButtonFormField<int>(
                value: data.selectedQuestionTypeId,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                hint: const Text('Seleccionar tipo de pregunta'),
                items: questionTypes.map((type) {
                  final String questionTypeString =
                      (type['type'] ?? '').toString().toLowerCase();

                  IconData icon;
                  switch (questionTypeString) {
                    case 'multiple_choices':
                      icon = Icons.radio_button_checked;
                      break;
                    case 'checkbox':
                      icon = Icons.check_box;
                      break;
                    case 'date':
                      icon = Icons.calendar_today;
                      break;
                    case 'datetime':
                      icon = Icons.access_time;
                      break;
                    case 'text':
                      icon = Icons.short_text;
                      break;
                    case 'user':
                      icon = Icons.person;
                      break;
                    case 'signature':
                      icon = Icons.draw;
                      break;
                    default:
                      icon = Icons.question_answer;
                  }

                  return DropdownMenuItem<int>(
                    value: type['id'] as int?,
                    child: Row(
                      children: [
                        Icon(icon, size: 20, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text((type['type'] ?? '').toString()),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    data.selectedQuestionTypeId = value;
                  });
                },
              ),
            ),
          const SizedBox(height: 16),
          // Barra inferior con switch y botón cancelar
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(8)),
            ),
           /* child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Obligatorio
                Row(
                  children: [
                    const Text('Obligatorio'),
                    Switch(
                      value: data.isRequired,
                      onChanged: (value) {
                        setState(() {
                          data.isRequired = value;
                        });
                      },
                      activeColor: const Color(0xFF673AB7),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _questionCreations.removeAt(index);
                    });
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),*/
          ),
        ],
      ),
    );
  }

  Future<void> _saveAllQuestions() async {
    try {
      // Validar que todas las preguntas tengan texto y tipo
      for (var data in _questionCreations) {
        if (data.questionTextController.text.isEmpty ||
            data.selectedQuestionTypeId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor complete todas las preguntas antes de guardar.'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      final formId = widget.form['id'];
      if (formId == null || formId is! int) {
        throw Exception("El ID del formulario no es válido.");
      }

      int order = (formDetails?['questions']?.length ?? 0) + 1;

      for (var data in _questionCreations) {
        final questionData = {
          'text': data.questionTextController.text,
          'question_type_id': data.selectedQuestionTypeId,
          'is_required': data.isRequired,
          'form_id': formId, // Se agrega form_id si la API lo requiere
        };

        final createdQuestion = await _formQuestionApiService.createQuestion(context, questionData);
        // Asegurar que createdQuestion contenga un 'id' int
        final newQuestionId = createdQuestion['question']['id'] as int;
        if (newQuestionId == null || newQuestionId is! int) {
          // Si no se obtuvo un ID válido, mostramos error
          throw Exception("La pregunta creada no retornó un ID válido.");
        }

        // Asignar la pregunta al formulario
        await _formQuestionApiService.assignQuestionToForm(
          context,
          formId,
          newQuestionId,
          order++,
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Preguntas creadas y asignadas exitosamente'),
          duration: Duration(milliseconds: 500),
        ),
      );

      setState(() {
        _questionCreations.clear();
      });

      await _fetchFormDetails();

    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creando las preguntas: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    for (var data in _questionCreations) {
      data.questionTextController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final formTitle = (formDetails?['title'] ?? widget.form['title'] ?? 'Untitled Form').toString();
    final formDescription = (formDetails?['description'] ?? 'No description').toString();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.ios_share_rounded, color: Colors.grey[700]),
            onPressed: _showExportDialog,
          ),
          if (!isDeleting)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _showDeleteConfirmation,
            ),
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey[700]),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) => FormUpdateDialog(
                  form: formDetails ?? widget.form,
                  refreshForms: _fetchFormDetails,
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: const Color(0xFFF0EBF8),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tarjeta de título del formulario
                     /* Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  formTitle,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  formDescription,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),*/

                      Card(
  elevation: 1,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(8),
  ),
  child: Container(
    width: double.infinity, // Asegura que ocupe todo el ancho
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center, // Centra horizontalmente
        children: [
          Text(
            formTitle,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center, // Centra el texto
          ),
          const SizedBox(height: 8),
          Text(
            formDescription,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center, // Centra el texto (opcional)
          ),
        ],
      ),
    ),
  ),
),
                      const SizedBox(height: 16),

                      (formDetails?['questions'] as List? ?? []).isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No questions available',
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ),
                            )
                          : QuestionsListWidget(
                              questions: formDetails?['questions'] as List? ?? [],
                              deleteFormQuestion: _deleteFormQuestion,
                              showEditAnswerDialog: _showEditAnswerDialog,
                              deleteAnswer: _deleteAnswer,
                              shouldShowAnswerSelection: _shouldShowAnswerSelection,
                              fetchFormDetails: _fetchFormDetails,
                              formId: widget.form['id'],
                            ),

                      // Mostrar todas las cards de creación de pregunta
                      for (int i = 0; i < _questionCreations.length; i++)
                        _buildQuestionCreationCard(i),

                      SizedBox(height: _questionCreations.isNotEmpty ? 80 : 16),
                    ],
                  ),
                ),

                // Botón SAVE si hay preguntas en creación
                if (_questionCreations.isNotEmpty)
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: _saveAllQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF673AB7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('SAVE', style: TextStyle(fontSize: 16)),
                    ),
                  ),
              ],
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Botón de crear pregunta (+)
            FloatingActionButton(
              heroTag: 'add_question',
              onPressed: () {
                setState(() {
                  _questionCreations.add(
                    _QuestionCreationData(
                      questionTextController: TextEditingController(),
                    ),
                  );
                });
              },
              backgroundColor: const Color(0xFF673AB7),
              child: const Icon(Icons.add),
            ),
            const SizedBox(height: 16),
            // Botón de asignar preguntas existentes
            FloatingActionButton(
              heroTag: 'assign_question',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) => QuestionSelectionDialog(
                    refreshQuestions: _fetchFormDetails,
                    formId: widget.form['id'],
                  ),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.assignment,
                color: Color(0xFF673AB7),
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
