/// Implementación de utilidades de plataforma para web
class PlatformUtilsImpl {
  /// Inicializa los permisos necesarios (implementación web - no hace nada)
  static Future<void> initializePermissions() async {
    print('Running on web platform, skipping native permissions');
    return;
  }

  /// Siempre falso en web
  static bool get isAndroid => false;

  /// Siempre falso en web
  static bool get isIOS => false;
}