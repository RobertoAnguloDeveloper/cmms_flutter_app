// 📂 lib/configs/api_config.dart

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Handles API configuration and environment-specific URLs
class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  /// Local development URLs for different environments
  static const String _localUrl = 'http://127.0.0.1:5000';
  static const String _remoteUrl = 'http://3.129.92.139';
  static const String _androidEmulatorUrl = 'http://10.0.2.2:5000';

  /// Determines if the app is running in development mode
  static const bool _isDevelopment = bool.fromEnvironment(
    'DEVELOPMENT_MODE',
    defaultValue: true,
  );

  /// Get the environment name for clearer logging
  static String get environmentName => _isDevelopment ? 'Development' : 'Production';

  /// Provides the appropriate base URL depending on platform and environment
  static String get baseUrl {
    if (!_isDevelopment) {
      return _remoteUrl;
    }

    // Web platform handling
    if (kIsWeb) {
      // For web, we need to handle CORS properly
      // Use window.location.hostname if running on actual web server
      return _getWebBaseUrl();
    }

    // Mobile platform handling
    if (Platform.isAndroid) {
      return _androidEmulatorUrl;
    }

    // Default fallback for other platforms (iOS, desktop)
    return _localUrl;
  }

  /// Specifically handle web platform URLs
  static String _getWebBaseUrl() {
    if (_isDevelopment) {
      // For local development, use localhost
      // This assumes your API server is configured to handle CORS
      return _localUrl;
    } else {
      // For production, use the remote URL
      // Make sure your server has proper CORS headers configured
      return _remoteUrl;
    }
  }

  /// API version for versioning endpoints
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
  static bool get isLocalEnvironment =>
      baseUrl.contains('127.0.0.1') || baseUrl.contains('10.0.2.2');

  /// Get full URL for a given endpoint
  static String getEndpointUrl(String endpoint) {
    // Ensure endpoint starts with a slash if not present
    final normalizedEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    return '$baseUrl$normalizedEndpoint';
  }

  /// CORS configuration for web platform
  static Map<String, String> get corsHeaders {
    if (!kIsWeb) return {};

    return {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Origin, Content-Type, Accept, Authorization',
    };
  }

  /// Get default headers for API requests
  static Map<String, String> get defaultHeaders {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (kIsWeb) {
      // Remove problematic headers for web
      headers.addAll({
        'X-Requested-With': 'XMLHttpRequest',
      });
    }

    return headers;
  }

  /// Get specific headers for file downloads on web
  static Map<String, String> get fileDownloadHeaders {
    if (kIsWeb) {
      return {
        'Accept': '*/*',
        'X-Requested-With': 'XMLHttpRequest',
        // Remove problematic headers
        // 'Cache-Control' and 'Accept-Encoding' are removed for web
      };
    }
    return {
      'Accept': '*/*',
      'Cache-Control': 'max-age=3600',
    };
  }

  /// Get environment-specific configuration
  static Map<String, dynamic> get environmentConfig {
    return {
      'isDevelopment': _isDevelopment,
      'environmentName': environmentName,
      'baseUrl': baseUrl,
      'apiVersion': apiVersion,
      'timeouts': {
        'connection': connectionTimeout,
        'receive': receiveTimeout,
        'send': sendTimeout,
      },
      'logging': enableApiLogs,
    };
  }

  /// Initialize API configuration
  static void initialize() {
    if (_isDevelopment) {
      print('API Configuration:');
      print('Environment: $environmentName');
      print('Base URL: $baseUrl');
      print('Platform: ${kIsWeb ? 'Web' : Platform.operatingSystem}');
      print('API Version: $apiVersion');
    }
  }
}

/// Extension for API URL handling
extension ApiUrlExtension on String {
  /// Convert relative path to full API URL
  String toApiUrl() => ApiConfig.getEndpointUrl(this);

  /// Add API version to the path if needed
  String withVersion() {
    if (contains('/v')) return this;
    return '/v${ApiConfig.apiVersion}$this';
  }
}