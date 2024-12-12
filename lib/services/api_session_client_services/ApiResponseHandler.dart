import 'package:flutter/material.dart';
import '../../screens/login_screen/LoginPage.dart';
import 'SessionManager.dart';

class ApiResponseHandler {
  static bool _isHandlingExpiredToken = false;

  static Future<void> handleExpiredToken(
    BuildContext context, Map<String, dynamic> response) async {
    
    //IF THERE IS MULTIPLE 401 RESPONSES
    if (_isHandlingExpiredToken) {
      return;
    }
    if (response.containsKey('msg') && response['msg'] == 'Token has expired') {
      _isHandlingExpiredToken = true;

      await SessionManager.clearSession();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired, Please Log in.'),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
        }
        _isHandlingExpiredToken = false;
      });
    }
  }

  static void resetHandlingState() {
    _isHandlingExpiredToken = false;
  }

  static void showError(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
