// lib/services/api_services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';

  ApiClient({required this.baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      receiveTimeout: const Duration(seconds: 15),
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Add auth token if available
        final token = await _storage.read(key: _tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (DioException e, handler) async {
        // Handle common errors
        if (e.response?.statusCode == 401) {
          // Clear token on unauthorized
          await _storage.delete(key: _tokenKey);
          // You might want to add a callback or event to notify the app
          // about unauthorized access to trigger a logout
        }
        return handler.next(e);
      },
    ));
  }

  // Method to save token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Method to clear token
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<Response<T>> delete<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      return await _dio.delete<T>(
        path,
        queryParameters: queryParameters,
      );
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  void _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException('Connection timed out');
      case DioExceptionType.badResponse:
        _handleResponseError(error.response?.statusCode, error.response?.data);
        break;
      case DioExceptionType.cancel:
        throw RequestCancelledException('Request cancelled');
      default:
        throw NetworkException('Network error occurred');
    }
  }

  void _handleResponseError(int? statusCode, dynamic data) {
    switch (statusCode) {
      case 400:
        throw BadRequestException(data?['error'] ?? 'Bad request');
      case 401:
        throw UnauthorizedException(data?['error'] ?? 'Unauthorized');
      case 403:
        throw ForbiddenException(data?['error'] ?? 'Forbidden');
      case 404:
        throw NotFoundException(data?['error'] ?? 'Not found');
      case 500:
        throw ServerException(data?['error'] ?? 'Server error');
      default:
        throw NetworkException('Network error occurred');
    }
  }
}

// Custom exceptions
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
}

class RequestCancelledException implements Exception {
  final String message;
  RequestCancelledException(this.message);
}

class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class BadRequestException implements Exception {
  final String message;
  BadRequestException(this.message);
}

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException(this.message);
}

class ForbiddenException implements Exception {
  final String message;
  ForbiddenException(this.message);
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);
}

class ServerException implements Exception {
  final String message;
  ServerException(this.message);
}