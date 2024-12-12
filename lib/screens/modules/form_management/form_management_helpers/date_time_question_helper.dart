// lib/screens/modules/form_management/form_management_helper/date_time_question_handler.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class DateTimeQuestionHandler {
  static final dateFormat = DateFormat('dd/MM/yyyy');
  static final timeFormat = DateFormat('HH:mm');
  static final dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  // Handles both date and datetime question types
   static Widget buildDateTimeQuestion({
    required BuildContext context,
    required Map<String, dynamic> question,
    required Function(int questionId, String value) onAnswerChanged,  // Changed to use int
    String? currentValue,
  }) {
    final bool isDateTime = question['question_type']['type'] == 'datetime';
    final int questionId = question['id'] as int;  // Ensure we get an int
    
    return Card(
      color: const Color.fromARGB(255, 219, 244, 255),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              question['text'] ?? 'No question text',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _showDateTimePicker(
                context: context,
                isDateTime: isDateTime,
                currentValue: currentValue,
                onSelected: (String value) {
                  onAnswerChanged(questionId, value);  // Pass the int questionId
                },
              ),
              child: AbsorbPointer(
                child: TextFormField(
                  initialValue: currentValue,
                  decoration: InputDecoration(
                    hintText: isDateTime 
                        ? 'Select date and time (DD/MM/YYYY HH:mm)'
                        : 'Select date (DD/MM/YYYY)',
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: Icon(
                      isDateTime ? Icons.event_available : Icons.calendar_today,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _showDateTimePicker({
    required BuildContext context,
    required bool isDateTime,
    required Function(String) onSelected,
    String? currentValue,
  }) async {
    DateTime? initialDate;
    if (currentValue != null) {
      try {
        initialDate = isDateTime 
            ? dateTimeFormat.parse(currentValue)
            : dateFormat.parse(currentValue);
      } catch (e) {
        initialDate = DateTime.now();
      }
    }

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromARGB(255, 34, 118, 186),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null && context.mounted) {
      if (isDateTime) {
        final TimeOfDay? selectedTime = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
          builder: (context, child) {
            return Theme(
              data: ThemeData.light().copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color.fromARGB(255, 34, 118, 186),
                ),
              ),
              child: child!,
            );
          },
        );

        if (selectedTime != null) {
          final DateTime fullDateTime = DateTime(
            selectedDate.year,
            selectedDate.month,
            selectedDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
          onSelected(dateTimeFormat.format(fullDateTime));
        }
      } else {
        onSelected(dateFormat.format(selectedDate));
      }
    }
  }

  static bool validateDateTimeValue(String value, bool isDateTime) {
    try {
      if (isDateTime) {
        dateTimeFormat.parseStrict(value);
      } else {
        dateFormat.parseStrict(value);
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  static String formatValue(DateTime dateTime, bool isDateTime) {
    return isDateTime 
        ? dateTimeFormat.format(dateTime)
        : dateFormat.format(dateTime);
  }
}