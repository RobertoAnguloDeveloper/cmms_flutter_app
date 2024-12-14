import 'package:cmms_app/screens/modules/form_management/form_management_helpers/form_detail_helper/QuestionCreationCard.dart';
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
  bool showMenuButtons = false;
  bool isAnimating = false;
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
          backgroundColor: const Color.fromARGB(255, 139, 54, 244),
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
  return QuestionCreationCard(
    questionTextController: data.questionTextController,
    selectedQuestionTypeId: data.selectedQuestionTypeId,
    isRequired: data.isRequired,
    isLoadingQuestionTypes: isLoadingQuestionTypes,
    questionTypes: questionTypes,
    onCancel: () {
      setState(() {
        _questionCreations.removeAt(index);
      });
    },
    onTypeChanged: (value) {
      setState(() {
        data.selectedQuestionTypeId = value;
      });
    },
    onRequiredChanged: (value) {
      setState(() {
        data.isRequired = value;
      });
    },
  );
}


  Future<void> _saveAllQuestions() async {
    try {
      for (var data in _questionCreations) {
        if (data.questionTextController.text.isEmpty ||
            data.selectedQuestionTypeId == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Por favor complete todas las preguntas antes de guardar.'),
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

        final createdQuestion =
            await _formQuestionApiService.createQuestion(context, questionData);
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
    final formTitle =
        (formDetails?['title'] ?? widget.form['title'] ?? 'Untitled Form')
            .toString();
    final formDescription =
        (formDetails?['description'] ?? 'No description').toString();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[700]),
          onPressed: () => Navigator.pop(context, true),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFE3F2FD),
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Contenedor principal del formulario
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tarjeta de título del formulario
                            Center(
                              child: Card(
                                elevation: 1,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      16), // Bordes redondeados de la tarjeta
                                ),
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.9,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: const Border(
                                      top: BorderSide(
                                        color: Color.fromARGB(255, 1, 116, 209),
                                        width: 8.0,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                      Positioned(
                                        top: 16,
                                        right: 16,
                                        child: IconButton(
                                          icon: const Icon(Icons.edit),
                                          color: Colors.grey[700],
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (BuildContext context) =>
                                                  FormUpdateDialog(
                                                form:
                                                    formDetails ?? widget.form,
                                                refreshForms: _fetchFormDetails,
                                              ),
                                            );
                                          },
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
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.grey),
                                      ),
                                    ),
                                  )
                                : QuestionsListWidget(
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

                            // Mostrar todas las cards de creación de pregunta
                            for (int i = 0; i < _questionCreations.length; i++)
                              _buildQuestionCreationCard(i),

                            SizedBox(
                                height:
                                    _questionCreations.isNotEmpty ? 80 : 16),
                          ],
                        ),
                      ),
              ),
              // Contenedor para botones flotantes
              // Contenedor para botones flotantes
              Container(
                width: 80,
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Botón para añadir preguntas
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
                      backgroundColor: const Color.fromARGB(255, 34, 118, 186),
                      child: const Icon(
                        Icons.add,
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botón para asignar preguntas
                    FloatingActionButton(
                      heroTag: 'assign_question',
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) =>
                              QuestionSelectionDialog(
                            refreshQuestions: _fetchFormDetails,
                            formId: widget.form['id'],
                          ),
                        );
                      },
                      backgroundColor: Colors.white,
                      child: const Icon(
                        Icons.assignment,
                        color: Color.fromARGB(255, 34, 118, 186),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Botón del menú
                    FloatingActionButton(
                      heroTag: 'menu_button',
                      onPressed: isAnimating
                          ? null // Deshabilita el botón mientras se anima
                          : () {
                              setState(() {
                                isAnimating = true; // Comienza la animación
                                showMenuButtons = !showMenuButtons;
                              });

                              // Marca la animación como completada después de su duración
                              Future.delayed(const Duration(milliseconds: 300),
                                  () {
                                setState(() {
                                  isAnimating =
                                      false; // Permite volver a presionar el botón
                                });
                              });
                            },
                      backgroundColor: Colors.white,
                      shape:
                          const CircleBorder(), // Asegura que el botón sea perfectamente circular
                      child: AnimatedRotation(
                        turns:
                            showMenuButtons ? 0.5 : 0, // Rotación de la flecha
                        duration: const Duration(
                            milliseconds: 300), // Duración de la animación
                        curve: Curves.easeInOut, // Curva de la animación
                        child: const Icon(
                          Icons.keyboard_arrow_down, // Icono de flecha
                          size:
                              28, // Tamaño del ícono más pequeño para ajustarse al botón
                          color: Color.fromARGB(255, 34, 118, 186),
                        ),
                      ),
                      mini:
                          true, // Hace que el botón sea más pequeño y compacto
                    ),

                    // Animación para mostrar/ocultar botones adicionales
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      switchInCurve: Curves.easeInOut,
                      switchOutCurve: Curves.easeInOut,
                      child: showMenuButtons
                          ? Column(
                              key: const ValueKey("buttonsVisible"),
                              children: [
                                const SizedBox(height: 16),
                                FloatingActionButton(
                                  heroTag: 'delete_form',
                                  onPressed: _showDeleteConfirmation,
                                  backgroundColor: Colors.red,
                                  child: const Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                FloatingActionButton(
                                  heroTag: 'export_form',
                                  onPressed: _showExportDialog,
                                  backgroundColor:
                                      const Color.fromARGB(255, 74, 180, 246),
                                  child: const Icon(
                                    Icons.ios_share_rounded,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              )
            ],
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
