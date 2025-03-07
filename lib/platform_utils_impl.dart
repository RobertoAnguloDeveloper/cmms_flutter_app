import 'dart:io' show Platform;
import 'package:permission_handler/permission_handler.dart';

/// Implementación de utilidades de plataforma para dispositivos móviles
class PlatformUtilsImpl {
  /// Inicializa los permisos necesarios (implementación móvil)
  static Future<void> initializePermissions() async {
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

  /// Verifica si estamos en Android
  static bool get isAndroid => Platform.isAndroid;

  /// Verifica si estamos en iOS
  static bool get isIOS => Platform.isIOS;
}