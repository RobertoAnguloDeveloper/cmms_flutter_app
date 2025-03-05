/*import 'package:flutter/material.dart';

import 'MyApp.dart';
import 'models/Permission_set.dart';
import 'services/api_session_client_services/AuthService.dart';
import 'services/api_session_client_services/SessionManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
}*/

import 'package:flutter/material.dart';
import 'dart:io'; // Add this import
import 'package:permission_handler/permission_handler.dart'; // Add this import

import 'MyApp.dart';
import 'models/Permission_set.dart';
import 'services/api_session_client_services/AuthService.dart';
import 'services/api_session_client_services/SessionManager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Add the permission initialization
  await _initializePermissions();

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

// Add this function for permission initialization
Future<void> _initializePermissions() async {
  if (Platform.isAndroid) {
    // Request permissions at app startup
    await [
      Permission.camera,
      Permission.storage,
    ].request();

    // For Android 13 (API level 33) and higher, we need to request
    // more specific permissions for media access
    if (await Permission.storage.status != PermissionStatus.granted) {
      await [
        Permission.photos,
        Permission.videos,
        Permission.mediaLibrary,
      ].request();
    }

    // Log permission statuses for debugging
    print('Camera permission: ${await Permission.camera.status}');
    print('Storage permission: ${await Permission.storage.status}');
  }
}
