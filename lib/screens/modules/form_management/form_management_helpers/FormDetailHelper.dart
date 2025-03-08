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
import 'QuestionCreationManager.dart';
import 'form_detail_helper/QuestionCreationCard.dart';

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
  List<String> options = [];
  final GlobalKey<QuestionCreationCardState> key = GlobalKey<QuestionCreationCardState>();

  _QuestionCreationData({
    required this.questionTextController,
    this.selectedQuestionTypeId,
    this.isRequired = true,
  });
}

class _FormDetailScreenState extends State<FormDetailHelper> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  final QuestionApiService _formQuestionApiService = QuestionApiService();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<QuestionsListWidgetState> _questionsListWidgetKey =
  GlobalKey<QuestionsListWidgetState>();

  bool isLoading = true;
  bool isDeleting = false;
  bool showMenuButtons = false;
  bool isAnimating = false;

  Map<String, dynamic>? formDetails;

  List<_QuestionCreationData> _questionCreations = [];
  List<dynamic> questionTypes = [];
  bool isLoadingQuestionTypes = true;

  bool _isValidating = false;
  List<bool> _questionCreationValidStates = [];

  // Track if we have any unsaved changes
  bool _hasUnsavedChanges = false;

  // Method to update unsaved changes flag
  void _setUnsavedChanges(bool value) {
    setState(() {
      _hasUnsavedChanges = value;
    });
  }

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

  void _addQuestionCreationCard() {
    setState(() {
      _questionCreations.add(
        _QuestionCreationData(
          questionTextController: TextEditingController(),
          isRequired: true,
        ),
      );
      _questionCreationValidStates.add(false);
    });

    // Mark that we have unsaved changes:
    _setUnsavedChanges(true);

    // Show question type selection immediately
    QuestionCreationManager().showQuestionTypeSelection(
      context,
      questionTypes,
          (typeId) {
        setState(() {
          _questionCreations.last.selectedQuestionTypeId = typeId;
          if (_isValidating) {
            _questionCreationValidStates.last =
                _validateQuestionCreation(_questionCreations.length - 1);
          }
        });
      },
    );

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

  bool _validateQuestionCreation(int index) {
    final data = _questionCreations[index];
    return data.questionTextController.text.isNotEmpty &&
        data.selectedQuestionTypeId != null;
  }

  /// Handles question creation (and can be expanded for other form data saving if needed).
  Future<void> _saveForm() async {
    setState(() {
      _isValidating = true;
    });

    // First, save all answer options for existing questions
    bool optionsSaved = await _questionsListWidgetKey.currentState?.saveAllAnswerOptions() ?? true;

    if (!optionsSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save some answer options'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Validate each newly added question
    for (int i = 0; i < _questionCreations.length; i++) {
      _questionCreationValidStates[i] = _validateQuestionCreation(i);
    }

    bool allValid = _questionCreationValidStates.every((valid) => valid);

    if (!allValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields before saving.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final formId = widget.form['id'];
      if (formId == null || formId is! int) {
        throw Exception("The form ID is not valid.");
      }

      int order = (formDetails?['questions']?.length ?? 0) + 1;

      // Create each question and assign it to the form
      for (var data in _questionCreations) {
        // Get the latest options from the component state if available
        if (data.key.currentState != null) {
          data.options = data.key.currentState!.getCurrentOptions();
        }

        String questionText = data.questionTextController.text;
        // Mark it with '~' if required
        if (data.isRequired && !questionText.endsWith("~")) {
          questionText = "$questionText~";
        }

        final questionData = {
          'text': questionText,
          'question_type_id': data.selectedQuestionTypeId,
          'is_required': data.isRequired,
          'form_id': formId,
        };

        final createdQuestion =
        await _formQuestionApiService.createQuestion(context, questionData);

        final newQuestionId = createdQuestion['question']['id'] as int?;
        if (newQuestionId == null) {
          throw Exception("The created question did not return a valid ID.");
        }

        // Assign question to form
        final assignedQuestion = await _formQuestionApiService.assignQuestionToForm(
          context,
          formId,
          newQuestionId,
          order++,
        );

        // Get the form_question_id from the assigned question
        final formQuestionId = assignedQuestion['form_question']['id'] as int?;
        if (formQuestionId == null) {
          throw Exception("The assigned question did not return a valid form_question_id.");
        }

        // Now create any options/answers for this question
        if (data.options.isNotEmpty) {
          for (String optionText in data.options) {
            if (optionText.trim().isEmpty) continue;

            // First create the answer
            final answerData = {'value': optionText};
            final createdAnswer = await _answerApiService.createAnswer(
              context,
              answerData,
            );

            // Then assign it to the question
            if (createdAnswer['status'] == 200 || createdAnswer['status'] == 201) {
              final int answerId = createdAnswer['answer']['id'];
              await _answerApiService.assignAnswerToQuestion(
                context,
                formQuestionId,
                answerId,
              );
            }
          }
        }
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form saved successfully'),
          duration: Duration(seconds: 1),
        ),
      );

      // Clear out local state, re-fetch form details
      setState(() {
        _questionCreations.clear();
        _questionCreationValidStates.clear();
        _isValidating = false;
        _hasUnsavedChanges = false; // Reset the flag
      });

      await _fetchFormDetails();
    } catch (e) {
      print('Error saving form: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving form: $e'),
          duration: const Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isValidating = false;
      });
    }
  }

  Widget _buildQuestionCreationCard(int index) {
    final data = _questionCreations[index];
    return QuestionCreationCard(
      key: data.key,
      questionTextController: data.questionTextController,
      selectedQuestionTypeId: data.selectedQuestionTypeId,
      isRequired: data.isRequired,
      isLoadingQuestionTypes: isLoadingQuestionTypes,
      questionTypes: questionTypes,
      showValidationError: _isValidating && !_questionCreationValidStates[index],
      // Using negative IDs as placeholders for new questions
      questionId: -1 * (index + 1),
      onCancel: () {
        setState(() {
          _questionCreations.removeAt(index);
          _questionCreationValidStates.removeAt(index);
        });
        // Potentially set unsaved changes here too; if everything is removed, you could reset.
        if (_questionCreations.isEmpty) {
          _setUnsavedChanges(false);
        } else {
          _setUnsavedChanges(true);
        }
      },
      onTypeChanged: (value) {
        setState(() {
          data.selectedQuestionTypeId = value;
          if (_isValidating) {
            _questionCreationValidStates[index] = _validateQuestionCreation(index);
          }
        });
        _setUnsavedChanges(true);
      },
      onRequiredChanged: (value) {
        setState(() {
          data.isRequired = value;
        });
        _setUnsavedChanges(true);
      },
      setUnsavedChanges: _setUnsavedChanges,
      onOptionsChanged: (options) {
        // Store the options in our data object
        data.options = options;
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
                                    color:
                                    Color.fromARGB(255, 1, 116, 209),
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

                        // Existing questions
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
                            key: _questionsListWidgetKey,
                            questions: formDetails?['questions'] as List? ?? [],
                            deleteFormQuestion: _deleteFormQuestion,
                            showEditAnswerDialog: _showEditAnswerDialog,
                            deleteAnswer: _deleteAnswer,
                            shouldShowAnswerSelection: _shouldShowAnswerSelection,
                            fetchFormDetails: _fetchFormDetails,
                            formId: widget.form['id'],
                            setUnsavedChanges: _setUnsavedChanges, // Pass the function here
                          ),

                        // Render the new question creation cards (if any)
                        for (int i = 0;
                        i < _questionCreations.length;
                        i++)
                          _buildQuestionCreationCard(i),
                      ],
                    ),
                  ),
                ),
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
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

            // Show the Save button if there are unsaved new questions OR if unsaved changes exist
            if (_questionCreations.isNotEmpty || _hasUnsavedChanges)
              Positioned(
                bottom: 20,
                left: 0,
                right: 80,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _saveForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 23, 99, 161),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 20,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.save,
                            color: Colors.white,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
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

  // Handle delete form question
  void _deleteFormQuestion(BuildContext context, int formQuestionId) async {
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

      final result = await _formQuestionApiService.deleteQuestionFromForm(
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

  // Handle show edit answer dialog
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

  // Handle delete answer
  Future<void> _deleteAnswer(int formAnswerId) async {
    try {
      final bool? confirm = await FormDialogs.showDeleteAnswerDialog(context);

      if (confirm != true) return;

      await _answerApiService.deleteAnswerFromQuestion(
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

  // Check if answer selection should be shown
  bool _shouldShowAnswerSelection(String questionType) {
    return !['date', 'datetime', 'text', 'user']
        .contains(questionType.toLowerCase());
  }

  // Handle show delete confirmation
  void _showDeleteConfirmation() async {
    final confirm = await FormDialogs.showDeleteConfirmationDialog(context);
    if (confirm == true) {
      _deleteForm();
    }
  }

  // Handle delete form
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

  // Handle show export dialog
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
}