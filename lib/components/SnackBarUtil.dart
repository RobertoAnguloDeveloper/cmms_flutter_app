import 'package:flutter/material.dart';

class SnackBarUtil {
  static void showCustomSnackBar({
    required BuildContext context,
    required String message,
    Duration duration =
        const Duration(milliseconds: 500), 
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0), 
        ),
      ),
    );
  }
}