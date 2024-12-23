// 📂 lib/services/api_services/api_client.dart

import 'dart:convert';
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

/// Token data model for managing authentication tokens
class TokenData {
  final String token;
  final DateTime expirationDate;

  TokenData({
    required this.token,
    required this.expirationDate,
  });

  factory TokenData.fromJson(Map<String, dynamic> json) {
    return TokenData(
      token: json['token'] as String,
      expirationDate: DateTime.parse(json['expiration_date'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'token': token,
    'expiration_date': expirationDate.toIso8601String(),
  };

  bool get isExpired => DateTime.now().isAfter(expirationDate);
}

/// Main API client class that handles all HTTP communication
class ApiClient {
  late final Dio _dio;
  final String baseUrl;
  final _storage = const FlutterSecureStorage();
  static const String _tokenKey = 'auth_token';
  static const String _tokenDataKey = 'auth_token_data';
  static const Duration _defaultTimeout = Duration(seconds: 30);
  final Function()? onTokenExpired;

  ApiClient({
    required this.baseUrl,
    this.onTokenExpired,
  }) {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      receiveTimeout: _defaultTimeout,
      connectTimeout: _defaultTimeout,
      sendTimeout: _defaultTimeout,
      validateStatus: (status) => true,
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      // Ensure headers are merged, not replaced
      contentType: 'application/json',
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
          final tokenData = await _getTokenData();
          if (kDebugMode) {
            print('Token Data: $tokenData');
          }

          if (tokenData != null) {
            if (tokenData.isExpired) {
              if (kDebugMode) {
                print('Token is expired - clearing token');
              }
              await clearToken();
              onTokenExpired?.call();
              return handler.reject(
                  DioException(
                    requestOptions: options,
                    error: 'Token expired',
                    type: DioExceptionType.badResponse,
                  )
              );
            }

            // Add the Authorization header
            final bearerToken = 'Bearer ${tokenData.token}';
            options.headers['Authorization'] = bearerToken;

            if (kDebugMode) {
              print('Setting Authorization header to: $bearerToken');
            }
          }

          return handler.next(options);
        } catch (e) {
          print('Error in request interceptor: $e');
          return handler.next(options);
        }
      },

      onResponse: (response, handler) async {
        try {
          // Handle new token from login
          if (response.requestOptions.path.contains('login') &&
              response.statusCode == 200 &&
              response.data is Map &&
              response.data['access_token'] != null) {

            final token = response.data['access_token'] as String;
            // Get expiration from JWT if possible or use default 1 hour
            final expiresIn = response.data['expires_in'] as int? ?? 3600;

            await saveTokenData(TokenData(
              token: token,
              expirationDate: DateTime.now().add(Duration(seconds: expiresIn)),
            ));

            if (kDebugMode) {
              print('New token saved after login');
            }
          }
        } catch (e) {
          print('Error handling response: $e');
        }

        return handler.next(response);
      },

      onError: (error, handler) async {
        // Only clear token for specific error cases
        if (error.response?.statusCode == 401 ||
            (error.response?.statusCode == 422 &&
                error.response?.data['msg'] == 'Signature verification failed')) {
          await clearToken();
          onTokenExpired?.call();
        }
        return handler.next(error);
      },
    ));
  }

  /// Token management methods
  Future<void> saveTokenData(TokenData tokenData) async {
    try {
      await _storage.write(
        key: _tokenDataKey,
        value: jsonEncode(tokenData.toJson()),
      );
    } catch (e) {
      print('Error saving token data: $e');
      rethrow;
    }
  }

  Future<void> clearToken() async {
    try {
      await _storage.delete(key: _tokenDataKey);
      if (kDebugMode) {
        print('Token cleared');
      }
    } catch (e) {
      print('Error clearing token: $e');
    }
  }

  Future<TokenData?> _getTokenData() async {
    try {
      final tokenDataStr = await _storage.read(key: _tokenDataKey);
      if (tokenDataStr == null) {
        return null;
      }

      final tokenData = TokenData.fromJson(
          jsonDecode(tokenDataStr) as Map<String, dynamic>
      );

      // Only clear if expired
      if (tokenData.isExpired) {
        await clearToken();
        return null;
      }

      return tokenData;
    } catch (e) {
      print('Error getting token data: $e');
      return null;
    }
  }

  Future<String?> getToken() async {
    try {
      final tokenData = await _getTokenData();
      if (tokenData != null) {
        if (kDebugMode) {
          print('Current token: ${tokenData.token}');
        }
        return tokenData.token;
      }
      return null;
    } catch (e) {
      print('Error in getToken: $e');
      return null;
    }
  }

  Future<bool> isAuthenticated() async {
    try {
      final tokenData = await _getTokenData();
      final isValid = tokenData != null && !tokenData.isExpired;
      if (kDebugMode) {
        print('Authentication status: $isValid');
      }
      return isValid;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  /// Generic HTTP request methods
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

  /// Authentication specific methods
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
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
      print('Login error: $e');
      rethrow;
    }
  }
}