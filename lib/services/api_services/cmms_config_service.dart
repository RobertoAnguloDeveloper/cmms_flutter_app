// 📂 lib/services/api_services/cmms_config_service.dart

import 'dart:convert';
import 'package:dio/dio.dart';
import '../../models/cmms_config.dart';
import 'api_client.dart';

class CmmsConfigService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/cmms-configs';

  const CmmsConfigService(this._apiClient);

  Future<CmmsConfig> createConfig({
    required String filename,
    required Map<String, dynamic> content,
  }) async {
    try {
      // Create request body as JSON
      final requestData = {
        'filename': filename,
        'content': content,
      };

      final response = await _apiClient.post(
        _basePath,
        data: requestData,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return CmmsConfig.fromJson(response.data['config'] as Map<String, dynamic>);
      } else {
        throw ApiException(
          response.data['error'] ?? 'Failed to create configuration',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<CmmsConfig> uploadConfig(MultipartFile file) async {
    try {
      final formData = FormData.fromMap({
        'file': file,
      });

      final response = await _apiClient.post(
        '$_basePath/upload',
        data: formData,
      );
      return CmmsConfig.fromJson(response.data['config'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<CmmsConfig> loadConfig(String filename) async {
    try {
      final response = await _apiClient.get('$_basePath/$filename');

      if (response.statusCode == 200) {
        return CmmsConfig.fromJson(response.data as Map<String, dynamic>);
      } else if (response.statusCode == 404) {
        throw NotFoundException('Configuration file not found');
      } else if (response.statusCode == 500) {
        throw ApiException('Server error loading configuration');
      }

      throw ApiException(
        response.data['error'] ?? 'Failed to load configuration',
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<CmmsConfig> renameConfig(String filename, String newFilename) async {
    try {
      final response = await _apiClient.put(
        '$_basePath/$filename/rename',
        data: {'new_filename': newFilename},
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );
      return CmmsConfig.fromJson(response.data['config'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteConfig(String filename) async {
    try {
      final response = await _apiClient.delete('$_basePath/$filename');
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw ApiException(
          response.data['error'] ?? 'Failed to delete configuration',
        );
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Exception _handleDioError(DioException e) {
    print('DioError response: ${e.response?.data}');
    if (e.response?.statusCode == 404) {
      return NotFoundException('Configuration not found');
    }
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['error'] as String? ?? 'Bad request';
      return BadRequestException(message);
    }
    if (e.response?.statusCode == 403) {
      return UnauthorizedException('Unauthorized access');
    }
    if (e.response?.statusCode == 500) {
      return ApiException('Internal server error');
    }
    return ApiException('Failed to complete configuration operation: ${e.message}');
  }
}

class ApiException implements Exception {
  final String message;
  const ApiException(this.message);
  @override
  String toString() => message;
}

class NotFoundException extends ApiException {
  const NotFoundException(super.message);
}

class BadRequestException extends ApiException {
  const BadRequestException(super.message);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException(super.message);
}