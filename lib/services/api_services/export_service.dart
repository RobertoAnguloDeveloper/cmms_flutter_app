import 'dart:typed_data';
import 'api_client.dart';

class ExportService {
  final ApiClient _apiClient;

  ExportService(this._apiClient);

  /// Export a form to PDF or DOCX format
  Future<Uint8List> exportForm(
      int formId, {
        String format = 'PDF',
        String pageSize = 'A4',
        double? marginTop,
        double? marginBottom,
        double? marginLeft,
        double? marginRight,
        double? lineSpacing,
        int? fontSize,
        String? logoPath,
      }) async {
    try {
      final response = await _apiClient.get(
        '/api/export/form/$formId',
        queryParameters: {
          'format': format,
          'page_size': pageSize,
          if (marginTop != null) 'margin_top': marginTop,
          if (marginBottom != null) 'margin_bottom': marginBottom,
          if (marginLeft != null) 'margin_left': marginLeft,
          if (marginRight != null) 'margin_right': marginRight,
          if (lineSpacing != null) 'line_spacing': lineSpacing,
          if (fontSize != null) 'font_size': fontSize,
          if (logoPath != null) 'logo_path': logoPath,
        },
      );

      // Convert response data to Uint8List for file handling
      return Uint8List.fromList(response.data);
    } catch (e) {
      rethrow;
    }
  }

  /// Get available export formats
  Future<Map<String, dynamic>> getExportFormats() async {
    try {
      final response = await _apiClient.get('/api/export/formats');
      return {
        'formats': response.data['formats'],
        'default': response.data['default'],
      };
    } catch (e) {
      rethrow;
    }
  }

  /// Get export parameters and their configurations
  Future<Map<String, dynamic>> getExportParameters() async {
    try {
      final response = await _apiClient.get('/api/export/parameters');
      return response.data['parameters'];
    } catch (e) {
      rethrow;
    }
  }

  /// Preview export parameters for a specific form
  Future<Map<String, dynamic>> previewExportParameters(int formId) async {
    try {
      final response = await _apiClient.get('/api/export/form/$formId/preview-params');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}