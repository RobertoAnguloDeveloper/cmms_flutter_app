import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Custom exception types for better error handling
abstract class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class ApiException extends AppException {
  ApiException(String message, [int? statusCode]) : super(message, statusCode);
}

class TimeoutException extends AppException {
  TimeoutException(String message) : super(message);
}

class NetworkException extends AppException {
  NetworkException(String message) : super(message);
}

class UnauthorizedException extends AppException {
  UnauthorizedException(String message) : super(message, 401);
}

class ForbiddenException extends AppException {
  ForbiddenException(String message) : super(message, 403);
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 404);
}

class ConflictException extends AppException {
  ConflictException(String message) : super(message, 409);
}

class ServerException extends AppException {
  ServerException(String message, [int? statusCode]) : super(message, statusCode);
}

/// Main API client class that handles all HTTP communication
class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const Duration _defaultTimeout = Duration(seconds: 30);

  /// Creates an instance of ApiClient with the given base URL
  ApiClient({required this.baseUrl}) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      receiveTimeout: _defaultTimeout,
      connectTimeout: _defaultTimeout,
      sendTimeout: _defaultTimeout,
      validateStatus: (status) => true,
      headers: _defaultHeaders,
    ));
    _initializeInterceptors();
  }

  Map<String, String> get _defaultHeaders => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  void _initializeInterceptors() {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
        requestHeader: true,
        responseHeader: true,
        logPrint: (object) {
          print('DIO LOG: $object');
        },
      ));
    }

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await _storage.read(key: _tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (e) {
          print('Error reading token: $e');
        }
        return handler.next(options);
      },
      onResponse: (response, handler) async {
        if (response.data is Map && response.data['access_token'] != null) {
          await saveToken(response.data['access_token']);
        }
        return handler.next(response);
      },
      onError: (error, handler) async {
        print('Error Type: ${error.type}');
        print('Error Message: ${error.message}');
        print('Error Response: ${error.response}');

        if (error.type == DioExceptionType.badResponse) {
          final statusCode = error.response?.statusCode;
          final responseData = error.response?.data;

          switch (statusCode) {
            case 401:
              await clearToken();
              throw UnauthorizedException(
                responseData?['error'] ?? 'Unauthorized access',
              );
            case 403:
              throw ForbiddenException(
                responseData?['error'] ?? 'Access forbidden',
              );
            case 404:
              throw NotFoundException(
                responseData?['error'] ?? 'Resource not found',
              );
            case 409:
              throw ConflictException(
                responseData?['error'] ?? 'Conflict occurred',
              );
            default:
              throw ServerException(
                responseData?['error'] ?? 'Server error occurred',
                statusCode,
              );
          }
        }

        if (error.type == DioExceptionType.connectionError) {
          throw NetworkException('Unable to connect to server');
        }

        return handler.next(error);
      },
    ));
  }

  /// Save auth token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  /// Clear auth token
  Future<void> clearToken() async {
    await _storage.delete(key: _tokenKey);
  }

  /// Get stored auth token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  /// Login user and get auth token
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      print('Attempting login to: $baseUrl/api/users/login');

      final response = await _dio.post(
        '/api/users/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200 && response.data['access_token'] != null) {
        await saveToken(response.data['access_token']);
        return response.data;
      } else {
        throw ApiException(
          response.data?['error'] ?? 'Login failed: Invalid response format',
          response.statusCode,
        );
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  /// Generic GET request
  Future<Response<T>> get<T>(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        void Function(int, int)? onReceiveProgress,
      }) async {
    try {
      return await _dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic POST request
  Future<Response<T>> post<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
      }) async {
    try {
      return await _dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic PUT request
  Future<Response<T>> put<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
      }) async {
    try {
      return await _dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic DELETE request
  Future<Response<T>> delete<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
      }) async {
    try {
      return await _dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Generic PATCH request
  Future<Response<T>> patch<T>(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
        CancelToken? cancelToken,
        void Function(int, int)? onSendProgress,
        void Function(int, int)? onReceiveProgress,
      }) async {
    try {
      return await _dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } catch (e) {
      rethrow;
    }
  }
}