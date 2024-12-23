// 📂 lib/services/api_services/cmms_config_service.dart

import 'package:dio/dio.dart';
import '../../models/cmms_config.dart';
import 'api_client.dart';

/// Custom exceptions for CMMS config operations
class CmmsConfigException implements Exception {
  final String message;
  const CmmsConfigException(this.message);
  @override
  String toString() => message;
}

class BadRequestException extends CmmsConfigException {
  const BadRequestException(super.message);
}

class NotFoundException extends CmmsConfigException {
  const NotFoundException(super.message);
}

class UnauthorizedException extends CmmsConfigException {
  const UnauthorizedException(super.message);
}

class ApiException extends CmmsConfigException {
  const ApiException(super.message);
}

/// Service class for handling CMMS configuration operations
class CmmsConfigService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/cmms-configs';

  const CmmsConfigService(this._apiClient);

  /// Create a new CMMS configuration file
  ///
  /// Throws:
  /// - [BadRequestException] if the request is malformed
  /// - [UnauthorizedException] if not authorized
  /// - [ApiException] for other API errors
  Future<CmmsConfig> createConfig({
    required String filename,
    required Map<String, dynamic> content,
  }) async {
    try {
      final response = await _apiClient.post(
        _basePath,
        data: {
          'filename': filename,
          'content': content,
        },
      );

      if (response.statusCode != 201) {
        throw ApiException(
          response.data?['error'] ?? 'Failed to create configuration',
        );
      }

      return CmmsConfig.fromJson(response.data['config']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload a configuration file
  ///
  /// Throws:
  /// - [BadRequestException] if file upload fails
  /// - [UnauthorizedException] if not authorized
  /// - [ApiException] for other API errors
  Future<CmmsConfig> uploadConfig(MultipartFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': file,
      });

      final response = await _apiClient.post(
        '$_basePath/upload',
        data: formData,
      );

      if (response.statusCode != 201) {
        throw ApiException(
          response.data?['error'] ?? 'Failed to upload configuration',
        );
      }

      return CmmsConfig.fromJson(response.data['config']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Load an existing configuration file
  ///
  /// Throws:
  /// - [NotFoundException] if config not found
  /// - [UnauthorizedException] if not authorized
  /// - [ApiException] for other API errors
  Future<CmmsConfig> loadConfig(String filename) async {
    try {
      final response = await _apiClient.get('$_basePath/$filename');

      if (response.statusCode != 200) {
        throw ApiException(
          response.data?['error'] ?? 'Failed to load configuration',
        );
      }

      return CmmsConfig.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Rename a configuration file
  ///
  /// Throws:
  /// - [NotFoundException] if original config not found
  /// - [BadRequestException] if new name is invalid
  /// - [UnauthorizedException] if not authorized
  /// - [ApiException] for other API errors
  Future<CmmsConfig> renameConfig(String oldFilename, String newFilename) async {
    try {
      final response = await _apiClient.put(
        '$_basePath/$oldFilename/rename',
        data: {'new_filename': newFilename},
      );

      if (response.statusCode != 200) {
        throw ApiException(
          response.data?['error'] ?? 'Failed to rename configuration',
        );
      }

      return CmmsConfig.fromJson(response.data['config']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete a configuration file
  ///
  /// Throws:
  /// - [NotFoundException] if config not found
  /// - [UnauthorizedException] if not authorized
  /// - [ApiException] for other API errors
  Future<void> deleteConfig(String filename) async {
    try {
      final response = await _apiClient.delete('$_basePath/$filename');

      if (response.statusCode != 200) {
        throw ApiException(
          response.data?['error'] ?? 'Failed to delete configuration',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Check if configuration file exists
  ///
  /// Returns a map containing:
  /// - exists: boolean indicating if config exists
  /// - metadata: map of config metadata if exists
  ///
  /// Throws:
  /// - [UnauthorizedException] if not authorized
  /// - [ApiException] for other API errors
  Future<Map<String, dynamic>> checkConfig() async {
    try {
      final response = await _apiClient.get('$_basePath/check');

      if (response.statusCode != 200) {
        throw ApiException(
          response.data?['error'] ?? 'Failed to check configuration',
        );
      }

      return {
        'exists': response.data['exists'] as bool,
        'metadata': response.data['metadata'] as Map<String, dynamic>,
      };
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle DioException and convert to appropriate CmmsConfigException
  Exception _handleDioError(DioException e) {
    final response = e.response;
    final errorMsg = response?.data?['error'] as String? ?? e.message ?? 'Unknown error';

    switch (response?.statusCode) {
      case 400:
        return BadRequestException(errorMsg);
      case 401:
      case 403:
        return UnauthorizedException(errorMsg);
      case 404:
        return NotFoundException(errorMsg);
      default:
        return ApiException('Failed to complete config operation: $errorMsg');
    }
  }
}