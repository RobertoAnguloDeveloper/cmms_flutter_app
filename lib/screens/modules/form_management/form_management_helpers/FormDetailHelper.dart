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

// Updated to default isRequired = true
class _QuestionCreationData {
  TextEditingController questionTextController;
  int? selectedQuestionTypeId;
  bool isRequired;

  _QuestionCreationData({
    required this.questionTextController,
    this.selectedQuestionTypeId,
    this.isRequired = true, // <-- Changed default to true
  });
}

class _FormDetailScreenState extends State<FormDetailHelper> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  final QuestionApiService _formQuestionApiService = QuestionApiService();
  final ScrollController _scrollController = ScrollController();

  bool isLoading = true;
  bool isDeleting = false;
  bool showMenuButtons = false;
  bool isAnimating = false;

  Map<String, dynamic>? formDetails;

  // List of new questions being created
  List<_QuestionCreationData> _questionCreations = [];
  List<dynamic> questionTypes = [];
  bool isLoadingQuestionTypes = true;

  // Validation fields
  bool _isValidating = false;
  List<bool> _questionCreationValidStates = [];

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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Question successfully deleted'),
            duration: Duration(milliseconds: 1500),
          ),
        );
        await _fetchFormDetails();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['error'] ?? 'Error deleting the question'),
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
          content: Text('Response deleted successfully'),
          duration: Duration(milliseconds: 500),
        ),
      );

      await _fetchFormDetails();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting the response: $e'),
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
              content: Text('Response updated successfully'),
              duration: Duration(milliseconds: 1500),
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating the response: $e'),
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

  // ----------------------------- NEW/UPDATED CODE BELOW -----------------------------

  // This method checks if question text and question type are both valid
  bool _validateQuestionCreation(int index) {
    final data = _questionCreations[index];
    return data.questionTextController.text.isNotEmpty &&
        data.selectedQuestionTypeId != null;
  }

  // Updated to default isRequired = true
  void _addQuestionCreationCard() {
    setState(() {
      _questionCreations.add(
        _QuestionCreationData(
          questionTextController: TextEditingController(),
          isRequired: true, // <-- ensure new questions default to required
        ),
      );
      // Add a corresponding validation state
      _questionCreationValidStates.add(false);
    });

    // Scroll to the bottom to show the new card
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Validates and then saves all new questions
  Future<void> _saveAllQuestions() async {
    setState(() {
      _isValidating = true;
    });

    // Update validation states for all new questions
    for (int i = 0; i < _questionCreations.length; i++) {
      _questionCreationValidStates[i] = _validateQuestionCreation(i);
    }

    // Check if any question is invalid
    bool allValid = _questionCreationValidStates.every((valid) => valid);

    if (!allValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields before saving.'),
          duration: Duration(seconds: 2),
        ),
      );
      setState(() {
        _isValidating = true;
      });
      return;
    }

    try {
      final formId = widget.form['id'];
      if (formId == null || formId is! int) {
        throw Exception("The form ID is not valid.");
      }

      int order = (formDetails?['questions']?.length ?? 0) + 1;

      // Create each new question, then assign it to the form
      for (var data in _questionCreations) {
        // Append "~" to the question text if the question is marked as required
        String questionText = data.questionTextController.text;
        if (data.isRequired && !questionText.endsWith("~")) {
          questionText = "$questionText~";
        }

        final questionData = {
          'text': questionText, // Use the modified question text
          'question_type_id': data.selectedQuestionTypeId,
          'is_required': data.isRequired, // keep the user's required value
          'form_id': formId,
        };

        final createdQuestion =
        await _formQuestionApiService.createQuestion(context, questionData);

        final newQuestionId = createdQuestion['question']['id'] as int;
        if (newQuestionId == null || newQuestionId is! int) {
          throw Exception("The created question did not return a valid ID.");
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
          content: Text('Questions created and assigned successfully'),
          duration: Duration(milliseconds: 500),
        ),
      );

      setState(() {
        _questionCreations.clear();
        _questionCreationValidStates.clear();
        _isValidating = false;
      });

      await _fetchFormDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating the questions: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
      setState(() {
        _isValidating = false;
      });
    }
  }

  // Builds each QuestionCreationCard for dynamic question creation
  Widget _buildQuestionCreationCard(int index) {
    final data = _questionCreations[index];
    return QuestionCreationCard(
      questionTextController: data.questionTextController,
      selectedQuestionTypeId: data.selectedQuestionTypeId,
      isRequired: data.isRequired,
      isLoadingQuestionTypes: isLoadingQuestionTypes,
      questionTypes: questionTypes,
      showValidationError: _isValidating && !_questionCreationValidStates[index],
      onCancel: () {
        setState(() {
          _questionCreations.removeAt(index);
          _questionCreationValidStates.removeAt(index);
        });
      },
      onTypeChanged: (value) {
        setState(() {
          data.selectedQuestionTypeId = value;
          if (_isValidating) {
            _questionCreationValidStates[index] = _validateQuestionCreation(index);
          }
        });
      },
      onRequiredChanged: (value) {
        setState(() {
          data.isRequired = value;
        });
      },
    );
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
      body: OrientationBuilder(builder: (context, orientation) {
        return Stack(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main container for the form
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: 8.0,
                      bottom: 100.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Form title card
                        Center(
                          child: Card(
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
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
                                          builder:
                                              (BuildContext context) =>
                                              FormUpdateDialog(
                                                form: formDetails ??
                                                    widget.form,
                                                refreshForms:
                                                _fetchFormDetails,
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

                        // Questions list
                        if ((formDetails?['questions'] as List? ?? [])
                            .isEmpty)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text(
                                'No questions available',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.grey),
                              ),
                            ),
                          )
                        else
                          QuestionsListWidget(
                            questions:
                            formDetails?['questions'] as List? ?? [],
                            deleteFormQuestion: _deleteFormQuestion,
                            showEditAnswerDialog: _showEditAnswerDialog,
                            deleteAnswer: _deleteAnswer,
                            shouldShowAnswerSelection:
                            _shouldShowAnswerSelection,
                            fetchFormDetails: _fetchFormDetails,
                            formId: widget.form['id'],
                          ),

                        // Show all dynamic question creation cards
                        for (int i = 0; i < _questionCreations.length; i++)
                          _buildQuestionCreationCard(i),
                      ],
                    ),
                  ),
                ),
                // Container for the floating buttons on the right
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // Add new question
                      FloatingActionButton(
                        heroTag: 'add_question',
                        onPressed: () {
                          _addQuestionCreationCard();
                        },
                        backgroundColor:
                        const Color.fromARGB(255, 34, 118, 186),
                        child: const Icon(
                          Icons.add,
                          size: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Assign existing question
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

                      if (orientation == Orientation.portrait)
                        FloatingActionButton(
                          heroTag: 'menu_button',
                          onPressed: isAnimating
                              ? null
                              : () {
                            setState(() {
                              isAnimating = true;
                              showMenuButtons = !showMenuButtons;
                            });

                            Future.delayed(
                                const Duration(milliseconds: 300), () {
                              setState(() {
                                isAnimating = false;
                              });
                            });
                          },
                          backgroundColor: Colors.white,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Menu',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color.fromARGB(255, 34, 118, 186),
                                ),
                              ),
                              AnimatedRotation(
                                turns: showMenuButtons ? 0.5 : 0,
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                child: const Icon(
                                  Icons.keyboard_arrow_down,
                                  size: 24,
                                  color: Color.fromARGB(255, 34, 118, 186),
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (showMenuButtons ||
                          orientation == Orientation.landscape)
                        Column(
                          children: [
                            const SizedBox(height: 8),
                            FloatingActionButton(
                              heroTag: 'delete_form',
                              onPressed: _showDeleteConfirmation,
                              backgroundColor: Colors.red,
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                        ),
                    ],
                  ),
                )
              ],
            ),
            // "Save" button for new questions
            if (_questionCreations.isNotEmpty)
              Positioned(
                bottom: 20,
                left: 0,
                right: 80,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _saveAllQuestions,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color.fromARGB(255, 23, 99, 161),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.save,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Save',
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
