import 'package:flutter/material.dart';

import 'MyApp.dart';
import 'models/Permission_set.dart';
import 'services/api_session_client_services/AuthService.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    final userData = await AuthService.getCurrentUser();
    print('User data received with permissions: ${userData['permissions']}');

    final permissionSet =
        PermissionSet.fromJson(userData['permissions'] as List<dynamic>);
    print(
        'Created permission set with permissions: ${permissionSet.permissions}');

    runApp(MyApp(
      sessionData: userData,
      permissionSet: permissionSet,
    ));
  } catch (e) {
    print('Error initializing app: $e');
    runApp(const MyApp(
      sessionData: null,
      permissionSet: null,
    ));
  }
}
