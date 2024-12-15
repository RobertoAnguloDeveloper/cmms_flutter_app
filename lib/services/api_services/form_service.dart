import 'api_client.dart';
import '../../models/form.dart';
import '../../models/form_submission.dart';

class FormService {
  final ApiClient _apiClient;

  FormService(this._apiClient);

  Future<List<Form>> getAllForms() async {
    try {
      final response = await _apiClient.get('/api/forms');
      return (response.data as List)
          .map((json) => Form.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Form>> getPublicForms() async {
    try {
      final response = await _apiClient.get('/api/forms/public');
      return (response.data as List)
          .map((json) => Form.fromJson(json))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Form> createForm({
    required String title,
    String? description,
    bool isPublic = false,
  }) async {
    try {
      final response = await _apiClient.post('/api/forms',
          data: {
            'title': title,
            'description': description,
            'is_public': isPublic,
          });
      return Form.fromJson(response.data['form']);
    } catch (e) {
      rethrow;
    }
  }

  Future<Form> updateForm(
      int formId, {
        String? title,
        String? description,
        bool? isPublic,
      }) async {
    try {
      final response = await _apiClient.put(
        '/api/forms/$formId',
        data: {
          if (title != null) 'title': title,
          if (description != null) 'description': description,
          if (isPublic != null) 'is_public': isPublic,
        },
      );
      return Form.fromJson(response.data['form']);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteForm(int formId) async {
    try {
      await _apiClient.delete('/api/forms/$formId');
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getFormStatistics(int formId) async {
    try {
      final response = await _apiClient.get('/api/forms/$formId/statistics');
      return response.data;
    } catch (e) {
      rethrow;
    }
  }
}