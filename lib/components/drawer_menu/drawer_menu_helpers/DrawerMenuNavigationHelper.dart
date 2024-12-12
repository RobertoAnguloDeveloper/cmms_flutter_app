import 'package:flutter/material.dart';

import '../../../models/Permission_set.dart';
import '../../../screens/login_screen/LoginPage.dart';
import '../../../screens/modules/home/HomePage.dart';
import '../../../services/api_session_client_services/AuthService.dart';
import '../../../services/api_session_client_services/SessionManager.dart';

class DrawerMenuNavigationHelper {
  //NAVIGATE TO HOME METHOD
  static Future<void> navigateToHome({
    required BuildContext context,
    Map<String, dynamic>? sessionData,
    PermissionSet? permissionSet,
  }) async {
    if (sessionData != null && permissionSet != null) {
      print('Using existing session data and permission set');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomePage(
            sessionData: sessionData,
            permissionSet: permissionSet,
          ),
        ),
      );
    } else {
      try {
        print('Fetching new user data');
        final userData = await AuthService.getCurrentUser();
        print('User data received with keys: ${userData.keys}');

        if (userData['permissions'] == null) {
          print('No permissions found in user data');
          throw Exception('No permissions found in user data');
        }

        print('Creating permission set from: ${userData['permissions']}');
        final permissionSet =
            PermissionSet.fromJson(userData['permissions'] as List);
        print(
            'Created permission set with permissions: ${permissionSet.permissions}');

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              sessionData: userData,
              permissionSet: permissionSet,
            ),
          ),
        );
      } catch (e) {
        print('Error in navigateToHome: $e');
        await SessionManager.clearSession();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      }
    }
  }
}
