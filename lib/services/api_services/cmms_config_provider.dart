// 📂 lib/services/api_services/cmms_config_provider.dart

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../models/cmms_config.dart';
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
        // Use PUT endpoint for updates
        response = await _apiClient.put(
          '/api/cmms-configs/configs/$filename',
          data: {
            'content': content,
          },
        );

        if (response.statusCode == 200) {
          if (response.data != null && response.data is Map<String, dynamic>) {
            final configData = response.data['config'] as Map<String, dynamic>;
            // Set content from our passed content since the response might not include it
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
        // Use POST endpoint for new files
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
            // Set content from our passed content since the response might not include it
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

  Future<void> deleteConfig(String filename) async {
    try {
      _setLoading(true);
      final response = await _apiClient.delete('/api/cmms-configs/$filename');

      if (response.statusCode == 200) {
        // Clear current config if we just deleted it
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
        // Update current config if we just renamed it
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

  Future<Uint8List> downloadConfig(String filename) async {
    try {
      _setLoading(true);

      final options = Options(
        responseType: ResponseType.bytes,
        headers: {
          'Accept': '*/*',  // Accept any content type for image files
          'Content-Type': 'application/octet-stream',  // For binary data
          'Authorization': 'Bearer ${_apiClient.getToken()}',  // Ensure token is sent
        },
        // Setting longer timeouts for large files
        receiveTimeout: const Duration(minutes: 5),
        sendTimeout: const Duration(minutes: 5),
        // Validate any successful status code
        validateStatus: (status) => status != null && status < 500,
        // Enable response streaming
        listFormat: ListFormat.multiCompatible,
        // Ensure buffer is large enough
        extra: {'bufferSize': 1024 * 1024}, // 1MB buffer
      );

      // Retry logic
      int maxRetries = 3;
      int currentTry = 0;
      DioException? lastError;

      while (currentTry < maxRetries) {
        try {
          final response = await _apiClient.get(
            '/api/cmms-configs/file/$filename',
            options: options,
          );

          if (response.statusCode == 200 && response.data != null) {
            if (response.data is! Uint8List) {
              throw ConfigException('Invalid response type: ${response.data.runtimeType}');
            }
            _error = null;
            return response.data as Uint8List;
          } else {
            throw ConfigException(
              'Failed to download file: ${response.statusCode}',
            );
          }
        } on DioException catch (e) {
          lastError = e;
          currentTry++;
          if (currentTry < maxRetries) {
            // Wait before retrying
            await Future.delayed(Duration(seconds: currentTry * 2));
            continue;
          }
          break;
        }
      }

      throw lastError ?? ConfigException('Failed to download file after retries');
    } catch (e) {
      print('Error downloading config: $e');
      if (e is DioException) {
        print('Dio error type: ${e.type}');
        print('Dio error message: ${e.message}');
        if (e.response != null) {
          print('Response status: ${e.response?.statusCode}');
        }
      }
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
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