import 'package:cmms_app/services/api_model_services/api_form_services/AnswerSubmittedService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart'; // Asegúrate de tener el import

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../screens/modules/form_submission/Components/CustomSignaturePad.dart';
import '../../screens/modules/form_submission/Components/DynamicQuestionInput.dart';
import '../../services/api_model_services/api_form_services/form_submission_service.dart';

class QuestionsAnswerScreen extends StatefulWidget {
  final int formId;
  final String formTitle;
  final String? formDescription;
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const QuestionsAnswerScreen({
    super.key,
    required this.formId,
    required this.formTitle,
    this.formDescription,
    required this.permissionSet,
    required this.sessionData,
  });

  @override
  _QuestionsAnswerScreenState createState() => _QuestionsAnswerScreenState();
}

class _QuestionsAnswerScreenState extends State<QuestionsAnswerScreen> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  final AnswerSubmittedService _answerSubmittedService = AnswerSubmittedService();
  final FormSubmissionService _formSubmissionService = FormSubmissionService();

  bool isLoading = true;
  List<dynamic> forms = [];
  List<dynamic> questions = [];
  Map<int, dynamic> answers = {};
  bool showQuestions = false;
  Map<String, dynamic>? selectedForm;
  List<String> _attachedFiles = [];

  // NUEVO: Lista para almacenar las rutas de los archivos seleccionados


  @override
  void initState() {
    super.initState();
    _fetchForms();
  }

  Future<void> _fetchForms() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
    });

    try {
      final fetchedForms = await _formApiService.fetchForms(context);
      if (mounted) {
        setState(() {
          forms = fetchedForms;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      _showErrorSnackBar('Error fetching forms: $e');
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return DateFormat('dd/MM/yyyy').format(date);
  }

  bool _hasQuestions(Map<String, dynamic> form) {
    final questions = form['questions'] as List? ?? [];
    return questions.isNotEmpty;
  }

  Future<void> _loadFormQuestions(Map<String, dynamic> form) async {
    try {
      setState(() {
        isLoading = true;
        selectedForm = form;
      });

      final formData = await _answerApiService.getFormWithQuestions(
        context,
        form['id'],
      );

      setState(() {
        questions = formData['questions'] ?? [];
        showQuestions = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error loading questions: $e');
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        // Add allowed extensions if needed
        allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx'],
        type: FileType.custom,
      );

      if (result != null) {
        // Validate file sizes
        for (var file in result.files) {
          if (file.size > 10 * 1024 * 1024) { // 10MB limit
            throw Exception('File ${file.name} exceeds 10MB size limit');
          }
        }

        setState(() {
          _attachedFiles = result.paths.whereType<String>().toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildFormCard(Map<String, dynamic> form) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            if (_hasQuestions(form)) {
              _loadFormQuestions(form);
            } else {
              _showErrorSnackBar('This form has no questions available');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  form['title'] ?? 'No Title',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  form['description'] ?? 'No description',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(form['created_at']),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.arrow_forward, color: Colors.blue),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> question) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    question['text'] ?? 'No question text',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (question['is_required'] == true)
                  const Text(
                    '*',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 20,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            _buildAnswerField(question),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerField(Map<String, dynamic> question) {
    final questionType = question['type']?.toString().toLowerCase() ?? '';

    if (questionType == 'signature') {
      return Column(
        children: [
          const CustomSignaturePad(),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () {
              final padState =
              context.findAncestorStateOfType<CustomSignaturePadState>();
              padState?.clear();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear'),
          ),
        ],
      );
    }

    return DynamicQuestionInput(
      question: question,
      currentValue: answers[question['id']],
      onAnswerChanged: (value) {
        setState(() {
          answers[question['id']] = value;
        });
      },
    );
  }

  Future<void> _submitAnswers() async {
    try {
      setState(() {
        isLoading = true;
      });

      // First create the form submission
      final submissionResult = await _formSubmissionService.createFormSubmission(
          context: context,
          formId: selectedForm!['id']
      );

      final int submissionId = submissionResult['submission_id'];
      print('Extracted submission ID: $submissionId');
      print('Current answers: $answers');
      print('Current questions: $questions');

      // Format answers for the API
      List<Map<String, dynamic>> formattedSubmissions = [];

      answers.forEach((questionId, answerValue) {
        Map<String, dynamic>? question = questions.firstWhere(
              (q) => q['id'] == questionId,
          orElse: () => null,
        );

        if (question == null) {
          print('Warning: No question found for ID $questionId');
          return;
        }

        final questionType = question['type']?.toString().toLowerCase() ?? 'text';
        final questionText = question['text']?.toString() ?? 'Unknown Question';

        print('Processing question: $questionText with type: $questionType and value: $answerValue');

        if (questionType == 'multiple_choice' || questionType == 'multiple-choices' || questionType == 'checkbox') {
          // For multiple choice/checkbox, handle multiple selections
          List<dynamic> selectedIds = answerValue is List ? answerValue : [answerValue];

          print('Selected IDs for $questionText: $selectedIds');

          // Get the possible answers from the question
          List<dynamic> possibleAnswers = question['possible_answers'] ?? [];

          // Create a submission for each selected answer
          for (var selectedId in selectedIds) {
            // Find the matching possible answer
            var selectedAnswer = possibleAnswers.firstWhere(
                  (answer) => answer['id'] == selectedId,
              orElse: () => null,
            );

            if (selectedAnswer != null) {
              String answerText = selectedAnswer['value']?.toString() ?? '';
              print('Found answer text: $answerText for ID: $selectedId');

              formattedSubmissions.add({
                'question_text': questionText,
                'question_type_text': questionType,  // Remove the replaceAll
                'answer_text': answerText
              });
            }
          }
        } else {
          // Handle other question types (text, date, etc.)
          formattedSubmissions.add({
            'question_text': questionText,
            'question_type_text': questionType,  // Remove the replaceAll
            'answer_text': answerValue?.toString() ?? ''
          });
        }
      });

      print('Submitting formatted answers: $formattedSubmissions');

      if (formattedSubmissions.isEmpty) {
        throw Exception('No answers to submit');
      }

      // Send the answers to the API
      await _answerSubmittedService.createAnswerSubmitted(
        context,
        submissionId,
        formattedSubmissions,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Form submitted successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      setState(() {
        showQuestions = false;
        selectedForm = null;
        answers.clear();
        _attachedFiles.clear();
        isLoading = false;
      });

    } catch (e, stackTrace) {
      print('Error in _submitAnswers: $e');
      print('Stack trace: $stackTrace');

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  // NUEVO: Botón para adjuntar archivos
  Widget _buildAttachmentButton() {
    return ElevatedButton.icon(
      onPressed: _pickFiles,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: const Icon(Icons.attach_file, color: Colors.white),
      label: const Text(
        'Attach Files',
        style: TextStyle(color: Colors.white),
      ),
    );
  }

  // NUEVO: Lista de archivos adjuntos
  Widget _buildAttachedFilesList() {
    if (_attachedFiles.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attached Files:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        ..._attachedFiles.map(
              (filePath) => ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: Text(filePath.split('/').last),
            subtitle: Text(filePath),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    String appBarTitle = showQuestions
        ? (selectedForm != null ? selectedForm!['title'] : 'Fill Form')
        : 'Available Forms';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: Icon(
                showQuestions ? Icons.arrow_back : Icons.menu,
                color: Colors.black,
              ),
              onPressed: showQuestions
                  ? () {
                setState(() {
                  showQuestions = false;
                  selectedForm = null;
                  answers.clear();
                  _attachedFiles.clear(); // Limpia los archivos si regresas
                });
              }
                  : () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
        title: Text(
          appBarTitle,
          style: const TextStyle(color: Colors.black),
        ),
      ),
      drawer: !showQuestions
          ? DrawerMenu(
        onItemTapped: (index) {
          Navigator.of(context).pop(); // Cierra el drawer
        },
        parentContext: context,
        permissionSet: widget.permissionSet,
        sessionData: widget.sessionData,
      )
          : null,
      body: Container(
        color: const Color(0xFFE3F2FD),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : showQuestions
            ? ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (selectedForm?['description'] != null)
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    selectedForm!['description'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ),

            // NUEVO: Ahora el Attachment Button y la lista se muestran aquí.
            const SizedBox(height: 16),
            _buildAttachmentButton(),
            const SizedBox(height: 16),
            _buildAttachedFilesList(),

            const SizedBox(height: 16),
            ...questions.map((q) => _buildQuestionCard(q)).toList(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _submitAnswers,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Submit Answers',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: forms.length,
          itemBuilder: (context, index) =>
              _buildFormCard(forms[index]),
        ),
      ),
    );
  }
}
