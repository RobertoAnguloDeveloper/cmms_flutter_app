import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Handles API configuration and environment-specific URLs
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Local development URL
  static const String _localUrl = 'http://localhost:5000';

  /// Remote server URL
  static const String _remoteUrl = 'http://3.129.92.139';

  /// Android emulator URL for localhost
  static const String _androidEmulatorUrl = 'http://10.0.2.2:5000';

  /// Determines if the app is running in development mode
  static const bool _isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT_MODE',
    defaultValue: true,
  );

  /// Provides the appropriate base URL depending on platform and environment
  static String get baseUrl {
    if (!_isDevelopment) {
      return _remoteUrl;
    }

    if (kIsWeb) {
      return _remoteUrl;
    }

    if (Platform.isAndroid) {
      return _androidEmulatorUrl;
    }

    if (Platform.isIOS) {
      return _localUrl;
    }

    return _localUrl;
  }

  /// API version
  static const String apiVersion = 'v1';

  /// Connection timeout duration in seconds
  static const int connectionTimeout = 30;

  /// Receive timeout duration in seconds
  static const int receiveTimeout = 30;

  /// Send timeout duration in seconds
  static const int sendTimeout = 30;

  /// Enable detailed API logging in development
  static bool get enableApiLogs => _isDevelopment;

  /// Checks if the current URL is local
  static bool get isLocalEnvironment => baseUrl.contains('localhost') ||
      baseUrl.contains('10.0.2.2');

  /// Get full URL for a given endpoint
  static String getEndpointUrl(String endpoint) {
    return '$baseUrl$endpoint';
  }
}