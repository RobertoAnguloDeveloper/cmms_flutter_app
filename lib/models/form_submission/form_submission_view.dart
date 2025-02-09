// lib/models/form_submission/form_submission_view.dart

import 'answer_view.dart';

/// Representa el "submission" (envío de formulario),
/// con un ID, quién lo envió, cuándo, título del form, y la lista de respuestas.
class FormSubmissionView {
  final int submissionId;       // ID único del submission
  final String submittedBy;     // Quién envió el formulario
  final DateTime submittedAt;   // Cuándo se envió
  final String formTitle;       // Nombre del formulario
  final List<AnswerView> answers; // Todas las respuestas unificadas

  FormSubmissionView({
    required this.submissionId,
    required this.submittedBy,
    required this.submittedAt,
    required this.formTitle,
    required this.answers,
  });

  /// IMPORTANTE:
  /// Este `fromJson` asume que *cada* objeto JSON trae información de UNA sola respuesta,
  /// y en 'form_submission' la info de ese submission.
  ///
  /// Si tu backend regresa *un item* por cada respuesta, entonces
  /// agrupar varias respuestas en *un* 'FormSubmissionView' se hace en la capa del service.
  ///
  /// Por eso verás que aquí se construye un 'answers: [ una sola respuesta ]'.
  /// Luego, en tu service, juntas todo en un map y transformas en un solo 'FormSubmissionView'.
  factory FormSubmissionView.fromJson(Map<String, dynamic> json) {
    final formSubmission = json['form_submission'] ?? {};
    final formInfo = formSubmission['form'] ?? {};

    return FormSubmissionView(
      submissionId: formSubmission['id'] ?? 0,
      submittedBy: formSubmission['submitted_by'] ?? '',
      submittedAt: DateTime.parse(
        formSubmission['submitted_at'] ?? DateTime.now().toIso8601String(),
      ),
      formTitle: formInfo['title'] ?? '',

      // Construimos la lista con UNA sola respuesta, extraída de este JSON puntual
      answers: [
        AnswerView(
          question: json['question'] ?? '',
          questionType: json['question_type'] ?? '',
          answer: json['answer'] ?? '',
        )
      ],
    );
  }

/// OPCIONAL:
/// Si tu backend ya regresa un JSON *unificado* con todas las respuestas
/// en un campo 'answers', podrías usar un constructor distinto, por ejemplo:
///
/// factory FormSubmissionView.fromGroupedJson(Map<String, dynamic> json) {
///   final form = json['form'] ?? {};
///   final answersList = json['answers'] as List? ?? [];
///
///   return FormSubmissionView(
///     submissionId: json['id'] ?? 0,
///     submittedBy: json['submitted_by'] ?? '',
///     submittedAt: DateTime.parse(json['submitted_at'] ?? DateTime.now().toString()),
///     formTitle: form['title'] ?? '',
///     answers: answersList.map((ans) => AnswerView.fromJson(ans)).toList(),
///   );
/// }
///
/// Pero este caso depende 100% de cómo tu backend te envía los datos.
}
