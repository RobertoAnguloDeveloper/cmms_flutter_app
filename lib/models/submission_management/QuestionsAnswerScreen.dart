import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cmms_app/services/api_model_services/api_form_services/AnswerSubmittedService.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../services/api_model_services/api_form_services/AttachmentService.dart';
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
    Key? key,
    required this.formId,
    required this.formTitle,
    this.formDescription,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _QuestionsAnswerScreenState createState() => _QuestionsAnswerScreenState();
}

class _QuestionsAnswerScreenState extends State<QuestionsAnswerScreen> {
  final FormApiService _formApiService = FormApiService();
  final AnswerApiService _answerApiService = AnswerApiService();
  final AnswerSubmittedService _answerSubmittedService = AnswerSubmittedService();
  final FormSubmissionService _formSubmissionService = FormSubmissionService();
  final AttachmentService _attachmentService = AttachmentService();

  bool isLoading = true;
  List<dynamic> forms = [];
  List<dynamic> questions = [];
  Map<int, dynamic> answers = {};
  bool showQuestions = false;
  Map<String, dynamic>? selectedForm;
  List<String> _attachedFiles = [];
  bool _isUploadingFiles = false;
  int _totalFiles = 0;
  int _uploadedFiles = 0;

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

  Future<void> _loadExistingAttachments(int submissionId) async {
    try {
      final result = await _attachmentService.fetchAttachments(
        context,
        filters: {'form_submission_id': submissionId},
      );

      final attachments = result['attachments'] as List;
      // Handle the attachments as needed
      setState(() {
        // Update UI with existing attachments if needed
      });
    } catch (e) {
      print('Error loading attachments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading attachments: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg', 'gif', 'doc', 'docx', 'xls', 'xlsx', 'txt'],
        type: FileType.custom,
      );

      if (result != null) {
        bool hasInvalidFiles = false;
        List<String> validFiles = [];

        for (var file in result.files) {
          if (file.path != null) {
            final fileToCheck = File(file.path!);

            // Basic validation
            if (fileToCheck.lengthSync() > 16 * 1024 * 1024) { // 16MB limit
              hasInvalidFiles = true;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${file.name}: File size exceeds 16MB limit'),
                  backgroundColor: Colors.orange,
                ),
              );
              continue;
            }

            // If validation passes, add to valid files
            validFiles.add(file.path!);
          }
        }

        setState(() {
          _attachedFiles.addAll(validFiles);
        });

        if (hasInvalidFiles) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Some files were not added due to validation errors'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error picking files: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Colors.red,
        ),
      );
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

  Future<void> _submitAnswers() async {
    try {
      setState(() {
        isLoading = true;
      });

      final submissionResult = await _formSubmissionService.createFormSubmission(
        context: context,
        formId: selectedForm!['id'],
      );

      final int submissionId = submissionResult['submission_id'];
      print('Extracted submission ID: $submissionId');

      if (_attachedFiles.isNotEmpty) {
        setState(() {
          _isUploadingFiles = true;
          _totalFiles = _attachedFiles.length;
          _uploadedFiles = 0;
        });

        final failedUploads = <String>[];
        final filesData = _attachedFiles.map((filePath) => {
          'file': File(filePath),
          'is_signature': false,
        }).toList();

        try {
          if (filesData.length > 1) {
            final uploadResponse = await _attachmentService.bulkCreateAttachments(
              context,
              submissionId,
              filesData,
            );

            if (uploadResponse['attachments'] != null) {
              setState(() {
                _uploadedFiles = _totalFiles;
              });
            }
          } else {
            for (var filePath in _attachedFiles) {
              try {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Uploading ${path.basename(filePath)}...'),
                    duration: const Duration(seconds: 1),
                  ),
                );

                final uploadResponse = await _attachmentService.createAttachment(
                  context,
                  submissionId,
                  File(filePath),
                  false,
                );

                if (uploadResponse['attachment'] != null) {
                  setState(() {
                    _uploadedFiles++;
                  });
                } else {
                  throw Exception('Invalid server response');
                }
              } catch (e) {
                failedUploads.add(path.basename(filePath));
              }
            }
          }

          if (failedUploads.isNotEmpty) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to upload: ${failedUploads.join(", ")}'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        } catch (e) {
          print('Error uploading files: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error uploading files: $e'),
              backgroundColor: Colors.red,
            ),
          );
        } finally {
          setState(() {
            _isUploadingFiles = false;
          });
        }
      }

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

        if (questionType.contains('multiple_choice') ||
            questionType.contains('checkbox')) {
          List<dynamic> selectedIds = (answerValue is List) ? answerValue : [answerValue];
          List<dynamic> possibleAnswers = question['possible_answers'] ?? [];

          for (var selectedId in selectedIds) {
            var selectedAnswer = possibleAnswers.firstWhere(
                  (answer) => answer['id'] == selectedId,
              orElse: () => null,
            );

            if (selectedAnswer != null) {
              String answerText = selectedAnswer['value']?.toString() ?? '';
              formattedSubmissions.add({
                'question_text': questionText,
                'question_type_text': questionType,
                'answer_text': answerText
              });
            }
          }
        } else {
          formattedSubmissions.add({
            'question_text': questionText,
            'question_type_text': questionType,
            'answer_text': answerValue?.toString() ?? ''
          });
        }
      });

      if (formattedSubmissions.isEmpty) {
        throw Exception('No answers to submit');
      }

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
        _isUploadingFiles = false;
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
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
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

  Widget _buildAttachedFilesList() {
    if (_attachedFiles.isEmpty) {
      return const SizedBox();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attached Files:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        ..._attachedFiles.map(
              (filePath) => Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: const Icon(Icons.insert_drive_file),
              title: Text(
                filePath.split('/').last,
                style: const TextStyle(fontSize: 14),
              ),
              subtitle: Text(
                'Size: ${_getFileSize(filePath)}',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _attachedFiles.remove(filePath);
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _getFileSize(String filePath) {
    final file = File(filePath);
    try {
      final bytes = file.lengthSync();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } catch (e) {
      return 'Unknown size';
    }
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
                  _attachedFiles.clear();
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
          Navigator.of(context).pop();
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
            const SizedBox(height: 16),
            _buildAttachmentButton(),
            const SizedBox(height: 16),
            _buildAttachedFilesList(),
            const SizedBox(height: 16),
            ...questions.map((q) => _buildQuestionCard(q)).toList(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: (isLoading || _isUploadingFiles)
                  ? null
                  : _submitAnswers,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isUploadingFiles
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white),
                      strokeWidth: 2,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Uploading $_uploadedFiles of $_totalFiles',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              )
                  : const Text(
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