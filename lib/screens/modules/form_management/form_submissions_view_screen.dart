// lib/screens/form_management/form_submissions_view_screen.dart

import 'dart:typed_data';

import 'package:cmms_app/screens/modules/form_management/pdf_export_submission_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../components/drawer_menu/DrawerMenu.dart';
import '../../../models/Permission_set.dart';
import '../../../models/form_submission/answer_view.dart';
import '../../../models/form_submission/form_submission_view.dart';
import '../../../services/api_model_services/api_form_services/form_submission_view_service.dart';

/// If the user taps the card, we show a detail screen with all answers
class SubmissionDetailScreen extends StatelessWidget {
  final FormSubmissionView submission;
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const SubmissionDetailScreen({
    Key? key,
    required this.submission,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  // Helper method to get appropriate icon for file type
  IconData _getIconForFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.attachment;
    }
  }

  // Helper method to get color for file type
  Color _getColorForFileType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();

    switch (extension) {
      case 'pdf':
        return Colors.red;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Colors.blue;
      case 'doc':
      case 'docx':
        return Colors.blue.shade800;
      case 'xls':
      case 'xlsx':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  List<AnswerView> _processAnswers(List<AnswerView> answers) {
    // En lugar de agrupar solo por nombre de pregunta, debemos asegurarnos de que
    // las preguntas con el mismo nombre pero diferentes ID se mantengan separadas

    // Creamos un mapa donde las claves serán pregunta+tipo+índice para mantener las respuestas únicas
    final Map<String, AnswerView> groupedAnswers = {};

    // Mapa auxiliar para llevar un registro de cuántas respuestas hay para cada pregunta
    final Map<String, int> questionCountMap = {};

    for (var answer in answers) {
      final questionKey = answer.question;
      final isCheckbox = answer.questionType.toLowerCase() == 'checkbox';

      // Incrementar el contador para esta pregunta
      questionCountMap[questionKey] = (questionCountMap[questionKey] ?? 0) + 1;

      // Crear una clave compuesta que incluye el nombre de la pregunta y un contador
      final uniqueKey = isCheckbox
          ? questionKey  // Para checkbox seguimos agrupando
          : "${questionKey}_${questionCountMap[questionKey]}";

      if (isCheckbox && groupedAnswers.containsKey(questionKey)) {
        // Si ya existe esta pregunta y es checkbox, agregamos la respuesta actual a la existente
        final existingAnswer = groupedAnswers[questionKey]!;
        groupedAnswers[questionKey] = AnswerView(
          question: existingAnswer.question,
          questionType: existingAnswer.questionType,
          answer: existingAnswer.answer + ', ' + answer.answer,
        );
      } else {
        // Si no existe esta pregunta o no es checkbox, la agregamos normalmente
        groupedAnswers[uniqueKey] = answer;
      }
    }

    // Convertimos el mapa de respuestas agrupadas a una lista
    return groupedAnswers.values.toList();
  }

  Future<Uint8List> _loadSignatureImage(
      BuildContext context, int attachmentId) async {
    try {
      final service = FormSubmissionViewService();
      // Asumiendo que el servicio tiene un método para obtener la imagen como bytes
      // Si no existe, necesitarás implementarlo
      return await service.getAttachmentBytes(attachmentId);
    } catch (e) {
      print('Error loading signature image: $e');
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Debug flag to help troubleshoot
    final bool hasAttachments = submission.attachments.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          submission.formTitle,
          style: const TextStyle(color: Colors.black87),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      drawer: DrawerMenu(
        onItemTapped: (index) => Navigator.pop(context),
        parentContext: context,
        permissionSet: permissionSet,
        sessionData: sessionData,
      ),
      body: // Versión corregida de la parte del ListView para evitar respuestas duplicadas
// Reemplaza todo el bloque del ListView en el método build con este código

          Container(
        color: const Color(0xFFE3F2FD),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Submission header
            // Submission header
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.symmetric(vertical: 12),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Título con Expanded para evitar desbordamiento
                        Expanded(
                          child: Text(
                            'Form Title: ${submission.formTitle.isNotEmpty ? submission.formTitle : "No title"}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        // Botones de acción agrupados
                        Row(
                          children: [
                            // Botón de exportar a PDF
                            IconButton(
                              icon: const Icon(
                                Icons.ios_share,
                                size: 28,
                                color: Colors.blue,
                              ),
                              tooltip: 'Export to PDF',
                              onPressed: () {
                                // Mostrar el diálogo de exportación de PDF
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return PdfExportDialog(
                                      submissionId: submission.submissionId,
                                    );
                                  },
                                );
                              },
                            ),
                            // Botón de eliminar - solo visible para superusuarios
                            if (sessionData.containsKey('role') &&
                                sessionData['role'] != null &&
                                sessionData['role']['is_super_user'] == true)
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  size: 28,
                                  color: Colors.red,
                                ),
                                tooltip: 'Delete Submission',
                                onPressed: () {
                                  // Mostrar diálogo de confirmación para eliminar
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Delete Submission'),
                                        content: const Text(
                                          'Are you sure you want to delete this submission? This action cannot be undone.',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context); // Cerrar diálogo de confirmación

                                              // Mostrar indicador de carga
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Deleting submission...'),
                                                  duration: Duration(seconds: 2),
                                                ),
                                              );

                                              try {
                                                // Usar el nuevo método para eliminar la presentación
                                                final FormSubmissionViewService service = FormSubmissionViewService();
                                                final bool success = await service.deleteFormSubmission(
                                                    context,
                                                    submission.submissionId
                                                );

                                                if (success && context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(
                                                      content: Text('Submission deleted successfully'),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                  // Volver a la pantalla anterior con un resultado que indique actualización
                                                  Navigator.pop(context, true); // Pasamos 'true' como resultado para indicar que se realizó una eliminación
                                                }
                                              } catch (e) {
                                                if (context.mounted) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Error deleting submission: $e'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            style: TextButton.styleFrom(
                                              foregroundColor: Colors.red,
                                            ),
                                            child: const Text('Delete'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Submitted by: ${submission.submittedBy}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Date: ${DateFormat('dd/MM/yyyy HH:mm').format(submission.submittedAt)}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Form answers - ESTA ES LA ÚNICA SECCIÓN DE RESPUESTAS
            const SizedBox(height: 16),
            ..._processAnswers(submission.answers
                    .where((answer) =>
                        answer.questionType.toLowerCase() != 'signature')
                    .toList())
                .map((processedAnswer) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFB3E5FC),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      processedAnswer.question,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (processedAnswer.questionType.toLowerCase() ==
                            'checkbox' &&
                        processedAnswer.answer.contains(','))
                      // Para respuestas tipo checkbox con múltiples opciones
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children:
                            processedAnswer.answer.split(',').map((option) {
                          final trimmedOption = option.trim();
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle,
                                    size: 18, color: Colors.blue),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    trimmedOption,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      )
                    else
                      // Para respuestas no-checkbox o checkbox con una sola opción
                      Text(
                        processedAnswer.answer,
                        style: const TextStyle(fontSize: 16),
                      ),
                  ],
                ),
              );
            }).toList(),

            // Usar método construido para generar widgets en función de las condiciones
            ...(() {
              // Primero comprobamos si hay firmas o adjuntos
              final signatures =
                  submission.attachments.where((a) => a.isSignature).toList();
              final regularAttachments =
                  submission.attachments.where((a) => !a.isSignature).toList();
              final hasSignatures = signatures.isNotEmpty;
              final hasRegularAttachments = regularAttachments.isNotEmpty;

              // Lista para almacenar todos los widgets a retornar
              final List<Widget> attachmentWidgets = [];

              // Sección de Signatures
              // Versión mejorada para identificar correctamente el nombre de cada firma
// Modifica solo la parte de las firmas en la sección de adjuntos

// Sección de Signatures
              // Sección de Signatures - versión mejorada
              // Sección de Signatures - versión con nombre de archivo
              // Sección de Signatures mejorada
              // Sección de Signatures mejorada con imágenes precargadas
              // Sección de Signatures mejorada con los nuevos campos
              if (hasSignatures) {
                attachmentWidgets.add(const SizedBox(height: 24));
                attachmentWidgets.add(const Text(
                  'Signatures:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ));
                attachmentWidgets.add(const SizedBox(height: 8));

                // Obtener todas las preguntas tipo signature
                final signatureQuestions = submission.answers
                    .where((answer) =>
                        answer.questionType.toLowerCase() == 'signature')
                    .toList();

                // Añadir cada firma a la lista de widgets
                for (var signature in signatures) {
                  // Buscar la pregunta correspondiente para esta firma específica
                  String questionName = 'Electronic Signature';

                  // Buscar coincidencia basada en los nombres de archivos
                  for (var question in signatureQuestions) {
                    // Extraer el nombre base del archivo de la respuesta de la pregunta
                    String answerFileName = "";
                    if (question.answer.contains('/')) {
                      // Si la respuesta contiene una ruta, extraer el nombre del archivo
                      answerFileName = question.answer.split('/').last;
                      if (answerFileName.contains('.')) {
                        answerFileName = answerFileName.split('.').first;
                      }
                    }

                    // Extraer el nombre base del archivo de la firma
                    String signatureFileName = "";
                    if (signature.filePath.contains('\\')) {
                      signatureFileName = signature.filePath.split('\\').last;
                      if (signatureFileName.contains('_')) {
                        // Obtener la parte principal del nombre (antes de los timestamp)
                        signatureFileName = signatureFileName.split('_').first +
                            "_" +
                            signatureFileName.split('_')[1];
                      }
                    }

                    // Verificar si los nombres de archivo coinciden
                    if (!answerFileName.isEmpty &&
                        !signatureFileName.isEmpty &&
                        signatureFileName.contains(answerFileName)) {
                      questionName = question.question;
                      break;
                    }
                  }

                  // Determinar el texto a mostrar para el autor de la firma
                  final String signatureAuthorText =
                      signature.signatureAuthor != null &&
                              signature.signatureAuthor!.isNotEmpty
                          ? signature.signatureAuthor!
                          : questionName;

                  // Añadir tarjeta de firma con la imagen precargada
                  attachmentWidgets.add(Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Encabezado con título
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Text(
                            'Signature by: $signatureAuthorText',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        // Mostrar el cargo/posición si está disponible
                        if (signature.signaturePosition != null &&
                            signature.signaturePosition!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              signature.signaturePosition!,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),

                        // Imagen de la firma
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          width: double.infinity,
                          child: signature.id != null
                              ? FutureBuilder<Uint8List>(
                                  future: _loadSignatureImage(
                                      context, signature.id!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return Container(
                                        height: 100,
                                        alignment: Alignment.center,
                                        child:
                                            const CircularProgressIndicator(),
                                      );
                                    } else if (snapshot.hasError) {
                                      return Container(
                                        height: 100,
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.error_outline,
                                                color: Colors.red, size: 32),
                                            const SizedBox(height: 8),
                                            Text(
                                              'Could not load signature',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (snapshot.hasData) {
                                      return Container(
                                        constraints:
                                            BoxConstraints(maxHeight: 150),
                                        child: Image.memory(
                                          snapshot.data!,
                                          fit: BoxFit.contain,
                                        ),
                                      );
                                    } else {
                                      return Container(
                                        height: 100,
                                        alignment: Alignment.center,
                                        child:
                                            Text('No signature data available'),
                                      );
                                    }
                                  },
                                )
                              : Container(
                                  height: 100,
                                  alignment: Alignment.center,
                                  child: Text('Signature ID missing'),
                                ),
                        ),

                        // Botón para ver en pantalla completa
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              icon: const Icon(Icons.fullscreen),
                              label: const Text('View Full Size'),
                              onPressed: () async {
                                try {
                                  if (signature.id != null) {
                                    await FormSubmissionViewService()
                                        .openAttachment(context, signature.id!);
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Signature ID is missing')),
                                    );
                                  }
                                } catch (e) {
                                  print('Error opening signature: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Error opening signature: $e')),
                                  );
                                }
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ));
                }
              }

              // Sección de Attachments
              if (hasRegularAttachments) {
                attachmentWidgets.add(const SizedBox(height: 24));
                attachmentWidgets.add(const Text(
                  'Attachments:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ));
                attachmentWidgets.add(const SizedBox(height: 8));

                attachmentWidgets.add(Text(
                  'Files attached: ${regularAttachments.length}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ));

                // Añadir cada adjunto normal a la lista de widgets
                for (var attachment in regularAttachments) {
                  // Extract just the filename for display
                  final fileName = attachment.filePath.split('\\').last;

                  attachmentWidgets.add(Card(
                    color: Colors.white,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: Icon(
                        _getIconForFileType(attachment.filePath),
                        color: _getColorForFileType(attachment.filePath),
                        size: 36,
                      ),
                      title: Text(
                        fileName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'Attachment',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                      onTap: () async {
                        try {
                          if (attachment.id != null) {
                            print('Opening attachment ${attachment.id}');
                            await FormSubmissionViewService()
                                .openAttachment(context, attachment.id!);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Attachment ID is missing')),
                            );
                          }
                        } catch (e) {
                          print('Error opening attachment: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Error opening attachment: $e')),
                          );
                        }
                      },
                    ),
                  ));
                }
              }

              // Mensaje si no hay adjuntos de ningún tipo
              if (!hasAttachments) {
                attachmentWidgets.add(const SizedBox(height: 24));
                attachmentWidgets.add(Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'No files or signatures attached to this submission.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ));
              }

              return attachmentWidgets;
            })(),
          ],
        ),
      ),
    );
  }
}

/// Main screen: lists the submissions for a form, one pastel card per submission.
class FormSubmissionsViewScreen extends StatefulWidget {
  final int formId;
  final String formTitle;
  final PermissionSet permissionSet;
  final Map<String, dynamic> sessionData;

  const FormSubmissionsViewScreen({
    Key? key,
    required this.formId,
    required this.formTitle,
    required this.permissionSet,
    required this.sessionData,
  }) : super(key: key);

  @override
  _FormSubmissionsViewScreenState createState() =>
      _FormSubmissionsViewScreenState();
}

// Actualización en la clase _FormSubmissionsViewScreenState

class _FormSubmissionsViewScreenState extends State<FormSubmissionsViewScreen> {
  final FormSubmissionViewService _submissionService = FormSubmissionViewService();

  List<FormSubmissionView> submissions = [];
  List<FormSubmissionView> filteredSubmissions = [];
  bool isLoading = true;

  // Filter by user (solo search, sin dropdown)
  String? _selectedUser;
  TextEditingController _searchController = TextEditingController();

  // Filter by date
  DateTime? _selectedDate;
  TextEditingController _dateController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _searchByUserName(String query) {
    setState(() {
      _applyFilters(userQuery: query);
    });
  }

  // Método para aplicar ambos filtros (usuario y fecha)
  void _applyFilters({String? userQuery, DateTime? date}) {
    // Guardar los valores proporcionados si no son nulos
    if (userQuery != null) {
      _selectedUser = userQuery.isEmpty ? null : userQuery;
    }
    if (date != null) {
      _selectedDate = date;
    }

    // Comenzar con todos los envíos
    List<FormSubmissionView> result = [...submissions];

    // Filtrar por usuario si hay uno seleccionado
    if (_selectedUser != null && _selectedUser!.isNotEmpty) {
      result = result
          .where((s) => s.submittedBy.toLowerCase().contains(_selectedUser!.toLowerCase()))
          .toList();
    }

    // Filtrar por fecha si hay una seleccionada
    if (_selectedDate != null) {
      result = result.where((s) {
        // Comparar solo año, mes y día (ignorar hora, minutos, segundos)
        return s.submittedAt.year == _selectedDate!.year &&
            s.submittedAt.month == _selectedDate!.month &&
            s.submittedAt.day == _selectedDate!.day;
      }).toList();
    }

    // Actualizar la lista filtrada
    setState(() {
      filteredSubmissions = result;
    });
  }

  // Método para mostrar el selector de fecha
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2015),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = DateFormat('dd/MM/yyyy').format(picked);
        _applyFilters(date: picked);
      });
    }
  }

  // Método para limpiar los filtros de fecha
  void _clearDateFilter() {
    setState(() {
      _selectedDate = null;
      _dateController.clear();
      _applyFilters();
    });
  }

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    try {
      setState(() => isLoading = true);

      // This call now returns one FormSubmissionView per submission
      final data = await _submissionService.getFormSubmissions(widget.formId, context);

      submissions = data;
      filteredSubmissions = data;

      setState(() => isLoading = false);
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading submissions: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Text(
            widget.formTitle,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        drawer: DrawerMenu(
          onItemTapped: (index) => Navigator.pop(context),
          parentContext: context,
          permissionSet: widget.permissionSet,
          sessionData: widget.sessionData,
        ),
        body: Container(
          color: const Color(0xFFE3F2FD),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
            children: [
              // Filtro de usuario
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Search by user',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Solo TextField para buscar usuario
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.transparent), // Sin borde
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Enter user name...',
                          border: InputBorder.none,
                          prefixIcon: Icon(Icons.search),
                          suffixIcon: Icon(Icons.person_outline),
                        ),
                        onChanged: _searchByUserName,
                      ),
                    ),
                  ],
                ),
              ),

              // Nuevo: Filtro de fecha
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Filter by date',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Selector de fecha con diseño consistente
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 5,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () => _selectDate(context),
                          ),
                          const VerticalDivider(), // Separador visual
                          // Campo de texto para mostrar la fecha seleccionada
                          Expanded(
                            child: TextField(
                              controller: _dateController,
                              decoration: const InputDecoration(
                                hintText: 'Select date...',
                                border: InputBorder.none,
                              ),
                              readOnly: true,
                              onTap: () => _selectDate(context),
                            ),
                          ),
                          // Botón para limpiar la fecha seleccionada
                          if (_selectedDate != null)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: _clearDateFilter,
                            ),
                        ],
                      ),
                    ),

                    // Badge que muestra cuántos registros se están mostrando
                    if (filteredSubmissions.length != submissions.length)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Showing ${filteredSubmissions.length} of ${submissions.length} submissions',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Mostrar lista o mensaje vacío
              Expanded(
                child: filteredSubmissions.isEmpty
                    ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.list_alt,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No submissions available.',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Once someone submits a form, you\'ll see it here.',
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredSubmissions.length,
                  itemBuilder: (context, index) {
                    final submission = filteredSubmissions[index];
                    return _CustomExpansionCard(
                      submission: submission,
                      onCardTap: () async {
                        // Navegar a la pantalla de detalles y esperar un resultado
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => SubmissionDetailScreen(
                              submission: submission,
                              permissionSet: widget.permissionSet,
                              sessionData: widget.sessionData,
                            ),
                          ),
                        );

                        // Si result es true, significa que se eliminó un submission
                        // y debemos actualizar la lista
                        if (result == true) {
                          // Recargar los submissions
                          _loadSubmissions();
                        }
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ));
  }
}

/// An "ExpansionTile"-like card. One card per submission.
/// Tapping the arrow expands a "compact form"; tapping the card navigates.
class _CustomExpansionCard extends StatefulWidget {
  final FormSubmissionView submission;
  final VoidCallback onCardTap;


  const _CustomExpansionCard({
    Key? key,
    required this.submission,
    required this.onCardTap,
  }) : super(key: key);

  @override
  State<_CustomExpansionCard> createState() => _CustomExpansionCardState();
}

class _CustomExpansionCardState extends State<_CustomExpansionCard> {
  bool _expanded = false;

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.submission;

    return Card(
      color: Colors.white, // pastel pink
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: widget.onCardTap, // navigate on card tap
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  // Left side: Title, user, date
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.formTitle.isNotEmpty
                              ? s.formTitle
                              : 'Submission #${s.submissionId}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Submitted by: ${s.submittedBy}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.calendar_today,
                                size: 16, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy HH:mm')
                                  .format(s.submittedAt),
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                            if (s.attachments.isNotEmpty) ...[
                              const SizedBox(width: 12),
                              Icon(Icons.attachment,
                                  size: 16, color: Colors.blue[600]),
                              const SizedBox(width: 4),
                              Text(
                                '${s.attachments.length} attachment${s.attachments.length > 1 ? 's' : ''}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[600],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Expand arrow
                  //IconButton(
                  //  icon: Icon(
                  //    _expanded
                  //        ? Icons.keyboard_arrow_up
                  //        : Icons.keyboard_arrow_down,
                  //    color: Colors.blue,
                  //  ),
                  //  onPressed: _toggleExpand,
                  //)
                ],
              ),
            ),
          ),
          // If expanded, show Q&A in pastel containers (compact form)
          if (_expanded)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: s.answers.map((answer) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB3E5FC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          answer.question,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          answer.answer,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}
