// 📂 lib/services/platform/web_logo_service.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:dio/dio.dart';
import '../api_services/api_client.dart';

/// Service to handle logo loading specifically for web platform
class WebLogoService {
  final ApiClient _apiClient;

  // In-memory cache for web
  static final Map<String, Uint8List> _webCache = {};

  const WebLogoService(this._apiClient);

  Future<Uint8List?> loadLogo(String filename) async {
    try {
      // Check in-memory cache first
      if (_webCache.containsKey(filename)) {
        return _webCache[filename];
      }

      // Load from API
      final response = await _apiClient.get(
        '/api/cmms-configs/file/$filename',
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': '*/*',
            'Cache-Control': 'max-age=3600',
          },
        ),
      );

      if (response.data != null) {
        final bytes = Uint8List.fromList(response.data);
        // Cache in memory
        _webCache[filename] = bytes;
        return bytes;
      }
      return null;
    } catch (e) {
      print('Error loading logo for web: $e');
      return null;
    }
  }

  void clearCache([String? filename]) {
    if (filename != null) {
      _webCache.remove(filename);
    } else {
      _webCache.clear();
    }
  }
}

// Updated logo loader service that handles both platforms
class LogoLoaderService {
  final ApiClient _apiClient;
  late final WebLogoService _webService;

  LogoLoaderService(this._apiClient) {
    _webService = WebLogoService(_apiClient);
  }

  Future<Uint8List?> loadLogo(String filename) async {
    if (kIsWeb) {
      return _webService.loadLogo(filename);
    } else {
      // For mobile platforms, use CmmsConfigProvider approach
      try {
        final response = await _apiClient.get(
          '/api/cmms-configs/file/$filename',
          options: Options(
            responseType: ResponseType.bytes,
            headers: {
              'Accept': '*/*',
            },
          ),
        );

        if (response.data != null) {
          return Uint8List.fromList(response.data);
        }
        return null;
      } catch (e) {
        print('Error loading logo for mobile: $e');
        return null;
      }
    }
  }

  void clearCache([String? filename]) {
    if (kIsWeb) {
      _webService.clearCache(filename);
    }
  }
}