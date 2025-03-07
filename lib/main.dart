import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'MyApp.dart';
import 'models/Permission_set.dart';
import 'services/api_session_client_services/AuthService.dart';
import 'services/api_session_client_services/SessionManager.dart';

// Solo importamos para plataformas móviles, no para web
import 'platform_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar permisos usando la abstracción
  await PlatformUtils.initializePermissions();

  if (!await SessionManager.isValidSession()) {
    runApp(const MyApp(
      sessionData: null,
      permissionSet: null,
    ));
    return;
  }

  try {
    final userData = await AuthService.getCurrentUser();

    if (userData.isEmpty || userData['permissions'] == null) {
      runApp(const MyApp(
        sessionData: null,
        permissionSet: null,
      ));
      return;
    }

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