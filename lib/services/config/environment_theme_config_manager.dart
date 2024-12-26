// File: lib/services/config/environment_theme_config_manager.dart

import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../models/environment.dart';
import '../api_services/api_client.dart';
import '../api_services/cmms_config_provider.dart';


class EnvironmentThemeConfigManager {
  final CmmsConfigProvider _configProvider;
  final ApiClient _apiClient;
  static const String configFilename = 'config.json';

  EnvironmentThemeConfigManager({required ApiClient apiClient})
      : _configProvider = CmmsConfigProvider(apiClient: apiClient),
      _apiClient = apiClient;

  // Add new methods for file handling
  Future<void> uploadConfig(MultipartFile file) async {
    try {
      await _configProvider.uploadConfig(file);
    } catch (e) {
      print('Error uploading config: $e');
      rethrow;
    }
  }

  Future<Uint8List> downloadConfig(String filename) async {
    try {
      final response = await _apiClient.get(  // Use _apiClient instead
        '/api/cmms-configs/file/$filename',
        options: Options(responseType: ResponseType.bytes),
      );

      if (response.data is! Uint8List) {
        throw Exception('Invalid response type');
      }

      return response.data as Uint8List;
    } catch (e) {
      print('Error downloading config: $e');
      rethrow;
    }
  }

  /// Check if config file exists
  Future<bool> checkConfigExists() async {
    try {
      final response = await _configProvider.checkConfig();
      return response['exists'] as bool;
    } catch (e) {
      print('Error checking config existence: $e');
      return false;
    }
  }


  /// Create initial configuration file
  Future<void> createInitialConfig() async {
    try {
      await _configProvider.saveConfig(
        filename: configFilename,
        content: {
          'name': 'Environment Themes Configuration',
          'description': 'Theme configurations for all environments',
          'environments': [],
        },
      );
    } catch (e) {
      print('Error creating initial config: $e');
      rethrow;
    }
  }

  /// Save configuration for a specific environment
  Future<void> saveEnvironmentConfig({
    required Environment environment,
    required Map<String, dynamic> themeSettings,
  }) async {
    try {
      // First check if config exists
      final configExists = await checkConfigExists();
      final baseContent = {
        'name': 'Environment Themes Configuration',
        'description': 'Theme configurations for all environments',
        'environments': [],
      };

      if (!configExists) {
        // Create initial config with first environment
        baseContent['environments'] = [
          {
            'name': 'Environment Theme Configuration',
            'description': 'Theme configuration for environment',
            'parameters': {
              'environment_id': environment.id,
              'environment_name': environment.name,
              'theme_settings': themeSettings,
            }
          }
        ];

        await _configProvider.saveConfig(
          filename: configFilename,
          content: baseContent,
          useUpdate: false,
        );
        return;
      }

      // Load existing config
      await _configProvider.loadConfig(configFilename);
      final currentConfig = _configProvider.currentConfig;

      if (currentConfig == null || !currentConfig.content.containsKey('environments')) {
        throw Exception('Invalid configuration format');
      }

      // Get existing environments
      List<Map<String, dynamic>> environments = List<Map<String, dynamic>>.from(
        currentConfig.content['environments'] as List,
      );

      // Find existing environment config or prepare new one
      final envIndex = environments.indexWhere(
            (env) => env['parameters']?['environment_id'] == environment.id,
      );

      final newEnvConfig = {
        'name': 'Environment Theme Configuration',
        'description': 'Theme configuration for environment',
        'parameters': {
          'environment_id': environment.id,
          'environment_name': environment.name,
          'theme_settings': themeSettings,
        }
      };

      if (envIndex >= 0) {
        // Update existing environment
        environments[envIndex] = newEnvConfig;
      } else {
        // Add new environment
        environments.add(newEnvConfig);
      }

      // Update the config using PUT endpoint
      await _configProvider.saveConfig(
        filename: configFilename,
        content: {
          'name': 'Environment Themes Configuration',
          'description': 'Theme configurations for all environments',
          'environments': environments,
        },
        useUpdate: true,
      );
    } catch (e) {
      print('Error saving environment config: $e');
      rethrow;
    }
  }

  /// Get theme settings for a specific environment
  Future<Map<String, dynamic>?> getEnvironmentTheme(int environmentId) async {
    try {
      await _configProvider.loadConfig(configFilename);
      final config = _configProvider.currentConfig;

      if (config == null || !config.content.containsKey('environments')) {
        return null;
      }

      final environments = List<Map<String, dynamic>>.from(
        config.content['environments'] as List,
      );

      // Find the matching environment
      final envConfig = environments.firstWhere(
            (env) => env['parameters']?['environment_id'] == environmentId,
        orElse: () => {},
      );

      if (envConfig.isEmpty) return null;

      return envConfig['parameters']?['theme_settings'] as Map<String, dynamic>;
    } catch (e) {
      print('Error getting environment theme: $e');
      return null;
    }
  }

  /// Delete configuration for a specific environment
  Future<void> deleteEnvironmentConfig(int environmentId) async {
    try {
      await _configProvider.loadConfig(configFilename);
      final config = _configProvider.currentConfig;

      if (config == null || !config.content.containsKey('environments')) {
        return;
      }

      List<Map<String, dynamic>> environments = List<Map<String, dynamic>>.from(
        config.content['environments'] as List,
      );

      environments.removeWhere(
            (env) => env['parameters']['environment_id'] == environmentId,
      );

      await _configProvider.saveConfig(
        filename: configFilename,
        content: {
          'name': 'Environment Themes Configuration',
          'description': 'Theme configurations for all environments',
          'environments': environments,
        },
      );
    } catch (e) {
      print('Error deleting environment config: $e');
      rethrow;
    }
  }
}