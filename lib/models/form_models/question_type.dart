// lib/models/question_type.dart
/*
enum QuestionType {
  text('text', 'Texto'),
  radio('radio', 'Opción única'),
  checkbox('checkbox', 'Selección múltiple'),
  date('date', 'Fecha'),
  multiple_choices('multiple_choices', 'Opciones múltiples');

  final String value;
  final String displayName;

  const QuestionType(this.value, this.displayName);

  static QuestionType fromString(String value) {
    return QuestionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => QuestionType.text,
    );
  }

  static String getDisplayName(String value) {
    return QuestionType.values
        .firstWhere(
          (type) => type.value == value,
          orElse: () => QuestionType.text,
        )
        .displayName;
  }

  bool get requiresOptions =>
      this == QuestionType.radio ||
      this == QuestionType.checkbox ||
      this == QuestionType.multiple_choices;
}*/

// lib/models/question_type.dart


import 'package:flutter/material.dart';


/*
enum QuestionType {
  short_text('short_text', 'Respuesta corta', Icons.short_text),
  paragraph('paragraph', 'Párrafo', Icons.subject),
  multiple_choice('multiple_choice', 'Varias opciones', Icons.radio_button_checked),
  checkbox('checkbox', 'Casillas', Icons.check_box),
  dropdown('dropdown', 'Desplegable', Icons.arrow_drop_down_circle),
  date('date', 'Fecha', Icons.calendar_today),
  file_upload('file_upload', 'Subir archivos', Icons.upload_file),
  linear_scale('linear_scale', 'Escala lineal', Icons.linear_scale),
  grid('grid', 'Cuadrícula', Icons.grid_on);

  final String value;
  final String displayName;
  final IconData icon;

  const QuestionType(this.value, this.displayName, this.icon);

  bool get requiresOptions => [
        QuestionType.multiple_choice,
        QuestionType.checkbox,
        QuestionType.dropdown,
      ].contains(this);
}*/


enum QuestionType {
  short_text('short_text', 'Respuesta corta', Icons.short_text),
  paragraph('paragraph', 'Párrafo', Icons.subject),
  multiple_choice('multiple_choice', 'Varias opciones', Icons.radio_button_checked),
  checkbox('checkbox', 'Casillas', Icons.check_box),
  dropdown('dropdown', 'Desplegable', Icons.arrow_drop_down_circle),
  date('date', 'Fecha', Icons.calendar_today),
  file_upload('file_upload', 'Subir archivos', Icons.upload_file),
  linear_scale('linear_scale', 'Escala lineal', Icons.linear_scale),
  grid('grid', 'Cuadrícula', Icons.grid_on),
  signature('Signature', 'Firma', Icons.draw); // Added new signature type

  final String value;
  final String displayName;
  final IconData icon;

  const QuestionType(this.value, this.displayName, this.icon);

  bool get requiresOptions => [
        QuestionType.multiple_choice,
        QuestionType.checkbox,
        QuestionType.dropdown,
      ].contains(this);
}