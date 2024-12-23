// 📂 lib/gui/screens/env_theme_config_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/api_services/auth_provider.dart';
import '../../services/api_services/api_client.dart';
import '../../services/api_services/environment_service.dart';
import '../../services/config/environment_theme_config_manager.dart';
import '../../models/environment.dart';
import '../components/custom_button.dart';
import '../components/color_picker_dialog.dart';
import '../components/screen_scaffold.dart';
import '../components/info_card.dart';
import '../components/theme_preview.dart';
import '../../constants/gui_constants/app_spacing.dart';
import '../../constants/gui_constants/app_typography.dart';
import '../../constants/gui_constants/theme_constants.dart';
import '../../configs/api_config.dart';

class EnvThemeConfigScreen extends StatefulWidget {
  const EnvThemeConfigScreen({super.key});

  @override
  State<EnvThemeConfigScreen> createState() => _EnvThemeConfigScreenState();
}

class _EnvThemeConfigScreenState extends State<EnvThemeConfigScreen> {
  late final ApiClient _apiClient;
  late final EnvironmentService _environmentService;
  late final EnvironmentThemeConfigManager _configManager;

  bool _isLoading = false;
  String? _error;

  // Theme configuration state
  Color _primaryColor = Colors.blue;
  Color _secondaryColor = Colors.green;
  Color _backgroundColor = Colors.white;
  Color _textColor = Colors.black;
  String _fontFamily = ThemeConstants.defaultFontFamily;
  double _fontSizeScale = 1.0;
  Environment? _selectedEnvironment;
  List<Environment> _environments = [];

  @override
  void initState() {
    super.initState();
    _apiClient = ApiClient(baseUrl: ApiConfig.baseUrl);
    _environmentService = EnvironmentService(_apiClient);
    _configManager = EnvironmentThemeConfigManager(apiClient: _apiClient);
    _loadEnvironments();
  }

  Future<void> _loadEnvironments() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      _environments = await _environmentService.getAllEnvironments();

      if (_environments.isNotEmpty) {
        await _selectEnvironment(_environments.first);
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _selectEnvironment(Environment environment) async {
    setState(() {
      _selectedEnvironment = environment;
      _isLoading = true;
      _error = null;
    });

    try {
      final themeSettings = await _configManager.getEnvironmentTheme(environment.id);

      if (themeSettings != null) {
        setState(() {
          _primaryColor = _colorFromHex(themeSettings['primary_color']);
          _secondaryColor = _colorFromHex(themeSettings['secondary_color']);
          _backgroundColor = _colorFromHex(themeSettings['background_color']);
          _textColor = _colorFromHex(themeSettings['text_color']);
          _fontFamily = themeSettings['font_family'];
          _fontSizeScale = themeSettings['font_size_scale'];
        });
      } else {
        // Set defaults if no existing configuration
        _resetToDefaults();
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _resetToDefaults() {
    setState(() {
      _primaryColor = Colors.blue;
      _secondaryColor = Colors.green;
      _backgroundColor = Colors.white;
      _textColor = Colors.black;
      _fontFamily = ThemeConstants.defaultFontFamily;
      _fontSizeScale = 1.0;
    });
  }

  Color _colorFromHex(String hexString) {
    final hex = hexString.replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  Future<void> _handleSaveConfiguration() async {
    if (_selectedEnvironment == null) {
      setState(() {
        _error = 'Please select an environment first';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final themeSettings = {
        'primary_color': _colorToHex(_primaryColor),
        'secondary_color': _colorToHex(_secondaryColor),
        'background_color': _colorToHex(_backgroundColor),
        'text_color': _colorToHex(_textColor),
        'font_family': _fontFamily,
        'font_size_scale': _fontSizeScale,
      };

      await _configManager.saveEnvironmentConfig(
        environment: _selectedEnvironment!,
        themeSettings: themeSettings,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Theme configuration saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to save configuration: ${e.toString()}';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;

    // Only show this screen to admin users
    if (currentUser?.id != 1) {
      return const Scaffold(
        body: Center(
          child: Text('You do not have permission to access this section.'),
        ),
      );
    }

    return ScreenScaffold(
      title: 'Environment Theme Configuration',
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_error != null) ...[
              InfoCard(
                title: 'Error',
                content: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],

            // Environment Selection
            InfoCard(
              title: 'Select Environment',
              content: DropdownButtonFormField<Environment>(
                value: _selectedEnvironment,
                decoration: const InputDecoration(
                  labelText: 'Environment',
                  border: OutlineInputBorder(),
                ),
                items: _environments.map((env) {
                  return DropdownMenuItem(
                    value: env,
                    child: Text('${env.name} - ${env.description}'),
                  );
                }).toList(),
                onChanged: (env) {
                  if (env != null) _selectEnvironment(env);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Colors Section
            InfoCard(
              title: 'Colors',
              content: Column(
                children: [
                  _buildColorPicker(
                    'Primary Color',
                    _primaryColor,
                        (color) => setState(() => _primaryColor = color),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildColorPicker(
                    'Secondary Color',
                    _secondaryColor,
                        (color) => setState(() => _secondaryColor = color),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildColorPicker(
                    'Background Color',
                    _backgroundColor,
                        (color) => setState(() => _backgroundColor = color),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildColorPicker(
                    'Text Color',
                    _textColor,
                        (color) => setState(() => _textColor = color),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Typography Section
            InfoCard(
              title: 'Typography',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Font Family',
                      border: OutlineInputBorder(),
                    ),
                    value: _fontFamily,
                    items: ThemeConstants.availableFontFamilies.map((font) {
                      return DropdownMenuItem(
                        value: font,
                        child: Text(font, style: TextStyle(fontFamily: font)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _fontFamily = value);
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text('Font Size Scale', style: theme.textTheme.titleSmall),
                  Slider(
                    value: _fontSizeScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 12,
                    label: _fontSizeScale.toStringAsFixed(2),
                    onChanged: (value) {
                      setState(() => _fontSizeScale = value);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Theme Preview
            InfoCard(
              title: 'Live Preview',
              content: SizedBox(
                height: 400,
                child: ThemePreview(
                  primaryColor: _primaryColor,
                  secondaryColor: _secondaryColor,
                  backgroundColor: _backgroundColor,
                  textColor: _textColor,
                  fontFamily: _fontFamily,
                  fontScale: _fontSizeScale,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xl),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomButton(
                  text: 'Reset to Defaults',
                  onPressed: _resetToDefaults,
                  variant: ButtonVariant.outline,
                ),
                const SizedBox(width: AppSpacing.md),
                CustomButton(
                  text: 'Save Configuration',
                  onPressed: _handleSaveConfiguration,
                  variant: ButtonVariant.primary,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorPicker(
      String label,
      Color color,
      ValueChanged<Color> onColorChanged,
      ) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: AppTypography.body),
        ),
        const SizedBox(width: AppSpacing.md),
        InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => ColorPickerDialog(
                initialColor: color,
                onColorSelected: onColorChanged,
              ),
            );
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}