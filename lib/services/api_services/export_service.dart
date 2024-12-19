import 'package:dio/dio.dart';
import 'dart:typed_data';
import 'api_client.dart';

/// Custom exceptions for export operations
class ExportException implements Exception {
  final String message;
  final dynamic originalError;

  ExportException(this.message, [this.originalError]);

  @override
  String toString() => 'ExportException: $message${originalError != null ? ' ($originalError)' : ''}';
}

/// Supported export formats
enum ExportFormat {
  pdf('PDF'),
  docx('DOCX');

  final String value;
  const ExportFormat(this.value);
}

/// Supported page sizes
enum PageSize {
  a4('A4'),
  letter('Letter'),
  legal('Legal');

  final String value;
  const PageSize(this.value);
}

/// Response model for export formats
class ExportFormatsResponse {
  final List<String> formats;
  final String defaultFormat;

  ExportFormatsResponse({
    required this.formats,
    required this.defaultFormat,
  });

  factory ExportFormatsResponse.fromJson(Map<String, dynamic> json) {
    return ExportFormatsResponse(
      formats: List<String>.from(json['formats'] ?? []),
      defaultFormat: json['default'] ?? 'PDF',
    );
  }
}

/// Response model for export parameters
class ExportParameters {
  final Map<String, dynamic> parameters;

  ExportParameters({required this.parameters});

  factory ExportParameters.fromJson(Map<String, dynamic> json) {
    return ExportParameters(
      parameters: json['parameters'] ?? {},
    );
  }
}

/// Service class for handling form exports and related operations
class ExportService {
  final ApiClient _apiClient;
  static const String _basePath = '/api/export';

  ExportService(this._apiClient);

  /// Export a form to PDF or DOCX format
  /// Returns the file as a Uint8List for download
  Future<Uint8List> exportForm(
      int formId, {
        ExportFormat format = ExportFormat.pdf,
        PageSize pageSize = PageSize.a4,
      }) async {
    try {
      final response = await _apiClient.get(
        '$_basePath/form/$formId',
        queryParameters: {
          'format': format.value,
          'page_size': pageSize.value,
        },
        options: Options(
          responseType: ResponseType.bytes,
          headers: {
            'Accept': format == ExportFormat.pdf
                ? 'application/pdf'
                : 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
          },
        ),
      );

      if (response.data is List<int>) {
        return Uint8List.fromList(response.data as List<int>);
      }

      throw ExportException('Invalid response format: expected binary data');
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ExportException('Failed to export form', e);
    }
  }

  /// Get available export formats
  Future<ExportFormatsResponse> getExportFormats() async {
    try {
      final response = await _apiClient.get('$_basePath/formats');
      return ExportFormatsResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ExportException('Failed to get export formats', e);
    }
  }

  /// Get export parameters and their configurations
  Future<ExportParameters> getExportParameters() async {
    try {
      final response = await _apiClient.get('$_basePath/parameters');
      return ExportParameters.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ExportException('Failed to get export parameters', e);
    }
  }

  /// Preview export parameters for a specific form
  Future<Map<String, dynamic>> previewExportParameters(int formId) async {
    try {
      final response = await _apiClient.get('$_basePath/form/$formId/preview-params');
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ExportException('Failed to preview export parameters', e);
    }
  }

  /// Handle DioException errors
  Exception _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final errorMessage = e.response?.data['error'] as String? ?? e.message;

    switch (statusCode) {
      case 404:
        return ExportException('Form not found: $errorMessage');
      case 400:
        return ExportException('Invalid export parameters: $errorMessage');
      case 401:
        return ExportException('Unauthorized: $errorMessage');
      case 403:
        return ExportException('Permission denied: $errorMessage');
      default:
        return ExportException('Export operation failed: $errorMessage');
    }
  }
}