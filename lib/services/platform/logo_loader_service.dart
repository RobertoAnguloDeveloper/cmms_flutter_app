// 📂 lib/services/platform/logo_loader_service.dart

import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../api_services/api_client.dart';

class LogoLoaderService {
  final ApiClient _apiClient;

  // Unified cache for both platforms
  static final Map<String, CachedLogo> _cache = {};
  static const Duration _cacheDuration = Duration(hours: 1);

  LogoLoaderService(this._apiClient);

  Future<Uint8List?> loadLogo(String filename) async {
    try {
      if (kIsWeb) {
        return await _loadLogoForWeb(filename);
      } else {
        return await _loadLogoForMobile(filename);
      }
    } catch (e, stack) {
      print('Error loading logo: $e');
      print('Stack trace: $stack');
      return null;
    }
  }

  Future<Uint8List?> _loadLogoForWeb(String filename) async {
    // Check memory cache first
    if (_cache.containsKey(filename)) {
      final cached = _cache[filename]!;
      if (DateTime.now().difference(cached.timestamp) < _cacheDuration) {
        return cached.data;
      } else {
        _cache.remove(filename);
      }
    }

    try {
      final options = Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': '*/*',
          'X-Requested-With': 'XMLHttpRequest',
          'Authorization': 'Bearer ${await _apiClient.getToken()}',
        },
      );

      final response = await _apiClient.get(
        '/api/cmms-configs/file/$filename',
        options: options,
      );

      if (response.statusCode == 200 && response.data != null) {
        final bytes = Uint8List.fromList(response.data);

        // Cache in memory for web
        _cache[filename] = CachedLogo(
          data: bytes,
          timestamp: DateTime.now(),
        );

        return bytes;
      }
      return null;
    } catch (e) {
      print('Error loading logo for web: $e');
      return null;
    }
  }

  Future<Uint8List?> _loadLogoForMobile(String filename) async {
    try {
      // Get the application documents directory
      final appDir = await getApplicationDocumentsDirectory();
      final logoDir = Directory('${appDir.path}/logos');

      // Create logos directory if it doesn't exist
      if (!await logoDir.exists()) {
        await logoDir.create(recursive: true);
      }

      final file = File('${logoDir.path}/$filename');

      // Check if file exists in device cache
      if (await file.exists()) {
        return await file.readAsBytes();
      }

      // Configure dedicated Dio instance for binary downloads
      final downloadDio = Dio(BaseOptions(
        baseUrl: _apiClient.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        responseType: ResponseType.bytes,
        validateStatus: (status) => status == 200,
      ));

      // Configure download options
      final options = Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': '*/*',
          'Authorization': 'Bearer ${await _apiClient.getToken()}',
        },
        validateStatus: (status) => status == 200,
      );

      try {
        final response = await downloadDio.get(
          '/api/cmms-configs/file/$filename',
          options: options,
          onReceiveProgress: (count, total) {
            if (total != -1) {
              final progress = (count / total * 100).toStringAsFixed(0);
              print('Download progress: $progress%');
            }
          },
        );

        if (response.statusCode == 200 && response.data != null) {
          final bytes = Uint8List.fromList(response.data);

          // Write to file
          await file.writeAsBytes(bytes);

          return bytes;
        }

        print('Failed to download logo: Status ${response.statusCode}');
        return null;

      } on DioException catch (e) {
        print('DioException while downloading logo:');
        print('  Message: ${e.message}');
        print('  Error: ${e.error}');
        print('  Response: ${e.response}');
        return null;
      }

    } catch (e, stack) {
      print('Error loading logo for mobile: $e');
      print('Stack trace: $stack');
      return null;
    }
  }

  Future<void> clearCache([String? filename]) async {
    if (kIsWeb) {
      if (filename != null) {
        _cache.remove(filename);
      } else {
        _cache.clear();
      }
    } else {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final logoDir = Directory('${appDir.path}/logos');

        if (await logoDir.exists()) {
          if (filename != null) {
            final file = File('${logoDir.path}/$filename');
            if (await file.exists()) {
              await file.delete();
            }
          } else {
            await logoDir.delete(recursive: true);
          }
        }
      } catch (e) {
        print('Error clearing cache: $e');
      }
    }
  }
}

class CachedLogo {
  final Uint8List data;
  final DateTime timestamp;

  const CachedLogo({
    required this.data,
    required this.timestamp,
  });
}