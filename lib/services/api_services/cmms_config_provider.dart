// 📂 lib/services/api_services/cmms_config_provider.dart

import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../../models/cmms_config.dart';
import 'cmms_config_service.dart';
import 'api_client.dart';
import '../../configs/api_config.dart';

class CmmsConfigProvider with ChangeNotifier {
  final CmmsConfigService _configService;
  CmmsConfig? _currentConfig;
  bool _isLoading = false;
  String? _error;

  CmmsConfigProvider() : _configService = CmmsConfigService(ApiClient(baseUrl: ApiConfig.baseUrl));

  CmmsConfig? get currentConfig => _currentConfig;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConfig(String filename) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentConfig = await _configService.loadConfig(filename);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveConfig({
    required String filename,
    required Map<String, dynamic> content,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentConfig = await _configService.createConfig(
        filename: filename,
        content: content,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> uploadConfig(MultipartFile file) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentConfig = await _configService.uploadConfig(file);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> renameConfig(String newFilename) async {
    if (_currentConfig == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _currentConfig = await _configService.renameConfig(
        _currentConfig!.filename,
        newFilename,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteConfig() async {
    if (_currentConfig == null) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _configService.deleteConfig(_currentConfig!.filename);
      _currentConfig = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}