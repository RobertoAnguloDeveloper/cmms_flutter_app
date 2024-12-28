// 📂 lib/services/api_services/cmms_config_provider.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../models/cmms_config.dart';
import '../../models/environment.dart';
import '../cache/local_file_cache.dart';
import 'api_client.dart';

/// Custom exceptions for config operations
class ConfigException implements Exception {
  final String message;
  const ConfigException(this.message);
  @override
  String toString() => message;
}

class CmmsConfigProvider with ChangeNotifier {
  final ApiClient _apiClient;
  final LocalFileCache _fileCache = LocalFileCache();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  CmmsConfig? _currentConfig;
  bool _isLoading = false;
  String? _error;

  CmmsConfigProvider({required ApiClient apiClient}) : _apiClient = apiClient;

  CmmsConfig? get currentConfig => _currentConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConfig(String filename) async {
    try {
      _setLoading(true);
      final response = await _apiClient.get('/api/cmms-configs/$filename');

      if (response.statusCode == 200) {
        _currentConfig = CmmsConfig.fromJson(response.data);
        _error = null;
      } else {
        throw ConfigException(
          response.data?['error'] ?? 'Failed to load configuration',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> saveConfig({
    required String filename,
    required Map<String, dynamic> content,
    bool useUpdate = false,
  }) async {
    try {
      _setLoading(true);
      Response response;

      if (useUpdate) {
        response = await _apiClient.put(
          '/api/cmms-configs/configs/$filename',
          data: {
            'content': content,
          },
        );

        if (response.statusCode == 200) {
          if (response.data != null && response.data is Map<String, dynamic>) {
            final configData = response.data['config'] as Map<String, dynamic>;
            configData['content'] = content;
            _currentConfig = CmmsConfig.fromJson(configData);
            _error = null;
          } else {
            throw ConfigException('Invalid response format');
          }
        } else {
          throw ConfigException(
            response.data?['error'] ?? 'Failed to update configuration',
          );
        }
      } else {
        response = await _apiClient.post(
          '/api/cmms-configs',
          data: {
            'filename': filename,
            'content': content,
          },
        );

        if (response.statusCode == 201) {
          if (response.data != null && response.data is Map<String, dynamic>) {
            final configData = response.data['config'] as Map<String, dynamic>;
            configData['content'] = content;
            _currentConfig = CmmsConfig.fromJson(configData);
            _error = null;
          } else {
            throw ConfigException('Invalid response format');
          }
        } else {
          throw ConfigException(
            response.data?['error'] ?? 'Failed to create configuration',
          );
        }
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> uploadConfig(MultipartFile file) async {
    try {
      _setLoading(true);
      final formData = FormData();
      formData.files.add(MapEntry('file', file));

      final response = await _apiClient.post(
        '/api/cmms-configs/upload',
        data: formData,
      );

      if (response.statusCode == 201) {
        if (response.data != null && response.data['config'] != null) {
          _currentConfig = CmmsConfig.fromJson(response.data['config']);
          _error = null;
        } else {
          throw ConfigException('Invalid response format');
        }
      } else {
        throw ConfigException(
          response.data?['error'] ?? 'Failed to upload configuration',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Uint8List?> downloadConfig(String filename) async {
    try {
      // Check cache first
      final cachedFile = await _fileCache.getCachedFile(filename);
      if (cachedFile != null) {
        print('Found cached file: $filename');
        return await cachedFile.readAsBytes();
      }

      // Create a dedicated Dio instance for file downloads
      final downloadDio = Dio(BaseOptions(
        baseUrl: _apiClient.baseUrl,
        connectTimeout: const Duration(minutes: 5),
        receiveTimeout: const Duration(minutes: 10),
        sendTimeout: const Duration(minutes: 5),
        validateStatus: (status) => status == 200,
        // Set specific headers for file download
        headers: {
          'Accept': '*/*',
          'Accept-Encoding': 'identity', // Disable compression
          'Authorization': 'Bearer ${await _apiClient.getToken()}',
        },
      ));

      // Add retry interceptor
      downloadDio.interceptors.add(
        RetryInterceptor(
          dio: downloadDio,
          logPrint: print,
          retries: 3,
          retryDelays: const [
            Duration(seconds: 1),
            Duration(seconds: 2),
            Duration(seconds: 3),
          ],
          retryableExtraStatuses: {200}, // Add 200 to retry status codes
        ),
      );

      final response = await downloadDio.get(
        '/api/cmms-configs/file/$filename',
        options: Options(
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status == 200,
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
          listFormat: ListFormat.multiCompatible,
          headers: {
            'Accept': '*/*',
            'Accept-Encoding': 'identity',
          },
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final percentage = (received / total * 100).toStringAsFixed(0);
            print('Download progress: $percentage% ($received/$total bytes)');
          }
        },
      );

      if (response.data != null) {
        final bytes = Uint8List.fromList(response.data as List<int>);
        print('Download completed: ${bytes.length} bytes');

        // Cache the file
        await _fileCache.cacheFile(
          filename,
          bytes,
          FileMetadata(
            filename: filename,
            modifiedAt: DateTime.now().toIso8601String(),
            size: bytes.length,
            mimeType: 'image/*',
          ),
        );

        return bytes;
      }

      print('Download failed: Empty response data');
      return null;

    } catch (e, stackTrace) {
      print('Error downloading file: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  Future<void> deleteConfig(String filename) async {
    try {
      _setLoading(true);
      final response = await _apiClient.delete('/api/cmms-configs/$filename');

      if (response.statusCode == 200) {
        if (_currentConfig?.filename == filename) {
          _currentConfig = null;
        }
        _error = null;
      } else {
        throw ConfigException(
          response.data?['error'] ?? 'Failed to delete configuration',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<Map<String, dynamic>> checkConfig() async {
    try {
      _setLoading(true);
      final response = await _apiClient.get('/api/cmms-configs/check');

      if (response.statusCode == 200) {
        _error = null;
        return response.data as Map<String, dynamic>;
      } else {
        throw ConfigException(
          response.data?['error'] ?? 'Failed to check configuration',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> renameConfig(String oldFilename, String newFilename) async {
    try {
      _setLoading(true);
      final response = await _apiClient.put(
        '/api/cmms-configs/$oldFilename/rename',
        data: {'new_filename': newFilename},
      );

      if (response.statusCode == 200) {
        if (_currentConfig?.filename == oldFilename) {
          _currentConfig = CmmsConfig.fromJson(response.data['config']);
        }
        _error = null;
      } else {
        throw ConfigException(
          response.data?['error'] ?? 'Failed to rename configuration',
        );
      }
    } on DioException catch (e) {
      _handleDioError(e);
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> getToken() async {
    try {
      final tokenData = await _secureStorage.read(key: _tokenKey);
      if (tokenData != null) {
        final data = jsonDecode(tokenData);
        return data['token'] as String?;
      }
    } catch (e) {
      print('Error getting token: $e');
    }
    return null;
  }

  Future<bool> verifyFileExists(String filename) async {
    try {
      final response = await _apiClient.get('/api/cmms-configs/files');
      if (response.statusCode == 200) {
        final files = (response.data['files'] as List)
            .map((f) => f['filename'] as String)
            .toList();
        return files.contains(filename);
      }
      return false;
    } catch (e) {
      print('Error verifying file existence: $e');
      return false;
    }
  }

  void _handleDioError(DioException e) {
    if (e.response?.statusCode == 404) {
      throw ConfigException('Configuration file not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['error'] as String? ?? 'Bad request';
      throw ConfigException(message);
    }
    if (e.response?.statusCode == 403) {
      throw ConfigException('Unauthorized access');
    }
    throw ConfigException('Failed to complete config operation: ${e.message}');
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _error = message;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}