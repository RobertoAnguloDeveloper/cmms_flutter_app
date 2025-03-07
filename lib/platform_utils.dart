import 'package:flutter/foundation.dart' show kIsWeb;

// Importaciones condicionales
import 'platform_utils_impl.dart' if (dart.library.html) 'platform_utils_web.dart' as impl;

/// Clase abstracta que proporciona utilidades específicas de plataforma
class PlatformUtils {
  /// Inicializa los permisos necesarios para la aplicación
  static Future<void> initializePermissions() async {
    // Delegamos a la implementación específica de plataforma
    return impl.PlatformUtilsImpl.initializePermissions();
  }

  /// Verifica si estamos en una plataforma móvil
  static bool get isMobile => !kIsWeb;

  /// Verifica si estamos en Android (falso para web)
  static bool get isAndroid => impl.PlatformUtilsImpl.isAndroid;

  /// Verifica si estamos en iOS (falso para web)
  static bool get isIOS => impl.PlatformUtilsImpl.isIOS;
}