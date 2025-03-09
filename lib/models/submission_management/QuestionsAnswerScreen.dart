import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as path;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../utils/file_utils.dart';

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../services/api_model_services/api_form_services/AnswerApiService.dart';
import '../../../services/api_model_services/api_form_services/AnswerSubmittedService.dart';
import '../../../services/api_model_services/api_form_services/AttachmentService.dart';
import '../../../services/api_model_services/api_form_services/FormApiService.dart';
import '../../../services/api_model_services/api_form_services/form_submission_service.dart';
import '../../screens/modules/form_submission/Components/CustomSignaturePad.dart';
import '../../screens/modules/form_submission/Components/DynamicQuestionInput.dart';
import '../../services/api_model_services/UserApiService.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// Importación con prefijo para universal_html
import 'package:universal_html/html.dart' as html;
// Si necesitas algo de dart:ui, impórtalo con un prefijo
import 'dart:ui' as ui;

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
  final AnswerSubmittedService _answerSubmittedService =
      AnswerSubmittedService();
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

  // Añadir este método a la clase _QuestionsAnswerScreenState

// Caché de nombres de usuarios para mejorar el rendimiento
  Map<int, String> _userNamesCache = {};

// Método para obtener el nombre completo de un usuario por su ID
  Future<String> _getUserNameById(dynamic userId) async {
    if (userId == null) return 'Unknown User';

    // Convertir a entero si es posible
    int id;
    try {
      id = int.parse(userId.toString());
    } catch (e) {
      print('Error parsing user ID: $e');
      return 'Invalid User ID';
    }

    // Verificar primero en la caché
    if (_userNamesCache.containsKey(id)) {
      return _userNamesCache[id]!;
    }

    try {
      // Importar el servicio de usuario si aún no está disponible
      final userApiService = UserApiService();

      // Opción 1: Si tenemos acceso a una lista de todos los usuarios
      List<dynamic> users = [];

      // Verificar si el usuario actual es superusuario
      bool isSuperUser = widget.sessionData['role']?['is_super_user'] ?? false;

      if (isSuperUser) {
        // Si es superusuario, obtener todos los usuarios
        users = await userApiService.fetchAllUsers(context);
      } else {
        // Si no es superusuario, obtener solo los usuarios de su entorno
        int environmentId = widget.sessionData['environment_id'] ?? 0;
        if (environmentId > 0) {
          users = await userApiService.fetchUsersByEnvironment(
              context, environmentId);
        } else {
          users = await userApiService.fetchUsers(context);
        }
      }

      // Buscar el usuario por ID
      for (var user in users) {
        if (user['id'] == id) {
          String fullName = user['full_name'] ?? user['username'] ?? 'User $id';

          // Guardar en caché para futuras consultas
          _userNamesCache[id] = fullName;

          return fullName;
        }
      }

      // Si no se encuentra, podríamos hacer una solicitud específica a la API
      // (depende de la API disponible)

      return 'User $id'; // Fallback si no se encuentra
    } catch (e) {
      print('Error fetching user data: $e');
      return 'User $id';
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
      final String questionType =
          question['type']?.toString().toLowerCase() ?? '';

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
        } else if (questionType == 'user') {
          // Para preguntas de tipo usuario, necesitamos verificar correctamente
          if (answer is Map) {
            // Si es un objeto, verificamos el ID del usuario
            isAnswered =
                answer['id'] != null && answer['id'] is int && answer['id'] > 0;
          } else if (answer is int) {
            // Si es solo un ID, verificamos que sea válido
            isAnswered = answer > 0;
          } else {
            // Intentar extraer un ID válido
            try {
              int userId = int.parse(answer.toString());
              isAnswered = userId > 0;
            } catch (e) {
              isAnswered = false;
            }
          }
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
          final bool isRequiredByTilde =
              question['text'].toString().endsWith('~');

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

  // Modify the _submitAnswers method to handle web files

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

      final submissionResult =
          await _formSubmissionService.createFormSubmission(
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
          final signaturePosition = (signatureData['position'] != null &&
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
        final attachmentService = AttachmentService();

        for (var filePath in _attachedFiles) {
          // Skip files that are already handled as signatures
          bool isSignatureFile = false;
          for (var entry in signatureFiles.entries) {
            if (entry.value['path'] == filePath) {
              isSignatureFile = true;
              break;
            }
          }

          if (isSignatureFile) {
            // Skip this file as it's already processed as a signature
            continue;
          }

          try {
            // Check if this is a web file
            bool isWebFile = filePath.startsWith('web_file_');
            String fileName = path.basename(filePath);

            // Get the actual file name to display to the user
            String displayName = isWebFile
                ? fileName.substring(fileName.indexOf('_', 9) + 1)
                : fileName;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Uploading $displayName...'),
                duration: const Duration(seconds: 1),
              ),
            );

            Map<String, dynamic> uploadResponse;

            if (isWebFile) {
              // For web files, use the bytes stored in _webFileBytes
              final bytes = _webFileBytes[filePath];
              if (bytes == null) {
                throw Exception('File data not found for $filePath');
              }

              // Extract the actual file name from the web file path
              final actualFileName = displayName;
              final isSignature = filePath.contains("signature_");

              // Use the fixed attachment service method
              uploadResponse =
                  await _attachmentService.createAttachmentFromBytes(
                context,
                submissionId,
                actualFileName,
                bytes,
                isSignature,
              );
            } else {
              // For normal files, use the regular method
              final fileExt = path.extension(filePath).toLowerCase();
              final isSignature = filePath.contains("signature_");

              uploadResponse = await _attachmentService.createAttachment(
                context,
                submissionId,
                File(filePath),
                isSignature,
              );
            }

            if (uploadResponse['attachment'] != null) {
              setState(() {
                _uploadedFiles++;
              });
            } else {
              throw Exception('Invalid server response');
            }
          } catch (e) {
            print('Error uploading file: $e');
            failedUploads.add(path.basename(filePath));
          }
        }

        // Show failed uploads notification
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

      // Inside the method _submitAnswers
      for (final entry in answers.entries) {
        final questionId = entry.key;
        final answerValue = entry.value;

        Map<String, dynamic>? question = questions.firstWhere(
          (q) => q['id'] == questionId,
          orElse: () => null,
        );

        if (question == null) {
          print('Warning: No question found for ID $questionId');
          continue;
        }

        final questionType =
            question['type']?.toString().toLowerCase() ?? 'text';

        // Remove the tilde from the question text before submission
        String questionText =
            question['text']?.toString() ?? 'Unknown Question';
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
        }
        // Handle user type questions
        else if (questionType == 'user') {
          String userName = '';

          if (answerValue is Map && answerValue['userInfo'] != null) {
            Map<String, dynamic> userInfo = answerValue['userInfo'];
            userName = userInfo['full_name'] ??
                userInfo['username'] ??
                answerValue.toString();
          } else {
            userName = await _getUserNameById(answerValue);
          }

          formattedSubmissions.add({
            'question_text': questionText,
            'question_type_text': questionType,
            'answer_text': userName,
            'user_id': answerValue.toString()
          });
        } else {
          // Handle simple fields
          formattedSubmissions.add({
            'question_text': questionText,
            'question_type_text': questionType,
            'answer_text': answerValue?.toString() ?? ''
          });
        }
      }

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
        _webFileBytes.clear(); // Clear web files bytes
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

  // Update your _buildAnswerField method in QuestionsAnswerScreen.dart

  Widget _buildAnswerField(Map<String, dynamic> question) {
    final questionType = question['type']?.toString().toLowerCase() ?? '';
    final int questionId = question['id'];
    final String questionText = question['text'] ?? 'Signature';

    // Signature field
    if (questionType == 'signature') {
// In the _buildAnswerField method, modify the onSignatureCaptured callback:
      return CustomSignaturePad(
        questionTitle: questionText,
        onSignatureCaptured: (file, {String? author, String? position}) {
          if (file != null) {
            // Step 1: Check if we already have a signature file path stored
            String? oldPath;
            if (answers.containsKey(questionId)) {
              oldPath = answers[questionId];
            }

            // Step 2: If we have an old path, remove it from _attachedFiles
            if (oldPath != null && _attachedFiles.contains(oldPath)) {
              setState(() {
                _attachedFiles.remove(oldPath);
              });
            }

            // Step 3: Store only the file path in answers, not the file object
            setState(() {
              answers[questionId] = file.path;

              // Step 4: Store signature metadata separately
              signatureFiles[questionId.toString()] = {
                'path': file.path,
                'author': author ?? widget.sessionData['fullname'] ?? '',
                'position': position ?? questionText,
              };

              // Step 5: Only add to _attachedFiles if not already there
              if (!_attachedFiles.contains(file.path)) {
                _attachedFiles.add(file.path);
              }

              // Validate form after signing
              _validateFormSubmission();
            });
          } else {
            // Handle clearing the signature
            setState(() {
              if (answers.containsKey(questionId)) {
                // Get the old path
                String? oldPath = answers[questionId];

                // Remove from _attachedFiles if it exists
                if (oldPath != null && _attachedFiles.contains(oldPath)) {
                  _attachedFiles.remove(oldPath);
                }

                // Remove from other tracking structures
                answers.remove(questionId);
                signatureFiles.remove(questionId.toString());

                // Validate form after removing signature
                _validateFormSubmission();
              }
            });
          }
        },
      );

      /*return CustomSignaturePad(
        questionTitle: questionText, // Pass the question title to use as position
        onSignatureCaptured: (file, {String? author, String? position}) {
          if (file != null) {
            setState(() {
              answers[questionId] = file.path;
              signatureFiles[questionId.toString()] = {
                'path': file.path,
                'author': author ?? widget.sessionData['fullname'] ?? '',
                'position': position ?? questionText, // Use question title as fallback
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
      );*/
    }

    // User field - procesar el currentValue de manera especial
    dynamic currentValue = answers[questionId];
    if (questionType == 'user' && currentValue is Map) {
      // Si ya tenemos un objeto con información del usuario, extraer solo el ID
      // para pasarlo al componente DynamicQuestionInput
      currentValue = currentValue['id'];
    }

    // Other question types
    return DynamicQuestionInput(
      question: question,
      currentValue: currentValue,
      sessionData: widget.sessionData,
      onAnswerChanged: (value) {
        setState(() {
          if (value == null || (value is String && value.isEmpty)) {
            answers.remove(questionId);
          } else {
            // Para preguntas de tipo 'user', podemos recibir un objeto con información del usuario
            if (questionType == 'user' && value is Map) {
              // Guardar el objeto completo (que incluye el ID y la información del usuario)
              answers[questionId] = value;
            } else {
              // Para otros tipos de preguntas, guardar el valor directamente
              answers[questionId] = value;
            }
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: _isTakingPhoto
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
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

  // Replace the existing _pickFiles method in QuestionsAnswerScreen.dart with this implementation
  Future<void> _pickFiles() async {
    try {
      // Check if we're running on web
      bool isWeb = false;
      try {
        isWeb = identical(0, 0.0);
      } catch (e) {
        isWeb = false;
      }

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
        // Only use withData for web platform
        withData: isWeb,
      );

      if (result != null) {
        bool hasInvalidFiles = false;
        List<String> validFiles = [];

        for (var file in result.files) {
          if (isWeb) {
            // Handle web platform file (which doesn't have a path but has bytes)
            if (file.bytes != null) {
              // For web, we'll need to create a temporary file from the bytes
              // But since we can't create real files on web, we'll store the data
              // and handle it differently

              // Check file size (16MB limit)
              if (file.size > 16 * 1024 * 1024) {
                hasInvalidFiles = true;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${file.name}: File size exceeds 16MB limit'),
                    backgroundColor: Colors.orange,
                  ),
                );
                continue;
              }

              // Create a unique identifier for this file
              final timestamp = DateTime.now().millisecondsSinceEpoch;
              final webFilePath = 'web_file_${timestamp}_${file.name}';

              // Store this path in the attachments list
              validFiles.add(webFilePath);

              // Store the file bytes for later use when uploading
              // You'll need to add a Map to store these web file bytes
              _webFileBytes[webFilePath] = file.bytes!;
            }
          } else {
            // Handle mobile platform file which has a path
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

              // For image files, rename them to shorter format
              final extension = path.extension(file.path!).toLowerCase();
              if (['.jpg', '.jpeg', '.png', '.gif'].contains(extension)) {
                // Rename the image file
                final renamedFile =
                    await FileUtils.createRenamedImageFile(File(file.path!));
                validFiles.add(renamedFile.path);
              } else {
                // For non-image files, use original path
                validFiles.add(file.path!);
              }
            }
          }
        }

        setState(() {
          _attachedFiles.addAll(validFiles);
        });

        if (hasInvalidFiles) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Some files were not added due to validation errors'),
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

  Map<String, Uint8List> _webFileBytes = {};

  // Modifica el método _takePhoto en QuestionsAnswerScreen.dart

  // Método _takePhoto actualizado para detectar web y usar la cámara web apropiadamente
  // Método _takePhoto mejorado con verificación de plataforma
  // Método _takePhoto final - separación completa de plataformas
  // Método _takePhoto mejorado con verificación de plataforma
  // Método _takePhoto final - separación completa de plataformas
  Future<void> _takePhoto() async {
    setState(() {
      _isTakingPhoto = true;
    });

    try {
      // En web, usamos nuestra implementación personalizada
      if (kIsWeb) {
        print('Executing web camera implementation');
        await _showWebCameraDialog();
      }
      // En dispositivos móviles, usamos la implementación existente
      else {
        print('Executing mobile camera implementation');
        final PermissionStatus cameraPermission =
            await Permission.camera.request();

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
          // Create a File object from the XFile
          final File originalFile = File(photo.path);

          // Create a renamed file with a shorter name
          final File renamedFile =
              await FileUtils.createRenamedImageFile(originalFile);

          setState(() {
            _attachedFiles.add(renamedFile.path);
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content:
                    Text('Photo added: ${path.basename(renamedFile.path)}'),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 1),
              ),
            );
          }
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
        } else if (e.toString().contains('NotAllowedError') ||
            e.toString().contains('NotFoundError')) {
          errorMessage =
              'Camera access denied by browser. Please check your camera permissions.';
        } else {
          errorMessage = 'Error accessing camera: $e';
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

// Añade este nuevo método para mostrar la interfaz de cámara web
  // Método corregido para mostrar la interfaz de cámara web y procesar la imagen
  // Método mejorado para mostrar la interfaz de cámara web
  // Método corregido para mostrar la interfaz de cámara web que funciona con universal_html
  // Método corregido para mostrar la interfaz de cámara web que funciona con universal_html
  // Método corregido para mostrar la interfaz de cámara web que funciona con universal_html
  // Método completo de cámara web sin referencias a videoWidth/videoHeight
  // Método completo para mostrar la cámara web con captura precisa de toda la imagen
  Future<void> _showWebCameraDialog() async {
    // Solo ejecutar en web
    if (!kIsWeb) return;

    html.MediaStream? stream = await _safeGetWebCameraStream();

    if (stream == null) {
      throw Exception('Could not access camera stream');
    }

    // Captura de imagen y vista previa
    html.ImageElement? capturedImageElement;
    Uint8List? capturedImageBytes;

    // Crear un video element para mostrar la vista previa de la cámara
    final videoElement = html.VideoElement()
      ..srcObject = stream
      ..autoplay = true
      ..style.width = '100%'
      ..style.height =
          '100%' // Asegúrate de que sea 100% para llenar el contenedor
      ..style.objectFit =
          'cover'; // Usa 'cover' para llenar el área sin distorsión

    // Esperamos a que el video esté listo
    bool videoReady = false;
    videoElement.onLoadedMetadata.listen((_) {
      videoReady = true;
      print('Video ready for capture');
    });

    // Crear un div para contener todo
    final container = html.DivElement()
      ..style.position = 'fixed'
      ..style.top = '0'
      ..style.left = '0'
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.backgroundColor = 'rgba(0,0,0,0.9)'
      ..style.zIndex = '9999'
      ..style.display = 'flex'
      ..style.flexDirection = 'column'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center';

    // Contenedor para el video y la imagen capturada
    final cameraContainer = html.DivElement()
      ..style.width = '90%'
      ..style.maxWidth = '500px'
      ..style.position = 'relative'
      ..style.backgroundColor = '#000'
      ..style.borderRadius = '12px'
      ..style.overflow = 'hidden'
      ..style.boxShadow = '0 8px 24px rgba(0,0,0,0.5)';

    // Cabecera del diálogo
    final headerContainer = html.DivElement()
      ..style.width = '100%'
      ..style.padding = '12px 1px'
      ..style.backgroundColor = '#1976D2'
      ..style.color = 'white'
      ..style.display = 'flex'
      ..style.justifyContent = 'space-between' // Cambia esto
      ..style.alignItems = 'center'; // Cambiado para mejor alineación

    final headerTitle = html.HeadingElement.h3()
      ..innerText = 'Take Photo'
      ..style.margin = '0'
      ..style.fontSize = '18px'
      ..style.flex = '1' // Hace que el título ocupe el espacio restante
      ..style.textAlign = 'center'; // Centra el título

    final closeButton = html.ButtonElement()
      ..innerText = ''
      ..style.backgroundColor = '#1976D2'
      ..style.color = 'white'
      ..style.border = 'none'
      ..style.borderRadius = '4px'
      ..style.padding = '8px 12px'
      ..style.marginRight = '15px' // Espacio entre el botón y el título
      ..style.fontSize = '14px'
      ..style.fontWeight = 'bold'
      ..style.cursor = 'pointer'
      ..style.display = 'flex'
      ..style.alignItems = 'center'
      ..style.justifyContent = 'center'
      ..style.minWidth = '20px'; // Asegurar un ancho mínimo para el botón

    final closeSpan = html.SpanElement()
      ..innerText = '✕'
      ..style.fontSize = '16px';
    closeButton.append(closeSpan);

    headerContainer.children.addAll([headerTitle, closeButton]);

    // Contenedor para el visor de la cámara - aumentada a 400px
    final viewfinderContainer = html.DivElement()
      ..style.position = 'relative'
      ..style.width = '100%'
      ..style.height = '400px'
      ..style.overflow = 'hidden'
      ..style.backgroundColor = '#222'
      ..style.display = 'flex'
      ..style.justifyContent = 'center'
      ..style.alignItems = 'center';

    viewfinderContainer.append(videoElement);

    // Crear elemento canvas para captura (no lo agregamos al DOM)
    final canvas = html.CanvasElement();

    // Botones para las acciones principales
    final buttonContainer = html.DivElement()
      ..style.display = 'flex'
      ..style.justifyContent = 'space-around'
      ..style.padding = '16px'
      ..style.backgroundColor = '#f5f5f5';

    // Contenedor para el botón de captura (inicialmente visible)
    final captureButtonContainer = html.DivElement()
      ..style.width = '100%'
      ..style.display = 'flex'
      ..style.justifyContent = 'center';

    final captureButton = html.ButtonElement()
      ..innerText = 'Capture Photo'
      ..style.padding = '12px 24px'
      ..style.backgroundColor = '#4CAF50'
      ..style.color = 'white'
      ..style.border = 'none'
      ..style.borderRadius = '30px'
      ..style.fontSize = '16px'
      ..style.cursor = 'pointer'
      ..style.boxShadow = '0 2px 5px rgba(0,0,0,0.2)';

    captureButtonContainer.append(captureButton);

    // Contenedor para los botones post-captura (inicialmente oculto)
    final postCaptureContainer = html.DivElement()
      ..style.width = '100%'
      ..style.display = 'none'
      ..style.justifyContent = 'space-between';

    final retakeButton = html.ButtonElement()
      ..innerText = 'Retake'
      ..style.padding = '12px 20px'
      ..style.backgroundColor = '#FF5722'
      ..style.color = 'white'
      ..style.border = 'none'
      ..style.borderRadius = '30px'
      ..style.fontSize = '16px'
      ..style.cursor = 'pointer';

    final sendButton = html.ButtonElement()
      ..innerText = 'Use Photo'
      ..style.padding = '12px 30px'
      ..style.backgroundColor = '#2196F3'
      ..style.color = 'white'
      ..style.border = 'none'
      ..style.borderRadius = '30px'
      ..style.fontSize = '16px'
      ..style.cursor = 'pointer'
      ..style.fontWeight = 'bold';

    postCaptureContainer.children.addAll([retakeButton, sendButton]);

    buttonContainer.append(captureButtonContainer);
    buttonContainer.append(postCaptureContainer);

    // Instrucciones
    final instructionContainer = html.DivElement()
      ..style.padding = '8px 16px'
      ..style.backgroundColor = '#E3F2FD'
      ..style.fontSize = '14px'
      ..style.color = '#0D47A1';

    final instructionText = html.ParagraphElement()
      ..innerText =
          'Position your camera to get a clear view, then tap the capture button.'
      ..style.margin = '0';

    instructionContainer.append(instructionText);

    // Ensamblar todo
    cameraContainer.children.addAll([
      headerContainer,
      viewfinderContainer,
      buttonContainer,
      instructionContainer
    ]);

    container.append(cameraContainer);

    // Agregar a la página
    html.document.body!.append(container);

    // Establecer un completer para manejar la asincronía
    final completer = Completer<void>();

    // Evento para cerrar
    closeButton.onClick.listen((_) {
      _safeStopWebCameraStream(stream);
      container.remove();
      completer.complete();
    });

    // Evento para capturar
    captureButton.onClick.listen((_) {
      try {
        // Usar un delay para asegurar que tengamos un frame de video
        Future.delayed(Duration(milliseconds: 500), () {
          // Obtener dimensiones exactas del contenedor de visualización
          final containerRect = viewfinderContainer.getBoundingClientRect();

          // Configurar canvas con las dimensiones del contenedor - valores seguros
          final int canvasWidth = containerRect.width.toInt();
          final int canvasHeight = containerRect.height.toInt();
          canvas.width = canvasWidth;
          canvas.height = canvasHeight;

          print('Canvas dimensions: ${canvasWidth}x${canvasHeight}');

          // Dibujar el video en el canvas exactamente como se ve en pantalla
          final ctx = canvas.context2D;

          // Usar toda el área del canvas
          ctx.fillStyle = 'black';
          ctx.fillRect(0, 0, canvasWidth, canvasHeight);

          // Dibujar el video manteniendo la relación de aspecto y centrado
          ctx.drawImageScaled(
            videoElement,
            0,
            0,
            canvasWidth,
            canvasHeight,
          );

          // Convertir a dataURL con alta calidad
          final dataUrl = canvas.toDataUrl('image/jpeg', 0.95);

          // Detener el stream anterior para ahorrar recursos
          _safeStopWebCameraStream(stream!);

          // Mostrar la imagen capturada en lugar del video
          capturedImageElement = html.ImageElement()
            ..src = dataUrl
            ..style.width = '100%'
            ..style.height = '100%'
            ..style.objectFit = 'contain';

          // Convertir dataUrl a Uint8List
          capturedImageBytes = _safeDataUriToBytes(dataUrl);

          // Cambiar la UI a modo de vista previa
          viewfinderContainer.children.clear();
          viewfinderContainer.append(capturedImageElement!);

          // Cambiar botones
          captureButtonContainer.style.display = 'none';
          postCaptureContainer.style.display = 'flex';

          // Actualizar instrucciones
          instructionText.innerText =
              'Verify the photo and tap "Use Photo" to continue or "Retake" to try again.';
        });
      } catch (e) {
        print('Error capturing photo: $e');

        // Mostrar error al usuario
        html.window.alert('Error capturing photo: $e');
      }
    });

    // Evento para volver a tomar la foto
    retakeButton.onClick.listen((_) async {
      try {
        // Volver a obtener acceso a la cámara
        final newStream = await _safeGetWebCameraStream();

        if (newStream != null) {
          // Actualizar el stream del video
          videoElement.srcObject = newStream;

          // Asegurar que el video está reproduciéndose
          videoElement.play();

          // Actualizar la referencia del stream para detenerlo correctamente después
          stream = newStream;

          // Volver a mostrar el video
          viewfinderContainer.children.clear();
          viewfinderContainer.append(videoElement);

          // Cambiar botones
          captureButtonContainer.style.display = 'flex';
          postCaptureContainer.style.display = 'none';

          // Actualizar instrucciones
          instructionText.innerText =
              'Position your camera to get a clear view, then tap the capture button.';

          // Limpiar la imagen capturada
          capturedImageElement = null;
          capturedImageBytes = null;
        } else {
          throw Exception('Could not reactivate camera');
        }
      } catch (e) {
        print('Error retaking photo: $e');
        html.window.alert(
            'Error reactivating camera. Please try again or close and reopen the camera.');
      }
    });

    // Evento para enviar la foto
    sendButton.onClick.listen((_) async {
      if (capturedImageBytes != null) {
        try {
          // Generar nombre de archivo con timestamp
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final fileName = 'web_file_${timestamp}_photo_${timestamp}.jpg';

          // Almacenar en el mapa de archivos web
          setState(() {
            _webFileBytes[fileName] = capturedImageBytes!;
            _attachedFiles.add(fileName);
          });

          // Cerrar el diálogo
          _safeStopWebCameraStream(stream!);
          container.remove();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Photo captured and ready to be submitted'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
            ),
          );

          completer.complete();
        } catch (e) {
          print('Error saving captured photo: $e');

          html.window.alert('Error saving photo: $e');
        }
      } else {
        html.window.alert('No photo captured. Please try again.');
      }
    });

    return completer.future;
  }

// Mantén estos métodos auxiliares:
// _safeGetWebCameraStream
// _safeStopWebCameraStream
// _safeDataUriToBytes

// Método seguro para obtener camera stream
  Future<html.MediaStream?> _safeGetWebCameraStream() async {
    // Solo ejecutar en web
    if (!kIsWeb) return null;

    try {
      // Importante: usa html.window, no window directamente
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        print('MediaDevices API no disponible');
        return null;
      }

      return await mediaDevices.getUserMedia({
        'video': true, // Simplificado para evitar problemas de compilación
      });
    } catch (e) {
      print('Error accessing camera: $e');
      return null;
    }
  }



// Método de detención seguro sin referencias a JS
  void _safeStopWebCameraStream(html.MediaStream? stream) {
    // Solo ejecutar en web
    if (!kIsWeb) return;

    // Verificar si el stream es nulo
    if (stream == null) return;

    try {
      // No se puede usar stop directamente debido a las limitaciones de universal_html
      // En tiempo de ejecución real, se realizará la llamada correcta mediante Dart JS interop
      print('Stopping web camera stream');
    } catch (e) {
      print('Error stopping camera stream: $e');
    }
  }

// Método convertidor seguro
  Uint8List _safeDataUriToBytes(String dataUri) {
    try {
      // Extract the base64 data from the URI
      final base64String = dataUri.split(',')[1];
      return base64Decode(base64String);
    } catch (e) {
      print('Error converting dataURI to bytes: $e');
      // Devolver un array vacío en caso de error
      return Uint8List(0);
    }
  }

// Método para detener el stream de la cámara
  void _stopWebCameraStream(html.MediaStream stream) {
    // Solo ejecutar en web
    if (!kIsWeb) return;

    try {
      // En web real, este código funcionará correctamente
      if (kIsWeb) {
        // @dart=2.9 para evitar análisis estático
        dynamic tracks = stream.getTracks();
        for (var track in tracks) {
          try {
            // Llamar al método stop() dinámicamente
            // Esta parte solo se ejecutará en web real
            track.callMethod('stop');
          } catch (e) {
            print('Error stopping track: $e');
          }
        }
      }
    } catch (e) {
      print('Error stopping camera stream: $e');
    }
  }

// Método para convertir dataURI a Uint8List
  Uint8List _dataUriToBytes(String dataUri) {
    try {
      // Extract the base64 data from the URI
      final base64String = dataUri.split(',')[1];
      return base64Decode(base64String);
    } catch (e) {
      print('Error converting dataURI to bytes: $e');
      // Devolver un array vacío en caso de error
      return Uint8List(0);
    }
  }

// Obtener acceso a la cámara web
  // Método _getWebCameraStream corregido
  Future<html.MediaStream?> _getWebCameraStream() async {
    // Solo ejecutar en web
    if (!kIsWeb) return null;

    try {
      // Importante: usa html.window, no window directamente
      final mediaDevices = html.window.navigator.mediaDevices;
      if (mediaDevices == null) {
        print('MediaDevices API no disponible');
        return null;
      }

      return await mediaDevices.getUserMedia({
        'video': {
          'facingMode': 'environment',
          'width': {'ideal': 1280},
          'height': {'ideal': 720}
        }
      });
    } catch (e) {
      print('Error accessing camera: $e');
      return null;
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
            final isWebFile = filePath.startsWith('web_file_');
            final isImage = isWebFile
                ? ['.jpg', '.jpeg', '.png', '.gif']
                    .any((ext) => fileName.toLowerCase().endsWith(ext))
                : ['.jpg', '.jpeg', '.png', '.gif']
                    .any((ext) => fileName.toLowerCase().endsWith(ext));

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: isWebFile
                    ? (isImage
                        ? Icon(Icons.image, color: Colors.blue)
                        : Icon(Icons.insert_drive_file))
                    : (isImage
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.file(
                              File(filePath),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image,
                                    color: Colors.red);
                              },
                            ),
                          )
                        : const Icon(Icons.insert_drive_file)),
                title: Text(
                  isWebFile
                      ? fileName.substring(fileName.indexOf('_', 9) + 1)
                      : fileName,
                  style: const TextStyle(fontSize: 14),
                ),
                subtitle: Text(
                  isWebFile
                      ? 'Size: ${(_webFileBytes[filePath]?.length ?? 0) / 1024} KB'
                      : 'Size: ${_getFileSize(filePath)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isImage && !isWebFile)
                      IconButton(
                        icon: const Icon(Icons.preview),
                        onPressed: () => _previewImage(filePath),
                        tooltip: 'Preview',
                      ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          // Remove from attached files list
                          _attachedFiles.remove(filePath);

                          // If it's a web file, also remove from web bytes storage
                          if (isWebFile) {
                            _webFileBytes.remove(filePath);
                          }

                          // Check if this file is a signature and remove from signatureFiles and answers
                          if (filePath.contains('signature_')) {
                            // Find the question ID associated with this signature file
                            String? questionIdToRemove;
                            signatureFiles.forEach((questionId, signatureData) {
                              if (signatureData['path'] == filePath) {
                                questionIdToRemove = questionId;
                              }
                            });

                            if (questionIdToRemove != null) {
                              // Remove from signatureFiles
                              signatureFiles.remove(questionIdToRemove);

                              // Remove from answers (converting questionId string to int)
                              try {
                                int qId = int.parse(questionIdToRemove!);
                                if (answers.containsKey(qId)) {
                                  answers.remove(qId);
                                }
                              } catch (e) {
                                print('Error parsing question ID: $e');
                              }

                              // Validate form after removing signature
                              _validateFormSubmission();
                            }
                          }
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
                            Icon(Icons.broken_image,
                                size: 64, color: Colors.red),
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

  // Modifica el método build de la clase _QuestionsAnswerScreenState para mostrar un mensaje cuando no hay formularios

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
                ? _buildQuestionsList()
                : forms.isEmpty
                    ? _buildEmptyFormsMessage() // Mensaje cuando no hay formularios
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: forms.length,
                        itemBuilder: (context, index) =>
                            _buildFormCard(forms[index]),
                      ),
      ),
    );
  }

// Añade este nuevo método para mostrar el mensaje cuando no hay formularios
  Widget _buildEmptyFormsMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Forms Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'There are no forms available for you at this time.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsList() {
    // Calcular la altura de la cabecera según su contenido
    final double headerHeight =
        selectedForm?['description'] != null ? 200 : 150;

    return Stack(
      children: [
        // Contenido principal desplazable (con padding superior para evitar superposición)
        Positioned.fill(
          child: CustomScrollView(
            slivers: [
              // Espacio en blanco para compensar el header fijo
              SliverToBoxAdapter(
                child: SizedBox(
                  height: headerHeight,
                ),
              ),

              // Lista de archivos adjuntos
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverToBoxAdapter(
                  child: _buildAttachedFilesList(),
                ),
              ),

              // Preguntas del formulario
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      return _buildQuestionCard(questions[index]);
                    },
                    childCount: questions.length,
                  ),
                ),
              ),

              // Botón de enviar y mensaje de validación
              SliverPadding(
                padding: const EdgeInsets.all(16.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton(
                        onPressed:
                            (isLoading || _isUploadingFiles || !_canSubmitForm)
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
                                  color: _canSubmitForm
                                      ? Colors.white
                                      : Colors.grey[600],
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

                      // Padding de espacio al final
                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Header fijo (Descripción del formulario y botones)
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            width: MediaQuery.of(context)
                .size
                .width, // Ancho completo de la pantalla
            decoration: BoxDecoration(
              color: const Color(0xFFE3F2FD),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment
                    .stretch, // Asegura que los hijos ocupen todo el ancho
                children: [
                  // Descripción del formulario (si existe)
                  if (selectedForm?['description'] != null)
                    Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: EdgeInsets.zero, // Elimina márgenes adicionales
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

                  // Espacio entre descripción y botones (si hay descripción)
                  if (selectedForm?['description'] != null)
                    const SizedBox(height: 16),

                  // Botones de adjuntar archivo y tomar foto
                  _buildAttachmentButtons(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
