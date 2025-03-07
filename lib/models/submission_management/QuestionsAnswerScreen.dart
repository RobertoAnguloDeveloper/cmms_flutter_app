import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../services/api_model_services/api_form_services/AnswerSubmittedService.dart';
import '../../../services/api_model_services/api_form_services/AttachmentService.dart';
import '../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../../services/api_model_services/api_form_services/form_submission_service.dart';
import '../../screens/modules/form_submission/Components/CustomSignaturePad.dart';
import '../../screens/modules/form_submission/Components/DynamicQuestionInput.dart';

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
  final ImagePicker _imagePicker = ImagePicker();

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
  bool _isTakingPhoto = false;
  bool _canSubmitForm = false;
  Map<int, bool> _questionValidityMap = {};
  bool _validatingForm = false;
  bool _cameraErrorDetected = false;
  Map<String, Map<String, dynamic>> signatureFiles = {};

  @override
  void initState() {
    super.initState();
    _fetchForms();
    _checkCameraPermission();

    // Validate form completion whenever the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateFormSubmission();
    });
  }

  Future<void> _checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      setState(() {
        _cameraErrorDetected = status != PermissionStatus.granted;
      });

      if (status != PermissionStatus.granted) {
        print('Camera permission not granted: $status');
      }
    } catch (e) {
      print('Error checking camera permission: $e');
      setState(() {
        _cameraErrorDetected = true;
      });
    }
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

  // Comprehensive validation method that checks all required questions
  void _validateFormSubmission() {
    if (questions.isEmpty) {
      setState(() => _canSubmitForm = false);
      return;
    }

    bool hasUnansweredRequired = false;
    _questionValidityMap.clear();

    for (var question in questions) {
      final bool isRequired = question['is_required'] ?? false;
      final bool isRequiredByTilde = question['text'].toString().endsWith('~');
      final int questionId = question['id'];
      final String questionType = question['type']?.toString().toLowerCase() ?? '';

      // Consider a question required if it has the is_required flag OR ends with tilde
      final bool questionIsRequired = isRequired || isRequiredByTilde;

      // Check if the question is answered based on its type
      bool isAnswered = false;

      if (answers.containsKey(questionId)) {
        dynamic answer = answers[questionId];

        if (answer is String) {
          isAnswered = answer.trim().isNotEmpty;
        } else if (answer is List) {
          isAnswered = answer.isNotEmpty;
        } else if (answer is File) {
          isAnswered = true; // File exists
        } else if (answer is bool) {
          isAnswered = true; // Boolean value exists
        } else if (answer != null) {
          isAnswered = true; // Any non-null value
        }

        // Special validation for date/time and signature fields
        if (questionType == 'date' || questionType == 'datetime') {
          isAnswered = answer != null && answer.toString().isNotEmpty;
        } else if (questionType == 'signature') {
          isAnswered = signatureFiles.containsKey(questionId.toString());
        }
      }

      // Update validity map and check if any required question is unanswered
      if (questionIsRequired && !isAnswered) {
        hasUnansweredRequired = true;
        _questionValidityMap[questionId] = false;
      } else {
        _questionValidityMap[questionId] = true;
      }
    }

    // Update form submission state
    setState(() {
      _canSubmitForm = !hasUnansweredRequired;
      _validatingForm = true;
    });
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
        _canSubmitForm = false;
        _questionValidityMap = {};
        _validatingForm = false;

        // Initialize validation state for each question
        for (var question in questions) {
          final int questionId = question['id'];
          final bool isRequired = question['is_required'] ?? false;
          final bool isRequiredByTilde = question['text'].toString().endsWith('~');

          if (isRequired || isRequiredByTilde) {
            _questionValidityMap[questionId] = false;
          } else {
            _questionValidityMap[questionId] = true;
          }
        }
      });

      // Validate after loading questions
      _validateFormSubmission();
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error loading questions: $e');
    }
  }

  Future<void> _submitAnswers() async {
    try {
      // Final validation before submitting
      _validateFormSubmission();

      if (!_canSubmitForm) {
        _showErrorSnackBar('Please complete all required questions');
        return;
      }

      setState(() {
        isLoading = true;
      });

      final submissionResult = await _formSubmissionService.createFormSubmission(
        context: context,
        formId: selectedForm!['id'],
      );

      final int submissionId = submissionResult['submission_id'];
      print('Extracted submission ID: $submissionId');

      // Upload signatures
      if (signatureFiles.isNotEmpty) {
        final attachmentService = AttachmentService();

        for (var entry in signatureFiles.entries) {
          final questionId = int.parse(entry.key);
          final signatureData = entry.value;

          final filePath = signatureData['path'] as String;
          final signatureAuthor = signatureData['author'] as String?;
          final signaturePosition =
          (signatureData['position'] != null &&
              (signatureData['position'] as String).isNotEmpty)
              ? signatureData['position']
              : 'Form Signature';

          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Uploading signature: ${path.basename(filePath)}...',
                ),
                duration: const Duration(seconds: 1),
              ),
            );

            await attachmentService.createAttachment(
              context,
              submissionId,
              File(filePath),
              true, // isSignature
              signatureAuthor: signatureAuthor,
              signaturePosition: signaturePosition,
            );

            setState(() {
              _uploadedFiles++;
            });
          } catch (e) {
            print('Error uploading signature: $e');
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Failed to upload signature: ${path.basename(filePath)}',
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }

      // Upload attachments
      if (_attachedFiles.isNotEmpty) {
        setState(() {
          _isUploadingFiles = true;
          _totalFiles = _attachedFiles.length;
          _uploadedFiles = 0;
        });

        final failedUploads = <String>[];

        for (var filePath in _attachedFiles) {
          try {
            final fileExt = path.extension(filePath).toLowerCase();
            final isSignature = filePath.contains("signature_");

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
              isSignature,
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

        setState(() {
          _isUploadingFiles = false;
        });
      }

      // Format answers for submission
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

        // Remove the tilde from the question text before submission
        String questionText = question['text']?.toString() ?? 'Unknown Question';
        if (questionText.endsWith('~')) {
          questionText = questionText.substring(0, questionText.length - 1);
        }

        // Handle multiple choice/checkbox
        if (questionType.contains('multiple_choice') ||
            questionType.contains('checkbox')) {
          List<dynamic> selectedIds =
          (answerValue is List) ? answerValue : [answerValue];
          List<dynamic> possibleAnswers = question['possible_answers'] ?? [];

          for (var selectedId in selectedIds) {
            var selectedAnswer = possibleAnswers.firstWhere(
                  (ans) => ans['id'] == selectedId,
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
          // Handle simple fields
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

      // Reset state
      setState(() {
        showQuestions = false;
        selectedForm = null;
        answers.clear();
        _attachedFiles.clear();
        signatureFiles.clear();
        isLoading = false;
        _canSubmitForm = false;
        _questionValidityMap = {};
        _validatingForm = false;
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
        elevation: 2,
        color: Colors.white,
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
    final int questionId = question['id'];
    final bool isRequired = question['is_required'] ?? false;
    final bool isRequiredByTilde = question['text'].toString().endsWith('~');
    final bool questionIsRequired = isRequired || isRequiredByTilde;

    // Display question text without the tilde
    String displayText = question['text'] ?? 'No question text';
    if (isRequiredByTilde && displayText.endsWith('~')) {
      displayText = displayText.substring(0, displayText.length - 1);
    }

    final bool isInvalid = _validatingForm &&
        _questionValidityMap.containsKey(questionId) &&
        !_questionValidityMap[questionId]!;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      color: isInvalid ? Colors.red[50] : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isInvalid
            ? const BorderSide(color: Colors.red, width: 1.0)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          displayText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (questionIsRequired)
                        const Text(
                          ' *',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (isInvalid)
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: Text(
                  'This question is required',
                  style: TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 8),
            _buildAnswerField(question),
          ],
        ),
      ),
    );
  }

  Widget _buildAnswerField(Map<String, dynamic> question) {
    final questionType = question['type']?.toString().toLowerCase() ?? '';
    final int questionId = question['id'];

    // Signature field
    if (questionType == 'signature') {
      return CustomSignaturePad(
        onSignatureCaptured: (file, {String? author, String? position}) {
          if (file != null) {
            setState(() {
              answers[questionId] = file.path;
              signatureFiles[questionId.toString()] = {
                'path': file.path,
                'author': author ?? widget.sessionData['fullname'] ?? '',
                'position': (position != null && position.isNotEmpty)
                    ? position
                    : 'Form Signature'
              };
              // Validate form after signing
              _validateFormSubmission();
            });
          } else {
            setState(() {
              if (answers.containsKey(questionId)) {
                answers.remove(questionId);
                signatureFiles.remove(questionId.toString());
                // Validate form after removing signature
                _validateFormSubmission();
              }
            });
          }
        },
      );
    }

    // Other question types
    return DynamicQuestionInput(
      question: question,
      currentValue: answers[questionId],
      onAnswerChanged: (value) {
        setState(() {
          if (value == null || (value is String && value.isEmpty)) {
            answers.remove(questionId);
          } else {
            answers[questionId] = value;
          }
          // Validate form on every answer change
          _validateFormSubmission();
        });
      },
    );
  }

  Widget _buildAttachmentButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.attach_file, color: Colors.white),
                label: const Text(
                  'Attach Files',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isTakingPhoto ? null : _takePhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isTakingPhoto
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2,
                  ),
                )
                    : const Icon(Icons.camera_alt, color: Colors.white),
                label: Text(
                  _isTakingPhoto ? 'Processing...' : 'Take Photo',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        if (_cameraErrorDetected)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Having trouble with the camera? You can attach photos from your gallery instead.',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Future<void> _pickFiles() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowedExtensions: [
          'pdf',
          'png',
          'jpg',
          'jpeg',
          'gif',
          'doc',
          'docx',
          'xls',
          'xlsx',
          'txt'
        ],
        type: FileType.custom,
      );

      if (result != null) {
        bool hasInvalidFiles = false;
        List<String> validFiles = [];

        for (var file in result.files) {
          if (file.path != null) {
            final fileToCheck = File(file.path!);

            if (fileToCheck.lengthSync() > 16 * 1024 * 1024) {
              hasInvalidFiles = true;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${file.name}: File size exceeds 16MB limit'),
                  backgroundColor: Colors.orange,
                ),
              );
              continue;
            }

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

  Future<void> _takePhoto() async {
    setState(() {
      _isTakingPhoto = true;
    });

    try {
      final PermissionStatus cameraPermission = await Permission.camera.request();

      if (cameraPermission != PermissionStatus.granted) {
        throw Exception('Camera permission not granted');
      }

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo != null) {
        setState(() {
          _attachedFiles.add(photo.path);
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo added to attachments'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        }
      }
    } catch (e) {
      print('Camera error: $e');

      if (mounted) {
        setState(() {
          _cameraErrorDetected = true;
        });

        String errorMessage = 'Error taking photo';

        if (e.toString().contains('channel-error')) {
          errorMessage =
          'Camera connection failed. Please try again or use file attachment instead.';
        } else if (e.toString().contains('permission')) {
          errorMessage =
          'Camera permission denied. Please enable camera access in settings.';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTakingPhoto = false;
        });
      }
    }
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
              (filePath) {
            final fileName = filePath.split('/').last;
            final isImage = ['.jpg', '.jpeg', '.png', '.gif']
                .any((ext) => fileName.toLowerCase().endsWith(ext));

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: isImage
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.file(
                    File(filePath),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.broken_image, color: Colors.red);
                    },
                  ),
                )
                    : const Icon(Icons.insert_drive_file),
                title: Text(
                  fileName,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  'Size: ${_getFileSize(filePath)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isImage)
                      IconButton(
                        icon: const Icon(Icons.preview),
                        onPressed: () => _previewImage(filePath),
                        tooltip: 'Preview',
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          _attachedFiles.remove(filePath);
                        });
                      },
                      tooltip: 'Remove',
                    ),
                  ],
                ),
              ),
            );
          },
        ).toList(),
      ],
    );
  }

  void _previewImage(String imagePath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                title: Text(
                  imagePath.split('/').last,
                  style: const TextStyle(fontSize: 16),
                ),
                backgroundColor: Colors.black,
                elevation: 0,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Flexible(
                child: InteractiveViewer(
                  panEnabled: true,
                  boundaryMargin: const EdgeInsets.all(20),
                  minScale: 0.5,
                  maxScale: 4,
                  child: Image.file(
                    File(imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image, size: 64, color: Colors.red),
                            SizedBox(height: 8),
                            Text('Unable to load image'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
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
                  _canSubmitForm = false;
                  _questionValidityMap = {};
                  _validatingForm = false;
                  signatureFiles.clear();
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
            _buildAttachmentButtons(),
            const SizedBox(height: 16),
            _buildAttachedFilesList(),
            const SizedBox(height: 16),
            ...questions.map((q) => _buildQuestionCard(q)).toList(),
            const SizedBox(height: 24),
            // Submit button that's disabled until all required questions are answered
            ElevatedButton(
              onPressed: (isLoading || _isUploadingFiles || !_canSubmitForm)
                  ? null
                  : _submitAnswers,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.grey[300],
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
                  : Text(
                _validatingForm && !_canSubmitForm
                    ? 'Complete required questions to submit'
                    : 'Submit Answers',
                style: TextStyle(
                  fontSize: 16,
                  color: _canSubmitForm ? Colors.white : Colors.grey[600],
                ),
              ),
            ),
            // Error message when user tries to submit with incomplete required fields
            if (_validatingForm && !_canSubmitForm)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Text(
                  'Please complete all required questions marked with a red asterisk (*)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                  ),
                ),
              ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: forms.length,
          itemBuilder: (context, index) => _buildFormCard(forms[index]),
        ),
      ),
    );
  }
}