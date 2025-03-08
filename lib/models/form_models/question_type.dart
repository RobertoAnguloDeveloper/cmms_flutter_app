// lib/models/question_type.dart


import 'package:flutter/material.dart';




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
  signature('signature', 'Firma', Icons.draw); // Fixed to use lowercase 'signature'

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