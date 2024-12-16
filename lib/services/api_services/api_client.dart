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
      validateStatus: (status) {
        return status != null && status < 500;
      },
      // Essential for web CORS
      extra: {
        'withCredentials': true,
      },
    ));

    _initializeInterceptors();
  }

  /// Initialize Dio interceptors for logging, auth, and error handling
  void _initializeInterceptors() {
    // Add logging in debug mode
    if (!kReleaseMode) {
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

    // Add auth and error handling interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: _handleRequest,
      onResponse: _handleResponse,
      onError: _handleError,
    ));
  }

  Future<void> _handleRequest(
      RequestOptions options,
      RequestInterceptorHandler handler,
      ) async {
    // Set base headers
    options.headers.addAll({
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    });

    // Web-specific configuration
    if (kIsWeb) {
      // Remove any existing CORS headers to prevent conflicts
      options.headers.remove('Origin');

      options.headers.addAll({
        'X-Requested-With': 'XMLHttpRequest',
      });

      // Enable CORS credentials
      options.extra['withCredentials'] = true;
    }

    try {
      final token = await _storage.read(key: _tokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (e) {
      print('Error reading token: $e');
    }

    return handler.next(options);
  }

  /// Handle incoming responses
  void _handleResponse(
      Response response,
      ResponseInterceptorHandler handler,
      ) {
    // Extract and save token if present
    if (response.data is Map && response.data['access_token'] != null) {
      saveToken(response.data['access_token']);
    }

    return handler.next(response);
  }

  /// Handle errors
  Future<void> _handleError(
      DioException e,
      ErrorInterceptorHandler handler,
      ) async {
    print('Error Type: ${e.type}');
    print('Error Message: ${e.message}');
    print('Error Response: ${e.response}');

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException('Connection timed out. Please check your internet connection.');

      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        final responseData = e.response?.data;

        switch (statusCode) {
          case 400:
            throw ApiException(
              responseData?['error'] ?? 'Invalid request',
              statusCode,
            );
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

      case DioExceptionType.cancel:
        throw ApiException('Request was cancelled');

      case DioExceptionType.connectionError:
        throw NetworkException(
          kIsWeb
              ? 'Cross-Origin Request Blocked: Please ensure CORS is properly configured'
              : 'Connection error occurred. Please check your internet connection.',
        );

      default:
        throw ApiException('An unexpected error occurred');
    }
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
        return response.data;
      } else {
        throw ApiException(
          response.data?['error'] ?? 'Login failed: Invalid response format',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is DioException) {
        print('DioException details:');
        print('Type: ${e.type}');
        print('Message: ${e.message}');
        print('Response: ${e.response}');
      }
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